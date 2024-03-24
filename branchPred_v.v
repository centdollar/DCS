`timescale 1ps/1ps

// TODO: Issue where if two jumps are too close together it will predict right but not say the prediction was correct 
module branchPred_v (
    input clk,
    input resetn,
    input [7:0] address,
    input [4:0] jumpType,
    input [11:0] statusBits,
    input [15:0] currPC,
    input enable,
    output reg jumpTaken,        // 0: not taken        1: taken
    output reg pred_correct
);

integer k;
integer i;

localparam [1:0] s_taken = 2'b00;
localparam [1:0] w_taken = 2'b01;
localparam [1:0] w_ntaken = 2'b10;
localparam [1:0] s_ntaken = 2'b11;

localparam [4:0]  JC1 = 5'b10000 ; // Jump if Carry == 1
localparam [4:0]  JN1 = 5'b01000 ; // Jump if Negative == 1
localparam [4:0]  JV1 = 5'b00100 ; // Jump if Overflow == 1
localparam [4:0]  JZ1 = 5'b00010 ; // Jump if Zero == 1
localparam [4:0]  JC0 = 5'b01110 ; // Jump if Carry == 0
localparam [4:0]  JN0 = 5'b10110 ; // Jump if Negative == 0
localparam [4:0]  JV0 = 5'b11010 ; // Jump if Overflow == 0
localparam [4:0]  JZ0 = 5'b11100 ; // Jump if Zero == 0



reg [1:0] predictStates [7:0];

reg [7:0] targetAddr [7:0];
reg [2:0] targetIndex;
reg [2:0] targetWriteIndex;


reg [1:0] cur_state;
localparam [1:0] IDLE = 2'b00;
localparam [1:0] FOUND = 2'b01;
localparam [1:0] NOTFOUND = 2'b10;







always @(posedge clk) begin
if (~resetn) begin
    // Reset prediction states to weak taken
    for (k = 0; k < 8; k = k + 1) begin predictStates[k] = w_taken; end
    for (k = 0; k < 8; k = k + 1) begin targetAddr[k] = 8'hFF; end
    targetIndex = 3'd0;
    targetWriteIndex = 3'd0;
    jumpTaken = 1'b0;
    pred_correct = 1'b0;
    cur_state = IDLE;
end
else if(enable) begin
    case(cur_state)
        IDLE: begin
            // pred_correct = 1'b0;

            // This should work in finding the index where the target address is, but could cause issues if jumps are 
            // stored bit 9 is a 1 or 0 and the 7:0 are the same
            for (i = 0; i < 8; i = i + 1) begin
                if (address == targetAddr[i]) begin 
                    targetIndex = i[2:0];
                    cur_state = FOUND;
                end
            end
            if(cur_state !=FOUND) begin
                cur_state = NOTFOUND;
                // New addresses always default to a weak taken state
                jumpTaken = 1'b1;
            end
            else jumpTaken = ~predictStates[targetIndex][1]; 
        end
        FOUND: begin
            case (jumpType)
                // JC1: begin if (statusBits[11] == 1) begin
                JC1: begin 
                    if (statusBits[11]  == 1) begin
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = w_ntaken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = s_ntaken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                     
                // end
                // else PC = PC; end

                // JN1: begin if (statusBits[10] == 1) PC = MAeff; else PC = PC; end
                JN1: begin 
                    if (statusBits[10]  == 1) begin
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = w_ntaken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = s_ntaken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                // JV1: begin if (statusBits[9]  == 1) PC = MAeff; else PC = PC; end
                JV1: begin 
                    if (statusBits[9]  == 1) begin
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = w_ntaken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = s_ntaken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                // JZ1: begin if (statusBits[8]  == 1) PC = MAeff; else PC = PC; end
                JZ1: begin 
                    if (statusBits[8]  == 1) begin
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = w_ntaken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = s_ntaken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                // JC0: begin if (statusBits[11] == 0) PC = MAeff; else PC = PC; end
                JC0: begin 
                    if (statusBits[11]  == 0) begin
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = w_ntaken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = s_ntaken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end

                JN0: begin 
                    if (statusBits[10]  == 0) begin
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = w_ntaken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = s_ntaken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                JV0: begin 
                    if (statusBits[9]  == 0) begin
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = w_ntaken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = s_ntaken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                JZ0: begin 
                    if (statusBits[8]  == 0) begin
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = s_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetIndex] == w_taken) predictStates[targetIndex] = w_ntaken;  
                        if(predictStates[targetIndex] == s_taken) predictStates[targetIndex] = w_taken;  
                        if(predictStates[targetIndex] == w_ntaken) predictStates[targetIndex] = s_ntaken;  
                        if(predictStates[targetIndex] == s_ntaken) predictStates[targetIndex] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end

            endcase
            cur_state = IDLE;

        end
        NOTFOUND: begin
            targetAddr[targetWriteIndex] = address;
            targetWriteIndex = targetWriteIndex + 1'b1;

            case (jumpType)
                // JC1: begin if (statusBits[11] == 1) begin
                JC1: begin 
                    if (statusBits[11]  == 1) begin
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                     
                // end
                // else PC = PC; end

                // JN1: begin if (statusBits[10] == 1) PC = MAeff; else PC = PC; end
                JN1: begin 
                    if (statusBits[10]  == 1) begin
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                // JV1: begin if (statusBits[9]  == 1) PC = MAeff; else PC = PC; end
                JV1: begin 
                    if (statusBits[9]  == 1) begin
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                // JZ1: begin if (statusBits[8]  == 1) PC = MAeff; else PC = PC; end
                JZ1: begin 
                    if (statusBits[8]  == 1) begin
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                // JC0: begin if (statusBits[11] == 0) PC = MAeff; else PC = PC; end
                JC0: begin 
                    if (statusBits[11]  == 0) begin
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                // JN0: begin if (statusBits[10] == 0) PC = MAeff; else PC = PC; end
                JN0: begin 
                    if (statusBits[10]  == 0) begin
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                // JV0: begin if (statusBits[9]  == 0) PC = MAeff; else PC = PC; end
                JV0: begin 
                    if (statusBits[9]  == 0) begin
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end
                JZ0: begin 
                    if (statusBits[8]  == 0) begin
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = s_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        pred_correct = 1'b1;
                    end    
                    else begin 
                        if(predictStates[targetWriteIndex - 1] == w_taken) predictStates[targetWriteIndex - 1] = w_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_taken) predictStates[targetWriteIndex - 1] = w_taken;  
                        if(predictStates[targetWriteIndex - 1] == w_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        if(predictStates[targetWriteIndex - 1] == s_ntaken) predictStates[targetWriteIndex - 1] = s_ntaken;  
                        pred_correct = 1'b0;
                    end
                end

            endcase
            cur_state = IDLE;
        end
    endcase
end

end




endmodule