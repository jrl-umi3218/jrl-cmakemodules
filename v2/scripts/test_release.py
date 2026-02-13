#!/usr/bin/env uv run --no-project
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "pytest>=8.4.2",
#     "pytest-mock>=3.12.0",
#     # The following dependencies must be kept in sync with release.py
#     "tomlkit",
#     "ruamel.yaml",
#     "rich",
#     "packaging",
#     "GitPython",
#     "cmake-parser",
# ]
# ///

"""
Comprehensive unit tests for release.py.

Run with:
    uv run test_release.py               # Run all tests
    uv run test_release.py -v            # Verbose output
    uv run test_release.py -k test_xml   # Run specific tests
"""

import sys
import re
import json
import subprocess
import argparse
from pathlib import Path
from io import StringIO
from datetime import date
from unittest.mock import Mock

import pytest
from rich.console import Console

# Import the module under test
sys.path.insert(0, str(Path(__file__).parent))
import release


# ============================================================================
# FIXTURES
# ============================================================================


@pytest.fixture
def sample_package_xml(tmp_path):
    """Create a sample package.xml file."""
    content = """<?xml version="1.0"?>
<package format="2">
  <name>test_package</name>
  <version>1.0.0</version>
  <description>Test package</description>
</package>"""
    file_path = tmp_path / "package.xml"
    file_path.write_text(content, encoding="utf-8")
    return file_path


@pytest.fixture
def sample_pyproject_toml(tmp_path):
    """Create a sample pyproject.toml file."""
    content = """[project]
name = "test-project"
version = "1.0.0"
description = "Test project"
"""
    file_path = tmp_path / "pyproject.toml"
    file_path.write_text(content, encoding="utf-8")
    return file_path


@pytest.fixture
def sample_poetry_pyproject_toml(tmp_path):
    """Create a sample pyproject.toml file with Poetry format."""
    content = """[tool.poetry]
name = "test-project"
version = "2.5.10"
description = "Test project with Poetry"
"""
    file_path = tmp_path / "pyproject.toml"
    file_path.write_text(content, encoding="utf-8")
    return file_path


@pytest.fixture
def sample_pixi_toml(tmp_path):
    """Create a sample pixi.toml file."""
    content = """[workspace]
version = "1.0.0"
name = "test-workspace"
"""
    file_path = tmp_path / "pixi.toml"
    file_path.write_text(content, encoding="utf-8")
    return file_path


@pytest.fixture
def sample_citation_cff(tmp_path):
    """Create a sample CITATION.cff file."""
    content = """cff-version: 1.2.0
title: "Test Project"
version: 1.0.0
date-released: "2024-01-01"
"""
    file_path = tmp_path / "CITATION.cff"
    file_path.write_text(content, encoding="utf-8")
    return file_path


@pytest.fixture
def sample_cmake_lists(tmp_path):
    """Create a sample CMakeLists.txt file."""
    content = """cmake_minimum_required(VERSION 3.10)
project(TestProject VERSION 1.0.0 DESCRIPTION "A test project")

add_library(testlib src/test.cpp)
"""
    file_path = tmp_path / "CMakeLists.txt"
    file_path.write_text(content, encoding="utf-8")
    return file_path


@pytest.fixture
def sample_changelog(tmp_path):
    """Create a sample CHANGELOG.md file."""
    content = """# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- New feature coming soon

## [1.0.0] - 2024-01-15

### Added
- Initial release
"""
    file_path = tmp_path / "CHANGELOG.md"
    file_path.write_text(content, encoding="utf-8")
    return file_path


@pytest.fixture
def malformed_xml(tmp_path):
    """Create a malformed XML file."""
    content = """<?xml version="1.0"?>
<package>
  <name>broken</name>
  <!-- Missing version tag -->
</package>"""
    file_path = tmp_path / "broken.xml"
    file_path.write_text(content, encoding="utf-8")
    return file_path


@pytest.fixture
def malformed_toml(tmp_path):
    """Create a malformed TOML file."""
    content = """[project
name = "broken"
# Missing closing bracket
"""
    file_path = tmp_path / "broken.toml"
    file_path.write_text(content, encoding="utf-8")
    return file_path


@pytest.fixture
def project_dir(
    tmp_path,
    sample_package_xml,
    sample_pyproject_toml,
    sample_pixi_toml,
    sample_citation_cff,
    sample_cmake_lists,
    sample_changelog,
):
    """Create a complete project directory with all version files."""
    # Files are already created in tmp_path by the fixtures
    return tmp_path


# ============================================================================
# TEST VersionExtractor Base Class
# ============================================================================


def test_version_extractor_properties(sample_package_xml):
    """Test VersionExtractor base properties."""
    extractor = release.XmlVersionExtractor(sample_package_xml)
    assert extractor.file_path == sample_package_xml
    assert extractor.name == "package.xml"
    assert extractor.path == str(sample_package_xml)


def test_version_extractor_file_exists(tmp_path):
    """Test check_file_exists method."""
    extractor = release.XmlVersionExtractor(tmp_path / "package.xml")
    assert not extractor.check_file_exists()

    # Create the file
    (tmp_path / "package.xml").write_text("<version>1.0.0</version>")
    assert extractor.check_file_exists()


