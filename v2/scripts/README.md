# jrl_release.py

Version management script for multi-format projects. Keeps version strings in sync across all tracked files and automates the release process.

## Usage

The tool can be invoked two equivalent ways:

```bash
# Installed console command — after `pip install .` / `uv tool install .`, or inside `uv run`
jrl-release [OPTIONS]

# Standalone, no install — runs the script directly via uv (PEP 723 inline deps)
uv run --no-project jrl_release.py [OPTIONS]
```

> The standalone form requires [`uv`](https://docs.astral.sh/uv/); it auto-installs dependencies from the script's inline metadata.

The examples below use the installed `jrl-release` form. If you haven't installed it, prefix-swap `jrl-release` → `uv run --no-project jrl_release.py`.

## Common Commands

```bash
# Check that all files agree on the current version
jrl-release --check-version

# Bump version
jrl-release --bump patch       # 1.0.0 -> 1.0.1
jrl-release --bump minor       # 1.0.0 -> 1.1.0
jrl-release --bump major       # 1.0.0 -> 2.0.0

# Set a specific version
jrl-release --update-version 1.2.3

# Bump, commit and tag in one step
jrl-release --bump patch --git-commit --git-tag
```

## Options

| Option | Description |
| :--- | :--- |
| `--root <PATH>` | Project root (default: cwd). |
| `--bump <major\|minor\|patch>` | Bump version component. |
| `--update-version <X.Y.Z>` | Set a specific version. |
| `--dry-run` | Show changes without writing files. |
| `--short` | Print only the version string. |
| `--output-format <text\|json>` | Output format (default: text). |
| `--confirm` | Skip interactive prompts. |
| `--list-files` | List tracked files. |
| `--git-commit [MSG]` | Commit changes. Optional message (`{version}` placeholder). |
| `--git-tag [NAME]` | Create a tag. Optional name (`{version}` placeholder). |
| `--git-tag-message <MSG>` | Tag annotation (`{version}` placeholder). |

**Git defaults**: commit `chore: bump version to {version}`, tag `v{version}`, tag message `Release version {version}`.

## Supported Files

| File | Key |
| :--- | :--- |
| `package.xml` | `<version>` tag |
| `pyproject.toml` | `project.version` |
| `CHANGELOG.md` | First `## [X.Y.Z]` section (not Unreleased) |
| `pixi.toml` | `[workspace] version` |
| `pixi.lock` | Regenerated via `pixi list` |
| `CITATION.cff` | `version` key |
| `CMakeLists.txt` | `project(... VERSION X.Y.Z ...)` |

> Requires `pixi` CLI if `pixi.lock` exists in the project root.

## Testing

The unit tests live in [`test_jrl_release.py`](test_jrl_release.py) and can be run two ways:

```bash
# Standalone (PEP 723 inline metadata, no install needed)
uv run --no-project test_jrl_release.py

# Via the project's test extra (from the repo root)
uv run --extra test pytest
```
