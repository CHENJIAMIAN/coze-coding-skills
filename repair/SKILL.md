---
name: repair
description: 调查并修复开发环境问题。当用户遇到沙箱稳定性问题、磁盘空间不足、.gitignore 缺失或不完整、git 历史中混入大文件、.git 目录损坏或丢失、需要恢复历史版本等情况时，使用此 skill。
---
# 开发环境问题调查与修复

**重要规则**：任何可能影响用户文件内容或可用性的操作（删除/移动/覆盖/批量改写、清空目录、恢复备份、改写 git 历史、强推等）都不得擅自执行，必须先获得用户明确同意后再执行。

默认行为是只做调查与给出建议/待执行命令；若涉及上述高风险操作，必须先向用户说明将影响哪些路径、影响方式与不可逆风险，并等待用户用明确措辞确认（例如“同意执行 X 命令/确认删除 Y 文件”）后才能按照用户确认意愿执行对应文件操作。

---

## Background: Standard Directory Structure by Project Type

When assessing whether a directory or file is "expected" or "abnormal", refer to the standard structure for the project's type.

### Web App (`general_web`)

```
.
├── assets/        # Small static resources (icons, etc.) — NOT for temp files or large files
├── node_modules/  # Dependencies — should NOT be committed to git
├── public/        # Public assets
├── scripts/       # Scripts
├── src/           # Source code
├── .coze/         # Coze project config
├── .git/          # Git repository
├── .gitignore
├── .next/         # Next.js build output — should NOT be committed to git
└── .npmrc
```

### Agent (`agent`)

```
.
├── config/
├── scripts/
├── src/
├── .coze/
├── .git/
├── .gitignore
├── README.md
└── requirements.txt
```

### Other project types (`app`, `wechat_mini_program`, `workflow`, `skill`)

No dedicated structure documented. Use `general_web` as the reference: source code directories are expected; build artifacts, dependency directories, and large binary/media files are typically not suitable for version control or local storage.

---

## Phase 1: Investigate

Run the following checks to get a complete picture. Do not make any changes yet.

**1.1 Check project type and safety threshold**

All disk-usage checks and thresholds in this skill refer to the size of `/workspace/projects/` (and its subdirectories), not the entire disk capacity.

```bash
echo $COZE_PROJECT_TYPE
```

| COZE_PROJECT_TYPE       | Disk Safety Threshold（/workspace/projects/） |
| ----------------------- | --------------------- |
| `general_web`         | 3G                    |
| `app`                 | 3G                    |
| `wechat_mini_program` | 3G                    |
| `agent`               | 1G                    |
| `workflow`            | 1G                    |
| `skill`               | 1G                    |
| `assistant_agent`     | 1G                    |


**1.2 Check `/workspace/projects/` usage**

```bash
du -sh /workspace/projects
# Use find -maxdepth 1 to reliably include hidden directories (.git, .next, etc.)
cd /workspace/projects && find . -maxdepth 1 -mindepth 1 -exec du -sh {} + 2>/dev/null | sort -rh | head -30
```

**1.3 Check .gitignore**

```bash
# Check existence and read content (needed for Check C comparison)
ls -la .gitignore 2>/dev/null && cat .gitignore || echo ".gitignore not found"
```

