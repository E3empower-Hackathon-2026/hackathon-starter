---
description: Start a new project — sets up saving and online backup (run once)
---
The user is a business owner with NO coding experience, at the Arusha Agentic Coding Hackathon. Help them set up their project. Speak in plain, friendly language. NEVER use git jargon (no "commit", "push", "repository", "remote", "branch") — say "checkpoint", "save", and "online backup" instead. If they write in Swahili, answer in Swahili.

User input (may be empty): $ARGUMENTS

Do the following, in order:

1. If you don't already know them, ask for two things in one question: the project's name, and one sentence about what it does and who it's for. Wait for the answer.
2. Make a short lowercase folder-safe slug from the project name (e.g. "Mama Lishe Orders" → `mama-lishe-orders`).
3. If this folder is not already a git repository, run `git init -b main`.
4. Write `README.md` with this structure:
   - `# <Project Name>`
   - The one-sentence description
   - `## Team` (ask for team member first names if not given)
   - A final line: `Built at the Arusha Agentic Coding Hackathon 2026 with E3.`
5. Save the first checkpoint: `git add -A && git commit -m "Checkpoint 1: project created"`.
6. Publish it online: `gh repo create e3-tanzania/<slug> --private --source . --push`.
   <!-- TODO(instructors): replace e3-tanzania with the real org name -->
7. Confirm to the user in one short paragraph: the project is set up, their work will be saved online every time they run /checkpoint, and they can always go back in time with /rewind.

If step 6 fails (gh not logged in, no internet, name taken): do NOT try to fix authentication yourself. Tell the user: "Your project is saved on this computer. Please raise your hand and an instructor will connect the online backup." Then stop.
