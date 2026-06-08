#!/usr/bin/env bash
# leaspec validate — 校验 spec/change 结构完整性
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh" 2>/dev/null || true

TARGET="${1:-.}"

ERRORS=0
WARNINGS=0

check() {
  local desc="$1"
  local condition="$2"
  local severity="${3:-error}"

  if eval "$condition"; then
    green "  [✓] $desc"
  else
    if [ "$severity" = "error" ]; then
      red "  [✗] $desc"
      ERRORS=$((ERRORS + 1))
    else
      yellow "  [!] $desc"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
}

echo "==> leaspec validate: $TARGET"
echo ""

# 判断验证目标类型
if [ -f "$TARGET/constitution.md" ] && [ -d "$TARGET/specs" ] && [ -d "$TARGET/changes" ]; then
  # 整个 leaspec/ 目录
  echo "验证模式: 完整 leaspec 目录"
  LEASPEC_ROOT="$TARGET"
  echo ""

  echo "--- 目录结构 ---"
  check "specs/ 存在" "[ -d '$LEASPEC_ROOT/specs' ]"
  check "changes/ 存在" "[ -d '$LEASPEC_ROOT/changes' ]"
  check "archive/ 存在" "[ -d '$LEASPEC_ROOT/archive' ]"
  check "constitution.md 存在" "[ -f '$LEASPEC_ROOT/constitution.md' ]"
  check "config.yaml 存在" "[ -f '$LEASPEC_ROOT/config.yaml' ]"

  echo ""
  echo "--- 规范文件 ---"
  if [ -d "$LEASPEC_ROOT/specs" ]; then
    spec_count=$(find "$LEASPEC_ROOT/specs" -name "*.md" -type f | wc -l | tr -d ' ')
    if [ "$spec_count" -eq 0 ]; then
      yellow "  [!] specs/ 中尚无规范文件"
      WARNINGS=$((WARNINGS + 1))
    else
      for spec in "$LEASPEC_ROOT/specs"/*.md; do
        [ -f "$spec" ] || continue
        spec_name=$(basename "$spec")
        echo "  --- $spec_name ---"

        # 检查是否有 SHALL 或 MUST
        if grep -qi 'SHALL\|MUST' "$spec"; then
          green "    [✓] 包含 RFC 2119 关键词"
        else
          yellow "    [!] 缺少 SHALL/MUST 关键词"
          WARNINGS=$((WARNINGS + 1))
        fi

        # 检查是否有空的 section
        if grep -P '^##\s+\S+.*\n\n\s*##' "$spec" > /dev/null 2>&1; then
          yellow "    [!] 可能存在空的 section"
          WARNINGS=$((WARNINGS + 1))
        fi

        # 检查 FR 编号格式
        if grep -qP 'FR-\d{3}' "$spec"; then
          green "    [✓] FR 编号格式正确"
        fi
      done
    fi
  fi

  echo ""
  echo "--- 活跃变更 ---"
  if [ -d "$LEASPEC_ROOT/changes" ]; then
    change_count=$(find "$LEASPEC_ROOT/changes" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
    if [ "$change_count" -eq 0 ]; then
      yellow "  [!] changes/ 中无活跃变更"
      WARNINGS=$((WARNINGS + 1))
    else
      for change in "$LEASPEC_ROOT/changes"/*/; do
        [ -d "$change" ] || continue
        change_name=$(basename "$change")
        echo "  --- $change_name ---"

        check "proposal.md" "[ -f '$change/proposal.md' ]"
        check "spec.md" "[ -f '$change/spec.md' ]"

        if [ -f "$change/spec.md" ]; then
          if grep -qi 'SHALL\|MUST' "$change/spec.md"; then
            green "    [✓] spec.md 包含 RFC 2119 关键词"
          else
            yellow "    [!] spec.md 缺少 SHALL/MUST 关键词"
            WARNINGS=$((WARNINGS + 1))
          fi

          if grep -qiP 'ADDED|MODIFIED|REMOVED' "$change/spec.md"; then
            green "    [✓] spec.md 包含增量标记"
          fi
        fi

        if [ -f "$change/tasks.md" ]; then
          done_count=$(grep -cP '^\- \[x\]' "$change/tasks.md" 2>/dev/null || echo 0)
          total_count=$(grep -cP '^\- \[[ x]\]' "$change/tasks.md" 2>/dev/null || echo 0)
          echo "    任务进度: $done_count/$total_count"
        fi
      done
    fi
  fi

elif [ -f "$TARGET/proposal.md" ] || [ -f "$TARGET/spec.md" ]; then
  # 单个变更目录
  echo "验证模式: 单个变更"
  echo ""

  check "proposal.md 存在" "[ -f '$TARGET/proposal.md' ]"
  check "spec.md 存在" "[ -f '$TARGET/spec.md' ]"

  if [ -f "$TARGET/spec.md" ]; then
    check "spec.md 包含 SHALL/MUST" "grep -qi 'SHALL\|MUST' '$TARGET/spec.md'"
    check "spec.md 非空" "[ -s '$TARGET/spec.md' ]"
  fi

  if [ -f "$TARGET/tasks.md" ]; then
    check "tasks.md 存在" "[ -f '$TARGET/tasks.md' ]"
  fi

elif [ -f "$TARGET" ]; then
  # 单个文件
  echo "验证模式: 单个文件"
  echo ""

  if echo "$TARGET" | grep -q "spec"; then
    check "包含 SHALL/MUST" "grep -qi 'SHALL\|MUST' '$TARGET'"
    check "非空" "[ -s '$TARGET' ]"
  fi

else
  red "无法识别验证目标: $TARGET"
  echo "用法: validate.sh <leaspec-dir|change-dir|file>"
  exit 1
fi

# 总结
echo ""
echo "============================================"
echo " 验证结果: $ERRORS 错误, $WARNINGS 警告"
echo "============================================"

if [ "$ERRORS" -gt 0 ]; then
  red "存在 $ERRORS 个错误，请修复后再继续。"
  exit 1
else
  green "全部检查通过。"
fi
