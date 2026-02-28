import 'package:hive_flutter/hive_flutter.dart'; // 移除多余的hive/hive.dart导入
import '../models/novel_model.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(NovelModelAdapter());
    Hive.registerAdapter(ChapterModelAdapter());
    Hive.registerAdapter(BookmarkModelAdapter());

    await Hive.openBox('bookshelf');
    await Hive.openBox('read_progress');
    await Hive.openBox('chapter_cache');
    await Hive.openBox('bookmarks');
  }
}