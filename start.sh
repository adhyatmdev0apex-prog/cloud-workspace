#!/bin/sh

set -eu

# ============================================================
# Cloud Workspace
# ============================================================

PROJECT="/home/coder/project"
CONFIG_DIR="/home/coder/.config/code-server"
CONFIG_FILE="${CONFIG_DIR}/config.yaml"

PORT="${PORT:-10000}"

REPO_URL="${REPO_URL:-https://github.com/adhyatmdev0apex-prog/cloud-workspace.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"

echo ""
echo "============================================================"
echo "        CLOUD WORKSPACE STARTUP"
echo "============================================================"
echo "PORT        : ${PORT}"
echo "PROJECT     : ${PROJECT}"
echo "REPOSITORY  : ${REPO_URL}"
echo "BRANCH      : ${REPO_BRANCH}"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# Directories
# ------------------------------------------------------------

mkdir -p "$PROJECT"
mkdir -p "$CONFIG_DIR"

# ------------------------------------------------------------
# Git configuration
# ------------------------------------------------------------

git config --global init.defaultBranch main
git config --global pull.rebase false

# ------------------------------------------------------------
# Clone repository if project is empty
# ------------------------------------------------------------

if [ ! -d "${PROJECT}/.git" ]; then

    echo "[GIT] Repository not found locally."
    echo "[GIT] Cloning ${REPO_URL}..."

    # Make sure the directory is empty.
    find "$PROJECT" -mindepth 1 -maxdepth 1 -exec rm -rf {} \;

    git clone \
        --branch "$REPO_BRANCH" \
        --single-branch \
        "$REPO_URL" \
        "$PROJECT"

    echo "[GIT] Clone complete."

else

    echo "[GIT] Existing repository detected."

    cd "$PROJECT"

    echo "[GIT] Fetching origin..."

    git fetch origin "$REPO_BRANCH"

    echo "[GIT] Repository already exists."
    echo "[GIT] Local work will NOT be automatically destroyed."

fi

# ------------------------------------------------------------
# Make sure project ownership is correct
# ------------------------------------------------------------

if command -v sudo >/dev/null 2>&1; then
    sudo chown -R coder:coder "$PROJECT" 2>/dev/null || true
fi

# ------------------------------------------------------------
# code-server configuration
# ------------------------------------------------------------

echo "[CODE-SERVER] Preparing configuration..."

mkdir -p "$CONFIG_DIR"

# PASSWORD must be supplied through Render Environment Variables.
#
# We deliberately do NOT place the password inside the Git repo.
#
# For simple passwords this creates valid YAML.
#
# If PASSWORD is not supplied, code-server will use its existing
# generated configuration/password behavior.
#

if [ -n "${PASSWORD:-}" ]; then

    # Escape backslashes and double quotes for YAML.
    SAFE_PASSWORD=$(printf '%s' "$PASSWORD" | \
        sed 's/\\/\\\\/g; s/"/\\"/g')

    cat > "$CONFIG_FILE" <<EOF
bind-addr: 0.0.0.0:${PORT}
auth: password
password: "${SAFE_PASSWORD}"
cert: false
disable-telemetry: true
disable-update-check: true
reconnection-grace-time: 10800
EOF

else

    cat > "$CONFIG_FILE" <<EOF
bind-addr: 0.0.0.0:${PORT}
auth: password
cert: false
disable-telemetry: true
disable-update-check: true
reconnection-grace-time: 10800
EOF

fi

chmod 600 "$CONFIG_FILE"

echo "[CODE-SERVER] Configuration ready."

# ------------------------------------------------------------
# Diagnostics
# ------------------------------------------------------------

echo ""
echo "---------------- SYSTEM ----------------"

echo "User:"
id

echo ""
echo "Node:"
node --version || true

echo ""
echo "npm:"
npm --version || true

echo ""
echo "Python:"
python3 --version || true

echo ""
echo "pip:"
python3 -m pip --version || true

echo ""
echo "Git:"
git --version || true

echo ""
echo "code-server:"
code-server --version || true

echo "-----------------------------------------"
echo ""

echo "[HEALTH] Project directory:"
ls -la "$PROJECT"

echo ""

# ------------------------------------------------------------
# Launch official code-server entrypoint
#
# The official image's entrypoint handles the container runtime
# and launches code-server.
#
# We explicitly override bind address/port and workspace.
# ------------------------------------------------------------

echo "[CODE-SERVER] Starting..."
echo "[CODE-SERVER] Listening on 0.0.0.0:${PORT}"
echo "[CODE-SERVER] Workspace: ${PROJECT}"
echo ""

exec /usr/bin/entrypoint.sh \
    --bind-addr "0.0.0.0:${PORT}" \
    --auth password \
    --disable-telemetry \
    --disable-update-check \
    --reconnection-grace-time 10800 \
    "$PROJECT"
