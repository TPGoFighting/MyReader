import 'package:hive/hive.dart';

part 'novel_model.g.dart';

// 小说主模型（包含chapters、category字段）
@HiveType(typeId: 0)
class NovelModel extends HiveObject {
  @HiveField(0)
  late String id; // 小说ID

  @HiveField(1)
  late String title; // 标题

  @HiveField(2)
  late String author; // 作者

  @HiveField(3)
  late String cover; // 封面（占位图）

  @HiveField(4)
  late String latestChapter; // 最新章节

  @HiveField(5)
  late String category; // 分类（解决category未定义）

  @HiveField(6)
  late List<ChapterModel> chapters; // 章节列表（解决chapters未定义）

  NovelModel({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.latestChapter,
    required this.category,
    required this.chapters,
  });
}

// 章节模型
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

// 模拟数据工具类（解决NovelMockData未定义）
class NovelMockData {
  // 生成模拟章节内容
  static String generateContent() {
    return """
      清晨的阳光透过窗棂，洒在青石板铺就的小院里，带着淡淡的草木清香。
      少年坐在石凳上，手中握着一本泛黄的古籍，指尖轻轻拂过书页上的字迹，眼中满是专注。
      这是他来到这个世界的第三个月，从最初的迷茫，到如今的适应，一切都像一场不真实的梦。
      “该去练剑了。”他轻声自语，收起古籍，起身走向院中的剑台。
      剑身轻鸣，划破空气，一道道剑光如流水般挥洒，带着少年对未来的期许，也带着对过往的释然。
      远处的山林间传来鸟鸣，清脆而悦耳，仿佛在为这少年的努力喝彩。
      他知道，想要在这个强者林立的世界立足，唯有不断前行，不曾停歇。
    """;
  }

  // 模拟小说列表
  static List<NovelModel> getNovelList() {
    return [
      NovelModel(
        id: '1',
        title: '剑起苍澜',
        author: '清风客',
        cover: 'https://picsum.photos/200/300?random=1',
        latestChapter: '第100章：剑指天涯',
        category: '玄幻',
        chapters: List.generate(100, (index) => ChapterModel(
          novelId: '1',
          chapterId: '1_${index+1}',
          chapterTitle: '第${index+1}章：${index==0?'初入江湖':index==99?'剑指天涯':'风雨兼程'}',
          content: generateContent(),
        )),
      ),
      NovelModel(
        id: '2',
        title: '都市风云',
        author: '夜行者',
        cover: 'https://picsum.photos/200/300?random=2',
        latestChapter: '第88章：商业帝国',
        category: '都市',
        chapters: List.generate(88, (index) => ChapterModel(
          novelId: '2',
          chapterId: '2_${index+1}',
          chapterTitle: '第${index+1}章：${index==0?'初入都市':index==87?'商业帝国':'步步为营'}',
          content: generateContent(),
        )),
      ),
      NovelModel(
        id: '3',
        title: '浮生若梦',
        author: '月下客',
        cover: 'https://picsum.photos/200/300?random=3',
        latestChapter: '第50章：江南烟雨',
        category: '言情',
        chapters: List.generate(50, (index) => ChapterModel(
          novelId: '3',
          chapterId: '3_${index+1}',
          chapterTitle: '第${index+1}章：${index==0?'初见':index==49?'江南烟雨':'情不知所起'}',
          content: generateContent(),
        )),
      ),
    ];
  }

  // 小说分类列表
  static List<String> getCategoryList() => ['全部', '玄幻', '都市', '言情'];
}