//module v_transformation (
//    input logic CLK,                  // Clock signal
//	 input int cx, cy, cz,
//    input logic [7:0] x,       // Signed X coordinate after view transformation
//    input logic [7:0] y,       // Signed Y coordinate after view transformation
//    input logic [7:0] z,       // Signed Z coordinate after view transformation (must be non-zero)
////    output logic signed [23:0] x_view,  
////    output logic signed [23:0] y_view,  
////	 output logic signed [23:0] z_view
//	output int x_view, y_view, z_view
//); 
//	always_ff @(posedge CLK) begin
//		x_view <= (int'(x) << 16) - cx;
//		y_view <= (int'(y) << 16) - cy;
//		z_view <= (int'(z) << 16) - cz;
//	end
////	always_comb begin
////		x_view = x * 4;// * 2; 
////		y_view = y * 4;// * 2; 
////		z_view = z * 4;// * 2; 
////	end
//endmodule

module v_transformation (
    input logic CLK,                  // Clock signal
    input int cx, cy, cz,
	 input int cos_theta1, sin_theta1, cos_theta2, sin_theta2,
    input logic [7:0] x,       // Signed X coordinate after view transformation
    input logic [7:0] y,       // Signed Y coordinate after view transformation
    input logic [7:0] z,       // Signed Z coordinate after view transformation (must be non-zero)
    output int x_view, y_view, z_view
); 

    longint x_rot1, z_rot1;
    longint y_rot2, z_rot2;
	 
    always_ff @(posedge CLK) begin
        // Apply rotation around Y-axis (XZ plane)
        x_rot1 <= (longint'(x) * cos_theta1 - longint'(z) * sin_theta1);
        z_rot1 <= (longint'(x) * sin_theta1 + longint'(z) * cos_theta1);
        
        // Apply rotation around X-axis (YZ plane)
        y_rot2 <= (longint'(y) * cos_theta2 - ((z_rot1 * sin_theta2) >>> 16));
        z_rot2 <= (longint'(y) * sin_theta2 + ((z_rot1 * cos_theta2) >>> 16));
        
        // Apply translation (view transformation)
        x_view <= (x_rot1) - cx;
        y_view <= (y_rot2) - cy;
        z_view <= (z_rot2) - cz;
    end
endmodule
