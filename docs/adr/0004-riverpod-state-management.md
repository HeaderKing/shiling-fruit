# ADR-0004: 使用 Riverpod 状态管理

**日期**: 2026-06-20  
**状态**: accepted  
**决策者**: 项目团队

## 背景

Flutter 应用需要状态管理方案来:
- 管理全局状态(如当前选中城市、主题模式)
- 处理异步数据(API 请求、数据库查询)
- 实现响应式 UI 更新
- 避免 Prop Drilling

Flutter 生态有多种状态管理方案:Provider、Riverpod、Bloc、GetX 等。

## 决策

我们决定使用 **Riverpod 2.x** 作为状态管理方案。

**使用场景**:
- 全局状态: `StateProvider`、`Provider`
- 异步数据: `FutureProvider`、`StreamProvider`
- 依赖注入: `Provider`

**代码示例**:
```dart
// 定义 Provider
final selectedCityIdProvider = StateProvider<String>((ref) => 'beijing');

final fruitsProvider = FutureProvider<List<Fruit>>((ref) async {
  final repo = ref.watch(fruitRepositoryProvider);
  return repo.getAllFruits();
});

// 使用 Provider
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityId = ref.watch(selectedCityIdProvider);
    final fruitsAsync = ref.watch(fruitsProvider);
    
    return fruitsAsync.when(
      data: (fruits) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => ErrorWidget(e),
    );
  }
}
```

## 备选方案

### 方案 A: Provider (原生)
- **优点**: 
  - Flutter 官方推荐
  - 学习资源丰富
  - 社区成熟
- **缺点**: 
  - API 相对繁琐
  - 需要手动管理 dispose
  - 类型安全性较弱
- **为何不选**: Riverpod 是 Provider 的改进版,解决了这些问题

### 方案 B: Bloc/Cubit
- **优点**: 
  - 强制单向数据流
  - 适合复杂业务逻辑
  - 易于测试
- **缺点**: 
  - 样板代码多
  - 学习曲线陡峭
  - 对简单场景过度设计
- **为何不选**: 项目业务逻辑相对简单,Bloc 的严格约束带来的收益不明显

### 方案 C: GetX
- **优点**: 
  - 开发速度快
  - 功能丰富(状态管理+路由+依赖注入)
- **缺点**: 
  - 过于"魔法",不符合 Flutter 设计哲学
  - 强耦合,难以迁移
  - 社区褒贬不一
- **为何不选**: 不符合团队编码风格,过度依赖全局状态

### 方案 D: setState
- **优点**: 
  - 最简单
  - 无需额外依赖
- **缺点**: 
  - 难以跨组件共享状态
  - Prop Drilling 严重
  - 不适合中大型应用
- **为何不选**: 项目已有跨页面共享状态需求

## 后果

### 积极影响
- **编译时安全**: Provider 在编译时检查类型,减少运行时错误
- **自动 dispose**: 无需手动管理生命周期
- **易于测试**: Provider 可以轻松 override 进行测试
- **代码简洁**: 相比 Bloc,样板代码少 60%+
- **响应式**: UI 自动响应状态变化
- **依赖注入**: Provider 天然支持依赖注入

### 消极影响
- **学习成本**: 团队需要学习 Riverpod 的 API 和概念
- **依赖**: 增加了 `flutter_riverpod` 依赖

### 风险
- **过度使用**: 可能为简单状态创建不必要的 Provider
- **性能**: 不当使用可能导致不必要的 rebuild

**缓解措施**:
- 制定 Provider 使用规范:
  - 局部状态用 `StatefulWidget`
  - 跨页面状态用 `StateProvider`
  - 异步数据用 `FutureProvider`/`StreamProvider`
  - 依赖注入用 `Provider`
- 使用 `select` 和 `Selector` 优化性能
- Code Review 检查 Provider 使用是否合理
