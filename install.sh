#!/usr/bin/env bash
# outlook-cli installer
# Usage: curl -fsSL https://outlook-cli.21436587.xyz/install.sh | bash

set -euo pipefail

BLUE="\033[0;34m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

info()  { printf "${BLUE}[outlook-cli]${NC} %s\n" "$1"; }
ok()    { printf "${GREEN}[ok]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[warn]${NC} %s\n" "$1"; }
die()   { printf "${RED}[error]${NC} %s\n" "$1"; exit 1; }

info "Checking prerequisites..."

if ! command -v python3 >/dev/null 2>&1; then
  die "python3 is required. Install Python 3.12+ and try again."
fi

PY_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PY_MAJOR=$(echo "$PY_VERSION" | cut -d. -f1)
PY_MINOR=$(echo "$PY_VERSION" | cut -d. -f2)
if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 12 ]; }; then
  die "Python 3.12+ is required. Found Python ${PY_VERSION}."
fi
ok "Python ${PY_VERSION}"

if ! command -v git >/dev/null 2>&1; then
  die "git is required. Install git and try again."
fi
ok "git available"

INSTALL_DIR="${OUTLOOK_CLI_DIR:-${HOME}/.local/lib/outlook-draft-cli}"
BIN_DIR="${HOME}/.local/bin"

info "Install directory: ${INSTALL_DIR}"
mkdir -p "$BIN_DIR"
mkdir -p "$(dirname "$INSTALL_DIR")"

if [ -d "${INSTALL_DIR}/.git" ]; then
  info "Updating existing install..."
  git -C "$INSTALL_DIR" pull --ff-only
  ok "Updated"
else
  info "Cloning outlook-cli..."
  git clone https://github.com/rossmeyerza/outlook-draft-cli.git "$INSTALL_DIR"
  ok "Cloned"
fi

info "Setting up virtual environment..."
python3 -m venv "${INSTALL_DIR}/.venv"
"${INSTALL_DIR}/.venv/bin/pip" install --quiet --upgrade pip
"${INSTALL_DIR}/.venv/bin/pip" install --quiet -e "$INSTALL_DIR"
ok "Dependencies installed"

info "Installing Playwright Chromium (needed for authentication)..."
"${INSTALL_DIR}/.venv/bin/python" -m playwright install chromium
ok "Playwright Chromium installed"

ln -sf "${INSTALL_DIR}/.venv/bin/outlook-cli" "${BIN_DIR}/outlook-cli"
ok "Symlinked to ${BIN_DIR}/outlook-cli"

if [ ! -f "${INSTALL_DIR}/.env" ]; then
  cp "${INSTALL_DIR}/.env.example" "${INSTALL_DIR}/.env"
  warn ".env created from .env.example. Edit ${INSTALL_DIR}/.env and set your MS_EMAIL and MS_PASSWORD."
else
  ok ".env already exists, not overwritten"
fi

if ! echo ":${PATH}:" | grep -q ":${BIN_DIR}:"; then
  warn "${BIN_DIR} is not in your PATH."
  warn "Add the following to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
  warn "  export PATH=\"${BIN_DIR}:\$PATH\""
fi

printf "\n"
ok "outlook-cli installed successfully."
printf "\n"
printf "  Next steps:\n"
printf "  1. Edit %s/.env and set MS_EMAIL and MS_PASSWORD\n" "$INSTALL_DIR"
printf "  2. Run: outlook-cli auth\n"
printf "  3. Run: outlook-cli config check\n"
printf "\n"