# ============================================================================
# TEST XmlVersionExtractor
# ============================================================================


def test_xml_extractor_get_version(sample_package_xml):
    """Test XmlVersionExtractor can read version."""
    extractor = release.XmlVersionExtractor(sample_package_xml)
    assert extractor.get_version() == "1.0.0"


def test_xml_extractor_update_version(sample_package_xml):
    """Test XmlVersionExtractor can update version."""
    extractor = release.XmlVersionExtractor(sample_package_xml)
    extractor.update_version("2.3.4")

    # Verify the update
    assert extractor.get_version() == "2.3.4"

    # Verify structure is preserved
    content = sample_package_xml.read_text(encoding="utf-8")
    assert "<name>test_package</name>" in content
    assert "<version>2.3.4</version>" in content


def test_xml_extractor_missing_version_tag(malformed_xml):
    """Test XmlVersionExtractor raises error for missing version tag."""
    extractor = release.XmlVersionExtractor(malformed_xml)
    with pytest.raises(ValueError, match="Could not find <version> tag"):
        extractor.get_version()


def test_xml_extractor_multiple_version_tags(tmp_path):
    """Test XmlVersionExtractor only updates first version tag."""
    content = """<?xml version="1.0"?>
<package>
  <version>1.0.0</version>
  <depends>
    <package version="0.5.0"/>
  </depends>
</package>"""
    file_path = tmp_path / "multi_version.xml"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.XmlVersionExtractor(file_path)
    extractor.update_version("2.0.0")

    updated_content = file_path.read_text(encoding="utf-8")
    assert "<version>2.0.0</version>" in updated_content
    assert '<package version="0.5.0"/>' in updated_content  # Should remain unchanged


# ============================================================================
# TEST TomlVersionExtractor
# ============================================================================


def test_toml_extractor_get_version(sample_pyproject_toml):
    """Test TomlVersionExtractor can read version from pyproject.toml."""
    extractor = release.TomlVersionExtractor(
        sample_pyproject_toml, ["project", "version"]
    )
    assert extractor.get_version() == "1.0.0"


def test_toml_extractor_poetry_format(sample_poetry_pyproject_toml):
    """Test TomlVersionExtractor with Poetry format."""
    extractor = release.TomlVersionExtractor(
        sample_poetry_pyproject_toml, ["tool", "poetry", "version"]
    )
    assert extractor.get_version() == "2.5.10"


def test_toml_extractor_update_version(sample_pyproject_toml):
    """Test TomlVersionExtractor can update version."""
    extractor = release.TomlVersionExtractor(
        sample_pyproject_toml, ["project", "version"]
    )
    extractor.update_version("3.1.4")

    assert extractor.get_version() == "3.1.4"

    # Verify structure is preserved
    content = sample_pyproject_toml.read_text(encoding="utf-8")
    assert 'name = "test-project"' in content


def test_toml_extractor_pixi_format(sample_pixi_toml):
    """Test TomlVersionExtractor with pixi.toml format."""
    extractor = release.TomlVersionExtractor(sample_pixi_toml, ["workspace", "version"])
    assert extractor.get_version() == "1.0.0"

    extractor.update_version("1.2.3")
    assert extractor.get_version() == "1.2.3"


def test_toml_extractor_missing_key(sample_pyproject_toml):
    """Test TomlVersionExtractor raises error for missing key."""
    extractor = release.TomlVersionExtractor(
        sample_pyproject_toml, ["nonexistent", "key"]
    )
    with pytest.raises(ValueError, match="Key 'nonexistent.key' not found"):
        extractor.get_version()


def test_toml_extractor_preserves_formatting(tmp_path):
    """Test TomlVersionExtractor preserves TOML formatting."""
    content = """# Comment preserved
[project]
name = "test"  # inline comment
version = "1.0.0"

[tool.other]
key = "value"
"""
    file_path = tmp_path / "formatted.toml"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.TomlVersionExtractor(file_path, ["project", "version"])
    extractor.update_version("2.0.0")

    updated = file_path.read_text(encoding="utf-8")
    assert "# Comment preserved" in updated
    assert "# inline comment" in updated
    assert 'version = "2.0.0"' in updated


# ============================================================================
# TEST YamlVersionExtractor
# ============================================================================


def test_yaml_extractor_get_version(sample_citation_cff):
    """Test YamlVersionExtractor can read version."""
    extractor = release.YamlVersionExtractor(sample_citation_cff, ["version"])
    assert extractor.get_version() == "1.0.0"


def test_yaml_extractor_update_version(sample_citation_cff):
    """Test YamlVersionExtractor can update version."""
    extractor = release.YamlVersionExtractor(sample_citation_cff, ["version"])
    extractor.update_version("2.1.0")

    assert extractor.get_version() == "2.1.0"

    # Verify other fields are preserved
    content = sample_citation_cff.read_text(encoding="utf-8")
    assert "cff-version: 1.2.0" in content
    assert 'title: "Test Project"' in content or "title: 'Test Project'" in content


