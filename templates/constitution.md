# Project Constitution — {{PROJECT_NAME}}

> 项目宪法是最高级别的治理文件。所有规范、计划和实现都必须遵守宪法中的原则。
> 如果某个技术决策需要违反宪法原则，必须在 plan.md 的 Complexity Tracking 中记录并说明理由。

## Core Principles

### Principle 1: Library-First

**描述**: 每个功能模块必须先作为独立库实现，再进行集成。

**检查项**:
- [ ] 新功能是否可以在无 UI/API 层的情况下独立运行？
- [ ] 库的接口是否清晰、最小化、有文档？

---

### Principle 2: Test-First (TDD)

**描述**: 禁止在无失败测试的情况下编写生产代码。RED → GREEN → REFACTOR。

**检查项**:
- [ ] 测试在代码之前编写？
- [ ] 所有测试在提交前通过？
- [ ] 测试覆盖了正常路径、边界条件和错误路径？

---

### Principle 3: Simplicity

**描述**: 选择最简单的方案。反对过度抽象和过早优化。

**检查项**:
- [ ] 当前方案是否是最简单的可行方案？
- [ ] 是否引入了不必要的抽象层？
- [ ] 是否有充分的理由增加复杂度？

---

### Principle 4: Integration-First Testing

**描述**: 测试应优先验证组件间的集成行为，而非单独 mock 每个依赖。

**检查项**:
- [ ] 关键路径是否有端到端的集成测试？
- [ ] Mock 是否只用于外部边界（网络、文件系统等），而不是内部组件？

---

### Principle 5: Observable

**描述**: 系统必须可观测。关键操作应产出日志、指标或事件。

**检查项**:
- [ ] 错误路径是否产出可操作的日志？
- [ ] 关键指标是否可被监控？

---

## Governance

- **修订流程**: 修改宪法需要创建专门的 change proposal，标注 `CONSTITUTION_CHANGE` 标签
- **版本策略**: 每次修改递增 `CONSTITUTION_VERSION`
- **合规审查**: 每个 plan.md 必须通过 Constitution Check gates

---

**CONSTITUTION_VERSION**: 1.0.0
**RATIFICATION_DATE**: {{DATE}}
**LAST_AMENDED_DATE**: {{DATE}}
