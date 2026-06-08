#!/usr/bin/env bash
# leaspec init — 在目标项目中初始化 leaspec/ 目录结构
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh" 2>/dev/null || true

# Fallback color functions if helpers.sh not available
type yellow &>/dev/null || yellow() { echo -e "\033[33m$*\033[0m"; }
type green &>/dev/null  || green()  { echo -e "\033[32m$*\033[0m"; }
type red &>/dev/null   || red()    { echo -e "\033[31m$*\033[0m"; }

# ============================================================
# Default values
# ============================================================
CFG_VERSION="1.0"
CFG_NAME=""
CFG_DESC=""
CFG_TRACK_LEASPEC="true"
CFG_TRACK_AGENT_DIRS="false"
CFG_IGNORE_METHOD="gitignore"
CFG_CONSTITUTION_FILE=""
CFG_NON_INTERACTIVE="false"

# Default constitution principles (3 parallel arrays, indexed 0-4)
_DEFAULT_PRINCIPLE_TITLES=(
  "Spec-as-Truth"
  "Trigger-by-Need"
  "Incremental-First"
  "Design-Before-Code"
  "Simplicity"
  "Respect-Comments"
)
_DEFAULT_PRINCIPLE_DESCS=(
  "specs/ 目录是系统行为的权威描述（source of truth），代码是规范的实现。所有功能行为必须以规范文件为准。"
  "根据项目状态和需求类型，自动选择最合适的流程。不强制走全流程，允许灵活裁剪。"
  "已有规范时优先走增量变更（spec diff），避免重复生成完整规范。仅在全新领域时使用 0→1 流程。"
  "禁止未经设计直接编写代码。设计必须产出可审查的方案（spec、plan、设计文档）。"
  "选择最简单的方案。反对过度抽象和过早优化。Templates 和 scripts 保持最小化，skill 职责单一。"
  "不修改任何已有注释，除非修改了对应的代码段。注释是代码上下文的一部分，即使是 TODO 类注释也不得删除。"
)
_DEFAULT_PRINCIPLE_CHECKS=(
  "新功能是否有对应的规范文件？|代码变更是否与规范保持一致？|规范是否被正确地反映在审查中？"
  "流程选择是否符合当前需求类型？|是否跳过了不必要的能力步骤？|是否在需要时触发了正确的 skill？"
  "是否复用了已有规范而非重新生成？|增量变更（ADDED/MODIFIED/REMOVED）是否精确、最小化？|是否避免了不必要的全量规范重写？"
  "设计文档是否在代码之前完成？|设计是否通过了审查？|设计是否充分考虑了替代方案？"
  "当前方案是否是最简单的可行方案？|是否引入了不必要的抽象层？|是否有充分的理由增加复杂度？"
  "是否误删或修改了与代码变更无关的注释？|修改代码时是否同步更新了对应的注释？|新增代码是否包含了必要的注释？"
)

# ============================================================
# T001: _print_usage
# ============================================================
_print_usage() {
  cat <<USAGE
Usage: init.sh [OPTIONS] <project-root>

Options:
  --version VERSION              leaspec config version (default: "1.0")
  --name NAME                    Project name (default: basename of project-root)
  --description DESC             Project description (default: "")
  --track-leaspec true|false     Git-track leaspec/ directory (default: true)
  --track-agent-dirs true|false  Git-track .claude/ .agents/ etc. (default: false)
  --ignore-method METHOD         Ignore mechanism: gitignore (team) or exclude (local) (default: gitignore)
  --git-track true|false         [deprecated] Shortcut for --track-leaspec
  --constitution-file PATH       Pre-written constitution.md file
  --non-interactive              Skip all interactive prompts, use defaults
  --help                         Show this help message

Examples:
  init.sh /path/to/project
  init.sh --name "myapp" --track-leaspec false --ignore-method exclude /path/to/project
  init.sh --non-interactive /path/to/project
  init.sh --name "myapp" --constitution-file /tmp/constitution.md /path/to/project
USAGE
}

