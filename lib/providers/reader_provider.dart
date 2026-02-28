import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderProvider extends ChangeNotifier {
  double fontSize = 18.0;
  Color bgColor = const Color(0xFFF5F5DC); // 默认羊皮纸色

  // 初始化配置
  Future<void> initConfig() async {
    final prefs = await SharedPreferences.getInstance();
    fontSize = prefs.getDouble('fontSize') ?? 18.0;
    final bgColorValue = prefs.getInt('bgColor');
    if (bgColorValue != null) {
      bgColor = Color(bgColorValue);
    }
    notifyListeners();
  }

  // 必须实现此方法，否则 ReaderScreen 翻页会报方法未找到错误（红屏）
  Future<void> saveReadProgress(String novelId, String chapterId, int chapterIndex) async {
    try {
      var box = Hive.box('read_progress');
      await box.put('current_novel_id', novelId);
      await box.put('current_chapter_id', chapterId);
      await box.put('${novelId}_progress', chapterIndex);
      await box.put('${novelId}_last_read', DateTime.now().millisecondsSinceEpoch);
      // 进度保存属于后台操作，不需要调 notifyListeners，避免翻页掉帧
    } catch (e) {
      debugPrint("进度保存失败: $e");
    }
  }

  // 获取小说阅读进度
  int getReadProgress(String novelId) {
    try {
      var box = Hive.box('read_progress');
      return box.get('${novelId}_progress', defaultValue: 0);
    } catch (e) {
      return 0;
    }
  }

  // 获取阅读进度百分比
  double getReadProgressPercent(String novelId, int totalChapters) {
    if (totalChapters == 0) return 0.0;
    int progress = getReadProgress(novelId);
    return (progress / totalChapters * 100).clamp(0.0, 100.0);
  }

  Future<void> setFontSize(double size) async {
    fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    notifyListeners();
  }

  Future<void> setBgColor(Color color) async {
    bgColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bgColor', color.value);
    notifyListeners();
  }
}