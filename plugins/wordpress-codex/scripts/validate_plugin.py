#!/usr/bin/env python3
"""Validate the WordPress Codex plugin package and optional marketplace entry."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


SKILL_FRONTMATTER_PATTERN = re.compile(r"^---\n(.*?)\n---", re.DOTALL)


def load_json(path: Path) -> dict[str, Any]:
    with path.open() as handle:
        payload = json.load(handle)
    if not isinstance(payload, dict):
        raise ValueError(f"{path} must contain a JSON object.")
    return payload


def parse_frontmatter(skill_path: Path) -> dict[str, str]:
    content = skill_path.read_text()
    match = SKILL_FRONTMATTER_PATTERN.match(content)
    if not match:
        raise ValueError(f"{skill_path} is missing valid YAML frontmatter.")

    fields: dict[str, str] = {}
    for raw_line in match.group(1).splitlines():
        if ":" not in raw_line or raw_line.startswith(" "):
            continue
        key, value = raw_line.split(":", 1)
        fields[key.strip()] = value.strip().strip("\"'")
    return fields


def validate_openai_yaml(path: Path, expected_skill_name: str | None = None) -> list[str]:
    errors: list[str] = []
    content = path.read_text()
    required_patterns = [
        r"(?m)^interface:\s*$",
        r"(?m)^\s+display_name:\s+",
        r"(?m)^\s+short_description:\s+",
        r"(?m)^\s+default_prompt:\s+",
    ]
    for pattern in required_patterns:
        if re.search(pattern, content) is None:
            errors.append(f"{path} is missing a required interface field.")
            break

    if expected_skill_name and f"${expected_skill_name}" not in content:
        errors.append(
            f"{path} should mention ${expected_skill_name} in interface.default_prompt."
        )
    return errors


def validate_plugin(plugin_root: Path) -> list[str]:
    errors: list[str] = []
    manifest_path = plugin_root / ".codex-plugin" / "plugin.json"
    if not manifest_path.exists():
        return [f"Missing plugin manifest: {manifest_path}"]

    try:
        manifest = load_json(manifest_path)
    except Exception as exc:
        return [str(exc)]

    plugin_name = manifest.get("name")
    if not isinstance(plugin_name, str) or not plugin_name:
        errors.append(f"{manifest_path} is missing a valid 'name'.")
    elif plugin_root.name != plugin_name:
        errors.append(
            f"Plugin folder name '{plugin_root.name}' does not match manifest name '{plugin_name}'."
        )

    interface = manifest.get("interface")
    if not isinstance(interface, dict):
        errors.append(f"{manifest_path} is missing a valid 'interface' object.")
    else:
        for field in ["displayName", "shortDescription", "defaultPrompt"]:
            if field not in interface:
                errors.append(f"{manifest_path} is missing interface.{field}.")

    plugin_agent_yaml = plugin_root / "agents" / "openai.yaml"
    if not plugin_agent_yaml.exists():
        errors.append(f"Missing plugin-level metadata: {plugin_agent_yaml}")
    else:
        errors.extend(validate_openai_yaml(plugin_agent_yaml))

    skills_root = plugin_root / "skills"
    if not skills_root.is_dir():
        errors.append(f"Missing skills directory: {skills_root}")
        return errors

    for skill_dir in sorted(path for path in skills_root.iterdir() if path.is_dir()):
        skill_md = skill_dir / "SKILL.md"
        if not skill_md.exists():
            errors.append(f"Missing SKILL.md in {skill_dir}")
            continue

        try:
            frontmatter = parse_frontmatter(skill_md)
        except Exception as exc:
            errors.append(str(exc))
            continue

        skill_name = frontmatter.get("name")
        skill_description = frontmatter.get("description")
        if not skill_name:
            errors.append(f"{skill_md} is missing frontmatter 'name'.")
        if not skill_description:
            errors.append(f"{skill_md} is missing frontmatter 'description'.")

        metadata_path = skill_dir / "agents" / "openai.yaml"
        if not metadata_path.exists():
            errors.append(f"Missing skill metadata: {metadata_path}")
        elif skill_name:
            errors.extend(validate_openai_yaml(metadata_path, skill_name))

    return errors


def validate_marketplace(plugin_root: Path, marketplace_path: Path) -> list[str]:
    errors: list[str] = []
    if not marketplace_path.exists():
        return [f"Marketplace file not found: {marketplace_path}"]

    try:
        payload = load_json(marketplace_path)
    except Exception as exc:
        return [str(exc)]

    plugins = payload.get("plugins")
    if not isinstance(plugins, list):
        return [f"{marketplace_path} field 'plugins' must be an array."]

    manifest = load_json(plugin_root / ".codex-plugin" / "plugin.json")
    plugin_name = manifest["name"]

    for entry in plugins:
        if not isinstance(entry, dict):
            continue
        if entry.get("name") != plugin_name:
            continue
        source = entry.get("source", {})
        relative_path = source.get("path")
        if relative_path != f"./plugins/{plugin_name}":
            errors.append(
                f"{marketplace_path} entry for {plugin_name} should use ./plugins/{plugin_name}."
            )
        resolved = (marketplace_path.parent.parent.parent / relative_path[2:]).resolve()
        if resolved != plugin_root.resolve():
            errors.append(
                f"{marketplace_path} entry resolves to {resolved}, not {plugin_root.resolve()}."
            )
        return errors

    errors.append(f"{marketplace_path} does not contain an entry for {plugin_name}.")
    return errors


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate the WordPress Codex plugin.")
    parser.add_argument(
        "--plugin-root",
        default=str(Path(__file__).resolve().parents[1]),
        help="Path to the plugin root.",
    )
    parser.add_argument(
        "--marketplace",
        help="Optional path to marketplace.json for install validation.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    plugin_root = Path(args.plugin_root).expanduser().resolve()
    errors = validate_plugin(plugin_root)

    if args.marketplace:
        marketplace_path = Path(args.marketplace).expanduser().resolve()
        errors.extend(validate_marketplace(plugin_root, marketplace_path))

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1

    print(f"Plugin validation passed: {plugin_root}")
    if args.marketplace:
        print(f"Marketplace validation passed: {args.marketplace}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
