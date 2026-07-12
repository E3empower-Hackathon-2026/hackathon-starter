---
description: Where am I? — what's changed and is my work saved
---
The user is a beginner with no coding experience asking about the state of their project. Answer in plain language, no git jargon. If they write in Swahili, answer in Swahili.

Current state (errors below just mean there are no checkpoints yet):
!`git status -sb`
!`git log --oneline -5`
!`git log -1 --format=%cr`

Answer these three questions in a short, friendly summary (no commands, no code):

1. **What have you changed since your last checkpoint?** — one plain sentence based on the changed files ("You've been working on the menu page and added two photos"). If nothing changed, say everything is saved.
2. **When was your last checkpoint?** — e.g. "about 20 minutes ago: Added the booking form."
3. **Is your work backed up online?** — if the branch is ahead of origin or there is no origin, say some work is only on this laptop and suggest /checkpoint; otherwise confirm it's safely online.

Do not change anything. This command only reports.
