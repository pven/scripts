#!/usr/bin/env python3
# creator: pven, supported by ChatGPT
# 06-SEP-2025
# version: v1.8
# Doel: jobs >= THRESH_GB pauzeren + category=big, mét duidelijke logging.
# Output (exact 7 regels): accept, name, pp, category, script, priority, group

import os, sys, time

THRESH_GB = int(os.environ.get("THRESH_GB", "80"))
GROUP_FALLBACK = "alt.binaries.misc"
LOG = "/config/scripts/prequeue_decisions.log"

# SAB roept: name, pp, category, script, priority, bytes, group
args = sys.argv[1:]
name    = args[0] if len(args) > 0 else ""
pp      = args[1] if len(args) > 1 else ""
cat_in  = args[2] if len(args) > 2 else ""
script  = args[3] if len(args) > 3 else ""
prio_in = args[4] if len(args) > 4 else ""
bytes_a = args[5] if len(args) > 5 else ""
group   = args[6] if len(args) > 6 else os.environ.get("SAB_GROUP", GROUP_FALLBACK)

# bytes: neem argv, anders env
b_raw = bytes_a or os.environ.get("SAB_BYTES", "0")
b = int("".join(ch for ch in b_raw if ch.isdigit())) if b_raw else 0
gb = b / (1024**3) if b else 0.0

over = b >= THRESH_GB * 1024**3
category = "big" if over else (cat_in or "")
priority = "-2" if over else (prio_in or "")
decision = "PAUSE+BIG" if over else "DOWNLOAD"

# Log alleen naar file (nooit stdout)
try:
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(f"{time.strftime('%F %T')} | {decision} | size={gb:.2f}GB (raw={b}) | thr={THRESH_GB}GB | name={name}\n")
except Exception:
    pass  # logging mag nooit de flow breken

# 7 regels exact
out = ["1", name, pp, category, script, priority, group or GROUP_FALLBACK]
sys.stdout.write("\n".join(out) + "\n")
sys.stdout.flush()
