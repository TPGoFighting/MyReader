import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/novel_model.dart';

class BookshelfProvider extends ChangeNotifier {
  late Box _bookshelfBox;
  List<NovelModel> _novelList = [];

  List<NovelModel> get novelList => _novelList;

  // 初始化书架
  Future<void> initBookshelf() async {
    _bookshelfBox = Hive.box('bookshelf');
    // 首次打开，添加模拟数据到书架
    if (_bookshelfBox.isEmpty) {
      final mockNovels = NovelMockData.getNovelList();
      await _bookshelfBox.addAll(mockNovels);
      _novelList = mockNovels;
    } else {
      _novelList = _bookshelfBox.values.cast<NovelModel>().toList();
    }
    notifyListeners();
  }

  // 删除小说
  Future<void> removeNovel(String novelId) async {
    final index = _novelList.indexWhere((novel) => novel.id == novelId);
    if (index != -1) {
      await _bookshelfBox.deleteAt(index);
      _novelList.removeAt(index);
      notifyListeners();
    }
  }

  // 检查小说是否在书架
  bool isInBookshelf(String novelId) {
    return _novelList.any((novel) => novel.id == novelId);
  }

  // 添加小说到书架
  Future<void> addNovel(NovelModel novel) async {
    if (!isInBookshelf(novel.id)) {
      await _bookshelfBox.add(novel);
      _novelList.add(novel);
      notifyListeners();
    }
  }
}