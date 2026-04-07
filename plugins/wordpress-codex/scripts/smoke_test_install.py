#!/usr/bin/env python3
"""Run an install plus validation smoke test for the WordPress Codex plugin."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def run_command(command: list[str]) -> None:
    result = subprocess.run(command, check=False)
    if result.returncode != 0:
        raise SystemExit(result.returncode)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run an install and validation smoke test for WordPress Codex."
    )
    parser.add_argument(
        "--workspace",
        help="Optional workspace root for smoke-test targets.",
    )
    parser.add_argument(
        "--methods",
        nargs="+",
        choices=["copy", "symlink"],
        default=["copy", "symlink"],
        help="Install methods to test.",
    )
    parser.add_argument(
        "--keep",
        action="store_true",
        help="Keep the generated workspace when using a temporary directory.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    scripts_root = Path(__file__).resolve().parent
    install_script = scripts_root / "install_plugin.py"
    validate_script = scripts_root / "validate_plugin.py"

    created_temp = False
    if args.workspace:
        workspace_root = Path(args.workspace).expanduser().resolve()
        workspace_root.mkdir(parents=True, exist_ok=True)
    else:
        workspace_root = Path(tempfile.mkdtemp(prefix="wordpress-codex-smoke-"))
        created_temp = True

    try:
        for method in args.methods:
            target_root = workspace_root / method
            run_command(
                [
                    sys.executable,
                    str(install_script),
                    "--target-root",
                    str(target_root),
                    "--method",
                    method,
                    "--force",
                ]
            )

            run_command(
                [
                    sys.executable,
                    str(validate_script),
                    "--plugin-root",
                    str(target_root / "plugins" / "wordpress-codex"),
                    "--marketplace",
                    str(target_root / ".agents" / "plugins" / "marketplace.json"),
                ]
            )

        print(f"Smoke test passed for methods: {', '.join(args.methods)}")
        print(f"Workspace: {workspace_root}")
        return 0
    finally:
        if created_temp and not args.keep:
            shutil.rmtree(workspace_root, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
