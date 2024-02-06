`timescale 1ps/1ps


// Houses the Floating point IP's
module FPAddWrap_v (
    input clk,
    input reset,
    input enable,
    input [15:0] A,
    input [15:0] B,
    output [15:0] Q
);


FPAdd Fpadd (
    .clk    (clk),
    .areset (~reset),
    .en     (enable),
    .a      (A),
    .b      (B),
    .q      (Q)
);

endmodule