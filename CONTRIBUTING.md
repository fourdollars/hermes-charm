# Contributing to Hermes Agent Charm

Thank you for considering contributing to the Hermes Agent Charm!

## Development Setup

```bash
# Clone the repository
git clone https://github.com/fourdollars/hermes-charm.git
cd hermes-charm

# Install charmcraft
sudo snap install charmcraft --classic

# Validate the charm structure
./validate.sh

# Pack the charm
charmcraft pack
```

## Testing

### Local Deploy (LXD)

```bash
# Ensure you have a Juju controller with LXD
juju bootstrap localhost test-controller

# Deploy from local charm
juju deploy ./hermes_amd64.charm --to lxd

# Configure
juju config hermes ai-provider=ollama ai-model=llama3

# Check status
juju status hermes

# View logs
juju debug-log --include unit-hermes-0
```

### Running Validation

```bash
./validate.sh
```

This checks:
- Required files exist
- All hooks are executable and have valid bash syntax
- All actions are executable and have valid bash syntax
- YAML files are valid
- metadata.yaml has correct charm name

## Project Structure

```
hermes-charm/
├── charmcraft.yaml       # Charm build config
├── metadata.yaml         # Charm metadata (name, description, relations)
├── config.yaml           # Juju config options
├── actions.yaml          # Juju actions definitions
├── hooks/                # Lifecycle hooks (bash)
│   ├── common.sh         # Shared functions
│   ├── install           # Install Hermes Agent + deps
│   ├── config-changed    # Generate config from Juju options
│   ├── start             # Start gateway service
│   ├── stop              # Stop gateway service
│   ├── remove            # Cleanup on removal
│   ├── update-status     # Report unit status
│   └── upgrade-charm     # Handle charm upgrades
├── actions/              # Action scripts
│   ├── get-status        # Show agent status
│   ├── get-dashboard-url # Start/get dashboard URL
│   ├── backup            # Backup agent data
│   ├── list-models       # List configured models
│   └── pairing-list      # Show pairing users
├── GETTING_STARTED.md    # User setup guide
├── FAQ.md                # Frequently asked questions
├── validate.sh           # Charm validation script
└── .github/workflows/    # CI/CD
    └── test.yaml         # Validate + pack on push/PR
```

## Hook Development

Hooks are bash scripts that source `hooks/common.sh` for shared functions:

- `config_get <option>` — read Juju config
- `status_set <status> <message>` — set unit status
- `log <message>` — write to Juju debug log
- `run_as_hermes_user <command>` — execute as the hermes user
- `is_service_active` — check if gateway service is running
- `restart_service` / `start_service` / `stop_service` — manage systemd

## Guidelines

1. **Test your changes** — deploy to a local LXD and verify hooks work
2. **Run validate.sh** — ensure no syntax errors before committing
3. **Keep hooks idempotent** — hooks may be called multiple times
4. **Use `|| true`** for non-critical commands that might fail
5. **Update config.yaml** when adding new Juju options
6. **Update actions.yaml** when adding new actions

## Commit Messages

Follow conventional commits:
- `feat:` — new feature
- `fix:` — bug fix
- `docs:` — documentation
- `chore:` — maintenance

## License

By contributing, you agree that your contributions will be licensed under MIT.
