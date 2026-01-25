# AI Assistant & Development Guidelines

**Birdhouse Vision: Raspberry Pi Motion-Triggered Bird Camera System**

Security-first development guide for public repository IoT project using PIR sensor → Image capture → AWS upload workflow.

---

## Quick Reference

**Project Type**: Public IoT repository - Raspberry Pi bird camera with AWS Rekognition  
**Tech Stack**: Python 3.9+, Raspberry Pi OS, picamera2, gpiozero, boto3, AWS S3/Rekognition  
**Security Priority**: ⚠️ No credentials in code - all AWS secrets in environment variables  
**Target Audience**: Hobbyists and makers - prioritize readability and documentation  
**Cost Awareness**: Stay within €0.30/month AWS budget (~300 images/month - see [docs/COSTS.md](docs/COSTS.md))

**Core Workflow**:
```
PIR Motion Sensor (GPIO) → Picamera2 Capture → Local Storage (microSD/SSD) 
    → Boto3 Upload → AWS S3 → Rekognition Analysis → Results Storage
```

---

## 1. ⚠️ Public Repository Security

**CRITICAL**: This is a **PUBLIC** repository. All code and documentation is visible to the world. Never commit sensitive data of any kind.

### Prohibited Content (Must Never Appear)

❌ **NEVER commit**:
- AWS account IDs, user IDs, or ARNs containing account numbers
- AWS Access Keys or Secret Keys (even if "revoked" or "example")
- AWS S3 bucket names (actual production buckets)
- AWS Rekognition collection IDs or resource ARNs
- Personal email addresses or phone numbers
- Home network details (IP addresses, WiFi SSIDs, router credentials)
- Location information (GPS coordinates, addresses)
- API keys or tokens from third-party services

### Credential Handling

❌ **WRONG** - Hardcoded credentials:
```python
# NEVER do this - credentials exposed in public GitHub repo
import boto3

s3_client = boto3.client(
    's3',
    aws_access_key_id='YOUR_AWS_ACCESS_KEY_ID_HERE',
    aws_secret_access_key='YOUR_AWS_SECRET_ACCESS_KEY_HERE',
    region_name='eu-north-1'
)
```

✅ **CORRECT** - Environment variables:
```python
# Use environment variables or IAM roles
import boto3
import os
from dotenv import load_dotenv

load_dotenv()  # Loads from .env file (gitignored)

# boto3 automatically uses:
# 1. Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
# 2. ~/.aws/credentials file
# 3. IAM instance role (if running on EC2)
s3_client = boto3.client('s3', region_name=os.getenv('AWS_REGION', 'eu-north-1'))
```

### Configuration Files

Always include `.gitignore` entries for:
```gitignore
# Secrets
.env
.env.local
*.pem
*.key
config/credentials.json

# Raspberry Pi specific
*.jpg
*.png
captures/
logs/*.log
__pycache__/
*.pyc
```

❌ **WRONG** - Exposing real identifiers:
```yaml
# config.yaml (committed to repo)
aws_s3_bucket: "birdhouse-prod-images-123456789012"
aws_account_id: "123456789012"
```

✅ **CORRECT** - Use placeholders and examples:
```yaml
# config.yaml.example (safe to commit)
aws_s3_bucket: "your-birdhouse-images-bucket"
aws_region: "eu-north-1"
rekognition_confidence_threshold: 80

# README.md instructions:
# Copy config.yaml.example to config.yaml and fill in your values
```

### Logging and Error Messages

Redact sensitive data from logs.

❌ **WRONG**:
```python
logger.info(f"Uploading to S3: s3://my-prod-bucket-123456/{filename}")
logger.debug(f"AWS credentials: {aws_access_key_id}")  # NEVER log credentials
```

✅ **CORRECT**:
```python
logger.info(f"Uploading {filename} to S3")
logger.debug(f"Using AWS region: {region}")
# Credentials should NEVER appear in logs
```

---

## 2. Project Architecture

### Technology Stack

