import os
from PIL import Image

# Set the directory where your PNG files are located
input_directory = "./"
output_directory = "./"
output_format = "webp"  # Change to "jpeg" if you prefer JPEG format

# Create the output directory if it doesn't exist
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

# Iterate through each file in the input directory
for filename in os.listdir(input_directory):
    if filename.endswith(".png"):
        # Open the PNG file
        img = Image.open(os.path.join(input_directory, filename))

        # Define the output file name
        base_name = os.path.splitext(filename)[0]
        output_file = os.path.join(output_directory, f"{base_name}.{output_format}")

        # Convert and save the image to the desired format
        img.save(output_file, format=output_format.upper())

        print(f"Converted {filename} to {output_file}")

print("Conversion completed!")
