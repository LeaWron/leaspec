<!-- leaspec bootstrap for Codex -->
<!-- 此文件由 leaspec install 自动追加到 AGENTS.md -->

---

<!-- LEASPEC-BOOTSTRAP-START -->
# leaspec — Lean Specification for AI-Assisted Development

你已安装了 leaspec skill 套件。以下是可用的 skills:

## 交互能力门禁

当 leaspec 流程需要用户选择、确认或多选输入时，必须先确认当前 Codex 模式是否提供可调用的交互工具。

- Codex Plan mode 可使用 `request_user_input` 进行结构化交互；Codex Default mode 通常没有该工具
- 如果当前工具列表中没有可用的结构化交互工具，且用户没有提前提供完整决策或明确授权使用默认值，不得把流程退化为 shell TTY prompt，也不得用默认值继续执行会产生文件写入、脚本运行或 git 提交的步骤
- 一旦检测到无法交互，立即停止在第一个副作用之前，向用户说明当前模式无法完成该 leaspec 交互步骤，并提示切换到 Codex Plan mode 或重新发起请求时一次性提供所需参数
- 停止提示必须包含当前卡住的问题、可选项摘要，以及继续所需的最小输入

| Skill | 用途 | 自动触发条件 |
|-------|------|-------------|
| `leaspec-new` | 自动判决并启动流程（推荐入口） | 任何新需求，自动路由到正确流程 |
| `leaspec-init` | 初始化项目规范目录 | 项目无 leaspec/ 目录且用户要规范驱动开发 |
| `leaspec-brainstorm` | 需求澄清与方案探索 | 需求模糊、探索性讨论、设计方案前 |
| `leaspec-specify` | 0→1 生成新领域规范 | 新功能、无现有 spec 覆盖的领域 |
| `leaspec-change` | 增量修改已有规范 | 修改/扩展已有规范的行为 |
| `leaspec-plan` | 技术方案 + 任务拆分 | spec 已就绪、需要实施方案 |
| `leaspec-execute` | TDD 实现执行 | plan + tasks 已就绪、需要编码实现 |
| `leaspec-review` | 代码审查 | 实现完成、归档前 |
| `leaspec-archive` | 归档已完成变更 | review 通过、需要合并规范 |

**Slash Commands:**

| 命令 | 对应 Skill |
|------|-----------|
| `/leaspec-new <描述>` | `leaspec-new` |
| `/leaspec-init` | `leaspec-init` |
| `/leaspec-brainstorm <描述>` | `leaspec-brainstorm` |
| `/leaspec-specify <描述>` | `leaspec-specify` |
| `/leaspec-change <描述>` | `leaspec-change` |
| `/leaspec-plan` | `leaspec-plan` |
| `/leaspec-execute` | `leaspec-execute` |
| `/leaspec-review` | `leaspec-review` |
| `/leaspec-archive` | `leaspec-archive` |

**项目结构 (leaspec/):**

```
leaspec/
├── config.yaml          # git_track 等配置
├── constitution.md      # 项目宪法
├── specs/               # 规范真相源
├── changes/             # 活跃变更
├── archive/             # 已归档
├── templates/           # 规范模板
└── scripts/             # 辅助脚本
```
<!-- LEASPEC-BOOTSTRAP-END -->
