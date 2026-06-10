# Tasks: {{FEATURE_NAME}}

> 任务列表。执行顺序：Phase 1 → Phase 2 → 按优先级排列的 User Story → Polish。
> 标记 `[P]` 的任务是并行候选。执行前仍必须验证依赖和写入范围。

## Task Format

每个任务必须包含:

- 任务 ID: `T001`, `T002`, ...
- 可选 `[P]`: 仅表示并行候选
- User Story 标签: User Story 阶段必须包含 `[US1]`, `[US2]`, ...
- 精确文件路径
- `Write scope`: 预计写入文件/目录
- `Depends on`: 依赖任务 ID，或 `none`
- `Parallel safety`: 为什么可并行；不可并行则说明原因

## Phase 1: Setup

- [ ] T001 Create project scaffolding per `design.md`
  - Write scope: `path/to/project`
  - Depends on: none
  - Parallel safety: sequential setup task
- [ ] T002 Install dependencies and verify build
  - Write scope: dependency manifests and lockfiles
  - Depends on: T001
  - Parallel safety: depends on setup

## Phase 2: Foundational

- [ ] T003 [P] {{FOUNDATIONAL_TASK}} in `path/to/file`
  - Write scope: `path/to/file`
  - Depends on: none
  - Parallel safety: no shared write scope with other `[P]` tasks
- [ ] T004 [P] {{FOUNDATIONAL_TASK}} in `path/to/file`
  - Write scope: `path/to/file`
  - Depends on: none
  - Parallel safety: no shared write scope with other `[P]` tasks

## Phase 3: {{US1_TITLE}} (P1) — {{USER_STORY_REF}}

- [ ] T005 [P] [US1] {{TASK}} in `path/to/file`
  - Write scope: `path/to/file`
  - Depends on: T003
  - Parallel safety: no shared write scope
- [ ] T006 [US1] {{TASK}} in `path/to/file`
  - Write scope: `path/to/file`
  - Depends on: T005
  - Parallel safety: depends on T005

## Phase 4: {{US2_TITLE}} (P2) — {{USER_STORY_REF}}

- [ ] T007 [P] [US2] {{TASK}} in `path/to/file`
  - Write scope: `path/to/file`
  - Depends on: T003
  - Parallel safety: no shared write scope

## Phase N: Polish

- [ ] T0XX Lint and format code
  - Write scope: changed files
  - Depends on: all implementation tasks
  - Parallel safety: final sequential validation
- [ ] T0XX Final integration test pass
  - Write scope: none
  - Depends on: all implementation tasks
  - Parallel safety: read-only validation
- [ ] T0XX Update documentation
  - Write scope: `docs/`
  - Depends on: relevant implementation tasks
  - Parallel safety: no shared write scope with code tasks

---

## Verification Checklist

- [ ] All tasks completed
- [ ] All tests pass
- [ ] Design matches implementation
- [ ] Spec coverage complete
- [ ] Constitution gates re-verified
- [ ] Execution assessment completed before implementation
- [ ] `[P]` tasks validated against dependencies and write scopes

---

**Total Tasks**: XX
**Estimated Effort**: XX hours