- **Hardware Platform**: Raspberry Pi 4 (8GB for camera unit, 4GB for NAS unit)
- **Camera**: Picamera2 library for Camera Module 3 (still images only, no streaming)
- **Motion Detection**: HC-SR501 PIR sensor via GPIO
- **GPIO**: `gpiozero` for event-driven sensor handling
- **Cloud**: AWS S3 (storage) + Rekognition (bird species detection)
- **Service Management**: `systemd` for daemon management
- **Networking**: PoE Ethernet (see [docs/WIFI_VS_ETHERNET.md](docs/WIFI_VS_ETHERNET.md))

### Hardware Constraints

- **Resource-constrained**: ARM CPU, 4-8GB RAM (vs cloud instances)
- **Storage limits**: 32GB microSD + 1TB SSD (requires cleanup policies)
- **Power-efficient design**: Triggered captures only (no continuous streaming)
- **Network resilience**: Works offline, queues images for upload when connection available
- **Outdoor deployment**: Weatherproof enclosure, temperature extremes (-20°C to +40°C)

### Project Structure

```
src/
  capture/      # Camera control & image capture (picamera2)
  detection/    # Motion detection logic (gpiozero PIR sensor)
  upload/       # AWS S3/Rekognition integration (boto3)
scripts/        # Utility scripts (gallery generation)
docs/           # Documentation (HARDWARE, COSTS, SETUP, etc.)
.github/        # GitHub Actions workflows
```

---

## 3. GPIO PIR Sensor Integration

### ❌ WRONG: Blocking Poll Loop

```python
import RPi.GPIO as GPIO
import time

PIR_PIN = 17
GPIO.setmode(GPIO.BCM)
GPIO.setup(PIR_PIN, GPIO.IN)

while True:  # ❌ Blocks entire process, CPU intensive
    if GPIO.input(PIR_PIN):
        capture_image()
    time.sleep(0.1)  # ❌ Wastes CPU cycles
```

**Issues**: High CPU usage, blocks other tasks, no graceful shutdown

### ✅ CORRECT: Event-Driven GPIO with gpiozero

```python
from gpiozero import MotionSensor
from signal import pause
import logging

PIR_PIN = 17
pir = MotionSensor(PIR_PIN, threshold=0.5, queue_len=5)

def on_motion_detected():
    """Event handler for PIR trigger - runs in separate thread."""
    logging.info("Motion detected by PIR sensor")
    try:
        capture_and_queue_image()
    except Exception as e:
        logging.error(f"Capture failed: {e}")

pir.when_motion = on_motion_detected

logging.info("PIR sensor ready, waiting for motion...")
pause()  # ✅ Event-driven, low CPU usage
```

**Best Practices**:
- Use event callbacks (`when_motion`) instead of polling
- Implement debouncing with `queue_len` to avoid false triggers
- Handle exceptions in callback to prevent daemon crashes
- Log all sensor events for debugging

---

## 4. Picamera2 Still Image Capture

### ❌ WRONG: Reinitialize Camera Every Time

```python
def capture_image(output_path):
    # ❌ Camera initialization is slow (~2-3 seconds)
    picam2 = Picamera2()
    picam2.start()
    picam2.capture_file(output_path)
    picam2.stop()  # ❌ Resource leak if exception occurs
```

**Issues**: Slow captures (misses fast birds), potential resource leaks

### ✅ CORRECT: Persistent Camera with Context Manager

