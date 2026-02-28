import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/novel_model.dart';

class BookmarkProvider extends ChangeNotifier {
  late Box _bookmarkBox;
  List<BookmarkModel> _bookmarks = [];

  List<BookmarkModel> get bookmarks => _bookmarks;

  Future<void> initBookmarks() async {
    _bookmarkBox = Hive.box('bookmarks');
    _loadBookmarks();
  }

  void _loadBookmarks() {
    _bookmarks = _bookmarkBox.values.cast<BookmarkModel>().toList();
    // 按时间倒序排列
    _bookmarks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  // 获取指定小说的书签
  List<BookmarkModel> getNovelBookmarks(String novelId) {
    return _bookmarks.where((b) => b.novelId == novelId).toList();
  }

  // 添加书签
  Future<void> addBookmark(BookmarkModel bookmark) async {
    await _bookmarkBox.add(bookmark);
    _loadBookmarks();
  }

  // 删除书签
  Future<void> removeBookmark(int index) async {
    final key = _bookmarkBox.keys.elementAt(index);
    await _bookmarkBox.delete(key);
    _loadBookmarks();
  }

  // 检查是否已存在相同位置的书签
  bool hasBookmarkAt(String novelId, String chapterId, int pageIndex) {
    return _bookmarks.any(
      (b) =>
          b.novelId == novelId &&
          b.chapterId == chapterId &&
          b.pageIndex == pageIndex,
    );
  }
}