def test_yaml_extractor_missing_key(sample_citation_cff):
    """Test YamlVersionExtractor raises error for missing key."""
    extractor = release.YamlVersionExtractor(sample_citation_cff, ["nonexistent"])
    with pytest.raises(ValueError, match="Key 'nonexistent' not found"):
        extractor.get_version()


def test_yaml_extractor_nested_key(tmp_path):
    """Test YamlVersionExtractor with nested keys."""
    content = """metadata:
  release:
    version: 3.2.1
"""
    file_path = tmp_path / "nested.yaml"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.YamlVersionExtractor(
        file_path, ["metadata", "release", "version"]
    )
    assert extractor.get_version() == "3.2.1"

    extractor.update_version("4.0.0")
    assert extractor.get_version() == "4.0.0"


# ============================================================================
# TEST RegexVersionExtractor
# ============================================================================


def test_regex_extractor_get_version(sample_cmake_lists):
    """Test RegexVersionExtractor can extract version from CMakeLists.txt."""
    pattern = r"project\s*\([^)]*VERSION\s+([\d.]+)"
    extractor = release.RegexVersionExtractor(sample_cmake_lists, pattern)
    assert extractor.get_version() == "1.0.0"


def test_regex_extractor_update_version(sample_cmake_lists):
    """Test RegexVersionExtractor can update version."""
    pattern = r"project\s*\([^)]*VERSION\s+([\d.]+)"
    extractor = release.RegexVersionExtractor(sample_cmake_lists, pattern)
    extractor.update_version("3.5.7")

    assert extractor.get_version() == "3.5.7"

    # Verify structure is preserved
    content = sample_cmake_lists.read_text(encoding="utf-8")
    assert "cmake_minimum_required" in content
    assert "add_library" in content
    assert 'DESCRIPTION "A test project"' in content


def test_regex_extractor_pattern_not_found(tmp_path):
    """Test RegexVersionExtractor raises error when pattern not found."""
    file_path = tmp_path / "no_match.txt"
    file_path.write_text("Nothing to match here\n")

    extractor = release.RegexVersionExtractor(file_path, r"VERSION\s+([\d.]+)")
    with pytest.raises(ValueError, match="Pattern not found"):
        extractor.get_version()


def test_regex_extractor_multiline_pattern(tmp_path):
    """Test RegexVersionExtractor with multiline CMake."""
    content = """cmake_minimum_required(VERSION 3.10)
project(
    MultiLineProject
    VERSION 2.3.4
    DESCRIPTION "Project with multiline declaration"
    LANGUAGES CXX
)
"""
    file_path = tmp_path / "multiline.cmake"
    file_path.write_text(content, encoding="utf-8")

    pattern = r"project\s*\([^)]*VERSION\s+([\d.]+)"
    extractor = release.RegexVersionExtractor(file_path, pattern)
    assert extractor.get_version() == "2.3.4"


# ============================================================================
# TEST CMakeListsVersionExtractor
# ============================================================================


def test_cmake_extractor_get_version_simple(sample_cmake_lists):
    """Test CMakeListsVersionExtractor can extract version from simple CMakeLists.txt."""
    extractor = release.CMakeListsVersionExtractor(sample_cmake_lists)
    assert extractor.get_version() == "1.0.0"


def test_cmake_extractor_get_version_multiline(tmp_path):
    """Test CMakeListsVersionExtractor with multiline project()."""
    content = """cmake_minimum_required(VERSION 3.22)

project(
  TestProject
  DESCRIPTION "JRL CMake utility toolbox"
  HOMEPAGE_URL "http://github.com/example/project"
  VERSION 2.5.10
  LANGUAGES CXX
)

add_library(testlib src/test.cpp)
"""
    file_path = tmp_path / "CMakeLists.txt"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.CMakeListsVersionExtractor(file_path)
    assert extractor.get_version() == "2.5.10"


def test_cmake_extractor_with_fallback_version(tmp_path):
    """Test CMakeListsVersionExtractor with PROJECT_VERSION variable and fallback."""
    content = """cmake_minimum_required(VERSION 3.22)

# Read version from package.xml if available
set(PROJECT_VERSION "3.1.4") # Default fallback version
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/package.xml")
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/package.xml" PACKAGE_XML_CONTENT)
  string(REGEX MATCH "<version>([0-9]+\\.[0-9]+\\.[0-9]+)</version>" _ "${PACKAGE_XML_CONTENT}")
  if(CMAKE_MATCH_1)
    set(PROJECT_VERSION "${CMAKE_MATCH_1}")
  endif()
endif()

project(
  TestProject
  DESCRIPTION "Test project"
  VERSION ${PROJECT_VERSION}
  LANGUAGES NONE
)
"""
    file_path = tmp_path / "CMakeLists.txt"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.CMakeListsVersionExtractor(file_path)
    # Should extract from the fallback set(PROJECT_VERSION "3.1.4")
    assert extractor.get_version() == "3.1.4"


