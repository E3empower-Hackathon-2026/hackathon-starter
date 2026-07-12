/**
 * E3 Hackathon harness plugin.
 *
 * 1. Blocks shell commands that could destroy a beginner's work, pointing
 *    them at the safe slash command instead.
 * 2. Nudges toward /checkpoint when the session goes idle with a lot of
 *    unsaved edits.
 */

const BLOCKED = [
  {
    pattern: /git\s+(?:\S+\s+)*push\b[^|;&]*--force(?!-with-lease)/,
    reason: "Force pushing can erase checkpoints saved online. Use /checkpoint to save and /rewind to go back.",
  },
  {
    pattern: /git\s+reset\s+--hard/,
    reason: "This permanently deletes unsaved work. Use /rewind to go back to a checkpoint safely.",
  },
  {
    pattern: /git\s+(?:\S+\s+)*rebase\b/,
    reason: "Rebasing rewrites checkpoint history. Use /rewind instead.",
  },
  {
    pattern: /git\s+clean\b[^|;&]*-[a-zA-Z]*f/,
    reason: "This deletes files that were never checkpointed. Use /checkpoint first, then ask an instructor.",
  },
  {
    pattern: /rm\s+(?:-[a-zA-Z]+\s+)*-[a-zA-Z]*[rR][a-zA-Z]*\s|rm\s+-[a-zA-Z]*f[a-zA-Z]*r/,
    reason: "Recursive deletes are too risky here. Ask the agent to remove specific files instead.",
  },
  // Windows shells (PowerShell / cmd) — most participant machines run Windows.
  {
    pattern: /\bremove-item\b[^|;&]*-recurse|\b(?:rm|ri)\b[^|;&]*-recurse[^|;&]*-force/i,
    reason: "Recursive deletes are too risky here. Ask the agent to remove specific files instead.",
  },
  {
    pattern: /\b(?:rmdir|rd)\b[^|;&]*\/s/i,
    reason: "Recursive deletes are too risky here. Ask the agent to remove specific files instead.",
  },
  {
    pattern: /\bdel\b[^|;&]*\/(?:f|s|q)\b/i,
    reason: "Force-deleting files is too risky here. Ask the agent to remove specific files instead.",
  },
  {
    pattern: /\b(?:rm|del|rd|rmdir|remove-item|ri)\b[^|;&]*\.git\b/i,
    reason: "Deleting .git would erase every checkpoint of this project.",
  },
]

// Threshold of edited files before the idle nudge fires.
const NUDGE_AFTER_EDITS = 5

export const E3Harness = async ({ client }) => {
  let editsSinceCheckpoint = 0

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return
      const command = output.args?.command ?? ""
      for (const rule of BLOCKED) {
        if (rule.pattern.test(command)) {
          throw new Error(`Blocked for safety: ${rule.reason}`)
        }
      }
    },

    "tool.execute.after": async (input, output) => {
      if (input.tool !== "bash") return
      const command = output.args?.command ?? ""
      if (/git\s+(?:\S+\s+)*commit\b/.test(command)) {
        editsSinceCheckpoint = 0
      }
    },

    event: async ({ event }) => {
      if (event.type === "file.edited") {
        editsSinceCheckpoint++
      }
      if (event.type === "session.idle" && editsSinceCheckpoint >= NUDGE_AFTER_EDITS) {
        editsSinceCheckpoint = 0
        try {
          await client.tui.showToast({
            body: {
              message: "Lots of new work since your last save — run /checkpoint to keep it safe.",
              variant: "info",
            },
          })
        } catch {
          // Toast API not available in this opencode version; the AGENTS.md
          // instruction to suggest checkpoints still covers us.
        }
      }
    },
  }
}
