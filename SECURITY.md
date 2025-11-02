# Security Policy

## Supported Versions

We actively support the following versions of PackageFactory:

| Version | Supported          |
| ------- | ------------------ |
| 2.1.x   | :white_check_mark: |
| 2.0.x   | :white_check_mark: |
| < 2.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do Not Publicly Disclose

Please do not create public GitHub issues for security vulnerabilities.

### 2. Contact Us Privately

Send an email to: **c@ramboeck.it**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested fixes (optional)

### 3. Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depending on severity
  - Critical: 1-7 days
  - High: 1-4 weeks
  - Medium: 1-3 months
  - Low: Best effort

### 4. Disclosure Process

1. We confirm the vulnerability
2. We develop and test a fix
3. We prepare a security advisory
4. We release the fix
5. We publish the advisory

### 5. Credit

We will credit you in the security advisory unless you prefer to remain anonymous.

## Security Best Practices

### For Users

1. **Keep Updated**: Always use the latest version
2. **Review Code**: Inspect scripts before running in production
3. **Least Privilege**: Run with minimum required permissions
4. **Network Security**: Only expose web server on localhost unless absolutely necessary
5. **Validate Input**: Review all package parameters before creation

### For Developers

1. **Code Review**: All PRs require review before merge
2. **Dependency Updates**: Regular updates to dependencies (Pode, PSADT)
3. **Input Validation**: Validate and sanitize all user input
4. **Secure Defaults**: Default to most secure configuration
5. **Logging**: Log security-relevant events

## Known Security Considerations

### Web Server

- Default binding is localhost only (127.0.0.1)
- No authentication by design (local use only)
- Do not expose to network without proper authentication

### Script Execution

- PSAppDeployToolkit scripts run with SYSTEM privileges in Intune
- Review generated scripts before deployment
- Test in isolated environment first

### Pode Module

- Uses external dependency (Pode PowerShell module)
- Keep Pode updated to latest stable version
- Review Pode security advisories

## Security Features

- Input validation on all API endpoints
- Path traversal protection
- No eval() or Invoke-Expression on user input
- CMTrace formatted logging for audit trails
- SupportsShouldProcess for destructive operations

## Compliance

PackageFactory is designed for use in enterprise environments and follows:

- PowerShell best practices
- Secure coding guidelines
- Principle of least privilege

## Questions?

For security questions that are not vulnerabilities, please open a regular GitHub issue or contact c@ramboeck.it.
