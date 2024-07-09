module texture_mapping(
    input logic CLK,
    input logic RESET,
    input logic signed [9:0] x0, y0, u0, v0,  // Vertex 0 with UV
    input logic signed [9:0] x1, y1, u1, v1,  // Vertex 1 with UV
    input logic signed [9:0] x2, y2, u2, v2,  // Vertex 2 with UV
    input logic signed [9:0] x3, y3, u3, v3,  // Vertex 3 with UV
    input logic signed [9:0] qx, qy,	       // Query point
	 input logic signed [15:0] z0, z1, z2, z3,
    output logic is_inside,                   // Is the query point inside the quadrilateral?
    output logic signed [3:0] qu, qv,          // Interpolated UV coordinates
	 output logic signed [15:0] qz
);

    // Variables to hold triangle areas for barycentric coordinates
    logic signed [31:0] area0, area1, area2, area_total_1,
								area3, area4, area5, area_total_2, zz;

    always_ff @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            is_inside <= 0;
            qu <= 0;
            qv <= 0;
				qz <= 16'b1111111111111111;
        end else begin
            // Calculate signed areas for barycentric coordinates without using functions
            area0 = (qx - x1) * (y2 - y1) - (qy - y1) * (x2 - x1);
            area1 = (qx - x2) * (y0 - y2) - (qy - y2) * (x0 - x2);
            area2 = (qx - x0) * (y1 - y0) - (qy - y0) * (x1 - x0);

            area3 = (qx - x3) * (y0 - y3) - (qy - y3) * (x0 - x3);
				area4 = (qx - x2) * (y3 - y2) - (qy - y2) * (x3 - x2);
				area5 = (qx - x0) * (y2 - y0) - (qy - y0) * (x2 - x0);
				
				if 			((area0 >= 0 && area1 >= 0 && area2 >= 0) 
							||  (area0 <= 0 && area1 <= 0 && area2 <= 0)) begin
					is_inside <= 1;
					qu <= (u0 * area0 + u1 * area1 + u2 * area2) / (area0 + area1 + area2);
					qv <= (v0 * area0 + v1 * area1 + v2 * area2) / (area0 + area1 + area2);
					zz <= (z0 * area0 + z1 * area1 + z2 * area2) / (area0 + area1 + area2);
//					if (zz <= 0)
//						qz <= 16'b1111111111111111;
//					else 
						qz <= zz[15:0];
            end else if ((area3 >= 0 && area4 >= 0 && area5 >= 0) 
							||  (area3 <= 0 && area4 <= 0 && area5 <= 0)) begin
					is_inside <= 1;
					qu <= (u3 * area5 + u2 * area3 + u0 * area4) / (area3 + area4 + area5);
					qv <= (v3 * area5 + v2 * area3 + v0 * area4) / (area3 + area4 + area5);
					zz <= (z3 * area5 + z2 * area3 + z0 * area4) / (area3 + area4 + area5);
//					if (zz <= 0)
//						qz <= 16'b1111111111111111;
//					else 
						qz <= zz[15:0];
				end else begin 
                is_inside <= 0;
                qu <= 0;
                qv <= 0;
					 qz <= 16'b1111111111111111;
            end
        end
    end
endmodule