```python
from picamera2 import Picamera2
from datetime import datetime
import logging
from pathlib import Path

class BirdhouseCamera:
    """Persistent camera instance for fast triggered captures."""
    
    def __init__(self, storage_dir: Path):
        self.storage_dir = storage_dir
        self.camera = Picamera2()
        
        # Configure for high-quality still images
        config = self.camera.create_still_configuration(
            main={"size": (1920, 1080)},  # Full HD
            buffer_count=2
        )
        self.camera.configure(config)
        self.camera.start()
        logging.info("Camera initialized and ready")
    
    def capture(self) -> Path:
        """Capture single image, return path."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"bird_{timestamp}.jpg"
        output_path = self.storage_dir / filename
        
        self.camera.capture_file(str(output_path))
        logging.info(f"Captured: {output_path}")
        return output_path
    
    def close(self):
        """Clean shutdown."""
        if self.camera:
            self.camera.stop()
            self.camera.close()
            logging.info("Camera closed")

# Usage in daemon
camera = BirdhouseCamera(Path("/mnt/captures"))

def on_motion_detected():
    try:
        image_path = camera.capture()
        queue_for_upload(image_path)
    except Exception as e:
        logging.error(f"Capture failed: {e}")
```

**Best Practices**:
- Initialize camera once at startup, keep running
- Use timestamp-based filenames to avoid collisions
- Configure buffer count for faster captures
- Implement proper cleanup in shutdown handler

---

## 5. Local Storage Queue Management

### ❌ WRONG: Unlimited Disk Usage

```python
def save_image(image_data, filename):
    # ❌ No disk space checks
    with open(f"/mnt/captures/{filename}", "wb") as f:
        f.write(image_data)
    # ❌ No cleanup policy - fills disk, system crashes
```

**Issues**: Fills disk, system crashes when microSD card full

### ✅ CORRECT: Disk-Aware Queue with Cleanup

```python
import os
import shutil
from pathlib import Path
from collections import deque
import logging

class ImageQueue:
    """Manages local image storage with disk space limits."""
    
    def __init__(self, queue_dir: Path, max_size_gb: float = 2.0):
        self.queue_dir = queue_dir
        self.max_size_bytes = int(max_size_gb * 1024**3)
        self.queue_dir.mkdir(parents=True, exist_ok=True)
        self.upload_queue = deque()
    
    def add_image(self, image_path: Path) -> bool:
        """Add image to queue, enforce disk limits."""
        # Enforce disk space limits for this image (file may already exist)
        if not self._has_space(image_path):
            logging.warning("Disk space low, cleaning old images")
            self._cleanup_old_images()
        
        if not self._has_space(image_path):
            logging.error("Cannot free enough space, skipping capture")
            return False
        
        self.upload_queue.append(image_path)
        logging.info(f"Queued: {image_path} (queue size: {len(self.upload_queue)})")
        return True
    
    def _has_space(self, new_file: Path) -> bool:
        """Check if we have space for new file."""
        current_usage = sum(f.stat().st_size for f in self.queue_dir.glob("*.jpg"))
        new_file_size = new_file.stat().st_size if new_file.exists() else 5_000_000  # Estimate 5MB
        return (current_usage + new_file_size) < self.max_size_bytes
    
    def _cleanup_old_images(self, keep_newest: int = 10):
        """Delete oldest images to free space."""
        images = sorted(self.queue_dir.glob("*.jpg"), key=lambda p: p.stat().st_mtime)
        
        for old_image in images[:-keep_newest]:
            try:
                old_image.unlink()
                logging.info(f"Deleted old image: {old_image}")
            except Exception as e:
                logging.error(f"Failed to delete {old_image}: {e}")
    
    def get_next_upload(self) -> Path:
        """Get next image to upload (FIFO)."""
        return self.upload_queue.popleft() if self.upload_queue else None
```

**Best Practices**:
- Monitor disk space before each capture
- Implement FIFO cleanup (delete oldest first)
- Keep newest images even if unuploaded
- Log all cleanup operations for debugging

---

## 6. AWS S3 Upload with Retry Logic

### ❌ WRONG: No Network Resilience

```python
import boto3

s3 = boto3.client('s3')

def upload_image(file_path):
    # ❌ Crashes if no internet connection
    s3.upload_file(file_path, 'my-bucket', file_path)
    os.remove(file_path)  # ❌ Deletes before confirming upload
```

**Issues**: Data loss if upload fails, no offline handling

### ✅ CORRECT: Resilient Upload with Retry

