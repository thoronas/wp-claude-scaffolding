#!/usr/bin/env python3
"""Collect deterministic performance review signals for a WordPress project."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


PATTERNS = [
    {
        "id": "query-posts",
        "severity": "high",
        "description": "query_posts alters the main query and is usually a performance and correctness smell.",
        "regex": re.compile(r"\bquery_posts\s*\("),
    },
    {
        "id": "wp-query",
        "severity": "medium",
        "description": "Review WP_Query usage for pagination, field selection, and cache behavior.",
        "regex": re.compile(r"\bnew\s+WP_Query\s*\("),
    },
    {
        "id": "get-posts",
        "severity": "medium",
        "description": "Review get_posts usage for no_found_rows, fields, and result size.",
        "regex": re.compile(r"\bget_posts\s*\("),
    },
    {
        "id": "posts-per-page-all",
        "severity": "medium",
        "description": "posts_per_page = -1 can cause large result sets.",
        "regex": re.compile(r"posts_per_page\s*['\"]?\s*=>\s*-1"),
    },
    {
        "id": "orderby-rand",
        "severity": "medium",
        "description": "orderby rand is expensive on large datasets.",
        "regex": re.compile(r"orderby\s*['\"]?\s*=>\s*['\"]rand['\"]"),
    },
    {
        "id": "remote-http",
        "severity": "medium",
        "description": "Remote HTTP calls should usually be cached or moved off the hot path.",
        "regex": re.compile(r"\bwp_remote_(?:get|post|request)\s*\("),
    },
    {
        "id": "global-enqueue",
        "severity": "low",
        "description": "Check whether this asset enqueue can be scoped more narrowly.",
        "regex": re.compile(r"\bwp_enqueue_(?:script|style)\s*\("),
    },
    {
        "id": "flush-rewrite-rules",
        "severity": "medium",
        "description": "flush_rewrite_rules should not run on normal requests.",
        "regex": re.compile(r"\bflush_rewrite_rules\s*\("),
    },
]

DEFAULT_ROOTS = ["plugins", "themes", "mu-plugins"]
ALLOWED_SUFFIXES = {".php", ".js", ".jsx", ".ts", ".tsx"}


def collect_files(project_root: Path, paths: list[str]) -> list[Path]:
    files: list[Path] = []
    if paths:
        candidates = [project_root / raw_path for raw_path in paths]
    else:
        candidates = [project_root / entry for entry in DEFAULT_ROOTS]

    for candidate in candidates:
        if candidate.is_file() and candidate.suffix in ALLOWED_SUFFIXES:
            files.append(candidate)
            continue
        if not candidate.is_dir():
            continue
        for path in candidate.rglob("*"):
            if path.is_file() and path.suffix in ALLOWED_SUFFIXES:
                files.append(path)
    return sorted(set(files))


def collect_findings(files: list[Path], project_root: Path) -> list[dict[str, str | int]]:
    findings: list[dict[str, str | int]] = []
    for path in files:
        try:
            lines = path.read_text(errors="ignore").splitlines()
        except OSError:
            continue

        for line_number, line in enumerate(lines, start=1):
            for pattern in PATTERNS:
                if pattern["regex"].search(line):
                    findings.append(
                        {
                            "id": pattern["id"],
                            "severity": pattern["severity"],
                            "description": pattern["description"],
                            "path": str(path.relative_to(project_root)),
                            "line": line_number,
                            "match": line.strip(),
                        }
                    )
    return findings


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Collect performance review signals.")
    parser.add_argument(
        "--project-root",
        default=".",
        help="Root of the WordPress project.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit JSON instead of plain text.",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="Optional file or directory paths, relative to project root.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).expanduser().resolve()
    files = collect_files(project_root, args.paths)
    findings = collect_findings(files, project_root)

    if args.json:
        print(json.dumps(findings, indent=2))
        return 0

    if not findings:
        print("No performance signals found.")
        return 0

    for finding in findings:
        print(
            f"{finding['severity'].upper()} {finding['id']} "
            f"{finding['path']}:{finding['line']} {finding['description']}"
        )
        print(f"  {finding['match']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
