# 启动检查 · init.ps1 —— 只检查，不修改任何文件
Set-Location -Path $PSScriptRoot
$fail = $false
function Ok($m)  { Write-Host "[OK]   $m" }
function Bad($m) { Write-Host "[FAIL] $m"; $script:fail = $true }

# 1. 必备文件
$required = @("AGENTS.md","feature_list.json","progress.md","session-handoff.md","DECISIONS.md",
              "docs/harness/verification.md","docs/harness/closing.md","docs/harness/lessons.md")
foreach ($f in $required) { if (Test-Path $f -PathType Leaf) { Ok "存在 $f" } else { Bad "缺少 $f" } }
if (Test-Path "deliverables" -PathType Container) { Ok "存在 deliverables/" } else { Bad "缺少 deliverables/" }

# 2. 任务清单：格式、状态、一次一件、有证据
try {
  $raw = Get-Content feature_list.json -Raw -Encoding UTF8 -ErrorAction Stop
  if (-not $raw.TrimStart().StartsWith('{')) { throw "任务清单根节点必须是对象" }
  $d = $raw | ConvertFrom-Json -ErrorAction Stop
  if ($null -eq $d -or $d -isnot [pscustomobject] -or $d.features -isnot [array]) {
    throw "features 必须是任务数组"
  }
  $legal = @("not_started","in_progress","blocked","awaiting_review","passing","cancelled")
  $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
  $index = 0
  foreach ($f in $d.features) {
    $index++
    if ($null -eq $f -or $f -isnot [pscustomobject]) { Bad "第 $index 项任务不是对象"; continue }
    if ($f.id -isnot [string] -or [string]::IsNullOrWhiteSpace($f.id)) {
      Bad "第 $index 项任务缺少编号"; continue
    }
    $id = $f.id.Trim()
    if (-not $seen.Add($id)) { Bad "任务编号重复: $id" }
    if ($f.title -isnot [string] -or [string]::IsNullOrWhiteSpace($f.title)) { Bad "任务缺少名称: $id" }
    if ($f.status -isnot [string] -or $legal -cnotcontains $f.status) { Bad "任务状态写错了: $id" }
    if ($f.verification -isnot [array] -or $f.verification.Count -eq 0) {
      Bad "任务缺少有效验收步骤: $id"
    } else {
      foreach ($step in $f.verification) {
        if ($step -isnot [string] -or [string]::IsNullOrWhiteSpace($step)) { Bad "任务验收步骤为空或不是文字: $id" }
      }
    }
    $evidence = @()
    if ($null -ne $f.PSObject.Properties['evidence']) {
      if ($f.evidence -isnot [array]) { Bad "证据必须是数组: $id" } else { $evidence = $f.evidence }
    }
    foreach ($entry in $evidence) {
      if ($entry -isnot [string] -or [string]::IsNullOrWhiteSpace($entry)) { Bad "证据为空或不是文字: $id" }
    }
    if (@("awaiting_review","passing") -ccontains $f.status -and $evidence.Count -eq 0) {
      Bad "没有证据却标了待审或完成: $id"
    }
  }
  $wip = @($d.features | Where-Object { $_.status -eq "in_progress" } | ForEach-Object { $_.id })
  if ($wip.Count -gt 1) { Bad "同时有多个 in_progress: $wip" }
  $review = @($d.features | Where-Object { $_.status -eq "awaiting_review" } | ForEach-Object { $_.id })
  if (-not $fail) { Ok "feature_list.json 结构与状态检查通过；正在做: $wip ；等用户审: $review" }
  Write-Host "[INFO] 证据内容是否真实、充分需另行核对"
} catch { Bad "feature_list.json 无法检查: $($_.Exception.Message)" }

# 3. 检查原模板的已知占位项；其他自定义占位项须人工检查
$placeholders = @(
  '{项目中文名}', '{english-name}', '{一句话目标}', '{交付物}',
  '{一次性项目 / 定期重复的工作流 / 改到达标为止}',
  '{bash init.sh / powershell -ExecutionPolicy Bypass -File .\init.ps1 / 按 docs/harness/startup-check.md 逐条检查}',
  '{项目特有约束}', '{哪次出错或哪个决定}', '{标准 1}', '{标准 2}', '{标准 3}',
  '{按项目类型写：命名、格式、存放位置、禁止出现的东西}'
)
foreach ($f in @("AGENTS.md","docs/harness/verification.md")) {
  if (Test-Path $f -PathType Leaf) {
    foreach ($placeholder in $placeholders) {
      if (Select-String -Path $f -Pattern $placeholder -SimpleMatch -Quiet) { Bad "$f 里还有未填写的模板项: $placeholder" }
    }
  }
}
Write-Host "[INFO] 其他自定义占位项需人工检查"

# 4. 项目专属检查（建项目时按项目类型追加）
# PROJECT_CHECKS

if ($fail) { Write-Host "启动检查没通过：先修好再开始新任务"; exit 1 } else { Write-Host "启动检查通过（仅限上述已执行的结构与格式检查）"; exit 0 }
