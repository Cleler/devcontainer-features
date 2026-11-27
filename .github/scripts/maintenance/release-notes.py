#!/usr/bin/env python3
"""Writes the notes (markdown) of a GitHub release.

usage: release-notes.py <release-name> <owner/repo> <features.jsonl>

features.jsonl: one JSON object per published feature, as written by the publish workflow:
  {"id", "version", "previous_version" (null for a first version), "previous_tag", "tag", "changes": [...], "docs": bool}
"""
import json
import sys

release, repo, path = sys.argv[1:4]
features = [json.loads(line) for line in open(path) if line.strip()]
registry = "ghcr.io/" + repo.split("/")[0] + "/" + repo.split("/")[1]
date = release.removeprefix("release_").replace("T", " ").replace("Z", " UTC")
# 2026-11-27 21-22-10 UTC -> 2026-11-27 21:22:10 UTC
day, _, rest = date.partition(" ")
date = day + " " + rest.replace("-", ":", 2)

n = len(features)
out = [
    f"## 🚀 Release of {date}",
    "",
    f"{n} feature{'s' if n > 1 else ''} published.",
    "",
    "| Feature | Version | Install |",
    "|---|---|---|",
]
for f in features:
    old = f["previous_version"]
    change = f"{old} → **{f['version']}**" if old else f"🆕 **{f['version']}**"
    out.append(f"| `{f['id']}` | {change} | `{registry}/{f['id']}:{f['version'].split('.')[0]}` |")

for f in features:
    out += ["", "---", "", f"### 📦 `{f['id']}` {f['version']}", ""]
    meta = []
    if f["previous_tag"]:
        meta.append(f"[full diff](https://github.com/{repo}/compare/{f['previous_tag']}...{f['tag']})")
    meta.append(f"[tag `{f['tag']}`](https://github.com/{repo}/tree/{f['tag']})")
    if f["docs"]:
        meta.append("📚 documentation updated")
    out += [" · ".join(meta), ""]
    out.append("**Changes**")
    out.append("")
    out += [f"- {c}" for c in f["changes"]] or ["- No notable change"]

print("\n".join(out))
