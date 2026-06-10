---
name: leaspec-execute
description: Execute implementation tasks from an approved plan using adaptive orchestration. Use after leaspec-plan when tasks.md is ready. Starts with execution assessment, chooses the simplest safe mode for low-risk work, and asks for confirmation before complex or high-risk execution such as worktree-backed parallelism.
requires: leaspec-plan
terminates: leaspec-review
---

# leaspec-execute — 自适应实现执行

基于 `tasks.md` 执行实现，但不得假设默认线性、默认 subagent 或默认并行。执行前必须先评估任务图、写入范围、风险和运行环境，再选择或推荐执行模式。

## HARD GATE

```
在失败的测试之前，不得编写生产代码。
违反这条规则 = 必须删除违规代码，重新开始。

在执行评估之前，不得开始实现。
高风险执行模式未经用户确认，不得创建 worktree、切换分支或改代码。
```

## 前置条件

- `tasks.md` 存在且有未完成任务
- `design.md` 存在（架构参考）
- `spec.md` 存在（需求参考）
- `plan.md` 存在（任务依赖和执行策略参考）

若缺失 → ERROR，提示先运行对应 skill。

## 核心原则

1. **Assessment First** — 先评估任务图、写入范围、git/worktree 状态、基线测试和可用能力
2. **Risk-Based Decision** — 简单低风险可自动执行；复杂或高风险必须先让用户确认
3. **TDD** — RED → GREEN → REFACTOR，不可颠倒
4. **Scoped Changes** — 只修改当前任务允许的写入范围
5. **Review Gates** — 每个任务或切片必须先过 spec 合规审查，再过代码质量审查
6. **Traceable Execution** — 记录执行模式、风险等级、任务状态、测试结果和审查结论

## Step 1: Execution Assessment（必须先做）

读取 `tasks.md`、`plan.md`、`design.md`、`spec.md` 后，输出执行评估。

评估内容:

| Area | Required Check |
|------|----------------|
| Task graph | Phase、User Story、依赖、阻塞任务、候选 `[P]` 分组 |
| Write scopes | 每个任务的文件/目录写入范围；是否存在共享写入范围 |
| Parallel safety | `[P]` 是否真的无依赖、不同写入范围、无共享状态 |
| Risk signals | 迁移、删除、公共 API、认证安全、包管理、构建/CI、spec/archive 风险 |
| Git state | 是否在 git 仓库、当前分支、是否 main/master、是否脏工作区 |
| Worktree state | 是否已在 linked worktree、是否需要创建 worktree、是否可安全清理 |
| Baseline | 可用测试命令、基线测试是否通过、失败是否已知且无关 |
| Capabilities | 当前环境是否有 subagent 工具；是否有可用 git/worktree |

输出格式:

```markdown
## Execution Assessment
- Risk: low / medium / high
- Recommended Mode: linear-local / subagent-sequential / worktree-parallel / blocked-needs-human
- Alternative Modes:
  - <mode> — <tradeoff>
- Confirmation Required: yes / no
- Reasons:
  - ...
- Blocking Risks:
  - ...
- Task Groups:
  - Group A: T001, T002 — reason
```

## Step 2: Risk Classification

### Low Risk

满足全部条件才是 low:

- 单 repo / 单 area
- 工作区干净，或当前不是 git 仓库
- 基线测试通过，或项目没有可识别基线测试
- 所有任务有明确写入范围
- 候选并行任务无同文件/同目录写入冲突
- 不涉及迁移、删除、公共行为、安全认证、包管理、构建/CI 或 spec/archive 合并风险
- 不需要创建 worktree

Low risk 行为: Agent 可选择最简单安全模式并继续，但必须先报告 assessment。

### Medium Risk

常见信号:

- 多个相关任务共享上下文，但不需要 destructive 操作
- subagent 顺序执行有明显价值
- 已知基线失败与当前变更无关
- `[P]` 候选存在，但不足以推荐 worktree 并行

Medium risk 行为: 若选择非破坏性模式且不创建 worktree，可继续；否则先确认。

### High Risk

任一信号即 high:

- git 工作区为脏
- 当前分支是 `main` 或 `master` 且需要实现
- 需要创建 branch 或 worktree
- 推荐多个 worktree 或并行实现切片
- 跨 repo / 跨 area 所有权
- `[P]` 任务共享写入范围或存在隐式依赖
- 涉及迁移、删除、安全认证、公共 API、包管理、构建系统、CI
- 基线测试失败且原因不清
- 可能存在 stale spec/archive 风险

High risk 行为: 停止，给出推荐模式、备选模式和主要风险，等待用户确认。若没有安全备选，必须明确写 `Alternative Modes: none — <原因>`。

## Step 3: Execution Modes

