# modify_godot_textures_to_lossy.py
import os
import argparse
import re # For potential parsing, although simple string ops might suffice

# --- Configuration ---

# Texture file extensions to look for (associated with .import files)
# Ensure lowercase for comparison
TEXTURE_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.tga', '.webp', '.bmp'}

# The value corresponding to "Lossy" compression in Godot 3.x .import files
TARGET_COMPRESS_MODE = '0'
TARGET_PARAM_KEY = 'compress/mode'

# --- Functions ---

def modify_import_file(import_file_path):
    """
    Reads a Godot 3.x .import file, checks if it's for a texture,
    and changes its compress/mode to Lossy (1) if it's different.

    Args:
        import_file_path (str): The absolute path to the .import file.

    Returns:
        bool: True if the file was modified, False otherwise.
    """
    # Derive the expected source file path to check its extension
    source_file_path = import_file_path[:-len(".import")]
    source_ext = os.path.splitext(source_file_path)[1].lower()

    # Check if the source file likely corresponds to a texture type
    if source_ext not in TEXTURE_EXTENSIONS:
        # print(f"  Debug: Skipping non-texture source type for {os.path.basename(import_file_path)}")
        return False

    try:
        with open(import_file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except IOError as e:
        print(f"  Error reading {import_file_path}: {e}")
        return False

    is_texture_import = False
    in_params_section = False
    needs_modification = False
    param_line_index = -1  # Track the line index of the parameter

    current_section = None
    for i, line in enumerate(lines):
        stripped_line = line.strip()

        # Detect section headers
        if stripped_line.startswith('[') and stripped_line.endswith(']'):
            current_section = stripped_line
            # Check if we entered the params section
            in_params_section = (current_section == '[params]')
            continue # Move to next line

        # Check if importer is "texture" within the [remap] section
        if current_section == '[remap]' and stripped_line == 'importer="texture"':
            is_texture_import = True
            # print(f"  Debug: Found texture importer in {os.path.basename(import_file_path)}")

        # Check for the compression mode within the [params] section
        if is_texture_import and in_params_section and stripped_line.startswith(TARGET_PARAM_KEY + '='):
            # print(f"  Debug: Found param line: {stripped_line}")
            parts = stripped_line.split('=', 1)
            if len(parts) == 2:
                current_value = parts[1].strip()
                if current_value != TARGET_COMPRESS_MODE:
                    needs_modification = True
                    param_line_index = i
                    # print(f"  Debug: Needs modification from {current_value}")
                else:
                    # print(f"  Debug: Already set to {TARGET_COMPRESS_MODE}")
                    pass # Already correct
            # Found the parameter, no need to check further lines within params for this specific key
            break # More efficient

    # Rewrite the file only if it's a texture and modification is needed
    if is_texture_import and needs_modification:
        print(f"  Modifying: {os.path.basename(import_file_path)}")
        # Preserve indentation from the original line
        original_line = lines[param_line_index]
        indent = ""
        match = re.match(r"^(\s*)", original_line)
        if match:
            indent = match.group(1)

        # Replace the specific line
        lines[param_line_index] = f"{indent}{TARGET_PARAM_KEY}={TARGET_COMPRESS_MODE}\n"

        # Write the modified content back to the file
        try:
            with open(import_file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            return True # Modification successful
        except IOError as e:
            print(f"  Error writing {import_file_path}: {e}")
            return False # Modification failed

    return False # Not a texture or no modification needed

def process_directory(target_dir):
    """
    Walks through the target directory and its subdirectories,
    modifying texture .import files.
    """
    if not os.path.isdir(target_dir):
        print(f"Error: Provided path is not a valid directory: {target_dir}")
        return

    print(f"Scanning directory: {target_dir}")
    modified_count = 0
    scanned_count = 0

    for root, _, files in os.walk(target_dir):
        for filename in files:
            if filename.endswith(".import"):
                scanned_count += 1
                file_path = os.path.join(root, filename)
                if modify_import_file(file_path):
                    modified_count += 1

    print("\nScan complete.")
    print(f"  Scanned {scanned_count} '.import' files.")
    print(f"  Modified {modified_count} texture import files to Lossy (mode={TARGET_COMPRESS_MODE}).")
    if modified_count > 0:
        print("\nIMPORTANT: Please re-open your Godot project.")
        print("Godot should detect the changes and reimport the modified textures automatically.")

# --- Main Execution ---

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Modify Godot 3.x texture import files in a directory to use Lossy compression."
    )
    parser.add_argument(
        "directory",
        help="Path to the target Godot project folder or a specific subfolder containing textures."
    )

    args = parser.parse_args()

    # Get the absolute path for robustness
    target_directory = os.path.abspath(args.directory)

    process_directory(target_directory)