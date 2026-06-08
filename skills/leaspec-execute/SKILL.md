---
name: leaspec-execute
description: Execute implementation tasks from an approved plan using TDD. Use after leaspec-plan when tasks.md is ready. Each task runs with a test-first approach — write failing test, verify failure, implement, verify pass. Triggers when the user has completed tasks.md and asks to "implement", "execute", "code", or "build" the feature.
requires: leaspec-plan
terminates: leaspec-review
---

# leaspec-execute — 实现执行

基于 tasks.md 按 TDD 逐任务实现。

## HARD GATE

```
在失败的测试之前，不得编写生产代码。
违反这条规则 = 必须删除违规代码，重新开始。

这不是建议。这不是偏好。这是不可谈判的约束。
```

## 前置条件

- `tasks.md` 存在且所有任务未完成
- `design.md` 存在（架构参考）
- `spec.md` 存在（需求参考）

若缺失 → ERROR，提示先运行对应 skill。

## 核心原则

1. **RED → GREEN → REFACTOR** — 测试在代码前，不可颠倒
2. **最小实现** — 只写让测试通过的最少代码
3. **一个 task 一个 commit** — 每个任务完成后提交
4. **持续验证** — 任务间不需要人工确认，自动推进

## 执行流程

### Step 1: 准备

1. 读取 `tasks.md` — 确认任务顺序
2. 读取 `design.md` — 确认架构
3. 读取 `spec.md` — 确认需求

### Step 2: 按 Phase 顺序执行

对每个 Phase 中每个未完成任务:

**2a. 编写失败测试**

```
1. 在对应的 __tests__/ 目录创建/修改测试文件
2. 测试必须验证 spec 中的具体行为
3. 运行测试，确认失败（RED）
```

**2b. 编写最小实现**

```
1. 编写刚好让测试通过的代码
2. 运行测试，确认通过（GREEN）
3. 不允许添加测试未覆盖的「额外」功能
```

**2c. 自检重构**

```
1. 代码可读性 OK？
2. 有重复吗？
3. 遵循 YAGNI 吗？
4. 如果有改进空间 → 重构 → 运行测试 → 确认仍通过
```

**2d. 提交**

```
git add <changed-files>
git commit -m "feat(TXXX): <task-description>"
```

**2e. 标记完成**

在 tasks.md 中将 `- [ ]` 改为 `- [X]`。

### Step 3: 阶段检查点

每个 Phase 结束后:
1. 运行完整测试套件
2. 确认没有引入回归

### Step 4: 最终验证

所有任务完成后:
1. 运行完整测试套件
2. 运行 linter / 类型检查
3. 对照 spec 手动验证关键场景

## TDD 铁律

```
生产代码 → 测试存在并且先失败
否则 → 不是 TDD
```

## 红旗 — 立即停止并回到 Step 2a

| 红旗信号 | 行动 |
|----------|------|
| 测试之前的代码 | **删除代码。重新开始。** |
| 实现之后的测试 | 删除测试，从 Step 2a 重新开始 |
| 测试立即通过 | 你的测试没有在验证新行为。回到 Step 2a |
| "稍后"添加的测试 | 不存在"稍后"。现在就写。 |
| "我已经手动测试过了" | 手动的 ≠ 系统化的。写自动化测试。 |
| "保留作为参考" | 不要保留。**删除代码。重新开始。** |

## 合理化反驳

| 借口 | 现实 |
|------|------|
| "太简单不需要测试" | 简单代码也会出问题。测试只需 30 秒。 |
| "先写代码再补测试" | 先写会验证实现的行为而非需求的行为。 |
| "测试难写 = 设计有问题" | 听测试的。重构设计。 |
| "TDD 会拖慢我" | TDD 比 debug 更快。 |

## 过渡

完成后提示用户运行 `/leaspec-review` 进行整体审查。
