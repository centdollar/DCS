// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

`include "vfm_ir2assembly_v.v"
`include "TestBenchControl.vh"

module vfmRISC621pipe_v_tb;

reg         Resetn_tb       ; // Active low reset signal
reg         Clock_tb        ;
reg  [ 4:0] SW_in_tb        ; // Switches In
wire [ 7:0] Display_out_tb  ; // LEDs Out
reg [15:0] interrupt_input;


wire [15:0] Output_IO_0_tb ;
wire [15:0] Output_IO_1_tb ;
wire [15:0] Output_IO_2_tb ;
wire [15:0] Output_IO_3_tb ;
wire Write_output_1_tb;
wire Write_output_2_tb;
wire Write_output_3_tb;



// wire [13:0] IO_OUTPUT [15:0];
wire [15:0] Peripheral_input_tb;
reg [15:0] clock_count;



`ifdef SINGLECORE
wire [111:0] ICis_MC3_tb     ; // Instruction to ASCII
wire [111:0] ICis_MC2_tb     ; // Instruction to ASCII
wire [111:0] ICis_MC1_tb     ; // Instruction to ASCII

// // Design under test instantiation
// vfmRISC621pipe_v dut(
//     .Resetn_pin         ( Resetn_tb             ), // Reset, implemented with push-button on FPGA
//     .Clock_pin          ( Clock_tb              ), // Clock, implemented with Oscillator on FPGA
//     .Input_write        ( SW_in_tb[4]           ), // Write enable for the input peripheral
    
//     .In0               (Peripheral_input_tb),
//     .In1               (),
//     .In2               (),
//     .In3               (),
//     .In4               (),
//     .In5               (),
//     .In6               (),
//     .In7               (),
//     .In8               (),
//     .In9               (),
//     .In10              (),
//     .In11              (),
//     .In12              (),
//     .In13              (),
//     .In14              (),
//     .In15              (),

//     .Out0               (Output_IO_0_tb),
//     .Out1               (),
//     .Out2               (),
//     .Out3               (),
//     .Out4               (),
//     .Out5               (),
//     .Out6               (),
//     .Out7               (),
//     .Out8               (),
//     .Out9               (),
//     .Out10              (),
//     .Out11              (),
//     .Out12              (),
//     .Out13              (),
//     .Out14              (),
//     .Out15              (),

//     .Write_output_0     (),
//     .Write_output_1     (),
//     .Write_output_2     (),
//     .Write_output_3     ()  


// );
vfm_proc_inst_v dut(
    .clock_in(Clock_tb),
    .resetn(Resetn_tb),
    .SW_in(SW_in_tb),
    .LEDS(Display_out_tb)

);
`ifdef NOCACHE
// defparam dut.core0.MM.altsyncram_component.init_file = "dcs_lab11_part3.mif";
defparam dut.core0.PM.altsyncram_component.init_file = "test16.mif";
`else
// defparam dut.core0.MM.main_mem.altsyncram_component.init_file = "dcs_lab11_part3.mif";
defparam dut.core0.PM.PM.altsyncram_component.init_file = "test16.mif";
`endif