```python
import boto3
from botocore.exceptions import ClientError, NoCredentialsError
from pathlib import Path
import time
import logging

class S3Uploader:
    """Resilient S3 uploader with retry logic for IoT devices."""
    
    def __init__(self, bucket_name: str, max_retries: int = 3):
        self.bucket_name = bucket_name
        self.max_retries = max_retries
        self.s3_client = None
        self._init_client()
    
    def _init_client(self):
        """Initialize S3 client with credentials check."""
        try:
            # Use environment variables or IAM role credentials
            self.s3_client = boto3.client('s3')
            
            # Test connection
            self.s3_client.head_bucket(Bucket=self.bucket_name)
            logging.info(f"S3 client initialized for bucket: {self.bucket_name}")
        except NoCredentialsError:
            logging.error("AWS credentials not found - uploads will fail")
            self.s3_client = None
        except ClientError as e:
            logging.error(f"S3 connection failed: {e}")
            self.s3_client = None
    
    def upload_with_retry(self, local_path: Path) -> bool:
        """Upload file with exponential backoff retry."""
        if not self.s3_client:
            logging.warning(f"No S3 client - queuing {local_path} for later")
            return False
        
        s3_key = f"captures/{local_path.name}"
        
        for attempt in range(1, self.max_retries + 1):
            try:
                self.s3_client.upload_file(
                    str(local_path),
                    self.bucket_name,
                    s3_key,
                    ExtraArgs={'ContentType': 'image/jpeg'}
                )
                logging.info(f"Uploaded {local_path.name} to S3: {s3_key}")
                return True
                
            except ClientError as e:
                error_code = e.response['Error']['Code']
                if error_code == '403':
                    logging.error(f"Permission denied - check IAM policy: {e}")
                    return False  # Don't retry permission errors
                    
                logging.warning(f"Upload attempt {attempt}/{self.max_retries} failed: {e}")
                if attempt < self.max_retries:
                    backoff = 2 ** attempt  # Exponential: 2s, 4s, 8s
                    time.sleep(backoff)
            
            except Exception as e:
                logging.error(f"Unexpected upload error: {e}")
                return False
        
        logging.error(f"Upload failed after {self.max_retries} retries")
        return False
```

**Best Practices**:
- Test AWS credentials at startup
- Use exponential backoff for retries
- Don't retry permission errors (fail fast)
- Keep local files until upload confirmed
- Log upload status for monitoring

---

## 7. Environment Variables & Configuration

### ❌ WRONG: Hardcoded Configuration

```python
# ❌ Exposed in public GitHub
AWS_REGION = 'eu-north-1'
S3_BUCKET = 'my-birdhouse-bucket-prod-123456'
CAPTURE_INTERVAL = 60
```

### ✅ CORRECT: Environment-Based Configuration

```python
# config.py
import os
from dotenv import load_dotenv

load_dotenv()  # Loads from .env file (gitignored)

class Config:
    """Application configuration from environment variables."""
    
    AWS_REGION = os.getenv('AWS_REGION', 'eu-north-1')
    AWS_S3_BUCKET = os.getenv('AWS_S3_BUCKET')
    CAPTURE_INTERVAL = int(os.getenv('CAPTURE_INTERVAL_SECONDS', '60'))
    REKOGNITION_CONFIDENCE = int(os.getenv('REKOGNITION_CONFIDENCE_THRESHOLD', '80'))
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    
    @classmethod
    def validate(cls):
        """Validate required configuration."""
        if not cls.AWS_S3_BUCKET:
            raise ValueError("AWS_S3_BUCKET environment variable required")
        return True

# In main.py
config = Config()
config.validate()
```

**Example `.env.example`** (safe to commit):
```bash
# AWS Credentials - Replace with your actual values
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_REGION=eu-north-1
AWS_S3_BUCKET=your-bucket-name-here

# Image Storage
LOCAL_STORAGE_DIR=/home/pi/birdhouse-vision/captures
MAX_LOCAL_STORAGE_GB=2.0

# Camera Settings
IMAGE_WIDTH=1920
IMAGE_HEIGHT=1080

# PIR Sensor
PIR_GPIO_PIN=17
```

