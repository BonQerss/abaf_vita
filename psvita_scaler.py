import os
from PIL import Image

def resize_images(input_folder, output_folder):
    # Ensure output base folder exists
    os.makedirs(output_folder, exist_ok=True)

    # Scale factor for resizing (e.g. 960x544 is half of 1920x1080)
    scale_factor = 960 / 1920

    # Recursively traverse input_folder
    for root, dirs, files in os.walk(input_folder):
        print("Looking in:", root)
        print("Subfolders:", dirs)
        print("Files:", files)
        # Calculate the path relative to the input folder, so we can replicate it in the output folder
        relative_path = os.path.relpath(root, input_folder)

        # Build the corresponding output path
        output_subdir = os.path.join(output_folder, relative_path)
        os.makedirs(output_subdir, exist_ok=True)

        # Process image files in the current folder
        for filename in files:
            if filename.lower().endswith(('png', 'jpg', 'jpeg', 'bmp', 'gif')):
                input_file_path = os.path.join(root, filename)
                output_file_path = os.path.join(output_subdir, filename)

                try:
                    with Image.open(input_file_path) as img:
                        new_width = int(img.width * scale_factor)
                        new_height = int(img.height * scale_factor)

                        # Ensure new dimensions are at least 1 pixel
                        new_width = max(1, new_width)
                        new_height = max(1, new_height)

                        # Resize image
                        resized_img = img.resize((new_width, new_height), Image.LANCZOS)
                        # Save into the matching subfolder structure
                        resized_img.save(output_file_path)

                        print(f"Resized {input_file_path} -> {output_file_path}")

                except Exception as e:
                    print(f"Error processing {input_file_path}: {e}")

if __name__ == "__main__":
    input_folder = "Sprites_nice"  # Change this to your folder
    output_folder = "Sprites"  # Change this to your desired output folder
    resize_images(input_folder, output_folder)
