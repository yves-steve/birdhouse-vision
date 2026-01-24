# GitHub Copilot Instructions for Birdhouse Vision

## Project Overview
Birdhouse Vision is an AI-powered bird camera system that uses:
- Raspberry Pi for hardware platform
- Python 3.9+ for application logic
- Picamera2 for camera control and image capture
- OpenCV for image processing and motion detection
- AWS Rekognition for AI-powered bird identification
- GitHub Pages for bird gallery hosting

## Technology Stack
- **Language**: Python 3.9+
- **Hardware**: Raspberry Pi with camera module
- **Cloud**: AWS (Boto3 for Rekognition)
- **Web**: Flask for local testing/API
- **CI/CD**: GitHub Actions for deployment

## Code Style and Conventions
- Follow PEP 8 style guide for Python code
- Use type hints for function parameters and return values
- Use docstrings for all functions, classes, and modules (Google-style format)
- Keep functions focused and modular
- Use descriptive variable names that reflect the bird camera domain

## Project Structure
```
src/
  capture/        # Camera control and image capture logic
scripts/          # Utility scripts (e.g., gallery generation)
docs/             # Documentation files
.github/          # GitHub Actions workflows and configurations
```

## Dependencies
- Install dependencies from `requirements.txt`
- Core libraries: picamera2, opencv-python, Pillow, boto3
- Development: Flask for local testing
- Keep dependencies minimal for Raspberry Pi resource constraints

## Development Guidelines

### Camera Code
- Always handle camera initialization and cleanup properly
- Include warm-up time (2+ seconds) before capturing images
- Use context managers or try/finally for camera resources
- Test camera code on actual Raspberry Pi hardware when possible

### AWS Integration
- Use environment variables for AWS credentials (never hardcode)
- Handle AWS API errors gracefully
- Consider rate limits and costs for Rekognition calls
- Use `.env` files for local configuration (excluded from git)

### Image Processing
- Optimize image processing for Raspberry Pi performance
- Use appropriate image formats and compression
- Consider storage limitations on the device
- Handle motion detection efficiently to reduce false positives

### Scripts
- Scripts should be executable and self-contained
- Include proper error handling and logging
- Add progress indicators for long-running operations

## Testing
- Write unit tests for core functionality
- Mock external dependencies (camera, AWS) in tests
- Test edge cases (no motion, multiple birds, poor lighting)
- Consider hardware limitations when writing tests

## Documentation
- Update relevant docs in `docs/` when adding features
- Keep README.md current with setup instructions
- Document hardware requirements and configurations
- Include troubleshooting guides for common issues

## Performance Considerations
- Optimize for Raspberry Pi resource constraints (CPU, memory)
- Minimize power consumption for outdoor deployments
- Cache AWS Rekognition results to reduce API calls
- Use efficient image processing algorithms

## Security
- Never commit AWS credentials or API keys
- Use environment variables for sensitive configuration
- Validate and sanitize any external input
- Keep dependencies updated for security patches

## Common Tasks
- **Capture image**: Use `src/capture/camera.py`
- **Process with AWS**: Use boto3 Rekognition client
- **Generate gallery**: Run `scripts/generate_gallery.py`
- **Deploy**: Push to main branch triggers GitHub Actions

## Additional Notes
- This is an IoT project running on resource-constrained hardware
- Consider offline operation capabilities
- Think about power management and reliability
- Prioritize code that works in outdoor/remote conditions
