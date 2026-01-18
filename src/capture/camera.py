"""
Camera capture module for birdhouse-vision.
Handles motion detection and image capture.
"""

from picamera2 import Picamera2
import time

def init_camera():
    """Initialize Raspberry Pi camera."""
    picam2 = Picamera2()
    config = picam2.create_still_configuration()
    picam2.configure(config)
    return picam2

def capture_image(output_path: str):
    """Capture a single image."""
    picam2 = init_camera()
    picam2.start()
    time.sleep(2)  # Warm-up
    picam2.capture_file(output_path)
    picam2.stop()
    print(f"Image saved to {output_path}")

if __name__ == "__main__":
    capture_image("test_image.jpg")