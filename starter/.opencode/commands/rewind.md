---
description: Go back in time to an earlier checkpoint (nothing is ever lost)
---
The user is a beginner with no coding experience who wants to go back to an earlier checkpoint. Speak plainly, no git jargon. If they write in Swahili, answer in Swahili.

User input (may name a checkpoint, may be empty): $ARGUMENTS

Recent checkpoints (if the command shows an error, there are no checkpoints yet):
!`git log --oneline -10`

Do the following:

1. If there are no checkpoints yet, explain there's nothing to rewind to and stop.
2. Show the recent checkpoints as a simple numbered list in plain language (checkpoint number + summary + roughly when). Ask which one they want to go back to, unless $ARGUMENTS already makes it clear. Wait for the answer.
3. Confirm once: "This will make your app exactly like it was at checkpoint N. Your current work is saved first, so you can rewind the rewind. Continue?" Wait for a yes.
4. SAFETY FIRST — if there are any uncommitted changes, save them: `git add -A && git commit -m "Checkpoint <next N>: automatic save before rewinding"`.
5. Rewind WITHOUT rewriting history:
   - `git revert --no-commit <target-sha>..HEAD`
   - `git commit -m "Checkpoint <next N>: rewound to checkpoint <target N>"`
   - If the revert hits a conflict, run `git revert --abort` and use the fallback: `git checkout <target-sha> -- . && git add -A && git commit -m "Checkpoint <next N>: rewound to checkpoint <target N>"` (checkout won't delete files added after the target on its own — remove files not present in the target with `git diff --name-only <target-sha> HEAD -- .` before committing, but NEVER touch .opencode/, AGENTS.md, or .git/).
6. Push with `git push`.
7. Confirm: "⏪ Done — your app is back to how it was at checkpoint N. Nothing was deleted; if you change your mind, just /rewind again."

NEVER use `git reset --hard`, `git rebase`, or force pushes. History only moves forward.
