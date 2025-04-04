import os
import math
from PIL import Image

def next_power_of_2(x):
    return 1 if x == 0 else 2**math.ceil(math.log2(x))

def expand_image(image_path):
    with Image.open(image_path) as img:
        img = img.convert("RGBA")  # Ensure image has an alpha channel
        width, height = img.size
        new_width = next_power_of_2(width)
        new_height = next_power_of_2(height)
        
        if (width, height) == (new_width, new_height):
            return  # Skip if already a power of 2
        
        new_img = Image.new("RGBA", (new_width, new_height), (0, 0, 0, 0))
        new_img.paste(img, (0, 0))
        new_img.save(image_path)
        print(f"Resized: {image_path} -> {new_width}x{new_height}")

def process_folder(folder):
    for root, _, files in os.walk(folder):
        for file in files:
            if file.lower().endswith((".png", ".jpg", ".jpeg")):
                expand_image(os.path.join(root, file))

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python script.py <folder_path>")
    else:
        process_folder(sys.argv[1])
