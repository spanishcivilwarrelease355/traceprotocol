# Contributing to TraceProtocol

Thank you for considering contributing to TraceProtocol! This document provides guidelines and instructions for contributing.

## 🤝 How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:

1. **Clear title** - Describe the issue briefly
2. **Description** - Detailed explanation of the bug
3. **Steps to reproduce** - How to recreate the issue
4. **Expected behavior** - What should happen
5. **Actual behavior** - What actually happens
6. **Environment** - OS version, system details
7. **Logs** - Relevant log files from `logs/` directory

### Suggesting Features

Feature requests are welcome! Please include:

1. **Use case** - Why is this feature needed?
2. **Description** - What should it do?
3. **Implementation ideas** - How could it work?
4. **Alternatives** - Other solutions you've considered

### Pull Requests

1. **Fork** the repository
2. **Create a branch** - `git checkout -b feature/YourFeature`
3. **Make changes** - Follow coding standards
4. **Test** - Ensure everything works
5. **Commit** - Use clear commit messages
6. **Push** - `git push origin feature/YourFeature`
7. **Open PR** - Describe your changes

## 📝 Coding Standards

### Bash Scripts

- Use `#!/bin/bash` shebang
- Include comments for complex logic
- Use meaningful variable names
- Add error handling with `set -e` where appropriate
- Follow existing code style

### Example:

```bash
#!/bin/bash

# Function to check service status
check_service() {
    local service=$1
    
    if systemctl is-active --quiet "$service"; then
        echo "Service $service is running"
        return 0
    else
        echo "Service $service is not running"
        return 1
    fi
}
```

### Documentation

- Keep README.md updated
- Add comments to complex functions
- Update help messages in scripts
- Include usage examples

## 🧪 Testing

Before submitting a PR:

1. Test installation on fresh system (VM recommended)
2. Test all commands in `privacy-manager.sh`
3. Verify monitor output is accurate
4. Check for errors in log files
5. Test on different distributions if possible

## 🎯 Priority Areas

Help is especially welcome in:

- **Cross-platform support** - Testing on different Linux distributions
- **Error handling** - Improving robustness
- **Documentation** - Improving guides and examples
- **Features** - Additional privacy tools integration
- **UI/UX** - Better terminal output and user experience
- **Automation** - Systemd services, auto-connect, etc.

## 📋 Commit Message Guidelines

Use clear, descriptive commit messages:

- `feat: Add live monitoring mode`
- `fix: Correct VPN status check`
- `docs: Update installation instructions`
- `refactor: Simplify monitor output`
- `test: Add installation tests`

## 🔍 Code Review

All submissions require review. We will:

- Check code quality and style
- Test functionality
- Review security implications
- Provide constructive feedback

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## ❓ Questions

Have questions? Feel free to:

- Open an issue
- Start a discussion
- Contact maintainers

## 🙏 Recognition

Contributors will be acknowledged in:

- README.md
- Release notes
- GitHub contributors page

Thank you for helping make TraceProtocol better! 🔒

