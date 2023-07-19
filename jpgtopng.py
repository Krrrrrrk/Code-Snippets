import os
import shutil
from PIL import Image

def jpg_to_png(input_folder, exclude_folder):
    for root, dirs, files in os.walk(input_folder):
        # Remove the excluded folder 
        if exclude_folder in dirs:
            dirs.remove(exclude_folder)
        
        for file in files:
            if file.lower().endswith('.jpg'):
                jpg_file_path = os.path.join(root, file)
                png_file_path = os.path.splitext(jpg_file_path)[0] + '.png'

                # Convert the JPG to PNG and save it in the same location
                try:
                    with Image.open(jpg_file_path) as img:
                        img.save(png_file_path)
                    print(f"Converted: {jpg_file_path} -> {png_file_path}")
                except Exception as e:
                    print(f"Error converting {jpg_file_path}: {e}")

if __name__ == "__main__":
    folder_to_convert = r"[Folder-path]"
    folder_to_exclude = "[Folder to exclude name]"
    jpg_to_png(folder_to_convert, folder_to_exclude)