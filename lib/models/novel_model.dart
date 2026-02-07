import 'package:hive/hive.dart';

// 生成适配器（执行 flutter packages pub run build_runner build）
part 'novel_model.g.dart';

@HiveType(typeId: 0)
class NovelModel extends HiveObject {
  @HiveField(0)
  late String id; // 小说ID

  @HiveField(1)
  late String title; // 标题

  @HiveField(2)
  late String author; // 作者

  @HiveField(3)
  late String cover; // 封面URL

  @HiveField(4)
  late String latestChapter; // 最新章节

  // 构造函数
  NovelModel({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.latestChapter,
  });
}

@HiveType(typeId: 1)
class ChapterModel extends HiveObject {
  @HiveField(0)
  late String novelId; // 所属小说ID

  @HiveField(1)
  late String chapterId; // 章节ID

  @HiveField(2)
  late String chapterTitle; // 章节标题

  @HiveField(3)
  late String content; // 章节内容

  ChapterModel({
    required this.novelId,
    required this.chapterId,
    required this.chapterTitle,
    required this.content,
  });
}