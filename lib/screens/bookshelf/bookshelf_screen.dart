import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:charset_converter/charset_converter.dart';
import 'package:epubx/epubx.dart' as epub;
import 'package:html/parser.dart' show parse;

import '../../providers/bookshelf_provider.dart';
import '../../models/novel_model.dart';
import '../reader/reader_screen.dart';

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _importLocalBook(BookshelfProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'epub'],
      );

      if (result == null || result.files.single.path == null) return;

      File file = File(result.files.single.path!);
      String fileName = path.basename(file.path);
      String extension = path.extension(file.path).toLowerCase();
      final String uniqueId = "local_${DateTime.now().millisecondsSinceEpoch}";

      NovelModel? newBook;

      if (extension == '.txt') {
        newBook = await _parseTxtFile(file, uniqueId, fileName);
      } else if (extension == '.epub') {
        newBook = await _parseEpubFile(file, uniqueId, fileName);
      }

      if (newBook != null) {
        provider.addNovel(newBook);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('《${newBook.title}》已加入书架')));
        }
      }
    } catch (e) {
      debugPrint("导入错误: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('解析失败：文件格式不规范或已损坏')));
      }
    }
  }

  Future<NovelModel> _parseTxtFile(File file, String id, String name) async {
    String content = "";
    try {
      content = await file.readAsString();
    } catch (e) {
      var bytes = await file.readAsBytes();
      content = await CharsetConverter.decode("GBK", bytes);
    }

    return NovelModel(
      id: id,
      title: name.replaceAll(".txt", ""),
      author: "本地导入",
      cover: "https://via.placeholder.com/150x200?text=TXT",
      latestChapter: "正文",
      category: "TXT",
      chapters: [
        ChapterModel(
          novelId: id,
          chapterId: "${id}_1",
          chapterTitle: "开始阅读",
          content: content,
        ),
      ],
    );
  }

  // --- 适配 epubx 4.0.0 的解析逻辑 ---
  Future<NovelModel?> _parseEpubFile(File file, String id, String name) async {
    try {
      List<int> bytes = await file.readAsBytes();
      epub.EpubBook epubBook = await epub.EpubReader.readBook(bytes);

      List<ChapterModel> tempChapters = [];

      // 遍历所有章节内容
      if (epubBook.Chapters != null) {
        for (var chapter in epubBook.Chapters!) {
          // 清洗 HTML
          String? htmlContent = chapter.HtmlContent;
          if (htmlContent == null || htmlContent.isEmpty) continue;

          var document = parse(htmlContent);
          String plainText = document.body?.text ?? "";

          if (plainText.trim().isNotEmpty) {
            tempChapters.add(
              ChapterModel(
                novelId: id,
                chapterId: "${id}_${tempChapters.length + 1}",
                chapterTitle: chapter.Title ?? "章节 ${tempChapters.length + 1}",
                content: plainText,
              ),
            );
          }
        }
      }

      if (tempChapters.isEmpty) return null;

      return NovelModel(
        id: id,
        title: epubBook.Title ?? name.replaceAll(".epub", ""),
        author: epubBook.Author ?? "未知作者",
        cover: "https://via.placeholder.com/150x200?text=EPUB",
        latestChapter: "共 ${tempChapters.length} 章节",
        category: "EPUB",
        chapters: tempChapters,
      );
    } catch (e) {
      debugPrint("EPUB 解析异常: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? null
            : IconButton(
                icon: const Icon(Icons.drive_folder_upload_rounded),
                onPressed: () => _importLocalBook(
                  Provider.of<BookshelfProvider>(context, listen: false),
                ),
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '搜索书架...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                onChanged: (value) => setState(() {}),
              )
            : const Text('我的书架'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Consumer<BookshelfProvider>(
        builder: (context, provider, child) {
          final displayList = provider.novelList
              .where(
                (novel) => novel.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
              )
              .toList();

          if (displayList.isEmpty) {
            return Center(
              child: Text(
                _isSearching ? '未找到相关书籍' : '书架空空如也\n点击左上角图标导入书籍',
                textAlign: TextAlign.center,
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.6,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final novel = displayList[index];
              return _buildBookCard(context, provider, novel);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    BookshelfProvider provider,
    NovelModel novel,
  ) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context, provider, novel),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReaderScreen(
              novel: novel,
              novelId: novel.id,
              chapterId: novel.chapters.isNotEmpty
                  ? novel.chapters[0].chapterId
                  : "0",
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                novel.cover,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      novel.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            novel.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    BookshelfProvider provider,
    NovelModel novel,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定要移除《${novel.title}》吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.removeNovel(novel.id);
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
