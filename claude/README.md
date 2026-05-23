# Claude Scripts

Scripts related to Claude AI usage monitoring and automation.

## 📄 Scripts

### `ccusage_log.sh`
Fetches Claude API usage data via OAuth and appends a JSON log line for ingestion by Loki/Grafana.

**Tracked metrics:**
- `blok_pct` — 5-hour usage block utilisation (%)
- `week_pct` — 7-day utilisation (%)
- `credits_pct` — Extra credits utilisation (%)
- `credits_used` — Credits spent this month (€)
- `credits_max` — Monthly credit limit (€)
- `blok_remaining_hours` — Estimated hours remaining in current block

**Dependencies:**
```bash
apt install jq curl
npm install -g ccusage
```

**Install:**
```bash
cp ccusage_log.sh /usr/local/sbin/ccusage_log
chmod +x /usr/local/sbin/ccusage_log
```

**Cron (every 5 minutes):**
```bash
*/5 * * * * /usr/local/sbin/ccusage_log
```

**Log location:** `/var/log/ccusage.log`

**Requires:** Claude Pro with Claude Code, logged in via `claude` CLI.
