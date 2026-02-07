import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reader_provider.dart';

class ReaderScreen extends StatefulWidget {
  final String novelId;
  final String chapterId;
  final String chapterTitle;
  final String content;

  const ReaderScreen({
    super.key,
    required this.novelId,
    required this.chapterId,
    required this.chapterTitle,
    required this.content,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late ReaderProvider _readerProvider;
  bool _showMenu = false; // 是否显示阅读菜单

  @override
  void initState() {
    super.initState();
    _readerProvider = Provider.of<ReaderProvider>(context, listen: false);
    _readerProvider.initConfig();
    // 保存当前阅读进度
    _readerProvider.saveReadProgress(widget.novelId, widget.chapterId);
  }

  // 左右滑动翻页（简化版，实际需对接章节列表）
  void _onSwipe(double dx) {
    if (dx > 50) {
      // 左滑 → 上一章（需对接章节接口）
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('上一章')),
      );
    } else if (dx < -50) {
      // 右滑 → 下一章
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('下一章')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _readerProvider.bgColor,
      body: GestureDetector(
        // 点击屏幕显示/隐藏菜单
        onTap: () => setState(() => _showMenu = !_showMenu),
        // 滑动翻页
        onHorizontalDragEnd: (details) => _onSwipe(details.primaryVelocity ?? 0),
        child: Stack(
          children: [
            // 小说内容
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 章节标题
                  Text(
                    widget.chapterTitle,
                    style: TextStyle(
                      fontSize: _readerProvider.fontSize + 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 小说内容
                  Text(
                    widget.content,
                    style: TextStyle(
                      fontSize: _readerProvider.fontSize,
                      height: 1.8, // 行高，提升阅读体验
                    ),
                  ),
                ],
              ),
            ),

            // 阅读菜单（显示时才展示）
            if (_showMenu)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Column(
                    children: [
                      // 字体大小调节
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.text_decrease, color: Colors.white),
                            onPressed: () => _readerProvider.setFontSize(
                              _readerProvider.fontSize - 1,
                            ),
                          ),
                          const Text('字体大小', style: TextStyle(color: Colors.white)),
                          IconButton(
                            icon: const Icon(Icons.text_increase, color: Colors.white),
                            onPressed: () => _readerProvider.setFontSize(
                              _readerProvider.fontSize + 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 背景色选择
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _colorBtn(Colors.white),
                          _colorBtn(Colors.yellow[100]!),
                          _colorBtn(Colors.grey[200]!),
                          _colorBtn(Colors.black87),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 背景色选择按钮
  Widget _colorBtn(Color color) {
    return GestureDetector(
      onTap: () => _readerProvider.setBgColor(color),
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          border: _readerProvider.bgColor == color
              ? Border.all(color: Colors.red, width: 2)
              : null,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}