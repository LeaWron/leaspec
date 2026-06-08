---
name: leaspec-new
description: Auto-dispatch entry point for new requirements. Analyzes the project state and user request to automatically select the right workflow (init, brainstorm, specify, change, or execute). Use this as the primary entry command for any new work.
terminates: leaspec-init, leaspec-brainstorm, leaspec-specify, leaspec-change, leaspec-execute
---

# leaspec-new — 自动判决并启动流程

这是 leaspec 的推荐入口。根据项目状态和需求类型，自动选择最合适的流程。

## HARD GATE

**必须先分析项目状态，再决定调用哪个 skill。** 不得跳过判决直接调用下游 skill。

## 执行流程

### Step 1: 项目状态检测

检查以下条件：

1. `leaspec/` 目录是否存在？
2. `leaspec/specs/` 中是否有规范文件？
3. `leaspec/changes/` 中是否有活跃变更？
4. 是否存在 `tasks.md` 且有待完成任务？

### Step 2: 需求分析

分析用户描述的需求：

- 是模糊想法还是明确需求？
- 涉及的是新领域还是已有规范的修改？
- 是否可以直接执行（已有 plan + tasks）？

### Step 3: 判决路由

根据判决逻辑选择下游 skill：

```
用户需求
  │
  ├─ 项目中没有 leaspec/ 目录？
  │   └─→ 调用 leaspec-init（创建目录结构 + constitution）
  │
  ├─ 需求是模糊想法/探索性讨论？
  │   └─→ 调用 leaspec-brainstorm（Socratic 澄清 → 设计方案草稿）
  │
  ├─ 需求明确，涉及新领域（leaspec/specs/ 中无对应规范）？
  │   └─→ 调用 leaspec-specify（0→1 生成完整规范）
  │
  ├─ 需求明确，是对已有规范的修改/扩展？
  │   └─→ 调用 leaspec-change（增量 proposal → spec diff）
  │
  ├─ 已有 spec + plan + tasks，需要实现？
  │   └─→ 调用 leaspec-execute（TDD 执行）
  │
  └─ 是简单 bug fix / 单文件小改动？
      └─→ 轻量执行模式（跳过正式流程）
```

### Step 4: 调用下游 Skill

调用判决选中的 skill，传递用户原始需求。调用前应向用户确认判决结果：

"根据你的需求和当前项目状态，我判断应该使用 **`<skill-name>`** 流程。是否同意？（回复 '是' 继续，或指定其他流程）"

## 自我检查

- [ ] 已检测 leaspec/ 目录是否存在
- [ ] 已分析需求类型（模糊/明确/新领域/修改/实现）
- [ ] 已向用户确认判决结果
- [ ] 已正确调用下游 skill
