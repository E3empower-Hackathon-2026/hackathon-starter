#!/usr/bin/env bash
#
# E3 Hackathon — macOS / Linux machine setup
#
# Bash counterpart of setup-windows.ps1. Installs everything a participant
# machine needs: Git, GitHub CLI, Node.js LTS, opencode, and Netlify CLI.
# Idempotent — safe to re-run; a second run acts as a verification pass.
#
# Usage:
#   bash setup-unix.sh
#   bash setup-unix.sh --git-name "Asha M" --git-email "asha@example.com"
#
# Supports macOS (Homebrew) and Debian/Ubuntu (apt). For anything else it
# tells you what to install manually.

set -euo pipefail

GIT_NAME=""
GIT_EMAIL=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --git-name)  GIT_NAME="$2";  shift 2 ;;
    --git-email) GIT_EMAIL="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

GREEN=$'\033[32m'; RED=$'\033[31m'; YELLOW=$'\033[33m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
ok()   { echo "${GREEN}[ok]${RESET} $*"; }
info() { echo "${YELLOW}[..]${RESET} $*"; }
fail() { echo "${RED}[!!]${RESET} $*"; }

have() { command -v "$1" >/dev/null 2>&1; }

echo ""
echo "${CYAN}=== E3 Hackathon setup ===${RESET}"

# --- 0. Detect package manager -----------------------------------------------
OS="$(uname -s)"
PKG=""
if [[ "$OS" == "Darwin" ]]; then
  if ! have brew; then
    fail "Homebrew is not installed. Install it from https://brew.sh, then re-run this script."
    exit 1
  fi
  PKG="brew"
elif have apt-get; then
  PKG="apt"
  info "Updating apt package index (needs sudo)..."
  sudo apt-get update -qq
else
  fail "Unsupported system (no Homebrew or apt). Install manually: git, gh, Node.js LTS — then re-run to finish."
  exit 1
fi

install_pkg() {
  local tool="$1" brew_pkg="$2" apt_pkg="$3" label="$4"
  if have "$tool"; then
    ok "$label already installed"
    return
  fi
  info "Installing $label..."
  if [[ "$PKG" == "brew" ]]; then
    brew install "$brew_pkg"
  else
    sudo apt-get install -y "$apt_pkg"
  fi
  if ! have "$tool"; then
    fail "$label installed but '$tool' is not on PATH — open a new terminal and re-run this script."
    exit 1
  fi
  ok "$label installed"
}

# --- 1. Base tools -------------------------------------------------------------
install_pkg git  git  git  "Git"

# gh: on apt, GitHub CLI needs its official repo added first
if have gh; then
  ok "GitHub CLI already installed"
elif [[ "$PKG" == "brew" ]]; then
  install_pkg gh gh gh "GitHub CLI"
else
  info "Installing GitHub CLI (adding GitHub's apt repo)..."
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y gh
  ok "GitHub CLI installed"
fi

# node: apt's default "nodejs" can be ancient — use NodeSource LTS there
if have node; then
  ok "Node.js already installed ($(node --version))"
elif [[ "$PKG" == "brew" ]]; then
  install_pkg node node nodejs "Node.js LTS"
else
  info "Installing Node.js LTS (NodeSource repo — apt's default is often too old)..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
  ok "Node.js LTS installed ($(node --version))"
fi

# --- 2. npm tools: opencode + netlify -------------------------------------------
if ! have npm; then
  fail "npm is not on PATH even though Node.js is installed — open a NEW terminal and re-run this script."
  exit 1
fi

# On Linux, global npm installs may need a user-writable prefix instead of sudo.
npm_global_install() {
  local pkg="$1"
  if npm install -g "$pkg" 2>/dev/null; then
    return
  fi
  info "npm -g needs a user prefix (no sudo for npm packages)..."
  npm config set prefix "$HOME/.npm-global"
  export PATH="$HOME/.npm-global/bin:$PATH"
  if ! grep -qs '.npm-global/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
  fi
  npm install -g "$pkg"
}

for entry in "opencode-ai:opencode:opencode" "netlify-cli:netlify:Netlify CLI"; do
  pkg="${entry%%:*}"; rest="${entry#*:}"; tool="${rest%%:*}"; label="${rest#*:}"
  if have "$tool"; then
    ok "$label already installed"
  else
    info "Installing $label (npm)..."
    npm_global_install "$pkg"
    ok "$label installed"
  fi
done

# --- 3. Git identity + defaults ---------------------------------------------------
[[ -z "$GIT_NAME"  ]] && GIT_NAME="$(git config --global user.name  || true)"
[[ -z "$GIT_NAME"  ]] && read -rp "Participant's name (shown on their checkpoints): " GIT_NAME
[[ -z "$GIT_EMAIL" ]] && GIT_EMAIL="$(git config --global user.email || true)"
[[ -z "$GIT_EMAIL" ]] && read -rp "Participant's email (same as their GitHub account): " GIT_EMAIL

git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
ok "Git identity: $GIT_NAME <$GIT_EMAIL>"

# --- 4. Verification summary --------------------------------------------------------
echo ""
echo "${CYAN}=== Verification ===${RESET}"
ALL_OK=true
for tool in git gh node npm opencode netlify; do
  if have "$tool"; then
    version="$("$tool" --version 2>&1 | head -n 1)"
    ok "$(printf '%-9s %s' "$tool" "$version")"
  else
    fail "$(printf '%-9s MISSING' "$tool")"
    ALL_OK=false
  fi
done

# --- 5. Manual steps (interactive logins — can't be scripted) -------------------------
echo ""
echo "${CYAN}=== Remaining manual steps (instructor, per machine) ===${RESET}"
echo "  1. gh auth login        (GitHub.com > HTTPS > login with browser, as the participant)"
echo "  2. opencode auth login  (paste the instructor-held API key for this team)"
echo "  3. netlify login        (team Netlify account — needed for Day 4 /publish)"
echo "  4. Create the team's project folder from the E3 starter template"
echo ""
if $ALL_OK; then
  echo "${GREEN}Machine ready (pending manual logins above).${RESET}"
else
  echo "${RED}Some tools are missing — fix the [!!] lines above and re-run.${RESET}"
  exit 1
fi