def test_cmake_extractor_update_version_simple(sample_cmake_lists):
    """Test CMakeListsVersionExtractor can update version in simple CMakeLists.txt."""
    extractor = release.CMakeListsVersionExtractor(sample_cmake_lists)
    extractor.update_version("2.0.0")

    # Verify the update
    assert extractor.get_version() == "2.0.0"

    # Verify structure is preserved
    content = sample_cmake_lists.read_text(encoding="utf-8")
    assert "cmake_minimum_required" in content
    assert "add_library" in content
    assert 'DESCRIPTION "A test project"' in content


def test_cmake_extractor_update_version_multiline(tmp_path):
    """Test CMakeListsVersionExtractor can update version in multiline project()."""
    content = """cmake_minimum_required(VERSION 3.22)

project(
  TestProject
  DESCRIPTION "Test project"
  VERSION 1.0.0
  LANGUAGES CXX
)
"""
    file_path = tmp_path / "CMakeLists.txt"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.CMakeListsVersionExtractor(file_path)
    extractor.update_version("1.2.3")

    assert extractor.get_version() == "1.2.3"
    content = file_path.read_text(encoding="utf-8")
    assert "VERSION 1.2.3" in content


def test_cmake_extractor_update_fallback_version(tmp_path):
    """Test CMakeListsVersionExtractor updates both fallback and project version."""
    content = """cmake_minimum_required(VERSION 3.22)

set(PROJECT_VERSION "1.0.0")

project(
  TestProject
  VERSION ${PROJECT_VERSION}
  LANGUAGES NONE
)
"""
    file_path = tmp_path / "CMakeLists.txt"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.CMakeListsVersionExtractor(file_path)
    extractor.update_version("2.5.0")

    # Check that fallback was updated
    content = file_path.read_text(encoding="utf-8")
    assert 'set(PROJECT_VERSION "2.5.0")' in content


def test_cmake_extractor_no_version_found(tmp_path):
    """Test CMakeListsVersionExtractor raises error when no version found."""
    content = """cmake_minimum_required(VERSION 3.10)
project(TestProject DESCRIPTION "No version here")
"""
    file_path = tmp_path / "CMakeLists.txt"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.CMakeListsVersionExtractor(file_path)
    with pytest.raises(ValueError, match="No version found|Pattern not found"):
        extractor.get_version()


def test_cmake_extractor_preserves_structure(tmp_path):
    """Test CMakeListsVersionExtractor preserves file structure and formatting."""
    content = """# This is a comment
cmake_minimum_required(VERSION 3.22)

# Another comment
project(
  TestProject
  VERSION 1.5.2
  DESCRIPTION "Test"
  LANGUAGES CXX
)

# Build configuration
set(CMAKE_CXX_STANDARD 17)
add_library(mylib src/lib.cpp)
"""
    file_path = tmp_path / "CMakeLists.txt"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.CMakeListsVersionExtractor(file_path)
    extractor.update_version("1.5.3")

    content = file_path.read_text(encoding="utf-8")
    # Check comments are preserved
    assert "# This is a comment" in content
    assert "# Another comment" in content
    assert "# Build configuration" in content
    # Check other settings preserved
    assert "CMAKE_CXX_STANDARD" in content
    assert "add_library" in content
    # Check version updated
    assert "VERSION 1.5.3" in content


# ============================================================================
# TEST ChangelogVersionExtractor
# ============================================================================


def test_changelog_extractor_get_version(sample_changelog):
    """Test ChangelogVersionExtractor can read version."""
    extractor = release.ChangelogVersionExtractor(sample_changelog, "")
    assert extractor.get_version() == "1.0.0"


def test_changelog_extractor_update_version(sample_changelog, capsys):
    """Test ChangelogVersionExtractor can update version."""
    extractor = release.ChangelogVersionExtractor(sample_changelog, "")
    extractor.update_version("1.1.0")

    content = sample_changelog.read_text(encoding="utf-8")
    today = date.today().isoformat()

    # Should have both Unreleased and new version
    assert "## [Unreleased]" in content
    assert f"## [1.1.0] - {today}" in content
    assert "## [1.0.0] - 2024-01-15" in content

    # New version should be after Unreleased
    unreleased_idx = content.index("## [Unreleased]")
    new_version_idx = content.index(f"## [1.1.0] - {today}")
    assert unreleased_idx < new_version_idx


def test_changelog_extractor_no_unreleased(tmp_path, capsys):
    """Test ChangelogVersionExtractor with no Unreleased section."""
    content = """# Changelog

## [1.0.0] - 2024-01-01

Initial release
"""
    file_path = tmp_path / "CHANGELOG.md"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.ChangelogVersionExtractor(file_path, "")
    extractor.update_version("1.1.0")

    # Content should be unchanged
    assert file_path.read_text() == content


def test_changelog_extractor_no_released_version(tmp_path):
    """Test ChangelogVersionExtractor with only Unreleased."""
    content = """# Changelog

## [Unreleased]

- Some changes
"""
    file_path = tmp_path / "CHANGELOG.md"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.ChangelogVersionExtractor(file_path, "")
    with pytest.raises(ValueError, match="No released version found"):
        extractor.get_version()