**Include in README.md**:
```markdown
## Configuration

1. Copy `.env.example` to `.env`
2. Fill in your AWS credentials and bucket name
3. Adjust capture intervals and thresholds as needed
```

---

## 8. Systemd Service Configuration

### ❌ WRONG: Screen Session / Manual Startup

```bash
# ❌ Not production-ready
ssh pi@birdhouse-cam
cd /home/pi/birdhouse-vision
screen -S birdcam
python3 src/main.py
# Ctrl+A, D to detach
```

**Issues**: Doesn't auto-start on boot, dies on SSH disconnect, no logging

### ✅ CORRECT: Systemd Service with Auto-Restart

```ini
# /etc/systemd/system/birdhouse-vision.service

[Unit]
Description=Birdhouse Vision Camera Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi/birdhouse-vision

# Environment
Environment="PYTHONUNBUFFERED=1"
EnvironmentFile=/home/pi/birdhouse-vision/.env

# Start command
ExecStart=/usr/bin/python3 /home/pi/birdhouse-vision/src/main.py

# Restart policy - critical for IoT reliability
Restart=always
RestartSec=10

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=birdhouse-vision

# Security hardening
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

**Installation Commands**:
```bash
# Install service
sudo cp birdhouse-vision.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable birdhouse-vision.service
sudo systemctl start birdhouse-vision.service

# Monitor
sudo systemctl status birdhouse-vision.service
sudo journalctl -u birdhouse-vision.service -f  # Follow logs
```

**Best Practices**:
- Use `Restart=always` for IoT resilience
- Load secrets from `EnvironmentFile`
- Log to systemd journal (queryable with `journalctl`)
- Wait for network before starting (`After=network-online.target`)
- Use dedicated user (not root) for security

---

## 9. AWS Rekognition Integration

### Async Processing Pattern

**On Raspberry Pi**: Upload and forget (don't wait for analysis)

```python
class BirdhouseWorkflow:
    """Async workflow - Pi only captures and uploads."""
    
    def __init__(self, camera, uploader, queue):
        self.camera = camera
        self.uploader = uploader
        self.queue = queue
    
    def on_motion(self):
        """Fast capture workflow - don't wait for analysis."""
        # 1. Capture image (~500ms)
        image_path = self.camera.capture()
        
        # 2. Add to upload queue
        self.queue.add_image(image_path)
        
        # 3. Trigger upload in background (non-blocking)
        success = self.uploader.upload_with_retry(image_path)
        
        if success:
            image_path.unlink()  # Delete after upload
            logging.info("Upload complete, ready for next trigger")
        else:
            logging.warning(f"Upload queued for retry: {image_path}")
```

**AWS Lambda Function** (triggered by S3 upload event):

```python
# lambda_function.py (separate from Pi code)
import boto3
import json

def lambda_handler(event, context):
    """Triggered by S3 upload event - runs Rekognition analysis."""
    rekognition = boto3.client('rekognition')
    
    # Get uploaded image from S3 event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # Run Rekognition (cloud-side)
    response = rekognition.detect_labels(
        Image={'S3Object': {'Bucket': bucket, 'Name': key}},
        MaxLabels=10,
        MinConfidence=80.0
    )
    
    # Filter for bird-related labels
    bird_labels = [
        label for label in response['Labels']
        if (
            'Bird' in label['Name']
            or any(parent.get('Name') == 'Animal' for parent in label.get('Parents', []))
        )
    ]
    
    # Store results in DynamoDB or back to S3
    return {
        'statusCode': 200,
        'body': json.dumps({'labels': bird_labels})
    }