# ============================================================
# T002: _parse_args
# ============================================================
_parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --help)
        _print_usage
        exit 0
        ;;
      --version)
        CFG_VERSION="$2"
        CFG_VERSION_SET="true"
        shift 2
        ;;
      --name)
        CFG_NAME="$2"
        CFG_NAME_SET="true"
        shift 2
        ;;
      --description)
        CFG_DESC="$2"
        CFG_DESC_SET="true"
        shift 2
        ;;
      --track-leaspec)
        CFG_TRACK_LEASPEC="$2"
        CFG_TRACK_LEASPEC_SET="true"
        shift 2
        ;;
      --track-agent-dirs)
        CFG_TRACK_AGENT_DIRS="$2"
        CFG_TRACK_AGENT_DIRS_SET="true"
        shift 2
        ;;
      --ignore-method)
        CFG_IGNORE_METHOD="$2"
        CFG_IGNORE_METHOD_SET="true"
        shift 2
        ;;
      --git-track)
        CFG_TRACK_LEASPEC="$2"
        shift 2
        ;;
      --constitution-file)
        CFG_CONSTITUTION_FILE="$2"
        shift 2
        ;;
      --non-interactive)
        CFG_NON_INTERACTIVE="true"
        shift
        ;;
      -*)
        echo "Error: Unknown option: $1"
        _print_usage
        exit 1
        ;;
      *)
        PROJECT_ROOT="$1"
        shift
        ;;
    esac
  done

  PROJECT_ROOT="${PROJECT_ROOT:-.}"
  PROJECT_ROOT="$(cd "$PROJECT_ROOT" 2>/dev/null && pwd || echo "$PROJECT_ROOT")"

  # Default project name from directory
  if [ -z "$CFG_NAME" ]; then
    CFG_NAME="$(basename "$PROJECT_ROOT")"
  fi
}

# ============================================================
# T003: _validate_args
# ============================================================
_validate_args() {
  local errs=0

  if [ -z "${PROJECT_ROOT:-}" ]; then
    echo "Error: <project-root> is required"
    errs=$((errs + 1))
  fi

  # Validate --track-leaspec
  case "$CFG_TRACK_LEASPEC" in
    true|false) ;;
    *)
      echo "Error: --track-leaspec must be 'true' or 'false', got '$CFG_TRACK_LEASPEC'"
      errs=$((errs + 1))
      ;;
  esac

  # Validate --track-agent-dirs
  case "$CFG_TRACK_AGENT_DIRS" in
    true|false) ;;
    *)
      echo "Error: --track-agent-dirs must be 'true' or 'false', got '$CFG_TRACK_AGENT_DIRS'"
      errs=$((errs + 1))
      ;;
  esac

  # Validate --ignore-method
  case "$CFG_IGNORE_METHOD" in
    gitignore|exclude) ;;
    *)
      echo "Error: --ignore-method must be 'gitignore' or 'exclude', got '$CFG_IGNORE_METHOD'"
      errs=$((errs + 1))
      ;;
  esac

  # Validate --constitution-file
  if [ -n "$CFG_CONSTITUTION_FILE" ] && [ ! -f "$CFG_CONSTITUTION_FILE" ]; then
    echo "Error: --constitution-file '$CFG_CONSTITUTION_FILE' does not exist or is not readable"
    errs=$((errs + 1))
  fi

  # Default version
  if [ -z "$CFG_VERSION" ]; then
    CFG_VERSION="1.0"
  fi

  if [ $errs -gt 0 ]; then
    exit 1
  fi
}

# ============================================================
# T013-T016: TTY interaction functions
# ============================================================

# T013: Check if stdin is a terminal
_is_tty() {
  [ -t 0 ]
}

# T014: Prompt for text input with default value
_prompt() {
  local label="$1"
  local default="$2"
  local input

  printf "%s [%s]: " "$label" "$default"
  read -r input
  echo "${input:-$default}"
}

# T014: Prompt for yes/no with default
_prompt_yn() {
  local question="$1"
  local default="${2:-y}"

  local hint
  if [ "$default" = "y" ]; then
    hint="[Y/n]"
  else
    hint="[y/N]"
  fi

  while true; do
    printf "%s %s: " "$question" "$hint"
    read -r answer
    answer="${answer:-$default}"

    case "$(echo "$answer" | tr '[:upper:]' '[:lower:]')" in
      y|yes) echo "true"; return 0 ;;
      n|no)  echo "false"; return 0 ;;
      *)     echo "请输入 y/yes 或 n/no" >&2 ;;
    esac
  done
}

