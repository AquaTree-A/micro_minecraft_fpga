// Interface between NIOS II and EZ-OTG chip
module hpi_io_intf( input        Clk, Reset,
                    input [1:0]  from_sw_address,
                    output[15:0] from_sw_data_in,
                    input [15:0] from_sw_data_out,
                    input        from_sw_r, from_sw_w, from_sw_cs, from_sw_reset, // Active low
                    inout [15:0] OTG_DATA,
                    output[1:0]  OTG_ADDR,
                    output       OTG_RD_N, OTG_WR_N, OTG_CS_N, OTG_RST_N // Active low
                   );

// Buffer (register) for from_sw_data_out because inout bus should be driven 
//   by a register, not combinational logic.
logic [15:0] from_sw_data_out_buffer;

// TODO: Fill in the blanks below. 
always_ff @ (posedge Clk)
begin
    if(Reset)
    begin //set signal resets if reset is pressed on the fpga board. Some signals are active low so accomodate for that.
        from_sw_data_out_buffer <= 16'b0;
        OTG_ADDR                <= 2'b0;
        OTG_RD_N                <= 1'b1;
        OTG_WR_N                <= 1'b1;
        OTG_CS_N                <= 1'b0;
        OTG_RST_N               <= 1'b0;
        from_sw_data_in         <= 16'b0;
    end
    else 
    begin //if reset is not pressed then pass through the values that were passed into the module and don't reset anything.
        from_sw_data_out_buffer <= from_sw_data_out;
        OTG_ADDR                <= from_sw_address;
        OTG_RD_N                <= from_sw_r;
        OTG_WR_N                <= from_sw_w;
        OTG_CS_N                <= from_sw_cs;
        OTG_RST_N               <= 1'b1;
        from_sw_data_in         <= OTG_DATA;
    end
end

// OTG_DATA should be high Z (tristated) when NIOS is not writing to OTG_DATA inout bus.
// Look at tristate.sv in lab 6 for an example.
// Drive (write to) Data bus only when tristate_output_enable is active.
//assign Data = tristate_output_enable ? Data_write_buffer : {N{1'bZ}};
assign OTG_DATA = ~from_sw_w ? from_sw_data_out_buffer : {16'bZ};

endmodule 