# 各智能体兼容说明

核对日期：2026-10-23。平台更新很快，标"待实测"的不要当成已经确认。

| 智能体 | 开新对话会不会自动读项目里的 AGENTS.md | 怎么处理 | 依据 |
| --- | --- | --- | --- |
| Codex | 会 | 直接用 | AGENTS.md 本来就是它用的格式 |
| Hermes | 会。一次只读一种说明文件，顺序是 .hermes.md → AGENTS.md → CLAUDE.md，读到第一个就停 | 项目里不要放 .hermes.md；对话中途改了 AGENTS.md，要开新对话才生效 | Hermes 官方文档 Context Files |
| WorkBuddy | 会，官方写明兼容 AGENTS.md、CODEBUDDY.md | 直接用 | WorkBuddy 官方文档「项目」页 |
| Claude Code | 只自动读 CLAUDE.md。新版本在没有 CLAUDE.md 时可能退而读 AGENTS.md，但受版本限制，不能指望 | 建一个 CLAUDE.md，第一行写 @AGENTS.md | 社区多方资料 |
| ZCode | 官方文档写了支持 AGENTS.md 和 SKILL.md | 直接用，建议实测一次 | ZCode 官方文档 |
| DeepSeek Harness | 没查到官方说明 | 待实测；读不到时靠兜底规则 | — |
| 豆包工作 | 没查到官方说明 | 待实测；读不到时靠兜底规则 | — |

## Claude Code 专门说明
- CLAUDE.md 里的 @AGENTS.md 是 Claude Code 的"引用"写法：读 CLAUDE.md 时，会把 AGENTS.md 的内容一起读进来。说明书只有一份，不会出现两份对不上。
- 要在项目文件夹里启动 Claude Code，它才会在开局读到这个 CLAUDE.md。
- 怎么确认读到了：在 Claude Code 里输入 /memory，看列表里有没有这个项目的 CLAUDE.md；或者直接问它"这个项目的开工步骤是什么"。
- 接管已有项目时，原来就有 CLAUDE.md 的，不覆盖，先问用户能不能在第一行加 @AGENTS.md。
- Windows 上不要用软链接代替 CLAUDE.md，用上面这个一行引用的写法。

## 兜底规则（所有平台都适用）
1. 本 Skill 被加载时：当前文件夹有 AGENTS.md，就先读它。
2. 用户常用的每个 AI 助手，全局设置里都加一句："项目总表在 {位置}；进入任何项目先读该项目根目录的 AGENTS.md"。
3. 实在读不到时，用户在新对话开头说一句"先读 AGENTS.md"。

## 实测方法（一个平台大约 2 分钟）
1. 在一个已经建好 AGENTS.md 的项目文件夹里，开一个全新对话。
2. 什么都不交代，直接问："这个项目是干什么的？开工要先做哪几步？"
3. 能准确答出来，就是会自动读；答不上来或瞎编，就是不会，得靠兜底规则。
4. 把结果更新到上面的表里，并注明测试日期和平台版本。
