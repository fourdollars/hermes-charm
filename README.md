# Hermes Agent Charm

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

# Get the gateway token and dashboard URL
juju run hermes/0 get-gateway-token format=url
```

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
juju config hermes \
  slack-bot-token="xoxb-..." \
  slack-app-token="xapp-..."
```

## Actions

### Get Gateway Token

```bash
juju run hermes/0 get-gateway-token
juju run hermes/0 get-gateway-token format=url
juju run hermes/0 get-gateway-token format=json
```

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

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `ai-provider` | string | | AI provider (anthropic, openai, google, etc.) |
| `ai-model` | string | | AI model name(s), comma-separated for fallback |
| `ai-api-key` | string | | Provider API key |
| `gateway-port` | int | 3000 | Gateway HTTP port |
| `install-method` | string | pip | Install method: pip or git |
| `telegram-bot-token` | string | | Telegram bot token |
| `discord-bot-token` | string | | Discord bot token |
| `dm-policy` | string | pairing | DM policy: pairing/open/closed |
| `manual` | boolean | false | Manual config mode |

See `juju config hermes` for the full list.

## Requirements

- Juju controller (version 3.1+)
- Ubuntu Noble 24.04
- API key for your chosen AI provider

## License

MIT
