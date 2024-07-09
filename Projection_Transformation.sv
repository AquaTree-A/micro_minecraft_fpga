module p_transformation (
    input logic CLK,                  // Clock signal
	 input logic OE, 
//    input logic signed [23:0] x,       // Signed X coordinate after view transformation
//    input logic signed [23:0] y,       // Signed Y coordinate after view transformation
//    input logic signed [23:0] z,       // Signed Z coordinate after view transformation (must be non-zero)
	 input int x, y, z,
    output logic signed [9:0] x_screen,  // Projected X coordinate on screen
    output logic signed [9:0] y_screen   // Projected Y coordinate on screen
);

    // Constants for projection and screen dimensions
    parameter integer d = 128;             // Distance from viewer to screen, adjusted for smaller screen size
    parameter integer screen_width = 320;  // Screen width
    parameter integer screen_height = 180; // Screen height

    // Temporary variables for perspective calculation and clamping
    logic signed [31:0] xt, yt, x_temp, y_temp, x_ndc, y_ndc;  // Calculated NDC coordinates

    always_ff @(posedge CLK) begin
//		  if (OE) begin 
				if (z != 0) begin
					// Calculate perspective projection in NDC					
					x_temp = (64 * x) / z; // / 65536; // $signed(xt) >> 16;
					y_temp = (64 * y) / z; // / 65536; // $signed(yt) >> 16;

					// Clamp NDC coordinates to the range [-128, 128] assuming NDC should be in [-1, 1]
					// We scale this to [-128, 128] because screen dimensions require wider range due to d value
					x_ndc = (x_temp > 256) ? 256 : ((x_temp < -256) ? -256 : x_temp);
					y_ndc = (y_temp > 256) ? 256 : ((y_temp < -256) ? -256 : y_temp);

					// Map from NDC to screen coordinates
					x_screen <= 160 + x_ndc;
					y_screen <= 90 - y_ndc;
				end else begin
					// Handle the case where z = 0 to avoid division by zero
					x_screen <= screen_width / 2;  // Default to center of screen
					y_screen <= screen_height / 2;
				end
//			end else begin
//				x_screen <= 9'b111111111;
//				y_screen <= 9'b111111111;
//			end
    end

//    // Output synchronization with the clock
//    always_ff @(posedge CLK) begin
//		  if (OE) begin
//			  x_screen <= x_screen;
//			  y_screen <= y_screen;
//		  end else begin
//			  x_screen <= 9'b111111111;
//			  y_screen <= 9'b111111111;
//		  end
//    end

endmodule