| Mode | Use When | Confirmation |
|------|----------|--------------|
| `linear-local` | 任务少、强耦合、subagent/worktree 收益低 | low risk 不需要；medium/high 按风险规则 |
| `subagent-sequential` | 任务可拆、需要 fresh context，但共享一个工作区更安全 | medium 可自动；high 需确认 |
| `worktree-parallel` | 任务组无依赖、写入范围不重叠，且并行收益足够 | 总是需要确认 |
| `blocked-needs-human` | 任务图、写入范围、git 状态或需求不清，无法安全执行 | 必须等待用户 |

不得因为任务标了 `[P]` 就直接并行。`[P]` 只是候选信号，必须通过写入范围和依赖验证。

## Step 4: Subagent Contract

只有当前工具环境提供 subagent 能力时才使用。若不可用，降级到 `linear-local` 或请求用户确认其他模式。

每个实现 subagent 必须收到:

- 完整任务文本（不要只让它自己读 `tasks.md`）
- 对应 FR / User Story / Acceptance Scenario 摘要
- `design.md` 中相关架构约束
- 允许修改的文件/目录
- TDD 要求和测试命令
- 提交/变更范围要求
- 报告格式

Subagent 报告状态:

| Status | Controller Action |
|--------|-------------------|
| `DONE` | 进入 spec compliance review |
| `DONE_WITH_CONCERNS` | 先处理 concern；若影响正确性或范围，不得进入 review |
| `NEEDS_CONTEXT` | 补充上下文后再派发 |
| `BLOCKED` | 改变上下文、模型能力、任务拆分或询问用户；不得无变化重试 |

## Step 5: TDD Execution

对每个任务或切片:

1. 写失败测试或验证夹具
2. 运行并确认失败原因正确（RED）
3. 编写最小实现（GREEN）
4. 重构并保持测试通过
5. 记录 TDD 证据

若任务是纯文档/skill 指令更新，测试可以是:

- fixture-based behavior check
- markdown structure validation
- spec coverage checklist
- `validate.sh` 校验

## Step 6: Review Gates

每个任务或切片完成后必须按顺序过门禁:

1. **TDD Evidence** — 看到测试或夹具先失败/未满足，再实现通过
2. **Spec Compliance Review** — 是否满足对应 FR/US，没有多做
3. **Code Quality Review** — 命名、结构、简洁性、错误处理、可维护性
4. **Regression Check** — 相关测试或校验通过

Spec 合规没过，不得进入代码质量审查。

## Step 7: Worktree Guardrails

推荐或创建 worktree 前:

1. 检测是否已在 linked worktree
2. 检测 submodule，避免误判为 worktree
3. 检查 git 分支和脏工作区
4. 对项目内 `.worktrees/` 确认已被忽略
5. 展示 worktree 路径、branch 名、任务组、合并策略
6. 等待用户确认

清理规则:

- 只清理本次 leaspec 创建且有 provenance 记录的 worktree
- 不清理外部 harness 或用户创建的 worktree
- 用户选择 PR / 保留分支时，不清理 worktree

## Step 8: Execution State

执行评估后创建或更新变更目录中的执行状态。建议文件名: `execution.yaml`。

最小字段:

```yaml
version: 1
change: <change-id>
risk: low
mode: linear-local
baseline:
  status: pass
tasks:
  T001:
    status: pending
    write_scope: []
    reviews:
      tdd: pending
      spec: pending
      quality: pending
      regression: pending
worktrees: []
```

恢复执行时:

- 读取已有 execution state
- 跳过已完成且 review 全过的任务
- 对 interrupted / blocked 任务重新评估
- 如果任务文件或环境变化，重新生成 assessment

## Step 9: Completion

所有任务完成后:

1. 运行完整可用验证
2. 确认 `tasks.md` 全部 `[X]`
3. 汇总执行模式、风险、测试和 review 结果
4. 提示用户运行 `/leaspec-review`

## Commit Policy

如果当前目录是 git 仓库:

- 每个任务完成后提交
- 提交前只 `git add` 当前任务相关文件
- 提交信息遵循 commitizen 格式，例如 `feat(leaspec-execute): add execution assessment`

如果当前目录不是 git 仓库:

- 跳过提交
- 在最终报告中明确说明未提交原因

## 红旗

| 红旗信号 | 行动 |
|----------|------|
| 未做 assessment 就实现 | 停止，先补 assessment |
| 高风险未确认就执行 | 停止并回滚未授权操作 |
| `[P]` 共享写入范围 | 不得并行 |
| subagent 报告 concern 却继续 | 停止处理 concern |
| spec review 未过就做 quality review | 回到 spec review |
| worktree provenance 不明 | 不得清理 |

## 过渡

完成后提示用户运行 `/leaspec-review` 进行整体审查。
