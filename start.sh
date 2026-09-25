#!/bin/sh

set -eu

REPO_URL="${REPO_URL:-https://github.com/adhyatmdev0apex-prog/cloud-workspace.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"

REPO_DIR="/home/coder/repo"
PROJECT_DIR="${REPO_DIR}/Project"

PORT="${PORT:-10000}"

echo ""
echo "============================================================"
echo "                 CLOUD WORKSPACE"
echo "============================================================"
echo "Repository : ${REPO_URL}"
echo "Branch     : ${REPO_BRANCH}"
echo "Repo       : ${REPO_DIR}"
echo "Workspace  : ${PROJECT_DIR}"
echo "PORT       : ${PORT}"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# Clone repository
# ------------------------------------------------------------

mkdir -p "$REPO_DIR"

if [ ! -d "${REPO_DIR}/.git" ]; then

    echo "[GIT] Cloning repository..."

    rm -rf "${REPO_DIR:?}"/*

    git clone \
        --branch "$REPO_BRANCH" \
        --single-branch \
        "$REPO_URL" \
        "$REPO_DIR"

    echo "[GIT] Clone complete."

else

    echo "[GIT] Existing repository found."
fi

# ------------------------------------------------------------
# Project directory
# ------------------------------------------------------------

if [ ! -d "$PROJECT_DIR" ]; then
    echo "[PROJECT] Creating Project/"
    mkdir -p "$PROJECT_DIR"
fi

# ------------------------------------------------------------
# Diagnostics
# ------------------------------------------------------------

echo ""
echo "================ DIAGNOSTICS ================="

echo "PORT:"
echo "$PORT"

echo ""
echo "CPU:"
nproc 2>/dev/null || true

echo ""
echo "MEMORY:"
free -h 2>/dev/null || true

echo ""
echo "CODE-SERVER:"
code-server --version 2>/dev/null || true

echo ""
echo "NODE:"
node --version 2>/dev/null || true

echo ""
echo "PYTHON:"
python3 --version 2>/dev/null || true

echo ""
echo "GIT:"
git --version 2>/dev/null || true

echo ""
echo "REPO:"
ls -la "$REPO_DIR"

echo ""
echo "PROJECT:"
ls -la "$PROJECT_DIR"

echo ""
echo "================================================"

# ------------------------------------------------------------
# Launch code-server directly
# ------------------------------------------------------------

echo ""
echo "[CODE-SERVER] Starting..."
echo "[CODE-SERVER] Address: 0.0.0.0:${PORT}"
echo "[CODE-SERVER] Workspace: ${PROJECT_DIR}"
echo ""

ARGS="
--bind-addr
0.0.0.0:${PORT}
--disable-telemetry
--disable-update-check
--reconnection-grace-time
10800
--log
debug
"

if [ -n "${PASSWORD:-}" ]; then
    exec code-server \
        --bind-addr "0.0.0.0:${PORT}" \
        --auth password \
        --disable-telemetry \
        --disable-update-check \
        --reconnection-grace-time 10800 \
        --log debug \
        "$PROJECT_DIR"
else
    echo "[ERROR] PASSWORD is not configured."
    echo "[ERROR] Set PASSWORD in Render Environment Variables."
    exit 1
fi
