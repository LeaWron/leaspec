---
name: leaspec-archive
description: Archive a completed change by merging spec deltas into the main specs and moving the change to the archive. Use after leaspec-review is APPROVED. Merges incremental specs (ADDED/MODIFIED/REMOVED) into leaspec/specs/ and moves the change directory to leaspec/archive/. Triggers when review is approved and user wants to "archive", "complete", or "finish" a change.
requires: leaspec-review
terminates: leaspec-brainstorm, leaspec-specify, leaspec-change
---

# leaspec-archive — 归档已完成变更

将已实现并审查通过的变更归档，合并增量规范到真相源。

## HARD GATE

**归档前必须确认:** Review 已 APPROVED。所有 CRITICAL 和 IMPORTANT issues 已修复。

## 前置条件

- 变更目录下所有 tasks 已完成（全部 `[X]`）
- Review 已通过（无 CRITICAL / IMPORTANT Issues）
- 用户确认归档
- 若变更修改或移除已有需求，stale spec 检测必须通过

## 执行流程

### Step 1: 确认归档

向用户展示:
- 变更摘要（proposal 标题）
- 影响的 spec 文件
- 变更统计（新增/修改/删除的 FR 数量）

请用户确认。

### Step 2: 合并增量规范

合并前先执行 stale spec 检测:

1. 检查变更目录是否记录了被修改/移除需求的基线指纹或等价基线记录
2. 对当前 `leaspec/specs/` 中对应需求重新计算或人工核对当前内容
3. 如果当前内容与基线不一致，停止归档
4. 提示用户先同步/人工协调该需求，再重新 review 和 archive

不得在 stale spec 风险未解决时继续合并。

对于 `change/NNN-name/spec.md` 中的变更，合并到对应 `specs/<domain>.md`:

**ADDED 需求** → 追加到目标 spec 的 Functional Requirements 表
**MODIFIED 需求** → 更新目标 spec 中对应的 FR 行
**REMOVED 需求** → 从目标 spec 中移除，保留在归档记录中

合并规则:
- 保持表格格式一致
- 更新目标 spec 的 **Last Updated** 为当前日期
- 如有新增 Entities / User Stories / Success Criteria → 同步追加

### Step 3: 移动变更目录

当前没有确定性归档脚本。完成 Step 2 的 spec 合并后，手工执行归档移动:

```bash
mkdir -p leaspec/archive
mv "leaspec/changes/<NNN-name>" "leaspec/archive/<YYYY-MM-DD>-<name>"
```

移动规则:
1. 移动前检查变更完整性（proposal, spec 是否存在）
2. 仅在主规范已完成合并后移动变更目录
3. 归档路径使用 `archive/YYYY-MM-DD-<name>/`
4. 如目标归档目录已存在，停止并请用户确认新的归档目录名

### Step 4: 按 config.yaml 提交

提交前必须读取 `leaspec/config.yaml` 中的 git 配置。不得跳过该配置，不得用默认值替代缺失或不可读配置。

必须遵守:

1. 如果当前目录不是 git 仓库，跳过提交并在归档摘要中说明。
2. 如果 `git.track_leaspec: true`:
   - 可以使用 `git add leaspec/`
   - 不得对 `leaspec/` 使用 `git add` 的强制参数
   - 如果 git 提示 `leaspec/` 被 ignore 规则排除，必须停止并要求用户协调 `leaspec/config.yaml` 与 ignore 规则
3. 如果 `git.track_leaspec: false`:
   - 不得执行 `git add leaspec/`
   - 不得对 `leaspec/` 使用 `git add` 的强制参数
   - 归档摘要必须说明 `leaspec/` 归档产物按配置保持本地/未追踪
4. 如果 `git.track_agent_dirs: true`:
   - 仅可正常 staging agent 目录，例如 `git add .agents/ .claude/`
   - 不得对 agent 目录使用 `git add` 的强制参数
   - 如果 agent 目录被 ignore 规则排除，必须停止并要求用户协调配置
5. 如果 `git.track_agent_dirs: false`:
   - 不得 staging `.agents/`、`.claude/` 或等价 agent 目录
6. `ignore_method` 仅描述忽略规则位置，不授权强制添加被忽略文件。

禁止使用任何 `git add` 的强制参数（`-f` / `--force`）处理 `leaspec/`、`.agents/`、`.claude/` 或其他被 ignore 规则排除的路径。

允许的提交示例（仅当 `track_leaspec: true` 且路径未被 ignore）:

```bash
git add leaspec/
git status --short
git commit -m "feat(leaspec): archive change <NNN>-<name>

- Merged spec changes for <domain>
- Archived to leaspec/archive/<YYYY-MM-DD>-<name>"
```

如果配置禁止 staging 或没有允许提交的变更，跳过 commit，不得通过 `-f` 制造提交。

### Step 5: 输出归档摘要

```markdown
# Archive Complete: {{CHANGE_NAME}}

## Changes Applied
| File | Action | Details |
|------|--------|---------|
| specs/auth.md | MODIFIED | Updated FR-003, Added FR-042-FR-045 |

## Archived To
`leaspec/archive/{{YYYY-MM-DD}}-{{CHANGE_NAME}}/`

## Next Steps
运行 `/leaspec-new <描述>` 开启下一个变更。
```

## 归档后的回顾

建议用户考虑:
- 是否要清理 `leaspec/changes/` 中已空的目录？
- 是否需要更新相关文档？
- Constitution 原则是否需要重新审视？
