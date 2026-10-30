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

    if timeout 300 codex --search exec \
		--model gpt-5.1-codex-mini \
  		-c model_reasoning_effort='"low"' \
        --skip-git-repo-check \
        "Find the 3 most interesting developments in AI, cybersecurity, or software engineering published during the last 5 hours.

  Requirements:
  - Use live web sources, not training knowledge.
  - Provide the headline, a 2-sentence summary, and the source URL.
  - Include the publication timestamp in UTC.
  - Do not invent news if fewer than 3 verified stories are available.
  - If web access is unavailable, report that clearly.
  - Link the source

  Keep the response concise." >> "$LOG_FILE" 2>&1; then

        echo "[$(date -Is)] Success" \
            >> "$LOG_FILE"
    else
        status=$?

        echo "[$(date -Is)] Failed: exit $status" \
            >> "$LOG_FILE"
    fi
done
