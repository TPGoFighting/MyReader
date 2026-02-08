import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'core/hive_init.dart';
import 'providers/reader_provider.dart';
import 'providers/bookshelf_provider.dart'; 
import 'screens/bookshelf/bookshelf_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/mine/mine_screen.dart';

void main() async {
  // 1. 确保 Flutter 引擎初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. 初始化 Hive (这步非常关键，确保内部已经 open 了 'bookshelf' 和 'read_progress' 的 Box)
  await HiveInit.init();

  // 3. 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 设为透明更符合现代设计
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 4. 注意这里：BookshelfProvider 启动时立即调用 initBookshelf()
        // 这样可以解决你“无法加入书架”或书架初始显示为空的问题
        ChangeNotifierProvider(create: (_) => BookshelfProvider()..initBookshelf()),
        ChangeNotifierProvider(create: (_) => ReaderProvider()..initConfig()),
      ],
      child: MaterialApp(
        title: '小说阅读APP',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blueGrey,
          // 5. 优化 AppBar 全局配置
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white, // 给书架和分类页一个清晰的底色
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
              color: Colors.black, 
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          // 6. 统一底部导航栏风格
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.blueGrey,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // 7. 去掉 const，因为页面内部可能依赖数据初始化
  final List<Widget> _pages = [
    const BookshelfScreen(),
    const CategoryScreen(),
    const MineScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 8. 使用 IndexedStack 保持页面状态
      // 这样当你从“分类”切回“书架”时，书架不会重新加载，体验更流畅
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined), 
            activeIcon: Icon(Icons.book),
            label: '书架'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined), 
            activeIcon: Icon(Icons.category),
            label: '分类'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person),
            label: '我的'
          ),
        ],
      ),
    );
  }
}