import math

# Open a file to write the SystemVerilog ROM
with open('sin_rom.sv', 'w') as f:
    f.write('module sin_rom (\n')
    f.write('    input logic [8:0] angle, // Input angle from 0 to 359\n')
    f.write('    output int sin_value // Output sin value * 2^16\n')
    f.write(');\n\n')
    f.write('    always_comb begin\n')
    f.write('        case (angle)\n')

    for angle in range(360):
        sin_value = int(math.sin(math.radians(angle)) * (2 ** 16))
        f.write(f'            9\'d{angle}: sin_value = {sin_value};\n')

    f.write('            default: sin_value = 0;\n')
    f.write('        endcase\n')
    f.write('    end\n')
    f.write('endmodule\n')