def test_changelog_extractor_multiple_versions(tmp_path):
    """Test ChangelogVersionExtractor returns first non-Unreleased version."""
    content = """# Changelog

## [Unreleased]

## [2.0.0] - 2024-02-01

## [1.5.0] - 2024-01-15

## [1.0.0] - 2024-01-01
"""
    file_path = tmp_path / "CHANGELOG.md"
    file_path.write_text(content, encoding="utf-8")

    extractor = release.ChangelogVersionExtractor(file_path, "")
    # Should get the first non-Unreleased version
    assert extractor.get_version() == "2.0.0"


# ============================================================================
# TEST Validation Functions
# ============================================================================


@pytest.mark.parametrize(
    "version,expected",
    [
        ("1.0.0", (1, 0, 0)),
        ("2.5.10", (2, 5, 10)),
        ("0.0.1", (0, 0, 1)),
        ("999.888.777", (999, 888, 777)),
    ],
)
def test_parse_semver_valid(version, expected):
    """Test parsing valid semver strings."""
    assert release.parse_semver(version) == expected


@pytest.mark.parametrize(
    "invalid_version",
    [
        "1.2",
        "1.2.3.4",
        "v1.2.3",
        "1.2.a",
        "abc",
        "1.2.3-alpha",
        "1.2.3+build",
    ],
)
def test_parse_semver_invalid(invalid_version):
    """Test parsing invalid semver strings."""
    with pytest.raises(ValueError, match="Invalid semver format"):
        release.parse_semver(invalid_version)


@pytest.mark.parametrize(
    "version,bump_type,expected",
    [
        ("1.0.0", "major", "2.0.0"),
        ("1.0.0", "minor", "1.1.0"),
        ("1.0.0", "patch", "1.0.1"),
        ("2.5.10", "major", "3.0.0"),
        ("2.5.10", "minor", "2.6.0"),
        ("2.5.10", "patch", "2.5.11"),
        ("0.0.1", "patch", "0.0.2"),
    ],
)
def test_bump_version_valid(version, bump_type, expected):
    """Test version bumping."""
    assert release.bump_version(version, bump_type) == expected


def test_bump_version_invalid_type():
    """Test bump_version with invalid bump type."""
    with pytest.raises(ValueError, match="Invalid bump type"):
        release.bump_version("1.0.0", "invalid")


def test_validate_semver_valid():
    """Test validate_semver accepts valid versions."""
    assert release.validate_semver("1.2.3") == "1.2.3"


def test_validate_semver_invalid():
    """Test validate_semver rejects invalid versions."""
    with pytest.raises(argparse.ArgumentTypeError):
        release.validate_semver("invalid")


# ============================================================================
# TEST Version Checking Functions
# ============================================================================


def test_get_current_version_all_match(project_dir):
    """Test get_current_version when all files have same version."""
    checks = [
        release.XmlVersionExtractor(project_dir / "package.xml"),
        release.TomlVersionExtractor(
            project_dir / "pyproject.toml", ["project", "version"]
        ),
    ]

    version = release.get_current_version(checks)
    assert version == "1.0.0"


def test_get_current_version_mismatch(tmp_path, capsys):
    """Test get_current_version with version mismatch."""
    (tmp_path / "package.xml").write_text("<version>1.0.0</version>")
    (tmp_path / "pyproject.toml").write_text('[project]\nversion = "2.0.0"\n')

    checks = [
        release.XmlVersionExtractor(tmp_path / "package.xml"),
        release.TomlVersionExtractor(
            tmp_path / "pyproject.toml", ["project", "version"]
        ),
    ]

    version = release.get_current_version(checks)
    assert version is None


def test_get_current_version_no_files(tmp_path, capsys):
    """Test get_current_version when no files exist."""
    checks = [
        release.XmlVersionExtractor(tmp_path / "package.xml"),
        release.TomlVersionExtractor(
            tmp_path / "pyproject.toml", ["project", "version"]
        ),
    ]

    version = release.get_current_version(checks)
    assert version is None


def test_get_current_version_some_missing(tmp_path):
    """Test get_current_version when some files are missing."""
    (tmp_path / "package.xml").write_text("<version>3.2.1</version>")
    # pyproject.toml doesn't exist

    checks = [
        release.XmlVersionExtractor(tmp_path / "package.xml"),
        release.TomlVersionExtractor(
            tmp_path / "pyproject.toml", ["project", "version"]
        ),
    ]

    version = release.get_current_version(checks)
    assert version == "3.2.1"


def test_show_version_diff_capture_output():
    """Test show_version_diff produces output."""
    string_io = StringIO()
    test_console = Console(file=string_io)

    # Temporarily replace global console
    old_console = release.console
    release.console = test_console

    try:
        release.show_version_diff("1.2.3", "2.0.0")
        output = string_io.getvalue()

        assert "1.2.3" in output
        assert "2.0.0" in output
        assert "Version Change" in output
    finally:
        release.console = old_console


def test_validate_version_progression_normal():
    """Test validate_version_progression with normal progression."""
    # Should not raise or warn for normal progression
    release.validate_version_progression("1.0.0", "1.0.1", "patch")
    release.validate_version_progression("1.0.0", "1.1.0", "minor")
    release.validate_version_progression("1.0.0", "2.0.0", "major")


