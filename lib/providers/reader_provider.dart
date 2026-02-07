import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 基础版阅读状态管理，保证类能被引用
class ReaderProvider extends ChangeNotifier {
  double _fontSize = 18.0;
  Color _bgColor = Colors.white;
  String _novelId = '';
  String _currentChapterId = '';

  // getter方法
  double get fontSize => _fontSize;
  Color get bgColor => _bgColor;
  String get novelId => _novelId;
  String get currentChapterId => _currentChapterId;

  // 初始化配置
  Future<void> initConfig() async {
    final sp = await SharedPreferences.getInstance();
    _fontSize = sp.getDouble('font_size') ?? 18.0;
    _bgColor = Color(sp.getInt('bg_color') ?? Colors.white.value);
    notifyListeners();
  }

  // 修改字体大小
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble('font_size', size);
    notifyListeners();
  }

  // 修改背景色
  Future<void> setBgColor(Color color) async {
    _bgColor = color;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('bg_color', color.value);
    notifyListeners();
  }

  // 保存阅读进度
  Future<void> saveReadProgress(String novelId, String chapterId) async {
    _novelId = novelId;
    _currentChapterId = chapterId;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('current_novel_id', novelId);
    await sp.setString('current_chapter_id', chapterId);
    notifyListeners();
  }
}