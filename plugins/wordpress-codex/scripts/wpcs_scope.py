#!/usr/bin/env python3
"""Run scoped WPCS validation for a WordPress project."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def build_command(script_name: str, paths: list[str]) -> list[str]:
    command = ["composer", script_name]
    if paths:
        command.extend(["--", *paths])
    return command


def run_command(command: list[str], project_root: Path) -> int:
    print(f"Running: {' '.join(command)}")
    result = subprocess.run(command, cwd=project_root, check=False)
    return result.returncode


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run scoped WPCS commands.")
    parser.add_argument(
        "--project-root",
        default=".",
        help="Root of the WordPress project containing composer.json.",
    )
    parser.add_argument(
        "--fix",
        action="store_true",
        help="Run composer phpcbf before composer phpcs.",
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
    if not (project_root / "composer.json").exists():
        print(f"composer.json not found in {project_root}", file=sys.stderr)
        return 1

    if args.fix:
        exit_code = run_command(build_command("phpcbf", args.paths), project_root)
        if exit_code != 0:
            return exit_code

    return run_command(build_command("phpcs", args.paths), project_root)


if __name__ == "__main__":
    sys.exit(main())
