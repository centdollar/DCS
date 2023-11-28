module vfm_proc_inst_tb();

reg Resetn_tb   ;
reg Clock_tb    ;

wire [95:0] ICis_MC3_core0_tb     ; // Instruction to ASCII
wire [95:0] ICis_MC2_core0_tb     ; // Instruction to ASCII
wire [95:0] ICis_MC1_core0_tb     ; // Instruction to ASCII


reg [1:0] push_button,    // [1] is for reset, [0] is for core0 input write
reg [3:0] dip_switchs,    // used for inputting data to core 0
wire  [7:0] LEDS



// Core 0 instantiation
vfmRISC621pipe_v core0(
    .Resetn_pin         ( Resetn_tb             ), // Reset, implemented with push-button on FPGA
    .Clock_pin          ( Clock_tb              ), // Clock, implemented with Oscillator on FPGA
    .Peripheral_input   ( {10'd0, dip_switchs}   ), // Input peripheral data 
    .Input_write        ( push_button[0]           ), // Write enable for the input peripheral
    .Output_IO_0        ( Output_IO_0_tb        ),  // 8 LEDs
    .Output_IO_1        (),
    .Output_IO_2        (),
    .Output_IO_3        ()
);

// Instruction to Ascii Translators, note use of hierarchical/virtual routing
vfm_ir2assembly_v instruction_translate_1(
    .IR           ( core0.IR1        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( core0.Resetn_pin        ), // Reset within dut
    .ICis         ( ICis_MC1_core0_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_2(
    .IR           ( core0.IR2        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( core0.Resetn_pin        ), // Reset within dut
    .ICis         ( ICis_MC2_core0_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);
vfm_ir2assembly_v instruction_translate_3(
    .IR           ( core0.IR3        [13:0] ), // Instruction word within dut
    .Resetn_pin   ( core0.Resetn_pin        ), // Reset within dut
    .ICis         ( ICis_MC3_core0_tb    [95:0] )  // ASCII stream translating IR from Binary to English
);




endmodule