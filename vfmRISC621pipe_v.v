// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
//----------------------------------------------------------------------------
// dxpRISC521pipe_v    Harvard    Memory Mapped I/O-Ps - top 16 locations
// (c) Dorin Patru 2022; Updated by Stefan Maczynski 2023
//----------------------------------------------------------------------------
`define SIMULATION              // REMOVE FOR FPGA EMULATION!
//`define DISABLE_PIPELINE      // Use for debuging issues with data-forwarding!
// `define NOCACHE              // Uncomment to remove hierachical memory
module vfmRISC621pipe_v (
input             Resetn_pin    , // Reset, implemented with push-button on FPGA
input             Clock_pin     , // Clock, implemented with Oscillator on FPGA
input      [ 4:0] SW_pin        , // Four switches and remaining push-button
output reg [ 7:0] Display_pin     // 8 LEDs
);

//----------------------------------------------------------------------------
//-- Declare machine cycle and instruction cycle parameters
//----------------------------------------------------------------------------

// Instructions
    //reg-mem data transfer
localparam [5:0] LD_IC   = 6'b000000 ; // Load
localparam [5:0] ST_IC   = 6'b000001 ; // Store
    //reg-reg data transfer
localparam [5:0] CPY_IC  = 6'b000010 ; // Copy
localparam [5:0] SWAP_IC = 6'b000011 ; // Swap
    //flow control
localparam [5:0] JMP_IC  = 6'b000100 ; // Jump
    //arithmetic manipulation
localparam [5:0] ADD_IC  = 6'b000101 ; // Add
localparam [5:0] SUB_IC  = 6'b000110 ; // Subtract
localparam [5:0] ADDC_IC = 6'b000111 ; // Add Constant
localparam [5:0] SUBC_IC = 6'b001000 ; // Subtract Constant
    //logic manipulation
localparam [5:0] NOT_IC  = 6'b001001 ; // Not
localparam [5:0] AND_IC  = 6'b001010 ; // And
localparam [5:0] OR_IC   = 6'b001011 ; // Or
    //shift/rotate
// localparam [5:0] SRA_IC  = 6'b1100 ; // Shift Right Arithmetic
localparam [5:0] RRC_IC  = 6'b001101 ; // Rotate Right Through Carry
    //SIMD (vector) - to be implemented later
localparam [5:0] VADD_IC = 6'b001110 ; // Vector Add
localparam [5:0] VSUB_IC = 6'b001111 ; // Vector Subtract
localparam [5:0] VADDC_IC = 6'b100000 ; // Vector Add
localparam [5:0] VSUBC_IC = 6'b100001 ; // Vector Subtract



localparam [5:0] MUL_IC  = 6'b010000 ; // Multiply
localparam [5:0] DIV_IC  = 6'b010001 ; // Divide
localparam [5:0] XOR_IC  = 6'b010010 ; // XOR
localparam [5:0] SHRL_IC = 6'b010011 ; // Shift right logical
localparam [5:0] SRA_IC = 6'b010100 ; // Shift right arithmetic
localparam [5:0] ROTL_IC = 6'b010101 ; // Rotate left 
localparam [5:0] ROTR_IC = 6'b010110 ; // rotate right
localparam [5:0] RLN_IC  = 6'b010111 ; // rotate left through negative
localparam [5:0] RLZ_IC  = 6'b011000 ; // rotate left through zero
localparam [5:0] RRN_IC  = 6'b011001 ; // Rotate right through negative
localparam [5:0] RRZ_IC  = 6'b011010 ; // Rotate right thorugh zero

//Jump conditions
localparam [5:0]  JU  = 4'b0000 ; // Jump Unconditional
localparam [5:0]  JC1 = 4'b1000 ; // Jump if Carry == 1
localparam [5:0]  JN1 = 4'b0100 ; // Jump if Negative == 1
localparam [5:0]  JV1 = 4'b0010 ; // Jump if Overflow == 1
localparam [5:0]  JZ1 = 4'b0001 ; // Jump if Zero == 1
localparam [5:0]  JC0 = 4'b0111 ; // Jump if Carry == 0
localparam [5:0]  JN0 = 4'b1011 ; // Jump if Negative == 0
localparam [5:0]  JV0 = 4'b1101 ; // Jump if Overflow == 0
localparam [5:0]  JZ0 = 4'b1110 ; // Jump if Zero == 0

// CALL and REturn
localparam [5:0]  CALL_IC = 6'b011011;
localparam [5:0]  RET_IC  = 6'b011100;

localparam [5:0]  IN_IC   = 6'b011101;
localparam [5:0]  OUT_IC  = 6'b011110;


