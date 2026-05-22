#!/bin/bash
# validate.sh — validate charm structure and syntax

set -euo pipefail

ERRORS=0
WARNINGS=0

info()  { echo "  ✓ $*"; }
warn()  { echo "  ⚠ $*"; WARNINGS=$((WARNINGS + 1)); }
fail()  { echo "  ✗ $*"; ERRORS=$((ERRORS + 1)); }

echo "=== Hermes Charm Validation ==="
echo

# ---- Required files ----
echo "Checking required files..."
for f in charmcraft.yaml metadata.yaml config.yaml actions.yaml README.md LICENSE; do
    if [ -f "$f" ]; then
        info "$f exists"
    else
        fail "$f missing"
    fi
done

# ---- Hooks ----
echo
echo "Checking hooks..."
REQUIRED_HOOKS="install config-changed start stop remove update-status upgrade-charm"
for hook in $REQUIRED_HOOKS; do
    if [ -f "hooks/$hook" ]; then
        if [ -x "hooks/$hook" ]; then
            info "hooks/$hook (executable)"
        else
            fail "hooks/$hook not executable"
        fi
        # Syntax check
        if bash -n "hooks/$hook" 2>/dev/null; then
            info "hooks/$hook syntax OK"
        else
            fail "hooks/$hook has syntax errors"
        fi
    else
        fail "hooks/$hook missing"
    fi
done

# common.sh
if [ -f "hooks/common.sh" ]; then
    if bash -n "hooks/common.sh" 2>/dev/null; then
        info "hooks/common.sh syntax OK"
    else
        fail "hooks/common.sh has syntax errors"
    fi
else
    fail "hooks/common.sh missing"
fi

# ---- Actions ----
echo
echo "Checking actions..."
if [ -d "actions" ]; then
    for action in actions/*; do
        [ -f "$action" ] || continue
        name=$(basename "$action")
        if [ -x "$action" ]; then
            info "actions/$name (executable)"
        else
            fail "actions/$name not executable"
        fi
        if bash -n "$action" 2>/dev/null; then
            info "actions/$name syntax OK"
        else
            fail "actions/$name has syntax errors"
        fi
    done
else
    warn "actions/ directory missing"
fi

# ---- YAML validation (basic) ----
echo
echo "Checking YAML structure..."
if command -v python3 &>/dev/null; then
    for yaml_file in charmcraft.yaml metadata.yaml config.yaml actions.yaml; do
        if [ -f "$yaml_file" ]; then
            if python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
                info "$yaml_file valid YAML"
            else
                fail "$yaml_file invalid YAML"
            fi
        fi
    done
else
    warn "python3 not available — skipping YAML validation"
fi

# ---- metadata.yaml checks ----
echo
echo "Checking metadata.yaml content..."
if command -v python3 &>/dev/null && [ -f "metadata.yaml" ]; then
    NAME=$(python3 -c "import yaml; print(yaml.safe_load(open('metadata.yaml')).get('name',''))" 2>/dev/null)
    if [ "$NAME" = "hermes" ]; then
        info "charm name is 'hermes'"
    else
        fail "charm name should be 'hermes', got '$NAME'"
    fi
fi

# ---- Summary ----
echo
echo "=== Summary ==="
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"

if [ $ERRORS -gt 0 ]; then
    echo
    echo "FAILED — fix errors before packing"
    exit 1
fi

if [ $WARNINGS -gt 0 ]; then
    echo "PASSED with warnings"
else
    echo "ALL CHECKS PASSED ✓"
fi
