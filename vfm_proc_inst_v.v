module vfm_proc_inst_v(
    input clock_in,
    input resetn,
    input [4:0] SW_in,
    output [7:0] LEDS
);

wire [13:0] display_out;
wire pll_outClk;
wire pll_locked;
wire Resetn;
wire [13:0] Peripheral_input;

assign LEDS = display_out[7:0];
assign Peripheral_input = {10'd0, SW_in[3:0]};

vfm_pll pll(
    .inclk0(clock_in),
    .c0(pll_outClk),
    .locked(pll_locked)
);

or(Resetn, ~pll_locked, resetn);

// Core 0 instantiation
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
    .Out15              (),

    .Write_output_0     (),
    .Write_output_1     (),
    .Write_output_2     (),
    .Write_output_3     ()  


);


endmodule