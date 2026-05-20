# 数据 Schema 说明

本项目所有种子数据放在 `data/` 下，格式 JSON，UTF-8 无 BOM。App 启动时由 `seed_loader.dart` 写入 SQLite。

## cities.json

每条记录一个城市。

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | 主键，城市拼音（如 `beijing` / `xian`） |
| `name` | string | 中文名 |
| `province` | string | 省级行政区 |
| `region` | string | 7 大区，枚举：华北 / 东北 / 华东 / 华中 / 华南 / 西南 / 西北 |
| `climate_zone` | string | 气候带描述（如 "暖温带半湿润"） |
| `lat` / `lng` | float | 城市中心经纬度，用于定位最近邻匹配 |

## fruits.json

每条记录一个水果（可以是品种/产地组合，如 "烟台苹果"）。

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | 主键，英文短名 |
| `name` | string | 中文名 |
| `alias` | string[] | 别名 |
| `english_name` | string | 英文名 |
| `image` | string | 占位图路径（MVP 阶段统一占位） |
| `color_hex` | string | 代表色，UI 色块用，如 `#FFD700` |
| `brix_min` / `brix_max` | float | 甜度区间 °Bx（典型值，实际因品种/成熟度波动 ±20%） |
| `calorie_kcal_per_100g` | int | 每 100g 可食部热量 |
| `vitamins` | object | 维生素含量（mg / 100g），常见键：`C`, `A`, `B1`, `B2`, `B6`, `E` |
| `minerals` | object | 矿物质含量（mg / 100g），常见键：`K`, `Ca`, `Mg`, `Fe`, `Zn` |
| `tcm_nature` | string | 中医性味，枚举：寒 / 凉 / 平 / 温 / 热 |
| `benefits` | string[] | 健康功效短句 |
| `contraindications` | string[] | 禁忌人群短句 |
| `peak_season` | string | 上市旺季描述（如 "9-11月"） |
| `origins` | string[] | 主要产地 |

## recommendations.json

每条记录 = "某城市 在 某月某旬 推荐 某水果"。

| 字段 | 类型 | 说明 |
|---|---|---|
| `city_id` | string | FK → cities.id |
| `month` | int | 1-12 |
| `period` | string | 枚举：`上旬`(1-10日) / `中旬`(11-20日) / `下旬`(21-月末) |
| `fruit_id` | string | FK → fruits.id |
| `score` | int | 0-100，综合推荐分（综合应季性 + 本地性 + 营养） |
| `reason` | string | 简短推荐理由（展示在卡片上） |
| `locality` | string | 枚举：`本地特产` / `邻近产区` / `外来` |

## 数据约束

- 每个城市 × 每月 × 每旬 至少 1 条推荐（覆盖率 100%）
- 推荐数 ≤ 5 条 / (城市, 月, 旬) 组合（避免主页信息过载）
- `recommendations.city_id` 必须存在于 cities
- `recommendations.fruit_id` 必须存在于 fruits

校验脚本：`scripts/validate_data.dart`

## 时间约定

- App 内部所有时间戳用 ISO 8601 字符串（如 `2026-05-20T13:45:00+08:00`）
- 月份 1-12，旬段按公历自然月划分
