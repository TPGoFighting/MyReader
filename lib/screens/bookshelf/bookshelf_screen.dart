import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bookshelf_provider.dart';
import '../../models/novel_model.dart';
import '../reader/reader_screen.dart';

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化书架数据
    Provider.of<BookshelfProvider>(context, listen: false).initBookshelf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的书架')),
      body: Consumer<BookshelfProvider>(
        builder: (context, provider, child) {
          if (provider.novelList.isEmpty) {
            return const Center(child: Text('书架为空，快去添加小说吧～'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 一行3个
              childAspectRatio: 2/3, // 封面比例
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: provider.novelList.length,
            itemBuilder: (context, index) {
              final novel = provider.novelList[index];
              return GestureDetector(
                onTap: () {
                  // 点击小说，进入阅读页（默认第一章）
                  final firstChapter = novel.chapters.first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReaderScreen(
                        novelId: novel.id,
                        chapterId: firstChapter.chapterId,
                        chapterTitle: firstChapter.chapterTitle,
                        content: firstChapter.content,
                        novel: novel, // 传递完整小说对象
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  // 长按删除
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('删除小说'),
                      content: Text('确定删除《${novel.title}》吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.removeNovel(novel.id);
                            Navigator.pop(context);
                          },
                          child: const Text('删除', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Column(
                  children: [
                    // 小说封面
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          novel.cover,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return const Icon(Icons.book, size: 50, color: Colors.grey);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // 小说标题（单行省略）
                    Text(
                      novel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    // 作者
                    Text(
                      novel.author,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}