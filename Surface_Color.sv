module surface_color(
	input logic [3:0] x,
	input logic [3:0] y,
	input logic [2:0] block_type,
	
	output logic [11:0] color
);
	logic [10:0] texture_address;
	logic [7:0] palete_address;
	logic [11:0] palete_color;
	
	always_comb begin
		texture_address = block_type << 8 + y << 4 + x;
	end
	
	texture_rom texture_rom(.addr(texture_address), .data(palete_address));
	palette_rom palette_rom(.addr(palete_address), .data(palete_color));
	
endmodule
