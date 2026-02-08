import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import '../models/novel_model.dart';

class BookshelfProvider extends ChangeNotifier {
  late Box _bookshelfBox;
  List<NovelModel> _novelList = [];

  List<NovelModel> get novelList => _novelList;

  Future<void> initBookshelf() async {
    _bookshelfBox = Hive.box('bookshelf');
    if (_bookshelfBox.isEmpty) {
      // 这里的 NovelMockData 确保你在 models 中已定义
      final mockNovels = NovelMockData.getNovelList();
      for (var novel in mockNovels) {
        await _bookshelfBox.add(novel);
      }
      _novelList = mockNovels;
    } else {
      _novelList = _bookshelfBox.values.cast<NovelModel>().toList();
    }
    notifyListeners();
  }

  // 导入本地文件
  Future<void> importLocalNovel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      String fileName = result.files.single.name.replaceAll('.txt', '');

      List<ChapterModel> chapters = _parseChapters(content, fileName);

      NovelModel newNovel = NovelModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: fileName,
        author: '本地导入',
        cover: 'https://via.placeholder.com/200x300.png?text=$fileName',
        latestChapter: chapters.isNotEmpty ? chapters.last.chapterTitle : '无章节',
        category: '本地',
        chapters: chapters,
      );

      await _bookshelfBox.add(newNovel);
      _novelList.add(newNovel);
      notifyListeners();
    }
  }

  List<ChapterModel> _parseChapters(String content, String novelId) {
    List<ChapterModel> chapters = [];
    RegExp regExp = RegExp(r'(第[0-9零一二三四五六七八九十百千]+[章回节][^\n]*)');
    Iterable<RegExpMatch> matches = regExp.allMatches(content);

    if (matches.isEmpty) {
      chapters.add(ChapterModel(
        novelId: novelId,
        chapterId: '${novelId}_1',
        chapterTitle: '开始阅读',
        content: content,
      ));
    } else {
      for (int i = 0; i < matches.length; i++) {
        int start = matches.elementAt(i).start;
        int end = (i + 1 < matches.length) ? matches.elementAt(i + 1).start : content.length;
        chapters.add(ChapterModel(
          novelId: novelId,
          chapterId: '${novelId}_${i + 1}',
          chapterTitle: matches.elementAt(i).group(0)!.trim(),
          content: content.substring(start, end).trim(),
        ));
      }
    }
    return chapters;
  }

  bool isInBookshelf(String novelId) => _novelList.any((n) => n.id == novelId);

  Future<void> addNovel(NovelModel novel) async {
    if (!isInBookshelf(novel.id)) {
      await _bookshelfBox.add(novel);
      _novelList.add(novel);
      notifyListeners();
    }
  }

  Future<void> removeNovel(String novelId) async {
    final index = _novelList.indexWhere((novel) => novel.id == novelId);
    if (index != -1) {
      await _bookshelfBox.deleteAt(index);
      _novelList.removeAt(index);
      notifyListeners();
    }
  }
}