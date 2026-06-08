---
name: leaspec-review
description: Review implemented code against spec compliance and code quality standards. Use after leaspec-execute when all tasks are complete. Checks spec compliance (every FR covered), code quality (YAGNI, naming, decomposition), test quality, and constitution alignment. Triggers after implementation is complete, before archiving.
requires: leaspec-execute
terminates: leaspec-archive, leaspec-execute
---

# leaspec-review — 代码审查

对已实现代码进行两阶段审查: Spec 合规性 → 代码质量。

## HARD GATE

**没有通过审查的代码不得归档。**
审查发现 Critical Issue → 必须修复后重新审查。

## 前置条件

- 所有 `tasks.md` 中的任务已完成（全部 `[X]`）
- 完整测试套件可通过

## 审查维度

### 阶段 1: Spec 合规性审查（必须先做）

逐条对照 `spec.md` 中的需求:

- [ ] 每个 Functional Requirement (FR-XXX) 都有对应实现
- [ ] 每个 Acceptance Scenario 都有对应测试
- [ ] 没有实现超出 spec 范围的「多余」功能（scope creep = bug）
- [ ] 没有遗漏 spec 中的任何需求
- [ ] 实现的语义与 spec 描述一致

**Spec Reviewer 心态:** 不要信任报告。亲自读代码。实现者的报告可能过时、不完整、过于乐观。验证每一条 FR。

### 阶段 2: 代码质量审查（Spec 合规通过后才做）

- [ ] 命名清晰一致（函数、变量、文件）
- [ ] 函数/方法职责单一（一个函数只做一件事）
- [ ] 没有过度抽象（遵循 YAGNI — 不需要的不要抽象）
- [ ] 错误处理适当（不吞异常、不泛泛 catch）
- [ ] 没有明显的性能问题
- [ ] 文件大小合理（超大文件 = 职责不清）

### 阶段 3: 测试质量审查

- [ ] 测试覆盖正常路径
- [ ] 测试覆盖边界条件（null, 空列表, 极值）
- [ ] 测试覆盖错误路径
- [ ] 测试使用真实代码（仅在外部边界用 mock）
- [ ] 测试命名描述被测试的行为（不是 "test1", "test2"）

### 阶段 4: Constitution 再次检查

- [ ] Library-First: 功能可否独立运行？
- [ ] Test-First: 测试在代码前？git log 可验证
- [ ] Simplicity: 方案是最简的吗？
- [ ] Integration-First: 集成测试充分吗？
- [ ] Observable: 关键路径有日志/指标吗？

## 红旗 — 自动判定 NEEDS_CHANGES

| 红旗信号 | 严重程度 |
|----------|----------|
| FR 需求无对应实现 | CRITICAL |
| 测试未覆盖 spec 中的场景 | CRITICAL |
| 实现超出 spec 范围（scope creep） | IMPORTANT |
| 函数超过 100 行 | IMPORTANT |
| Mock 了不该 mock 的内部组件 | IMPORTANT |
| "万能"函数/类（职责过多） | IMPORTANT |
| 命名含糊（data, info, result, tmp） | MINOR |

## 禁止的回应

```
绝对不要写:
- "你完全正确！"
- "好观点！"
- "极好的反馈！"

改为:
- 陈述技术事实
- 引用代码行
- 直接行动
```

## 输出格式

```markdown
# Review Report: {{CHANGE_NAME}}

## Summary
- Status: APPROVED / NEEDS_CHANGES
- Reviewed Files: N
- Issues: X (Critical: A, Important: B, Minor: C)

## Critical Issues
1. {{ISSUE}} — {{FILE}}:{{LINE}}

## Important Issues
1. {{ISSUE}} — {{FILE}}:{{LINE}}

## Minor Suggestions
1. {{SUGGESTION}}

## Spec Coverage
| FR ID | Has Implementation? | Has Test? |
|-------|---------------------|-----------|
| FR-001 | ✅ | ✅ |
```

## 过渡

- APPROVED → 提示用户运行 `/leaspec-archive`
- NEEDS_CHANGES → 回到 `/leaspec-execute` 修复，修复后重新审查