def test_validate_version_progression_backwards(capsys):
    """Test validate_version_progression with backwards version."""
    release.validate_version_progression("2.0.0", "1.0.0", "patch")
    captured = capsys.readouterr()
    assert "not greater than old version" in captured.out.lower()


def test_validate_version_progression_wrong_bump_type(capsys):
    """Test validate_version_progression with wrong bump type."""
    release.validate_version_progression("1.0.0", "2.0.0", "patch")
    captured = capsys.readouterr()
    assert "major version changed during patch bump" in captured.out.lower()


def test_validate_version_progression_skipped_versions(capsys):
    """Test validate_version_progression with skipped versions."""
    release.validate_version_progression("1.0.0", "1.0.5", "patch")
    captured = capsys.readouterr()
    assert "skipping versions" in captured.out.lower()


# ============================================================================
# TEST Git Integration Functions (Mocked)
# ============================================================================


def test_run_git_command_success(mocker):
    """Test run_git_command with successful execution."""
    mock_run = mocker.patch("subprocess.run")
    mock_run.return_value = Mock(stdout="success output", stderr="", returncode=0)

    success, output = release.run_git_command(["status"], Path("/fake/path"))

    assert success is True
    assert output == "success output"
    mock_run.assert_called_once()


def test_run_git_command_failure(mocker):
    """Test run_git_command with command failure."""
    mock_run = mocker.patch("subprocess.run")
    mock_run.side_effect = subprocess.CalledProcessError(
        1, ["git"], stderr="error message"
    )

    success, output = release.run_git_command(["status"], Path("/fake/path"))

    assert success is False
    assert output == "error message"


def test_run_git_command_not_found(mocker):
    """Test run_git_command when git is not found."""
    mock_run = mocker.patch("subprocess.run")
    mock_run.side_effect = FileNotFoundError()

    success, output = release.run_git_command(["status"], Path("/fake/path"))

    assert success is False
    assert output == "git command not found"


def test_git_commit_version_success(mocker, tmp_path, capsys):
    """Test git_commit_version with successful commit."""
    mock_run = mocker.patch("release.run_git_command")
    mock_run.side_effect = [
        (True, ""),  # rev-parse --git-dir
        (True, "M file.txt"),  # status --porcelain
        (True, ""),  # add -u
        (True, "commit successful"),  # commit
    ]

    result = release.git_commit_version(tmp_path, "1.2.3", auto_confirm=True)

    assert result is True
    captured = capsys.readouterr()
    assert "Committed changes" in captured.out


def test_git_commit_version_not_git_repo(mocker, tmp_path, capsys):
    """Test git_commit_version when not in a git repo."""
    mock_run = mocker.patch("release.run_git_command")
    mock_run.return_value = (False, "not a git repository")

    result = release.git_commit_version(tmp_path, "1.2.3", auto_confirm=True)

    assert result is False
    captured = capsys.readouterr()
    assert "Not a git repository" in captured.out


def test_git_commit_version_no_changes(mocker, tmp_path, capsys):
    """Test git_commit_version with no changes."""
    mock_run = mocker.patch("release.run_git_command")
    mock_run.side_effect = [
        (True, ""),  # rev-parse --git-dir
        (True, ""),  # status --porcelain (empty = no changes)
    ]

    result = release.git_commit_version(tmp_path, "1.2.3", auto_confirm=True)

    assert result is False
    captured = capsys.readouterr()
    assert "No changes to commit" in captured.out


def test_git_commit_version_user_cancels(mocker, tmp_path, capsys):
    """Test git_commit_version when user cancels."""
    mock_run = mocker.patch("release.run_git_command")
    mock_run.side_effect = [
        (True, ""),  # rev-parse --git-dir
        (True, "M file.txt"),  # status --porcelain
    ]
    mock_confirm = mocker.patch("rich.prompt.Confirm.ask")
    mock_confirm.return_value = False

    result = release.git_commit_version(tmp_path, "1.2.3", auto_confirm=False)

    assert result is False
    captured = capsys.readouterr()
    assert "skipped" in captured.out.lower()


def test_git_tag_version_success(mocker, tmp_path, capsys):
    """Test git_tag_version with successful tag creation."""
    mock_run = mocker.patch("release.run_git_command")
    mock_run.side_effect = [
        (True, ""),  # rev-parse --git-dir
        (False, ""),  # rev-parse v1.2.3 (tag doesn't exist)
        (True, "tag created"),  # tag -a
    ]

    result = release.git_tag_version(tmp_path, "1.2.3", auto_confirm=True)

    assert result is True
    captured = capsys.readouterr()
    # Output may contain ANSI escape codes - strip them before checking
    ansi_escape = re.compile(r"\x1b\[[0-9;]*m")
    clean_output = ansi_escape.sub("", captured.out)
    assert "v1.2.3" in clean_output


