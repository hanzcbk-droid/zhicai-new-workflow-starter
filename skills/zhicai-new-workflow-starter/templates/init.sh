#!/usr/bin/env bash
# 启动检查 · init.sh —— 只检查，不修改任何文件
# 运行：bash init.sh
set -u
cd "$(dirname "$0")" || exit 1
fail=0
incomplete=0
ok()  { echo "[OK]   $1"; }
bad() { echo "[FAIL] $1"; fail=1; }

# 1. 必备文件
for f in AGENTS.md feature_list.json progress.md session-handoff.md DECISIONS.md \
         docs/harness/verification.md docs/harness/closing.md docs/harness/lessons.md; do
  if [ -f "$f" ]; then ok "存在 $f"; else bad "缺少 $f"; fi
done
if [ -d deliverables ]; then ok "存在 deliverables/"; else bad "缺少 deliverables/"; fi

# 2. 任务清单：格式、状态、一次一件、有证据
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PY' || fail=1
import json, sys
try:
    d = json.load(open("feature_list.json", encoding="utf-8"))
except Exception as e:
    print("[FAIL] feature_list.json 不是合法 JSON:", e); sys.exit(1)
if not isinstance(d, dict) or not isinstance(d.get("features"), list):
    print("[FAIL] feature_list.json 必须是对象，features 必须是任务数组"); sys.exit(1)
fs = d["features"]
legal = {"not_started", "in_progress", "blocked", "awaiting_review", "passing", "cancelled"}
seen = set()
for index, f in enumerate(fs, 1):
    if not isinstance(f, dict):
        print(f"[FAIL] 第 {index} 项任务不是对象"); sys.exit(1)
    ident, title = f.get("id"), f.get("title")
    if not isinstance(ident, str) or not ident.strip():
        print(f"[FAIL] 第 {index} 项任务缺少编号"); sys.exit(1)
    if ident.strip() in seen:
        print("[FAIL] 任务编号重复:", ident); sys.exit(1)
    seen.add(ident.strip())
    if not isinstance(title, str) or not title.strip():
        print("[FAIL] 任务缺少名称:", ident); sys.exit(1)
    if not isinstance(f.get("status"), str) or f["status"] not in legal:
        print("[FAIL] 任务状态写错了:", ident); sys.exit(1)
    steps = f.get("verification")
    if not isinstance(steps, list) or not steps or any(not isinstance(x, str) or not x.strip() for x in steps):
        print("[FAIL] 任务缺少有效验收步骤:", ident); sys.exit(1)
    evidence = f.get("evidence", [])
    if not isinstance(evidence, list) or any(not isinstance(x, str) or not x.strip() for x in evidence):
        print("[FAIL] 证据必须是非空文字组成的数组:", ident); sys.exit(1)
    if f["status"] in ("awaiting_review", "passing") and not evidence:
        print("[FAIL] 没有证据却标了待审或完成:", ident); sys.exit(1)
wip = [f.get("id") for f in fs if f.get("status") == "in_progress"]
if len(wip) > 1:
    print("[FAIL] 同时有多个 in_progress:", wip); sys.exit(1)
review = [f.get("id") for f in fs if f.get("status") == "awaiting_review"]
print("[OK]   feature_list.json 结构与状态检查通过；正在做:", wip or "无", "；等用户审:", review or "无")
print("[INFO] 证据内容是否真实、充分需另行核对")
PY
else
  echo "[SKIP] 没有 python3，feature_list.json 未检查；需人工检查"
  incomplete=1
fi

# 3. 检查原模板的已知占位项；其他自定义占位项须人工检查
placeholders=(
  '{项目中文名}' '{english-name}' '{一句话目标}' '{交付物}'
  '{一次性项目 / 定期重复的工作流 / 改到达标为止}'
  '{bash init.sh / powershell -ExecutionPolicy Bypass -File .\init.ps1 / 按 docs/harness/startup-check.md 逐条检查}'
  '{项目特有约束}' '{哪次出错或哪个决定}'
  '{标准 1}' '{标准 2}' '{标准 3}'
  '{按项目类型写：命名、格式、存放位置、禁止出现的东西}'
)
for f in AGENTS.md docs/harness/verification.md; do
  [ -f "$f" ] || continue
  for placeholder in "${placeholders[@]}"; do
    if grep -Fq -- "$placeholder" "$f"; then
      bad "$f 里还有未填写的模板项: $placeholder"
    fi
  done
done
echo "[INFO] 其他自定义占位项需人工检查"

# 4. 项目专属检查（建项目时按项目类型追加，比如检查素材文件夹是否存在）
# PROJECT_CHECKS

if [ "$fail" -ne 0 ]; then
  echo "启动检查未通过：先修好再开始新任务"; exit 1
elif [ "$incomplete" -ne 0 ]; then
  echo "启动检查未完成：存在未检查项目，请先完成检查"; exit 2
else
  echo "启动检查通过（仅限上述已执行的结构与格式检查）"; exit 0
fi