**1.4 Check file extension distribution (to understand what's in the project)**

```bash
find . -not -path './.git/*' -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -40
```

**1.5 Check .git directory**

```bash
# Check existence and size
ls -la .git/ 2>/dev/null && du -sh .git/ || echo ".git not found"
```

After collecting all findings above, proceed to Phase 2.

---

## Phase 2: Diagnose and Fix

Work through each of the following checks. Each check is independent — handle whichever ones are relevant based on the findings from Phase 1.

---

### Check A: `/workspace/projects/` usage approaching threshold?

Compare `/workspace/projects/` usage against the safety threshold from Phase 1.

- If usage is near or above the threshold → investigate which directories are large (found in step 1.2) and continue with the checks below to find what can be reduced.
- If usage is well within threshold → note this and continue checking other items as a precaution.

---

### Check B: .gitignore missing?

If `.gitignore` does not exist:

```bash
cp /source/vibe_coding/.gitignore .gitignore
```

Inform the user that a template was copied, then continue to Check C.

---

### Check C: .gitignore incomplete?

Based on the file extension distribution from step 1.4 and the directory list from step 1.2, check whether `.gitignore` is missing entries for things that shouldn't be version-controlled:

- **Build/dependency directories** that exist on disk: e.g. `node_modules/`, `.next/`, `dist/`, `build/`
- **Log files** found in the project: e.g. `*.log`, `logs/`
- **Temporary files** found: e.g. `*.tmp`, `*.cache`
- **Large non-source files** found (binaries, media, documents, datasets, etc.)

Only flag file types/directories that **actually exist** in the project. For each candidate entry not already covered by `.gitignore`, confirm with the user before adding it.

---

### Check D: Large files in the project directory (outside .git)?

If any directory is large (found in step 1.2) — whether a standard directory like `assets/` or a user-created one — investigate its contents:

```bash
# Replace <dir> with the actual large directory
find <dir> -type f -exec du -sh {} + 2>/dev/null | sort -rh | head -30
```

For each file found, assess:

- **Temporary/intermediate files**: recommend moving to system `/tmp`.
- **Large non-source files** (media, exports, datasets, etc.) that are not suitable for the project directory: recommend moving to **object storage**.

Do not move or delete anything without user confirmation.

---

### Check E: .git directory too large?

Calculate 33% of the safety threshold. If `.git/` size from step 1.5 exceeds that value, there is likely large files in git history.

Ask the user whether to proceed with git history cleanup. **Only continue below if they agree.**

**E.1 Install prerequisite**

```bash
apt-get install -y git-filter-repo
```

**E.2 Generate large-file report from git history**

```bash
git filter-repo --analyze --force
cat .git/filter-repo/analysis/path-all-sizes.txt
```

Review the report with the user. Identify which paths or file types in history are large and should be removed.

**E.3 Add identified paths/extensions to .gitignore first** (prevent re-introduction), then commit:

```bash
git add .gitignore && git commit -m "chore: update .gitignore to exclude large files"
```

**E.4 Remove from git history**

Based on the report — not a preset list — construct and run the relevant commands:

```bash
# Remove specific directories (replace with actual paths from the report)
git filter-repo --path <dir>/ --invert-paths --force

# Remove by file glob (replace with actual patterns from the report)
git filter-repo \
  --path-glob '**.<ext1>' \
  --path-glob '**.<ext2>' \
  --invert-paths --force
```

After `git filter-repo` rewrites history, MUST run the provided script to persist the commit-ID mapping.

Note: First try to find `merge-commit-map.sh` under `/skills/public/prod/repair/scripts`. If you can’t find it and need to create it yourself, make sure to create it under `/tmp` to avoid polluting the user’s `/workspace/projects` directory.

```bash
# find /skills/public/prod/repair/scripts -name merge-commit-map.sh
# Run the /{path}/merge-commit-map.sh in pwd /workspace/projects
cd /workspace/projects
bash /{path}/merge-commit-map.sh
```

merge-commit-map.sh
 
```bash
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
```

**Confirm with the user before running each command.** After each removal, verify the result:

```bash
du -sh .git/
git log --oneline -10
```

---

### Check F: .git directory missing?

If step 1.5 shows `.git` does not exist, the user has lost version control. Default to recommending Option 1 (the code is already the latest; only the history is missing), and ask the user to choose one of two options:

**Option 1 — Rebuild (lossy, recommended)**: All previous commit history will be lost. The current files become the first commit.

```bash
git config --global init.defaultBranch main
git init
git config user.name "coze_user"
git config user.email "0-coze_user@noreply.coze.cn"
git add -A
git commit -m "Initial commit"
```

**Option 2 — Restore from backup (high risk)**: Attempt to recover history from a backup. This can overwrite the current working tree, introduce inconsistent history, or cause data loss if done incorrectly. If the user does not have a reliable backup, do not attempt this. Give a clear high-risk warning and proceed to **Check H** only with explicit user confirmation.

Confirm with the user before taking either action.

---

### Check G: .git corrupted?

If `.git` exists but git commands fail (e.g. `git log`, `git status` throw errors), investigate carefully:

**G.1** Check whether HEAD is valid:

```bash
cat .git/HEAD
# Expected: ref: refs/heads/main
```

**G.2** Check whether the branch ref points to a valid commit:

```bash
cat .git/refs/heads/main
# Expected: a valid 40-character commit hash
```

**G.3** Try recovering from reflog:

```bash
git reflog
```

If a valid commit hash is visible in the reflog, attempt to restore HEAD:

```bash
git update-ref HEAD <commit-hash>
```

Proceed cautiously. Confirm with the user before any write operations.

---

### Check H: Restore from historical backup (high risk)

**This is a high-risk operation. Warn the user clearly and require explicit confirmation before proceeding.**

**H.1** Back up the current project directory first:

```bash
cp -r /workspace/projects /workspace/projects.bak
```

**H.2** List available backups with timestamps and sizes:

```bash
ls -lh /space/pack_projects/pack_project_*.tar.gz 2>/dev/null | sort
```

Present the list to the user (filename, size, and timestamp derived from the filename). Ask the user to choose which backup to restore.

**H.3** Restore the chosen backup:

```bash
# Replace <timestamp> with the value chosen by the user
tar fzx /space/pack_projects/pack_project_<timestamp>.tar.gz -C /space/pack_projects/
```

Then replace the current project directory with the restored content. Confirm the exact replacement steps with the user before executing.

---

## Phase 3: Summary

After completing all relevant checks, report back to the user:

1. Project type and safety threshold
2. Current total disk usage vs. threshold
3. Each issue found, with its severity
4. Actions taken and their outcomes
5. Any remaining recommendations
6. Inform the user that "空间容量" data shown in the bottom-right corner of the page will be refreshed after a short delay (0-3 minutes).
