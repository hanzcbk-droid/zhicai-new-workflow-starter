# 开工检查清单 · Startup Check

> 智能体不能运行命令时，用这份清单代替 init 脚本。每一条都要真的打开文件看，不能凭印象打勾。结果写进 progress.md。

- [ ] 这些文件都在：AGENTS.md、feature_list.json、progress.md、session-handoff.md、DECISIONS.md、docs/harness/verification.md、docs/harness/closing.md、docs/harness/lessons.md；deliverables/ 目录存在
- [ ] feature_list.json 为合法 JSON 对象，features 是任务数组；每项都是对象
- [ ] 每项有非空 id 和 title，id 不重复；verification 是含非空文字的检查步骤数组
- [ ] 每个任务的 status 都是这六个之一：not_started / in_progress / blocked / awaiting_review / passing / cancelled
- [ ] 最多只有一个 in_progress
- [ ] evidence 如有填写应为文字数组，每项不是空白；标了 awaiting_review 或 passing 的任务至少有一条证据。再人工判断证据是否说明了检查及结果
- [ ] 人工检查 AGENTS.md 和 verification.md 的模板占位项是否填完；正常代码、JSON 或公式里的大括号不是占位符
- [ ] progress.md、session-handoff.md 的当前状态和下一步与 feature_list.json 对得上；没有验证的如实标明
- [ ] 每项检查都记录通过、失败或未检查；有未检查项目时不能称全部通过
- [ ] {项目专属检查项}
