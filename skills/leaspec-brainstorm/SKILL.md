---
name: leaspec-brainstorm
description: Socratic requirements clarification and design exploration. Use BEFORE any code is written. Use when the user has a vague idea, wants to explore options, asks to "brainstorm", "discuss", "design", or "explore" a feature, or when requirements are ambiguous. This skill MUST be used before leaspec-specify or leaspec-change when requirements are not yet clear.
terminates: leaspec-specify, leaspec-change
---

# leaspec-brainstorm — 需求澄清与方案探索

在编写正式规范（spec）之前，通过 Socratic 式提问将模糊想法转化为清晰的设计方案。

## HARD GATE

```
在用户批准设计方案之前：
- 不得调用任何实现 skill
- 不得编写任何代码
- 不得创建项目脚手架
- 不得采取任何实现行动

这适用于每个项目，无论感觉多么简单。
简单的项目正是未经检验的假设造成最多浪费的地方。
```

## 核心原则

1. **一次只问一个问题** — 每个问题附带选项表格，推荐一个并说明理由
2. **Ruthless YAGNI** — 不断挑战不必要的复杂度。每次设计评审问自己：「这真的必要吗？」
3. **增量验证** — 每个设计小节产出后征求用户确认，不要全部写完再一起呈现
4. **禁止写代码** — 在用户确认设计方案之前，不允许写任何实现代码

## 执行流程

### Step 1: 探索上下文

- 读取 `leaspec/constitution.md`（如存在）— 了解项目宪法原则
- 读取相关 `leaspec/specs/*.md`（如存在）— 了解已有规范
- 浏览相关源码 — 了解当前实现状态

### Step 2: 逐一澄清需求

按以下维度逐一提问，**每次只问一个**（最多 5 个）：

| 维度 | 示例问题 |
|------|----------|
| 功能范围 | "这个功能的核心价值是什么？侧重点在哪？" |
| 用户场景 | "谁来用？主要场景是什么？" |
| 数据模型 | "核心实体是什么？它们之间的关系？" |
| 边界条件 | "X 不可用时系统如何响应？" |
| 非功能需求 | "性能/安全/扩展性方面的约束？" |
| 集成点 | "需要和哪些已有系统/模块交互？" |

每个问题格式:
```
**推荐：** 选项 [X] — <理由>

| 选项 | 描述 |
|------|------|
| A    | ...   |
| B    | ...   |
```

### Step 3: 方案对比

提出 2-3 种可行方案:

```
方案 A: <名称>
  - 优点: ...
  - 缺点: ...
  - 复杂度: 低/中/高

方案 B: <名称>
  - 优点: ...
  - 缺点: ...
  - 复杂度: 低/中/高

推荐: 方案 X，因为 ...
```

### Step 4: 输出设计文档

将确认的方案写入变更目录:
- 运行 `bash leaspec/scripts/helpers.sh` 获取编号
- 创建 `leaspec/changes/<NNN>-<name>/proposal.md`

### Step 5: 自我审查（必须）

在呈现给用户前，以全新视角检查:
- [ ] 所有用户关注点已有回应？
- [ ] 方案与 constitution 不冲突？
- [ ] Scope 清晰（In/Out Scope 明确）？
- [ ] 没有 TBD/TODO/未解决的不确定性？

## 红旗 — 立即停止并重新评估

如果发现自己有以下想法，这是需要回到 Step 2 的信号:

| 红旗信号 | 现实 |
|----------|------|
| "这很简单，不需要设计" | 简单项目是假设造成最多浪费的地方 |
| "我已经知道用户要什么了" | 不经确认的假设是 bug 的来源 |
| "我先写代码再看看" | 没有设计基准，review 无据可依 |
| "一个方案就够了" | 没有对比就无法验证方案选择 |
| "边做边设计" | 「边做边设计」==「没有设计」 |

## 合理化反驳

| 借口 | 现实 |
|------|------|
| "太简单不需要设计" | 简单代码也会出问题。30 秒的思考值得。 |
| "用户说随便做" | "随便"意味着没有验收标准。必须定义。 |
| "我先探索一下代码" | 探索 OK。但探索前先理解「为什么」。 |
| "需求和已有功能类似" | 那就引用已有 spec。不需要重新设计但需要明确范围。 |

## 过渡

完成后提示用户:
- 新领域 → 运行 `/leaspec-specify` 生成正式规范
- 修改已有规范 → 运行 `/leaspec-change` 生成增量规范
