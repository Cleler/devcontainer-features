#!/usr/bin/env python3
"""Adds the entry of a new version at the top of the Changelog table of src/<id>/NOTES.md.

usage: changelog.py <id> <version> [previous-tag]

The notes are the subjects of the commits that touched the feature since the previous tag (changes.sh). The
README of the feature, generated from NOTES.md, then gets the table too.
"""
import os
import subprocess
import sys

id_, version = sys.argv[1], sys.argv[2]
previous_tag = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != "null" else ""
here = os.path.dirname(os.path.abspath(__file__))
path = f"src/{id_}/NOTES.md"

subjects = subprocess.run([os.path.join(here, "changes.sh"), id_, previous_tag],
                          check=True, capture_output=True, text=True).stdout.split("\n")
notes = "<br>".join(s.replace("|", "\\|") for s in subjects if s) or "No notable change"
row = f"| {version} | {notes} |"

lines = open(path).read().split("\n")
if "## Changelog" in lines:
    i = lines.index("## Changelog")
    # skip the header and the separator of the table
    j = i + 1
    while j < len(lines) and not lines[j].startswith("| ---"):
        j += 1
    lines.insert(j + 1, row)
else:
    section = ["## Changelog", "", "| Version | Notes |", "| ------- | ----- |", row, ""]
    k = lines.index("## Source") if "## Source" in lines else len(lines)
    lines[k:k] = section

open(path, "w").write("\n".join(lines))
print(f"{id_}: changelog entry {version}")
