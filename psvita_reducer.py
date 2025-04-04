import os
import math
from PIL import Image

def previous_multiple_of_2(x):
    return max(2, x - (x % 2))  # Ensure it never returns 0

def resize_image(image_path, scale_factor):
    with Image.open(image_path) as img:
        img = img.convert("RGBA")  # Ensure image has an alpha channel
        width, height = img.size
        
        new_width = max(2, int(width * scale_factor))
        new_height = max(2, int(height * scale_factor))
        
        new_width = previous_multiple_of_2(new_width)
        new_height = previous_multiple_of_2(new_height)
        
        if (width, height) == (new_width, new_height):
            return  # Skip if already at the correct size
        
        new_img = img.resize((new_width, new_height), Image.LANCZOS)
        output_path = image_path
        
        if image_path.lower().endswith(".png"):
            new_img.save(output_path, optimize=True)
        elif image_path.lower().endswith((".jpg", ".jpeg")):
            new_img = new_img.convert("RGB")  # Ensure proper format for JPEG
            new_img.save(output_path, quality=85, optimize=True)  # Reduce JPEG size
        
        print(f"Resized and optimized: {image_path} -> {new_width}x{new_height}")

def process_folder(folder, scale_factor):
    for root, _, files in os.walk(folder):
        for file in files:
            if file.lower().endswith((".png", ".jpg", ".jpeg")):
                resize_image(os.path.join(root, file), scale_factor)

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python script.py <folder_path> <scale_factor>")
    else:
        folder_path = sys.argv[1]
        scale_factor = float(sys.argv[2])
        process_folder(folder_path, scale_factor)
