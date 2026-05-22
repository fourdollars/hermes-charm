#!/bin/bash
# common.sh — shared functions for hermes-charm hooks

set -euo pipefail

HERMES_USER="ubuntu"
HERMES_HOME="/home/${HERMES_USER}"
HERMES_DIR="${HERMES_HOME}/.hermes"
HERMES_VENV="${HERMES_HOME}/.local/share/hermes-venv"
HERMES_BIN="${HERMES_VENV}/bin/hermes"
SERVICE_NAME="hermes-gateway.service"

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
