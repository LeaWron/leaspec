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

### 阶段 0: 执行证据审查

- [ ] 是否存在执行评估（risk、mode、确认要求、主要原因）？
- [ ] 高风险模式是否有用户确认记录？
- [ ] 每个完成任务是否有 TDD 证据或对应验证夹具？
- [ ] 若使用 subagent，是否记录了 subagent 状态并处理 concerns/blockers？
- [ ] 若使用 worktree，是否记录 provenance 且没有清理外部 worktree？

### 阶段 1: Spec 合规性审查（必须先做）

逐条对照 `spec.md` 中的需求:

- [ ] 每个 Functional Requirement (FR-XXX) 都有对应实现
- [ ] 每个 Functional Requirement 的审查结果都包含 FR ID 和一句话梗概
- [ ] 每个 Acceptance Scenario 都有对应测试
- [ ] 没有实现超出 spec 范围的「多余」功能（scope creep = bug）
- [ ] 没有遗漏 spec 中的任何需求
- [ ] 实现的语义与 spec 描述一致

**Spec Reviewer 心态:** 不要信任报告。亲自读代码。实现者的报告可能过时、不完整、过于乐观。验证每一条 FR。

**FR 梗概规则:** 从 Functional Requirements 表的 Requirement 文本提炼一句短语，保留核心对象和行为。不要只写 ID；不要复制整段长需求。示例: `FR-003 — 支持 --constitution-file 覆盖默认宪法`。

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

- [ ] 读取当前项目的 `leaspec/constitution.md`
- [ ] 对 `Core Principles` 中的每一条原则逐条检查，不得使用过期的硬编码原则列表
- [ ] 默认 leaspec 宪法应覆盖:
  - Spec-as-Truth: 规范是否作为真相源？
  - Trigger-by-Need: 流程选择是否匹配需求？
  - Incremental-First: 是否优先复用已有规范并最小化变更？
  - Design-Before-Code: 是否先完成设计再实现？
  - Simplicity: 是否是最简单可行方案？
  - Respect-Comments: 是否避免无关注释改动？
- [ ] 如果当前宪法被项目修改过，以当前 `constitution.md` 为准

### 阶段 5: Archive Safety 审查

- [ ] 修改或移除已有 FR 时，是否记录了基线指纹或等价 stale 检测证据？
- [ ] 若检测到 live spec 与基线不一致，是否阻止归档并要求同步/人工协调？
- [ ] 归档风险是否写入 review report？

## 红旗 — 自动判定 NEEDS_CHANGES

| 红旗信号 | 严重程度 |
|----------|----------|
| FR 需求无对应实现 | CRITICAL |
| 测试未覆盖 spec 中的场景 | CRITICAL |
| 高风险执行缺少用户确认 | CRITICAL |
| stale spec 风险未处理就准备归档 | CRITICAL |
| 实现超出 spec 范围（scope creep） | IMPORTANT |
| subagent concern/blocker 未处理 | IMPORTANT |
| worktree provenance 不明却清理 | IMPORTANT |
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
1. [{{FR_ID}} — {{FR_SUMMARY}}] {{ISSUE}} — {{FILE}}:{{LINE}}

## Important Issues
1. [{{FR_ID}} — {{FR_SUMMARY}}] {{ISSUE}} — {{FILE}}:{{LINE}}

## Minor Suggestions
1. {{SUGGESTION}}

## Spec Coverage
| FR ID | FR Summary | Has Implementation? | Has Test? | Evidence |
|-------|------------|---------------------|-----------|----------|
| FR-001 | 创建 leaspec 标准目录结构 | ✅ | ✅ | `scripts/init.sh`, `test_phase1.sh` |
```

若 issue 不对应具体 FR，使用 `[General — {{AREA_SUMMARY}}]` 前缀，例如 `[General — 测试隔离性]`。

## 过渡

- APPROVED → 提示用户运行 `/leaspec-archive`
- NEEDS_CHANGES → 回到 `/leaspec-execute` 修复，修复后重新审查