# T015: Collect config fields via TTY (only for fields not provided via CLI)
_collect_config_tty() {
  if ! _is_tty || [ "$CFG_NON_INTERACTIVE" = "true" ]; then
    return 0
  fi

  echo ""
  echo "--- config.yaml 配置 ---"

  # version
  if [ -z "${CFG_VERSION_SET:-}" ]; then
    CFG_VERSION="$(_prompt "配置版本" "${CFG_VERSION:-1.0}")"
  fi

  # project.name
  if [ -z "${CFG_NAME_SET:-}" ]; then
    CFG_NAME="$(_prompt "项目名称" "${CFG_NAME:-$(basename "$PROJECT_ROOT")}")"
  fi

  # project.description
  if [ -z "${CFG_DESC_SET:-}" ]; then
    CFG_DESC="$(_prompt "项目描述" "")"
  fi

  # track_leaspec
  if [ -z "${CFG_TRACK_LEASPEC_SET:-}" ]; then
    yellow "Git 追踪设置: track_leaspec — leaspec/ 目录是否被 git 追踪？"
    CFG_TRACK_LEASPEC="$(_prompt_yn "追踪 leaspec/？" "y")"
  fi

  # track_agent_dirs
  if [ -z "${CFG_TRACK_AGENT_DIRS_SET:-}" ]; then
    yellow "Git 追踪设置: track_agent_dirs — .claude/ .agents/ 是否被 git 追踪？"
    CFG_TRACK_AGENT_DIRS="$(_prompt_yn "追踪 agent 目录？" "n")"
  fi

  # ignore_method
  if [ -z "${CFG_IGNORE_METHOD_SET:-}" ]; then
    yellow "忽略机制: gitignore (团队共享) 或 exclude (仅本地)？"
    local method
    method="$(_prompt "ignore_method [gitignore/exclude]" "gitignore")"
    while [ "$method" != "gitignore" ] && [ "$method" != "exclude" ]; do
      echo "无效值，请输入 'gitignore' 或 'exclude'"
      method="$(_prompt "ignore_method [gitignore/exclude]" "gitignore")"
    done
    CFG_IGNORE_METHOD="$method"
  fi
}

