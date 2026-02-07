import 'package:flutter/material.dart';

// 书架页基础版（加const构造，支持const列表）
class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key}); // 关键：添加const构造函数

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('书架页面（后续扩展功能）'),
      ),
    );
  }
}