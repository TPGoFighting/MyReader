import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../../providers/reader_provider.dart';
import '../../models/novel_model.dart';

class ReaderScreen extends StatefulWidget {
  final String novelId;
  final String chapterId;
  final String chapterTitle;
  final String content;
  final NovelModel novel;

  const ReaderScreen({
    super.key,
    required this.novelId,
    required this.chapterId,
    required this.chapterTitle,
    required this.content,
    required this.novel,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late ReaderProvider _readerProvider;
  late Box _chapterCacheBox;
  bool _showMenu = false;
  int _currentChapterIndex = 0;

  @override
  void initState() {
    super.initState();
    _readerProvider = Provider.of<ReaderProvider>(context, listen: false);
    _chapterCacheBox = Hive.box('chapter_cache');
    _readerProvider.initConfig();
    _readerProvider.saveReadProgress(widget.novelId, widget.chapterId);
    
    _currentChapterIndex = widget.novel.chapters.indexWhere(
      (chapter) => chapter.chapterId == widget.chapterId,
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _cacheChapter(widget.novel.chapters[_currentChapterIndex]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _cacheChapter(ChapterModel chapter) {
    _chapterCacheBox.put('${chapter.novelId}_${chapter.chapterId}', chapter);
  }

  void _switchChapter(int offset) {
    final newIndex = _currentChapterIndex + offset;
    if (newIndex < 0 || newIndex >= widget.novel.chapters.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(offset > 0 ? '已是最后一章' : '已是第一章')),
      );
      return;
    }

    setState(() {
      _currentChapterIndex = newIndex;
      final newChapter = widget.novel.chapters[newIndex];
      _readerProvider.saveReadProgress(widget.novelId, newChapter.chapterId);
      _cacheChapter(newChapter);
    });
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Text('章节列表', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: widget.novel.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = widget.novel.chapters[index];
                  return ListTile(
                    title: Text(
                      chapter.chapterTitle,
                      style: TextStyle(
                        color: index == _currentChapterIndex ? Colors.blue : Colors.black,
                        fontWeight: index == _currentChapterIndex ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _currentChapterIndex = index;
                        _readerProvider.saveReadProgress(widget.novelId, chapter.chapterId);
                        _cacheChapter(chapter);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = widget.novel.chapters[_currentChapterIndex];
    return Scaffold(
      backgroundColor: _readerProvider.bgColor,
      body: GestureDetector(
        onTap: () => setState(() => _showMenu = !_showMenu),
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 50) {
            _switchChapter(-1);
          } else if (velocity < -50) {
            _switchChapter(1);
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    currentChapter.chapterTitle,
                    style: TextStyle(
                      fontSize: _readerProvider.fontSize + 4,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentChapter.content,
                    style: TextStyle(
                      fontSize: _readerProvider.fontSize,
                      height: 1.8,
                      color: _readerProvider.bgColor == Colors.black87 ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (_showMenu)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          onPressed: _showChapterList,
                          child: const Text('章节列表', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () => _switchChapter(-1),
                              child: const Text('上一章', style: TextStyle(color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () => _switchChapter(1),
                              child: const Text('下一章', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.text_decrease, color: Colors.white),
                              onPressed: () => _readerProvider.setFontSize(_readerProvider.fontSize - 1),
                            ),
                            Text('字体大小', style: TextStyle(color: Colors.white, fontSize: _readerProvider.fontSize)),
                            IconButton(
                              icon: const Icon(Icons.text_increase, color: Colors.white),
                              onPressed: () => _readerProvider.setFontSize(_readerProvider.fontSize + 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _colorBtn(Colors.white),
                            _colorBtn(Colors.yellow[100]!),
                            _colorBtn(Colors.grey[200]!),
                            _colorBtn(Colors.black87),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _colorBtn(Color color) {
    return GestureDetector(
      onTap: () => _readerProvider.setBgColor(color),
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          border: _readerProvider.bgColor == color ? Border.all(color: Colors.red, width: 2) : null,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}