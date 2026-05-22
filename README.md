# Hermes Agent Charm

[![Test](https://github.com/fourdollars/hermes-charm/actions/workflows/test.yaml/badge.svg)](https://github.com/fourdollars/hermes-charm/actions/workflows/test.yaml)
[![CharmHub](https://img.shields.io/badge/CharmHub-hermes-blue)](https://charmhub.io/hermes)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Deploy [Hermes Agent](https://github.com/NousResearch/hermes-agent), the self-improving AI agent by Nous Research, with a single command using Juju.

[CharmHub](https://charmhub.io/hermes) • [Hermes Docs](https://hermes-agent.nousresearch.com/docs/) • [Report Bug](https://github.com/fourdollars/hermes-charm/issues)

## Features

- 🧠 **Self-Improving**: Built-in learning loop — creates skills from experience
- 💬 **Multi-Platform**: 20+ messaging channels (Telegram, Discord, Slack, WhatsApp, Signal, LINE...)
- 🤖 **Multi-Provider**: Anthropic, OpenAI, Google, OpenRouter, GitHub Copilot, Ollama, and more
- ⚡ **Production-Ready**: Systemd service with automatic restarts
- 📅 **Scheduled Automations**: Built-in cron with natural language
- 🔒 **Self-Hosted**: Your data stays on your infrastructure

## Quick Start

```bash
# Deploy Hermes Agent
juju deploy hermes --channel edge

# Configure with your AI provider
juju config hermes \
  ai-provider="anthropic" \
  ai-api-key="sk-ant-xxx" \
  ai-model="claude-sonnet-4"

# Wait for deployment
juju status --watch 1s

# Check status
juju run hermes/0 get-status format=json
```

## Interactive Chat (TUI)

### Via SSH (recommended for interactive use)

```bash
# Modern TUI (full terminal UI with panels)
juju ssh hermes/leader -- sudo -u ubuntu /home/ubuntu/.local/share/hermes-venv/bin/hermes chat --tui

# Classic REPL (simple text chat)
juju ssh hermes/leader -- sudo -u ubuntu /home/ubuntu/.local/share/hermes-venv/bin/hermes chat

# Single query (non-interactive)
juju ssh hermes/leader -- sudo -u ubuntu /home/ubuntu/.local/share/hermes-venv/bin/hermes chat -q "What is the weather?"
```

### Via Web Dashboard

The dashboard (port 9119) includes an embedded Chat tab when `dashboard-enabled=true` (default).
Access it at `http://<unit-ip>:9119`.

### Tips
- Use `--model provider/model` to override the configured model for a session
- Use `--resume <session-id>` to continue a previous conversation
- Use `--continue` to resume the most recent session

## AI Provider Configuration

### Anthropic Claude (Recommended)

```bash
juju config hermes \
  ai-provider="anthropic" \
  ai-api-key="sk-ant-xxx" \
  ai-model="claude-sonnet-4"
```

### OpenAI

```bash
juju config hermes \
  ai-provider="openai" \
  ai-api-key="sk-xxx" \
  ai-model="gpt-4"
```

### Google Gemini

```bash
juju config hermes \
  ai-provider="google" \
  ai-api-key="YOUR-GEMINI-KEY" \
  ai-model="gemini-2.5-pro"
```

### GitHub Copilot

```bash
juju config hermes \
  ai-provider="github-copilot" \
  ai-api-key="ghp_xxx" \
  ai-model="claude-sonnet-4"
```

### Local Models (Ollama)

```bash
juju config hermes \
  ai-provider="ollama" \
  ai-model="llama3"
```

## Messaging Platforms

```bash
# Telegram
juju config hermes telegram-bot-token="123456:ABC..."

# Discord
juju config hermes discord-bot-token="MTIz..."

# Slack
juju config hermes hermes \
  slack-bot-token="xoxb-..." \
  slack-app-token="xapp-..."
```

```bash
# LINE
juju config hermes \
  line-channel-access-token="..." \
  line-channel-secret="..."
```

## Actions

### Get Status

```bash
# Human-readable status
juju run hermes/0 get-status

# Structured JSON
juju run hermes/0 get-status format=json
```

### Get Dashboard URL

Start the web-based management dashboard:

```bash
juju run hermes/0 get-dashboard-url
```

> **Note:** Dashboard binds to localhost by default for security.
> Use SSH tunnel for remote access:
> `ssh -L 9119:127.0.0.1:9119 <unit-ip>`

### Backup

```bash
juju run hermes/0 backup
juju run hermes/0 backup output-path=/home/ubuntu/backups
```

### List Models

```bash
juju run hermes/0 list-models
juju run hermes/0 list-models format=text
```

### Pairing List

Show pending and approved DM users:

```bash
juju run hermes/0 pairing-list
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `ai-provider` | string | | AI provider (anthropic, openai, google, etc.) |
| `ai-model` | string | | AI model name(s), comma-separated for fallback |
| `ai-api-key` | string | | Provider API key |
| `gateway-port` | int | 3000 | Gateway port (for future webhook use) |
| `install-method` | string | pip | Install method: pip or git |
| `version` | string | latest | Hermes version (PyPI version or git ref) |
| `auto-update` | boolean | false | Auto-update on upgrade-charm |
| `telegram-bot-token` | string | | Telegram bot token |
| `discord-bot-token` | string | | Discord bot token |
| `slack-bot-token` | string | | Slack bot token (xoxb-) |
| `slack-app-token` | string | | Slack app token (xapp-) |
| `dm-policy` | string | pairing | DM policy: pairing/open/closed |
| `manual` | boolean | false | Manual config mode (skip auto-generation) |
| `log-level` | string | info | Log level (debug/info/warn/error) |
| `install-pkgs` | string | | Extra packages: chrome, chromium, firefox, tailscale |

Multi-model support: up to 10 additional AI slots (`ai0` through `ai9`), each with `-provider`, `-model`, `-api-key`, `-base-url`.

See `juju config hermes` for the full list.

## Requirements

- Juju controller (version 3.1+)
- Ubuntu Noble 24.04
- API key for your chosen AI provider (except Ollama)

## Development

```bash
# Validate charm structure
./validate.sh

# Pack the charm
charmcraft pack

# Deploy locally for testing
juju deploy ./hermes_amd64.charm --to lxd
```

## License

MIT
