#!/bin/bash
# common.sh — shared functions for hermes-charm hooks
# shellcheck disable=SC2034

set -euo pipefail

HERMES_USER="ubuntu"
HERMES_HOME="/home/${HERMES_USER}"
HERMES_DIR="${HERMES_HOME}/.hermes"
# Official installer layout: ~/.hermes/hermes-agent/ repo, venv inside it
HERMES_SCRIPT_SRC="${HERMES_DIR}/hermes-agent"
HERMES_SCRIPT_VENV="${HERMES_SCRIPT_SRC}/venv"
# Legacy pip/git venv path (kept for backward compat during migration)
HERMES_VENV="${HERMES_HOME}/.local/share/hermes-venv"
HERMES_BIN="${HERMES_HOME}/.local/bin/hermes"
SERVICE_NAME="hermes-gateway.service"
DASHBOARD_SERVICE_NAME="hermes-dashboard.service"

export PATH="${HERMES_SCRIPT_VENV}/bin:${HERMES_HOME}/.local/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:${PATH}"

log() {
    juju-log "$@"
}

status_set() {
    local status="$1"
    local message="$2"
    status-set "$status" "$message"
}

config_get() {
    config-get "$1"
}

action_get() {
    action-get "$1" 2>/dev/null || echo ""
}

action_set() {
    action-set "$@"
}

action_fail() {
    action-fail "$1"
}

run_as_hermes_user() {
    sudo -u "$HERMES_USER" -H bash -c "$*"
}

is_service_active() {
    systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null
}

restart_service() {
    if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
        systemctl restart "$SERVICE_NAME"
    fi
}

stop_service() {
    if is_service_active; then
        systemctl stop "$SERVICE_NAME"
    fi
}

start_service() {
    if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
        systemctl start "$SERVICE_NAME"
    fi
}

get_hermes_version() {
    if [ -x "$HERMES_BIN" ]; then
        run_as_hermes_user "$HERMES_BIN --version" 2>/dev/null || echo "unknown"
    elif run_as_hermes_user "command -v hermes" &>/dev/null; then
        run_as_hermes_user "hermes --version" 2>/dev/null || echo "unknown"
    else
        echo "not installed"
    fi
}

ensure_hermes_dir() {
    run_as_hermes_user "mkdir -p ${HERMES_DIR}"
}

install_homebrew() {
    local brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"

    if command -v brew &>/dev/null || [ -x "$brew_bin" ]; then
        log "Homebrew already installed"
    else
        log "Installing Homebrew (Linuxbrew)"
        apt-get update -qq
        apt-get install -y -qq build-essential procps curl file git sudo

        # Homebrew refuses to run its installer as root, but Juju hooks run as root.
        # Give the Hermes user temporary passwordless sudo so the official installer
        # can create /home/linuxbrew/.linuxbrew non-interactively, then remove it.
        local install_script
        local sudoers_file="/etc/sudoers.d/hermes-homebrew-install"
        install_script=$(mktemp)
        curl -fsSL -o "$install_script" https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
        chmod 0755 "$install_script"
        printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$HERMES_USER" > "$sudoers_file"
        chmod 0440 "$sudoers_file"
        if ! sudo -u "$HERMES_USER" -H env NONINTERACTIVE=1 CI=1 bash "$install_script"; then
            rm -f "$sudoers_file" "$install_script"
            return 1
        fi
        rm -f "$sudoers_file" "$install_script"
    fi

    if [ -x "$brew_bin" ]; then
        # Make brew available for interactive shells and for subsequent charm hook commands.
        cat > /usr/local/bin/brew <<'BREW_WRAPPER'
#!/bin/bash
if [ -z "${HOME:-}" ]; then
    export HOME=/home/ubuntu
fi
exec /home/linuxbrew/.linuxbrew/bin/brew "$@"
BREW_WRAPPER
        chmod 0755 /usr/local/bin/brew
        local brew_shellenv="eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
        if ! grep -qxF "$brew_shellenv" "${HERMES_HOME}/.profile"; then
            printf '%s\n' "$brew_shellenv" >> "${HERMES_HOME}/.profile"
            chown "${HERMES_USER}:${HERMES_USER}" "${HERMES_HOME}/.profile"
        fi
        eval "$(HOME="${HERMES_HOME}" "$brew_bin" shellenv)"
        log "Homebrew installed: $(HOME="${HERMES_HOME}" "$brew_bin" --version | head -n1)"
    elif command -v brew &>/dev/null; then
        log "Homebrew installed: $(HOME="${HERMES_HOME}" brew --version | head -n1)"
    else
        log "WARNING: Homebrew install did not produce a brew executable"
        return 1
    fi
}

install_extra_pkgs() {
    local pkgs_csv="$1"
    [ -z "$pkgs_csv" ] && return 0
    log "Installing extra packages: ${pkgs_csv}"
    IFS=, read -ra PKGS <<< "$pkgs_csv"
    for pkg in "${PKGS[@]}"; do
        pkg=$(echo "$pkg" | xargs)  # trim whitespace
        [ -z "$pkg" ] && continue
        case "$pkg" in
            homebrew|brew|linuxbrew)
                install_homebrew || log "WARNING: failed to install Homebrew"
                ;;
            chrome)
                if ! command -v google-chrome &>/dev/null; then
                    log "Installing Google Chrome"
                    wget -q -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
                    apt-get install -y -qq /tmp/chrome.deb || apt-get install -f -y -qq
                    rm -f /tmp/chrome.deb
                fi
                ;;
            chromium)
                if ! command -v chromium-browser &>/dev/null && ! command -v chromium &>/dev/null; then
                    log "Installing Chromium"
                    apt-get install -y -qq chromium-browser
                fi
                ;;
            firefox)
                if ! command -v firefox &>/dev/null; then
                    log "Installing Firefox"
                    apt-get install -y -qq firefox
                fi
                ;;
            tailscale)
                if ! command -v tailscale &>/dev/null; then
                    log "Installing Tailscale"
                    curl -fsSL https://tailscale.com/install.sh | sh
                fi
                ;;
            *)
                log "Trying apt-get for unknown package: ${pkg}"
                apt-get install -y -qq "$pkg" || log "WARNING: failed to install ${pkg}"
                ;;
        esac
    done
}
