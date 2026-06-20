# Architecture Decision Records

本目录记录项目的重要架构决策,帮助团队理解"为什么这样设计"。

## ADR 列表

| ADR | 标题 | 状态 | 日期 |
|-----|------|------|------|
| [0001](0001-feature-first-architecture.md) | 采用 Feature-First 架构 | accepted | 2026-06-20 |
| [0002](0002-dual-database-strategy.md) | Drift + Supabase 双数据源策略 | accepted | 2026-06-20 |
| [0003](0003-repository-pattern.md) | 引入 Repository 抽象层 | accepted | 2026-06-20 |
| [0004](0004-riverpod-state-management.md) | 使用 Riverpod 状态管理 | accepted | 2026-06-20 |

---

## 如何创建新 ADR

1. 复制 `template.md` 到新文件 `NNNN-decision-title.md`
2. 填写决策内容(Context、Decision、Alternatives、Consequences)
3. 更新本 README 添加索引
4. 提交 PR 时一并包含 ADR

## ADR 编号规则

- 使用 4 位数字编号: `0001`, `0002`, ...
- 按时间顺序递增
- 不要重复使用已废弃的编号

## ADR 状态

- **proposed**: 提议中,尚未最终决定
- **accepted**: 已接受并执行
- **deprecated**: 已废弃,不再遵循
- **superseded by ADR-XXXX**: 被新决策替代

---

**更多信息**: [Architectural Decision Records](https://adr.github.io/)
