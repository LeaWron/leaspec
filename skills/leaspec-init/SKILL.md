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

## 交互原则

**Agent 全程使用 `AskUserQuestion` 做选项式交互，禁止依赖 shell TTY prompt。**

- 每个 `AskUserQuestion` 问题都会自动附带 **"Other" 选项**，用户可随时选择 "Other" 并输入自定义内容，确保选项不会限制用户的表达
- `init.sh` 始终以 `--non-interactive` + 全部显式参数调用，shell 脚本的 TTY 交互仅保留给人类直接运行脚本的场景
- 人类直接运行 `init.sh` 时，每个编号选择也提供「✏️ 自定义输入...」选项

## 执行流程

### Step 1: 确认初始化位置

- 默认在当前项目根目录
- 使用 `ls` 检查 `leaspec/` 是否已存在
- 若已存在 → 向用户确认是否合并（跳过已有文件）
- 若用户拒绝 → 停止执行

### Step 2: Git 追踪配置（AskUserQuestion 选项式）

使用 `AskUserQuestion` 一次性收集 3 个 Git 追踪相关配置，让用户通过选项选择而非自由文本输入：

**问题 1: `track_leaspec` — leaspec/ 目录是否纳入 git 追踪？**

| 选项 | 标签 | 说明 |
|------|------|------|
| 追踪 (推荐) | 追踪 | leaspec/ 规范文件提交到 git 仓库，团队共享 |
| 不追踪 | 不追踪 | 个人使用 leaspec 但团队尚未采用 |

**问题 2: `track_agent_dirs` — agent 隐藏目录是否纳入 git 追踪？**

| 选项 | 标签 | 说明 |
|------|------|------|
| 不追踪 (推荐) | 不追踪 | .claude/ .agents/ 不追踪，每个开发者独立维护 |
| 追踪 | 追踪 | 团队统一 agent 配置时需要 |

**问题 3: `ignore_method` — 不追踪时使用哪种忽略机制？**

| 选项 | 标签 | 说明 |
|------|------|------|
| gitignore (推荐) | gitignore | 写入项目根 .gitignore，**团队共享**，会被提交到仓库 |
| exclude | exclude | 写入 .git/info/exclude，**仅本地生效**，不影响团队其他成员 |

> **注意**: `ignore_method` 仅在 `track_leaspec=false` 或 `track_agent_dirs=false` 时生效。如果两个都追踪，该配置无实际影响。

### Step 3: 项目元信息（对话收集）

通过简单对话收集以下文本字段：

1. **project.name** — 项目名称（默认：项目根目录名）
2. **project.description** — 项目描述（默认：空）
3. **version** — leaspec 配置版本（默认：`"1.0"`）

向用户展示：
"项目名默认是 `<根目录名>`，描述默认为空，版本默认为 `1.0`。你可以直接确认使用默认值，或告诉我需要修改的内容。"

### Step 4: 宪法审计（AskUserQuestion + 对话引导）

**段 1 — 元信息：**

通过对话询问用户是否需要修改宪法版本号（默认 `1.0.0`）和批准日期（默认当天日期）。大多数用户直接回车跳过。

**段 2 — Core Principles 审计：**

Agent 以表格一次性展示 6 项默认原则：

| # | 标题 | 描述 |
|---|------|------|
| 1 | Spec-as-Truth | `specs/` 目录是系统行为的权威描述，代码是规范的实现 |
| 2 | Trigger-by-Need | 根据项目状态和需求类型，自动选择最合适的流程 |
| 3 | Incremental-First | 已有规范时优先走增量变更，避免重复描述 |
| 4 | Design-Before-Code | 禁止未经设计直接编写代码 |
| 5 | Simplicity | 选择最简单的方案，反对过度抽象和过早优化 |
| 6 | Respect-Comments | 不修改任何已有注释，除非修改了对应的代码段 |

使用 `AskUserQuestion`（multiSelect）询问：

> "哪些原则需要**保留**？（未选中的将被移除或替换）"

选项（全部默认选中）：
- `1. Spec-as-Truth`
- `2. Trigger-by-Need`
- `3. Incremental-First`
- `4. Design-Before-Code`
- `5. Simplicity`
- `6. Respect-Comments`

**处理未选中的原则：** 对每个未选中的原则，通过对话询问用户：
- **删除** — 直接移除该项
- **替换** — 提供新的标题、描述、检查项

**处理新增原则：** 通过对话询问用户是否添加额外原则。若需要，收集新原则的标题、描述、检查项。可多次添加直到用户表示完成。

**段 3 — Governance 审计：**

展示当前 Governance 规则（修订流程、版本策略、合规审查），询问用户是否需要修改。通常用户直接使用默认值。

**生成宪法文件：** 审计完成后，Agent 必须：

1. 使用 `date +%Y-%m-%d` 获取当前日期填入 `LAST_AMENDED_DATE`
2. 将完整宪法内容写入临时文件：`bash -c 'mktemp /tmp/leaspec-constitution-XXXXXX.md'`
3. 确认文件写入成功后再继续

### Step 5: 运行初始化脚本

Agent 拼接 CLI 命令并通过 Bash 工具执行。**关键：始终携带 `--non-interactive` 标志 + 全部显式参数**，确保脚本不会回退到 TTY prompt：

```bash
bash <path-to-leaspec-src>/scripts/init.sh \
  --non-interactive \
  --version "<CFG_VERSION>" \
  --name "<CFG_NAME>" \
  --description "<CFG_DESC>" \
  --track-leaspec <CFG_TRACK_LEASPEC> \
  --track-agent-dirs <CFG_TRACK_AGENT_DIRS> \
  --ignore-method <CFG_IGNORE_METHOD> \
  --constitution-file "<临时宪法文件路径>" \
  <project-root>
```

**脚本行为（Agent 无需手动干预）：**
- 创建 `leaspec/{specs,changes,archive,templates,scripts}`
- 根据传入的参数生成 `leaspec/config.yaml`
- 从临时宪法文件复制 `leaspec/constitution.md`
- 根据 `track_leaspec` / `track_agent_dirs` / `ignore_method` 配置 `.gitignore` 或 `.git/info/exclude`

### Step 6: 验证与引导

初始化后运行验证脚本确认结构完整：

```bash
bash leaspec/scripts/validate.sh leaspec/
```

向用户报告验证结果，并提示下一步：
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
- [ ] 所有交互使用 `AskUserQuestion`，未依赖 shell TTY prompt
