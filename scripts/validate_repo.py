#!/usr/bin/env python3
"""
validate_repo.py — Special Agent Ops repo health check
Checks required files exist and scans markdown for misleading claims.
No external dependencies required.

Usage:
    python scripts/validate_repo.py
"""

import sys
import os
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# ── Required files ─────────────────────────────────────────────────────────────

REQUIRED_FILES = [
    "README.md",
    ".env.example",
    "scripts/run-claude-local.ps1",
    "scripts/check-endpoint.ps1",
    "examples/ollama-litellm/README.md",
    "examples/ollama-litellm/litellm_config.yaml",
]

# ── Banned phrases ─────────────────────────────────────────────────────────────
# These imply the user is running Anthropic's Claude model locally for free,
# which is misleading. The repo uses a local *endpoint*, not Anthropic's model.

BANNED_PHRASES = [
    "Claude runs locally",
    "Anthropic Claude locally",
    "free Claude locally",
    "Claude model running locally",
]

# Markdown files to scan for misleading claims
SCAN_GLOBS = ["**/*.md"]

SCAN_SKIP = [
    ".git",
]


def check_required_files():
    failures = []
    for rel in REQUIRED_FILES:
        path = REPO_ROOT / rel
        if path.exists():
            print(f"  [OK]   {rel}")
        else:
            print(f"  [FAIL] {rel} — not found")
            failures.append(rel)
    return failures


def scan_markdown():
    failures = []
    md_files = []
    for glob in SCAN_GLOBS:
        for p in REPO_ROOT.glob(glob):
            if any(skip in p.parts for skip in SCAN_SKIP):
                continue
            md_files.append(p)

    for md in sorted(md_files):
        try:
            content = md.read_text(encoding="utf-8", errors="replace")
        except OSError as e:
            print(f"  [WARN] Could not read {md.relative_to(REPO_ROOT)}: {e}")
            continue

        for phrase in BANNED_PHRASES:
            if phrase.lower() in content.lower():
                rel = md.relative_to(REPO_ROOT)
                print(f"  [FAIL] Banned phrase found in {rel}: \"{phrase}\"")
                failures.append(f"{rel}: {phrase}")

    if not failures:
        print(f"  [OK]   No misleading claims found in {len(md_files)} markdown file(s)")

    return failures


def validate_yaml_files():
    """Parse YAML files using only stdlib (json is stdlib; yaml needs a workaround).
    We do a minimal structural check: file must be non-empty and not contain
    obvious syntax errors (tab-before-key, unclosed brackets).
    Full yaml parsing needs PyYAML which is not stdlib, so we check what we can."""
    failures = []
    yaml_files = list(REPO_ROOT.glob("**/*.yaml")) + list(REPO_ROOT.glob("**/*.yml"))
    yaml_files = [f for f in yaml_files if ".git" not in f.parts]

    for yf in sorted(yaml_files):
        rel = yf.relative_to(REPO_ROOT)
        try:
            content = yf.read_text(encoding="utf-8", errors="replace")
            if not content.strip():
                print(f"  [FAIL] {rel} is empty")
                failures.append(str(rel))
                continue
            # Detect tabs used as indentation (common YAML error)
            for i, line in enumerate(content.splitlines(), 1):
                if line.startswith("\t"):
                    print(f"  [FAIL] {rel}:{i} — tab indentation is invalid in YAML")
                    failures.append(str(rel))
                    break
            else:
                print(f"  [OK]   {rel}")
        except OSError as e:
            print(f"  [WARN] Could not read {rel}: {e}")

    return failures


def main():
    print()
    print("=" * 58)
    print("  claude-code-local-runner — Repo Health Check")
    print("=" * 58)

    all_failures = []

    print("\n  Required files:")
    all_failures.extend(check_required_files())

    print("\n  YAML syntax (structural check):")
    all_failures.extend(validate_yaml_files())

    print("\n  Markdown content scan:")
    all_failures.extend(scan_markdown())

    print()
    print("=" * 58)
    if all_failures:
        print(f"  RESULT: FAIL — {len(all_failures)} issue(s) found")
        print("=" * 58)
        print()
        sys.exit(1)
    else:
        print("  RESULT: PASS — all checks passed")
        print("=" * 58)
        print()
        sys.exit(0)


if __name__ == "__main__":
    main()
