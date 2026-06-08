---
name: leaspec-init
description: Initialize the leaspec directory structure in a project. Use when the project has no leaspec/ directory, when setting up spec-driven development for the first time, or when the user asks to "init leaspec", "set up specs", or "initialize the spec system".
terminates: leaspec-brainstorm, leaspec-specify, leaspec-change
---

# leaspec-init — 初始化项目规范结构

在目标项目中创建 `leaspec/` 目录和完整的规范管理结构。

## HARD GATE

**在 leaspec/ 目录存在之前，不得执行任何其他 leaspec 流程。**
此技能是全部后续流程的前置条件。不得跳过。

## 执行流程

### Step 1: 确认初始化位置

- 默认在当前项目根目录
- 使用 `find` 或 `ls` 检查 `leaspec/` 是否已存在
- 若已存在 → 向用户输出 "leaspec/ 已存在，是否合并（跳过已有文件）？" → 等待用户回答后才继续
- 若用户拒绝合并 → 停止执行

### Step 2: 交互式采集 config.yaml 配置（Agent 对话引导）

**Agent 必须以表格形式一次性向用户展示 config.yaml 的全部 6 个字段及其默认值，引导用户审阅和修改：**

| 字段 | 默认值 | 说明 |
|------|--------|------|
| `version` | `"1.0"` | leaspec 配置版本 |
| `track_leaspec` | `true` | leaspec/ 目录是否被 git 追踪 |
| `track_agent_dirs` | `false` | `.claude/` `.agents/` 等 agent 隐藏目录是否被 git 追踪 |
| `ignore_method` | `gitignore` | 不追踪时使用的忽略机制 |
| `project.name` | `<项目根目录名>` | 项目名称 |
| `project.description` | `""` | 项目描述 |

**Agent 需要向用户解释 `ignore_method` 的两个选项含义：**

- `gitignore` — 写入项目根目录的 `.gitignore` 文件（**团队共享**，该文件会被 git 追踪并提交到仓库）
- `exclude` — 写入 `.git/info/exclude` 文件（**仅本地生效**，不会被提交，不影响团队其他成员）

**Agent 需要向用户解释追踪选项的典型使用场景：**

- `track_leaspec=true` — leaspec/ 规范文件会被提交到 git 仓库，团队共享（推荐）
- `track_leaspec=false, ignore_method=exclude` — 个人使用 leaspec 但团队尚未采用
- `track_agent_dirs=false` — agent 配置 (.claude/ .agents/) 不追踪，每个开发者独立维护（推荐默认）
- `track_agent_dirs=true` — 团队统一 agent 配置时需要

Agent 展示表格后应询问用户：
"以上是默认配置。你可以修改任何字段（如：'version 改成 2.0，track_leaspec 改成 false，ignore_method 改成 exclude'），或直接回车使用默认值。"

**解析用户回答：** Agent 应从用户自然语言回答中提取字段名和对应值。常见的映射包括：

- "version 改成 X" / "版本 X" → CFG_VERSION=X
- "track_leaspec X" / "追踪 leaspec" / "不追踪 leaspec" → CFG_TRACK_LEASPEC=true/false
- "track_agent_dirs X" / "追踪 agent" / "不追踪 agent" → CFG_TRACK_AGENT_DIRS=true/false
- "ignore_method X" / "gitignore" / "exclude" → CFG_IGNORE_METHOD=gitignore/exclude
- "name X" / "项目名 X" → CFG_NAME=X
- "description X" / "描述 X" → CFG_DESC=X

Agent 解析后必须向用户确认："我理解你希望：... 对吗？" 然后再继续下一步。

### Step 3: 交互式审计 constitution.md（Agent 对话引导）

Agent 需要分 3 段审计宪法内容：

**段 1 — 元信息审计：**
Agent 展示宪法元信息：

| 字段 | 默认值 |
|------|--------|
| CONSTITUTION_VERSION | 1.0.0 |
| RATIFICATION_DATE | <当天的日期> |