// Compare instruction for loops
localparam [5:0]  CMP_IC  = 6'b110000;


//----------------------------------------------------------------------------
//-- Declare internal signals
//----------------------------------------------------------------------------
reg  [13:0]    R       [15:0] ; // Register File (RF) 64 16-bit registers
reg            WR_DM          ; // Write-enable data-memory input
reg            stall_mc0      ; // Stall Control Bits
reg            stall_mc1      ; // Stall Control Bits
reg            stall_mc2      ; // Stall Control Bits
reg            stall_mc3      ; // Stall Control Bits
reg  [13:0]    PC             ; // Program Counter
reg  [13:0]    IR4            ;
reg  [13:0]    IR3            ; // Instruction Register 3
reg  [13:0]    IR2            ; // Instruction Register 2
reg  [13:0]    IR1            ; // Instruction Register 1
reg  [13:0]    MAB            ; // Memory Address B
reg  [13:0]    MAX            ; // Memory Address X
reg  [13:0]    MAeff          ; // Memory Address Effective
reg  [13:0]    MM_in          ; // Data-Memory Input
reg  [13:0]    TA             ; // Temporary Input of Arithmetic-Logic-Unit "A"
reg  [13:0]    TB             ; // Temporary Input of Arithmetic-Logic-Unit "B"
reg  [28:0]    TALUout        ; // Temoprary Output of Arithmetic-Logic-Unit with carry
reg  [13:0]    TALUH          ; // Temporary Output of Arithmetic-Logic-Unit "High"
reg  [13:0]    TALUL          ; // Temporary Output of Arithmetic-Logic-Unit "Low"
reg  [13:0]    Ri1            ; // Index within registerfile
reg  [13:0]    Rj1            ; // Index within registerfile
reg  [13:0]    Ri2            ; // Index within registerfile
reg  [13:0]    Rj2            ; // Index within registerfile
reg  [13:0]    Ri3            ; // Index within registerfile
reg  [13:0]    Rj3            ; // Index within registerfile
reg  [11:0]    TSR            ; // Temporary Status Register
reg  [11:0]    SR             ; // Status Register
wire           Clock_not      ; // Inverted Clock
wire           Cache_done     ;
reg            Wait_for_cache;
wire [13:0]    MM_out         ; // Output of monolithic memory 
reg  [29:0]    TALUS          ; // temporary alu shift reg for status shifting
reg unsigned [13:0] SP        ;
integer        k              ; // Index for looping construct

reg [13:0] Input_Ps;            // 
reg [3:0]  IPA;                 // Input peripheral Address Dont think this is needed
reg [13:0] IPDR[15:0];          // 16 14-bit Input peripheral Data registers, addressed by Rj in IN_IC
reg [13:0] OPDR[15:0];          // 16 14-bit output registers that are addressed by Rj in the in OUT_IC

//------------------------------------------------------------------------------------------------------------------------------------------
// - In this architecture we are using a combination of structural and behavioral code.
// - Care has to be excercised because the values assigned in the always block are visible outside of it only during the next clock cycle.
// - The CPU, which is comprised of the Data-Path and Control-Unit, is modeled as a combination of CASE and IF statements (behavioral).
// - The memories are called within the structural part of the code.
// - We could model the memories as arrays, but that would result in less than optimal memory implementations.
// - Later on we will want to add an hierarchcial memory subsystem.
//------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------
// Structural section of the code.  The order of the assignments doesn't matter.
//------------------------------------------------------------------------------------------------------------------------------------------

not clock_inverter ( Clock_not, Clock_pin ); // Using a language primative so timing analyzer can recognize the derived clock

// push button used for allowing input 
// always @(~SW_pin[4])
// begin
//     // assign 
// 	Input_Ps = {10'd0, SW_pin[3:0]};
// end


