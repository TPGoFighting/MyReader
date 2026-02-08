import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ReaderProvider extends ChangeNotifier {
  double fontSize = 18.0;
  Color bgColor = const Color(0xFFF5F5DC); // 默认羊皮纸色

  // 初始化配置
  void initConfig() {
    // 这里可以从本地读取保存的字体大小和背景色
  }

  // 必须实现此方法，否则 ReaderScreen 翻页会报方法未找到错误（红屏）
  Future<void> saveReadProgress(String novelId, String chapterId) async {
    try {
      var box = Hive.box('read_progress');
      await box.put('current_novel_id', novelId);
      await box.put('current_chapter_id', chapterId);
      // 进度保存属于后台操作，不需要调 notifyListeners，避免翻页掉帧
    } catch (e) {
      debugPrint("进度保存失败: $e");
    }
  }

  void setFontSize(double size) {
    fontSize = size;
    notifyListeners();
  }

  void setBgColor(Color color) {
    bgColor = color;
    notifyListeners();
  }
}