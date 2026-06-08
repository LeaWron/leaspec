# leaspec — Lean Specification for AI-Assisted Development

面向 AI Coding Agent 的通用规范驱动开发 skill 套件，整合了结构化规范生成、增量变更管理、需求澄清与 TDD 执行等能力。

## 核心能力

| 能力 | 说明 | 关键机制 |
|------|------|----------|
| **0→1 规范生成** | 为新领域生成完整的功能规范 | FR/SC 编号体系、宪法门禁、跨制品一致性分析 |
| **增量变更管理** | 对已有规范进行最小化修改 | 增量 spec (ADDED/MODIFIED/REMOVED)、变更归档 |
| **需求澄清** | 将模糊想法转化为清晰的设计方案 | Socratic 提问、HARD GATE 约束 |
| **TDD 执行** | 测试驱动的严格实现流程 | RED→GREEN→REFACTOR、红旗表、两阶段 Review |

## 安装

```bash
git clone https://github.com/LeaWron/leaspec.git
cd leaspec
./install.sh /path/to/your-project
```

首次安装会自动检测 AI agent 并部署 skills。若目标项目已安装过 leaspec，自动切换为更新模式。

### 更新

```bash
cd leaspec
./install.sh --update /path/to/your-project
```

更新时覆盖 skills、scripts、templates、bootstrap，但保护 config.yaml、constitution.md、specs/、changes/、archive/ 不动。

## 支持的 Agent

| Agent | Skills 目录 | Context 文件 |
|-------|------------|-------------|
| Claude Code | `.claude/skills/leaspec-*/` | `CLAUDE.md` |
| Codex | `.agents/skills/leaspec-*/` | `AGENTS.md` |

## 使用方式

```
/leaspec-new <描述>          # 推荐入口 — 自动判决路由到正确流程
/leaspec-init                # 初始化项目规范结构
/leaspec-brainstorm <描述>   # 需求澄清与方案探索
/leaspec-specify <描述>      # 0→1 新领域规范
/leaspec-change <描述>       # 增量变更
/leaspec-plan                # 技术方案 + 任务拆分
/leaspec-execute             # TDD 实现
/leaspec-review              # 代码审查
/leaspec-archive             # 归档变更
```

## 工作流

```
leaspec-new (入口)
    │
    ├──→ init ──→ brainstorm ──→ specify ──→ plan ──→ execute ──→ review ──→ archive
    │                │            │                    │             │
    │                └──→ change ──→ plan ──→ execute ──→ review ──→ archive
    │                                                                  │
    └──→ (轻量模式：简单 bug fix)                                         │
                                                                       │
                   ←←←←←←←←← 循环到下一个变更 ←←←←←←←←←←←←←←←←←←←←←←←┘
```

## 项目结构

### 源码仓库

```
leaspec/
├── skills/          # Agent 无关的核心 skill 定义 (9 个)
├── templates/       # Markdown 规范模板 (7 个)
├── scripts/         # 确定性 Shell 脚本 (5 个)
├── agents/          # Agent bootstrap (claude + codex)
├── install.sh → scripts/install.sh   # 安装入口
├── CLAUDE.md        # 本仓库开发入口
└── AGENTS.md
```

### 目标项目中

```
your-project/
├── leaspec/
│   ├── config.yaml          # git_track 等配置
│   ├── constitution.md      # 项目宪法
│   ├── specs/               # 规范真相源
│   ├── changes/             # 活跃变更
│   └── archive/             # 已归档
├── .claude/skills/leaspec-*/ # Skills（install.sh 安装）
└── .agents/skills/leaspec-*/ # Skills（install.sh 安装）
```

## 依赖链

每个 skill 定义了 `requires` 和 `terminates` 约束，形成有向执行图：

```
new → init → brainstorm → specify ──→ plan → execute → review → archive
                ↓          ↓
                └──→ change ────→ plan
```

## 鸣谢

leaspec 的设计受到以下项目的启发：

- [spec-kit](https://github.com/github/spec-kit) — GitHub 的结构化规范驱动开发工具
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) — AI 友好的规范管理与变更追踪
- [superpowers](https://github.com/obra/superpowers) — AI Coding Agent 开发方法论
- [ADR](https://github.com/architecture-decision-record/architecture-decision-record) — 架构决策记录，轻量级技术决策文档化方法
- [PRD-driven-context-engineering](https://github.com/mattgierhart/PRD-driven-context-engineering) — PRD 驱动的上下文工程
- [Gherkin](https://cucumber.io/docs/gherkin/) — 行为驱动开发（BDD）结构化语言
- [Rust RFCs](https://github.com/rust-lang/rfcs) — Rust 的 RFC 流程，规范驱动开发的经典实践

## License

MIT