```

**Best Practices**:
- Raspberry Pi only captures and uploads (fast operations)
- AWS Lambda triggers on S3 upload event (configure S3 event notifications)
- Rekognition runs in cloud, not on Pi
- Pi ready for next motion trigger immediately
- Monitor costs with monthly budget alerts (see [docs/COSTS.md](docs/COSTS.md))

---

## 10. Structured Logging for Debugging

### ❌ WRONG: Print Statements

```python
def capture_image():
    print("Taking photo...")  # ❌ Lost when run as systemd service
    picam2.capture_file("image.jpg")
    print("Done!")  # ❌ No timestamps, severity, or context
```

**Issues**: No timestamps, can't filter by severity, lost in systemd

### ✅ CORRECT: Structured Logging with Context

```python
import logging
from logging.handlers import RotatingFileHandler
from pathlib import Path

def setup_logging(log_dir: Path):
    """Configure logging for systemd and file output."""
    log_dir.mkdir(parents=True, exist_ok=True)
    
    # Format with timestamp, level, and message
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    # Console handler (goes to systemd journal)
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    console_handler.setLevel(logging.INFO)
    
    # File handler with rotation (max 10MB, keep 5 files)
    file_handler = RotatingFileHandler(
        log_dir / 'birdhouse.log',
        maxBytes=10_000_000,  # 10MB
        backupCount=5
    )
    file_handler.setFormatter(formatter)
    file_handler.setLevel(logging.DEBUG)
    
    # Root logger
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    
    return logger

# Usage in main.py
logger = setup_logging(Path('/home/pi/birdhouse-vision/logs'))

logger.info("Birdhouse Vision starting up")
logger.debug(f"Camera initialized: resolution=1920x1080")
logger.warning(f"Disk usage at 85%")
logger.error(f"Upload failed: {error}", exc_info=True)  # Include stack trace
```

**Log Levels Guide**:
- `DEBUG`: Camera config, GPIO pin states, queue sizes
- `INFO`: Motion detected, image captured, upload successful
- `WARNING`: Disk space low, network unreachable, retry attempts
- `ERROR`: Camera failure, upload failure, exception occurred

---

## 11. Testing with Mock Hardware

### ❌ WRONG: Requires Real Hardware

```python
# test_capture.py
from src.camera import capture_image

def test_capture():
    # ❌ Only works on Raspberry Pi with camera attached
    capture_image("test.jpg")
    assert os.path.exists("test.jpg")
```

**Issues**: Can't test on Mac/Windows, CI/CD requires real Pi

### ✅ CORRECT: Mock GPIO and Camera

```python
# tests/test_motion_capture.py
import pytest
from unittest.mock import Mock, patch, MagicMock
from pathlib import Path

@pytest.fixture
def mock_camera():
    """Mock Picamera2 for testing without hardware."""
    with patch('src.camera.Picamera2') as mock:
        camera_instance = MagicMock()
        mock.return_value = camera_instance
        yield camera_instance

@pytest.fixture
def mock_pir():
    """Mock GPIO PIR sensor."""
    with patch('gpiozero.MotionSensor') as mock:
        pir_instance = MagicMock()
        mock.return_value = pir_instance
        yield pir_instance

def test_capture_on_motion(mock_camera, tmp_path):
    """Test full workflow with mocked hardware."""
    from src.main import BirdhouseWorkflow
    
    # Setup
    output_dir = tmp_path / "captures"
    output_dir.mkdir()
    
    workflow = BirdhouseWorkflow(
        camera=mock_camera,
        storage_dir=output_dir
    )
    
    # Simulate motion detection
    workflow.on_motion()
    
    # Verify camera was triggered
    mock_camera.capture_file.assert_called_once()

# Mock S3 with moto library
import boto3
from moto import mock_s3

@mock_s3
def test_s3_upload():
    """Test S3 upload with mocked AWS."""
    # Create mock S3 bucket
    s3 = boto3.client('s3', region_name='us-east-1')
    s3.create_bucket(Bucket='test-bucket')
    
    # Test uploader
    from src.upload import S3Uploader
    uploader = S3Uploader('test-bucket')
    
    test_file = Path('test.jpg')
    test_file.write_text('fake image data')
    
    success = uploader.upload_with_retry(test_file)
    assert success
