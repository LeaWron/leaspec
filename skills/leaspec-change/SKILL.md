---
name: leaspec-change
description: Manage an incremental change to existing specifications. Use when modifying, extending, or removing behavior documented in leaspec/specs/. Creates a spec-diff (ADDED/MODIFIED/REMOVED) instead of a full spec. Triggers when the user's request targets an area that already has a spec file, or after leaspec-brainstorm for modifications to existing features.
requires: leaspec-init
terminates: leaspec-plan
---

# leaspec-change — 增量变更管理

对已有规范进行增量修改。只描述变化，不重复整个 spec。

## HARD GATE

**增量规范只描述变化部分。** 严禁复制整个已有 spec。归档时增量将合并到真相源。如果复制了整份 spec，归档时会丢失上下文。

## 前置条件

1. `leaspec/specs/` 中存在目标领域的规范文件
2. 用户需求是对该规范的修改或扩展

## 执行流程

### Step 1: 读取上下文

必须读取:
- `leaspec/specs/<target-domain>.md` — 当前真相源
- `leaspec/constitution.md` — 项目宪法
- 相关源码 — 了解当前实现

### Step 2: 创建变更目录

```bash
NEXT_NUM=$(bash leaspec/scripts/helpers.sh get_next_change_number)
CHANGE_DIR="leaspec/changes/${NEXT_NUM}-<change-name>"
mkdir -p "$CHANGE_DIR"
```

### Step 3: 生成 proposal.md

使用模板，重点填写:
- **Related Specs** 表 — 标注每个受影响文件的 Impact 类型
- **Approach** — 变更思路

### Step 4: 生成增量 spec (spec.md)

使用 `leaspec/templates/spec-diff.md`，分三部分:

**ADDED — 新增需求:**
```
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-042 | The system SHALL send email notification on order confirmation | P1 |
```
- 新增需求按已有编号顺延
- 附带 Given/When/Then 场景

**MODIFIED — 修改已有需求:**
```
| ID | Original | Modified |
|----|----------|----------|
| FR-001 | The system SHALL require email | The system SHALL require email OR phone |
```
- 引用原始 FR ID
- 附带影响分析: 为什么改、影响哪些组件

**REMOVED — 删除需求:**
```
| ID | Original Requirement | Removal Reason |
|----|---------------------|----------------|
| FR-999 | Support legacy XML format | Replaced by JSON API (FR-100) |
```
- 必须说明删除原因
- 如有替代方案，标注替代的 FR ID

### Step 6: 自我审查

- [ ] 只描述了变更部分（没有复制整个 spec）？
- [ ] MODIFIED 引用了原始 FR ID？
- [ ] REMOVED 说明了删除原因和替代方案？
- [ ] 新增需求使用 RFC 2119 关键词？
- [ ] 与 constitution 原则一致？
- [ ] 新增需求附带验收场景？
- [ ] 影响分析完整？

### Step 7: 验证

```bash
bash leaspec/scripts/validate.sh "$CHANGE_DIR/spec.md"
```

## 过渡

完成后提示用户运行 `/leaspec-plan` 生成技术方案和任务拆分。
