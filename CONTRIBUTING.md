# 贡献指南

感谢你想为「时令水果」贡献数据/代码！本项目的核心价值是**数据准确性**，所以对数据贡献尤其欢迎。

## 数据贡献（最有价值）

项目的水果与时令数据存放在 `data/` 下三个 JSON 文件中。结构定义见 [`docs/data-schema.md`](docs/data-schema.md)。

### 数据来源参考

按可信度从高到低：

| 来源 | 适合采纳的字段 | 注意 |
|---|---|---|
| **USDA FoodData Central** (`fdc.nal.usda.gov`) | `vitamins` / `minerals` / `calorie_kcal_per_100g` | 英文，需用英文名/拉丁名搜索；权威 |
| **《中国食物成分表 第 6 版》** | 营养字段 | 中国常见食材标准参考 |
| **维基百科中文/英文** | `alias` / `english_name` / `origins` / `peak_season` | 上市期需交叉验证 |
| **国家地理标志保护产品名录** | `origins` 准确产地 | 标识"本地特产"的最权威依据 |
| **农业农村部公开统计** | `peak_season` | 区域上市表 |
| **地方农业志、品种志** | 小众水果详情 | 多为 PDF，需手工提取 |
| **电商生鲜上市表**（淘宝/京东等） | `peak_season` 实际市场窗口 | 受冷库影响会偏长，需对照原产地数据 |
| **中医药学辅教材**（如《中药大辞典》） | `tcm_nature` / `benefits` / `contraindications` | 务必标注"仅供参考，不构成医疗建议" |

⚠️ **避免**：
- 不带来源的"营销文案" / 短视频博主说法
- AI 直接生成且未经人工核对的数据
- 跨年龄/体质 / 病理状态的医疗建议

### 新增一个水果的完整流程

```bash
# 1) 在 data/fruits.json 末尾追加一条 entry（保持单行紧凑格式）
#    必须包含 schema 中所有字段（含 emoji，注意 id 唯一）

# 2) 在 data/templates/regional_calendar.json 的相关 region × month 池
#    里插入推荐 entry（按 origins 选主产 region，按 peak_season 选月份）

# 3) 重新生成推荐表
dart scripts/generate_recommendations.dart

# 4) 校验外键 + 覆盖率
dart scripts/validate_data.dart    # 必须 0 ERROR

# 5) 同步到 assets（打包入 app）
cp data/*.json assets/data/

# 6) 重新生成人类可读 almanac（可选）
dart scripts/generate_almanac.dart

# 7) 提交 PR，描述新增水果 + 引用的数据源链接
```

### 修正已有水果数据

修改 `data/fruits.json` 中对应 entry 的字段后，跑步骤 4-7。`peak_season` 改动通常会影响 `regional_calendar.json` 的 `periods/scores`，请一并审视。

### 新增/修正城市

修改 `data/cities.json`（确保 `id` 全 ASCII snake_case、`lat/lng` 精度足够定位匹配），然后在 `regional_calendar.json` 中确认该 city 的 region 已有 12 个月推荐池（若空将无推荐数据），再跑步骤 3-7。

## 数据准确性原则

- **标注产地**：`origins` 数组里写最具代表性的 1-3 个产区（如「山东烟台」「新疆阿克苏」），不要写「全国各地」除非真的全国主产。
- **`peak_season` 是上市旺季，不是全年供应**：写「9-11月」而不是「全年」，即使该水果通过冷库全年可见。
- **`tcm_nature` 用枚举**：寒/凉/平/温/热，五选一。
- **`contraindications` 客观描述人群**：「糖尿病患者控量」「孕妇慎食」「脾胃虚寒者少食」——避免「某某不能吃」式绝对化表述。
- **不构成医疗建议**：在 PR 描述中明确「营养与功效仅供参考」。

## 半自动数据工具

仓库提供两个抓取脚本辅助贡献者填空（不替代人工校对）：

```bash
# USDA 营养数据抓取（需要环境变量 USDA_API_KEY，免费注册：https://fdc.nal.usda.gov/api-guide.html）
dart scripts/scrape_usda.dart "Apple"

# 中文维基百科抓取（免 key）
dart scripts/scrape_wiki.dart "烟台苹果"
```

输出会按本项目 schema 打印 JSON 片段，复制到 `fruits.json` 后再人工校对。

## 代码贡献

```bash
# 安装依赖
flutter pub get

# 生成 Drift 代码（schema 改了才需要）
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run -d windows   # 或 android / chrome
```

提 PR 前请确保：
- `flutter analyze` 0 错误 0 警告（info 级允许）
- 如果改了 `lib/data/database.dart`，重新生成 `database.g.dart` 并提交

## 问题反馈

- 数据错误（产地/上市期/营养值偏差）：用 [数据错误模板](.github/ISSUE_TEMPLATE/data_error.md)
- 新增水果请求：用 [新增水果模板](.github/ISSUE_TEMPLATE/new_fruit.md)
- Bug / UI 问题：直接开 Issue，附截图

## License

代码 MIT，数据 CC BY 4.0。贡献即同意按这两个协议发布。
