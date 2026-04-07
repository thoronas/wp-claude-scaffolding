#!/usr/bin/env python3
"""Collect deterministic security review signals for a WordPress project."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


PATTERNS = [
    {
        "id": "direct-superglobal",
        "severity": "medium",
        "description": "Direct superglobal access requires sanitization review.",
        "regex": re.compile(r"\$_(?:GET|POST|REQUEST|COOKIE|FILES|SERVER)\b"),
    },
    {
        "id": "unsafe-rest-permission",
        "severity": "high",
        "description": "REST permission_callback should not be __return_true.",
        "regex": re.compile(r"permission_callback\s*['\"]?\s*=>\s*['\"]__return_true['\"]"),
    },
    {
        "id": "wp-redirect",
        "severity": "medium",
        "description": "Review wp_redirect usage; wp_safe_redirect is usually preferred.",
        "regex": re.compile(r"\bwp_redirect\s*\("),
    },
    {
        "id": "unserialize",
        "severity": "high",
        "description": "unserialize can be unsafe with untrusted data.",
        "regex": re.compile(r"\bunserialize\s*\("),
    },
    {
        "id": "raw-wpdb-call",
        "severity": "medium",
        "description": "Review raw $wpdb query calls for prepare() usage.",
        "regex": re.compile(r"\$wpdb->(?:query|get_var|get_row|get_results|get_col)\s*\("),
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
    parser = argparse.ArgumentParser(description="Collect security review signals.")
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
        print("No security signals found.")
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
