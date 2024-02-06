`timescale 1ps/1ps


// Houses the Floating point IP's
module FPDivWrap_v (
    input clk,
    input reset,
    input enable,
    input [15:0] A,
    input [15:0] B,
    output [15:0] Q,
    output wire stall
);

// State Machine stuff
localparam IDLE = 2'b00;
localparam WAIT = 2'b01;
localparam DONE = 2'b10;
reg [1:0] state;

reg done_int;
reg [2:0] counter;


// Floating Point addition IP
// Has 1 cycle of delay
FPDiv Fpdiv (
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
    counter = 1'b0;
end
else begin
    case(state)
        IDLE: begin
            done_int = 1'b0;
            if (enable) begin state = WAIT; done_int = 1'b0; end
            else begin state = IDLE; end
        end

        WAIT: begin
            if (counter == 5) begin state = DONE; done_int = 1'b1; end
            else begin counter = counter + 1'b1; end
        end

        DONE: begin
            state = IDLE;
            done_int = 1'b0;
        end
    endcase
end


end

endmodule