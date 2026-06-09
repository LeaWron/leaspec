#!/usr/bin/env bash
# leaspec status — 查看项目规范和变更状态
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh" 2>/dev/null || true

LEASPEC_ROOT="${1:-$LEASPEC_DIR}"

echo "==> leaspec status"
echo ""

# 检查 leaspec 目录是否存在
if [ ! -d "$LEASPEC_ROOT" ]; then
  red "leaspec/ 目录不存在。请先运行 /leaspec-init。"
  exit 1
fi

# 配置信息
echo "--- 配置 ---"
if [ -f "$LEASPEC_ROOT/config.yaml" ]; then
  grep -E 'version|git_track|name' "$LEASPEC_ROOT/config.yaml" | sed 's/^/  /'
fi
echo ""

# 规范文件
echo "--- 规范文件 (specs/) ---"
if [ -d "$LEASPEC_ROOT/specs" ]; then
  spec_count=0
  for spec in "$LEASPEC_ROOT/specs"/*.md; do
    [ -f "$spec" ] || continue
    spec_count=$((spec_count + 1))
    spec_name=$(basename "$spec" .md)
    fr_count=$(grep -cE 'FR-[0-9]{3}' "$spec" 2>/dev/null || echo 0)
    last_updated=$(grep "Last Updated" "$spec" 2>/dev/null | head -1 | sed 's/.*: //' || echo "unknown")
    echo "  [$spec_name] $fr_count 需求 | 更新于 $last_updated"
  done
  if [ "$spec_count" -eq 0 ]; then
    echo "  (尚无规范文件)"
  fi
else
  yellow "  specs/ 目录不存在"
fi
echo ""

# 活跃变更
echo "--- 活跃变更 (changes/) ---"
if [ -d "$LEASPEC_ROOT/changes" ]; then
  change_count=0
  for change in "$LEASPEC_ROOT/changes"/*/; do
    [ -d "$change" ] || continue
    change_count=$((change_count + 1))
    change_name=$(basename "$change")

    # 检查各制品状态
    has_proposal=" "; [ -f "$change/proposal.md" ] && has_proposal="✓"
    has_spec=" ";     [ -f "$change/spec.md" ] && has_spec="✓"
    has_design=" ";   [ -f "$change/design.md" ] && has_design="✓"
    has_plan=" ";     [ -f "$change/plan.md" ] && has_plan="✓"
    has_tasks=" ";    [ -f "$change/tasks.md" ] && has_tasks="✓"

    # 任务进度
    if [ -f "$change/tasks.md" ]; then
      done_count=$(grep -cE '^- \[x\]' "$change/tasks.md" 2>/dev/null || echo 0)
      total_count=$(grep -cE '^- \[[ x]\]' "$change/tasks.md" 2>/dev/null || echo 0)
      task_progress="$done_count/$total_count"
    else
      task_progress="-"
    fi

    echo "  [$change_name]"
    echo "    proposal:$has_proposal spec:$has_spec design:$has_design plan:$has_plan tasks:$has_tasks"
    echo "    任务进度: $task_progress"
  done
  if [ "$change_count" -eq 0 ]; then
    echo "  (无活跃变更)"
  fi
else
  yellow "  changes/ 目录不存在"
fi
echo ""

# 归档统计
echo "--- 归档 (archive/) ---"
if [ -d "$LEASPEC_ROOT/archive" ]; then
  archive_count=$(find "$LEASPEC_ROOT/archive" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
  echo "  已归档变更: $archive_count"
else
  echo "  archive/ 目录不存在"
fi

echo ""
echo "============================================"
