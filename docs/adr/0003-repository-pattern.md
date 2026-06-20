# ADR-0003: 引入 Repository 抽象层

**日期**: 2026-06-20  
**状态**: accepted  
**决策者**: 项目团队

## 背景

项目当前存在的问题:
- **强耦合**: UI 层直接依赖 `AppDatabase`,与 Drift 强绑定
- **难以测试**: 无法轻易 Mock 数据层进行单元测试
- **难以切换**: 如果未来需要切换数据源(如从 Drift 迁移到 Supabase),需要修改所有调用方
- **混合数据源**: ADR-0002 决定使用 Drift + Supabase 双数据源,需要统一接口

代码示例(重构前):
```dart
// UI 直接依赖 AppDatabase
final fruits = ref.watch(dbProvider).allFruits();
```

## 决策

我们决定引入 **Repository 模式**,为数据访问提供统一抽象:

**架构分层**:
```
UI Layer (Widgets)
    ↓
Provider Layer (Riverpod)
    ↓
Repository Layer (抽象接口)
    ↓
Data Source Layer (Drift / Supabase)
```

**目录结构**:
```
lib/data/repositories/
├── base_repositories.dart       # 抽象接口
├── local_repositories.dart      # Drift 实现
├── remote_repositories.dart     # Supabase 实现(未来)
└── repository_providers.dart    # Riverpod Providers
```

**使用示例**:
```dart
// 定义接口
abstract class FruitRepository {
  Future<List<Fruit>> getAllFruits();
  Future<Fruit?> getFruitById(String id);
}

// 本地实现
class LocalFruitRepository implements FruitRepository {
  final AppDatabase _db;
  LocalFruitRepository(this._db);
  
  @override
  Future<List<Fruit>> getAllFruits() => _db.allFruits();
}

// UI 使用
final fruits = ref.watch(fruitRepositoryProvider).getAllFruits();
```

## 备选方案

### 方案 A: 直接使用 Database
- **优点**: 
  - 代码简洁,无抽象层
  - 开发速度快
- **缺点**: 
  - UI 与数据库强耦合
  - 难以测试
  - 无法灵活切换数据源
- **为何不选**: 项目需要双数据源,必须有抽象层

### 方案 B: 使用 UseCase 层
- **优点**: 
  - 业务逻辑集中
  - 符合 Clean Architecture
- **缺点**: 
  - 增加额外抽象层
  - 对当前项目规模过度设计
  - 大部分 UseCase 只是简单转发
- **为何不选**: 项目业务逻辑简单,Repository 层足够

### 方案 C: 直接在 Provider 中处理数据源切换
- **优点**: 
  - 无需额外文件
  - 灵活性高
- **缺点**: 
  - Provider 职责过重
  - 代码重复
  - 难以复用和测试
- **为何不选**: 违反单一职责原则,不利于维护

## 后果

### 积极影响
- **解耦**: UI 不再直接依赖具体数据库实现
- **可测试**: 可以轻松 Mock Repository 进行单元测试
- **灵活切换**: 未来可以无缝切换到 Supabase 或混合模式
- **代码组织**: 数据访问逻辑集中在 Repository 层
- **类型安全**: 接口定义明确,编译时检查

### 消极影响
- **间接层**: 增加了一层抽象,代码行数增加约 20%
- **学习成本**: 团队需要理解 Repository 模式

### 风险
- **过度抽象**: 可能为简单查询创建不必要的 Repository 方法
- **性能**: 多一层调用可能带来微小性能损耗(实际可忽略不计)

**缓解措施**:
- 只为业务实体创建 Repository,不为每个表都创建
- Repository 方法保持简洁,避免过度封装
- 提供代码示例和文档,降低学习成本
