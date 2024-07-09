module render_engine (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	input logic [7:0] keycode,
	
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [7:0]  VGA_R, VGA_G, VGA_B,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,					// VGA HS/VS
	output logic sync, blank, pixel_clk,		// Required by DE2-115 video encoder
	output logic [6:0] HEX0, HEX1, HEX2, HEX3,
);

logic [7:0] keycode_sh;
always_ff @(posedge CLK) begin
	keycode_sh <= keycode;
end
HexDriver hex_inst_0 (cz[19:16], HEX0); // z
HexDriver hex_inst_1 (cy[19:16], HEX1); // y
HexDriver hex_inst_2 (column_number, HEX2); // x
HexDriver hex_inst_3 (seleted_item[3:0], HEX3);
//HexDriver hex_inst_0 (gx[3:0], HEX0); // z
//HexDriver hex_inst_1 (gy[3:0], HEX1); // y
//HexDriver hex_inst_2 (gz[3:0], HEX2); // x
//HexDriver hex_inst_3 (map_reg[gx][gy][gz][3:0], HEX3);
//put other local variables here
//logic color;
logic [9:0] DrawX, DrawY;

// size to be adjust in the furture.
parameter BLOCK_WIDTH = 16;
parameter [2:0] block_type = 3'b000;

logic surface_x, surface_y;
logic [11:0] palette_color, color;
logic [10:0] texture_address;
logic [7:0] palette_address, texture_data;
   
logic [3:0] texture_u, texture_v;
logic [4:0] texture_id;


texture_rom texture_rom(.clk(CLK), .id(texture_id), .x(qu[0]), .y(qv[0]), .data(texture_data));

logic [7:0] texture_data_sh;
//Declare submodules..e.g. VGA controller, ROMS, etc
vga_controller vga_controller(.Clk(CLK), .Reset(RESET), .hs, .vs, .pixel_clk, .blank, .sync, .DrawX, .DrawY);







logic [15:0] read_addr, write_addr;
logic wren;
logic [7:0] frame_buffer_data;



parameter LENGTH = 320;
parameter WIDTH = 180;
logic DrawBackground, FrameComplete;
logic [8:0] BackX, BackY;
logic [3:0] SurfX, SurfY;

logic DrawVertice, DrawSurface, DrawBlocks, DrawSelected;
parameter SIZE = 16;


initial begin
    FrameComplete = 1;
end

logic [23:0] E  = 24'h000000;   // eye point (0, 0, 0)
logic [31:0] v1 = 32'h01010200; // (1, 0, 1) uv = (0, 0)

//logic [31:0] v2 = 32'h01000400; // (0, 0, 8) uv = (0, 0)
//logic [31:0] v3 = 32'h02000400; // (0, 0, 8) uv = (0, 0)
//logic [31:0] v4 = 32'h02010400; // (0, 0, 8) uv = (0, 0)

logic signed [23:0] vx[8], vy[8], vz[8];
int vx_view[8], vy_view[8], vz_view[8];

//logic [31:0] blocks[8];
//logic [4:0] block_id;
//parameter block_number = 7;

parameter [0:15][29:0] BLOCK_FACE_ID = {
	30'b000000000000000000000000000000,  // air
	30'b000000000000000000000000000000,  // 01 dirt
	30'b000010000100000000010000100010,  // 110112,  // 02 grass
	30'b000110001100100000110001100100,  // 334334,  // 03 oak
	30'b001010010100101001010010100101,  // 555555,  // 04 planks
	30'b001100011000110001100011000110,  // 666666,  // 05 flower_leave
	30'b001110011100111001110011101001,  // music box
	30'b010000100001000010000100001000,  // 888888,  // 07 stone
   30'b100101001110100100111001110100,  // 08 furnace
	
	30'b101101011010110101101011010111,  // 09 cobblestone
	30'b010110110001101011000110001101,  // 10 crafting table
	30'b011100111001110011100111001110,  // 11 iron_block
	30'b011110111101111011110111101111,  // 12 gold_block
	30'b100001000010000100001000010000,  // 13 redstone_block
	30'b100011000110001100011000110001,  // 14 diamand_block
	30'b101011010110101101011010110101,  // 15 amethyst_block
};

always_comb begin
	if (surface_id == 0) 
		texture_id = BLOCK_FACE_ID[map_reg[gx][gy][gz]][29:25];
	else if (surface_id == 1) 
		texture_id = BLOCK_FACE_ID[map_reg[gx][gy][gz]][24:20];
	else if (surface_id == 2) 
		texture_id = BLOCK_FACE_ID[map_reg[gx][gy][gz]][19:15];
	else if (surface_id == 3) 
		texture_id = BLOCK_FACE_ID[map_reg[gx][gy][gz]][14:10];
	else if (surface_id == 4) 
		texture_id = BLOCK_FACE_ID[map_reg[gx][gy][gz]][ 9: 5];
	else if (surface_id == 5) 
		texture_id = BLOCK_FACE_ID[map_reg[gx][gy][gz]][ 4: 0];
	else 
		texture_id = 0;
	
end

//always_comb begin
//	blocks[0] = 32'h01010200;
//	blocks[1] = 32'h02010201;
//	blocks[2] = 32'h01020201;
//	blocks[3] = 32'h01010301;
//	blocks[4] = 32'h00010201;
//	blocks[5] = 32'h01010101;
//	blocks[6] = 32'h01000200;
//	blocks[7] = target_block;
//end


