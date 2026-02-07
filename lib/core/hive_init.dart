import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveInit {
  // 基础初始化，先不注册适配器（后续加模型时再补）
  static Future<void> init() async {
    await Hive.initFlutter();
    // 打开所需的存储箱
    await Hive.openBox('bookshelf');
    await Hive.openBox('read_progress');
  }
}