# Getting Started with Hermes Agent Charm

## Prerequisites

1. **Juju controller** (v3.1+) connected to a cloud (LXD, AWS, Azure, GCE, etc.)
2. **Ubuntu Noble 24.04** base (the charm targets this series)
3. **AI provider API key** (Anthropic, OpenAI, Google, OpenRouter, etc.) — or Ollama for local models

## Step 1: Deploy

```bash
# From CharmHub (when published)
juju deploy hermes --channel edge

# Or from local charm file
juju deploy ./hermes_amd64.charm
```

## Step 2: Configure AI Provider

Choose one:

```bash
# GitHub Copilot (easiest — uses your GitHub token)
juju config hermes \
  ai-provider="copilot" \
  ai-api-key="ghu_YOUR-GITHUB-TOKEN" \
  ai-model="claude-sonnet-4"

# Anthropic Claude
juju config hermes \
  ai-provider="anthropic" \
  ai-api-key="sk-ant-api03-YOUR-KEY" \
  ai-model="claude-sonnet-4"

# OpenAI
juju config hermes \
  ai-provider="openai" \
  ai-api-key="sk-YOUR-KEY" \
  ai-model="gpt-4"

# Local Ollama (no API key needed — install Ollama separately)
juju config hermes \
  ai-provider="ollama" \
  ai-model="llama3"
```

## Step 3: Verify Deployment

```bash
# Watch deployment progress
juju status hermes

# Expected: active | Running (provider/model)
```

## Step 4: Connect Messaging Platform

```bash
# Telegram (get token from @BotFather)
juju config hermes telegram-bot-token="123456789:ABCdefGHI..."

# Discord (from Developer Portal)
juju config hermes discord-bot-token="MTIz..."

# Slack
juju config hermes \
  slack-bot-token="xoxb-..." \
  slack-app-token="xapp-..."
```

After setting a token, the gateway automatically restarts and connects to the platform.

## Step 5: Pair with the Bot

By default, `dm-policy=pairing`. When you message the bot for the first time, it will give you a pairing code. Enter it to authenticate.

To allow all users without pairing:
```bash
juju config hermes gateway-allow-all-users=true
```

## Step 6: Access Dashboard (Optional)

```bash
juju run hermes/0 get-dashboard-url
```

The dashboard provides web-based config management. It binds to localhost — use SSH tunnel for remote access:

```bash
ssh -L 9119:<unit-ip>:9119 <juju-machine>
# Then open http://localhost:9119
```

## Common Operations

```bash
# Check status
juju run hermes/0 get-status format=json

# List configured models
juju run hermes/0 list-models format=text

# View pairing status
juju run hermes/0 pairing-list

# Backup data
juju run hermes/0 backup

# Change model
juju config hermes ai-model="claude-opus-4"

# Enable auto-update on charm upgrade
juju config hermes auto-update=true

# Manual mode (manage ~/.hermes/ yourself)
juju config hermes manual=true
```

## Multi-Model Setup

Configure up to 10 additional AI model slots for fallback or switching:

```bash
# Primary: Anthropic
juju config hermes \
  ai-provider="anthropic" \
  ai-api-key="sk-ant-..." \
  ai-model="claude-sonnet-4"

# Fallback: OpenAI (slot 0)
juju config hermes \
  ai0-provider="openai" \
  ai0-api-key="sk-..." \
  ai0-model="gpt-4"

# Fallback: Google (slot 1)
juju config hermes \
  ai1-provider="google" \
  ai1-api-key="..." \
  ai1-model="gemini-2.5-pro"
```

## Troubleshooting

```bash
# Check unit logs
juju debug-log --include unit-hermes-0

# SSH into the unit
juju ssh hermes/0

# Check gateway service
juju exec --unit hermes/0 'systemctl status hermes-gateway.service'

# View gateway logs
juju exec --unit hermes/0 'journalctl -u hermes-gateway.service --no-pager -n 50'

# Run Hermes doctor
juju exec --unit hermes/0 'sudo -u ubuntu /home/ubuntu/.local/share/hermes-venv/bin/hermes doctor'
```