def test_git_tag_version_already_exists(mocker, tmp_path, capsys):
    """Test git_tag_version when tag already exists."""
    mock_run = mocker.patch("release.run_git_command")
    mock_run.side_effect = [
        (True, ""),  # rev-parse --git-dir
        (True, "abc123"),  # rev-parse v1.2.3 (tag exists)
    ]

    result = release.git_tag_version(tmp_path, "1.2.3", auto_confirm=True)

    assert result is False
    captured = capsys.readouterr()
    assert "already exists" in captured.out


def test_git_tag_version_user_cancels(mocker, tmp_path):
    """Test git_tag_version when user cancels."""
    mock_run = mocker.patch("release.run_git_command")
    mock_run.side_effect = [
        (True, ""),  # rev-parse --git-dir
        (False, ""),  # rev-parse v1.2.3 (tag doesn't exist)
    ]
    mock_confirm = mocker.patch("rich.prompt.Confirm.ask")
    mock_confirm.return_value = False

    result = release.git_tag_version(tmp_path, "1.2.3", auto_confirm=False)

    assert result is False


# ============================================================================
# TEST CLI Integration
# ============================================================================


def test_cli_check_version_success(project_dir, mocker, capsys):
    """Test CLI --check-version with all files matching."""
    mocker.patch(
        "sys.argv", ["release.py", "--root", str(project_dir), "--check-version"]
    )

    with pytest.raises(SystemExit) as exc_info:
        release.main()

    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "SUCCESS" in captured.out or "1.0.0" in captured.out


def test_cli_check_version_mismatch(tmp_path, mocker, capsys):
    """Test CLI --check-version with version mismatch."""
    (tmp_path / "package.xml").write_text("<version>1.0.0</version>")
    (tmp_path / "pyproject.toml").write_text('[project]\nversion = "2.0.0"\n')

    mocker.patch("sys.argv", ["release.py", "--root", str(tmp_path), "--check-version"])

    with pytest.raises(SystemExit) as exc_info:
        release.main()

    assert exc_info.value.code == 1


def test_cli_check_version_json_output(project_dir, mocker, capsys):
    """Test CLI --check-version with JSON output."""
    mocker.patch(
        "sys.argv",
        [
            "release.py",
            "--root",
            str(project_dir),
            "--check-version",
            "--output-format",
            "json",
        ],
    )

    with pytest.raises(SystemExit):
        release.main()

    captured = capsys.readouterr()
    data = json.loads(captured.out)
    assert data["consensus_version"] == "1.0.0"
    assert data["consistent"] is True


def test_cli_check_version_short_output(project_dir, mocker, capsys):
    """Test CLI --check-version with --short flag."""
    mocker.patch(
        "sys.argv",
        ["release.py", "--root", str(project_dir), "--check-version", "--short"],
    )

    with pytest.raises(SystemExit):
        release.main()

    captured = capsys.readouterr()
    assert captured.out.strip() == "1.0.0"


def test_cli_list_files(project_dir, mocker, capsys):
    """Test CLI --list-files."""
    mocker.patch("sys.argv", ["release.py", "--root", str(project_dir), "--list-files"])

    with pytest.raises(SystemExit) as exc_info:
        release.main()

    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "package.xml" in captured.out
    assert "pyproject.toml" in captured.out


def test_cli_list_files_json(project_dir, mocker, capsys):
    """Test CLI --list-files with JSON output."""
    mocker.patch(
        "sys.argv",
        [
            "release.py",
            "--root",
            str(project_dir),
            "--list-files",
            "--output-format",
            "json",
        ],
    )

    with pytest.raises(SystemExit):
        release.main()

    captured = capsys.readouterr()
    data = json.loads(captured.out)
    assert isinstance(data, list)
    assert any(f["name"] == "package.xml" for f in data)


def test_cli_update_version(project_dir, mocker, capsys):
    """Test CLI --update-version."""
    mocker.patch(
        "sys.argv",
        ["release.py", "--root", str(project_dir), "--update-version", "2.3.4"],
    )

    # main() may or may not raise SystemExit depending on the path
    try:
        release.main()
    except SystemExit as e:
        # If it does exit, ensure it's successful
        assert e.code == 0

    # Verify files were updated
    xml_content = (project_dir / "package.xml").read_text()
    assert "<version>2.3.4</version>" in xml_content


def test_cli_update_version_invalid_semver(project_dir, mocker, capsys):
    """Test CLI --update-version with invalid semver."""
    mocker.patch(
        "sys.argv",
        ["release.py", "--root", str(project_dir), "--update-version", "1.2"],
    )

    with pytest.raises(SystemExit) as exc_info:
        release.main()

    assert exc_info.value.code == 1


def test_cli_bump_patch(project_dir, mocker, capsys):
    """Test CLI --bump patch."""
    mock_confirm = mocker.patch("rich.prompt.Confirm.ask")
    mock_confirm.return_value = True

    mocker.patch(
        "sys.argv", ["release.py", "--root", str(project_dir), "--bump", "patch"]
    )

    release.main()

    # Verify version was bumped from 1.0.0 to 1.0.1
    xml_content = (project_dir / "package.xml").read_text()
    assert "<version>1.0.1</version>" in xml_content