询问用户："是否需要修改宪法版本号或批准日期？" 用户可修改或直接回车跳过。

**段 2 — Core Principles 审计：**
Agent 以表格一次性展示 6 项默认原则：

| # | 标题 | 描述 |
|---|------|------|
| 1 | Spec-as-Truth | `specs/` 目录是系统行为的权威描述，代码是规范的实现 |
| 2 | Trigger-by-Need | 根据项目状态和需求类型，自动选择最合适的流程 |
| 3 | Incremental-First | 已有规范时优先走增量变更，避免重复描述 |
| 4 | Design-Before-Code | 禁止未经设计直接编写代码 |
| 5 | Simplicity | 选择最简单的方案，反对过度抽象和过早优化 |
| 6 | Respect-Comments | 不修改任何已有注释，除非修改了对应的代码段。注释是代码上下文的一部分 |

询问用户："请决定：保留哪些？替换哪些？删除哪些？是否需要添加新原则？"
示例回答："保留 1、2、5、6，替换 3 为 'Test-First: 所有代码必须先有失败测试再编写'，删除 4，添加一项 'Observable: 系统必须可观测，关键操作产出日志和指标'"

**段 3 — Governance 审计：**
Agent 展示当前 Governance 规则：

| 规则 | 默认文本 |
|------|---------|
| 修订流程 | 修改宪法需要创建专门的 change proposal，标注 CONSTITUTION_CHANGE 标签 |
| 版本策略 | 每次修改递增 CONSTITUTION_VERSION |
| 合规审查 | 每个 plan.md 必须通过 Constitution Check gates |

询问用户："是否需要修改任何 Governance 规则？" 用户可逐条修改或直接回车跳过。

**生成宪法文件：** 审计完成后，Agent 必须：

1. 使用 `date +%Y-%m-%d` 获取当前日期填入 `LAST_AMENDED_DATE`
2. 将完整宪法内容（元信息 + 审计后的原则 + Governance 规则）写入临时文件 `/tmp/leaspec-constitution-$(date +%s).md`
3. 确认文件写入成功

### Step 4: 运行初始化脚本

Agent 拼接 CLI 命令并通过 Bash 工具执行：

```bash
bash <path-to-leaspec-src>/scripts/init.sh \
  --version "<CFG_VERSION>" \
  --name "<CFG_NAME>" \
  --description "<CFG_DESC>" \
  --track-leaspec <CFG_TRACK_LEASPEC> \
  --track-agent-dirs <CFG_TRACK_AGENT_DIRS> \
  --ignore-method <CFG_IGNORE_METHOD> \
  --constitution-file "<临时宪法文件路径>" \
  <project-root>
```

若用户在对话中明确表示"不交互"，Agent 应添加 `--non-interactive` 标志并使用全部默认值。

**脚本行为（Agent 无需手动干预）：**
- 创建 `leaspec/{specs,changes,archive,templates,scripts}`
- 根据传入的参数生成 `leaspec/config.yaml`
- 从临时宪法文件复制 `leaspec/constitution.md`
- 根据 `track_leaspec` / `track_agent_dirs` / `ignore_method` 配置处理 `.gitignore` 或 `.git/info/exclude`

### Step 5: 验证与引导

初始化后运行验证脚本确认结构完整：

```bash
bash leaspec/scripts/validate.sh leaspec/
```

Agent 应向用户报告验证结果。无论结果如何，都要提示用户：
1. 审阅 `leaspec/constitution.md` — 确认宪法内容符合预期
2. 审阅 `leaspec/config.yaml` — 确认配置正确
3. 运行 `/leaspec-new <描述>` 开始第一个变更

## 自我检查

- [ ] `leaspec/specs/` 已创建
- [ ] `leaspec/changes/` 已创建
- [ ] `leaspec/archive/` 已创建
- [ ] `leaspec/config.yaml` 已生成（含 git 粒度配置）
- [ ] `leaspec/constitution.md` 已生成（反映用户审计结果）
- [ ] `validate.sh` 通过
