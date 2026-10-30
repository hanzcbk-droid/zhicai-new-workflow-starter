# {项目中文名} · {english-name}

> 这是项目入口和目录，不是完整手册。细节在 docs/harness/，用到时再读。
> 用户当场的指令优先于本文件。跳过哪条规则，要在 progress.md 写明原因。

## 这是什么
{一句话目标}
交付物：{交付物}
类型：{一次性项目 / 定期重复的工作流 / 改到达标为止}

## 开工（每次对话开始，按顺序）
1. 确认当前位置是本文件夹。
2. 读 progress.md：最新的已验证状态、卡点、下一步。
3. 读 feature_list.json：有 awaiting_review 的任务，先提醒用户去审；然后选优先级最高的未完成任务。同一时间只能有一个 in_progress。
4. 读 session-handoff.md：结合更新时间核对交接与进度；需要决策背景时读 DECISIONS.md，有 docs/harness/workflow.md 时按需读。
5. 有 Git 的话，看一眼最近几次提交。
6. 跑启动检查：{bash init.sh / powershell -ExecutionPolicy Bypass -File .\init.ps1 / 按 docs/harness/startup-check.md 逐条检查}
7. 检查没通过就先修好，不在坏的起点上开始新任务。

## 硬约束（最多 15 条；新规则先记进 docs/harness/lessons.md）
- 一次只做一个任务，不顺手做别的。
- 做了不等于做完：检查真的跑过、证据写进 feature_list.json，才能改成 awaiting_review。
- 只有用户说"行"，才能从 awaiting_review 改成 passing。用户说"不行"时把原因写进 notes：没有其他 in_progress 任务则改回 in_progress；已有其他任务进行中时，先将被退回任务标为 blocked、说明等待返工并保留现有任务进度。用户要求立即返工时，先把原进行中任务标为 blocked 并记录暂停与恢复信息，再将退回任务设为 in_progress。
- 不悄悄放宽合格标准。要改先问用户。
- 以文件为准，不以聊天记录为准。
- 核心功能没做对之前，不做美化和优化。
- 指出问题时，要同时说清哪里不对、怎么修、修完会是什么样。
- 同一条规则被跳过 3 次，就提出来和用户商量要不要改这条规则。
- {项目特有约束}（来源：{哪次出错或哪个决定}）

## 完成定义
目标实现 + 检查真的跑过 + 证据已记录 + 用户说"行" + 下一轮对话不用人工修就能直接开工。
具体检查项见 docs/harness/verification.md。

## 收尾（每次对话结束前；用户说"全局更新"时马上做）
按 docs/harness/closing.md 做：更新状态和进度、记录没解决的问题、整理产出、删临时文件、再跑一次启动检查。
用户说"全局更新"：不管对话结束没有，马上按收尾清单完整走一遍，并填写或更新 session-handoff.md，保证换任何 AI 助手进来都能接着干。做完按 closing.md 里的格式汇报。

## 文件地图

### 业务目录与成果位置
{业务目录与成果位置}

当前版本、验收状态、问题及下一步以任务清单、进度和交接的实际记录为准；放入成果目录不代表已经验收。

### 管理文件
| 文件 | 中文名 | 什么时候读 |
| --- | --- | --- |
| feature_list.json | 任务清单 | 开工、选任务、改状态时 |
| progress.md | 进度记录 | 开工、收尾时 |
| DECISIONS.md | 决策记录 | 做方案选择前 |
| session-handoff.md | 交接单 | 开工时；交接、收尾及全局更新时核对并更新 |
| changelog.md | 改版记录 | 改规则或交付物时（有的话） |
| docs/harness/verification.md | 验收标准 | 自检、评审时 |
| docs/harness/closing.md | 收尾清单 | 收尾时 |
| docs/harness/lessons.md | 经验与候选规则 | 出错后、想加规则时 |
| docs/harness/workflow.md | 步骤表 | 走多步流程时（有的话） |
| docs/harness/loop.md | 循环说明表 | 重复执行时（有的话） |
| deliverables/（默认；生成时替换为已确认的实际成果位置） | 产出入口 | 交付时；同一成果保持一个权威位置 |
