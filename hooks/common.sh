#!/bin/bash
# common.sh — shared functions for hermes-charm hooks
# shellcheck disable=SC2034

set -euo pipefail

HERMES_USER="ubuntu"
HERMES_HOME="/home/${HERMES_USER}"
HERMES_DIR="${HERMES_HOME}/.hermes"
HERMES_VENV="${HERMES_HOME}/.local/share/hermes-venv"
HERMES_BIN="${HERMES_VENV}/bin/hermes"
SERVICE_NAME="hermes-gateway.service"
DASHBOARD_SERVICE_NAME="hermes-dashboard.service"

export PATH="${HERMES_VENV}/bin:${HERMES_HOME}/.local/bin:/usr/local/bin:${PATH}"

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
    else
        echo "not installed"
    fi
}

ensure_hermes_dir() {
    run_as_hermes_user "mkdir -p ${HERMES_DIR}"
}

install_extra_pkgs() {
    local pkgs_csv="$1"
    [ -z "$pkgs_csv" ] && return 0
    log "Installing extra packages: ${pkgs_csv}"
    IFS=, read -ra PKGS <<< "$pkgs_csv"
    for pkg in "${PKGS[@]}"; do
        pkg=$(echo "$pkg" | xargs)  # trim whitespace
        case "$pkg" in
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
