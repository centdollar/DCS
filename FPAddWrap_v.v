`timescale 1ps/1ps


// Houses the Floating point IP's
module FPAddWrap_v (
    input clk,
    input reset,
    input enable,
    input [15:0] A,
    input [15:0] B,
    output [15:0] Q,
    output wire stall
);

// State Machine stuff
localparam IDLE = 1'b0;
localparam DONE = 1'b1;
reg state;

reg done_int;


// Floating Point addition IP
// Has 1 cycle of delay
FPAdd Fpadd (
    .clk    (clk),
    .areset (~reset),
    .en     (enable),
    .a      (A),
    .b      (B),
    .q      (Q)
);


assign stall = enable && ~done_int;


always @(posedge clk) begin
if (~reset) begin
    done_int = 1'b1;
    state = IDLE;
end
else begin
    case(state)
        IDLE: begin
            done_int = 1'b0;
            if (enable) begin state = DONE; done_int = 1'b1; end
            else begin state = IDLE; end
        end
        DONE: begin
            state = IDLE;
            done_int = 1'b0;
        end
    endcase
end


end

endmodule