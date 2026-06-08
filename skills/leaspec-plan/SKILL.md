---
name: leaspec-plan
description: Generate a technical implementation plan and task breakdown from an approved spec. Use after leaspec-specify or leaspec-change when the spec is ready. Creates design.md, plan.md, research.md, and tasks.md. Triggers when the user has an approved spec and asks for "plan", "how to implement", "break down", or "next steps".
requires: leaspec-specify, leaspec-change
terminates: leaspec-execute
---

# leaspec-plan — 技术方案与任务拆分

基于已批准的 spec 生成技术方案、研究文档和可执行任务列表。

## HARD GATE

**Constitution Check 必须在 Phase 0 (research) 前通过。**
任何违反宪法原则的决策必须记录在 Complexity Tracking 表中并说明理由。未记录 = 不允许。

## 前置条件

变更目录中必须存在:
- `proposal.md` — 已评审
- `spec.md` — 已评审

若缺失任何文件 → ERROR，提示用户先运行对应的 skill。

## 执行流程

### Step 1: 技术上下文确认

若 proposal 中未明确，向用户确认:
- 语言 / 运行时
- 框架
- 存储方案
- 外部依赖
- 目标平台

只问未明确的关键选择，不要问所有。

### Step 2: Research (Phase 0)

对不确定的技术点进行调研:

1. 在项目中搜索相关实现: `grep -r "<keyword>" src/`
2. 搜索外部最佳实践（如需要）
3. 每个决策记录: 决策 + 理由 + 备选方案

产出 `research.md`。

### Step 3: 生成 design.md

从 `leaspec/templates/design.md` 生成:

1. **Technical Context** — 从 Step 1 获取
2. **Architecture Decisions** — 每个决策单独说明 Context / Options / Decision / Rationale
3. **Project Structure** — 源码树
4. **Constitution Check（宪法门禁）** — 逐条检查:

| Gate | Status | Notes |
|------|--------|-------|
| Library-First | ✅ / ⚠️ | 功能是否可独立运行？ |
| Test-First (TDD) | ✅ / ⚠️ | 测试策略？ |
| Simplicity | ✅ / ⚠️ | 是最简方案吗？ |
| Integration-First Testing | ✅ / ⚠️ | 集成测试如何组织？ |
| Observable | ✅ / ⚠️ | 关键操作有日志/指标？ |

5. **Complexity Tracking** — 记录违规和例外:

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| | | |

**关键是在判断过程中，如果你认为需要了解实际情况才能决策，就应该去读代码。**

### Step 4: 生成 plan.md

从模板生成，按 Phase 组织:

```
Phase 1: Setup       — 项目初始化
Phase 2: Foundational — 所有 User Story 依赖的基础
Phase 3+: User Stories — 按 P1/P2/P3
Phase N: Polish      — 文档、性能、收尾
```

- 标注 `[P]` 并行任务
- 绘制依赖图
- 选择实现策略（MVP-first / Incremental / Parallel）

### Step 5: 生成 tasks.md

从 `leaspec/templates/tasks.md` 生成。

**严格格式:**
```
- [ ] T001 [P] [US1] 描述 in path/to/file
```

要求:
1. **任务 ID**: T001, T002, ... 顺序编号
2. **`[P]` 标记**: 可选 — 仅当可并行时
3. **`[Story]` 标签**: User Story 阶段必须: `[US1]`, `[US2]`。Setup/Foundational 阶段无标签
4. **描述**: 必须包含精确文件路径
5. **粒度**: 单个任务应在 5-15 分钟内可完成

**绝对禁止的占位符（会导致 Plan 失败）:**
- "TBD"、"TODO"、"稍后实现"
- "添加适当错误处理" / "添加验证"（说具体是什么错误/验证）
- "类似于 T00N"（不要重复代码）
- 只描述做什么而不展示怎么做的步骤
- 引用未定义的类型/函数

**每个任务必须包含实际可执行的具体内容。** 工程师拿到任务后可以直接开始编码，不需要再去理解业务。

### Step 6: 自我审查

- [ ] design.md 通过了所有 Constitution Check gates？
- [ ] plan.md 中 Phase 划分合理且依赖明确？
- [ ] tasks.md 中无占位符（所有任务有具体描述和文件路径）？
- [ ] 测试先行（TDD 顺序: 测试 → 实现）？
- [ ] 所有 spec 需求都有对应的 task 覆盖？（覆盖度检查）

### Step 7: 覆盖率验证

逐条对照 spec.md:
- 每个 `FR-XXX` 需求 → 至少 1 个 task
- 每个 Acceptance Scenario → 至少 1 个 task
- 每个 `SC-XXX` 成功标准 → 有验证方式

未覆盖的需求 → 补充 task。

## 过渡

完成后提示用户运行 `/leaspec-implement` 开始实现。
