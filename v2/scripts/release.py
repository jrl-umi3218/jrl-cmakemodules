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
    -   `pixi.lock` (Pixi lockfile - automatically updated via `pixi list`)
    -   `CITATION.cff` (Citation File Format)
    -   `CMakeLists.txt` (CMake)
-   **Version Checking**: Verifies that all tracked files share the same version number.
-   **Semantic Versioning**: Enforces SemVer (X.Y.Z) compliance.
-   **Automated Bumping**: Supports major, minor, and patch version bumps.
-   **Git Integration**: Option to automatically commit changes and create release tags using GitPython.
-   **Safe Checks**: Includes dry-run mode and version progression validation.
-   **Pixi Lock Update**: When updating versions, runs `pixi list` to regenerate `pixi.lock`. Requires `pixi` to be installed if a lock file exists.

## Prerequisites

The script lists its dependencies in the file header using [inline script metadata (PEP 723)](https://peps.python.org/pep-0723/). It is recommended to execute it using `uv` to handle dependencies automatically.

-   Python >= 3.9
-   Dependencies: `tomlkit`, `ruamel.yaml`, `rich`, `packaging`, `GitPython`, `cmake-parser`
-   Optional: `pixi` CLI tool (required if `pixi.lock` exists)

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
| `--git-commit [MESSAGE]` | Commit version changes. Optional custom message (use `{version}` placeholder). |
| `--git-tag [NAME]` | Create a git tag. Optional custom tag name (use `{version}` placeholder). |
| `--git-tag-message <MESSAGE>` | Custom git tag message. Use `{version}` as placeholder. |

### Git Integration

The script can automatically commit changes and tag the release using the local git configuration.

#### Default Behavior

-   **Default Commit Message**: `chore: bump version to {version}` (e.g., `chore: bump version to 1.2.3`)
-   **Default Tag Name**: `v{version}` (e.g., `v1.2.3`)
-   **Default Tag Message**: `Release version {version}` (e.g., `Release version 1.2.3`)

#### Examples

```bash
# Bump patch version, commit and tag with defaults
# Commit: "chore: bump version to 1.0.1"
# Tag: "v1.0.1" with message "Release version 1.0.1"
uv run --no-project release.py --bump patch --git-commit --git-tag

# Custom commit message
# Commit: "release: version 1.0.1"
uv run --no-project release.py --bump patch --git-commit "release: version {version}"

# Custom tag name (without 'v' prefix)
# Tag: "1.1.0" with default message "Release version 1.1.0"
uv run --no-project release.py --bump minor --git-tag "{version}"

# Custom tag name and message
# Tag: "1.1.0" with message "Version 1.1.0"
uv run --no-project release.py --bump minor --git-tag "{version}" --git-tag-message "Version {version}"

# Only commit, no tag
uv run --no-project release.py --bump patch --git-commit

# Only tag, no commit
uv run --no-project release.py --bump patch --git-tag
```

## Supported File Patterns

The script defines several `VersionExtractor` classes to handle specific file formats:

-   **package.xml**: Updates contents of `<version>X.Y.Z</version>`.
-   **pyproject.toml**: Updates `tool.poetry.version` or standard `project.version`.
-   **CHANGELOG.md**:
    -   Reads the first version that != "Unreleased".
    -   On update, replaces the `## [Unreleased]` header with `## [Unreleased]` followed by a new section `## [X.Y.Z] - YYYY-MM-DD`.
-   **pixi.toml**: Updates the `[workspace] version` key.
-   **pixi.lock**: Regenerated by running `pixi list`. Requires the `pixi` executable to be available.
-   **CITATION.cff**: Updates the top-level `version` key.
-   **CMakeLists.txt**: Scans for `project(... VERSION X.Y.Z ...)` using regex.
"""

import sys
import re
import argparse
import datetime
import json
import subprocess
import shutil
import tempfile
from pathlib import Path
from abc import ABC, abstractmethod
from typing import List, Optional, Tuple, Dict

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

STYLE_INFO = "bold blue"
STYLE_SUCCESS = "green"
STYLE_SUCCESS_STRONG = "bold green"
STYLE_WARNING = "yellow"
STYLE_WARNING_STRONG = "bold yellow"
STYLE_ERROR = "red"
STYLE_ERROR_STRONG = "bold red"
STYLE_MUTED = "dim"
STYLE_OLD_VALUE = "red"
STYLE_NEW_VALUE = "green"
STYLE_UNCHANGED_VALUE = "dim"
STYLE_HIGHLIGHT = "cyan"


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
                f"[{STYLE_WARNING}]Warning: Could not find '## [Unreleased]' in CHANGELOG.md. Skipping update.[/{STYLE_WARNING}]"
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
            f"[{STYLE_INFO}]Updated CHANGELOG.md header. Note: Link definitions at the bottom were not updated automatically.[/{STYLE_INFO}]"
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
    errors = []

    for check in checks:
        if check.check_file_exists():
            try:
                version = check.get_version()
                versions_found.add(version)
            except Exception as e:
                errors.append(f"{check.name}: {e}")

    # Report parsing errors
    if errors:
        console.print(
            f"[{STYLE_WARNING}]Warning: Failed to parse version from some files:[/{STYLE_WARNING}]"
        )
        for error in errors:
            console.print(f"  [{STYLE_MUTED}]• {error}[/{STYLE_MUTED}]")

    if len(versions_found) == 1:
        return list(versions_found)[0]
    elif len(versions_found) > 1:
        console.print(
            f"[{STYLE_ERROR}]Error: Multiple versions found: {', '.join(sorted(versions_found))}[/{STYLE_ERROR}]"
        )
        console.print(
            f"[{STYLE_WARNING}]Please run --check-version first to resolve conflicts.[/{STYLE_WARNING}]"
        )
        return None
    else:
        console.print(
            f"[{STYLE_ERROR}]Error: No version found in any files.[/{STYLE_ERROR}]"
        )
        return None


def infer_change_type(
    old_version: str, new_version: str, bump_type: Optional[str] = None
) -> str:
    """Infer change type label (major/minor/patch/custom)."""
    if bump_type in {"major", "minor", "patch"}:
        return bump_type

    try:
        old_major, old_minor, old_patch = parse_semver(old_version)
        new_major, new_minor, new_patch = parse_semver(new_version)
    except ValueError:
        return "custom"

    if new_major != old_major:
        return "major"
    if new_minor != old_minor:
        return "minor"
    if new_patch != old_patch:
        return "patch"
    return "no-change"


def show_version_diff(
    old_version: str, new_version: str, bump_type: Optional[str] = None
) -> None:
    """Display a visual diff between old and new versions."""
    old_parts = old_version.split(".")
    new_parts = new_version.split(".")

    # Build colored versions with highlights on changed parts
    old_colored_parts = []
    new_colored_parts = []

    for i, (old, new) in enumerate(zip(old_parts, new_parts)):
        if old != new:
            old_colored_parts.append(f"[{STYLE_OLD_VALUE}]{old}[/{STYLE_OLD_VALUE}]")
            new_colored_parts.append(f"[{STYLE_NEW_VALUE}]{new}[/{STYLE_NEW_VALUE}]")
        else:
            old_colored_parts.append(
                f"[{STYLE_UNCHANGED_VALUE}]{old}[/{STYLE_UNCHANGED_VALUE}]"
            )
            new_colored_parts.append(
                f"[{STYLE_UNCHANGED_VALUE}]{new}[/{STYLE_UNCHANGED_VALUE}]"
            )

    old_colored = ".".join(old_colored_parts)
    new_colored = ".".join(new_colored_parts)

    change_type = infer_change_type(old_version, new_version, bump_type)

    panel = Panel(
        f"[bold]{old_colored} → {new_colored}[/bold]",
        title=f"[{STYLE_WARNING_STRONG}]Version Change ({change_type})[/{STYLE_WARNING_STRONG}]",
        border_style=STYLE_WARNING,
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
        console.print(
            f"[{STYLE_WARNING_STRONG}]⚠ Version Progression Warnings:[/{STYLE_WARNING_STRONG}]"
        )
        for warning in warnings:
            console.print(f"  [{STYLE_WARNING}]• {warning}[/{STYLE_WARNING}]")
        console.print()


def git_commit_version(
    root_dir: Path,
    version: str,
    files_to_commit: List[str],
    auto_confirm: bool,
    custom_message: Optional[str] = None,
) -> bool:
    """Commit version changes to git.

    Args:
        root_dir: Project root directory
        version: Version being committed
        files_to_commit: List of file paths to stage
        auto_confirm: Whether to skip confirmation prompts
        custom_message: Optional custom commit message (default: 'chore: bump version to {version}')
    """
    try:
        repo = Repo(root_dir, search_parent_directories=True)
    except exc.InvalidGitRepositoryError:
        console.print(
            f"[{STYLE_WARNING}]Not a git repository, skipping git commit.[/{STYLE_WARNING}]"
        )
        return False

    if not repo.is_dirty():
        console.print(f"[{STYLE_WARNING}]No changes to commit.[/{STYLE_WARNING}]")
        return False

    # Use custom message if provided, otherwise use default
    if custom_message:
        # Replace {version} placeholder if present
        commit_message = custom_message.format(version=version)
    else:
        commit_message = f"chore: bump version to {version}"

    if not auto_confirm:
        confirmed = Confirm.ask(
            f"[bold]Commit changes with message: '{commit_message}'?[/bold]",
            default=True,
        )
        if not confirmed:
            console.print(f"[{STYLE_WARNING}]Git commit skipped.[/{STYLE_WARNING}]")
            return False

    # Add all version files
    try:
        console.print(
            f"[{STYLE_MUTED}]$ git add {' '.join(files_to_commit)}[/{STYLE_MUTED}]"
        )
        repo.git.add(files_to_commit)
    except exc.GitCommandError as e:
        console.print(f"[{STYLE_ERROR}]Failed to stage changes: {e}[/{STYLE_ERROR}]")
        return False

    # Commit
    try:
        # Use git command to trigger hooks
        console.print(
            f"[{STYLE_MUTED}]$ git commit -m '{commit_message}'[/{STYLE_MUTED}]"
        )
        repo.git.commit("-m", commit_message)
        console.print(
            f"[{STYLE_SUCCESS}]✓ Committed changes: {commit_message}[/{STYLE_SUCCESS}]"
        )
        return True
    except exc.GitCommandError as e:
        # Check if pre-commit hooks failed (often they modify files)
        if (root_dir / ".pre-commit-config.yaml").exists():
            console.print(
                f"[{STYLE_WARNING}]Commit failed or hooks triggered. Attempting to re-stage and commit...[/{STYLE_WARNING}]"
            )
            try:
                # Re-stage any changes made by hooks (e.g. formatting)
                console.print(
                    f"[{STYLE_MUTED}]$ git add {' '.join(files_to_commit)}[/{STYLE_MUTED}]"
                )
                repo.git.add(files_to_commit)
                # Try commit again
                console.print(
                    f"[{STYLE_MUTED}]$ git commit -m '{commit_message}'[/{STYLE_MUTED}]"
                )
                repo.git.commit("-m", commit_message)
                console.print(
                    f"[{STYLE_SUCCESS}]✓ Committed changes after hook updates: {commit_message}[/{STYLE_SUCCESS}]"
                )
                return True
            except exc.GitCommandError as e2:
                console.print(
                    f"[{STYLE_ERROR}]Failed to commit after retry: {e2}[/{STYLE_ERROR}]"
                )
                return False

        console.print(f"[{STYLE_ERROR}]Failed to commit: {e}[/{STYLE_ERROR}]")
        return False


def git_tag_version(
    root_dir: Path,
    version: str,
    auto_confirm: bool,
    custom_tag_name: Optional[str] = None,
    custom_tag_message: Optional[str] = None,
) -> bool:
    """Create a git tag for the version.

    Args:
        root_dir: Project root directory
        version: Version being tagged
        auto_confirm: Whether to skip confirmation prompts
        custom_tag_name: Optional custom tag name (default: 'v{version}')
        custom_tag_message: Optional custom tag message (default: 'Release version {version}')
    """
    try:
        repo = Repo(root_dir, search_parent_directories=True)
    except exc.InvalidGitRepositoryError:
        console.print(
            f"[{STYLE_WARNING}]Not a git repository, skipping git tag.[/{STYLE_WARNING}]"
        )
        return False

    # Use custom tag name if provided, otherwise use default
    if custom_tag_name:
        tag_name = custom_tag_name.format(version=version)
    else:
        tag_name = f"v{version}"

    # Use custom tag message if provided, otherwise use default
    if custom_tag_message:
        tag_message = custom_tag_message.format(version=version)
    else:
        tag_message = f"Release version {version}"

    # Check if tag already exists
    if tag_name in repo.tags:
        console.print(
            f"[{STYLE_WARNING}]Tag {tag_name} already exists.[/{STYLE_WARNING}]"
        )
        return False

    if not auto_confirm:
        confirmed = Confirm.ask(
            f"[bold]Create git tag '{tag_name}'?[/bold]", default=True
        )
        if not confirmed:
            console.print(f"[{STYLE_WARNING}]Git tag skipped.[/{STYLE_WARNING}]")
            return False

    # Create annotated tag
    try:
        console.print(
            f"[{STYLE_MUTED}]$ git tag -a {tag_name} -m '{tag_message}'[/{STYLE_MUTED}]"
        )
        repo.create_tag(tag_name, message=tag_message)
        console.print(f"[{STYLE_SUCCESS}]✓ Created tag: {tag_name}[/{STYLE_SUCCESS}]")
        console.print(
            f"[{STYLE_MUTED}]  To push: git push origin {tag_name}[/{STYLE_MUTED}]"
        )
        return True
    except exc.GitCommandError as e:
        console.print(f"[{STYLE_ERROR}]Failed to create tag: {e}[/{STYLE_ERROR}]")
        return False


def update_pixi_lock(
    root_dir: Path, target_version: str, dry_run: bool = False
) -> Optional[str]:
    """Update pixi.lock file by running 'pixi list'.

    Returns the path to pixi.lock if updated, None otherwise.
    """
    pixi_lock_path = root_dir / "pixi.lock"

    # Check if pixi.lock exists
    if not pixi_lock_path.exists():
        return None

    if dry_run:
        console.print(
            f"[{STYLE_HIGHLIGHT}]Would run 'pixi list' to update pixi.lock[/{STYLE_HIGHLIGHT}]"
        )
        return None

    # Run 'pixi list' to update the lock file
    # This is REQUIRED if pixi.lock exists
    try:
        console.print(
            f"[{STYLE_INFO}]Running 'pixi list' to update pixi.lock...[/{STYLE_INFO}]"
        )
        result = subprocess.run(
            ["pixi", "list"],
            cwd=root_dir,
            capture_output=True,
            text=True,
            timeout=30,
        )

        if result.returncode != 0:
            console.print(
                f"[{STYLE_ERROR}]Error: 'pixi list' returned non-zero exit code: {result.returncode}[/{STYLE_ERROR}]"
            )
            if result.stderr:
                console.print(
                    f"[{STYLE_MUTED}]stderr: {result.stderr.strip()}[/{STYLE_MUTED}]"
                )
            console.print(
                f"[{STYLE_ERROR}]Failed to update pixi.lock. Please ensure 'pixi' is installed.[/{STYLE_ERROR}]"
            )
            raise RuntimeError(f"'pixi list' failed with exit code {result.returncode}")

    except subprocess.TimeoutExpired:
        console.print(
            f"[{STYLE_ERROR}]Error: 'pixi list' command timed out[/{STYLE_ERROR}]"
        )
        raise RuntimeError("'pixi list' command timed out after 30 seconds")
    except FileNotFoundError:
        console.print(f"[{STYLE_ERROR}]Error: 'pixi' command not found[/{STYLE_ERROR}]")
        console.print(
            f"[{STYLE_ERROR}]pixi.lock exists but 'pixi' executable is not available.[/{STYLE_ERROR}]"
        )
        console.print(
            f"[{STYLE_INFO}]Please install pixi: https://pixi.sh[/{STYLE_INFO}]"
        )
        raise RuntimeError("'pixi' executable not found. Install from https://pixi.sh")
    except Exception as e:
        console.print(
            f"[{STYLE_ERROR}]Error: Failed to run 'pixi list': {e}[/{STYLE_ERROR}]"
        )
        raise RuntimeError(f"Failed to run 'pixi list': {e}") from e

    console.print(
        f"[{STYLE_SUCCESS}]✓ Updated pixi.lock via 'pixi list'[/{STYLE_SUCCESS}]"
    )

    return str(pixi_lock_path)


def create_backups(file_paths: List[Path]) -> Dict[Path, Path]:
    """Create backup copies of files in a temporary directory.

    Returns a mapping of original paths to backup paths.
    """
    backups = {}
    temp_dir = Path(tempfile.mkdtemp(prefix="release_backup_"))

    for file_path in file_paths:
        if file_path.exists():
            backup_path = temp_dir / file_path.name
            shutil.copy2(file_path, backup_path)
            backups[file_path] = backup_path

    return backups


def restore_backups(backups: Dict[Path, Path]) -> None:
    """Restore files from backups and cleanup temporary directory."""
    if not backups:
        return

    # Get temp directory from first backup
    temp_dir = None
    for original_path, backup_path in backups.items():
        if backup_path.exists():
            shutil.copy2(backup_path, original_path)
            temp_dir = backup_path.parent

    # Clean up temp directory
    if temp_dir and temp_dir.exists():
        shutil.rmtree(temp_dir)


def cleanup_backups(backups: Dict[Path, Path]) -> None:
    """Remove backup files without restoring."""
    if not backups:
        return

    # Get temp directory from first backup
    temp_dir = None
    for backup_path in backups.values():
        temp_dir = backup_path.parent
        break

    # Clean up temp directory
    if temp_dir and temp_dir.exists():
        shutil.rmtree(temp_dir)


def list_version_files(checks: List[VersionExtractor]) -> None:
    """List all files that are checked for versions."""
    table = Table(title="Version Files", box=box.ROUNDED)
    table.add_column("File", style="cyan")
    table.add_column("Path", style="dim")
    table.add_column("Exists", justify="center")
    table.add_column("Type", style="magenta")

    for check in checks:
        exists = (
            f"[{STYLE_SUCCESS}]✓[/{STYLE_SUCCESS}]"
            if check.check_file_exists()
            else f"[{STYLE_ERROR}]✗[/{STYLE_ERROR}]"
        )
        file_type = check.__class__.__name__.replace("VersionExtractor", "")
        table.add_row(check.name, str(check.file_path), exists, file_type)

    console.print(table)
    sys.exit(0)


def handle_check_version(checks: List[VersionExtractor], args) -> int:
    """Handle the --check-version command.

    Returns the exit code.
    """
    results = []
    versions_found = set()
    errors = False

    if not args.short:
        console.print(
            f"[{STYLE_INFO}]Checking versions in {args.root}...[/{STYLE_INFO}]"
        )

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
        return 1 if errors else 0

    # Standard Rich table output
    table = Table(title="Version Check Summary", box=box.ROUNDED)
    table.add_column("File", style="cyan")
    table.add_column("Version", style="magenta")
    table.add_column("Status", justify="center")
    table.add_column("Details")

    for res in results:
        status_style = res["status"]
        if res["status"] == "Found":
            status_style = f"[{STYLE_SUCCESS}]Found[/{STYLE_SUCCESS}]"
        elif res["status"] == "Missing":
            status_style = f"[{STYLE_WARNING}]Missing[/{STYLE_WARNING}]"
        elif res["status"] == "Error":
            status_style = f"[{STYLE_ERROR}]Error[/{STYLE_ERROR}]"

        version_display = res["version"] if res["version"] else "-"
        if res["version"]:
            if (
                consensus_version
                and consensus_version != "MISMATCH"
                and res["version"] == consensus_version
            ):
                version_display = f"[{STYLE_SUCCESS}]{res['version']}[/{STYLE_SUCCESS}]"
            elif consensus_version == "MISMATCH":
                version_display = f"[{STYLE_WARNING}]{res['version']}[/{STYLE_WARNING}]"

        table.add_row(res["file"], version_display, status_style, res["message"])

    if not args.short:
        console.print(table)

    if args.short and consensus_version and consensus_version != "MISMATCH":
        print(consensus_version)

    if errors:
        if len(versions_found) > 1:
            console.print(
                f"\n[{STYLE_ERROR_STRONG}]FAILURE:[/{STYLE_ERROR_STRONG}] Found conflicting versions: {', '.join(sorted(versions_found))}"
            )
        else:
            console.print(
                f"\n[{STYLE_ERROR_STRONG}]FAILURE:[/{STYLE_ERROR_STRONG}] Errors encountered (parsing errors)."
            )
        return 1
    elif not versions_found:
        console.print(
            f"\n[{STYLE_ERROR_STRONG}]FAILURE:[/{STYLE_ERROR_STRONG}] No version files found in {args.root}."
        )
        return 1
    else:
        if not args.short:
            console.print(
                f"\n[{STYLE_SUCCESS_STRONG}]SUCCESS:[/{STYLE_SUCCESS_STRONG}] All files match version [bold]{consensus_version}[/bold]."
            )
        return 0


def perform_version_updates(
    checks: List[VersionExtractor],
    target_version: str,
    dry_run: bool = False,
) -> Tuple[List[str], List[str], bool]:
    """Apply version updates to all files.

    Returns: (updated_files, updated_file_paths, failed)
    """
    updated_files = []
    updated_file_paths = []
    failed = False

    for check in checks:
        if check.check_file_exists():
            try:
                if dry_run:
                    curr = check.get_version()
                    console.print(
                        f"[{STYLE_HIGHLIGHT}]Would update[/{STYLE_HIGHLIGHT}] {check.name}: [{STYLE_OLD_VALUE}]{curr}[/{STYLE_OLD_VALUE}] → [{STYLE_NEW_VALUE}]{target_version}[/{STYLE_NEW_VALUE}]"
                    )
                else:
                    check.update_version(target_version)
                    console.print(
                        f"[{STYLE_SUCCESS}]Updated[/{STYLE_SUCCESS}] {check.name}"
                    )
                updated_files.append(check.name)
                updated_file_paths.append(str(check.file_path))
            except Exception as e:
                console.print(
                    f"[{STYLE_ERROR}]Failed to update {check.name}: {e}[/{STYLE_ERROR}]"
                )
                if not dry_run:
                    failed = True
        else:
            console.print(
                f"[{STYLE_WARNING}]Skipping[/{STYLE_WARNING}] {check.name} (not found)"
            )

    return updated_files, updated_file_paths, failed


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
        nargs="?",
        const=True,
        default=None,
        metavar="MESSAGE",
        help="Commit version changes to git. Optionally provide a custom commit message. Use {version} as placeholder. Default: 'chore: bump version to {version}'",
    )
    parser.add_argument(
        "--git-tag",
        nargs="?",
        const=True,
        default=None,
        metavar="NAME",
        help="Create a git tag for the new version. Optionally provide a custom tag name. Use {version} as placeholder. Default: 'v{version}'",
    )
    parser.add_argument(
        "--git-tag-message",
        type=str,
        default=None,
        metavar="MESSAGE",
        help="Custom git tag message. Use {version} as placeholder for version number. Default: 'Release version {version}'",
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
                    f"[{STYLE_ERROR}]Invalid SemVer '{args.update_version}'. strict X.Y.Z required.[/{STYLE_ERROR}]"
                )
                sys.exit(1)
        except Exception as e:
            console.print(
                f"[{STYLE_ERROR}]Error validating version: {e}[/{STYLE_ERROR}]"
            )
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
        sys.exit(handle_check_version(checks, args))

    # BRANCH: update-version or bump
    current_version = None
    new_version_str = None

    if args.update_version:
        new_version_str = args.update_version
        console.print(
            f"[{STYLE_INFO}]Updating versions to {new_version_str} in {root_dir}...[/{STYLE_INFO}]"
        )
    elif args.bump:
        # Get current version
        current_version = get_current_version(checks)
        if not current_version:
            # get_current_version likely printed why
            sys.exit(1)

        # Calculate new version
        try:
            new_version_str = bump_version(current_version, args.bump)
        except ValueError as e:
            console.print(f"[{STYLE_ERROR}]Error: {e}[/{STYLE_ERROR}]")
            sys.exit(1)

        # Show version diff visualization
        show_version_diff(current_version, new_version_str, args.bump)

        # Validate version progression
        validate_version_progression(current_version, new_version_str, args.bump)

        # Confirm upgrade
        if args.dry_run:
            console.print(
                f"\n[{STYLE_WARNING_STRONG}]DRY RUN:[/{STYLE_WARNING_STRONG}] Would upgrade from [{STYLE_OLD_VALUE}]{current_version}[/{STYLE_OLD_VALUE}] to [{STYLE_NEW_VALUE}]{new_version_str}[/{STYLE_NEW_VALUE}]"
            )
            confirmed = True
        elif args.confirm:
            confirmed = True
        else:
            confirmed = Confirm.ask(
                f"\n[bold]Do you want to upgrade from [{STYLE_INFO}]{current_version}[/{STYLE_INFO}] to [{STYLE_NEW_VALUE}]{new_version_str}[/{STYLE_NEW_VALUE}]?[/bold]",
                default=True,
            )

        if not confirmed:
            console.print(f"[{STYLE_WARNING}]Upgrade cancelled.[/{STYLE_WARNING}]")
            sys.exit(0)

        console.print(
            f"\n[{STYLE_INFO}]Upgrading version from {current_version} to {new_version_str}...[/{STYLE_INFO}]"
        )

    if new_version_str is None:
        console.print(
            f"[{STYLE_ERROR}]Internal error: target version is undefined.[/{STYLE_ERROR}]"
        )
        sys.exit(1)
    target_version: str = new_version_str

    # APPLY UPDATES with rollback support
    backups = {}
    if not args.dry_run:
        # Create backups before updating
        file_paths_to_backup = [
            check.file_path for check in checks if check.check_file_exists()
        ]
        backups = create_backups(file_paths_to_backup)
        console.print(
            f"[{STYLE_MUTED}]Created backups for {len(backups)} files[/{STYLE_MUTED}]"
        )

    try:
        updated_files, updated_file_paths, failed = perform_version_updates(
            checks, target_version, args.dry_run
        )

        if failed:
            if backups:
                console.print(
                    f"[{STYLE_WARNING}]Restoring files from backup due to failures...[/{STYLE_WARNING}]"
                )
                restore_backups(backups)
                console.print(
                    f"[{STYLE_SUCCESS}]Files restored from backup[/{STYLE_SUCCESS}]"
                )
            sys.exit(1)

        # Update pixi.lock if present - wrap in try/except
        try:
            pixi_lock_path = update_pixi_lock(root_dir, target_version, args.dry_run)
            if pixi_lock_path:
                updated_files.append("pixi.lock")
                updated_file_paths.append(pixi_lock_path)
        except RuntimeError as e:
            # Pixi update failed - restore backups
            console.print(
                f"[{STYLE_ERROR}]Pixi lock update failed: {e}[/{STYLE_ERROR}]"
            )
            if backups:
                console.print(
                    f"[{STYLE_WARNING}]Restoring files from backup...[/{STYLE_WARNING}]"
                )
                restore_backups(backups)
                console.print(
                    f"[{STYLE_SUCCESS}]Files restored from backup[/{STYLE_SUCCESS}]"
                )
            sys.exit(1)

        # Success - clean up backups
        if backups:
            cleanup_backups(backups)
    except Exception as e:
        # Unexpected error - restore backups
        console.print(f"[{STYLE_ERROR}]Unexpected error: {e}[/{STYLE_ERROR}]")
        if backups:
            console.print(
                f"[{STYLE_WARNING}]Restoring files from backup...[/{STYLE_WARNING}]"
            )
            restore_backups(backups)
            console.print(
                f"[{STYLE_SUCCESS}]Files restored from backup[/{STYLE_SUCCESS}]"
            )
        raise

    if args.output_format == "json":
        res_json = {
            "previous_version": current_version,
            "new_version": target_version,
            "updated_files": updated_files,
            "dry_run": args.dry_run,
        }
        print(json.dumps(res_json, indent=2))

    elif args.short:
        print(target_version)

    if args.dry_run:
        console.print(
            f"\n[{STYLE_WARNING_STRONG}]DRY RUN COMPLETE:[/{STYLE_WARNING_STRONG}] No files were modified."
        )
        sys.exit(0)
    else:
        if not args.short and args.output_format == "text":
            console.print(
                f"\n[{STYLE_SUCCESS_STRONG}]SUCCESS:[/{STYLE_SUCCESS_STRONG}] Version updated to {target_version}."
            )

        # Git operations - only perform if explicitly requested
        if args.git_commit is not None:
            # args.git_commit is True for default message, or a string for custom message
            custom_message = None if args.git_commit is True else args.git_commit
            git_commit_version(
                root_dir,
                target_version,
                updated_file_paths,
                args.confirm,
                custom_message,
            )

        if args.git_tag is not None:
            # args.git_tag is True for default tag name, or a string for custom tag name
            custom_tag_name = None if args.git_tag is True else args.git_tag
            git_tag_version(
                root_dir,
                target_version,
                args.confirm,
                custom_tag_name,
                args.git_tag_message,
            )


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        console.print(
            f"\n[{STYLE_WARNING}]Operation cancelled by user (Ctrl+C).[/{STYLE_WARNING}]"
        )
        sys.exit(130)
