import os
from PIL import Image
import json

def resize_images_and_create_import_data(folder_path, resize_ratio):
    """
    Scans subfolders for images, resizes them, and creates Godot import data.

    Args:
        folder_path (str): The path to the main folder containing subfolders with images.
        resize_ratio (float): The ratio by which to reduce the image size (e.g., 0.5 for 50%).
    """

    if not 0 < resize_ratio < 1:
        print("Error: Resize ratio must be between 0 and 1 (exclusive).")
        return

    godot_import_data = {}

    for subfolder_name in os.listdir(folder_path):
        subfolder_path = os.path.join(folder_path, subfolder_name)
        if os.path.isdir(subfolder_path):
            print(f"Processing subfolder: {subfolder_name}")
            godot_import_data[subfolder_name] = {}

            for filename in os.listdir(subfolder_path):
                if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
                    image_path = os.path.join(subfolder_path, filename)
                    try:
                        with Image.open(image_path) as img:
                            original_width, original_height = img.size
                            new_width = int(original_width * resize_ratio)
                            new_height = int(original_height * resize_ratio)
                            resized_img = img.resize((new_width, new_height))

                            new_filename = f"resized_{filename}"
                            new_image_path = os.path.join(subfolder_path, new_filename)
                            resized_img.save(new_image_path)
                            print(f"  Resized and saved: {filename} -> {new_filename}")

                            # Calculate the scale factor for Godot
                            godot_scale_x = 1 / resize_ratio
                            godot_scale_y = 1 / resize_ratio

                            godot_import_data[subfolder_name][filename] = {
                                "original_width": original_width,
                                "original_height": original_height,
                                "new_width": new_width,
                                "new_height": new_height,
                                "godot_scale_x": godot_scale_x,
                                "godot_scale_y": godot_scale_y
                            }

                    except Exception as e:
                        print(f"  Error processing {filename}: {e}")

    # Create a JSON file with Godot import data
    import_data_filename = "godot_import_data.json"
    import_data_path = os.path.join(folder_path, import_data_filename)
    with open(import_data_path, 'w') as f:
        json.dump(godot_import_data, f, indent=4)

    print(f"\nGodot import data saved to: {import_data_path}")
    print("Remember to apply the 'godot_scale_x' and 'godot_scale_y' in your Godot scenes for the corresponding original images.")

if __name__ == "__main__":
    target_folder = input("Enter the path to the folder containing subfolders with images: ")
    try:
        resize_value = float(input("Enter the resize ratio (e.g., 0.5 to make images 50% smaller): "))
        if 0 < resize_value < 1:
            resize_images_and_create_import_data(target_folder, resize_value)
        else:
            print("Invalid resize ratio. Please enter a value between 0 and 1 (exclusive).")
    except ValueError:
        print("Invalid input for resize ratio. Please enter a number.")