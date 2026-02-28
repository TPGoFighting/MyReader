import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../providers/reader_provider.dart';
import '../../providers/theme_provider.dart';

class MineScreen extends StatefulWidget {
  const MineScreen({super.key});

  @override
  State<MineScreen> createState() => _MineScreenState();
}

class _MineScreenState extends State<MineScreen> {
  late Box _readProgressBox;
  late Box _chapterCacheBox;
  String _currentNovelId = '';
  String _currentChapterId = '';

  @override
  void initState() {
    super.initState();
    _readProgressBox = Hive.box('read_progress');
    _chapterCacheBox = Hive.box('chapter_cache');
    _loadReadProgress();
  }

  // 加载阅读进度
  void _loadReadProgress() {
    setState(() {
      _currentNovelId = _readProgressBox.get('current_novel_id') ?? '';
      _currentChapterId = _readProgressBox.get('current_chapter_id') ?? '';
    });
  }

  // 清除缓存
  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定清除所有章节缓存吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await _chapterCacheBox.clear();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存已清除')),
                );
              }
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readerProvider = Provider.of<ReaderProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          // 夜间模式开关
          SwitchListTile(
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('夜间模式'),
            subtitle: Text(themeProvider.isDarkMode ? '已开启' : '已关闭'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          const Divider(height: 1),
          // 阅读进度
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('上次阅读'),
            subtitle: Text(
              _currentNovelId.isEmpty
                  ? '暂无阅读记录'
                  : '小说ID：$_currentNovelId | 章节ID：$_currentChapterId',
            ),
          ),
          const Divider(height: 1),
          // 阅读设置
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('阅读设置'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('字体大小设置'),
                  content: Slider(
                    value: readerProvider.fontSize,
                    min: 14,
                    max: 28,
                    divisions: 14,
                    label: '${readerProvider.fontSize.toInt()}号字',
                    onChanged: (value) {
                      readerProvider.setFontSize(value);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          // 清除缓存
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('清除缓存'),
            textColor: Colors.red,
            onTap: _clearCache,
          ),
          const Divider(height: 1),

          // 关于APP
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于MyReader'),
            subtitle: const Text('基于Flutter开发的小说阅读APP v1.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'MyReader',
                applicationVersion: '1.0',
                applicationLegalese: '© 2026 TPGoFighting',
              );
            },
          ),
        ],
      ),
    );
  }
}
