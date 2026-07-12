---
description: Take your app online at a permanent URL (Day 4)
---
The user is a beginner with no coding experience who wants their app live on the internet at a permanent address. Speak plainly. If they write in Swahili, answer in Swahili.

User input (may be empty): $ARGUMENTS

Do the following:

1. First run a silent /checkpoint-style save if there are uncommitted changes (add, commit "Checkpoint N: save before publishing", push).
2. Deploy with Netlify CLI (preferred at this hackathon):
   - Check it's installed: `netlify --version`. If missing or not logged in, tell the user to raise their hand for an instructor — do not attempt logins yourself.
   - Static site: `netlify deploy --prod --dir .` (adjust `--dir` if there's a build output folder; run the build first if the project has one).
3. Show the permanent URL prominently and tell them to open it on their phone right now.
4. Add the URL to the top of README.md as "🌍 Live at: <url>", then save a checkpoint: `git add -A && git commit -m "Checkpoint N: app published at <url>" && git push`.
5. Explain in one sentence the difference between this permanent address and the temporary preview links they used before.

If anything in the deploy fails twice, stop and ask for an instructor rather than trying increasingly complicated fixes.
