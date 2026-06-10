# Project Constitution — {{PROJECT_NAME}}

> 项目宪法是最高级别的治理文件。所有规范、计划和实现都必须遵守宪法中的原则。
> 如果某个技术决策需要违反宪法原则，必须在 plan.md 的 Complexity Tracking 中记录并说明理由。

## Core Principles

### Principle 1: Spec-as-Truth

**描述**: `specs/` 目录是系统行为的权威描述，代码是规范的实现。

**检查项**:
- [ ] 新功能是否有对应的规范文件？
- [ ] 代码变更是否与规范保持一致？
- [ ] 规范是否被正确地反映在审查中？

---

### Principle 2: Trigger-by-Need

**描述**: 根据项目状态和需求类型，自动选择最合适的流程。

**检查项**:
- [ ] 流程选择是否符合当前需求类型？
- [ ] 是否跳过了不必要的能力步骤？
- [ ] 是否在需要时触发了正确的 skill？

---

### Principle 3: Incremental-First

**描述**: 已有规范时优先走增量变更，避免重复描述。

**检查项**:
- [ ] 是否复用了已有规范而非重新生成？
- [ ] 增量变更是否精确、最小化？
- [ ] 是否避免了不必要的全量规范重写？

---

### Principle 4: Design-Before-Code

**描述**: 禁止未经设计直接编写代码。

**检查项**:
- [ ] 设计文档是否在代码之前完成？
- [ ] 设计是否通过了审查？
- [ ] 设计是否充分考虑了替代方案？

---

### Principle 5: Simplicity

**描述**: 选择最简单的方案，反对过度抽象和过早优化。

**检查项**:
- [ ] 当前方案是否是最简单的可行方案？
- [ ] 是否引入了不必要的抽象层？
- [ ] 是否有充分的理由增加复杂度？

---

### Principle 6: Respect-Comments

**描述**: 不修改任何已有注释，除非修改了对应的代码段。

**检查项**:
- [ ] 是否误删或修改了与代码变更无关的注释？
- [ ] 修改代码时是否同步更新了对应的注释？
- [ ] 新增代码是否包含了必要的注释？

---

## Governance

- **修订流程**: 修改宪法需要创建专门的 change proposal，标注 `CONSTITUTION_CHANGE` 标签
- **版本策略**: 每次修改递增 `CONSTITUTION_VERSION`
- **合规审查**: 每个 plan.md 必须通过 Constitution Check gates

---

**CONSTITUTION_VERSION**: 1.0.0
**RATIFICATION_DATE**: {{DATE}}
**LAST_AMENDED_DATE**: {{DATE}}
