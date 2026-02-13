#!/usr/bin/env uv run --no-project
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "tomlkit",
#     "ruamel.yaml",
#     "rich",
#     "packaging",
#     "GitPython",
#     "cmake-parser",
# ]
# ///

"""
# Release Script Documentation

`release.py` is a utility script designed to manage project versions across multiple file formats, ensuring consistency and automating the release process.

## Features

-   **Multi-file Support**: Updates version strings in:
    -   `package.xml` (ROS)
    -   `pyproject.toml` (Python)
    -   `CHANGELOG.md` (Keep a Changelog format)
    -   `pixi.toml` (Pixi)
    -   `CITATION.cff` (Citation File Format)
    -   `CMakeLists.txt` (CMake)
-   **Version Checking**: Verifies that all tracked files share the same version number.
-   **Semantic Versioning**: Enforces SemVer (X.Y.Z) compliance.
-   **Automated Bumping**: Supports major, minor, and patch version bumps.
-   **Git Integration**: Option to automatically commit changes and create release tags using GitPython.
-   **Safe Checks**: Includes dry-run mode and version progression validation.

## Prerequisites

The script lists its dependencies in the file header using [inline script metadata (PEP 723)](https://peps.python.org/pep-0723/). It is recommended to execute it using `uv` to handle dependencies automatically.

-   Python >= 3.9
-   Dependencies: `tomlkit`, `ruamel.yaml`, `rich`, `packaging`, `GitPython`

## Usage

### Running the Script

You can run the script directly with `uv`:

```bash
uv run --no-project release.py [OPTIONS]
```

Or via python if dependencies are manually installed:

```bash
python release.py [OPTIONS]
```

### Common Commands

#### Check Current Version
Verify that all files are in sync and report the current consensus version.

```bash
uv run --no-project release.py --check-version
```

#### Bump Version
Bump the project version (semver).

```bash
# Bump patch version (e.g. 1.0.0 -> 1.0.1)
uv run --no-project release.py --bump patch

# Bump minor version (e.g. 1.0.0 -> 1.1.0)
uv run --no-project release.py --bump minor

# Bump major version (e.g. 1.0.0 -> 2.0.0)
uv run --no-project release.py --bump major
```

#### Set Specific Version
Manually set the project to a specific version string.

```bash
uv run --no-project release.py --update-version 1.2.3
```

### Options

| Option | Description |
| :--- | :--- |
| `--root <PATH>` | Set the project root directory (default: current working directory). |
| `--bump <major\\|minor\\|patch>` | Bump the version component. |
| `--dry-run` | Show what would change without modifying files. |
| `--short` | Output only the final version string. |
| `--output-format <text\\|json>` | Output format (default: text). |
| `--confirm` | Auto-confirm actions without interactive prompts. |
| `--list-files` | List all files that are currently checked/updated. |

### Git Integration

The script can automatically commit changes and tag the release using the local git configuration.

```bash
# Bump patch version, commit, and tag
uv run --no-project release.py --bump patch --git-commit --git-tag
```

-   **Commit Message**: `chore: bump version to X.Y.Z`
-   **Tag Name**: `vX.Y.Z`
-   **Tag Message**: `Release version X.Y.Z`

## Supported File Patterns

The script defines several `VersionExtractor` classes to handle specific file formats:

-   **package.xml**: Updates contents of `<version>X.Y.Z</version>`.
-   **pyproject.toml**: Updates `tool.poetry.version` or standard `project.version`.
-   **CHANGELOG.md**:
    -   Reads the first version that != "Unreleased".
    -   On update, replaces the `## [Unreleased]` header with `## [Unreleased]` followed by a new section `## [X.Y.Z] - YYYY-MM-DD`.
-   **pixi.toml**: Updates the `[workspace] version` key.
-   **CITATION.cff**: Updates the top-level `version` key.
-   **CMakeLists.txt**: Scans for `project(... VERSION X.Y.Z ...)` using regex.
"""

import sys
import re
import argparse
import datetime
import json
from pathlib import Path
from abc import ABC, abstractmethod
from typing import List, Optional, Tuple

