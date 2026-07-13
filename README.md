# E3 Hackathon Harness

The skeleton repo for the Arusha Agentic Coding Hackathon — clone this onto every machine. It contains the machine setup scripts, the opencode slash commands, and the plugins that abstract version management away from participants with no coding experience.

## Quick start (instructor, per machine)

```
git clone https://github.com/e3-tanzania/e3-hackathon.git   # TODO(instructors): real org
cd e3-hackathon

# Windows:
powershell -ExecutionPolicy Bypass -File setup\setup-windows.ps1
powershell -ExecutionPolicy Bypass -File setup\new-project.ps1 -Name team-name

# macOS / Linux:
bash setup/setup-unix.sh
bash setup/new-project.sh team-name
```

Then do the three interactive logins the setup script prints (gh / opencode key / netlify), and the team opens opencode in their new folder (`~/Desktop/team-name` by default) and runs `/setup`.

## Layout

```
starter/                     Template every team project starts from
  .opencode/
    commands/                Slash commands (markdown prompts)
      setup.md               /setup      — create project, README, publish to E3 org
      checkpoint.md          /checkpoint — plain-language commit + push
      rewind.md              /rewind     — safe revert to an earlier checkpoint
      status.md              /status     — what changed, is it saved
      publish.md             /publish    — deploy to a permanent URL (Day 4)
      start.md               /start      — turn on the website, hand out the link
      refresh.md             /refresh    — restart a stuck website, re-show the link
      stop.md                /stop       — turn the website off
    plugins/
      e3-harness.js          Blocks destructive git/rm commands; idle nudge to checkpoint
      e3-webserver.js        In-process static server behind /start /refresh /stop —
                             no npx/ports for participants; serves no-cache; links for
                             this computer + phones on the same wifi (ports 3000-3019)
  AGENTS.md                  Tunes the agent for beginners: plain language, simple stack,
                             suggest checkpoints, Swahili-friendly
  index.html                 Welcome page so /start shows something before the first prompt
setup/
  setup-windows.ps1          Idempotent participant-machine setup (winget + npm);
                             re-running acts as a verification pass
  setup-unix.sh              Same flow for macOS (Homebrew) and Debian/Ubuntu (apt) —
                             instructor machines or the odd non-Windows student
  new-project.ps1            Stamp out a fresh team folder from starter/ (no git history;
  new-project.sh             the team's /setup initializes git and publishes to the org)
```

## Design decisions

- **Template repo, not global install**: commands and the plugin travel inside each team's project folder, so one repo to maintain and zero per-machine setup beyond opencode itself.
- **Names avoid opencode built-ins**: `/init` and `/undo` already exist in opencode, hence `/setup` and `/rewind`.
- **History only moves forward**: `/rewind` uses `git revert`, never `reset --hard` or force pushes — every rewind is itself a checkpoint, so nothing is ever lost. The plugin hard-blocks the destructive alternatives even if the agent tries them.
- **Vocabulary**: checkpoint / rewind / saved online. Jargon-free by construction — the commands and AGENTS.md both enforce it.

## Instructor setup

1. Create the E3 GitHub org, push this repo to it, and update the org name in `starter/.opencode/commands/setup.md` and the clone URL above (marked with `TODO(instructors)`).
2. Per machine: the Quick start above. Most participants are on **Windows**; opencode's docs recommend WSL there, but we target native install — our stack is simple enough, and WSL adds BIOS/virtualization/reboot variables you don't want on student-owned laptops the night before Day 1.
3. Per team: `new-project` + open opencode in the folder + `/setup`. The team folder deliberately starts with no git history — `/setup` creates the team's own repo and publishes it to the org.

## Testing checklist (before the event)

- [ ] `/setup` end-to-end against a throwaway org repo
- [ ] `/checkpoint` with changes, with no changes, and with no remote configured
- [ ] `/rewind` two checkpoints back, then rewind the rewind
- [ ] Plugin blocks: `git reset --hard`, `git push --force`, `rm -rf`, `git rebase`, and Windows variants (`Remove-Item -Recurse -Force`, `rmdir /s`, `del /f`)
- [ ] Full run-through **on an actual Windows laptop**: setup-windows.ps1 on a clean machine, then /setup → build → /checkpoint → /rewind (opencode's shell snippets and the plugin are written shell-agnostic, but verify on real hardware)
- [ ] Idle nudge appears after ~5 file edits (or degrades silently on older opencode)
- [ ] /start inside opencode returns working links; page loads on a phone over venue wifi (many guest networks block device-to-device traffic — test at the venue; if blocked, fall back to a tunnel for phone demos)
- [ ] Full role-play: 30 minutes as a non-technical user, Swahili prompts included
