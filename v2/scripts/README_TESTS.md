# Release Script Test Suite

Comprehensive unit tests for `release.py` - a utility script for managing project versions across multiple file formats.

## Overview

The test suite provides **83 tests** covering all functionality of the release script, including:

- ✅ All VersionExtractor classes (XML, TOML, YAML, Regex, Changelog)
- ✅ Validation functions (semver parsing, version bumping)
- ✅ Version checking and consensus validation
- ✅ Git integration (commits, tags) - fully mocked
- ✅ CLI argument parsing and workflows
- ✅ Edge cases and error handling

**All tests pass with 100% success rate.**

## Quick Start

### Run All Tests

```bash
uv run test_release.py
```

### Run with Verbose Output

```bash
uv run test_release.py -v
```

### Run Specific Test Categories

```bash
# Test all VersionExtractor classes
uv run test_release.py -k "extractor"

# Test only XML handling
uv run test_release.py -k "xml"

# Test git integration
uv run test_release.py -k "git"

# Test CLI workflows
uv run test_release.py -k "cli"

# Test validation functions
uv run test_release.py -k "semver or bump"
```

### Run with Coverage (optional)

If you want to see code coverage, add `pytest-cov` to the dependencies in `test_release.py` and run:

```bash
uv run test_release.py --cov=release --cov-report=term-missing
```

## Test Organization

### 1. VersionExtractor Classes (25 tests)

Tests for all file format parsers:

#### XmlVersionExtractor (6 tests)
- Reading/updating `package.xml` files
- Handling malformed XML
- Multiple version tags (only updates first)
- Structure preservation after updates

#### TomlVersionExtractor (6 tests)
- `pyproject.toml` (standard and Poetry formats)
- `pixi.toml` workspace files
- Nested key navigation
- Formatting preservation
- Missing key error handling

#### YamlVersionExtractor (4 tests)
- `CITATION.cff` files
- Nested key support
- Missing key detection
- Format preservation

#### RegexVersionExtractor (4 tests)
- `CMakeLists.txt` version extraction
- Multiline pattern matching
- Pattern not found errors
- Complex regex replacements

#### ChangelogVersionExtractor (5 tests)
- Keep a Changelog format parsing
- Finding first non-"Unreleased" version
- Inserting new version with date
- Handling missing "Unreleased" section
- Multiple version entries

### 2. Validation Functions (17 tests)

#### Semver Parsing
- Valid formats: `1.0.0`, `2.5.10`, `0.0.1`
- Invalid formats: `1.2`, `v1.2.3`, `1.2.3-alpha`, etc.
- Parametrized tests for comprehensive coverage

#### Version Bumping
- Major bumps: `1.0.0` → `2.0.0`
- Minor bumps: `1.0.0` → `1.1.0`
- Patch bumps: `1.0.0` → `1.0.1`
- Invalid bump type detection

#### Version Progression Validation
- Normal progression (no warnings)
- Backwards versions (detected)
- Skipped versions (detected)
- Wrong bump type applied (detected)

### 3. Version Checking Functions (6 tests)

- **Consensus validation**: All files have same version
- **Mismatch detection**: Files with different versions
- **Missing files**: Graceful handling
- **Partial files**: Some exist, some don't
- **Visual diff output**: Rich console formatting

### 4. Git Integration (9 tests - fully mocked)

All subprocess calls are mocked - no actual git operations:

#### `run_git_command()`
- Successful command execution
- Command failure (CalledProcessError)
- Git not found (FileNotFoundError)

#### `git_commit_version()`
- Successful commit
- Not in a git repository
- No changes to commit
- User cancellation

#### `git_tag_version()`
- Successful tag creation
- Tag already exists
- User cancellation

### 5. CLI Integration (25 tests)

Full end-to-end testing of command-line workflows:

#### Check Version
```bash
--check-version                  # All files match
--check-version --short          # Output: 1.0.0
--check-version --output-format json
```

#### List Files
```bash
--list-files
--list-files --output-format json
```

#### Update Version
```bash
--update-version 2.3.4           # Set specific version
--update-version invalid         # Error handling
```

#### Bump Version
```bash
--bump patch                     # 1.0.0 → 1.0.1
--bump minor                     # 1.0.0 → 1.1.0
--bump major                     # 1.0.0 → 2.0.0
--bump patch --confirm           # Auto-confirm
```

#### Dry Run
```bash
--bump patch --dry-run           # No files modified
```

#### Git Operations
```bash
--bump patch --git-commit --git-tag --confirm
```

#### Output Formats
```bash
--bump patch --short             # Output: 1.0.1
--bump patch --output-format json
```

## Test Features

### Self-Contained Execution

The test file uses **PEP 723 inline script metadata**, making it completely self-contained:

```python
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "pytest>=8.4.2",
#     "pytest-mock>=3.12.0",
#     "tomlkit",
#     "ruamel.yaml",
#     "rich",
#     "packaging",
# ]
# ///
```

No `pyproject.toml`, `requirements.txt`, or virtual environment setup required - `uv` handles everything automatically.

