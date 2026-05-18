# outlook-cli-install

Public installer for [outlook-cli](https://github.com/rossmeyerza/outlook-draft-cli), a CLI for Outlook mail, calendar, tasks, contacts, and Teams browsing.

## Install

```bash
curl -fsSL https://outlook-cli.21436587.xyz | bash
```

## Prerequisites

- Python 3.12+
- [GitHub CLI](https://cli.github.com/) installed and authenticated (`gh auth login`)

The install script will:

1. Clone the private repo using your authenticated `gh` session.
2. Create a Python virtualenv and install all dependencies.
3. Install Playwright Chromium (used for headless Microsoft SSO auth).
4. Symlink `outlook-cli` to `~/.local/bin`.
5. Create `~/.local/lib/outlook-draft-cli/.env` from `.env.example` if not present.

## After install

1. Edit `~/.local/lib/outlook-draft-cli/.env` and set your `MS_EMAIL` and `MS_PASSWORD`.
2. Run `outlook-cli auth` to complete authentication.
3. Run `outlook-cli config check` to verify setup.

## Note

The installer script is hosted at [outlook-cli.21436587.xyz](https://outlook-cli.21436587.xyz). You can read the full script before running it.
