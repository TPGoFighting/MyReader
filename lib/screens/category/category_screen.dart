import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/novel_model.dart';
import '../../providers/bookshelf_provider.dart';
import '../reader/reader_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = '全部';
  final List<String> _categories = NovelMockData.getCategoryList();
  late List<NovelModel> _allNovels;
  late List<NovelModel> _filteredNovels;

  @override
  void initState() {
    super.initState();
    _allNovels = NovelMockData.getNovelList();
    _filteredNovels = _allNovels;
  }

  // 筛选小说
  void _filterNovels(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == '全部') {
        _filteredNovels = _allNovels;
      } else {
        _filteredNovels = _allNovels.where((novel) => novel.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookshelfProvider = Provider.of<BookshelfProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('小说分类')),
      body: Column(
        children: [
          // 分类标签栏
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedCategory == category ? Colors.blue : Colors.grey[200],
                      foregroundColor: _selectedCategory == category ? Colors.white : Colors.black,
                    ),
                    onPressed: () => _filterNovels(category),
                    child: Text(category),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // 小说列表
          Expanded(
            child: _filteredNovels.isEmpty
                ? const Center(child: Text('暂无该分类小说～'))
                : ListView.builder(
                    itemCount: _filteredNovels.length,
                    itemBuilder: (context, index) {
                      final novel = _filteredNovels[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            novel.cover,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(novel.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('作者：${novel.author}'),
                            Text('最新章节：${novel.latestChapter}'),
                          ],
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            bookshelfProvider.addNovel(novel);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('《${novel.title}》已添加到书架')),
                            );
                          },
                          child: Text(
                            bookshelfProvider.isInBookshelf(novel.id) ? '已添加' : '加入书架',
                            style: TextStyle(
                              color: bookshelfProvider.isInBookshelf(novel.id) ? Colors.grey : Colors.blue,
                            ),
                          ),
                        ),
                        onTap: () {
                          // 点击进入阅读页
                          final firstChapter = novel.chapters.first;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReaderScreen(
                                novelId: novel.id,
                                chapterId: firstChapter.chapterId,
                                chapterTitle: firstChapter.chapterTitle,
                                content: firstChapter.content,
                                novel: novel,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}