import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/reader_provider.dart';
import '../../models/novel_model.dart';

class ReaderScreen extends StatefulWidget {
  final String novelId;
  final String chapterId;
  final NovelModel novel;

  const ReaderScreen({
    super.key,
    required this.novelId,
    required this.chapterId,
    required this.novel,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with WidgetsBindingObserver {
  late ReaderProvider _readerProvider;
  PageController? _pageController;

  // 状态控制
  bool _showMenu = false;
  bool _isLoading = true;

  // 数据源
  List<Map<String, dynamic>> _pagesData = [];
  int _currentIndex = 0;

  // 系统信息
  String _timeString = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _readerProvider = Provider.of<ReaderProvider>(context, listen: false);

    _readerProvider.initConfig();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _updateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _updateTime(),
    );

    // 关键：必须等待第一帧渲染完成，才能获取真实的 MediaQuery 尺寸进行分页计算
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePages();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final time =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    if (mounted && _timeString != time) {
      setState(() => _timeString = time);
    }
  }

  // --- 核心逻辑：精准行数分页算法 ---
  void _calculatePages() {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // 1. 计算可用显示区域 (扣除顶部标题 40 和底部信息 40)
    final size = MediaQuery.of(context).size;
    final double paddingH = 20.0;
    final double availableHeight = size.height - 80;
    final double availableWidth = size.width - (paddingH * 2);

    // 2. 根据字号和行高计算
    // 假设行高倍率为 1.8
    const double lineHeightMultiplier = 1.8;
    double lineHeight = _readerProvider.fontSize * lineHeightMultiplier;

    // 计算每页能容纳的行数（向下取整，确保不溢出）
    int maxLinesPerPage = (availableHeight / lineHeight).floor();

    // 计算每行大约能容纳的字符数
    int charsPerLine = (availableWidth / _readerProvider.fontSize).floor();

    List<Map<String, dynamic>> tempPages = [];
    int initialPage = 0;

    for (var chapter in widget.novel.chapters) {
      // 处理段落
      List<String> paragraphs = chapter.content.split(RegExp(r'\n+'));

      String currentPageContent = "";
      int currentLines = 0;
      int pageInChapter = 1;

      for (String para in paragraphs) {
        String cleanPara = para.trim();
        if (cleanPara.isEmpty) continue;

        // 模拟首行缩进
        String textToRender = "　　$cleanPara";

        // 计算这一段占多少行
        int paraLines = (textToRender.length / charsPerLine).ceil();

        // 如果当前页放不下了，就切分段落或新开一页
        if (currentLines + paraLines > maxLinesPerPage) {
          // 如果当前页已经有内容，先存为一页
          if (currentPageContent.isNotEmpty) {
            tempPages.add({
              "content": currentPageContent.trim(),
              "chapterTitle": chapter.chapterTitle,
              "pageNum": pageInChapter++,
            });
            currentPageContent = "";
            currentLines = 0;
          }

          // 如果单段文字极长，这里简单处理，实际可做更细的切分
          currentPageContent = "$textToRender\n";
          currentLines = paraLines;
        } else {
          currentPageContent += "$textToRender\n";
          currentLines += paraLines;
        }
      }

      // 添加章节最后一页
      if (currentPageContent.isNotEmpty) {
        tempPages.add({
          "content": currentPageContent.trim(),
          "chapterTitle": chapter.chapterTitle,
          "pageNum": pageInChapter,
        });
      }

      // 定位当前打开的章节
      if (chapter.chapterId == widget.chapterId && initialPage == 0) {
        initialPage = tempPages.length - pageInChapter;
      }
    }

    setState(() {
      _pagesData = tempPages;
      _currentIndex = (initialPage < 0) ? 0 : initialPage;
      _pageController = PageController(initialPage: _currentIndex);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.removeObserver(this);
    _pageController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: provider.bgColor,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // 阅读主体：禁止垂直滚动
                    GestureDetector(
                      onTapUp: (details) => _handleTap(details),
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _pagesData.length,
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                          provider.saveReadProgress(
                            widget.novelId,
                            "page_$index",
                          );
                        },
                        itemBuilder: (context, index) =>
                            _buildPage(_pagesData[index], provider),
                      ),
                    ),
                    if (_showMenu) ...[
                      _buildTopMenu(),
                      _buildBottomMenu(provider),
                    ],
                  ],
                ),
        );
      },
    );
  }

  // 构建单页：彻底移除 ScrollView
  Widget _buildPage(Map<String, dynamic> data, ReaderProvider provider) {
    bool isDark = provider.bgColor.computeLuminance() < 0.5;
    Color textColor = isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF333333);
    Color subColor = isDark ? Colors.white24 : Colors.black26;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部固定高度
          Container(
            height: 40,
            alignment: Alignment.bottomLeft,
            child: Text(
              data['chapterTitle'],
              style: TextStyle(fontSize: 12, color: subColor),
              maxLines: 1,
            ),
          ),
          // 正文 Expanded，不再包裹任何 ScrollView
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                data['content'],
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: provider.fontSize,
                  height: 1.8,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // 底部固定高度
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Icon(Icons.battery_std_rounded, size: 12, color: subColor),
                const SizedBox(width: 4),
                Text(
                  _timeString,
                  style: TextStyle(fontSize: 11, color: subColor),
                ),
                const Spacer(),
                Text(
                  "第 ${data['pageNum']} 页",
                  style: TextStyle(fontSize: 11, color: subColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;
    final x = details.globalPosition.dx;
    if (_showMenu) {
      setState(() => _showMenu = false);
    } else if (x < width * 0.3) {
      _pageController?.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else if (x > width * 0.7) {
      _pageController?.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _showMenu = true);
    }
  }

  // --- 菜单组件 (保持你原有的逻辑，优化了视觉) ---
  Widget _buildTopMenu() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.novel.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildBottomMenu(ReaderProvider provider) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.9),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text("字号", style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    value: provider.fontSize,
                    min: 14,
                    max: 30,
                    divisions: 8,
                    onChanged: (v) {
                      provider.setFontSize(v);
                      _calculatePages(); // 字号改变立即重算
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _colorDot(provider, const Color(0xFFF7F7F7), "简约"),
                _colorDot(provider, const Color(0xFFF0E6D2), "羊皮"),
                _colorDot(provider, const Color(0xFFCBE1CF), "护眼"),
                _colorDot(provider, const Color(0xFF1A1A1A), "夜间"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(ReaderProvider provider, Color color, String name) {
    bool isSel = provider.bgColor.value == color.value;
    return GestureDetector(
      onTap: () => provider.setBgColor(color),
      child: Column(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSel ? Colors.blue : Colors.white24,
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              color: isSel ? Colors.blue : Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