```

**Testing Best Practices**:
- Mock `picamera2` and `gpiozero` for unit tests
- Use `tmp_path` fixture for file operations
- Test on Mac/CI without real hardware
- Integration test on actual Pi before deployment
- Mock S3 with `moto` library for upload tests

**Run tests**:
```bash
# Run all tests
python -m pytest tests/ -v

# Run only non-hardware tests (for CI)
python -m pytest tests/ -k "not hardware"
```

---

## 12. Error Handling & Resilience

### ❌ WRONG: Crash on Any Error

```python
def main_loop():
    while True:
        wait_for_motion()
        image = capture_image()  # ❌ Camera failure crashes entire daemon
        upload_to_s3(image)      # ❌ Network error kills process
```

**Issues**: Single failure takes down entire system

### ✅ CORRECT: Graceful Degradation

```python
import logging
import signal
import sys
from typing import Optional

class BirdhouseDaemon:
    """Resilient daemon with error isolation."""
    
    def __init__(self):
        self.running = True
        self.camera = None
        self.uploader = None
        self.consecutive_errors = 0
        self.max_consecutive_errors = 5
        
        # Register shutdown handlers
        signal.signal(signal.SIGTERM, self.shutdown)
        signal.signal(signal.SIGINT, self.shutdown)
    
    def initialize(self) -> bool:
        """Initialize hardware with error handling."""
        try:
            self.camera = BirdhouseCamera(Path('/mnt/captures'))
            logging.info("Camera initialized")
        except Exception as e:
            logging.error(f"Camera init failed: {e}", exc_info=True)
            return False
        
        try:
            self.uploader = S3Uploader('birdhouse-captures')
            logging.info("S3 uploader initialized")
        except Exception as e:
            logging.warning(f"S3 init failed, will queue locally: {e}")
            self.uploader = None  # Continue without upload
        
        return True
    
    def on_motion(self):
        """Motion callback with error isolation."""
        try:
            # Capture image
            image_path = self.camera.capture()
            self.consecutive_errors = 0  # Reset on success
            
            # Try to upload (non-critical)
            if self.uploader:
                try:
                    self.uploader.upload_with_retry(image_path)
                    image_path.unlink()  # Delete after upload
                except Exception as e:
                    logging.warning(f"Upload failed, keeping local: {e}")
                    # Continue operation even if upload fails
            
        except Exception as e:
            self.consecutive_errors += 1
            logging.error(
                f"Capture error ({self.consecutive_errors}/{self.max_consecutive_errors}): {e}",
                exc_info=True
            )
            
            # Exit if too many consecutive failures (likely hardware issue)
            if self.consecutive_errors >= self.max_consecutive_errors:
                logging.critical("Too many consecutive errors, shutting down for restart")
                self.shutdown()
    
    def shutdown(self, signum=None, frame=None):
        """Graceful shutdown handler."""
        logging.info("Shutdown signal received, cleaning up...")
        self.running = False
        
        if self.camera:
            self.camera.close()
        
        logging.info("Shutdown complete")
        sys.exit(0)
```

**Resilience Best Practices**:
- Isolate errors to prevent cascade failures
- Continue operation if non-critical components fail (e.g., upload)
- Exit and let systemd restart if critical hardware fails
- Track consecutive errors to detect hardware faults
- Implement graceful shutdown for clean restarts

---

## 13. Code Style & Documentation

### Python Style Standards

✅ **Required patterns**:
- Follow PEP 8 (use `black` for auto-formatting)
- Type hints for all public functions
- Docstrings for all modules, classes, and public functions
- Line length: 100 characters

```python
from typing import Optional, List
from pathlib import Path

