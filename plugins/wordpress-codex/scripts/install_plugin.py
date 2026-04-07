#!/usr/bin/env python3
"""Install the WordPress Codex plugin into a Codex plugin root."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
from pathlib import Path
from typing import Any


DEFAULT_MARKETPLACE_NAME = "local-plugins"
DEFAULT_MARKETPLACE_DISPLAY_NAME = "Local Plugins"


def load_json(path: Path) -> dict[str, Any]:
    with path.open() as handle:
        payload = json.load(handle)
    if not isinstance(payload, dict):
        raise ValueError(f"{path} must contain a JSON object.")
    return payload


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w") as handle:
        json.dump(payload, handle, indent=2)
        handle.write("\n")


def remove_path(path: Path) -> None:
    if path.is_symlink() or path.is_file():
        path.unlink()
        return
    if path.is_dir():
        shutil.rmtree(path)


def load_plugin_manifest(plugin_root: Path) -> dict[str, Any]:
    manifest_path = plugin_root / ".codex-plugin" / "plugin.json"
    payload = load_json(manifest_path)
    if "name" not in payload:
        raise ValueError(f"{manifest_path} is missing 'name'.")
    return payload


def install_plugin(source_root: Path, target_root: Path, method: str, force: bool) -> Path:
    manifest = load_plugin_manifest(source_root)
    plugin_name = manifest["name"]
    destination = target_root / "plugins" / plugin_name

    if destination.exists() and destination.resolve() == source_root.resolve():
        return destination

    if destination.exists() or destination.is_symlink():
        if not force:
            raise FileExistsError(
                f"{destination} already exists. Re-run with --force to replace it."
            )
        remove_path(destination)

    destination.parent.mkdir(parents=True, exist_ok=True)

    if method == "copy":
        shutil.copytree(
            source_root,
            destination,
            symlinks=True,
            ignore=shutil.ignore_patterns("__pycache__", "*.pyc"),
        )
    else:
        os.symlink(source_root, destination, target_is_directory=True)

    return destination


def update_marketplace(
    target_root: Path,
    plugin_name: str,
    category: str,
) -> Path:
    marketplace_path = target_root / ".agents" / "plugins" / "marketplace.json"
    should_write = not marketplace_path.exists()
    if marketplace_path.exists():
        payload = load_json(marketplace_path)
    else:
        payload = {
            "name": DEFAULT_MARKETPLACE_NAME,
            "interface": {"displayName": DEFAULT_MARKETPLACE_DISPLAY_NAME},
            "plugins": [],
        }

    plugins = payload.setdefault("plugins", [])
    if not isinstance(plugins, list):
        raise ValueError(f"{marketplace_path} field 'plugins' must be an array.")

    payload_before = json.dumps(payload, indent=2, sort_keys=True)

    new_entry = {
        "name": plugin_name,
        "source": {
            "source": "local",
            "path": f"./plugins/{plugin_name}",
        },
        "policy": {
            "installation": "AVAILABLE",
            "authentication": "ON_INSTALL",
        },
        "category": category,
    }

    replaced = False
    for index, entry in enumerate(plugins):
        if isinstance(entry, dict) and entry.get("name") == plugin_name:
            plugins[index] = new_entry
            replaced = True
            break

    if not replaced:
        plugins.append(new_entry)

    payload_after = json.dumps(payload, indent=2, sort_keys=True)
    if should_write or payload_before != payload_after:
        write_json(marketplace_path, payload)
    return marketplace_path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Install the WordPress Codex plugin into a Codex plugin root."
    )
    parser.add_argument(
        "--target-root",
        default=str(Path.home()),
        help=(
            "Root containing plugins/ and .agents/plugins/marketplace.json. "
            "Defaults to the user's home directory for home-local installs."
        ),
    )
    parser.add_argument(
        "--method",
        choices=["copy", "symlink"],
        default="symlink",
        help="Install by copying or symlinking the plugin directory.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Replace an existing installation or marketplace entry for this plugin.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source_root = Path(__file__).resolve().parents[1]
    target_root = Path(args.target_root).expanduser().resolve()
    manifest = load_plugin_manifest(source_root)

    plugin_name = str(manifest["name"])
    interface = manifest.get("interface", {})
    category = interface.get("category", "Developer Tools")

    installed_path = install_plugin(source_root, target_root, args.method, args.force)
    marketplace_path = update_marketplace(target_root, plugin_name, category)

    print(f"Installed plugin: {plugin_name}")
    print(f"Source root: {source_root}")
    print(f"Installed path: {installed_path}")
    print(f"Marketplace: {marketplace_path}")
    print(f"Method: {args.method}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