always_comb begin // front case
//	vx[0] = blocks[block_id][31:24] 			;  	// (0, 0, 0)
//	vy[0] = blocks[block_id][23:16] 			;
//	vz[0] = blocks[block_id][15:8 ] 			;
	vx[0] = gx[3:0];
	vy[0] = gy[3:0];
	vz[0] = gz[3:0];

	vx[3'b001] = vx[0]		;
	vy[3'b001] = vy[0]		;
	vz[3'b001] = vz[0] + 1	;

	vx[3'b010] = vx[0]		;
	vy[3'b010] = vy[0] + 1	;
	vz[3'b010] = vz[0]    	;

	vx[3'b011] = vx[0]		;
	vy[3'b011] = vy[0] + 1	;
	vz[3'b011] = vz[0] + 1 	;

	vx[3'b100] = vx[0] + 1 	;
	vy[3'b100] = vy[0] 		;
	vz[3'b100] = vz[0]  		;

	vx[3'b101] = vx[0] + 1	;
	vy[3'b101] = vy[0]   	;
	vz[3'b101] = vz[0] + 1 	;
		
	vx[3'b110] = vx[0] + 1	;
	vy[3'b110] = vy[0] + 1	;
	vz[3'b110] = vz[0]     	;

	vx[3'b111] = vx[0] + 1  ;
	vy[3'b111] = vy[0] + 1	;
	vz[3'b111] = vz[0] + 1 	;

end	 

logic oe;
logic [3:0] surface_counter;
logic signed [9:0] sx, sy, x_screen[8], y_screen[8];

logic signed [9:0] x0, x1, x2, x3, y0, y1, y2, y3, x_min, x_max, y_min, y_max, x_min_t, x_max_t, y_min_t, y_max_t,
					    x_min_l, x_min_r, x_max_l, x_max_r, y_min_l, y_min_r, y_max_l, y_max_r;

parameter [0:5][11:0] surface_vertices = {
	12'b010000100110, // front 	2-0-4-6
	12'b011001000010, // left  	3-1-0-2
	12'b001000100101, // bottom 	1-0-4-5
	
	12'b111101001011, // behind	7-5-1-3
	12'b110100101111, // right		6-4-5-7
	12'b011010110111  // top 		3-2-6-7
};

int cx, cx_in; // = 2 << 13; // 0.5 // 0.125 for a frame is reasonable
int cy, cy_in; // = 6 << 13; // 0.5
int cz, cz_in; // = 3 << 13; // 0.5

logic [8:0] theta1;
logic [8:0] theta2;

int cos_theta1; // = 59870;  // thera1 = 0 around y axis
int sin_theta1; // = 26655;
int cos_theta2; // = 59870;  // thera2 = 0 around x axis
int sin_theta2; // = 26655;

//always_comb begin
//	theta1 = 9'b000011110;
//	theta2 = 9'b000011110;
//end

cos_rom(.angle(theta1), .cos_value(cos_theta1));
cos_rom(.angle(theta2), .cos_value(cos_theta2));
sin_rom(.angle(theta1), .sin_value(sin_theta1));
sin_rom(.angle(theta2), .sin_value(sin_theta2));

v_transformation(.*, .x(vx[0]), .y(vy[0]), .z(vz[0]), .x_view(vx_view[0]), .y_view(vy_view[0]), .z_view(vz_view[0]));
v_transformation(.*, .x(vx[1]), .y(vy[1]), .z(vz[1]), .x_view(vx_view[1]), .y_view(vy_view[1]), .z_view(vz_view[1]));
v_transformation(.*, .x(vx[2]), .y(vy[2]), .z(vz[2]), .x_view(vx_view[2]), .y_view(vy_view[2]), .z_view(vz_view[2]));
v_transformation(.*, .x(vx[3]), .y(vy[3]), .z(vz[3]), .x_view(vx_view[3]), .y_view(vy_view[3]), .z_view(vz_view[3]));
v_transformation(.*, .x(vx[4]), .y(vy[4]), .z(vz[4]), .x_view(vx_view[4]), .y_view(vy_view[4]), .z_view(vz_view[4]));
v_transformation(.*, .x(vx[5]), .y(vy[5]), .z(vz[5]), .x_view(vx_view[5]), .y_view(vy_view[5]), .z_view(vz_view[5]));
v_transformation(.*, .x(vx[6]), .y(vy[6]), .z(vz[6]), .x_view(vx_view[6]), .y_view(vy_view[6]), .z_view(vz_view[6]));
v_transformation(.*, .x(vx[7]), .y(vy[7]), .z(vz[7]), .x_view(vx_view[7]), .y_view(vy_view[7]), .z_view(vz_view[7]));


p_transformation(.CLK, .OE(oe), .x(vx_view[0]), .y(vy_view[0]), .z(vz_view[0]), .x_screen(x_screen[0]), .y_screen(y_screen[0]));
p_transformation(.CLK, .OE(oe), .x(vx_view[1]), .y(vy_view[1]), .z(vz_view[1]), .x_screen(x_screen[1]), .y_screen(y_screen[1]));
p_transformation(.CLK, .OE(oe), .x(vx_view[2]), .y(vy_view[2]), .z(vz_view[2]), .x_screen(x_screen[2]), .y_screen(y_screen[2]));
p_transformation(.CLK, .OE(oe), .x(vx_view[3]), .y(vy_view[3]), .z(vz_view[3]), .x_screen(x_screen[3]), .y_screen(y_screen[3]));
p_transformation(.CLK, .OE(oe), .x(vx_view[4]), .y(vy_view[4]), .z(vz_view[4]), .x_screen(x_screen[4]), .y_screen(y_screen[4]));
p_transformation(.CLK, .OE(oe), .x(vx_view[5]), .y(vy_view[5]), .z(vz_view[5]), .x_screen(x_screen[5]), .y_screen(y_screen[5]));
p_transformation(.CLK, .OE(oe), .x(vx_view[6]), .y(vy_view[6]), .z(vz_view[6]), .x_screen(x_screen[6]), .y_screen(y_screen[6]));
p_transformation(.CLK, .OE(oe), .x(vx_view[7]), .y(vy_view[7]), .z(vz_view[7]), .x_screen(x_screen[7]), .y_screen(y_screen[7]));

logic signed [9:0] qx[8], qy[8];
logic [3:0] qu[8], qv[8];
logic signed [15:0] qz[8];
logic is_inside;
logic ins[8];

// front
texture_mapping(.*, 	.x0, .y0, .u0(0), .v0(0), 
							.x1, .y1, .u1(0), .v1(15),
							.x2, .y2, .u2(15), .v2(15),
							.x3, .y3, .u3(15), .v3(0),
							.qx(qx[0]), .qy(qy[0]), 
							.z0, .z1, .z2, .z3,
							.is_inside(ins[0]), .qu(qu[0]), .qv(qv[0]), .qz(qz[0]));

texture_mapping(.*, 	.x0, .y0, .u0(0), .v0(0), 
							.x1, .y1, .u1(0), .v1(15),
							.x2, .y2, .u2(15), .v2(15),
							.x3, .y3, .u3(15), .v3(0),
							.qx(qx[1]), .qy(qy[1]),
							.z0, .z1, .z2, .z3,	
							.is_inside(ins[1]), .qu(qu[1]), .qv(qv[1]), .qz(qz[1]));
							
texture_mapping(.*, 	.x0, .y0, .u0(0), .v0(0), 
							.x1, .y1, .u1(0), .v1(15),
							.x2, .y2, .u2(15), .v2(15),
							.x3, .y3, .u3(15), .v3(0),
							.qx(qx[2]), .qy(qy[2]), 
							.z0, .z1, .z2, .z3,
							.is_inside(ins[2]), .qu(qu[2]), .qv(qv[2]), .qz(qz[2]));
							
texture_mapping(.*, 	.x0, .y0, .u0(0), .v0(0), 
							.x1, .y1, .u1(0), .v1(15),
							.x2, .y2, .u2(15), .v2(15),
							.x3, .y3, .u3(15), .v3(0),
							.qx(qx[3]), .qy(qy[3]), 
							.z0, .z1, .z2, .z3,
							.is_inside(ins[3]), .qu(qu[3]), .qv(qv[3]), .qz(qz[3]));

//point_in_quadrilateral (.*,	.qx(qx[0]), .qy(qy[0]), 
//										.is_inside(ins[0]));
//										
//point_in_quadrilateral (.*, 	.qx(qx[1]), .qy(qy[1]), 
//										.is_inside(ins[1]));
//										
//point_in_quadrilateral (.*, 	.qx(qx[2]), .qy(qy[2]), 
//										.is_inside(ins[2]));
//										
//point_in_quadrilateral (.*, 	.qx(qx[3]), .qy(qy[3]), 
//										.is_inside(ins[3]));

//assign surface_id = 1;
always_comb begin
	x0 = x_screen[surface_vertices[surface_id][11:9]];
	x1 = x_screen[surface_vertices[surface_id][8:6]];
	x2 = x_screen[surface_vertices[surface_id][5:3]];
	x3 = x_screen[surface_vertices[surface_id][2:0]];

	y0 = y_screen[surface_vertices[surface_id][11:9]];
	y1 = y_screen[surface_vertices[surface_id][8:6]];
	y2 = y_screen[surface_vertices[surface_id][5:3]];
	y3 = y_screen[surface_vertices[surface_id][2:0]];
	
	z0 = vz_view[surface_vertices[surface_id][11:9]][23:8];
	z1 = vz_view[surface_vertices[surface_id][8:6]][23:8];
	z2 = vz_view[surface_vertices[surface_id][5:3]][23:8];
	z3 = vz_view[surface_vertices[surface_id][2:0]][23:8];
	
	

	x_min_l = (x0 < x1) ? x0 : x1;
	x_min_r = (x2 < x3) ? x2 : x3;
	
	x_max_l = (x0 > x1) ? x0 : x1;
	x_max_r = (x2 > x3) ? x2 : x3;
	
	y_min_l = (y0 < y1) ? y0 : y1;
	y_min_r = (y2 < y3) ? y2 : y3;
	
	y_max_l = (y0 > y1) ? y0 : y1;
	y_max_r = (y2 > y3) ? y2 : y3;

	
	x_min_t = (x_min_l < x_min_r) ? x_min_l : x_min_r;
	x_max_t = (x_max_l > x_max_r) ? x_max_l : x_max_r;
	y_min_t = (y_min_l < y_min_r) ? y_min_l : y_min_r;
	y_max_t = (y_max_l > y_max_r) ? y_max_l : y_max_r;
	
	x_min = (x_min_t < 0) ? 0 : x_min_t;
	x_max = (x_max_t > 319) ? 319 : x_max_t;
	y_min = (y_min_t < 0) ? 0 : y_min_t;
	y_max = (y_max_t > 179) ? 179 : y_max_t;
end



z_buffer_ocm(
	.clock(CLK),
	.data(z_in),
	.rdaddress(z_buffer_read_addr),
	.wraddress(write_addr),
	.wren(wren),
	.q(z_out)
);

logic	[15:0]  z_in;
logic	[15:0]  z_buffer_read_addr;
logic	[15:0]  z_buffer_write_addr;
logic	  z_buffer_wren;
logic	signed [15:0]  z_value[8], z0, z1, z2, z3;


logic [15:0] z_out, z_out_sh, z_buffer[8];



							
logic wait_cycle, init_cycle, iteration_complete, wait_complete;
logic [4:0] wait_counter;
logic [4:0] id_counter;

parameter surface_num = 5; 
logic [7:0] surface_id;

logic [31:0] target_block;
logic [3:0] target_surface;

logic [4:0] seleted_item;
logic column_number;
logic temp;
int action_counter;

logic visible;

//always_ff @(posedge CLK) begin
//	visible <= ((map_reg[gx][gy][gz] == 4'b0000) && 
//					(
//end

//initial begin
////		map_reg[5][1][5] <= 4'b0001; // dirt
//
//end

always_ff @(posedge pixel_clk) begin
	if (init_map) begin
		init_map <= 0;
		cx <= (7 << 16);
		cy <= (4 << 16) + (1 << 15);
		cz <= (4 << 16);
		theta1 <= 0;
		theta2 <= 0;
		seleted_item <= 1;
		column_number <= 0;
		action_counter <= 0;
		
		map_reg[5][1][6] <= 4'b0010; // grass
		map_reg[5][1][7] <= 4'b0010; // grass
		map_reg[5][1][8] <= 4'b0010; // grass
		map_reg[5][1][9] <= 4'b0010; // grass
		map_reg[6][1][5] <= 4'b0010; // grass
		map_reg[6][1][6] <= 4'b0001; // dirt
		map_reg[6][1][7] <= 4'b0001; // dirt
		map_reg[6][1][8] <= 4'b0001; // dirt
		map_reg[6][1][9] <= 4'b0010; // grass
		map_reg[7][1][5] <= 4'b0010; // grass
		map_reg[7][1][6] <= 4'b0001; // dirt
		map_reg[7][1][7] <= 4'b0001; // dirt
		map_reg[7][1][8] <= 4'b0001; // dirt
		map_reg[7][1][9] <= 4'b0010; // grass
		map_reg[8][1][5] <= 4'b0010; // grass
		map_reg[8][1][6] <= 4'b0001; // dirt
		map_reg[8][1][7] <= 4'b0001; // dirt
		map_reg[8][1][8] <= 4'b0001; // dirt
		map_reg[8][1][9] <= 4'b0010; // grass
		map_reg[9][1][5] <= 4'b0010; // grass
		map_reg[9][1][6] <= 4'b0010; // grass
		map_reg[9][1][7] <= 4'b0010; // grass
		map_reg[9][1][8] <= 4'b0010; // grass
		map_reg[9][1][9] <= 4'b0010; // grass
		
		map_reg[6][2][6] <= 4'b0010; // center block type is grass
		map_reg[6][2][7] <= 4'b0010; // center block type is grass
		map_reg[6][2][8] <= 4'b0010; // center block type is grass
		map_reg[7][2][6] <= 4'b0010; // center block type is grass
		map_reg[7][2][7] <= 4'b0010; // center block type is grass
		map_reg[7][2][8] <= 4'b0010; // center block type is grass
		map_reg[8][2][6] <= 4'b0010; // center block type is grass
		map_reg[8][2][7] <= 4'b0010; // center block type is grass
		map_reg[8][2][8] <= 4'b0010; // center block type is grass
		
		
		
//		// tree
		map_reg[7][3][7] <= 4'b0011; // tree sterm
		map_reg[7][4][7] <= 4'b0011; // tree sterm
		map_reg[7][5][7] <= 4'b0011; // tree sterm

		map_reg[6][5][6] <= 4'b0101; // tree leaves
		map_reg[6][5][7] <= 4'b0101; // tree leaves
		map_reg[6][5][8] <= 4'b0101; // tree leaves
		map_reg[7][5][6] <= 4'b0101; // tree leaves
		map_reg[7][5][8] <= 4'b0101; // tree leaves
		map_reg[8][5][6] <= 4'b0101; // tree leaves
		map_reg[8][5][7] <= 4'b0101; // tree leaves
		map_reg[8][5][8] <= 4'b0101; // tree leaves
		map_reg[7][6][7] <= 4'b0101; // tree leaves
		
	end else 
	if (DrawX == 0 && DrawY == 0 && FrameComplete == 1) begin
		if (action_counter == 15) begin
			action_counter <= 0;
		end else begin
			action_counter <= (action_counter + 1);
		end
		
		if (keycode_sh == 8'h2c) begin // SPACE => JUMP
			cx <= cx; 
			cy <= (cy + (1 << 10)); 
			cz <= cz; 
		end else if (keycode_sh == 8'h1b) begin // X => SHIFT (TEMP)
			cx <= cx; 
			cy <= (cy - (1 << 10)); 
			cz <= cz; 
		end else if (keycode_sh == 8'h04) begin // A => LEFT
			cx <= (cx - (1 << 10)); 
			cy <= cy; 
			cz <= cz; 
		end else if (keycode_sh == 8'h07) begin // D => RIGHT
			cx <= (cx + (1 << 10)); 
			cy <= cy; 
			cz <= cz; 
		end else if (keycode_sh == 8'h1a) begin // W => FRONT
			cx <= cx; 
			cy <= cy; 
			cz <= (cz + (1 << 10)); 
		end else if (keycode_sh == 8'h16) begin // S => BACK
			cx <= cx; 
			cy <= cy; 
			cz <= (cz - (1 << 10)); 
		end else if (keycode_sh == 8'h1e) begin // 1 => ITEM1
			seleted_item <= 1;
		end else if (keycode_sh == 8'h1f) begin // 2 => ITEM2
			seleted_item <= 2;
		end else if (keycode_sh == 8'h20) begin // 3 => ITEM3
			seleted_item <= 3;
		end else if (keycode_sh == 8'h21) begin // 4 => ITEM4
			seleted_item <= 4;
		end else if (keycode_sh == 8'h22) begin // 5 => ITEM5
			seleted_item <= 5;
		end else if (keycode_sh == 8'h23) begin // 1 => ITEM1
			seleted_item <= 6;
		end else if (keycode_sh == 8'h24) begin // 1 => ITEM1
			seleted_item <= 7;
		end else if (keycode_sh == 8'h25) begin // 1 => ITEM1
			seleted_item <= 8;
		end else if (keycode_sh == 8'h26) begin // 1 => ITEM1
			seleted_item <= 9;
		end else if (keycode_sh == 8'h27) begin // 1 => ITEM1
			seleted_item <= 0;
		end else if (keycode_sh == 8'h4b) begin // PAGEUP 	 => column 0
			column_number <= 0;
		end else if (keycode_sh == 8'h4e) begin // PAGEDOWN => column 1
			column_number <= 1;
		
		end else if (keycode_sh == 8'h52) begin // UPARROW => LOOKUP
			if (action_counter[2:0] == 0) begin
				if (theta2 == 360)
					theta2 <= 0;
				else
					theta2 <= (theta2 + 1);
			end
		end else if (keycode_sh == 8'h51) begin // DOWNARROW => LOOKDOWN
			if (action_counter[2:0] == 0) begin
				if (theta2 == 0)
					theta2 <= 359;
				else
					theta2 <= (theta2 - 1);
			end
		end else if (keycode_sh == 8'h4f) begin // RIGHTARROW => LOOKRIGHT
			if (action_counter[2:0] == 0) begin
				if (theta1 == 360)
					theta1 <= 0;
				else
					theta1 <= (theta1 + 1);
			end
		end else if (keycode_sh == 8'h50) begin // LEFTARROW => LOOKLEFT
			if (action_counter[2:0] == 0) begin
				if (theta1 == 0)
					theta1 <= 359;
				else
					theta1 <= (theta1 - 1);
			end
		end else if (keycode_sh == 8'h4a) begin // HOME => BACK2HOME
			cx <= (7 << 16);
			cy <= (4 << 16) + (1 << 15);
			cz <= (4 << 16);
			theta1 <= 0;
			theta2 <= 0;
		end else if (keycode_sh == 8'h0d) begin // J => DESTROY
			destroy_mark <= 1;
			
		end else if (keycode_sh == 8'h0e) begin // K => PLACE
			place_mark <= 1;
			
		end else begin
			destroy_mark <= 0;
			place_mark <= 0;
			destroy_done <= 0;
			place_done <= 0;
		end 
	end else if (BLOCK_UPDATE) begin
		if (destroy_mark && (destroy_done == 0)) begin
			destroy_done <= 1;
			map_reg[gx][gy][gz] <= 4'b0000;
		end
		else if (place_mark && (place_done == 0)) begin
			place_done <= 1;
			if (target_surface == 0) begin
				map_reg[gx][gy][gz-1] <= (column_number * 9 + seleted_item);
			end else if (target_surface == 1) begin
				map_reg[gx-1][gy][gz] <= (column_number * 9 + seleted_item);
			end else if (target_surface == 2) begin
				map_reg[gx][gy-1][gz] <= (column_number * 9 + seleted_item);
			end else if (target_surface == 3) begin // behind face
				map_reg[gx][gy][gz+1] <= (column_number * 9 + seleted_item);
			end else if (target_surface == 4) begin // right face
				map_reg[gx+1][gy][gz] <= (column_number * 9 + seleted_item);
			end else if (target_surface == 5) begin // top face
				map_reg[gx][gy+1][gz] <= (column_number * 9 + seleted_item);
			end
			
		end
	end
end

logic destroy_mark, place_mark, destroy_done, place_done;


int gx, gy, gz, target_x, target_y , target_z;

reg [3:0] map_reg [0:15][0:7][0:15];  // x y z 

logic init_map = 1;
logic BLOCK_UPDATE;



logic current_surface_visible;

//always_ff @(posedge CLK) begin
always_comb begin 
	if ((gx == 0) || (gx == 15) || (gy == 0) || (gy == 7) || (gz == 0) || (gz == 15)) begin // at the edge
		current_surface_visible = 0;
	end else if ((x_min > 319) || (x_max < 0) || (y_max < 0) || (y_min > 179)) begin // block out of the screen
		current_surface_visible = 0;
	end else if ((z0 <= 0) || (z1 <= 0) || (z2 <= 0) || (z3 <= 0)) begin
		current_surface_visible = 0;
	end else begin
		if (surface_id == 0) 
			current_surface_visible = (map_reg[gx][gy][gz-1] == 0);
		else if (surface_id == 1)
			current_surface_visible = (map_reg[gx-1][gy][gz] == 0);
		else if (surface_id == 2)
			current_surface_visible = (map_reg[gx][gy-1][gz] == 0);
		else if (surface_id == 3)
			current_surface_visible = (map_reg[gx][gy][gz+1] == 0);
		else if (surface_id == 4)
			current_surface_visible = (map_reg[gx+1][gy][gz] == 0);
		else if (surface_id == 5)
			current_surface_visible = (map_reg[gx][gy+1][gz] == 0);
		else 
			current_surface_visible = 0;
	end
end

always_ff @(posedge pixel_clk) begin
	if (DrawX == 0 && DrawY == 0 && FrameComplete == 1) begin
//	if (DrawX == 0 && DrawY == 0) begin
//		switch_buffer <= 1;
		FrameComplete <= 0;
		DrawBackground <= 1'b1;
		DrawVertice <= 0;
		DrawSurface <= 0;
		DrawBlocks <= 0;
		DrawSelected <= 0;
		BackX <= 0;
		BackY <= 0;
		wren <= 1;
		write_addr <= 0;
		sx <= 9'b111111111;
		sy <= 9'b111111111;
		oe <= 0;
		surface_counter <= 0;
		target_x <= (-1);
		target_y <= (-1);
		target_z <= (-1);
		target_surface <= 0;	
		gx <= 0;
		gy <= 0;
		gz <= 0;
		BLOCK_UPDATE <= 0;
	end
	
	else begin
		if (DrawBackground) begin
//			switch_buffer <= 0;
			if (BackX == (LENGTH - 1)) begin
				BackX <= 0;
				if (BackY == (WIDTH - 1)) begin // complete drawing of background
					
					DrawBackground <= 0; // Background complete
//					DrawVertice <= 1;
					
//					if (keycode_sh == 8'h00)
//						DrawSurface <= 0;
//						FrameComplete <= 1;
//					else 
					DrawSurface <= 1;
					

					init_cycle <= 1;
					wait_cycle <= 0;
					wait_counter <= 0;
					id_counter <= 0;
					iteration_complete <= 0;
					sx <= x_min;
					sy <= y_min; // tbm
					surface_id <= 0;
					wren <= 0;					
//					gx <= 0;
//					gy <= 0;
//					gz <= 0;

				end else begin
					BackY <= (BackY + 1);
				end
			end else begin
				BackX <= (BackX + 1);
			end
			write_addr <= BackY * LENGTH + BackX;
			z_buffer_write_addr <= BackY * LENGTH + BackX;
			frame_buffer_data <= 8'b00000000;  // this store the sky color, need to modify
			z_in <= 16'b1111111111111111;
		end
	
	
		else if (DrawSurface) begin
			if (map_reg[gx][gy][gz] == 4'b0000) begin
				// skip air
				if (gx == 15) begin
					gx <= 0;
					if (gy == 7) begin
						gy <= 0;
						if (gz == 15) begin
							gz <= 0;
							DrawSurface <= 0;
							if (target_x < 0) begin	
								DrawSelected <= 0;
								surface_id <= 0; 
//								block_id <= (block_id + 1);
								FrameComplete <= 1;
							end else begin
								DrawSelected <= 1;
								gx <= target_x;
								gy <= target_y;
								gz <= target_z;
							end
								
//							block_id <= 7;
							surface_id <= 0;
							
						end else begin
							gz <= (gz + 1);
						end
					end else begin
						gy <= (gy + 1);
					end
				end else begin
					gx <= (gx + 1);
				end

			
			end else begin
				if (surface_id == (surface_num + 1)) begin
//					DrawSurface <= 0;
					surface_id <= 0; 
//					block_id <= (block_id + 1);
					// move to next block
					if (gx == 15) begin
						gx <= 0;
						if (gy == 7) begin
							gy <= 0;
							if (gz == 15) begin
								gz <= 0;
								DrawSurface <= 0;
								if (target_x < 0) begin	
									DrawSelected <= 0;
									surface_id <= 0; 
//									block_id <= (block_id + 1);
									FrameComplete <= 1;
								end else begin
									DrawSelected <= 1;
									gx <= target_x;
									gy <= target_y;
									gz <= target_z;
								end
									
//								block_id <= 7;
								surface_id <= 0;
								
							end else begin
								gz <= (gz + 1);
							end
						end else begin
							gy <= (gy + 1);
						end
					end else begin
						gx <= (gx + 1);
					end
					
					
					
				end else begin
					if (current_surface_visible) begin
						// make all the uv-mapper work.
						if (init_cycle) begin
							if (id_counter == 1) begin
								id_counter <= 0; 
								init_cycle <= 0; 
								wait_cycle <= 1;
								wait_complete <= 0;
							
							end else begin
								if (sx == x_max) begin
									sx <= x_min;
									if (sy == y_max) begin
										sy <= y_min;
									end else begin
										sy <= (sy + 1);
									end
								end else begin
									sx <= (sx + 1);
								end					
								id_counter <= (id_counter + 1);
								qx[id_counter] <=  (sx > 359) ? 359 : ((sx < 0) ? 0 : sx);  // == prev_sx ?? can be moved to init but no big impact
								qy[id_counter] <= (sy > 179) ? 179 : ((sy < 0) ? 0 : sy);
								
							end 
						end
			//		end
			//			// wait until uv-mapper complete calculation
						if (wait_cycle) begin
							if (wait_counter == 1) begin
								wait_cycle <= 0;
								wait_counter <= 0;
								if (iteration_complete == 1) begin
									wait_complete <= 1;
								end
							end else begin
								wait_counter = (wait_counter + 1);
							end
						// write to the ocm
						end else begin
							if (id_counter == 1) begin
								if (wait_complete) begin							
									init_cycle <= 1;
									wait_cycle <= 0;
									wait_counter <= 0;
									id_counter <= 0;
									iteration_complete <= 0;
									sx <= x_min;
									sy <= y_min; // tbm
								end
								wren <= 0;
								id_counter <= 0;
								wait_cycle <= 1;
							end else begin
								if (sx == x_max) begin
									sx <= x_min;
									if (sy == y_max) begin
										sy <= y_min;
										iteration_complete <= 1;
										surface_id <= (surface_id + 1);
									end else begin
										sy <= (sy + 1);
									end
								end else begin
									sx <= (sx + 1);
								end
								if (ins[id_counter] && (qz[id_counter] <= z_out_sh) && (qz[id_counter] > 0)) begin// in quad and z-depth is smaller
									wren <= 1;
									if ((qx[id_counter] == 160) && (qy[id_counter] == 90)) begin
										target_x <= gx;
										target_y <= gy;
										target_z <= gz;
										target_surface <= surface_id;
									end
								end else begin
									wren <= 0;
								end
								id_counter <= (id_counter + 1);
								// get uv for the current pixel
								qx[id_counter] <=  (sx > 359) ? 359 : ((sx < 0) ? 0 : sx);  // == prev_sx ?? can be moved to init but no big impact
								qy[id_counter] <= (sy > 179) ? 179 : ((sy < 0) ? 0 : sy);
								
								
								// write the color of the pixel to frame buffer
								write_addr <= (qy[id_counter]) * LENGTH + (qx[id_counter]);
								texture_u = qu[id_counter]; // not sure
								texture_v = qv[id_counter];		
								frame_buffer_data <= texture_data_sh; // (4 * (surface_id + 1)); // texture_data; // surface_id; // texture_data;
								
								z_in <= qz[id_counter]; // surface_id;
								
							end
						end
					end else begin
						surface_id <= (surface_id + 1);
					end
				end 
			end
		end 
		
		else if (DrawSelected == 1) begin
			if (surface_id == (surface_num + 1)) begin
					DrawSelected <= 0;
					surface_id <= 0; 
//					block_id <= (block_id + 1);
					if (destroy_mark || place_mark) begin
						BLOCK_UPDATE <= 1;
					end else begin
						BLOCK_UPDATE <= 0;
					end
					FrameComplete <= 1;
				end else begin
					// make all the uv-mapper work.
					if (init_cycle) begin
						if (id_counter == 1) begin
							id_counter <= 0; 
							init_cycle <= 0; 
							wait_cycle <= 1;
							wait_complete <= 0;
						
						end else begin
							if (sx == x_max) begin
								sx <= x_min;
								if (sy == y_max) begin
									sy <= y_min;
								end else begin
									sy <= (sy + 1);
								end
							end else begin
								sx <= (sx + 1);
							end					
							id_counter <= (id_counter + 1);
							qx[id_counter] <=  (sx > 359) ? 359 : ((sx < 0) ? 0 : sx);  // == prev_sx ?? can be moved to init but no big impact
							qy[id_counter] <= (sy > 179) ? 179 : ((sy < 0) ? 0 : sy);
							
						end 
					end
		//		end
		//			// wait until uv-mapper complete calculation
					if (wait_cycle) begin
						if (wait_counter == 1) begin
							wait_cycle <= 0;
							wait_counter <= 0;
							if (iteration_complete == 1) begin
								wait_complete <= 1;
							end
						end else begin
							wait_counter = (wait_counter + 1);
						end
					// write to the ocm
					end else begin
						if (id_counter == 1) begin
							if (wait_complete) begin							
								init_cycle <= 1;
								wait_cycle <= 0;
								wait_counter <= 0;
								id_counter <= 0;
								iteration_complete <= 0;
								sx <= x_min;
								sy <= y_min; // tbm
							end
							wren <= 0;
							id_counter <= 0;
							wait_cycle <= 1;
						end else begin
							if (sx == x_max) begin
								sx <= x_min;
								if (sy == y_max) begin
									sy <= y_min;
									iteration_complete <= 1;
									surface_id <= (surface_id + 1);
								end else begin
									sy <= (sy + 1);
								end
							end else begin
								sx <= (sx + 1);
							end
							if (ins[id_counter] && (qz[id_counter] <= z_out_sh) && (qz[id_counter] > 0)) 
//							&& ((qu[id_counter] == 0) || (qu[id_counter] == 4'b1111) 
//							||  (qv[id_counter] == 0) || (qv[id_counter] == 4'b1111))) // in quad and z-depth is smaller
								wren <= 1;
							else
								wren <= 0;
							id_counter <= (id_counter + 1);
							// get uv for the current pixel
							qx[id_counter] <=  (sx > 359) ? 359 : ((sx < 0) ? 0 : sx);  // == prev_sx ?? can be moved to init but no big impact
							qy[id_counter] <= (sy > 179) ? 179 : ((sy < 0) ? 0 : sy);
							
							
							// write the color of the pixel to frame buffer
							write_addr <= (qy[id_counter]) * LENGTH + (qx[id_counter]);
							texture_u = qu[id_counter]; // not sure
							texture_v = qv[id_counter];		
							frame_buffer_data <= (texture_data_sh + 1); // surface_id; // texture_data;
							
							z_in <= qz[id_counter]; // surface_id;
							
						end
					end
				end

		end
		
		
		else begin // end drawing
			wren <= 0;
		end
		
	end
end


always_ff @(posedge pixel_clk) begin
	read_addr <= ((DrawY >> 1) * 320) + (DrawX >> 1);
	z_buffer_read_addr <= ((qy[0] * LENGTH) + qx[0]);
end

always_ff @(posedge CLK) begin
	z_out_sh <= z_out;
	texture_data_sh <= texture_data;
//	if ((DrawX == 0) && (DrawY == 0) && (FrameComplete == 1))
//		switch_buffer <= 1;
//	else
//		switch_buffer <= 0;
end

logic switch_buffer;

double_frame_buffer dfb(.CLK, .pixel_clk, .RESET, .wren, .switch_buffer(vs), 
.FrameComplete, .frame_buffer_data, .read_addr, .write_addr, .palette_color);

parameter COLOR1 = 12'b101010101010;	
parameter COLOR2 = 12'b001100110011;	
parameter COLOR3 = 12'b110111011101;	// LIGHT
parameter COLOR4 = 12'b010101010101;   // UNLOCKED COLOR

//parameter COLOR2 = 12'b110111011101;	
logic [10:0] x_item;
logic [10:0] y_item;
logic [4:0] id_item;
logic [7:0] p_item, p_addr;
logic [11:0] c_item, color_item;

texture_rom texture_rom1(.clk(CLK), .id(BLOCK_FACE_ID[id_item][29:25]), .x(x_item), .y(y_item), .data(p_item));

palette_rom p1(.addr(p_addr), .data(c_item));


//// make selected be brighter
always_comb begin
	if (id_item == ((column_number * 9 + seleted_item))) 
		p_addr = (p_item + 1);
	else
		p_addr = p_item;
end

always_comb begin
	if (1) 
		color_item = c_item;
	else 
		color_item = COLOR4;
end

always_ff @(posedge pixel_clk) begin
	if (DrawY <= 355) begin
		if ((DrawX >= 316) && (DrawX <= 322)) begin
			if (DrawY == 179) begin
				color <= 12'b100110011001;
			end else if ((DrawY >= 176) && (DrawY <= 182) && (DrawX == 319)) begin
				color <= 12'b100110011001;
			end else begin
				color <= palette_color;
			end
		end else begin
			color <= palette_color;
		end
	end else if (DrawY == 356) begin
		color <= 12'b001100110011;
	end else if (DrawY == 357) begin
		color <= 12'b111011101110;
	end else begin
//		if (DrawX < 484) begin
//			if (DrawY > 360) begin
//				if (DrawY[4:0] == 0) begin // white light
//					color <= 12'b111011101110;
//				end else if (DrawY[4:0] >= 1 && DrawY[4:0] < 4) begin // orignal color
//					color <= 12'b110111011101;
//				end else if (DrawY[4:0] == 4) begin	// nearly black for shader
//					color <= 12'b001100110011;
//				end else begin
//					if (DrawX[4:0] == 0) begin
//						color <= 12'b111011101110;
//					end else if (DrawX[4:0] >= 1 && DrawX[4:0] < 4) begin
//						color <= 12'b110111011101;
//					end else if (DrawX[4:0]  == 4) begin
//						color <= 12'b001100110011;
//					end else begin
//						color <= 12'b100010001000;
//					end
//				end
//			end
//		end else begin
//			color <= 12'b110011001100;
//		end
if (DrawY <= 375) begin
	color <= COLOR1;
end else if (DrawY <= 407) begin
	y_item = (DrawY - 376) >> 1;
	if (DrawX <= 119) begin
		color <= COLOR1;
	end else if (DrawX <= 151) begin
		if ((DrawX == 120) || (DrawX == 121) || (DrawY == 376) || (DrawY == 377))
			color <= COLOR2;
		else if ((DrawX == 150) || (DrawX == 151) || (DrawY == 406) || (DrawY == 407))
			color <= COLOR3;
		else 
			color <= color_item;  
		x_item = (DrawX - 120) >> 1;
		id_item <= 1; 
	end else if (DrawX <= 165) begin
		color <= COLOR1;
	end else if (DrawX <= 197) begin
		if ((DrawX == 166) || (DrawX == 167) || (DrawY == 376) || (DrawY == 377))
			color <= COLOR2;
		else if ((DrawX == 196) || (DrawX == 197) || (DrawY == 406) || (DrawY == 407))
			color <= COLOR3;
		else
			color <= color_item; 
		x_item = (DrawX - 166) >> 1;
		id_item <= 2;
	end else if (DrawX <= 211) begin
		color <= COLOR1;
	end else if (DrawX <= 243) begin
		if ((DrawX == 212) || (DrawX == 213) || (DrawY == 376) || (DrawY == 377)) 
			color <= COLOR2;
		else if ((DrawX == 242) || (DrawX == 243) || (DrawY == 406) || (DrawY == 407))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX - 212) >> 1;
		id_item <= 3;
	end else if (DrawX <= 257) begin
		color <= COLOR1;
	end else if (DrawX <= 289) begin
		if ((DrawX == 258) || (DrawX == 259) || (DrawY == 376) || (DrawY == 377)) 
			color <= COLOR2;
		else if ((DrawX == 288) || (DrawX == 289) || (DrawY == 406) || (DrawY == 407))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX - 258) >> 1;
		id_item <= 4;
	end else if (DrawX <= 303) begin
		color <= COLOR1;
	end else if (DrawX <= 335) begin
		if ((DrawX == 304) || (DrawX == 305) || (DrawY == 376) || (DrawY == 377)) 
			color <= COLOR2;
		else if ((DrawX == 334) || (DrawX == 335) || (DrawY == 406) || (DrawY == 407))
			color <= COLOR3;
		else 
			color <= color_item;  
		x_item = (DrawX - 304) >> 1;
		id_item <= 5;
	end else if (DrawX <= 349) begin
		color <= COLOR1;
	end else if (DrawX <= 381) begin
		if ((DrawX == 350) || (DrawX == 351) || (DrawY == 376) || (DrawY == 377)) 
			color <= COLOR2;
		else if ((DrawX == 380) || (DrawX == 381) || (DrawY == 406) || (DrawY == 407))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX - 350) >> 1;
		id_item <= 6;
	end else if (DrawX <= 395) begin
		color <= COLOR1;
	end else if (DrawX <= 427) begin
		if ((DrawX == 396) || (DrawX == 397) || (DrawY == 376) || (DrawY == 377)) 
			color <= COLOR2;
		else if ((DrawX == 426) || (DrawX == 427) || (DrawY == 406) || (DrawY == 407))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX - 396)>>1;
		id_item <= 7;
	end else if (DrawX <= 441) begin
		color <= COLOR1;
	end else if (DrawX <= 473) begin
		if ((DrawX == 442) || (DrawX == 443) || (DrawY == 376) || (DrawY == 377)) 
			color <= COLOR2;
		else if ((DrawX == 472) || (DrawX == 473) || (DrawY == 406) || (DrawY == 407))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX-442)>>1;
		id_item <= 8;
	end else if (DrawX <= 487) begin
		color <= COLOR1;
	end else if (DrawX <= 519) begin
		if ((DrawX == 488) || (DrawX == 489) || (DrawY == 376) || (DrawY == 377)) 
			color <= COLOR2;
		else if ((DrawX == 518) || (DrawX == 519) || (DrawY == 406) || (DrawY == 407))
			color <= COLOR3;
		else
			color <= color_item; 
		x_item = (DrawX - 488) >> 1;
		id_item <= 9;
	end else begin
		color <= COLOR1;
	end
end else if (DrawY <= 425) begin
	color <= COLOR1;
end else if (DrawY <= 457) begin
	y_item = (DrawY - 426) >> 1;
	if (DrawX <= 119) begin
		color <= COLOR1;
	end else if (DrawX <= 151) begin
		if ((DrawX == 120) || (DrawX == 121) || (DrawY == 426) || (DrawY == 427)) 
			color <= COLOR2;
		else if ((DrawX == 150) || (DrawX == 151) || (DrawY == 456) || (DrawY == 457))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX - 120) >> 1;
		id_item <= 10;
	end else if (DrawX <= 165) begin
		color <= COLOR1;
	end else if (DrawX <= 197) begin
		if ((DrawX == 166) || (DrawX == 167) || (DrawY == 426) || (DrawY == 427)) 
			color <= COLOR2;
		else if ((DrawX == 196) || (DrawX == 197) || (DrawY == 456) || (DrawY == 457))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX - 166) >> 1;
		id_item <= 11;
	end else if (DrawX <= 211) begin
		color <= COLOR1;
	end else if (DrawX <= 243) begin
		if ((DrawX == 212) || (DrawX == 213) || (DrawY == 426) || (DrawY == 427)) 
			color <= COLOR2;
		else if ((DrawX == 242) || (DrawX == 243) || (DrawY == 456) || (DrawY == 457))
			color <= COLOR3;
		else
			color <= color_item; 
		x_item = (DrawX - 212) >> 1;
		id_item <= 12;
	end else if (DrawX <= 257) begin
		color <= COLOR1;
	end else if (DrawX <= 289) begin
		if ((DrawX == 258) || (DrawX == 259) || (DrawY == 426) || (DrawY == 427)) 
			color <= COLOR2;
		else if ((DrawX == 288) || (DrawX == 289) || (DrawY == 456) || (DrawY == 457))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX - 258) >> 1;
		id_item <= 13;
	end else if (DrawX <= 303) begin
		color <= COLOR1;
	end else if (DrawX <= 335) begin
		if ((DrawX == 304) || (DrawX == 305) || (DrawY == 426) || (DrawY == 427)) 
			color <= COLOR2;
		else if ((DrawX == 334) || (DrawX == 335) || (DrawY == 456) || (DrawY == 457))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX - 304) >> 1;
		id_item <= 14;
	end else if (DrawX <= 349) begin
		color <= COLOR1;
	end else if (DrawX <= 381) begin
		if ((DrawX == 350) || (DrawX == 351) || (DrawY == 426) || (DrawY == 427)) 
			color <= COLOR2;
		else if ((DrawX == 380) || (DrawX == 381) || (DrawY == 456) || (DrawY == 457))
			color <= COLOR3;
		else
			color <= color_item;  
		x_item = (DrawX - 350) >> 1;
		id_item <= 15;
	end else if (DrawX <= 395) begin
		color <= COLOR1;
	end else if (DrawX <= 427) begin
		if ((DrawX == 396) || (DrawX == 397) || (DrawY == 426) || (DrawY == 427)) 
			color <= COLOR2;
		else if ((DrawX == 426) || (DrawX == 427) || (DrawY == 456) || (DrawY == 457))
			color <= COLOR3;
		else
			color <= COLOR4;  
		x_item = (DrawX - 396)>>1;
	end else if (DrawX <= 441) begin
		color <= COLOR1;
	end else if (DrawX <= 473) begin
		if ((DrawX == 442) || (DrawX == 443) || (DrawY == 426) || (DrawY == 427)) 
			color <= COLOR2;
		else if ((DrawX == 472) || (DrawX == 473) || (DrawY == 456) || (DrawY == 457))
			color <= COLOR3;
		else
			color <= COLOR4;  
		x_item = (DrawX - 442)>>1;
	end else if (DrawX <= 487) begin
		color <= COLOR1;
	end else if (DrawX <= 519) begin
		if ((DrawX == 488) || (DrawX == 489) || (DrawY == 426) || (DrawY == 427)) 
			color <= COLOR2;
		else if ((DrawX == 518) || (DrawX == 519) || (DrawY == 456) || (DrawY == 457))
			color <= COLOR3;
		else
			color <= COLOR4;  
		x_item = (DrawX - 488) >> 1;
	end else begin
		color <= COLOR1;
	end
end else begin
	color <= COLOR1;
end


	end
end



//	end
//	if (DrawX >= 0 & DrawX < 640 & DrawY >= 0 & DrawY < 360) begin
//		color <= palette_color;
//	end
//	else begin
//		color <= 12'b000000000000;
//	end
//end
		

assign VGA_R[3:0] = 4'h0;
assign VGA_G[3:0] = 4'h0;
assign VGA_B[3:0] = 4'h0;

//always_ff @(posedge pixel_clk) begin
always_comb begin
    if (!DrawX) begin
        VGA_R[7:4]   = 8'h00; // Non-blocking assignment
        VGA_G[7:4] = 8'h00;
        VGA_B[7:4]  = 8'h00;
    end
    else if (!blank) begin
        VGA_R[7:4]   = 8'h00;
        VGA_G[7:4] 	= 8'h00;
        VGA_B[7:4]  	= 8'h00;
    end
    else if (RESET) begin
        VGA_R[7:4]   = 8'h00;
        VGA_G[7:4] 	= 8'h00;
        VGA_B[7:4]  	= 8'h00;
    end
    else begin
        VGA_R[7:4]	= color[11:8]; // Extracting MSBs for red
        VGA_G[7:4]	= color[7:4];  // Extracting middle bits for green
        VGA_B[7:4]	= color[3:0];  // Extracting LSBs for blue
    end
end


endmodule

