---
name: leaspec-specify
description: Generate a complete specification for a NEW domain (0→1). Use when requirements are clear and the target domain has no existing spec in leaspec/specs/. Creates a full specification with user stories, functional requirements, key entities, and success criteria. Triggers after leaspec-brainstorm or when the user describes a clear feature for an unmodeled domain.
requires: leaspec-init
terminates: leaspec-plan
---

# leaspec-specify — 0→1 生成新领域规范

为尚无规范的领域生成完整的功能规范。

## HARD GATE

**规范是真相源。代码是规范的实现。**
规范未经过用户评审批准前，不得进入 plan 或实现阶段。

## 前置条件

1. `leaspec/` 已初始化
2. `leaspec/specs/` 中不存在目标领域的规范文件（若存在 → 使用 `leaspec-change`）
3. 需求已足够明确（或已通过 brainstorm 澄清）

## 执行流程

### Step 1: 创建变更目录

```bash
NEXT_NUM=$(bash leaspec/scripts/helpers.sh get_next_change_number)
CHANGE_DIR="leaspec/changes/${NEXT_NUM}-<feature-name>"
mkdir -p "$CHANGE_DIR"
```

### Step 2: 生成 proposal.md

从 `leaspec/templates/proposal.md` 模板生成，明确:
- **Why**: 从用户描述中提取业务动机
- **Scope**: In scope / Out of scope 必须清晰
- **Related Specs**: 标注为 NEW

### Step 3: 生成 spec.md

从 `leaspec/templates/spec.md` 模板生成，强制执行以下规范:

**User Stories（必须）:**
- 按优先级 P1/P2/P3 排列
- 每个附带 Given/When/Then 验收场景（至少 1 个）
- 每个 User Story 必须独立可测试

**Functional Requirements（必须）:**
- 使用 `FR-001`, `FR-002`, ... 格式编号
- 使用 RFC 2119 关键词: SHALL, MUST, SHOULD, MAY
- 每项需求量化且可测试
- `[NEEDS CLARIFICATION]` 标记限制: **最多 3 个**
  - 若超过 3 个，仅保留最关键的 3 个（优先级: 范围 > 安全/隐私 > UX > 技术细节）
  - 其余做有根据的猜测并在 Assumptions 中记录
  - 每个标记必须附带选项表格供用户选择

**Key Entities（涉及数据时必填）:**
- 领域概念，不带实现细节（不涉及数据库/框架）

**Success Criteria（必须）:**
- 使用 `SC-001`, `SC-002`, ... 格式编号
- 必须可衡量、与技术无关
- ❌ 错误: "API 响应时间 < 200ms"（与技术相关）
- ✅ 正确: "用户 3 分钟内完成结账"（与技术无关）

**Assumptions:**
- 记录规范编写时做出的合理假设

### Step 4: 技术无关性审查

规范中**不得**出现以下内容:
- 编程语言、框架、数据库名称
- API 路径、协议细节
- 文件结构、模块名称
- 任何实现细节

如果有 → 移除，替换为行为描述。

### Step 5: 用户评审

逐部分呈现给用户确认:
1. User Stories → 确认用户场景完整
2. Functional Requirements → 确认需求正确
3. Success Criteria → 确认验收标准合理

### Step 6: 自我审查

评审完成的 spec:
- [ ] 所有 User Stories 有 Given/When/Then 场景？
- [ ] 所有 FR 使用 RFC 2119 关键词（SHALL/MUST/SHOULD/MAY）？
- [ ] `[NEEDS CLARIFICATION]` 不超过 3 个？
- [ ] 无技术栈/实现细节语言？
- [ ] Out of scope 清晰标注？
- [ ] 与 `leaspec/constitution.md` 原则一致？
- [ ] Success Criteria 可衡量且与技术无关？

### Step 7: 验证

```bash
bash leaspec/scripts/validate.sh "$CHANGE_DIR/spec.md"
```

## 过渡

完成后提示用户运行 `/leaspec-plan` 生成技术方案和任务拆分。
