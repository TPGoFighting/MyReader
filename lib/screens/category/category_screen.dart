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

  void _filterNovels(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == '全部') {
        _filteredNovels = _allNovels;
      } else {
        _filteredNovels = _allNovels
            .where((novel) => novel.category == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听 BookshelfProvider 以便 UI 能够根据书架状态实时刷新
    final bookshelfProvider = Provider.of<BookshelfProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('小说分类')),
      body: Column(
        children: [
          // 1. 分类标签栏：这里只负责切换分类
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedCategory == category
                          ? Colors.blue
                          : Colors.grey[200],
                      foregroundColor: _selectedCategory == category
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () => _filterNovels(category), // 仅仅执行筛选
                    child: Text(category),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // 2. 小说列表：这里才是处理具体某本小说(novel)的地方
          Expanded(
            child: _filteredNovels.isEmpty
                ? const Center(child: Text('暂无该分类小说～'))
                : ListView.builder(
                    itemCount: _filteredNovels.length,
                    itemBuilder: (context, index) {
                      // 在这里定义的 novel 才能被下面的组件使用
                      final novel = _filteredNovels[index];
                      final bool isInBookshelf = bookshelfProvider
                          .isInBookshelf(novel.id);

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            novel.cover,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 50,
                                  color: Colors.grey,
                                  child: Icon(Icons.book),
                                ),
                          ),
                        ),
                        title: Text(novel.title),
                        subtitle: Text('作者：${novel.author}'),
                        trailing: TextButton(
                          onPressed: isInBookshelf
                              ? null // 如果已添加，禁用按钮
                              : () {
                                  bookshelfProvider.addNovel(novel);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('《${novel.title}》已加入书架'),
                                    ),
                                  );
                                },
                          child: Text(
                            isInBookshelf ? '已添加' : '加入书架',
                            style: TextStyle(
                              color: isInBookshelf ? Colors.grey : Colors.blue,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReaderScreen(
                                novel: novel,
                                novelId: novel.id,
                                chapterId: novel.chapters.isNotEmpty
                                    ? novel.chapters[0].chapterId
                                    : "1",
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
