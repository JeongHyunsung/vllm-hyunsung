#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

OUT="artifacts/overview_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT" logs
echo "[INFO] Output dir: $OUT"

# ---- cloc per top-level dir -------------------------------------------------
if command -v cloc >/dev/null 2>&1; then
  echo "[INFO] Running cloc (per top-level dir)..."
  # 전체 요약
  cloc . > "$OUT/cloc_total.txt" 2> "logs/cloc.err"

  # 디렉토리별
  for d in */; do
    if [ -d "$d" ] && [ "$d" != ".git/" ]; then
      cloc "$d" >> "$OUT/cloc_by_dir.txt" 2>> "logs/cloc.err"
    fi
  done
elif command -v tokei >/dev/null 2>&1; then
  echo "[INFO] cloc not found. Running tokei instead ..."
  tokei --output=cli > "$OUT/cloc_total.txt" 2> "logs/tokei.err"
else
  echo "[WARN] Neither cloc nor tokei found. Skipping code stats." | tee -a "logs/warn.log"
fi

# ---- level1_file_counts -----------------------------------------------------
echo "[INFO] Counting files in each top-level dir..."
for d in */; do
  if [ -d "$d" ] && [ "$d" != ".git/" ]; then
    cnt=$(find "$d" -type f | wc -l)
    printf "%6d  %s\n" "$cnt" "$d"
  fi
done | sort -nr > "$OUT/level1_file_counts.txt"

# ---- churn analysis ---------------------------------------------------------
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[INFO] Computing churn by top-level dir over last 90 days..."
  git log --since="90 days ago" --name-only --pretty= 2> "logs/git.err" \
    | grep -vE '(^$|\.md$|\.png$|\.jpg$|\.svg$)' \
    | awk -F/ 'NF>1{print $1}' \
    | sort \
    | uniq -c \
    | sort -nr \
    > "$OUT/churn_90d_by_top1.txt"
else
  echo "[WARN] Not a git repository. Skipping churn analysis." | tee -a "logs/warn.log"
fi

echo "[DONE] Artifacts written to: $OUT"
