#!/usr/bin/env bash
set -uo pipefail

INTERVAL="${PING_INTERVAL_SECONDS:-18000}"
LOG_DIR="${HOME}/logs"
LOG_FILE="${LOG_DIR}/codex-ping.log"

mkdir -p "$LOG_DIR"

echo "[$(date -Is)] Scheduler started" \
    >> "$LOG_FILE"

while true; do
    sleep "$INTERVAL"

    echo "[$(date -Is)] Sending hello to Codex" \
        >> "$LOG_FILE"

    if timeout 300 codex exec \
        --skip-git-repo-check \
        "hello" >> "$LOG_FILE" 2>&1; then

        echo "[$(date -Is)] Success" \
            >> "$LOG_FILE"
    else
        status=$?

        echo "[$(date -Is)] Failed: exit $status" \
            >> "$LOG_FILE"
    fi
done