import tomlkit
import cmake_parser
from git import Repo, exc
from ruamel.yaml import YAML
from rich.console import Console
from rich.table import Table
from rich import box
from rich.prompt import Confirm
from rich.panel import Panel
from rich.markdown import Markdown
from rich.text import Text
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


class CMakeListsVersionExtractor(VersionExtractor):
    """Specialized extractor for CMakeLists.txt that uses cmake-parser
    and handles both direct VERSION and variables (e.g., from package.xml)."""

    def get_version(self) -> str:
        with open(self.file_path, "r", encoding="utf-8") as f:
            content = f.read()

        try:
            # Parse the CMakeLists.txt file
            tree = cmake_parser.parse(content)

            fallback_version = None
            project_version = None

            # Walk through all commands
            for node in tree:
                if hasattr(node, "name"):
                    # Look for set(PROJECT_VERSION "...")
                    if node.name.lower() == "set":
                        args = self._get_command_args(node)
                        if len(args) >= 2 and args[0] == "PROJECT_VERSION":
                            # Remove quotes from version string
                            fallback_version = args[1].strip('"')

                    # Look for project(...VERSION ...)
                    elif node.name.lower() == "project":
                        args = self._get_command_args(node)
                        # Find VERSION keyword
                        try:
                            version_idx = args.index("VERSION")
                            if version_idx + 1 < len(args):
                                ver = args[version_idx + 1]
                                # Check if it's a variable reference
                                if not ver.startswith("${"):
                                    project_version = ver
                        except ValueError:
                            pass

            # If project() uses a variable, return fallback
            if fallback_version and not project_version:
                return fallback_version

            # If project() has a literal version, use that
            if project_version:
                return project_version

            raise ValueError(f"No version found in {self.name}")

        except Exception:
            # Fallback to regex if cmake-parser fails
            return self._get_version_regex(content)

    def _get_command_args(self, node) -> List[str]:
        """Extract arguments from a cmake command node."""
        args = []
        if hasattr(node, "body"):
            for item in node.body:
                if hasattr(item, "contents"):
                    args.append(item.contents)
        return args

    def _get_version_regex(self, content: str) -> str:
        """Fallback regex-based version extraction."""
        # First try to find set(PROJECT_VERSION "X.Y.Z")
        fallback_pattern = re.compile(
            r'set\s*\(\s*PROJECT_VERSION\s+"([0-9]+\.[0-9]+\.[0-9]+)"',
            re.MULTILINE,
        )
        fallback_match = fallback_pattern.search(content)

        # Also check if project() uses a literal version or variable
        project_pattern = re.compile(
            r"project\s*\([^)]*VERSION\s+([\d.]+|\$\{[^}]+\})", re.MULTILINE
        )
        project_match = project_pattern.search(content)

        # If project() uses a variable, use the fallback version
        if project_match and project_match.group(1).startswith("${"):
            if fallback_match:
                return fallback_match.group(1)
            raise ValueError(
                f"{self.name} reads version from variable {project_match.group(1)}, no fallback found"
            )

        # If project() uses a literal, return it
        if project_match and not project_match.group(1).startswith("${"):
            return project_match.group(1)

        raise ValueError(f"Pattern not found in {self.name}")

    def update_version(self, new_version: str) -> None:
        with open(self.file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Update the fallback version in set(PROJECT_VERSION "...")
        fallback_pattern = re.compile(
            r'(set\s*\(\s*PROJECT_VERSION\s+)"([0-9]+\.[0-9]+\.[0-9]+)"',
            re.MULTILINE,
        )

        def repl_fallback(match):
            return f'{match.group(1)}"{new_version}"'

        content = fallback_pattern.sub(repl_fallback, content, count=1)

        # Also update literal version in project() if present
        project_pattern = re.compile(
            r"(project\s*\([^)]*VERSION\s+)([\d.]+)", re.MULTILINE
        )

        def repl_project(match):
            return f"{match.group(1)}{new_version}"

        content = project_pattern.sub(repl_project, content, count=1)

        with open(self.file_path, "w", encoding="utf-8") as f:
            f.write(content)


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


def parse_semver(version: str) -> Tuple[int, int, int]:
    """Parse a semantic version string into major, minor, patch components."""
    match = re.match(r"^(\d+)\.(\d+)\.(\d+)$", version.strip())
    if not match:
        raise ValueError(f"Invalid semver format: {version}")
    return int(match.group(1)), int(match.group(2)), int(match.group(3))


def bump_version(version: str, bump_type: str) -> str:
    """Bump a semantic version by major, minor, or patch."""
    major, minor, patch = parse_semver(version)

    if bump_type == "major":
        return f"{major + 1}.0.0"
    elif bump_type == "minor":
        return f"{major}.{minor + 1}.0"
    elif bump_type == "patch":
        return f"{major}.{minor}.{patch + 1}"
    else:
        raise ValueError(f"Invalid bump type: {bump_type}")


def get_current_version(checks: List[VersionExtractor]) -> Optional[str]:
    """Get the current consensus version from all files."""
    versions_found = set()

    for check in checks:
        if check.check_file_exists():
            try:
                version = check.get_version()
                versions_found.add(version)
            except Exception:
                pass

    if len(versions_found) == 1:
        return list(versions_found)[0]
    elif len(versions_found) > 1:
        console.print(
            f"[red]Error: Multiple versions found: {', '.join(sorted(versions_found))}[/red]"
        )
        console.print(
            "[yellow]Please run --check-version first to resolve conflicts.[/yellow]"
        )
        return None
    else:
        console.print("[red]Error: No version found in any files.[/red]")
        return None


def show_version_diff(old_version: str, new_version: str) -> None:
    """Display a visual diff between old and new versions."""
    old_parts = old_version.split(".")
    new_parts = new_version.split(".")

    diff_parts = []
    for i, (old, new) in enumerate(zip(old_parts, new_parts)):
        if old != new:
            diff_parts.append(f"[red]{old}[/red] → [green]{new}[/green]")
        else:
            diff_parts.append(f"[dim]{old}[/dim]")

    diff_text = ".".join(diff_parts)

    panel = Panel(
        f"[bold]{diff_text}[/bold]\n\n"
        f"[cyan]{old_version}[/cyan] → [green]{new_version}[/green]",
        title="[bold yellow]Version Change[/bold yellow]",
        border_style="yellow",
        expand=False,
    )
    console.print(panel)


def validate_version_progression(
    old_version: str, new_version: str, bump_type: str
) -> None:
    """Validate and warn about unusual version progressions."""
    try:
        old_major, old_minor, old_patch = parse_semver(old_version)
        new_major, new_minor, new_patch = parse_semver(new_version)
    except ValueError:
        return  # Can't validate non-semver

    warnings = []

    # Check for skipped versions
    if bump_type == "major":
        if new_major != old_major + 1:
            warnings.append(
                f"Major version jump: {old_major} → {new_major} (skipping versions)"
            )
    elif bump_type == "minor":
        if new_major != old_major:
            warnings.append(
                f"Major version changed during minor bump: {old_major} → {new_major}"
            )
        elif new_minor != old_minor + 1:
            warnings.append(
                f"Minor version jump: {old_minor} → {new_minor} (skipping versions)"
            )
    elif bump_type == "patch":
        if new_major != old_major:
            warnings.append(
                f"Major version changed during patch bump: {old_major} → {new_major}"
            )
        elif new_minor != old_minor:
            warnings.append(
                f"Minor version changed during patch bump: {old_minor} → {new_minor}"
            )
        elif new_patch != old_patch + 1:
            warnings.append(
                f"Patch version jump: {old_patch} → {new_patch} (skipping versions)"
            )

    # Check for backward version
    if (new_major, new_minor, new_patch) <= (old_major, old_minor, old_patch):
        warnings.append("New version is not greater than old version")

    if warnings:
        console.print("[bold yellow]⚠ Version Progression Warnings:[/bold yellow]")
        for warning in warnings:
            console.print(f"  [yellow]• {warning}[/yellow]")
        console.print()


def git_commit_version(
    root_dir: Path, version: str, files_to_commit: List[str], auto_confirm: bool
) -> bool:
    """Commit version changes to git."""
    try:
        repo = Repo(root_dir, search_parent_directories=True)
    except exc.InvalidGitRepositoryError:
        console.print("[yellow]Not a git repository, skipping git commit.[/yellow]")
        return False

    if not repo.is_dirty():
        console.print("[yellow]No changes to commit.[/yellow]")
        return False

    commit_message = f"chore: bump version to {version}"

    if not auto_confirm:
        confirmed = Confirm.ask(
            f"[bold]Commit changes with message: '{commit_message}'?[/bold]",
            default=True,
        )
        if not confirmed:
            console.print("[yellow]Git commit skipped.[/yellow]")
            return False

    # Add all version files
    try:
        console.print(f"[dim]$ git add {' '.join(files_to_commit)}[/dim]")
        repo.git.add(files_to_commit)
    except exc.GitCommandError as e:
        console.print(f"[red]Failed to stage changes: {e}[/red]")
        return False

    # Commit
    try:
        # Use git command to trigger hooks
        console.print(f"[dim]$ git commit -m '{commit_message}'[/dim]")
        repo.git.commit("-m", commit_message)
        console.print(f"[green]✓ Committed changes: {commit_message}[/green]")
        return True
    except exc.GitCommandError as e:
        # Check if pre-commit hooks failed (often they modify files)
        if (root_dir / ".pre-commit-config.yaml").exists():
            console.print(
                "[yellow]Commit failed or hooks triggered. Attempting to re-stage and commit...[/yellow]"
            )
            try:
                # Re-stage any changes made by hooks (e.g. formatting)
                console.print(f"[dim]$ git add {' '.join(files_to_commit)}[/dim]")
                repo.git.add(files_to_commit)
                # Try commit again
                console.print(f"[dim]$ git commit -m '{commit_message}'[/dim]")
                repo.git.commit("-m", commit_message)
                console.print(
                    f"[green]✓ Committed changes after hook updates: {commit_message}[/green]"
                )
                return True
            except exc.GitCommandError as e2:
                console.print(f"[red]Failed to commit after retry: {e2}[/red]")
                return False

        console.print(f"[red]Failed to commit: {e}[/red]")
        return False


def git_tag_version(root_dir: Path, version: str, auto_confirm: bool) -> bool:
    """Create a git tag for the version."""
    try:
        repo = Repo(root_dir, search_parent_directories=True)
    except exc.InvalidGitRepositoryError:
        console.print("[yellow]Not a git repository, skipping git tag.[/yellow]")
        return False

    tag_name = f"v{version}"
    tag_message = f"Release version {version}"

    # Check if tag already exists
    if tag_name in repo.tags:
        console.print(f"[yellow]Tag {tag_name} already exists.[/yellow]")
        return False

    if not auto_confirm:
        confirmed = Confirm.ask(
            f"[bold]Create git tag '{tag_name}'?[/bold]", default=True
        )
        if not confirmed:
            console.print("[yellow]Git tag skipped.[/yellow]")
            return False

    # Create annotated tag
    try:
        console.print(f"[dim]$ git tag -a {tag_name} -m '{tag_message}'[/dim]")
        repo.create_tag(tag_name, message=tag_message)
        console.print(f"[green]✓ Created tag: {tag_name}[/green]")
        console.print(f"[dim]  To push: git push origin {tag_name}[/dim]")
        return True
    except exc.GitCommandError as e:
        console.print(f"[red]Failed to create tag: {e}[/red]")
        return False


def list_version_files(checks: List[VersionExtractor]) -> None:
    """List all files that are checked for versions."""
    table = Table(title="Version Files", box=box.ROUNDED)
    table.add_column("File", style="cyan")
    table.add_column("Path", style="dim")
    table.add_column("Exists", justify="center")
    table.add_column("Type", style="magenta")

    for check in checks:
        exists = "[green]✓[/green]" if check.check_file_exists() else "[red]✗[/red]"
        file_type = check.__class__.__name__.replace("VersionExtractor", "")
        table.add_row(check.name, str(check.file_path), exists, file_type)

    console.print(table)
    sys.exit(0)


class RichHelpAction(argparse.Action):
    def __init__(
        self,
        option_strings,
        dest=argparse.SUPPRESS,
        default=argparse.SUPPRESS,
        help=None,
    ):
        super().__init__(
            option_strings=option_strings,
            dest=dest,
            default=default,
            nargs=0,
            help=help,
        )

    def __call__(self, parser, namespace, values, option_string=None):
        if parser.description:
            console.print(Markdown(parser.description))

        # Print the standard argparse usage and options
        # We clear the description to avoid printing the markdown source again
        original_description = parser.description
        parser.description = None

        console.print(Text("\nCommand Reference:\n", style="bold"))
        console.print(Text(parser.format_help()))

        parser.description = original_description
        parser.exit()


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        add_help=False,
    )
    parser.add_argument(
        "-h",
        "--help",
        action=RichHelpAction,
        help="Show this help message and exit",
    )
    parser.add_argument(
        "--root", type=Path, default=Path.cwd(), help="Project root directory"
    )
    parser.add_argument(
        "--confirm",
        action="store_true",
        help="Auto-confirm all actions without prompting.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would change without modifying files.",
    )
    parser.add_argument(
        "--git-commit",
        action="store_true",
        help="Commit version changes to git after updating.",
    )
    parser.add_argument(
        "--git-tag",
        action="store_true",
        help="Create a git tag for the new version.",
    )
    parser.add_argument(
        "--short",
        action="store_true",
        help="Output only the final version string.",
    )
    parser.add_argument(
        "--output-format",
        choices=["text", "json"],
        default="text",
        help="Output format (default: text).",
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--check-version", action="store_true", help="Check versions across files."
    )
    group.add_argument(
        "--list-files",
        action="store_true",
        help="List all files that are checked for versions.",
    )
    group.add_argument(
        "--update-version",
        type=str,
        help="Update version in all files (enforces semver).",
    )
    group.add_argument(
        "--bump",
        choices=["major", "minor", "patch"],
        help="Bump the project version.",
    )

    args = parser.parse_args()
    root_dir = args.root

    # Redirect console output to stderr if we want clean stdout for json/short
    global console
    if args.short or args.output_format == "json":
        console = Console(file=sys.stderr)
    else:
        # Default behavior
        console = Console()

    # Enforce semver for update
    if args.update_version:
        try:
            # simple semver check
            if not re.match(r"^\d+\.\d+\.\d+$", args.update_version):
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
        CMakeListsVersionExtractor(root_dir / "CMakeLists.txt"),
    ]

    if args.list_files:
        if args.output_format == "json":
            files_list = []
            for check in checks:
                files_list.append(
                    {
                        "name": check.name,
                        "path": str(check.file_path),
                        "exists": check.check_file_exists(),
                        "type": check.__class__.__name__.replace(
                            "VersionExtractor", ""
                        ),
                    }
                )
            print(json.dumps(files_list, indent=2))
        else:
            list_version_files(checks)
        sys.exit(0)

    if args.check_version:
        results = []
        versions_found = set()
        errors = False

        if not args.short:
            console.print(f"[bold blue]Checking versions in {root_dir}...[/bold blue]")

        for check in checks:
            result = {
                "file": check.name,
                "version": None,
                "status": "Unknown",
                "message": "",
            }

            if not check.check_file_exists():
                result["status"] = "Missing"
                result["message"] = "File not found"
            else:
                try:
                    version = check.get_version()
                    result["version"] = version
                    result["status"] = "Found"
                    versions_found.add(version)
                except Exception as e:
                    result["status"] = "Error"
                    result["message"] = str(e)
                    errors = True

            results.append(result)

        consensus_version = None
        if len(versions_found) == 1:
            consensus_version = list(versions_found)[0]
        elif len(versions_found) > 1:
            errors = True
            consensus_version = "MISMATCH"

        if args.output_format == "json":
            out_payload = {
                "consensus_version": consensus_version,
                "files": results,
                "consistent": not errors and len(versions_found) == 1,
            }
            print(json.dumps(out_payload, indent=2))
            sys.exit(1 if errors else 0)

        # Standard Rich table output
        table = Table(title="Version Check Summary", box=box.ROUNDED)
        table.add_column("File", style="cyan")
        table.add_column("Version", style="magenta")
        table.add_column("Status", justify="center")
        table.add_column("Details")

        for res in results:
            status_style = res["status"]
            if res["status"] == "Found":
                status_style = "[green]Found[/green]"
            elif res["status"] == "Missing":
                status_style = "[yellow]Missing[/yellow]"
            elif res["status"] == "Error":
                status_style = "[red]Error[/red]"

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

            table.add_row(res["file"], version_display, status_style, res["message"])

        if not args.short:
            console.print(table)

        if args.short and consensus_version and consensus_version != "MISMATCH":
            print(consensus_version)

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
        elif not versions_found:
            console.print(
                f"\n[bold red]FAILURE:[/bold red] No version files found in {root_dir}."
            )
            sys.exit(1)
        else:
            if not args.short:
                console.print(
                    f"\n[bold green]SUCCESS:[/bold green] All files match version [bold]{consensus_version}[/bold]."
                )
            sys.exit(0)

    # BRANCH: update-version or bump
    current_version = None
    new_version_str = None

    if args.update_version:
        new_version_str = args.update_version
        console.print(
            f"[bold blue]Updating versions to {new_version_str} in {root_dir}...[/bold blue]"
        )
    elif args.bump:
        # Get current version
        current_version = get_current_version(checks)
        if not current_version:
            # get_current_version likely printed why
            sys.exit(1)

        console.print(f"[bold blue]Current version: {current_version}[/bold blue]")

        # Calculate new version
        try:
            new_version_str = bump_version(current_version, args.bump)
        except ValueError as e:
            console.print(f"[red]Error: {e}[/red]")
            sys.exit(1)

        # Show version diff visualization
        show_version_diff(current_version, new_version_str)

        # Validate version progression
        validate_version_progression(current_version, new_version_str, args.bump)

        # Confirm upgrade
        if args.dry_run:
            console.print(
                f"\n[bold yellow]DRY RUN:[/bold yellow] Would upgrade from {current_version} to {new_version_str}"
            )
            confirmed = True
        elif args.confirm:
            confirmed = True
        else:
            confirmed = Confirm.ask(
                f"\n[bold]Do you want to upgrade from [cyan]{current_version}[/cyan] to [green]{new_version_str}[/green]?[/bold]",
                default=True,
            )

        if not confirmed:
            console.print("[yellow]Upgrade cancelled.[/yellow]")
            sys.exit(0)

        console.print(
            f"\n[bold blue]Upgrading version from {current_version} to {new_version_str}...[/bold blue]"
        )

    # APPLY UPDATES
    updated_files = []
    updated_file_paths = []
    failed = False

    for check in checks:
        if check.check_file_exists():
            try:
                if args.dry_run:
                    curr = check.get_version()
                    console.print(
                        f"[cyan]Would update[/cyan] {check.name}: {curr} → {new_version_str}"
                    )
                else:
                    check.update_version(new_version_str)
                    console.print(f"[green]Updated[/green] {check.name}")
                updated_files.append(check.name)
                updated_file_paths.append(str(check.file_path))
            except Exception as e:
                console.print(f"[red]Failed to update {check.name}: {e}[/red]")
                if not args.dry_run:
                    failed = True
        else:
            console.print(f"[yellow]Skipping[/yellow] {check.name} (not found)")

    if failed:
        sys.exit(1)

    if args.output_format == "json":
        res_json = {
            "previous_version": current_version,
            "new_version": new_version_str,
            "updated_files": updated_files,
            "dry_run": args.dry_run,
        }
        print(json.dumps(res_json, indent=2))

    elif args.short:
        print(new_version_str)

    if args.dry_run:
        console.print(
            "\n[bold yellow]DRY RUN COMPLETE:[/bold yellow] No files were modified."
        )
        sys.exit(0)
    else:
        if not args.short and args.output_format == "text":
            console.print(
                f"\n[bold green]SUCCESS:[/bold green] Version updated to {new_version_str}."
            )

        # Git operations
        committed = False
        if args.git_commit or (not args.confirm and not args.dry_run):
            committed = git_commit_version(
                root_dir, new_version_str, updated_file_paths, args.confirm
            )

        if args.git_tag or (not args.confirm and not args.dry_run):
            if args.git_tag or committed:
                git_tag_version(root_dir, new_version_str, args.confirm)


if __name__ == "__main__":
    main()
