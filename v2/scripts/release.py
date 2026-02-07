#!/usr/bin/env uv run --no-project
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "tomlkit",
#     "ruamel.yaml",
#     "rich",
#     "packaging",
# ]
# ///

import sys
import re
import argparse
import datetime
from pathlib import Path
from abc import ABC, abstractmethod
from typing import List

import tomlkit
from ruamel.yaml import YAML
from rich.console import Console
from rich.table import Table
from rich import box
from packaging.version import parse as parse_version, InvalidVersion

console = Console()


class VersionExtractor(ABC):
    def __init__(self, file_path: Path):
        self.file_path = file_path

    @abstractmethod
    def get_version(self) -> str:
        pass

    @abstractmethod
    def update_version(self, new_version: str) -> None:
        pass

    def check_file_exists(self) -> bool:
        return self.file_path.exists()

    @property
    def name(self) -> str:
        return self.file_path.name

    @property
    def path(self) -> str:
        return str(self.file_path)


class XmlVersionExtractor(VersionExtractor):
    def get_version(self) -> str:
        # Simple regex for package.xml to avoid parsing namespaces or losing comments
        with open(self.file_path, "r", encoding="utf-8") as f:
            content = f.read()
        match = re.search(r"<version>(.*?)</version>", content)
        if match:
            return match.group(1).strip()
        raise ValueError("Could not find <version> tag in package.xml")

    def update_version(self, new_version: str) -> None:
        with open(self.file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Replace only the first occurrence which is standard for the package version
        new_content = re.sub(
            r"<version>(.*?)</version>",
            f"<version>{new_version}</version>",
            content,
            count=1,
        )

        with open(self.file_path, "w", encoding="utf-8") as f:
            f.write(new_content)


class TomlVersionExtractor(VersionExtractor):
    def __init__(self, file_path: Path, keys: List[str]):
        super().__init__(file_path)
        self.keys = keys

    def get_version(self) -> str:
        with open(self.file_path, "r", encoding="utf-8") as f:
            data = tomlkit.load(f)

        value = data
        for key in self.keys:
            if key in value:
                value = value[key]
            else:
                raise ValueError(
                    f"Key '{'.'.join(self.keys)}' not found in {self.name}"
                )

        return str(value)

    def update_version(self, new_version: str) -> None:
        with open(self.file_path, "r", encoding="utf-8") as f:
            data = tomlkit.load(f)

        # Navigate to the key
        container = data
        for i, key in enumerate(self.keys[:-1]):
            if key in container:
                container = container[key]
            else:
                raise ValueError(f"Key '{key}' not found in {self.name}")

        container[self.keys[-1]] = new_version

        with open(self.file_path, "w", encoding="utf-8") as f:
            tomlkit.dump(data, f)


class YamlVersionExtractor(VersionExtractor):
    def __init__(self, file_path: Path, keys: List[str]):
        super().__init__(file_path)
        self.keys = keys
        self.yaml = YAML()
        self.yaml.preserve_quotes = True

    def get_version(self) -> str:
        with open(self.file_path, "r", encoding="utf-8") as f:
            data = self.yaml.load(f)

        value = data
        for key in self.keys:
            if key in value:
                value = value[key]
            else:
                raise ValueError(
                    f"Key '{'.'.join(self.keys)}' not found in {self.name}"
                )

        return str(value)

    def update_version(self, new_version: str) -> None:
        with open(self.file_path, "r", encoding="utf-8") as f:
            data = self.yaml.load(f)

        container = data
        for key in self.keys[:-1]:
            container = container[key]

        container[self.keys[-1]] = new_version

        with open(self.file_path, "w", encoding="utf-8") as f:
            self.yaml.dump(data, f)


class RegexVersionExtractor(VersionExtractor):
    def __init__(self, file_path: Path, pattern: str):
        super().__init__(file_path)
        self.pattern = re.compile(pattern, re.MULTILINE)

    def get_version(self) -> str:
        with open(self.file_path, "r", encoding="utf-8") as f:
            content = f.read()

        match = self.pattern.search(content)
        if match:
            return match.group(1)
        raise ValueError(f"Pattern not found in {self.name}")

    def update_version(self, new_version: str) -> None:
        with open(self.file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # We need to replace the group(1) with new_version.
        # re.sub with a function allows us to reconstruct the string using the match
        def repl(match):
            # match.group(0) is the whole match
            # match.group(1) is the version part
            # We want to keep everything before and after group(1) in group(0)
            start, end = match.span(1)
            full_start, _ = match.span(0)

            # offset in the full match
            inner_start = start - full_start
            inner_end = end - full_start

            original_text = match.group(0)
            return original_text[:inner_start] + new_version + original_text[inner_end:]

        new_content = self.pattern.sub(repl, content, count=1)

        with open(self.file_path, "w", encoding="utf-8") as f:
            f.write(new_content)


class ChangelogVersionExtractor(RegexVersionExtractor):
    # Specialized for Keep a Changelog
    def get_version(self) -> str:
        with open(self.file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Look for ## [Version]
        matches = re.findall(r"^## \[(.*?)\]", content, re.MULTILINE)
        for version in matches:
            if version.lower() != "unreleased":
                return version
        raise ValueError("No released version found in CHANGELOG.md")

    def update_version(self, new_version: str) -> None:
        # Strategy: Rename [Unreleased] to [new_version] - Date
        # And add a new [Unreleased] section above it?
        # Or just rename [Unreleased] if the user is cutting a release.
        # Assuming we keep the [Unreleased] section for future dev.

        with open(self.file_path, "r", encoding="utf-8") as f:
            content = f.read()

        today = datetime.date.today().isoformat()

        # Find ## [Unreleased]
        # Replace with:
        # ## [Unreleased]
        #
        # ## [new_version] - YYYY-MM-DD

        pattern = r"^## \[Unreleased\]"
        if not re.search(pattern, content, re.MULTILINE):
            console.print(
                "[yellow]Warning: Could not find '## [Unreleased]' in CHANGELOG.md. Skipping update.[/yellow]"
            )
            return

        replacement = f"## [Unreleased]\n\n## [{new_version}] - {today}"

        new_content = re.sub(pattern, replacement, content, count=1, flags=re.MULTILINE)

        # Also, we might need to update the comparison links at the bottom if they exist.
        # e.g. [Unreleased]: https://.../compare/vX.Y.Z...HEAD
        # [X.Y.Z]: https://.../compare/vPrevious...vX.Y.Z
        # This is complex to do reliably with regex alone without strict format adherence.
        # For now, we update the header which is the visible part.

        with open(self.file_path, "w", encoding="utf-8") as f:
            f.write(new_content)

        console.print(
            "[blue]Updated CHANGELOG.md header. Note: Link definitions at the bottom were not updated automatically.[/blue]"
        )


def validate_semver(version: str) -> str:
    try:
        parsed = parse_version(version)
        if not isinstance(
            parsed, parse_version("1.0.0").__class__
        ):  # check if it's a valid version object
            # packaging.version.parse returns a LegacyVersion if strict=False (default) and it's invalid
            # But packaging > 22 removes LegacyVersion.
            pass
        return str(parsed)
    except InvalidVersion:
        raise argparse.ArgumentTypeError(
            f"'{version}' is not a valid Semantic Version."
        )


def main():
    parser = argparse.ArgumentParser(description="Manage project versions.")
    parser.add_argument(
        "--root", type=Path, default=Path.cwd(), help="Project root directory"
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--check-version", action="store_true", help="Check versions across files."
    )
    group.add_argument(
        "--update-version",
        type=str,
        help="Update version in all files (enforces semver).",
    )

    args = parser.parse_args()
    root_dir = args.root

    # Enforce semver for update
    if args.update_version:
        try:
            # simple semver check
            if not re.match(r"^\d+\.\d+\.\d+$", args.update_version):
                # packaging.version allows v1.0, 1.0.0.0 etc.
                # Strict SemVer 2.0.0 is X.Y.Z
                # The user asked to "Enforce semver".
                console.print(
                    f"[red]Invalid SemVer '{args.update_version}'. strict X.Y.Z required.[/red]"
                )
                sys.exit(1)
        except Exception as e:
            console.print(f"[red]Error validating version: {e}[/red]")
            sys.exit(1)

    checks: List[VersionExtractor] = [
        XmlVersionExtractor(root_dir / "package.xml"),
        TomlVersionExtractor(root_dir / "pyproject.toml", ["project", "version"]),
        ChangelogVersionExtractor(root_dir / "CHANGELOG.md", r""),
        TomlVersionExtractor(root_dir / "pixi.toml", ["workspace", "version"]),
        YamlVersionExtractor(root_dir / "CITATION.cff", ["version"]),
        RegexVersionExtractor(
            root_dir / "CMakeLists.txt", r"project\s*\(\s*\w+\s+VERSION\s+([\d.]+)"
        ),
    ]

    if args.check_version:
        results = []
        versions_found = set()
        errors = False

        console.print(f"[bold blue]Checking versions in {root_dir}...[/bold blue]")

        for check in checks:
            result = {
                "file": check.name,
                "version": None,
                "status": "Unknown",
                "message": "",
            }

            if not check.check_file_exists():
                result["status"] = "[yellow]Missing[/yellow]"
                result["message"] = "File not found (optional)"
            else:
                try:
                    version = check.get_version()
                    result["version"] = version
                    result["status"] = "[green]Found[/green]"
                    versions_found.add(version)
                except Exception as e:
                    result["status"] = "[red]Error[/red]"
                    result["message"] = str(e)
                    errors = True

            results.append(result)

        consensus_version = None
        if len(versions_found) == 1:
            consensus_version = list(versions_found)[0]
        elif len(versions_found) > 1:
            errors = True
            consensus_version = "MISMATCH"

        table = Table(title="Version Check Summary", box=box.ROUNDED)
        table.add_column("File", style="cyan")
        table.add_column("Version", style="magenta")
        table.add_column("Status", justify="center")
        table.add_column("Details")

        for res in results:
            version_display = res["version"] if res["version"] else "-"
            if res["version"]:
                if (
                    consensus_version
                    and consensus_version != "MISMATCH"
                    and res["version"] == consensus_version
                ):
                    version_display = f"[green]{res['version']}[/green]"
                elif consensus_version == "MISMATCH":
                    version_display = f"[yellow]{res['version']}[/yellow]"

            table.add_row(res["file"], version_display, res["status"], res["message"])

        console.print(table)

        if errors:
            if len(versions_found) > 1:
                console.print(
                    f"\n[bold red]FAILURE:[/bold red] Found conflicting versions: {', '.join(sorted(versions_found))}"
                )
            else:
                console.print(
                    "\n[bold red]FAILURE:[/bold red] Errors encountered (parsing errors)."
                )
            sys.exit(1)
        else:
            console.print(
                f"\n[bold green]SUCCESS:[/bold green] All files match version [bold]{consensus_version}[/bold]."
            )
            sys.exit(0)

    elif args.update_version:
        new_ver = args.update_version
        console.print(
            f"[bold blue]Updating versions to {new_ver} in {root_dir}...[/bold blue]"
        )

        for check in checks:
            if check.check_file_exists():
                try:
                    check.update_version(new_ver)
                    console.print(f"[green]Updated[/green] {check.name}")
                except Exception as e:
                    console.print(f"[red]Failed to update {check.name}: {e}[/red]")
                    sys.exit(1)
            else:
                console.print(f"[yellow]Skipping[/yellow] {check.name} (not found)")

        console.print(
            f"\n[bold green]SUCCESS:[/bold green] Version updated to {new_ver}."
        )


if __name__ == "__main__":
    main()