# T016: Audit constitution via TTY
_audit_constitution_tty() {
  if ! _is_tty || [ "$CFG_NON_INTERACTIVE" = "true" ] || [ -n "$CFG_CONSTITUTION_FILE" ]; then
    return 0
  fi

  echo ""
  echo "--- 宪法审计 ---"
  echo ""

  # Metadata audit
  local constitution_version="1.0.0"
  local today
  today=$(date +%Y-%m-%d)
  constitution_version="$(_prompt "CONSTITUTION_VERSION" "$constitution_version")"
  local ratification_date
  ratification_date="$(_prompt "RATIFICATION_DATE" "$today")"

  # Principles audit
  local accepted_titles=()
  local accepted_descs=()
  local accepted_checks=()
  local total=${#_DEFAULT_PRINCIPLE_TITLES[@]}

  echo ""
  echo "--- Core Principles ($total 项) ---"
  for ((i=0; i<total; i++)); do
    echo ""
    echo "原则 $((i+1)): ${_DEFAULT_PRINCIPLE_TITLES[$i]}"
    echo "  ${_DEFAULT_PRINCIPLE_DESCS[$i]}"
    local keep
    keep=$(_prompt_yn "保留此原则？" "y")

    if [ "$keep" = "true" ]; then
      accepted_titles+=("${_DEFAULT_PRINCIPLE_TITLES[$i]}")
      accepted_descs+=("${_DEFAULT_PRINCIPLE_DESCS[$i]}")
      accepted_checks+=("${_DEFAULT_PRINCIPLE_CHECKS[$i]}")
    else
      local action
      action="$(_prompt "替换(r) 还是 删除(d)？" "d")"
      if [ "$action" = "r" ] || [ "$action" = "replace" ]; then
        local new_title new_desc new_checks
        new_title="$(_prompt "新原则标题" "")"
        new_desc="$(_prompt "新原则描述" "")"
        new_checks="$(_prompt "检查项 (逗号分隔)" "")"
        accepted_titles+=("$new_title")
        accepted_descs+=("$new_desc")
        accepted_checks+=("$(echo "$new_checks" | tr ',' '|')")
      fi
    fi
  done

  # Add new principles
  while true; do
    local add_more
    add_more=$(_prompt_yn "添加额外原则？" "n")
    if [ "$add_more" != "true" ]; then
      break
    fi
    local new_title new_desc new_checks
    new_title="$(_prompt "新原则标题" "")"
    new_desc="$(_prompt "新原则描述" "")"
    new_checks="$(_prompt "检查项 (逗号分隔)" "")"
    accepted_titles+=("$new_title")
    accepted_descs+=("$new_desc")
    accepted_checks+=("$(echo "$new_checks" | tr ',' '|')")
  done

  # Generate constitution temp file
  local tmpfile
  tmpfile="/tmp/leaspec-constitution-$(date +%s).md"
  _write_constitution "$tmpfile" "$constitution_version" "$ratification_date" "$today" \
    accepted_titles accepted_descs accepted_checks
  CFG_CONSTITUTION_FILE="$tmpfile"
}

# Write a constitution.md from principle arrays
_write_constitution() {
  local outfile="$1"
  local cversion="$2"
  local rdate="$3"
  local ldate="$4"
  local -n titles_ref="$5"
  local -n descs_ref="$6"
  local -n checks_ref="$7"

  {
    echo "# Project Constitution — ${CFG_NAME}"
    echo ""
    echo "> 项目宪法是最高级别的治理文件。所有规范、计划和实现都必须遵守宪法中的原则。"
    echo "> 如果某个技术决策需要违反宪法原则，必须在 plan.md 的 Complexity Tracking 中记录并说明理由。"
    echo ""
    echo "## Core Principles"
    echo ""

    local count=${#titles_ref[@]}
    for ((i=0; i<count; i++)); do
      local pnum=$((i + 1))
      echo "### Principle ${pnum}: ${titles_ref[$i]}"
      echo ""
      echo "**描述**: ${descs_ref[$i]}"
      echo ""
      echo "**检查项**:"
      # Split checks by |
      IFS='|' read -ra items <<< "${checks_ref[$i]}"
      for item in "${items[@]}"; do
        echo "- [ ] ${item}"
      done
      echo ""
      echo "---"
      echo ""
    done

    echo "## Governance"
    echo ""
    echo "- **修订流程**: 修改宪法需要创建专门的 change proposal，标注 \`CONSTITUTION_CHANGE\` 标签"
    echo "- **版本策略**: 每次修改递增 \`CONSTITUTION_VERSION\`"
    echo "- **合规审查**: 每个 plan.md 必须通过 Constitution Check gates"
    echo ""
    echo "---"
    echo ""
    echo "**CONSTITUTION_VERSION**: ${cversion}"
    echo "**RATIFICATION_DATE**: ${rdate}"
    echo "**LAST_AMENDED_DATE**: ${ldate}"
  } > "$outfile"
}

# ============================================================
# File generation (refactored into functions)
# ============================================================
_generate_config() {
  local leaspec_root="$1"
  cat > "$leaspec_root/config.yaml" <<YAML
# leaspec configuration
version: "${CFG_VERSION}"

# Git 追踪设置
git:
  track_leaspec: ${CFG_TRACK_LEASPEC}
  track_agent_dirs: ${CFG_TRACK_AGENT_DIRS}
  ignore_method: ${CFG_IGNORE_METHOD}

# 项目元信息
project:
  name: "${CFG_NAME}"
  description: "${CFG_DESC}"
YAML
}

_generate_constitution() {
  local leaspec_root="$1"

  if [ -n "$CFG_CONSTITUTION_FILE" ] && [ -f "$CFG_CONSTITUTION_FILE" ]; then
    cat "$CFG_CONSTITUTION_FILE" > "$leaspec_root/constitution.md"
  else
    # Fallback: use template with sed substitution
    local templates_src="${TEMPLATES_SRC:-$SCRIPT_DIR/../templates}"
    if [ -f "$templates_src/constitution.md" ]; then
      local today
      today=$(date +%Y-%m-%d)
      sed "s/{{PROJECT_NAME}}/${CFG_NAME}/g; s/{{DATE}}/${today}/g" \
        "$templates_src/constitution.md" > "$leaspec_root/constitution.md"
    fi
  fi
}

_handle_git_tracking() {
  local project_root="$1"

  # Determine ignore file path
  local ignore_file
  if [ "$CFG_IGNORE_METHOD" = "exclude" ]; then
    ignore_file="$project_root/.git/info/exclude"
  else
    ignore_file="$project_root/.gitignore"
  fi

  # Ensure parent dir exists (for .git/info/exclude)
  mkdir -p "$(dirname "$ignore_file")"

  # Track leaspec/
  if [ "$CFG_TRACK_LEASPEC" = "false" ]; then
    if ! grep -q "^leaspec/" "$ignore_file" 2>/dev/null; then
      echo "leaspec/" >> "$ignore_file"
      echo "  added leaspec/ to $ignore_file"
    fi
  fi

  # Track agent dirs (.claude/ .agents/)
  if [ "$CFG_TRACK_AGENT_DIRS" = "false" ]; then
    for agent_dir in ".claude/" ".agents/"; do
      if ! grep -q "^${agent_dir}" "$ignore_file" 2>/dev/null; then
        echo "${agent_dir}" >> "$ignore_file"
        echo "  added ${agent_dir} to $ignore_file"
      fi
    done
  fi
}

_print_next_steps() {
  local leaspec_root="$1"
  echo ""
  echo "============================================"
  echo " leaspec 初始化完成"
  echo "============================================"
  echo ""
  echo "--- 创建的文件 ---"
  find "$leaspec_root" -maxdepth 2 -not -path '*/templates/*' | sort | while read -r f; do
    if [ -d "$f" ]; then
      echo "  $f/"
    else
      echo "  $f"
    fi
  done
  echo ""
  echo "--- 配置摘要 ---"
  echo "  config version:  ${CFG_VERSION}"
  echo "  project.name:    ${CFG_NAME}"
  echo "  project.description: ${CFG_DESC:-"(空)"}"
  echo ""
  echo "--- Git 追踪 ---"
  echo "  track_leaspec:     ${CFG_TRACK_LEASPEC}"
  echo "  track_agent_dirs:  ${CFG_TRACK_AGENT_DIRS}"
  echo "  ignore_method:     ${CFG_IGNORE_METHOD}"
  echo ""
  echo "下一步:"
  echo "  1. 审阅 leaspec/constitution.md"
  echo "  2. 审阅 leaspec/config.yaml"
  echo "  3. 开始开发: /leaspec-new <需求描述>"
}

# ============================================================
# main
# ============================================================
main() {
  _parse_args "$@"
  _validate_args

  # Check for existing leaspec/
  local leaspec_root="$PROJECT_ROOT/leaspec"
  if [ -f "$leaspec_root/config.yaml" ]; then
    if _is_tty && [ "$CFG_NON_INTERACTIVE" != "true" ]; then
      local merge
      merge=$(_prompt_yn "leaspec/ 已存在，是否合并（跳过已有文件）？" "y")
      if [ "$merge" != "true" ]; then
        echo "已取消"
        exit 0
      fi
    elif [ "$CFG_NON_INTERACTIVE" = "true" ]; then
      echo "==> leaspec/ 已存在，跳过已有文件继续"
    fi
  fi

  # TTY interaction (skipped in Agent mode / non-interactive)
  _collect_config_tty
  _audit_constitution_tty

  local templates_src="${TEMPLATES_SRC:-$SCRIPT_DIR/../templates}"

  echo "==> 初始化 leaspec 到 $leaspec_root"

  # Create directory structure
  for subdir in specs changes archive templates scripts; do
    mkdir -p "$leaspec_root/$subdir"
    echo "  created: leaspec/$subdir/"
  done

  # Generate config.yaml
  if [ ! -f "$leaspec_root/config.yaml" ]; then
    _generate_config "$leaspec_root"
    echo "  created: leaspec/config.yaml"
  else
    echo "  skipped: leaspec/config.yaml (已存在)"
  fi

  # Generate constitution.md
  if [ ! -f "$leaspec_root/constitution.md" ]; then
    _generate_constitution "$leaspec_root"
    if [ -f "$leaspec_root/constitution.md" ]; then
      echo "  created: leaspec/constitution.md"
    else
      echo "  skipped: leaspec/constitution.md (模板不可用)"
    fi
  else
    echo "  skipped: leaspec/constitution.md (已存在)"
  fi

  # Handle git tracking / ignore
  _handle_git_tracking "$PROJECT_ROOT"

  # Validate
  echo ""
  echo "==> 验证结构完整性..."
  if [ -f "$leaspec_root/scripts/validate.sh" ]; then
    bash "$leaspec_root/scripts/validate.sh" "$leaspec_root" || echo "  [!] 验证发现警告，请检查上述输出"
  fi

  _print_next_steps "$leaspec_root"
}

# Only run main when executed directly, not when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
