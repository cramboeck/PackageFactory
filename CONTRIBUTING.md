# Contributing to PackageFactory

Thank you for your interest in contributing to PackageFactory! This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct (see CODE_OF_CONDUCT.md).

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Environment details** (OS, PowerShell version, etc.)
- **Error messages and logs**
- **Screenshots** (if applicable)

Use the bug report template when creating issues.

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide detailed description** of the proposed feature
- **Explain why this enhancement would be useful**
- **List any alternative solutions** you've considered

Use the feature request template when creating issues.

### Pull Requests

1. **Fork the repository** and create your branch from `dev`
   ```bash
   git checkout -b feature/my-new-feature dev
   ```

2. **Follow PowerShell best practices**
   - Use approved verbs for function names
   - Follow PascalCase naming convention
   - Add comment-based help to functions
   - Use `SupportsShouldProcess` for destructive operations

3. **Update documentation**
   - Update README.md if needed
   - Update function help
   - Add changelog entry

4. **Commit your changes**
   - Use clear, descriptive commit messages
   - Follow conventional commits format:
     ```
     feat: add new feature
     fix: resolve bug
     docs: update documentation
     test: add tests
     refactor: code refactoring
     ```

5. **Push to your fork** and submit a pull request to `dev` branch

## Development Setup

### Prerequisites

- PowerShell 5.1 or PowerShell 7.x
- Git
- Pester 5.x (for testing)
- PSScriptAnalyzer (for code analysis)

### Local Development

1. Clone the repository
   ```bash
   git clone https://github.com/cramboeck/PackageFactory.git
   cd PackageFactory
   ```

2. Import the module
   ```powershell
   Import-Module ./src/PackageFactory.psd1 -Force
   ```

3. Make your changes in the `src/` directory

4. Test your changes manually with the web server or cmdlets

## Project Structure

```
PackageFactory/
├── src/                    # Module source code
│   ├── Public/            # Exported functions
│   ├── Private/           # Internal functions
│   ├── PackageFactory.psd1  # Module manifest
│   └── PackageFactory.psm1  # Module loader
├── WebServer/             # Pode web server
├── Generator/             # Templates
└── Config/                # Configuration files
```

## Coding Standards

### PowerShell Style Guide

- Use 4 spaces for indentation (no tabs)
- Maximum line length: 120 characters
- Always use full cmdlet names (no aliases) in scripts
- Use single quotes for strings unless interpolation is needed
- Add comment-based help to all public functions

### Function Template

```powershell
<#
.SYNOPSIS
    Brief description

.DESCRIPTION
    Detailed description

.PARAMETER ParameterName
    Parameter description

.EXAMPLE
    Example usage

.NOTES
    Author: Your Name
    Version: 1.0.0
#>
function Verb-Noun {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ParameterName
    )

    begin {
        # Initialization
    }

    process {
        # Main logic
    }

    end {
        # Cleanup
    }
}
```

## Testing

- Test manually with both Windows PowerShell 5.1 and PowerShell 7.x
- Test package creation with various applications
- Test web server functionality
- PackageFactory is Windows-specific

## Branch Strategy

- `main` - Production-ready code
- `dev` - Development branch (default)
- `feature/*` - Feature branches
- `bugfix/*` - Bug fix branches
- `hotfix/*` - Urgent production fixes

## Release Process

1. All changes merged to `dev` branch
2. Version bumped in manifest (src/PackageFactory.psd1)
3. CHANGELOG.md updated
4. Create release PR from `dev` to `main`
5. Tag release after merge
6. Create GitHub release with zip file

## Questions?

Feel free to open an issue for any questions or reach out to the maintainers:

- Email: c@ramboeck.it
- GitHub: [@cramboeck](https://github.com/cramboeck)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