def test_cli_bump_minor(project_dir, mocker):
    """Test CLI --bump minor."""
    mock_confirm = mocker.patch("rich.prompt.Confirm.ask")
    mock_confirm.return_value = True

    mocker.patch(
        "sys.argv", ["release.py", "--root", str(project_dir), "--bump", "minor"]
    )

    release.main()

    xml_content = (project_dir / "package.xml").read_text()
    assert "<version>1.1.0</version>" in xml_content


def test_cli_bump_major(project_dir, mocker):
    """Test CLI --bump major."""
    mock_confirm = mocker.patch("rich.prompt.Confirm.ask")
    mock_confirm.return_value = True

    mocker.patch(
        "sys.argv", ["release.py", "--root", str(project_dir), "--bump", "major"]
    )

    release.main()

    xml_content = (project_dir / "package.xml").read_text()
    assert "<version>2.0.0</version>" in xml_content


def test_cli_bump_with_auto_confirm(project_dir, mocker):
    """Test CLI --bump with --confirm flag."""
    mocker.patch(
        "sys.argv",
        ["release.py", "--root", str(project_dir), "--bump", "patch", "--confirm"],
    )

    release.main()

    xml_content = (project_dir / "package.xml").read_text()
    assert "<version>1.0.1</version>" in xml_content


def test_cli_bump_user_cancels(project_dir, mocker, capsys):
    """Test CLI --bump when user cancels."""
    mock_confirm = mocker.patch("rich.prompt.Confirm.ask")
    mock_confirm.return_value = False

    mocker.patch(
        "sys.argv", ["release.py", "--root", str(project_dir), "--bump", "patch"]
    )

    with pytest.raises(SystemExit) as exc_info:
        release.main()

    assert exc_info.value.code == 0

    # Version should not be changed
    xml_content = (project_dir / "package.xml").read_text()
    assert "<version>1.0.0</version>" in xml_content


def test_cli_dry_run(project_dir, mocker, capsys):
    """Test CLI --dry-run flag."""
    mocker.patch(
        "sys.argv",
        ["release.py", "--root", str(project_dir), "--bump", "patch", "--dry-run"],
    )

    with pytest.raises(SystemExit) as exc_info:
        release.main()

    assert exc_info.value.code == 0

    # Version should not be changed
    xml_content = (project_dir / "package.xml").read_text()
    assert "<version>1.0.0</version>" in xml_content

    captured = capsys.readouterr()
    assert "DRY RUN" in captured.out


def test_cli_git_commit_and_tag(project_dir, mocker, capsys):
    """Test CLI with --git-commit and --git-tag flags."""
    mock_run = mocker.patch("release.run_git_command")
    mock_run.side_effect = [
        (True, ""),  # rev-parse --git-dir (commit check)
        (True, "M file.txt"),  # status --porcelain
        (True, ""),  # add -u
        (True, "committed"),  # commit
        (True, ""),  # rev-parse --git-dir (tag check)
        (False, ""),  # rev-parse v1.0.1 (tag doesn't exist)
        (True, "tagged"),  # tag -a
    ]

    mocker.patch(
        "sys.argv",
        [
            "release.py",
            "--root",
            str(project_dir),
            "--bump",
            "patch",
            "--git-commit",
            "--git-tag",
            "--confirm",
        ],
    )

    release.main()

    captured = capsys.readouterr()
    assert "Committed changes" in captured.out
    assert "Created tag" in captured.out


def test_cli_short_output(project_dir, mocker, capsys):
    """Test CLI with --short flag."""
    mocker.patch(
        "sys.argv",
        [
            "release.py",
            "--root",
            str(project_dir),
            "--update-version",
            "3.2.1",
            "--short",
        ],
    )

    release.main()

    captured = capsys.readouterr()
    assert captured.out.strip() == "3.2.1"


def test_cli_json_output(project_dir, mocker, capsys):
    """Test CLI with --output-format json."""
    mocker.patch(
        "sys.argv",
        [
            "release.py",
            "--root",
            str(project_dir),
            "--update-version",
            "3.2.1",
            "--output-format",
            "json",
        ],
    )

    release.main()

    captured = capsys.readouterr()
    data = json.loads(captured.out)
    assert data["new_version"] == "3.2.1"
    assert data["previous_version"] is None  # Because we used --update-version
    assert "updated_files" in data


# ============================================================================
# TEST Helper Functions
# ============================================================================


def test_list_version_files_display(project_dir):
    """Test list_version_files displays table."""
    checks = [
        release.XmlVersionExtractor(project_dir / "package.xml"),
        release.TomlVersionExtractor(
            project_dir / "pyproject.toml", ["project", "version"]
        ),
    ]

    # Capture output using StringIO instead of capsys since function calls sys.exit
    string_io = StringIO()
    test_console = Console(file=string_io)
    old_console = release.console
    release.console = test_console

    try:
        with pytest.raises(SystemExit) as exc_info:
            release.list_version_files(checks)
        assert exc_info.value.code == 0

        output = string_io.getvalue()
        assert "package.xml" in output
        assert "pyproject.toml" in output
    finally:
        release.console = old_console


# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-v"]))
