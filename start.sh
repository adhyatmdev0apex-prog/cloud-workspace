#!/bin/sh

set -eu

# ============================================================
# CLOUD WORKSPACE
# ============================================================

REPO_URL="${REPO_URL:-https://github.com/adhyatmdev0apex-prog/cloud-workspace.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"

REPO_DIR="/home/coder/repo"
PROJECT_DIR="${REPO_DIR}/Project"

PORT="${PORT:-10000}"

CONFIG_DIR="/home/coder/.config/code-server"
CONFIG_FILE="${CONFIG_DIR}/config.yaml"

echo ""
echo "============================================================"
echo "                 CLOUD WORKSPACE"
echo "============================================================"
echo "Repository : ${REPO_URL}"
echo "Branch     : ${REPO_BRANCH}"
echo "Repo root  : ${REPO_DIR}"
echo "Workspace  : ${PROJECT_DIR}"
echo "PORT       : ${PORT}"
echo "============================================================"
echo ""

# ============================================================
# 1. Prepare directories
# ============================================================

mkdir -p "$REPO_DIR"
mkdir -p "$CONFIG_DIR"

# ============================================================
# 2. Clone repository
# ============================================================

if [ ! -d "${REPO_DIR}/.git" ]; then

    echo "[GIT] No repository found."
    echo "[GIT] Cloning..."

    # Keep the repo directory clean.
    find "$REPO_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} \;

    git clone \
        --branch "$REPO_BRANCH" \
        --single-branch \
        "$REPO_URL" \
        "$REPO_DIR"

    echo "[GIT] Clone complete."

else

    echo "[GIT] Existing repository detected."

    cd "$REPO_DIR"

    echo "[GIT] Fetching ${REPO_BRANCH}..."

    git fetch origin "$REPO_BRANCH" || true

    echo "[GIT] Keeping existing working tree."
    echo "[GIT] Local changes will NOT be destroyed."

fi

# ============================================================
# 3. Verify Project directory
# ============================================================

if [ ! -d "$PROJECT_DIR" ]; then

    echo ""
    echo "[PROJECT] ERROR:"
    echo "[PROJECT] The repository does not contain:"
    echo ""
    echo "          ${PROJECT_DIR}"
    echo ""
    echo "[PROJECT] Creating it so code-server can start."
    echo ""

    mkdir -p "$PROJECT_DIR"

    touch "${PROJECT_DIR}/.gitkeep"

fi

# ============================================================
# 4. Permissions
# ============================================================

chown -R coder:coder "$REPO_DIR" 2>/dev/null || true

# ============================================================
# 5. code-server configuration
# ============================================================

echo "[CODE-SERVER] Creating configuration..."

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" <<EOF
bind-addr: 0.0.0.0:${PORT}
auth: password
cert: false
disable-telemetry: true
disable-update-check: true
reconnection-grace-time: 10800
EOF

# Password comes ONLY from Render.
if [ -n "${PASSWORD:-}" ]; then

    SAFE_PASSWORD=$(printf '%s' "$PASSWORD" | \
        sed 's/\\/\\\\/g; s/"/\\"/g')

    cat >> "$CONFIG_FILE" <<EOF
password: "${SAFE_PASSWORD}"
EOF

fi

chmod 600 "$CONFIG_FILE"

# ============================================================
# 6. Diagnostics
# ============================================================

echo ""
echo "================ ENVIRONMENT ================="

echo "User:"
id

echo ""
echo "PORT:"
echo "$PORT"

echo ""
echo "CPU:"
nproc 2>/dev/null || true

echo ""
echo "Memory:"
free -h 2>/dev/null || true

echo ""
echo "Node:"
node --version 2>/dev/null || true

echo ""
echo "npm:"
npm --version 2>/dev/null || true

echo ""
echo "Python:"
python3 --version 2>/dev/null || true

echo ""
echo "Git:"
git --version 2>/dev/null || true

echo ""
echo "code-server:"
code-server --version 2>/dev/null || true

echo "================================================"

echo ""
echo "[GIT] Repository:"
ls -la "$REPO_DIR"

echo ""
echo "[PROJECT] Workspace:"
ls -la "$PROJECT_DIR"

echo ""

# ============================================================
# 7. Launch code-server
# ============================================================

echo "============================================================"
echo "[CODE-SERVER] STARTING"
echo "============================================================"
echo ""
echo "Bind address : 0.0.0.0:${PORT}"
echo "Workspace    : ${PROJECT_DIR}"
echo ""
echo "============================================================"
echo ""

exec /usr/bin/entrypoint.sh \
    --bind-addr "0.0.0.0:${PORT}" \
    --auth password \
    --disable-telemetry \
    --disable-update-check \
    --reconnection-grace-time 10800 \
    --log debug \
    "$PROJECT_DIR"
