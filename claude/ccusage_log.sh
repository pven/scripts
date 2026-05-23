#!/usr/bin/env bash
# Creator:      pven, supported by Claude
# Date:         2026-05-23
# Version:      v1.0
# Description:  Fetches Claude API usage data and appends JSON log lines for Loki/Grafana
#
# Dependencies:
#   - jq       (apt install jq)
#   - curl     (apt install curl)
#   - ccusage  (npm install -g ccusage)
#
# Usage:
#   Copy to /usr/local/sbin/ccusage_log and add to cron:
#   */5 * * * * /usr/local/sbin/ccusage_log >> /dev/null 2>&1

# --- Configuration -----------------------------------------------------------
LOGFILE="/var/log/ccusage.log"
CREDENTIALS_FILE="${HOME}/.claude/.credentials.json"
ANTHROPIC_USAGE_URL="https://api.anthropic.com/api/oauth/usage"
# -----------------------------------------------------------------------------

log() { echo "[$(date '+%d-%b-%Y %H:%M:%S')] $*" >&2; }

TOKEN=$(jq -r '.claudeAiOauth.accessToken // empty' "$CREDENTIALS_FILE" 2>/dev/null)
if [[ -z "$TOKEN" ]]; then
    log "No credentials available, aborting"
    exit 1
fi

USAGE=$(curl -s \
    -H "Authorization: Bearer $TOKEN" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "$ANTHROPIC_USAGE_URL")

if ! echo "$USAGE" | jq -e '.five_hour' > /dev/null 2>&1; then
    log "Invalid API response"
    exit 1
fi

BLOK=$(echo "$USAGE"         | jq '(.five_hour.utilization   // 0) | round')
WEEK=$(echo "$USAGE"         | jq '(.seven_day.utilization   // 0) | round')
CREDITS_PCT=$(echo "$USAGE"  | jq '(.extra_usage.utilization // 0) * 100 | round / 100')
CREDITS_USED=$(echo "$USAGE" | jq '(.extra_usage.used_credits  // 0) / 100')
CREDITS_MAX=$(echo "$USAGE"  | jq '(.extra_usage.monthly_limit // 0) / 100')

REMAINING=$(ccusage blocks --json 2>/dev/null | jq '
    if (.blocks // []) | length > 0
       and (.blocks[-1].projection.remainingMinutes // null) != null
    then (.blocks[-1].projection.remainingMinutes / 60 * 10 | round / 10)
    else 0
    end' 2>/dev/null || echo 0)

printf '{"blok_pct":%s,"week_pct":%s,"credits_pct":%s,"credits_used":%s,"credits_max":%s,"blok_remaining_hours":%s}\n' \
    "$BLOK" "$WEEK" "$CREDITS_PCT" "$CREDITS_USED" "$CREDITS_MAX" "$REMAINING" \
    >> "$LOGFILE"

log "ccusage logged: block=${BLOK}% week=${WEEK}% credits=${CREDITS_PCT}%"