vfm_ir2assembly_v instruction_translate_1(
    .IR           ( dut.core0.IR1        [15:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core0.Resetn_pin        ), // Reset within dut
    .ICis         ( ICis_MC1_tb    [111:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_2(
    .IR           ( dut.core0.IR2        [15:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core0.Resetn_pin        ), // Reset within dut
    .ICis         ( ICis_MC2_tb    [111:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_3(
    .IR           ( dut.core0.IR3        [15:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core0.Resetn_pin        ), // Reset within dut
    .ICis         ( ICis_MC3_tb    [111:0] )  // ASCII stream translating IR from Binary to English
);


// Instruction to Ascii Translators, note use of hierarchical/virtual routing
`elsif MULTICORE2
wire [95:0] IC0is_MC3_tb     ; // Instruction to ASCII
wire [95:0] IC0is_MC2_tb     ; // Instruction to ASCII
wire [95:0] IC0is_MC1_tb     ; // Instruction to ASCII
wire [95:0] IC1is_MC3_tb     ; // Instruction to ASCII
wire [95:0] IC1is_MC2_tb     ; // Instruction to ASCII
wire [95:0] IC1is_MC1_tb     ; // Instruction to ASCII

vfm_proc_inst_v dut(
    .clock_in(Clock_tb),
    .resetn(Resetn_tb),
    .SW_in(SW_in_tb),
    .LEDS(Display_out_tb)

);
`ifdef NOCACHE
defparam dut.core0.MM.altsyncram_component.init_file = "core0.mif";
defparam dut.core1.MM.altsyncram_component.init_file = "core1.mif";
`else
defparam dut.core0.MM.main_mem.altsyncram_component.init_file = "core0.mif";
defparam dut.core1.MM.main_mem.altsyncram_component.init_file = "core1.mif";
`endif




vfm_ir2assembly_v instruction_translate_1(
    .IR           ( dut.core0.IR1        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core0.Resetn_pin        ), // Reset within dut
    .ICis         ( IC0is_MC1_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_2(
    .IR           ( dut.core0.IR2        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core0.Resetn_pin        ), // Reset within dut
    .ICis         ( IC0is_MC2_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_3(
    .IR           ( dut.core0.IR3        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core0.Resetn_pin        ), // Reset within dut
    .ICis         ( IC0is_MC3_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);

vfm_ir2assembly_v instruction_translate_4(
    .IR           ( dut.core1.IR1        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core1.Resetn_pin        ), // Reset within dut
    .ICis         ( IC1is_MC1_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_5(
    .IR           ( dut.core1.IR2        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core1.Resetn_pin        ), // Reset within dut
    .ICis         ( IC1is_MC2_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_6(
    .IR           ( dut.core1.IR3        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core1.Resetn_pin        ), // Reset within dut
    .ICis         ( IC1is_MC3_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
`elsif MULTICORE4
wire [95:0] IC0is_MC3_tb     ; // Instruction to ASCII
wire [95:0] IC0is_MC2_tb     ; // Instruction to ASCII
wire [95:0] IC0is_MC1_tb     ; // Instruction to ASCII
wire [95:0] IC1is_MC3_tb     ; // Instruction to ASCII
wire [95:0] IC1is_MC2_tb     ; // Instruction to ASCII
wire [95:0] IC1is_MC1_tb     ; // Instruction to ASCII
wire [95:0] IC2is_MC3_tb     ; // Instruction to ASCII
wire [95:0] IC2is_MC2_tb     ; // Instruction to ASCII
wire [95:0] IC2is_MC1_tb     ; // Instruction to ASCII
wire [95:0] IC3is_MC3_tb     ; // Instruction to ASCII
wire [95:0] IC3is_MC2_tb     ; // Instruction to ASCII
wire [95:0] IC3is_MC1_tb     ; // Instruction to ASCII

vfm_proc_inst_v dut(
    .clock_in(Clock_tb),
    .resetn(Resetn_tb),
    .SW_in(SW_in_tb),
    .LEDS(Display_out_tb)

);
`ifdef NOCACHE
defparam dut.core0.MM.altsyncram_component.init_file = "dcs_lab12_core0.mif";
defparam dut.core1.MM.altsyncram_component.init_file = "dcs_lab12_core1.mif";
defparam dut.core2.MM.altsyncram_component.init_file = "dcs_lab12_core2.mif";
defparam dut.core3.MM.altsyncram_component.init_file = "dcs_lab12_core3.mif";
`else
defparam dut.core0.MM.main_mem.altsyncram_component.init_file = "dcs_lab12_core0.mif";
defparam dut.core1.MM.main_mem.altsyncram_component.init_file = "dcs_lab12_core1.mif";
defparam dut.core2.MM.main_mem.altsyncram_component.init_file = "dcs_lab12_core2.mif";
defparam dut.core3.MM.main_mem.altsyncram_component.init_file = "dcs_lab12_core3.mif";
`endif


vfm_ir2assembly_v instruction_translate_1(
    .IR           ( dut.core0.IR1        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core0.Resetn_pin        ), // Reset within dut
    .ICis         ( IC0is_MC1_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_2(
    .IR           ( dut.core0.IR2        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core0.Resetn_pin        ), // Reset within dut
    .ICis         ( IC0is_MC2_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_3(
    .IR           ( dut.core0.IR3        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core0.Resetn_pin        ), // Reset within dut
    .ICis         ( IC0is_MC3_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);

vfm_ir2assembly_v instruction_translate_4(
    .IR           ( dut.core1.IR1        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core1.Resetn_pin        ), // Reset within dut
    .ICis         ( IC1is_MC1_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_5(
    .IR           ( dut.core1.IR2        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core1.Resetn_pin        ), // Reset within dut
    .ICis         ( IC1is_MC2_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_6(
    .IR           ( dut.core1.IR3        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core1.Resetn_pin        ), // Reset within dut
    .ICis         ( IC1is_MC3_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);

vfm_ir2assembly_v instruction_translate_7(
    .IR           ( dut.core2.IR1        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core2.Resetn_pin        ), // Reset within dut
    .ICis         ( IC2is_MC1_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_8(
    .IR           ( dut.core2.IR2        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core2.Resetn_pin        ), // Reset within dut
    .ICis         ( IC2is_MC2_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_9(
    .IR           ( dut.core2.IR3        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core2.Resetn_pin        ), // Reset within dut
    .ICis         ( IC2is_MC3_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);

vfm_ir2assembly_v instruction_translate_10(
    .IR           ( dut.core3.IR1        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core3.Resetn_pin        ), // Reset within dut
    .ICis         ( IC3is_MC1_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_11(
    .IR           ( dut.core3.IR2        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core3.Resetn_pin        ), // Reset within dut
    .ICis         ( IC3is_MC2_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_12(
    .IR           ( dut.core3.IR3        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( dut.core3.Resetn_pin        ), // Reset within dut
    .ICis         ( IC3is_MC3_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);

`endif

// Setup Free-Running Clock
always #20000 Clock_tb = ~(Clock_tb === 1'd1);

always @(posedge Clock_tb) begin
`ifdef SINGLECORE
if ((dut.core0.PC >= 70) && (dut.core0.PC <= 144)) begin clock_count = clock_count + 1'b1; end
`endif

`ifdef MULTICORE2
// if ((dut.core0.PC >= 70) && (dut.core0.PC <= 189)) begin clock_count = clock_count + 1'b1; end
if ((dut.core0.PC >= 70) && (dut.core0.PC <= 170)) begin clock_count = clock_count + 1'b1; end
// if ((dut.core0.PC >= 70) && (dut.core0.PC <= 211)) begin clock_count = clock_count + 1'b1; end
`endif

`ifdef MULTICORE4
if ((dut.core0.PC >= 70) && (dut.core0.PC <= 155)) begin clock_count = clock_count + 1'b1; end
// if ((dut.core0.PC >= 70) && (dut.core0.PC <= 282)) begin clock_count = clock_count + 1'b1; end
`endif
// `ifdef (MULTICORE2 || MULTICORE4)
// clock_count = clock_count + 1'b1;
// `else
// 
// `endif
end

integer k;
integer i;



// initial begin
// Resetn_tb = 1'd0;
//     SW_in_tb  = 5'b00000;
//     clock_count = 16'd0;
//     k = 0;
//     repeat (4) @(posedge Clock_tb);

//     // Take DUT out of Reset
//     Resetn_tb = 1'd1;

//     wait(Display_out_tb == 1'b1);
//     $stop();
// end

assign dut.interrupt_input = interrupt_input;

initial begin 
    // Reset DUT
    Resetn_tb = 1'd0;
    SW_in_tb  = 5'b00000;
    clock_count = 16'd0;
    interrupt_input = 16'd0;
    k = 0;
    repeat (4) @(posedge Clock_tb);

    // Take DUT out of Reset
    Resetn_tb = 1'd1;

    // Assert inputs to desired value
    SW_in_tb  = 5'b01111;


    repeat (50) @(posedge Clock_tb);

    interrupt_input = 16'd99;

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
    // repeat (10) @(posedge Clock_tb);

    // SW_in_tb = 5'b11111;
    
    // repeat (20) @(posedge Clock_tb);

    // SW_in_tb = 5'b01111;

    // repeat (20) @(posedge Clock_tb);

    // SW_in_tb = 5'b11111;

    // // wait(Display_out_tb == 8'b00001111);
    // repeat(80) @(posedge Clock_tb);
    // // KNOWN ISSUE: THE BOUNDS NEED TO START AT 1 FOR NO PIPE SINGLE CORE
    // for (i = 1; i < 17; i=i+1) begin
    //     switches(i[3:0]);
    //     wait(Display_out_tb == {4'd0, i[3:0]});
    // end

    // repeat(100) @(posedge Clock_tb);


    // for (i = 0; i < 16; i=i+1) begin
    //     case(i)
    //         4'd0: begin switches(4'd1); wait(Display_out_tb == 8'd1); end
    //         4'd5: begin switches(4'd1); wait(Display_out_tb == 8'd1); end
    //         4'd10: begin switches(4'd1); wait(Display_out_tb == 8'd1); end
    //         4'd15: begin switches(4'd1); wait(Display_out_tb == 8'd1); end
    //         default: begin switches(4'd0); wait(Display_out_tb == 8'd0); k = k + 1; end
    //     endcase
    // end

    // SW_in_tb = 5'b10000;

    wait(Display_out_tb == 1);

    // Run simulation for additional 15 clock cycles for human observation


    // End simultaion (normally we would use "$finish()" but modelsim prefers "$stop()")
    $stop();
end

`ifdef DISABLE_PIPELINE
task switches;
    input [3:0] i_data;
    begin
        
        SW_in_tb = {1'b1, i_data};
        repeat (40) @(posedge Clock_tb);
        SW_in_tb = {1'b0, i_data};
        repeat (55) @(posedge Clock_tb);
        SW_in_tb = {1'b1, i_data};
        repeat (20) @(posedge Clock_tb);

    end
endtask
`else
task switches;
    input [3:0] i_data;
    begin
        repeat (10) @(posedge Clock_tb);

        SW_in_tb = {1'b1, i_data};
    
        repeat (20) @(posedge Clock_tb);

        SW_in_tb = {1'b0, i_data};

        repeat (20) @(posedge Clock_tb);

        SW_in_tb = {1'b1, i_data};

    end
endtask
`endif

endmodule
