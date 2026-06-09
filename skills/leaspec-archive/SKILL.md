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

## 执行流程

### Step 1: 确认归档

向用户展示:
- 变更摘要（proposal 标题）
- 影响的 spec 文件
- 变更统计（新增/修改/删除的 FR 数量）

请用户确认。

### Step 2: 合并增量规范

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

### Step 4: 提交

```bash
git add leaspec/
git commit -m "feat(leaspec): archive change <NNN>-<name>

- Merged spec changes for <domain>
- Archived to leaspec/archive/<YYYY-MM-DD>-<name>"
```

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
