from PIL import Image
import os


palette = [(12, 13, 15), (0, 0, 0)]
pure_palette = [(12, 13, 15)]

def create_palette(image_path):
    img = Image.open(image_path)
    img = img.convert('RGB')
    width, height = img.size
    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))
            r = r >> 4
            g = g >> 4
            b = b >> 4
            if not ((r, g, b) in pure_palette):
                pure_palette.append((r, g, b))
                palette.append((r, g, b))
                palette.append((min(15, r+3), min(15, g+3), min(15, b+3)))
                # palette.append((max(0, r-1), max(0, g-1), max(0, b-1)))
                # palette.append((max(0, r-2), max(0, g-2), max(0, b - 2)))

def convert_to_sv(image_path, output_file):
    img = Image.open(image_path)
    img = img.convert('RGB')
    width, height = img.size
    with open(output_file, 'a') as f:
        f.write(f"        // {os.path.splitext(os.path.basename(image_path))[0]}\n")
        for y in range(height):
            for x in range(width):
                r, g, b = img.getpixel((x, y))
                r = r >> 4
                g = g >> 4
                b = b >> 4
                color_index = pure_palette.index((r, g, b))
                f.write("        8'b{0:08b}, // Color {1} ({2}, {3})\n".format((2*color_index), (r, g, b), x, y))

def remap_texture(image_path, output_folder):
    img = Image.open(image_path)
    img = img.convert('RGB')
    width, height = img.size
    remapped_img = Image.new('RGB', (width, height))
    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))
            r = r >> 4
            g = g >> 4
            b = b >> 4
            color_index = palette.index((r, g, b))
            remapped_color = tuple(int(x * 16) for x in palette[color_index])
            remapped_img.putpixel((x, y), remapped_color)
    output_filename = os.path.basename(image_path)
    output_path = os.path.join(output_folder, output_filename)
    remapped_img.save(output_path)

def main():
    texture_folder = "texture"
    texture_output_file = "texture_rom.sv"
    palette_output_file = "palette_rom.sv"
    remapped_texture_folder = "remapped_texture"

    if not os.path.exists(remapped_texture_folder):
        os.makedirs(remapped_texture_folder)

    type_number = 0
    for filename in os.listdir(texture_folder):
        if filename.endswith(".png") or filename.endswith(".jpg"):
            image_path = os.path.join(texture_folder, filename)
            create_palette(image_path)
            type_number += 1

    with open(palette_output_file, 'w') as f:
        f.write("/* Automatically generated palette ROM */\n\n")
        f.write("module palette_rom(\n")
        f.write("    input  logic [7:0] addr,\n")
        f.write("    output logic [11:0] data\n")
        f.write(");\n\n")
        f.write("    parameter ADDR_WIDTH = 8;\n")
        f.write("    parameter DATA_WIDTH = 12;\n")
        # f.write("    logic [ADDR_WIDTH-1:0] addr_reg;\n\n")
        f.write("    // ROM definition\n")
        # f.write(f"    parameter [0:{type_number}*2**ADDR_WIDTH-1][DATA_WIDTH-1:0]" + " TEXTURE_ROM = {\n")
        f.write("     parameter [0:{}-1][DATA_WIDTH-1:0] PALETTE_ROM = ".format(len(palette)))
        f.write("{\n")
        for i, color in enumerate(palette):
            r, g, b = color
            f.write("        12'b{0:04b}{1:04b}{2:04b}, // Index {3}\n".format(r, g, b, i))
        f.write("    };\n\n")
        f.write("    assign data = PALETTE_ROM[addr];\n\n")
        f.write("endmodule")

    for filename in os.listdir(texture_folder):
        if filename.endswith(".png") or filename.endswith(".jpg"):
            image_path = os.path.join(texture_folder, filename)
            remap_texture(image_path, remapped_texture_folder)
            print(f"Remapped {filename}.")

    with open(texture_output_file, 'w') as f:
        f.write("module texture_rom(\n")
        f.write("    input  logic clk,\n")
        f.write("    input  logic [4:0] id,\n")
        f.write("    input  logic [3:0] x,\n")
        f.write("    input  logic [3:0] y,\n")
        f.write("    output logic [7:0] data\n")
        f.write(");\n\n")
        f.write("    parameter ADDR_WIDTH = 8;\n")
        f.write("    parameter DATA_WIDTH = 8;\n")
        f.write(f"    parameter TYPE_NUMBER = {type_number};\n")
        # f.write("    logic [ADDR_WIDTH-1:0] addr_reg;\n\n")
        f.write("    // ROM definition\n")
        f.write(f"    parameter [0:{type_number}*2**ADDR_WIDTH-1][DATA_WIDTH-1:0]" + " TEXTURE_ROM = {\n")

    for filename in os.listdir(texture_folder):
        if filename.endswith(".png") or filename.endswith(".jpg"):
            image_path = os.path.join(texture_folder, filename)
            convert_to_sv(image_path, texture_output_file)
            print(f"Converted {filename} to SV format.")

    with open(texture_output_file, 'a') as f:
        f.write("    };\n\n")
        f.write("    logic [15:0] texture_address;\n")
        f.write("    logic [7:0] rom_data;\n\n")
        f.write("    always_comb begin\n")
        f.write("       texture_address = (id << 8) | (y << 4) | x;\n")
        f.write("    end\n\n")
        f.write("    always_ff @(posedge clk) begin\n")
        f.write("       rom_data <= TEXTURE_ROM[texture_address];\n")
        f.write("    end\n\n")
        f.write("    assign data = rom_data;\n\n")
        f.write("endmodule")

    print("Conversion complete.")

if __name__ == "__main__":
    main()
