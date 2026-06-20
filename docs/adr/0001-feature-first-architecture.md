# ADR-0001: 采用 Feature-First 架构

**日期**: 2026-06-20  
**状态**: accepted  
**决策者**: 项目团队

## 背景

项目初期采用了混合的目录结构:
- `lib/presentation/` - 旧的展示层代码
- `lib/features/` - 新的按功能组织的代码
- `lib/shared/` - 共享组件

这导致:
- 代码组织混乱,新人难以理解项目结构
- 相同类型的代码散落在不同目录
- 导入路径不一致,维护困难

## 决策

我们决定采用 **Feature-First 架构**,按业务功能组织代码:

```
lib/
├── core/              # 核心基础设施
│   ├── auth/
│   ├── config/
│   ├── navigation/
│   └── providers/
├── shared/            # 跨 feature 共享
│   ├── theme/
│   └── widgets/
├── features/          # 按功能组织
│   ├── home/
│   ├── encyclopedia/
│   ├── community/
│   └── profile/
└── data/              # 数据层
    ├── database.dart
    └── repositories/
```

每个 feature 内部采用分层结构:
```
features/home/
├── pages/         # UI 页面
├── widgets/       # feature 专用组件
└── providers/     # feature 专用状态
```

## 备选方案

### 方案 A: Layer-First (按层级组织)
```
lib/
├── pages/
├── widgets/
├── providers/
└── services/
```

- **优点**: 
  - 结构简单,易于上手
  - 适合小型项目
- **缺点**: 
  - 相关业务代码分散在不同目录
  - 大型项目难以维护
  - 难以做模块化拆分
- **为何不选**: 项目已有多个业务模块,Layer-First 不利于团队协作和代码隔离

### 方案 B: Domain-Driven Design (DDD)
```
lib/
├── domain/
│   ├── entities/
│   ├── usecases/
│   └── repositories/
├── application/
└── infrastructure/
```

- **优点**: 
  - 强调业务领域建模
  - 清晰的依赖方向
- **缺点**: 
  - 学习曲线陡峭
  - 对小型项目过度设计
  - 需要大量抽象层
- **为何不选**: 项目规模不大,DDD 的复杂度带来的收益不明显

## 后果

### 积极影响
- **代码组织清晰**: 业务相关代码集中在一个 feature 目录下
- **易于协作**: 不同开发者可以独立开发不同 feature,减少冲突
- **便于模块化**: 未来可以轻松将 feature 拆分为独立 package
- **导入路径一致**: 所有导入遵循相同的规则,易于重构

### 消极影响
- **迁移成本**: 需要移动大量文件并更新导入路径
- **学习成本**: 团队需要适应新的目录结构

### 风险
- **过度分层**: 需要避免在 feature 内部过度分层,保持简洁
- **共享代码**: 需要明确 `shared/` 和 feature 内部 widgets 的界限

**缓解措施**:
- 制定清晰的代码组织规范文档
- Code Review 时检查目录结构是否符合规范