### Isolation and Safety

- **Temporary directories**: All file I/O uses pytest's `tmp_path` fixture
- **Mocked subprocess**: No actual git commands executed
- **No side effects**: Tests don't modify real files or repositories
- **Parallel-safe**: Each test has isolated fixtures

### Comprehensive Fixtures

Pre-built sample files for all supported formats:

- `sample_package_xml` - ROS package.xml
- `sample_pyproject_toml` - Python project metadata
- `sample_poetry_pyproject_toml` - Poetry format
- `sample_pixi_toml` - Pixi workspace
- `sample_citation_cff` - Citation File Format
- `sample_cmake_lists` - CMake project
- `sample_changelog` - Keep a Changelog format
- `malformed_xml` / `malformed_toml` - Error testing
- `project_dir` - Complete project with all files

### Parametrized Tests

Efficient testing of multiple scenarios with `@pytest.mark.parametrize`:

```python
@pytest.mark.parametrize("version,bump_type,expected", [
    ("1.0.0", "major", "2.0.0"),
    ("1.0.0", "minor", "1.1.0"),
    ("1.0.0", "patch", "1.0.1"),
    # ... more cases
])
def test_bump_version_valid(version, bump_type, expected):
    assert release.bump_version(version, bump_type) == expected
```

## Advanced Usage

### Run Specific Tests by Name

```bash
# Test only the XML extractor
uv run test_release.py::test_xml_extractor_get_version

# Test all TOML-related tests
uv run test_release.py -k toml

# Test validation functions
uv run test_release.py::test_parse_semver_valid
```

### Show Test Output

```bash
# Show print statements and captured output
uv run test_release.py -v -s

# Show only failed tests with full output
uv run test_release.py --tb=short

# Show one line per test
uv run test_release.py -q
```

### Stop on First Failure

```bash
uv run test_release.py -x
```

### Run Last Failed Tests

```bash
uv run test_release.py --lf
```

## Test Structure

```
v2/scripts/
├── release.py           # Main script being tested
├── test_release.py      # Test suite (83 tests)
└── README_TESTS.md      # This file
```

## Requirements

- **Python**: >=3.9
- **uv**: Package manager (handles dependencies automatically)
- **Dependencies** (auto-installed by uv):
  - pytest >= 8.4.2
  - pytest-mock >= 3.12.0
  - tomlkit
  - ruamel.yaml
  - rich
  - packaging

## Adding New Tests

To add tests for new functionality:

1. **Add fixtures** if testing new file formats:
   ```python
   @pytest.fixture
   def sample_new_format(tmp_path):
       content = "..."
       file_path = tmp_path / "file.ext"
       file_path.write_text(content)
       return file_path
   ```

2. **Add test functions** following naming conventions:
   ```python
   def test_new_feature():
       """Test description."""
       # Arrange
       # Act
       result = function_to_test()
       # Assert
       assert result == expected
   ```

3. **Use mocks** for external dependencies:
   ```python
   def test_with_mock(mocker):
       mock_function = mocker.patch("module.function")
       mock_function.return_value = "expected"
       # Test code
   ```

4. **Use parametrize** for testing multiple inputs:
   ```python
   @pytest.mark.parametrize("input,expected", [
       ("1.0.0", "result1"),
       ("2.0.0", "result2"),
   ])
   def test_multiple_cases(input, expected):
       assert function(input) == expected
   ```

## Coverage Goals

The test suite aims for:

- ✅ **100% of public functions** tested
- ✅ **All edge cases** covered (missing files, malformed input, errors)
- ✅ **All CLI workflows** validated end-to-end
- ✅ **All file formats** tested for read and write operations
- ✅ **Error handling** verified for all failure modes

## Continuous Integration

To integrate with CI/CD:

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: |
    cd v2/scripts
    uv run test_release.py --verbose
```

Or use pytest's JUnit XML output for reporting:

```bash
uv run test_release.py --junit-xml=test-results.xml
```

## Troubleshooting

### Tests fail with import errors

Make sure you're running from the correct directory:
```bash
cd jrl-cmakemodules\v2\scripts
uv run test_release.py
```

### Tests fail with "module not found"

The test file automatically adds the script directory to `sys.path`. If this fails, verify:
```python
sys.path.insert(0, str(Path(__file__).parent))
import release  # Should work
```

### Mock assertions fail

Ensure you're using `pytest-mock` (not just `unittest.mock`):
```python
def test_example(mocker):  # Note: mocker fixture
    mock = mocker.patch("module.function")
    # Test code
```

### Rich output contains ANSI codes

Tests handle ANSI escape codes by stripping them:
```python
ansi_escape = re.compile(r'\x1b\[[0-9;]*m')
clean_output = ansi_escape.sub('', captured.out)
assert "expected text" in clean_output
```

## Related Documentation

- [release.py documentation](release.py) - Main script docstring
- [pytest documentation](https://docs.pytest.org/) - Testing framework
- [pytest-mock documentation](https://pytest-mock.readthedocs.io/) - Mocking plugin

## License

Same as the parent jrl-cmakemodules project.
