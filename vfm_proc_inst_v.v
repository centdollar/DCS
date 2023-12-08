
// `define SIMULATION
// `define DISABLE_PIPELINE
// `define NOCACHE
// Only one of these can be uncommented at once
// `define SINGLECORE
// `define MULTICORE2
// `define MULTICORE4
`include "TestBenchControl.vh"
module vfm_proc_inst_v(
    input clock_in,
    input resetn,
    input [4:0] SW_in,
    output [7:0] LEDS
);

wire [13:0] display_out;
wire pll_outClk;
wire Resetn;
wire [13:0] Peripheral_input;

assign LEDS = display_out[7:0];
assign Peripheral_input = {9'd0, SW_in[3:0], SW_in[4]};
assign Resetn = resetn;

// TODO: PUT THIS BACK IN FOR HARDWARE
//always @(posedge pll_outClk) begin
//
//	SW_in_intx <= SW_in;
//	SW_in_int  <= SW_in_intx;
//	Resetn_intx <= Resetn;
//	Resetn_int  <= Resetn_intx;
//
//end


// Do not use PLL in simulation because it takes forever
`ifdef SIMULATION
assign pll_outClk = clock_in;
assign pll_locked = 1'b1;
`else
wire pll_locked;
vfm_pll my_pll(
    .inclk0(clock_in),
    .c0(pll_outClk),
    .locked(pll_locked)
);
`endif

// TODO: TURN THESE INTO GENERATE FOR LOOPS
// =============== Modules to instantiate depending on how many cores you want==========
// ============================= FOR 1 CORE ================================
`ifdef SINGLECORE


`ifdef NOCACHE
defparam dut.core0.MM.altsyncram_component.init_file = "dcs_lab11_part3.mif";
`else
defparam dut.core0.MM.main_mem.altsyncram_component.init_file = "dcs_lab11_part3.mif";
`endif


vfmRISC621pipe_v core0(
    .Resetn_pin         ( Resetn             ), // Reset, implemented with push-button on FPGA
    .Clock_pin          ( pll_outClk              ), // Clock, implemented with Oscillator on FPGA
    .Input_write        ( SW_in[4]           ), // Write enable for the input peripheral
    
    .In0               (Peripheral_input),
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
    .Out15              ()

);

// ============================= FOR 1 CORE ================================

`elsif MULTICORE2
// ============================= FOR 2 CORES ================================

// Interconnects between cores
wire[13:0] core1to0_ack;
wire[13:0] core1to0_data;
wire[13:0] core0to1_ack;
wire[13:0] core0to1_data;

// memoory defines
`ifdef NOCACHE
defparam core0.MM.altsyncram_component.init_file = "core0.mif";
defparam core1.MM.altsyncram_component.init_file = "core1.mif";
`else
defparam core0.MM.main_mem.altsyncram_component.init_file = "core0.mif";
defparam core1.MM.main_mem.altsyncram_component.init_file = "core1.mif";
`endif


// *************** Core 0 ***************
vfmRISC621pipe_v core0(
    .Resetn_pin         ( Resetn             ), // Reset, implemented with push-button on FPGA
    .Clock_pin          ( pll_outClk              ), // Clock, implemented with Oscillator on FPGA
    .Input_write        ( SW_in[4]           ), // Write enable for the input peripheral
    
    .In0               (Peripheral_input),
    .In1               (core1to0_ack),
    .In2               (core1to0_data),
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
    .Out1               (core0to1_ack),
    .Out2               (core0to1_data),
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
    .Out15              ()


);



// *************** Core 1 **************
vfmRISC621pipe_v core1(
    .Resetn_pin         ( Resetn             ), // Reset, implemented with push-button on FPGA
    .Clock_pin          ( pll_outClk              ), // Clock, implemented with Oscillator on FPGA
    .Input_write        ( ~SW_in[4]           ), // Write enable for the input peripheral
    
    .In0               (Peripheral_input),
    .In1               (core0to1_ack),
    .In2               (core0to1_data),
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

    .Out0               (),
    .Out1               (core1to0_ack),
    .Out2               (core1to0_data),
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
    .Out15              () 


);

// ============================= END 2 CORES =======================================

