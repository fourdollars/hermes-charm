# FAQ — Hermes Agent Charm

## Installation & Setup

### Q: What's the minimum model requirement?

Hermes Agent requires a model with **at least 64K token context window**. Most modern models (Claude Sonnet/Opus, GPT-4, Gemini Pro) meet this. Smaller models like GPT-3.5-turbo (16K) won't work well.

### Q: Can I use a local model?

Yes! Configure Ollama:
```bash
# Install Ollama on the unit first (or on a reachable host)
juju config hermes ai-provider="ollama" ai-model="llama3"

# For remote Ollama
juju config hermes \
  ai-provider="openai" \
  ai-base-url="http://ollama-host:11434/v1" \
  ai-api-key="ollama" \
  ai-model="llama3"
```

### Q: What's the difference between `pip` and `git` install methods?

- **pip** (default): Installs stable releases from PyPI. Reliable, tested.
- **git**: Clones the source repo and tracks `main` branch. Gets latest features but may have bugs.

```bash
juju config hermes install-method="git"
```

## Messaging

### Q: How do I set up Telegram?

1. Talk to [@BotFather](https://t.me/BotFather) on Telegram
2. Create a new bot, get the token
3. `juju config hermes telegram-bot-token="YOUR_TOKEN"`
4. Message your bot — it will respond with a pairing code
5. Enter the code to pair

### Q: How do I allow all users without pairing?

```bash
juju config hermes gateway-allow-all-users=true
```

⚠️ Only use this in trusted environments. Without pairing, anyone who discovers your bot can interact with it.

### Q: Can I use multiple messaging platforms simultaneously?

Yes! Just configure multiple tokens:
```bash
juju config hermes \
  telegram-bot-token="..." \
  discord-bot-token="..." \
  slack-bot-token="..."
```

The gateway handles all platforms from a single process.

## Access & Security

### Q: How do I access the gateway remotely?

The Hermes gateway doesn't expose an HTTP port like OpenClaw. It connects outbound to messaging platforms. For the web dashboard:

```bash
# Start dashboard
juju run hermes/0 get-dashboard-url

# SSH tunnel for remote access
ssh -L 9119:<unit-ip>:9119 <juju-machine-ip>
```

### Q: What data does the charm store?

Everything in `~/.hermes/` on the unit:
- `config.yaml` — settings
- `.env` — API keys (chmod 600)
- `sessions/` — conversation history
- `memories/` — agent long-term memory
- `skills/` — learned skills
- `cron/` — scheduled jobs

### Q: How do I backup?

```bash
juju run hermes/0 backup output-path=/home/ubuntu/backups

# Copy off the machine
juju scp hermes/0:/tmp/hermes-backup-*.tar.gz ./
```

## Operations

### Q: How do I update Hermes Agent?

Option 1: Auto-update on charm upgrade
```bash
juju config hermes auto-update=true
juju refresh hermes  # triggers update
```

Option 2: Manual update inside the unit
```bash
juju ssh hermes/0
sudo -u ubuntu /home/ubuntu/.local/share/hermes-venv/bin/pip install --upgrade hermes-agent
sudo systemctl restart hermes-gateway.service
```

### Q: How do I check logs?

```bash
# Juju debug log
juju debug-log --include unit-hermes-0

# Gateway service journal
juju exec --unit hermes/0 'journalctl -u hermes-gateway.service -n 100 --no-pager'

# Hermes log files
juju exec --unit hermes/0 'cat /home/ubuntu/.hermes/logs/errors.log'
```

### Q: Can I manage the config manually?

Yes. Set manual mode to prevent the charm from overwriting your config:
```bash
juju config hermes manual=true
```

Then SSH in and edit `~/.hermes/config.yaml` and `~/.hermes/.env` directly.

### Q: How do I completely remove Hermes?

```bash
juju remove-application hermes
```

This stops the service and removes the unit. Data in `~/.hermes/` is preserved on the machine until the machine is destroyed.

## Differences from OpenClaw Charm

| Feature | OpenClaw Charm | Hermes Charm |
|---------|---------------|--------------|
| Runtime | Node.js | Python + Node.js |
| Config format | JSON | YAML + .env |
| Gateway | HTTP/WebSocket server (port 18789) | Background messaging bot (no HTTP port) |
| Auth | Gateway token | DM pairing codes |
| Dashboard | Control UI (built-in) | Separate process (port 9119) |
| Multi-unit | Peer relation cluster | Single unit (no cluster) |
| Package manager | npm/bun | pip/uv |
