# MyReader

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.x-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

一个轻量、高效的 Flutter 小说阅读 APP，专注于沉浸式阅读体验，支持本地缓存、阅读进度同步、个性化阅读设置等核心功能。

## 🌟 核心功能
### 📚 书架管理
- 小说列表可视化展示（封面+标题+作者）
- 长按删除小说，分类页一键添加到书架
- 基于 Hive 本地存储，数据不丢失

### 📖 分类浏览
- 多分类筛选（玄幻/都市/言情/全部）
- 小说列表展示（封面+简介+最新章节）
- 快速识别已加入书架的小说

### 📝 沉浸式阅读
- 左右滑动翻页，仿真阅读体验
- 自定义字体大小（14-28号字可调）
- 多背景色切换（白色/淡黄色/灰色/黑色）
- 章节列表快速跳转
- 沉浸式状态栏，隐藏系统导航栏

### 💾 本地存储
- 阅读进度自动保存（小说ID+章节ID）
- 章节内容本地缓存，离线可阅读
- 一键清理缓存，释放存储空间

### ⚙️ 个性化设置
- 字体大小可精细化调节
- 阅读背景色自定义
- 阅读历史记录查看

## 🛠️ 技术栈
| 技术/框架         | 版本/作用                                                              |
| ----------------- | ---------------------------------------------------------------------- |
| Flutter           | 3.x - 跨平台UI框架，实现一套代码多端运行                               |
| Dart              | 3.x - Flutter 官方开发语言                                             |
| Provider          | 最新版 - 轻量级状态管理，统一管理书架/阅读/设置状态                    |
| Hive              | 最新版 - 轻量级NoSQL本地数据库，存储小说/章节/阅读进度（无需原生配置） |
| SharedPreferences | 最新版 - 存储阅读偏好设置（字体大小/背景色）                           |
| Dio               | 最新版 - 网络请求框架（预留接口，可快速对接小说API）                   |
| flutter/services  | 系统服务 - 控制沉浸式状态栏、屏幕方向等                                |

## 🚀 快速开始

### 环境要求
- Flutter 3.10+（推荐最新稳定版）
- Dart 3.0+
- Android 5.0+/iOS 11.0+
- Git（版本控制）

### 安装步骤
1. 克隆仓库
   ```bash
   git clone https://github.com/TPGoFighting/MyReader.git
   cd MyReader
   ```

2. 安装依赖
   ```bash
   flutter pub get
   ```

3. 生成 Hive 模型适配器
   ```bash
   flutter packages pub run build_runner build
   ```

4. 运行项目
   ```bash
   # 运行Android
   flutter run
   # 运行iOS（需Mac环境）
   flutter run -d ios
   ```

## 📂 项目目录结构
```
MyReader/
├── lib/
│   ├── core/                # 核心工具类
│   │   ├── hive_init.dart   # Hive初始化（注册模型/打开Box）
│   │   └── dio_client.dart  # Dio网络请求配置（预留）
│   ├── models/              # 数据模型
│   │   ├── novel_model.dart # 小说/章节模型 + 模拟数据
│   │   └── novel_model.g.dart # Hive自动生成的适配器
│   ├── providers/           # 状态管理
│   │   ├── bookshelf_provider.dart # 书架状态（增删/列表）
│   │   └── reader_provider.dart    # 阅读状态（字体/背景/进度）
│   ├── screens/             # 页面
│   │   ├── bookshelf/       # 书架页
│   │   ├── category/        # 分类页
│   │   ├── reader/          # 阅读页
│   │   └── mine/            # 我的页
│   └── main.dart            # 入口文件（路由/全局状态）
├── pubspec.yaml             # 依赖配置
└── README.md                # 项目说明
```


## 📌 后续规划
### 短期迭代
1. 对接真实小说API（替换模拟数据）
2. 增加小说搜索功能
3. 优化翻页动画（仿真翻页/滑动效果）
4. 支持夜间模式一键切换

### 长期规划
1. 增加书签功能（章节书签/段落标记）
2. 支持TXT/EPUB小说导入
3. 增加朗读功能（TTS语音）
4. 多设备同步（基于云服务）
5. 广告集成/会员体系（可选）

## 📄 许可证
本项目基于 MIT 许可证开源，详情见 [LICENSE](LICENSE) 文件。

## 🙏 致谢
- Flutter 官方文档：https://docs.flutter.dev/
- Hive 官方文档：https://docs.hivedb.dev/
- Provider 状态管理指南：https://pub.dev/packages/provider