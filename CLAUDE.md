# leaspec — Lean Specification for AI-Assisted Development

融合 spec-kit 的 0→1 启动能力、open-spec 的规范管理与变更能力、superpowers 的 brainstorm 与执行能力。

## 核心原则

1. **规范即真相源** — specs/ 目录是系统行为的权威描述，代码是规范的实现
2. **按需触发** — 根据项目状态和需求类型，自动选择最合适的流程，不强制全流程
3. **增量优先** — 已有规范时走增量变更，避免重复描述
4. **设计先于编码** — 禁止未经设计直接写代码

## 场景判决逻辑

```
用户需求
  │
  ├─ 项目中没有 leaspec/ 目录？
  │   └─→ 触发 leaspec-init（创建目录结构 + constitution）
  │
  ├─ 需求是模糊想法/探索性讨论？
  │   └─→ 触发 leaspec-brainstorm（Socratic 澄清 → 设计方案草稿）
  │
  ├─ 需求明确，涉及新领域（leaspec/specs/ 中无对应规范）？
  │   └─→ 触发 leaspec-specify（0→1 生成完整规范）
  │
  ├─ 需求明确，是对已有规范的修改/扩展？
  │   └─→ 触发 leaspec-change（增量 proposal → spec diff）
  │
  ├─ 已有 spec + plan + tasks，需要实现？
  │   └─→ 触发 leaspec-execute（TDD 执行）
  │
  └─ 是简单 bug fix / 单文件小改动？
      └─→ 轻量执行模式（跳过正式流程）
```

## 源码仓库结构

```
myspecskills/
├── skills/                         # Agent 无关的核心 skills
│   ├── leaspec-new/SKILL.md        # 自动判决入口
│   ├── leaspec-init/SKILL.md       # 初始化 leaspec/ 目录
│   ├── leaspec-brainstorm/SKILL.md # 需求澄清与方案探索
│   ├── leaspec-specify/SKILL.md    # 0→1 新领域规范
│   ├── leaspec-change/SKILL.md     # 增量变更管理
│   ├── leaspec-plan/SKILL.md       # 技术方案 + 任务拆分
│   ├── leaspec-execute/SKILL.md    # TDD 实现执行
│   ├── leaspec-review/SKILL.md     # Spec + Code 审查
│   └── leaspec-archive/SKILL.md    # 归档已完成变更
├── templates/                      # Markdown 模板（agent 无关）
├── scripts/                        # 确定性 Shell 脚本
│   ├── helpers.sh                  # 公共函数库
│   ├── install.sh                  # 安装 leaspec 到目标项目
│   ├── init.sh                     # 初始化 leaspec/ 目录
│   ├── validate.sh                 # 校验 spec 结构完整性
│   └── status.sh                   # 查看项目规范状态
├── agents/                         # Agent 特定的 bootstrap
│   ├── claude/bootstrap.md         # Claude Code
│   └── codex/bootstrap.md          # Codex
├── CLAUDE.md                       # 本仓库开发用
└── AGENTS.md -> CLAUDE.md
```

## 目标项目结构

```
<项目根目录>/
├── leaspec/
│   ├── config.yaml              # 配置: git_track 等
│   ├── constitution.md          # 项目宪法
│   ├── specs/                   # 规范真相源
│   ├── changes/                 # 活跃变更
│   ├── archive/                 # 已归档
│   ├── templates/               # 规范模板（副本）
│   └── scripts/                 # 辅助脚本（副本）
├── .claude/skills/leaspec-*/    # Claude Code（由 install.sh 安装）
└── .agents/skills/leaspec-*/    # Codex（由 install.sh 安装）
```

## 安装到目标项目

```bash
# 在目标项目中运行
bash <path-to-myspecskills>/scripts/install.sh <project-root>
```

install.sh 自动:
1. 检测当前使用的 agent (claude / codex)
2. 复制 skills 到 agent 的 skills 目录
3. 追加 bootstrap 到 agent 的 context 文件
4. 复制 scripts + templates 到 leaspec/

## Slash Commands

**命名约定**: Skill 目录与 Slash Command 均为 `leaspec-*`（kebab-case），目录名与命令名相同。`leaspec-foo` ↔ `/leaspec-foo`。

| 命令 | 用途 | 对应 Skill |
|------|------|------------|
| `/leaspec-new <描述>` | 自动判决并启动流程（推荐入口） | `leaspec-new` |
| `/leaspec-init` | 初始化项目规范结构 | `leaspec-init` |
| `/leaspec-brainstorm <描述>` | 需求澄清与方案探索 | `leaspec-brainstorm` |
| `/leaspec-specify <描述>` | 0→1 生成新领域规范 | `leaspec-specify` |
| `/leaspec-change <描述>` | 增量修改已有规范 | `leaspec-change` |
| `/leaspec-plan` | 技术方案 + 任务拆分 | `leaspec-plan` |
| `/leaspec-execute` | TDD 实现执行 | `leaspec-execute` |
| `/leaspec-review` | 代码审查 | `leaspec-review` |
| `/leaspec-archive` | 归档变更 | `leaspec-archive` |

## Skills 依赖链

```
leaspec-new (入口 — 自动判决路由)
    │
    ├──→ leaspec-init ──→ leaspec-brainstorm ──→ leaspec-specify ──→ leaspec-plan ──→ leaspec-execute ──→ leaspec-review ──→ leaspec-archive
    │                     │                       │                                    │
    │                     └──→ leaspec-change  ──→┘                                    │
    │                                                                                  │
    └──→ (轻量模式：简单 bug fix / 小改动)                                               │
                                                                                       │
                                              leaspec-archive ←────────────────────────┘
                                                  │
                                                  └──→ leaspec-new (循环回到入口)
```
