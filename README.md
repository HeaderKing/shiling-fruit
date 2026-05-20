# 时令水果 · shiling-fruit

> 按城市、月份、旬段推荐当地最适合吃的水果。离线、开源、可贡献。

![覆盖](https://img.shields.io/badge/cities-40-brightgreen) ![水果](https://img.shields.io/badge/fruits-79-orange) ![推荐](https://img.shields.io/badge/recommendations-6610-blue) ![license](https://img.shields.io/badge/license-MIT-lightgrey) ![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)

---

## 它解决什么

> "现在这个季节，在我所在的城市，吃什么水果最合适？"

中国地域辽阔、气候差异巨大，同一时间不同城市的"时令"水果完全不同。这个 App 把"城市 × 月份 × 旬段"组合起来，告诉你哪些水果当下最值得吃——并附上每种水果的甜度、维生素、健康功效与禁忌人群。

## 功能

- **今日推荐**：自动按当前月份和旬段（上/中/下旬）展示选中城市的推荐水果
- **月历浏览**：12 个月 × 3 旬段，提前规划全年水果
- **水果详情**：甜度（°Bx）、热量、维生素、矿物质、中医性味、健康功效、**禁忌人群**、主要产地
- **40 城覆盖**：华北/东北/华东/华中/华南/西南/西北 7 大区主要城市
- **离线优先**：数据全部打包进 APK，不需要后端
- **自动定位**：geolocator + 最近邻匹配最近的城市
- **本地推送**：每周一 8:30 提醒本周时令水果
- **收藏**：把喜欢的水果加入收藏列表

## 截图

> 待截图。运行后用 `flutter screenshot` 保存到 `docs/screenshots/`。

## 数据来源

- 城市与气候带：标准行政区划资料
- 水果上市期、特产关系：公开农业资料（农业农村部、地方农业志、电商平台上市表等）+ AI 整理
- 营养数据（甜度、维生素、矿物质）：通用营养数据库（USDA、中国食物成分表）参考值
- 中医性味、功效、禁忌：主流文献整理（**仅供参考，不构成医疗建议**）

数据的"可读版"汇总见 [`docs/fruit-almanac.md`](docs/fruit-almanac.md)；字段定义见 [`docs/data-schema.md`](docs/data-schema.md)。

**⚠️ 数据准确性说明**：水果上市时间因年景/产地/品种差异有 ±2 周波动；营养值是典型参考。如有错误，欢迎 PR/Issue 修正。

## 技术栈

| 组件 | 选型 |
|---|---|
| 框架 | Flutter 3.41 / Dart 3.11 |
| 持久化 | Drift（SQLite + 类型安全 + 代码生成） |
| 状态管理 | Riverpod |
| 定位 | geolocator（最近邻匹配本地 cities 表，不走外部 API） |
| 本地推送 | flutter_local_notifications + timezone |
| 平台 | Android + Windows Desktop（MVP）；可扩展 iOS / macOS / Linux / Web |

## 项目结构

```
shiling-fruit/
├── data/                     # 数据采集原始 JSON
│   ├── cities.json           # 40 城
│   ├── fruits.json           # 79 种水果（含营养/禁忌）
│   ├── recommendations.json  # 6610 条 城市×月×旬 推荐
│   └── templates/regional_calendar.json  # 区域时令模板（推荐数据的来源）
├── docs/
│   ├── data-schema.md        # 数据字段定义
│   ├── fruit-almanac.md      # 人类可读的时令水果汇总
│   └── screenshots/
├── scripts/
│   ├── generate_recommendations.dart  # 模板 → recommendations.json
│   ├── generate_almanac.dart          # JSON → fruit-almanac.md
│   └── validate_data.dart             # 外键/覆盖率校验
├── lib/                      # Flutter 工程
│   ├── data/                 # Drift 数据库 + seed loader
│   ├── services/             # 定位 + 推送
│   ├── presentation/         # pages / widgets / providers
│   └── main.dart
└── assets/data/              # 拷贝自 data/ 用于打包
```

## 本地运行

```bash
# 1) 安装依赖
flutter pub get

# 2) 生成 Drift 代码（若 lib/data/database.g.dart 缺失）
#    ⚠️ Windows 中文路径会导致 dart AOT 编译失败 - 临时复制到无中文路径运行
dart run build_runner build --delete-conflicting-outputs

# 3) 运行 (Android 设备 / Windows Desktop)
flutter run -d windows     # 或 -d <你的设备>
```

## 数据贡献

数据是这个项目最有价值的部分，欢迎贡献。

```bash
# 修改 data/templates/regional_calendar.json 或 data/fruits.json/cities.json 后:

# 1) 重新生成推荐表
dart scripts/generate_recommendations.dart

# 2) 校验完整性
dart scripts/validate_data.dart

# 3) 重新生成人类可读汇总
dart scripts/generate_almanac.dart

# 4) 把更新后的 data/*.json 拷贝到 assets/data/
cp data/*.json assets/data/

# 5) 提 PR
```

## Roadmap

- [ ] 扩展到 300+ 地级市
- [ ] 水果实图替换占位色块（需收集免版权图片）
- [ ] i18n 英文界面
- [ ] iOS / macOS / Linux / Web 平台
- [ ] 用户上传市场实拍 + 价格反馈
- [ ] 节气推荐（春分赏樱、立秋食枣等）

## License

MIT — 见 [LICENSE](LICENSE)。

数据本身（`data/*.json` 与 `docs/fruit-almanac.md`）使用 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 协议，引用请注明来源。
