---
description: Save your work — creates a checkpoint you can always come back to
---
The user is a beginner with no coding experience. Save their work as a checkpoint. Speak plainly, never use git jargon — say "checkpoint" and "saved online". If they write in Swahili, answer in Swahili.

Optional label from the user: $ARGUMENTS

Current state (if the log command shows an error, there are simply no checkpoints yet):
!`git status --porcelain`
!`git log --oneline -5`

Do the following:

1. If there are no changes at all, tell the user everything is already saved (mention when the last checkpoint was) and stop.
2. Look at what actually changed (`git diff` / new files) and write a ONE-sentence plain-language summary of the work, e.g. "Added the booking form and a price list page." If the user provided a label in $ARGUMENTS, use their words.
3. Count existing checkpoints (`git rev-list --count HEAD`, treat errors as 0) and use N+1 as the new number.
4. Run: `git add -A && git commit -m "Checkpoint <N+1>: <summary>"`.
5. Back it up online with `git push -u origin main`. If the push fails because there's no online backup yet, tell them to run /setup or call an instructor — their work IS still safe on this computer.
6. Confirm in one line, e.g.: "✅ Checkpoint 5 saved: Added the booking form. Your work is backed up online."

Do not change any code during this command. Only save.