// ============================= START 4 CORES =======================================
`elsif MULTICORE4

// Iterconnects between cores
wire[13:0] core1to0_ack;
wire[13:0] core1to0_data;
wire[13:0] core0to1_ack;
wire[13:0] core0to1_data;

wire[13:0] core2to0_ack;
wire[13:0] core2to0_data;
wire[13:0] core0to2_ack;
wire[13:0] core0to2_data;

wire[13:0] core3to0_ack;
wire[13:0] core3to0_data;
wire[13:0] core0to3_ack;
wire[13:0] core0to3_data;


`ifdef NOCACHE
defparam core0.MM.altsyncram_component.init_file = "dcs_lab12_core0.mif";
defparam core1.MM.altsyncram_component.init_file = "dcs_lab12_core1.mif";
defparam core2.MM.altsyncram_component.init_file = "dcs_lab12_core2.mif";
defparam core3.MM.altsyncram_component.init_file = "dcs_lab12_core3.mif";
`else
defparam core0.MM.main_mem.altsyncram_component.init_file = "dcs_lab12_core0.mif";
defparam core1.MM.main_mem.altsyncram_component.init_file = "dcs_lab12_core1.mif";
defparam core2.MM.main_mem.altsyncram_component.init_file = "dcs_lab12_core2.mif";
defparam core3.MM.main_mem.altsyncram_component.init_file = "dcs_lab12_core3.mif";
`endif

// ******************* CORE 0 ***************
vfmRISC621pipe_v core0(
    .Resetn_pin         ( Resetn             ), // Reset, implemented with push-button on FPGA
    .Clock_pin          ( pll_outClk              ), // Clock, implemented with Oscillator on FPGA
    .Input_write        ( SW_in[4]           ), // Write enable for the input peripheral
    
    .In0               (Peripheral_input),
    .In1               (core1to0_ack),
    .In2               (core1to0_data),
    .In3               (core2to0_ack),
    .In4               (core2to0_data),
    .In5               (core3to0_ack),
    .In6               (core3to0_data),
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
    .Out1               (core0to1_ack),
    .Out2               (core0to1_data),
    .Out3               (core0to2_ack),
    .Out4               (core0to2_data),
    .Out5               (core0to3_ack),
    .Out6               (core0to3_data),
    .Out7               (),
    .Out8               (),
    .Out9               (),
    .Out10              (),
    .Out11              (),
    .Out12              (),
    .Out13              (),
    .Out14              (),
    .Out15              ()


);

// ******************* CORE 1 ***************
vfmRISC621pipe_v core1(
    .Resetn_pin         ( Resetn             ), // Reset, implemented with push-button on FPGA
    .Clock_pin          ( pll_outClk              ), // Clock, implemented with Oscillator on FPGA
    .Input_write        ( ~SW_in[4]           ), // Write enable for the input peripheral
    
    .In0               (Peripheral_input),
    .In1               (core0to1_ack),
    .In2               (core0to1_data),
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

    .Out0               (),
    .Out1               (core1to0_ack),
    .Out2               (core1to0_data),
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
    .Out15              ()


);

// ******************* CORE 2 ***************
vfmRISC621pipe_v core2(
    .Resetn_pin         ( Resetn             ), // Reset, implemented with push-button on FPGA
    .Clock_pin          ( pll_outClk              ), // Clock, implemented with Oscillator on FPGA
    .Input_write        ( ~SW_in[4]           ), // Write enable for the input peripheral
    
    .In0               (Peripheral_input),
    .In1               (),
    .In2               (),
    .In3               (core0to2_ack),
    .In4               (core0to2_data),
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

    .Out0               (),
    .Out1               (),
    .Out2               (),
    .Out3               (core2to0_ack),
    .Out4               (core2to0_data),
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
    .Out15              ()


);

// ******************* CORE 3 ***************
vfmRISC621pipe_v core3(
    .Resetn_pin         ( Resetn             ), // Reset, implemented with push-button on FPGA
    .Clock_pin          ( pll_outClk              ), // Clock, implemented with Oscillator on FPGA
    .Input_write        ( ~SW_in[4]           ), // Write enable for the input peripheral
    
    .In0               (Peripheral_input),
    .In1               (),
    .In2               (),
    .In3               (),
    .In4               (),
    .In5               (core0to3_ack),
    .In6               (core0to3_data),
    .In7               (),
    .In8               (),
    .In9               (),
    .In10              (),
    .In11              (),
    .In12              (),
    .In13              (),
    .In14              (),
    .In15              (),

    .Out0               (),
    .Out1               (),
    .Out2               (),
    .Out3               (),
    .Out4               (),
    .Out5               (core3to0_ack),
    .Out6               (core3to0_data),
    .Out7               (),
    .Out8               (),
    .Out9               (),
    .Out10              (),
    .Out11              (),
    .Out12              (),
    .Out13              (),
    .Out14              (),
    .Out15              ()

);

`endif
// ============================= END 4 CORES =======================================


endmodule