def upload_image_to_s3(
    file_path: Path,
    bucket_name: str,
    object_name: Optional[str] = None,
    max_retries: int = 3
) -> bool:
    """
    Upload image file to AWS S3 bucket.
    
    Args:
        file_path: Local path to image file
        bucket_name: Target S3 bucket name
        object_name: Optional S3 object key (defaults to file basename)
        max_retries: Maximum upload retry attempts
    
    Returns:
        True if upload succeeded, False otherwise
    
    Raises:
        FileNotFoundError: If file_path does not exist
    """
    # Implementation...
```

### README Documentation

Required sections:
- **Quick Start**: Get running in 5 minutes
- **Hardware Setup**: Links to [docs/HARDWARE.md](docs/HARDWARE.md) and [docs/SETUP.md](docs/SETUP.md)
- **AWS Configuration**: Step-by-step AWS account setup
- **Configuration**: Environment variables and `.env` setup
- **Testing**: How to run tests
- **Troubleshooting**: Common issues
- **Cost Tracking**: Monthly AWS costs ([docs/COSTS.md](docs/COSTS.md))
- **License**: MIT License

---

## 14. Quick Copilot Prompt Seeds

Use these prompts when working with AI agents:

**Camera & Sensors**:
- "Implement PIR motion detection with gpiozero event callbacks and debouncing"
- "Add picamera2 initialization with 1920x1080 config and persistent instance"
- "Create camera capture handler with proper cleanup in signal handlers"

**AWS Integration**:
- "Create S3 uploader with exponential backoff retry for network interruptions. This is a public repo - use placeholder bucket names in examples."
- "Add Rekognition bird detection with monthly API limit tracking to stay within 300 requests (see docs/COSTS.md)"
- "Implement async upload workflow where Pi uploads and Lambda processes"

**Testing**:
- "Write pytest tests with mocked Picamera2 and gpiozero for Mac development"
- "Create unit tests with moto library for S3 upload mocking"
- "Add integration test fixtures for sample bird images"

**Deployment**:
- "Create systemd service file with auto-restart and journal logging"
- "Add disk space monitoring to prevent microSD card from filling up"
- "Implement graceful shutdown with signal handlers for camera cleanup"

**Security**:
- "Create .env.example file with placeholder AWS credentials (AKIAIOSFODNN7EXAMPLE format)"
- "Add .gitignore entries for .env, *.pem, captures/, logs/"
- "Update README with environment variable setup instructions using placeholders"

---

## Security Checklist

**Before committing code, verify**:

- [ ] No hardcoded AWS credentials (access keys, secret keys)
- [ ] No hardcoded S3 bucket names containing account IDs
- [ ] `.env` file is in `.gitignore`
- [ ] All example files use placeholders: `your-bucket-name`, `<your-region>`
- [ ] Log statements don't output credentials or tokens
- [ ] SSH keys and certificates are in `.gitignore`
- [ ] `.env.example` provided with safe placeholder values
- [ ] No personal information (email, location, IP addresses) in code/docs

**Prompt AI agents explicitly**:
> "This is a public repository. Use placeholder values like `your-bucket-name` and `<your-aws-region>` in all documentation and example files."

---

## Further Reading

- **[README.md](README.md)** - Project overview and quick start
- **[docs/SETUP.md](docs/SETUP.md)** - Complete hardware and software setup guide
- **[docs/HARDWARE.md](docs/HARDWARE.md)** - Bill of materials and supplier links
- **[docs/COSTS.md](docs/COSTS.md)** - Cost tracking and AWS budget (€0.30/month target)
- **[docs/WIFI_VS_ETHERNET.md](docs/WIFI_VS_ETHERNET.md)** - Network decision rationale

**For questions or issues**:
- Open a GitHub issue
- Check existing issues for similar problems
- Include logs and error messages (sanitize any sensitive data first)

---

**Summary**: This guide focuses on the **specific constraints of a Raspberry Pi-based PIR motion-triggered bird camera**: event-driven GPIO (not polling), persistent camera instance (fast captures), disk-aware local queue, resilient S3 upload with retry, systemd auto-restart, and security-first development for public repositories. No streaming, no video - this is a focused, secure, PIR-triggered still image capture system.
