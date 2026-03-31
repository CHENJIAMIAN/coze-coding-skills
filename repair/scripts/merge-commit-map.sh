#!/usr/bin/env bash
# merge-commit-map.sh
# Merges .git/filter-repo/commit-map into .git/coze-commit-map using chain rules.
# Entries where old == new (identity / no change) are never written.

set -euo pipefail

COZE_MAP=".git/coze-commit-map"
FILTER_MAP=".git/filter-repo/commit-map"

if [[ ! -f "$FILTER_MAP" ]]; then
  echo "Error: $FILTER_MAP not found. Run git filter-repo first." >&2
  exit 1
fi

# Case 1: coze-commit-map does not exist — initialise from the new map
if [[ ! -f "$COZE_MAP" ]]; then
  echo "No existing $COZE_MAP found. Initialising from $FILTER_MAP."
  python3 - "$FILTER_MAP" "$COZE_MAP" <<'PYTHON'
import sys
src, dst = sys.argv[1], sys.argv[2]
entries = []
with open(src) as f:
    for i, line in enumerate(f):
        line = line.strip()
        if not line or (i == 0 and line.startswith("old")):
            continue
        parts = line.split()
        if len(parts) == 2 and parts[0] != parts[1]:
            entries.append((parts[0], parts[1]))
with open(dst, "w") as f:
    f.write("old" + " " * 37 + "new\n")
    for old, new in entries:
        f.write(f"{old} {new}\n")
print(f"Done. {len(entries)} entries written.")
PYTHON
  exit 0
fi

# Case 2: coze-commit-map exists — merge using chain rule
echo "Merging $FILTER_MAP into $COZE_MAP..."

python3 - "$COZE_MAP" "$FILTER_MAP" <<'PYTHON'
import sys

coze_path = sys.argv[1]
filter_path = sys.argv[2]

def parse_map(path):
    """Parse a commit-map file, skipping the header and identity entries."""
    entries = []
    with open(path) as f:
        for i, line in enumerate(f):
            line = line.strip()
            if not line or (i == 0 and line.startswith("old")):
                continue
            parts = line.split()
            if len(parts) == 2 and parts[0] != parts[1]:
                entries.append((parts[0], parts[1]))
    return entries

coze_entries = parse_map(coze_path)   # existing map
new_entries  = parse_map(filter_path) # fresh filter-repo map

# Build lookup: old → new from the fresh map
new_map = {old: new for old, new in new_entries}

# Update existing entries via chain rule:
# if coze_entry.new appears as an old in new_map, follow the chain
updated = []
chained_olds = set()

for old, mid in coze_entries:
    if mid in new_map:
        updated.append((old, new_map[mid]))
        chained_olds.add(mid)
    else:
        updated.append((old, mid))

# Append new_map entries not consumed by chaining
for old, new in new_entries:
    if old not in chained_olds:
        updated.append((old, new))

# Drop identity entries (old == new) before writing
changed = [(old, new) for old, new in updated if old != new]

with open(coze_path, "w") as f:
    f.write("old" + " " * 37 + "new\n")
    for old, new in changed:
        f.write(f"{old} {new}\n")

skipped = len(updated) - len(changed)
print(f"Done. {len(changed)} entries written to {coze_path}" +
      (f" ({skipped} identity entries skipped)." if skipped else "."))
PYTHON