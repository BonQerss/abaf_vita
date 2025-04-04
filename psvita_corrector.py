import os
import math
from PIL import Image

def nearest_power_of_2(n):
    """Finds the nearest power of 2 for a given number."""
    return 2 ** math.ceil(math.log2(n))

def resize_to_nearest_po2(image_path, output_folder, compression_quality=85):
    """Resizes an image to the nearest power of 2 and applies compression."""
    try:
        img = Image.open(image_path)

        # Convert to RGB if image has transparency (to avoid issues with JPEG)
        if img.mode in ("RGBA", "P"):
            img = img.convert("RGB")

        width, height = img.size
        new_width = nearest_power_of_2(width)
        new_height = nearest_power_of_2(height)

        img = img.resize((new_width, new_height), Image.LANCZOS)

        # Ensure output folder exists
        os.makedirs(output_folder, exist_ok=True)

        output_path = os.path.join(output_folder, os.path.basename(image_path))

        # Save as JPEG with compression
        img.save(output_path, format='JPEG', quality=compression_quality)
        print(f"Resized and saved: {output_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

def process_folder(input_folder, output_folder, compression_quality=85):
    """Processes all images in a folder and its subfolders."""
    supported_formats = (".png", ".jpg", ".jpeg", ".bmp", ".tiff")

    for root, _, files in os.walk(input_folder):
        relative_path = os.path.relpath(root, input_folder)
        current_output_folder = os.path.join(output_folder, relative_path)
        os.makedirs(current_output_folder, exist_ok=True)

        for filename in files:
            if filename.lower().endswith(supported_formats):
                image_path = os.path.join(root, filename)
                resize_to_nearest_po2(image_path, current_output_folder, compression_quality)

if __name__ == "__main__":
    input_folder = "Sprites_good"  # Change to your input folder
    output_folder = "Sprites"  # Change to your output folder
    print(f"Checking if input folder '{input_folder}' exists: {os.path.exists(input_folder)}")

    process_folder(input_folder, output_folder)
    print("Finished processing images.")