`ifdef NOCACHE
vfm_ram my_ram (
    .address    ( MAeff      [ 13:0]), // input
    .clock      ( Clock_not         ), // input
    .data       ( MM_in      [13:0] ), // input
    .wren       ( WR_DM             ), // input
    .q          ( MM_out     [13:0] )  // output
);
assign Cache_done = 1'd1;
`else
vfm_cache_4w_v2 MM (
    .Resetn      ( Resetn_pin               ), // input
    .MEM_address ( MAeff        [13:0]      ), // input   // Address coming from the CPU
    .MEM_in      ( MM_in        [13:0]      ), // input   // Write-Back data from the CPU
    .WR          ( WR_DM                    ), // input   // Write-Enable from the CPU
    .Clock       ( Clock_not                ), // input
    .MEM_out     ( MM_out       [13:0]      ), // output  // Data Stored at the Address pointed to by MEM_address
    .Done        ( Cache_done               )  // output  // Data out is valid
);
`endif

//------------------------------------------------------------------------------------------------------------------------------------------
// - Behavioral section of the code.  Assignments are evaluated in order, i.e. sequentially.
// - New assigned values are visible outside the always block only after it is exit.
// - Last assigned value will be the exit value.
//------------------------------------------------------------------------------------------------------------------------------------------
always@(posedge Clock_pin) begin : my_CPU

if (~SW_pin[4]) begin
	Input_Ps = {10'd0, SW_pin[3:0]};
end


//----------------------------------------------------------------------------
// RESET 
//----------------------------------------------------------------------------
if (Resetn_pin == 0) begin    
    // - The reset is active low and clock synchronous.
    // - Initialize registers.
    PC = 14'h0000; // Initialize the PC to point to the location of the FIRST instruction to be executed; location 0000 is arbitrary!
    Wait_for_cache = 1'b0;
    for (k = 0; k < 16; k = k+1) begin R[k] = 0; end
    MAB         = 14'd0;
    MAX         = 14'd0;
    MAeff       = 14'd0;
    MM_in       = 14'd0;
    TA          = 14'd0;
    TB          = 14'd0;
    TALUH       = 14'd0;
    TALUL       = 14'd0;
    TSR         = 12'd0;
    SR          = 12'd0;
    SP          = 14'h3FFF;
    TALUout     = 16'd0;
    Ri1         = 14'd0;
    Rj1         = 14'd0;
    Ri2         = 14'd0;
    Rj2         = 14'd0;
    Ri3         = 14'd0;
    Rj3         = 14'd0;
    Display_pin =  8'd0;
    IR1         = 14'h3fff; // All IRs are initialized to the "don't care OpCode value 0xffff
    IR2         = 14'h3fff;
    IR3         = 14'h3fff;
    stall_mc0   =  1'b0; // The initialization of the stall_mc signals is necessary for the correct startup of the pipeline.
    stall_mc1   =  1'b1;
    stall_mc2   =  1'b1;
    stall_mc3   =  1'b1;
    WR_DM       =  1'b0;
end // if (Resetn_pin == 0)
else if(Cache_done) begin
    Wait_for_cache = 1'b0;
//----------------------------------------------------------------------------
// MACHINE CYCLE 3
//----------------------------------------------------------------------------
    // MC3 is executed first because its assignments might be needed by the instructions executing MC2 or MC1 to resolve data or control D/H.
    // An instruction that has arrived in MC3 does not have any dependency.
    if ((stall_mc3 == 0) && (IR3 != 14'h3FFF)) begin 
        case (IR3[13:8]) // Decode the OpCode of the IW
            LD_IC: begin
                R[IR3[3:0]] = MM_out;
                MAeff = PC;
            end // LD_IC
            ST_IC: begin
                MM_in = R[IR3[3:0]];
                WR_DM = 1'b0;
                MAeff = PC;
                // stall_mc0 = 1;
            end // ST_IC
            CALL_IC: begin
                PC = MAB + MAX;
                MAeff = MAB + MAX;
                WR_DM = 1'b0;
                // stall_mc0 = 1;
            end
            RET_IC: begin
                PC = MM_out;
                MAeff = PC;
                WR_DM = 1'b0;
            end
            IN_IC: begin
                PC = PC + 1'b0;
            end
            OUT_IC: begin
                Display_pin = OPDR[Rj3][7:0];
            end
            CPY_IC: begin
                    R[IR3[7:4]] = TALUL;
            end // CPY_IC
            SWAP_IC: begin
                    R[IR3[7:4]] = TALUL;
                    R[IR3[3:0]] = TALUH;
            end // SWAP_IC
            JMP_IC: begin
                case (IR3[3:0])
                    JU : begin PC = MAeff; end
                    JC1: begin if (SR[11] == 1) PC = MAeff; else PC = PC; end
                    JN1: begin if (SR[10] == 1) PC = MAeff; else PC = PC; end
                    JV1: begin if (SR[9]  == 1) PC = MAeff; else PC = PC; end
                    JZ1: begin if (SR[8]  == 1) PC = MAeff; else PC = PC; end
                    JC0: begin if (SR[11] == 0) PC = MAeff; else PC = PC; end
                    JN0: begin if (SR[10] == 0) PC = MAeff; else PC = PC; end
                    JV0: begin if (SR[9]  == 0) PC = MAeff; else PC = PC; end
                    JZ0: begin if (SR[8]  == 0) PC = MAeff; else PC = PC; end
                    default: PC = PC;
                endcase
            end // JMP_IC
            CMP_IC, ADD_IC, SUB_IC, ADDC_IC, SUBC_IC, VADD_IC, VSUB_IC, VADDC_IC, VSUBC_IC, NOT_IC, AND_IC, OR_IC, XOR_IC, ROTL_IC, ROTR_IC, SHRL_IC, SRA_IC, RLN_IC, RLZ_IC, RRN_IC, RRZ_IC : begin
                if (CMP_IC == IR3[13:8]) begin
                    SR = TSR;
                end 
                else begin 
                    R[IR3[7:4]] = TALUH;
                    SR = TSR;
                end
            end // ADD_IC, SUB_IC, ADDC_IC, SUBC_IC, NOT_IC, AND_IC, OR_IC, SRA_IC, RRC_IC
            MUL_IC, DIV_IC: begin
                R[IR3[7:4]] = TALUH;
                R[IR3[3:0]] = TALUL;
                SR = TSR;
            end
            default: begin // Default case should not be reached0
                `ifdef SIMULATION
                $display("ERROR: Default Case Selection Reached from MC3 , OPCODE: %b @ %t",IR3[13:8], $time());
                `endif
            end // default
        endcase // IR3[15:12]
    end // stall_mc3
//----------------------------------------------------------------------------
// MACHINE CYCLE 2
//----------------------------------------------------------------------------
    if ((stall_mc2 == 0) && (IR2 != 14'h3FFF)) begin
        case (IR2[13:8]) // Decode the OpCode of the IW
            LD_IC, JMP_IC: begin
                MAeff = MAB + MAX; // Address Arithmetic to calculate the effective address
                WR_DM = 1'b0; // For LD_IC we ensure here that WR_DM=0.
            end // LD_IC, JMP_IC
            ST_IC: begin
                MAeff = MAB + MAX;
                if (MAeff[13:2] != 12'hFFF) begin
                    WR_DM = 1'b1;
                    // DF-PU = Data Forwarding from the instruction in MC3:
                        // 1st, From the instructions that perform a write-back:
                    if ((Rj2 == Ri3) && (IR3[13:8] != LD_IC ) && (IR3[13:8] !=  ST_IC) && (IR3[13:8] != JMP_IC)) begin
                        MM_in = R[Ri3];
                    end
                    // Next, resolve the SWAP write-back:
                    else if (Rj2 == Rj3 && IR3[13:8] == SWAP_IC) begin
                        MM_in = R[Rj3];
                    end
                    // OR without Data-Forwarding:
                    else begin
                        MM_in = R[Rj2];
                    end
                end
                else begin
                    WR_DM = 1'b0;
                end
            end // ST_IC
            CALL_IC: begin
                SP = $unsigned(SP - 1'b1);
                MM_in = {SR, 2'b00};
                WR_DM = 1'b1;
                MAeff = SP;
            end
            RET_IC: begin
                MAeff = SP;
                SP = $unsigned(SP + 1'b1);
                SR = MM_out[13:2];
                WR_DM = 1'b0;
            end
            IN_IC: begin
                R[Ri2] = IPDR[Rj2];
            end
            OUT_IC: begin
                PC = PC + 1'b0;
            end
            CPY_IC: begin
                TALUL = TB;
            end // CPY_IC
            SWAP_IC: begin
                TALUH = TA;
                TALUL = TB;
            end // SWAP_IC
            //----------------------------------------------------------------------------
            // For all assignments that target TALUH we use TALUout.  This is 17-bits wide
            //     to account for the value of the carry when necessary.
            //----------------------------------------------------------------------------
            ADD_IC, ADDC_IC: begin
                TALUout = TA + TB;
                TSR[11] = TALUout[14]; // Carry
                TSR[10] = TALUout[13]; // Negative
                TSR[9] = ((TA[13] ~^ TB[13]) & TA[13]) ^ (TALUout[13] & (TA[13] ~^ TB[13])); // V Overflow
                if (TALUout[13:0] == 14'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
                TALUH = TALUout[13:0];
            end // ADD_IC, ADDC_IC
            SUB_IC, SUBC_IC, CMP_IC: begin
                TALUout = TA - TB;
                TSR[11] = TALUout[14]; // Carry
                TSR[10] = TALUout[13]; // Negative
                TSR[9] = ((TA[13] ~^ TB[13]) & TA[13]) ^ (TALUout[13] & (TA[13] ~^ TB[13])); // V Overflow
                if (TALUout[13:0] == 14'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
                TALUH = TALUout[13:0];
            end // SUB_IC, SUBC_IC

            VADD_IC, VADDC_IC: begin

                // Add the two parts of the vector independently
                TALUout[14:8] = TA[13:7] + TB[13:7];
                TALUout[7:0] = TA[6:0] + TB[6:0];


                TSR[11] = TALUout[15]; // Carry
                TSR[10] = TALUout[14]; // Negative
                TSR[9] = ((TA[13] ~^ TB[13]) & TA[13]) ^ (TALUout[13] & (TA[13] ~^ TB[13])); // V Overflow
                if (TALUout[14:8] == 7'h0000) begin TSR[8] = 1; end else begin TSR[8] = 0; end

                TSR[7] = TALUout[7]; // Carry
                TSR[6] = TALUout[7]; // Negative
                TSR[5] = ((TA[6] ~^ TB[6]) & TA[6]) ^ (TALUout[6] & (TA[6] ~^ TB[6])); // V Overflow
                if (TALUout[7:0] == 7'h0000) begin TSR[4] = 1; end else begin TSR[4] = 0; end

                TALUH = {TALUout[14:8], TALUout[6:0]};
            end // VADD_IC, VADDC_IC

            VSUB_IC, VSUBC_IC: begin

                // Add the two parts of the vector independently
                TALUout[14:8] = TA[13:7] - TB[13:7];
                TALUout[7:0] = TA[6:0] - TB[6:0];


                TSR[11] = TALUout[15]; // Carry
                TSR[10] = TALUout[14]; // Negative
                TSR[9] = ((TA[13] ~^ TB[13]) & TA[13]) ^ (TALUout[13] & (TA[13] ~^ TB[13])); // V Overflow
                if (TALUout[14:8] == 7'h0000) begin TSR[8] = 1; end else begin TSR[8] = 0; end

                TSR[7] = TALUout[7]; // Carry
                TSR[6] = TALUout[7]; // Negative
                TSR[5] = ((TA[6] ~^ TB[6]) & TA[6]) ^ (TALUout[6] & (TA[6] ~^ TB[6])); // V Overflow
                if (TALUout[7:0] == 7'h0000) begin TSR[4] = 1; end else begin TSR[4] = 0; end

                TALUH = {TALUout[14:8], TALUout[6:0]};
            end // VSUB_IC, VSUBC_IC

            MUL_IC: begin
                TALUout = TA * TB;
                TSR[11] = TALUout[14]; // Carry
                TSR[10] = TALUout[13]; // Negative
                TSR[9] = ((TA[13] ~^ TB[13]) & TA[13]) ^ (TALUout[13] & (TA[13] ~^ TB[13])); // V Overflow
                if (TALUout[27:0] == 27'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
                TALUH = TALUout[27:14];
                TALUL = TALUout[13:0];
            end // MUL_IC
            DIV_IC: begin
                TALUout = TA / TB;
                TALUL = TA % TB;
                TSR[11] = TALUout[14]; // Carry
                TSR[10] = TALUout[13]; // Negative
                TSR[9] = ((TA[13] ~^ TB[13]) & TA[13]) ^ (TALUout[13] & (TA[13] ~^ TB[13])); // V Overflow
                if (TALUout[13:0] == 14'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
                TALUH = TALUout[13:0];
            end // DIV_IC
            NOT_IC: begin
                TALUH = ~TA; //Carry and Overflow are not affected by ~
                TSR[10] = TALUH[13]; // Negative
                if (TALUout[13:0] == 16'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
            end // NOT_IC
            AND_IC: begin
                TALUH = TA & TB; //Carry and Overflow are not affected by &
                TSR[10] = TALUH[13]; // Negative
                if (TALUout[13:0] == 14'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
            end // AND_IC
            OR_IC: begin
                TALUH = TA | TB; //Carry and Overflow are not affected by |
                TSR[10] = TALUH[13]; // Negative
                if (TALUout[13:0] == 14'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
            end // OR_IC
            XOR_IC: begin
                TALUH = TA ^ TB; //Carry and Overflow are not affected by |
                TSR[10] = TALUH[13]; // Negative
                if (TALUout[13:0] == 14'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
            end // XOR_IC
            SHRL_IC: begin
                if(TA[13] == 1'b1) TALUout = {14'b11111111111111, TA} >> TB;
                else TALUout = {14'b00000000000000, TA} >> TB;
                TALUH = TALUout[13:0];
                TSR[10] = TALUout[13]; // Negative
                if (TALUout[13:0] == 14'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\

            end // SHRL_IC
            ROTL_IC:
                begin
                    TALUout = {TA,TA} << TB;
                    TALUH = TALUout[27:14];
                    TSR[10] = TALUH[13]; // Negative
                    if (TALUH[13:0] == 14'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end // ROTL_IC
            SRA_IC: begin
                    if(TA[13] == 1'b1) TALUout = {14'b11111111111111, TA} >> TB;
                    else TALUout = {14'b00000000000000, TA} >> TB;
                    TALUH = TALUout[13:0];
                    TSR[10] = TALUout[13]; // Negative
                    if (TALUout[13:0] == 14'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end
            ROTR_IC:
                begin
                TALUout = {{TA, TA} >> TB};
                TALUH = TALUout[13:0];
                TSR[10] = TALUH[13]; // Negative
                if (TALUH[13:0] == 14'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end // ROTR_IC
            RLN_IC:
                begin
                    TALUS = {TA, TSR[10], TA, TSR[10]} << TB;
                    TALUH = TALUS[29:16];	
                    TSR[10] = TALUH[13]; // Negative
                    if (TALUH[13:0] == 14'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end // RLN_IC
            RLZ_IC:
                begin
                    TALUS = {TA, TSR[8], TA, TSR[8]} << TB;
                    TALUH = TALUS[29:16];
                    TSR[10] = TALUH[13]; // Negative
                    if (TALUH[13:0] == 14'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end // RLZ_IC
            RRN_IC:
                begin
                    TALUS = {TSR[10], TA, TSR[10], TA} >> TB;
                    TALUH = TALUS[13:0];
                    TSR[10] = TALUH[13]; // Negative
                    if (TALUH[13:0] == 14'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end //RRN_IC
            RRZ_IC:
                begin
                    TALUS = {TSR[8], TA, TSR[8], TA} >> TB;
                    TALUH = TALUS[13:0];
                    TSR[10] = TALUH[13]; // Negative
                    if (TALUH[13:0] == 14'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end //RRZ_IC
            default: begin // Default case should not be reached
                `ifdef SIMULATION
                $display("ERROR: Default Case Selection Reached from MC2 , OPCODE: %b @ %t",IR2[13:8], $time());
                `endif
            end //default
        endcase // IR2[15:12]
    end // stall_mc2
//----------------------------------------------------------------------------
// MACHINE CYCLE 1
//----------------------------------------------------------------------------
    if ((stall_mc1 == 0) && (IR1 != 14'h3fff)) begin // MC1, or Operand Fetch for manip inst, or Address_Fetch for transfer and flow control inst
        case (IR1[13:8]) // Decode the OpCode of the IW
            LD_IC, ST_IC, JMP_IC: begin
                MAeff = PC;
                MAB = MM_out; // Load MAB with base address constant value embedded in IW-field; the value 0 emulates the Register Direct AM
                PC = PC + 1'b1;// Increment the PC to point to the location of the next IW
                // stall_mc0 = 1;
                if (Ri1 == 0) begin
                    MAX = 0; 
                end
                // TODO: double check that this data forward should be here or with the MAX = R[Ri1] at the else at the end
                else if (Ri1 == 1) MAX = PC;
                else if (Ri1 == 2) MAX = SP;
                else begin
                    if (Ri1 == Ri2) begin
                        MAX = TALUH;
                    end
                    else begin MAX = R[Ri1]; end
                end
            end //LD_IC, ST_IC, JMP_IC
            CALL_IC: begin
                PC = PC + 1'b1;
                SP = $unsigned(SP - 1'b1);
                if (Ri1 == 0) MAX = 0; 
                else if (Ri1 == 1) MAX = PC;
                else if (Ri1 == 2) MAX = SP;
                else MAX = R[Ri1]; 	//Load MAX
                MAB = MM_out;
                // Setup for write
                WR_DM = 1'b1;
                MM_in = PC;
                MAeff = SP;
                // stall_mc0 = 1;

            end
            RET_IC: begin
                MAeff = SP;
                SP = $unsigned(SP + 1'b1);
                WR_DM = 1'b0;
                stall_mc0 = 1;
            end
            IN_IC: begin
                IPDR[Rj1] = Input_Ps;
            end
            OUT_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 14'h3fff)) OPDR[Rj1] = TALUH[7:0];
                else OPDR[Rj1] = R[Ri1][7:0];
            end
            CPY_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 14'h3fff)) begin
                    TB = TALUH; // <-- DF-FU = Data Forwarding from the instruction in MC2
                end
                else begin
                    TB = R[Rj1];
                end
            end //CPY_IC
            NOT_IC, SRA_IC, RRC_IC, RRN_IC, RRZ_IC, SHRL_IC, ROTL_IC, RLN_IC, RLZ_IC, ROTR_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 14'h3fff)) begin
                    TA = TALUH; // <-- DF-FU = Data Forwarding from the instruction in MC2
                end
                else begin
                    TA = R[Ri1];
                end
                TB = Rj1;
            end // NOT_IC, SRA_IC, RRC_IC
            ADDC_IC, SUBC_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 14'h3fff)) begin
                    TA = TALUH; // <-- DF-FU
                end
                else begin
                    TA = R[Ri1]; 
                end
                TB = {10'b0000000000, IR1[3:0]};
            end // ADDC_IC, SUBC_IC

            VADDC_IC, VSUBC_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 14'h3fff)) begin
                    TA = TALUH; // <-- DF-FU
                end
                else begin
                    TA = R[Ri1]; 
                end
                TB = {10'b0000000000, IR1[3:0]};
            end // ADDC_IC, SUBC_IC



                // TODO: Fix this and make it work
                //       draw it out and you will see the pattern
                // if previous instruction is MUL DIV or SWAP
            ADD_IC, SUB_IC, AND_IC, OR_IC, XOR_IC, VADD_IC, VSUB_IC: begin
                if((IR2[13:8] == MUL_IC) || (IR2[13:8] == DIV_IC) || (IR2[13:8] == SWAP_IC)) begin
                    // if 
                    if (Rj1 == Rj2) begin
                        TB = TALUL;
                    end
                    else begin
                        TB = R[Rj1];
                    end
                    if (Rj1 == Ri2) begin
                        TB = TALUL;
                    end
                    else begin
                        TB = R[Rj1];
                    end
                    if (Ri1 == Rj2) begin
                        TA = TALUL;
                    end
                    else begin
                        TA = R[Ri1];
                    end
                    if (Ri1 == Ri2) begin
                        TA = TALUL;
                    end
                    else begin
                        TA = R[Ri1];
                    end
                end

                else begin
                    if ((Ri1 == Ri2) && (IR2 != 14'h3fff)) begin TA = TALUH; end
                    else begin TA = R[Ri1]; end
                    
                    if ((Rj1 == Rj2) && (IR2 != 14'h3fff)) begin TB = TALUH; end
                    else begin TB = R[Rj1]; end
                end
            end

            CMP_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 14'h3fff)) begin TA = TALUH; end
                else begin TA = R[Ri1]; end

                TB = Rj1;    
            end

            SWAP_IC, MUL_IC, DIV_IC: begin
                // DF-FU; Ri2 below is right for every previous instruction that returns a result in Ri2; 
                // need to modify for a previous SWAP if the value is to be Rj2
                if ((Ri1 == Ri2) && (IR2 != 14'h3fff)) begin
                    TA = TALUH; 
                end
                else begin
                    TA = R[Ri1];
                end
                if ((Rj1 == Rj2) && (IR2 != 14'h3fff)) begin
                    TB = TALUH; 
                end
                else begin
                    TB = R[Rj1]; 
                end
             
            end // SWAP_IC, ADD_IC, SUB_IC, AND_IC, OR_IC, XOR_IC, MUL_IC, DIV_IC,
            default: begin // Default case should not be reached
                `ifdef SIMULATION
                $display("ERROR: Default Case Selection Reached from MC1 , OPCODE: %b @ %t",IR1[13:8], $time());
                `endif
            end //default
        endcase // IR1[15:12]
    end // stall_mc1
//----------------------------------------------------------------------------
// MACHINE CYCLE 0 and Stall Control
//----------------------------------------------------------------------------
`ifndef DISABLE_PIPELINE
    // The only data D/H that can occur are RAW.  These are automatically resolved.  
    // In the case of the JUMPS we stall until the adress of the next instruction to be executed is known.
    // The IR value 0xffff I call a "don't care" OpCode value.  
    // It allows us to control the refill of the pipe after the stalls of a jump emptied it.
    // Instruction in MC2 can move to MC3; 
    // Below: Rj3 = Ri3 because the previous instruction returns a result in Ri2; 
    //        need to modify for a previous SWAP

    // if (stall_mc3 == 0) begin
    //     IR4 = IR3;
    // end


    if ((stall_mc2 == 0) && 
        (IR3[13:8] != JMP_IC)&& 
        (IR3[13:8] != LD_IC) && 
        (IR3[13:8] != ST_IC)&& 
        (IR3[13:8] != CALL_IC) && 
        (IR3[13:8] != RET_IC)) begin 
        IR3 = IR2;
        Ri3 = Ri2;
        Rj3 = Rj2;
        stall_mc3 = 0;
    end 
    // Instruction in MC2 is stalled and IR3 is loaded with the "don't care IW"    
    else begin 
        stall_mc2 =1; 
        IR3 = 14'h3fff; 
    end 
    // Instruction in MC1 can move to MC2; Rj2 may need to be = Ri1 for certain instruction sequences
    if ((stall_mc1 == 0) && 
        (IR2[13:8] != JMP_IC)&& 
        (IR2[13:8] != LD_IC) && 
        (IR2[13:8] != ST_IC)&& 
        (IR2[13:8] != CALL_IC) && 
        (IR2[13:8] != RET_IC)) begin 
        IR2 = IR1;
        Ri2 = Ri1;
        Rj2 = Rj1;
        stall_mc2 = 0;
    end
    // Instruction in MC1 is stalled and IR2 is loaded with the "don't care IW"    
    else begin
        stall_mc1 = 1;
        IR2 = 14'h3fff;
    end 
    // Instruction in MC0 can move to MC1;     
    if ((stall_mc0 == 0)        && 
        (IR1[13:8] != JMP_IC)   && 
        (IR1[13:8] != LD_IC)    && 
        (IR1[13:8] != ST_IC)    && 
        (IR1[13:8] != CALL_IC)  && 
        (IR1[13:8] != RET_IC)) begin
        // Below: IW0 is fetched directly into IR1, Ri1, and Rj1
       
        IR1 = MM_out; 
        Ri1 = MM_out[7:4];
        Rj1 = MM_out[3:0]; 
        PC = PC + 1'b1; 
        MAeff = PC;
        stall_mc1 = 0; 
    end
    // Instruction in MC0 is stalled and IR1 is loaded with the "don't care IW"    
    else begin 
        stall_mc0 = 1; 
        IR1 = 14'h3fff; 
    end 

    // // If mc0 is stalled and the output of main memory is store, keep on stalling MC0
    // if ((stall_mc0 == 1) && (MM_out[13:8] == ST_IC)) begin
    //     stall_mc0 = 1;
    // end
    // else begin
    //     stall_mc0 = 0;
    // end

    // After the JMP_IC instruction reaches MC3 OR (LD_IC or ST_C) reach MC1,
    // start refilling the pipe by removing the stalls. For JMP_IC the stalls are 
    // removed in this order: stall_mc0 --> stall_mc1 --> stall_mc2
    if ((IR3 == 14'h3fff) &&
        (IR2[13:8] != LD_IC) && 
        (IR2[13:8] != ST_IC) && 
        (IR2[13:8] != CALL_IC) && 
        (IR2[13:8] != RET_IC)) begin
        stall_mc0 = 0; 

        // after this also reset the Ri1 Ri2 Ri3 and Rj1 Rj2 Rj3 regs
        // Ri2 = 4'd0;
        // Rj2 = 4'd0;
        // Ri3 = 4'd0;
        // Rj3 = 4'd0;
    end

//---------------------------------------------------------------------------
// STALL FOR MEMORY TO BE DONE
//---------------------------------------------------------------------------

// if (~Cache_done) begin
//     stall_mc0 = 1'b1;
//     stall_mc1 = 1'b1;
//     stall_mc2 = 1'b1;
//     stall_mc3 = 1'b1;
// end
// else begin
//     stall_mc0 = 1'b0;
//     stall_mc1 = 1'b0;
//     stall_mc2 = 1'b0;
//     stall_mc3 = 1'b0;
// end




`else // ifndef DISABLE_PIPELINE
    // Alternative Operation Mode, Disables Pipeline
    // For Debug and Benchmarking Purposes Only! -> This can help you find data-forwarding issues
    if (stall_mc0 == 0) begin
		  MAeff = PC;
        IR1 = MM_out;
        Ri1 = MM_out[7:4];
        Rj1 = MM_out[3:0];
        PC = PC + 1'b1;
        stall_mc1 = 0;
        stall_mc0 = 1;
        IR2 = 14'h3fff;
        IR3 = 14'h3fff;
    end
    else if (stall_mc1 == 0) begin
        IR2 = IR1;
        Ri2 = Ri1;
        Rj2 = Rj1;
        stall_mc2 = 0;
        stall_mc1 = 1;
        IR1 = 14'h3fff;
        IR3 = 14'h3fff;
    end
    else if (stall_mc2 == 0) begin
        IR3 = IR2;
        Ri3 = Ri2;
        Rj3 = Ri3;
        stall_mc3 = 0;
        stall_mc2 = 1;
        IR2 = 14'h3fff;
        IR1 = 14'h3fff;
    end
    else if (stall_mc3 == 0) begin
        stall_mc0 = 0;
        stall_mc3 = 1;
    end
`endif // ifndef DISABLE_PIPELINE
end // reset
else if (~Cache_done) begin    
    Wait_for_cache = 1'b1; // Normal Operation
end
end // my_CPU
endmodule
