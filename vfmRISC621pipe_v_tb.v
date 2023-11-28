// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

`include "vfm_ir2assembly_v.v"
`define SIMULATION

module vfmRISC621pipe_v_tb;

reg         Resetn_tb       ; // Active low reset signal
reg         Clock_tb        ;
reg  [ 4:0] SW_in_tb        ; // Switches In
wire [ 7:0] Display_out_tb  ; // LEDs Out
wire [95:0] ICis_MC3_tb     ; // Instruction to ASCII
wire [95:0] ICis_MC2_tb     ; // Instruction to ASCII
wire [95:0] ICis_MC1_tb     ; // Instruction to ASCII
wire [13:0] Output_IO_0_tb ;
wire [13:0] Output_IO_1_tb ;
wire [13:0] Output_IO_2_tb ;
wire [13:0] Output_IO_3_tb ;
wire Write_output_1_tb;
wire Write_output_2_tb;
wire Write_output_3_tb;



// wire [13:0] IO_OUTPUT [15:0];
wire [13:0] Peripheral_input_tb;
reg [15:0] clock_count;

// Design under test instantiation
vfmRISC621pipe_v dut(
    .Resetn_pin         ( Resetn_tb             ), // Reset, implemented with push-button on FPGA
    .Clock_pin          ( Clock_tb              ), // Clock, implemented with Oscillator on FPGA
    .Input_write        ( SW_in_tb[4]           ), // Write enable for the input peripheral
    
    .In0               (Peripheral_input_tb),
    .In1               (),
    .In2               (),
    .In3               (),
    .In4               (),
    .In5               (),
    .In6               (),
    .In7               (),
    .In8               (),
    .In9               (),
    .In10              (),
    .In11              (),
    .In12              (),
    .In13              (),
    .In14              (),
    .In15              (),

    .Out0               (display_out),
    .Out1               (),
    .Out2               (),
    .Out3               (),
    .Out4               (),
    .Out5               (),
    .Out6               (),
    .Out7               (),
    .Out8               (),
    .Out9               (),
    .Out10              (),
    .Out11              (),
    .Out12              (),
    .Out13              (),
    .Out14              (),
    .Out15              (),

    .Write_output_0     (),
    .Write_output_1     (),
    .Write_output_2     (),
    .Write_output_3     ()


);

assign Peripheral_input_tb = {11'd0, SW_in_tb};
assign Display_out_tb = Output_IO_0_tb[7:0];

// Instruction to Ascii Translators, note use of hierarchical/virtual routing
vfm_ir2assembly_v instruction_translate_1(
    .IR           ( dut.IR1        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.Resetn_pin        ), // Reset within dut
    .ICis         ( ICis_MC1_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_2(
    .IR           ( dut.IR2        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.Resetn_pin        ), // Reset within dut
    .ICis         ( ICis_MC2_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_3(
    .IR           ( dut.IR3        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.Resetn_pin        ), // Reset within dut
    .ICis         ( ICis_MC3_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);

// Setup Free-Running Clock
always #20000 Clock_tb = ~(Clock_tb === 1'd1);

always @(posedge Clock_tb) begin
clock_count = clock_count + 1'b1;
end

initial begin 
    // Reset DUT
    Resetn_tb = 1'd0;
    SW_in_tb  = 5'b00000;
    clock_count = 16'd0;
    repeat (4) @(posedge Clock_tb);

    // Take DUT out of Reset
    Resetn_tb = 1'd1;

    // Assert inputs to desired value
    SW_in_tb  = 5'b01111;

/**********************************************************************************************
*   - Run simulation for 33 clocks, without pipelining this example required 81.              *
*   - What is the relative speedup for this example?                                          *
*          ie: how do we express the increased throughput per unit time for the pipeline?     *
*   - Speedup = old execution time / new execution time = 81 / 33 = 2.45                      *
*   - Now apply Ahmdal's Law to compare!                                                      *
*   - Speedup (S) = 1/((1-Fraction Enhanced)+(Fraction Enhanced/Speedup Enhanced))            *
*           - 16 instructions in this architecture, 3 of them stall the pipeline              *
*           - an instruction which does not stall execution should be 4x faster               *
*           - assume (though incorrectly!) that each instruction is used equally              *
*   - S = 1/((1-13/16)+((13/16)/4)) = 2.56                                                    *
**********************************************************************************************/

// What is the speedup for your design? 
    // Hint: write a basic program that does "something useful" and mildly complex, run it with pipeline enabled and disabled, compare difference in execution time
    // Does the calculated speedup match the experimental speedup? Why or why not?
    repeat (10) @(posedge Clock_tb);

    SW_in_tb = 5'b11111;
    
    repeat (10) @(posedge Clock_tb);

    SW_in_tb = 5'b01111;

    repeat (100) @(posedge Clock_tb);

    SW_in_tb = 5'b11010;

    repeat (100) @(posedge Clock_tb);

    SW_in_tb = 5'b11110;

    repeat (100) @(posedge Clock_tb);

    SW_in_tb = 5'b11011;

    repeat (100) @(posedge Clock_tb);

    // Run simulation for additional 15 clock cycles for human observation
    repeat (15) @(posedge Clock_tb);

    // End simultaion (normally we would use "$finish()" but modelsim prefers "$stop()")
    $stop();
end

endmodule
