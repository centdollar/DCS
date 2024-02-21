// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
//----------------------------------------------------------------------------
// dxpRISC521pipe_v    Harvard    Memory Mapped I/O-Ps - top 16 locations
// (c) Dorin Patru 2022; Updated by Stefan Maczynski 2023
//----------------------------------------------------------------------------
// `define SIMULATION              // REMOVE FOR FPGA EMULATION!
// `define DISABLE_PIPELINE      // Use for debuging issues with data-forwarding!
// `define NOCACHE              // Uncomment to remove hierachical memory

// TODO:
/*
- 14 -> 16 bit                  DONE
- FP add, sub, mul, div
- VN -> Harvard                 WORKING ON NOW
- 2 bit branch predictor
- SIMD mul and div
*/



`include "TestBenchControl.vh"

module vfmRISC621pipe_v (
input             Resetn_pin        , // Reset, implemented with push-button on FPGA
input             Clock_pin         , // Clock, implemented with Oscillator on FPGA

input [15:0]       In0,     // write signal that triggers on MC3 of OUT_IC if we wrote to output peripheral 1
input [15:0]       In1,
input [15:0]       In2,
input [15:0]       In3,
input [15:0]       In4,
input [15:0]       In5,
input [15:0]       In6,
input [15:0]       In7,
input [15:0]       In8,
input [15:0]       In9,
input [15:0]       In10,
input [15:0]       In11,
input [15:0]       In12,
input [15:0]       In13,
input [15:0]       In14,
input [15:0]       In15,

// These signals are used for inter-core communication using OUT_IC
// Are used as the tri-state buffer inputs for the input peripherals for other cores
output reg  [15:0]       Out0,     // write signal that triggers on MC3 of OUT_IC if we wrote to output peripheral 1
output reg  [15:0]       Out1,
output reg  [15:0]       Out2,
output reg  [15:0]       Out3,
output reg  [15:0]       Out4,
output reg  [15:0]       Out5,
output reg  [15:0]       Out6,
output reg  [15:0]       Out7,
output reg  [15:0]       Out8,
output reg  [15:0]       Out9,
output reg  [15:0]       Out10,
output reg  [15:0]       Out11,
output reg  [15:0]       Out12,
output reg  [15:0]       Out13,
output reg  [15:0]       Out14,
output reg  [15:0]       Out15



);
parameter INSTR_WIDTH = 16;

//----------------------------------------------------------------------------
//-- Declare machine cycle and instruction cycle parameters
//----------------------------------------------------------------------------

// Instructions
// MEMORY INSTRUCTIONS
    //reg-mem data transfer
localparam [5:0] LD_IC   = 6'b000000 ; // Load
localparam [5:0] ST_IC   = 6'b000001 ; // Store

// FP INSTRUCTIONS
localparam [5:0] FPADD_IC = 6'b001000; // FPADD
localparam [5:0] FPSUB_IC = 6'b001001; // FPADD
localparam [5:0] FPMUL_IC = 6'b001010; // FPADD
localparam [5:0] FPDIV_IC = 6'b001011; // FPADD



// REG REG INSTRUCTION TYPE
    // Peripheral Output
localparam [5:0] IN_IC   = 6'b100000; // Peripheral input
localparam [5:0] OUT_IC  = 6'b100001; // Peripheral Output

    // reg-reg manipulation
localparam [5:0] CPY_IC  = 6'b100011 ; // Copy
localparam [5:0] SWAP_IC = 6'b100010 ; // Swap

    // primititve integer manip
localparam [5:0] ADD_IC  = 6'b101000 ; // Add
localparam [5:0] SUB_IC  = 6'b101001 ; // Subtract
localparam [5:0] MUL_IC  = 6'b101010 ; // Multiply
localparam [5:0] DIV_IC  = 6'b101011 ; // Divide

    //logic manipulation
localparam [5:0] NOT_IC  = 6'b100111 ; // Not
localparam [5:0] AND_IC  = 6'b100101 ; // And
localparam [5:0] OR_IC   = 6'b100110 ; // Or
localparam [5:0] XOR_IC  = 6'b100100 ; // XOR

    //SIMD (vector) 
localparam [5:0] VADD_IC = 6'b110000 ; // Vector Add
localparam [5:0] VSUB_IC = 6'b110001 ; // Vector Subtract
localparam [5:0] VMUL_IC  = 6'b110010 ; // Vector Multiplication
localparam [5:0] VDIV_IC  = 6'b110011 ; // Vector Division

// REG IMMED INSTRUCTIONS

localparam [5:0]  CMP_IC  = 6'b010000;

    // Vector Constant 
localparam [5:0] VADDC_IC = 6'b111011 ; // Vector Add
localparam [5:0] VSUBC_IC = 6'b111100 ; // Vector Subtract

    // Shifts and rotates
localparam [5:0] SHRL_IC = 6'b010001 ; // Shift right logical
localparam [5:0] SRA_IC = 6'b010010 ; // Shift right arithmetic
localparam [5:0] ROTL_IC = 6'b010011 ; // Rotate left 
localparam [5:0] ROTR_IC = 6'b010100 ; // rotate right

    // integer manip constant
localparam [5:0] ADDC_IC = 6'b010101 ; // Add Constant
localparam [5:0] SUBC_IC = 6'b010110 ; // Subtract Constant

    // rotate right through status
localparam [5:0] RRC_IC  = 6'b011000 ; // Rotate Right Through Carry
localparam [5:0] RRN_IC  = 6'b011001 ; // Rotate right through negative
localparam [5:0] RRZ_IC  = 6'b011010 ; // Rotate right thorugh zero

    // rotate left through status
localparam [5:0] RLN_IC  = 6'b011100 ; // rotate left through negative
localparam [5:0] RLZ_IC  = 6'b011101 ; // rotate left through zero

// JUMP
    //flow control
localparam [5:0] JMP_IC  = 6'b000100 ; // Jump
    //arithmetic manipulation
//Jump conditions
localparam [4:0]  JU  = 5'b00000 ; // Jump Unconditional
localparam [4:0]  JC1 = 5'b10000 ; // Jump if Carry == 1
localparam [4:0]  JN1 = 5'b01000 ; // Jump if Negative == 1
localparam [4:0]  JV1 = 5'b00100 ; // Jump if Overflow == 1
localparam [4:0]  JZ1 = 5'b00010 ; // Jump if Zero == 1
localparam [4:0]  JC0 = 5'b01110 ; // Jump if Carry == 0
localparam [4:0]  JN0 = 5'b10110 ; // Jump if Negative == 0
localparam [4:0]  JV0 = 5'b11010 ; // Jump if Overflow == 0
localparam [4:0]  JZ0 = 5'b11100 ; // Jump if Zero == 0

// CALL and REturn
localparam [5:0]  CALL_IC = 6'b111110;
localparam [5:0]  RET_IC  = 6'b111101;

// Compare instruction for loops
localparam [5:0]  NOP_IC  = 6'b111000;


//----------------------------------------------------------------------------
//-- Declare internal signals
//----------------------------------------------------------------------------
reg  [INSTR_WIDTH-1:0]          R       [31:0] ; // Register File (RF) 64 16-bit registers
reg  [INSTR_WIDTH-1:0]          branchingRFClone       [31:0] ; // Register File (RF) 64 16-bit registers
reg  [INSTR_WIDTH-1:0]          FPR     [31:0] ;
reg                             WR_DM          ; // Write-enable data-memory input
reg                             stall_mc0      ; // Stall Control Bits
reg                             stall_mc1      ; // Stall Control Bits
reg                             stall_mc2      ; // Stall Control Bits
reg                             stall_mc3      ; // Stall Control Bits
reg  [INSTR_WIDTH-1:0]          PC             ; // Program Counter
reg  [INSTR_WIDTH-1:0]          IR4            ;
reg  [INSTR_WIDTH-1:0]          IR3            ; // Instruction Register 3
reg  [INSTR_WIDTH-1:0]          IR2            ; // Instruction Register 2
reg  [INSTR_WIDTH-1:0]          IR1            ; // Instruction Register 1
reg  [INSTR_WIDTH-1:0]          MAB            ; // Memory Address B
reg  [INSTR_WIDTH-1:0]          MAX            ; // Memory Address X
reg  [INSTR_WIDTH-1:0]          MAeff          ; // Memory Address Effective
reg  [INSTR_WIDTH-1:0]          MM_in          ; // Data-Memory Input
reg  [INSTR_WIDTH-1:0]          TA             ; // Temporary Input of Arithmetic-Logic-Unit "A"
reg  [INSTR_WIDTH-1:0]          TB             ; // Temporary Input of Arithmetic-Logic-Unit "B"
reg  [INSTR_WIDTH-1:0]          FPAdd_a           ;
reg  [INSTR_WIDTH-1:0]          FPAdd_b           ;
reg  [INSTR_WIDTH-1:0]          FPSub_a           ;
reg  [INSTR_WIDTH-1:0]          FPSub_b           ;
reg  [INSTR_WIDTH-1:0]          FPMul_a           ;
reg  [INSTR_WIDTH-1:0]          FPMul_b           ;
reg  [INSTR_WIDTH-1:0]          FPDiv_a           ;
reg  [INSTR_WIDTH-1:0]          FPDiv_b           ;
reg  [INSTR_WIDTH-1:0]          TFP           ;
reg  [32:0]                     TALUout        ; // Temoprary Output of Arithmetic-Logic-Unit with carry
reg  [INSTR_WIDTH-1:0]          TALUH          ; // Temporary Output of Arithmetic-Logic-Unit "High"
reg  [INSTR_WIDTH-1:0]          TALUL          ; // Temporary Output of Arithmetic-Logic-Unit "Low"
reg  [4:0]                      Ri1            ; // Index within registerfile
reg  [4:0]                      Rj1            ; // Index within registerfile
reg  [4:0]                      Ri2            ; // Index within registerfile
reg  [4:0]                      Rj2            ; // Index within registerfile
reg  [4:0]                      Ri3            ; // Index within registerfile
reg  [4:0]                      Rj3            ; // Index within registerfile
reg  [11:0]                     TSR            ; // Temporary Status Register
reg  [11:0]                     SR             ; // Status Register
wire                            Clock_not      ; // Inverted Clock
wire                            PM_Cache_done     ;
wire                            MM_Cache_done     ;
wire [INSTR_WIDTH-1:0]          MM_out         ; // Output of monolithic memory 
wire [INSTR_WIDTH-1:0]          PM_out         ; // Output of monolithic memory 
wire  [INSTR_WIDTH-1:0]          FPAdd_q           ;
wire  [INSTR_WIDTH-1:0]          FPSub_q           ;
wire  [INSTR_WIDTH-1:0]          FPMul_q           ;
wire  [INSTR_WIDTH-1:0]          FPDiv_q           ;

reg  [2*INSTR_WIDTH+1:0]        TALUS          ; // temporary alu shift reg for status shifting
reg unsigned [INSTR_WIDTH-1:0]  SP        ;
integer        k              ; // Index for looping construct

reg [INSTR_WIDTH-1:0] IPDR;          // 16 14-bit Input peripheral Data registers, addressed by Rj in IN_IC

reg [INSTR_WIDTH-1:0] OPDR;          // 16 14-bit output registers that are addressed by Rj in the in OUT_IC

reg BP_en;
reg [7:0] BPAddr;
reg [4:0] BPJumpType;
reg [15:0] TPC;
wire jumpTaken;

wire stall_pipe;
wire pred_correct;


reg enable_add;
reg enable_sub;
reg enable_mul;
reg enable_div;
wire FPSUB_stall;
wire FPADD_stall;
wire FPMUL_stall;
wire FPDIV_stall;
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


branchPred_v BP (
    .clk(Clock_pin),
    .resetn(Resetn_pin),
    .address(BPAddr),
    .jumpType(BPJumpType),
    .statusBits(TSR),
    .currPC(TPC),
    .enable(BP_en && stall_pipe),
    .jumpTaken(jumpTaken),
    .pred_correct(pred_correct)
);


`ifdef NOCACHE
// only use 14 bits for memory rn, the lower 14
vfm6849_rom1 PM (
    .address    ( PC      [ 13:0]), // input
    .clock      ( Clock_not         ), // input
    .q          ( PM_out     [INSTR_WIDTH-1:0] )  // output
);

vfmRISC621_ram1 MM (
    .address    ( MAeff      [ 13:0]), // input
    .clock      ( Clock_not         ), // input
    .data       ( MM_in      [INSTR_WIDTH-1:0] ), // input
    .wren       ( WR_DM             ), // inputs
    .q          ( MM_out     [INSTR_WIDTH-1:0] )  // output
);

assign PM_Cache_done = 1;
assign MM_Cache_done = 1;
`else
vfm_cache_4w_PM_v2 PM (
    .Resetn      ( Resetn_pin               ), // input
    .MEM_address ( PC        [13:0]      ), // input   // Address coming from the CPU
    .Clock       ( Clock_not                ), // input
    .MEM_out     ( PM_out       [INSTR_WIDTH-1:0]      ), // output  // Data Stored at the Address pointed to by MEM_address
    .Done        ( PM_Cache_done               )  // output  // Data out is valid
);

vfm_cache_4w_v2 MM (
    .Resetn      ( Resetn_pin               ), // input
    .MEM_address ( MAeff        [13:0]      ), // input   // Address coming from the CPU
    .MEM_in      ( MM_in        [INSTR_WIDTH-1:0]      ), // input   // Write-Back data from the CPU
    .WR          ( WR_DM                    ), // input   // Write-Enable from the CPU
    .Clock       ( Clock_not                ), // input
    .MEM_out     ( MM_out       [INSTR_WIDTH-1:0]      ), // output  // Data Stored at the Address pointed to by MEM_address
    .Done        ( MM_Cache_done               )  // output  // Data out is valid
);

`endif

FPAddWrap_v FPAddWrap (
    .clk    (Clock_pin),
    .reset  (Resetn_pin),
    .enable (enable_add),
    .A      (FPAdd_a),
    .B      (FPAdd_b),
    .Q      (FPAdd_q),
    .stall  (FPADD_stall)
);

FPSubWrap_v FPSubWrap (
    .clk    (Clock_pin),
    .reset  (Resetn_pin),
    .enable (enable_sub),
    .A      (FPSub_a),
    .B      (FPSub_b),
    .Q      (FPSub_q),
    .stall  (FPSUB_stall)
);

FPMultWrap_v FPMultWrap (
    .clk    (Clock_pin),
    .reset  (Resetn_pin),
    .enable (enable_mul),
    .A      (FPMul_a),
    .B      (FPMul_b),
    .Q      (FPMul_q),
    .stall  (FPMUL_stall)
);

FPDivWrap_v FPDivWrap (
    .clk    (Clock_pin),
    .reset  (Resetn_pin),
    .enable (enable_div),
    .A      (FPDiv_a),
    .B      (FPDiv_b),
    .Q      (FPDiv_q),
    .stall  (FPDIV_stall)
);



assign stall_pipe = PM_Cache_done && MM_Cache_done && ~FPSUB_stall && ~FPADD_stall && ~FPMUL_stall && ~FPDIV_stall;

//------------------------------------------------------------------------------------------------------------------------------------------
// - Behavioral section of the code.  Assignments are evaluated in order, i.e. sequentially.
// - New assigned values are visible outside the always block only after it is exit.
// - Last assigned value will be the exit value.
//------------------------------------------------------------------------------------------------------------------------------------------
always@(posedge Clock_pin) begin : my_CPU


//----------------------------------------------------------------------------
// RESET 
//----------------------------------------------------------------------------
if (Resetn_pin == 0) begin    
    // - The reset is active low and clock synchronous.
    // - Initialize registers.
    PC = 16'h0000; // Initialize the PC to point to the location of the FIRST instruction to be executed; location 0000 is arbitrary!
    for (k = 0; k < 32; k = k+1) begin R[k] = 0; end
    for (k = 2; k < 32; k = k+1) begin FPR[k] = 0; end
    FPR[0] = 16'b0100010000000000;
    FPR[1] = 16'b0100010100000000;
    TFP = 0;
    MAB         = 16'd0;
    MAX         = 16'd0;
    MAeff       = 16'd0;
    MM_in       = 16'd0;
    TA          = 16'd0;
    TB          = 16'd0;
    TALUH       = 16'd0;
    TALUL       = 16'd0;
    TSR         = 12'd0;
    SR          = 12'd0;
    SP          = 16'hFFFF;
    TALUout     = 16'd0;
    Ri1         = 4'd0;
    Rj1         = 4'd0;
    Ri2         = 4'd0;
    Rj2         = 4'd0;
    Ri3         = 4'd0;
    Rj3         = 4'd0;
    IPDR        = 16'd0;

    Out0        = 16'd0;
    Out1        = 16'd0;
    Out2        = 16'd0;
    Out3        = 16'd0;
    Out4        = 16'd0;
    Out5        = 16'd0;
    Out6        = 16'd0;
    Out7        = 16'd0;
    Out8        = 16'd0;
    Out9        = 16'd0;
    Out10        = 16'd0;
    Out11        = 16'd0;
    Out12        = 16'd0;
    Out13        = 16'd0;
    Out14        = 16'd0;
    Out15        = 16'd0;

    enable_add = 1'b0;
    enable_sub = 1'b0;
    enable_mul = 1'b0;
    enable_div = 1'b0;

    BP_en = 1'b0;
    BPAddr = 8'd0;
    BPJumpType = 5'd0;



    // Display_pin =  8'd0;
    IR1         = 16'hffff; // All IRs are initialized to the "don't care OpCode value 0xffff
    IR2         = 16'hffff;
    IR3         = 16'hffff;
    IR4         = 16'hffff;
    stall_mc0   =  1'b0; // The initialization of the stall_mc signals is necessary for the correct startup of the pipeline.
    stall_mc1   =  1'b1;
    stall_mc2   =  1'b1;
    stall_mc3   =  1'b1;
    WR_DM       =  1'b0;
end // if (Resetn_pin == 0)
else if (stall_pipe) begin // Normal Operation
//----------------------------------------------------------------------------
// MACHINE CYCLE 3
//----------------------------------------------------------------------------
    // MC3 is executed first because its assignments might be needed by the instructions executing MC2 or MC1 to resolve data or control D/H.
    // An instruction that has arrived in MC3 does not have any dependency.
    if ((stall_mc3 == 0) && (IR3 != 16'hFFFF)) begin 
        case (IR3[INSTR_WIDTH-1:10]) // Decode the OpCode of the IW
            LD_IC: begin
                R[IR3[4:0]] = MM_out;   
                // MAeff = PC;
            end // LD_IC
            ST_IC: begin
                MM_in = R[IR3[4:0]];
                WR_DM = 1'b0;
                // MAeff = PC;
                // stall_mc0 = 1;
            end // ST_IC
            CALL_IC: begin
                PC = MAB + MAX;
                // MAeff = MAB + MAX;
                WR_DM = 1'b0;
                // stall_mc0 = 1;
            end
            RET_IC: begin
                PC = MM_out;
                // MAeff = PC;
                WR_DM = 1'b0;
            end
            IN_IC: begin
                PC = PC + 1'b0;
            end
            OUT_IC: begin
                PC = PC + 1'b0;
            end
            CPY_IC: begin
                    R[IR3[9:5]] = TALUL;
            end // CPY_IC
            SWAP_IC: begin
                    R[IR3[9:5]] = TALUL;
                    R[IR3[4:0]] = TALUH;
            end // SWAP_IC
            JMP_IC: begin
                BP_en = 1'b0;
                // case (IR3[4:0])
                //     JU : begin PC = MAeff; end
                //     JC1: begin if (SR[11] == 1) PC = MAeff; else PC = PC; end
                //     JN1: begin if (SR[10] == 1) PC = MAeff; else PC = PC; end
                //     JV1: begin if (SR[9]  == 1) PC = MAeff; else PC = PC; end
                //     JZ1: begin if (SR[8]  == 1) PC = MAeff; else PC = PC; end
                //     JC0: begin if (SR[11] == 0) PC = MAeff; else PC = PC; end
                //     JN0: begin if (SR[10] == 0) PC = MAeff; else PC = PC; end
                //     JV0: begin if (SR[9]  == 0) PC = MAeff; else PC = PC; end
                //     JZ0: begin if (SR[8]  == 0) PC = MAeff; else PC = PC; end
                //     default: PC = PC;
                // endcase
            end // JMP_IC
            ADD_IC, SUB_IC, ADDC_IC, SUBC_IC, VADD_IC, VSUB_IC, VADDC_IC, VSUBC_IC, NOT_IC, AND_IC, OR_IC, XOR_IC, ROTL_IC, ROTR_IC, SHRL_IC, SRA_IC, RLN_IC, RLZ_IC, RRN_IC, RRC_IC, RRZ_IC, VMUL_IC, VDIV_IC : begin
                R[IR3[9:5]] = TALUH;
                SR = TSR;
            end // ADD_IC, SUB_IC, ADDC_IC, SUBC_IC, NOT_IC, AND_IC, OR_IC, SRA_IC, RRC_IC

            CMP_IC: begin
                SR = TSR;
            end
            
            MUL_IC, DIV_IC: begin
                R[IR3[9:5]] = TALUH;
                R[IR3[4:0]] = TALUL;
                SR = TSR;
            end
            NOP_IC: begin
                PC = PC + 1'b0;
            end

            FPADD_IC: begin
                FPR[IR3[9:5]] = TFP;
                enable_add = 1'b0;
            end
            
            FPSUB_IC: begin
                FPR[IR3[9:5]] = TFP;
                enable_sub = 1'b0;
            end
            
            FPMUL_IC: begin
                FPR[IR3[9:5]] = TFP;
                enable_mul = 1'b0;
            end
            
            FPDIV_IC: begin
                FPR[IR3[9:5]] = TFP;
                enable_div = 1'b0;
            end

            default: begin // Default case should not be reached0
                `ifdef SIMULATION
                $display("ERROR: Default Case Selection Reached from MC3 , OPCODE: %b @ %t",IR3[INSTR_WIDTH-1:10], $time());
                `endif
            end // default
        endcase // IR3[15:12]
    end // stall_mc3
//----------------------------------------------------------------------------
// MACHINE CYCLE 2
//----------------------------------------------------------------------------
    if ((stall_mc2 == 0) && (IR2 != 16'hFFFF)) begin
        case (IR2[15:10]) // Decode the OpCode of the IW
            LD_IC: begin
                MAeff = MAB + MAX; // Address Arithmetic to calculate the effective address
                WR_DM = 1'b0; // For LD_IC we ensure here that WR_DM=0.
            end
            
            JMP_IC: begin
                WR_DM = 1'b0; // For LD_IC we ensure here that WR_DM=0.
                if(IR2[15:10] == JMP_IC) begin
                    BP_en = 1'b0;
                    if(jumpTaken) begin
                        PC = MAB + MAX + 1'b1;
                    end
                    else begin 
                        PC = TPC;
                    end
                end
            end // LD_IC, JMP_IC
            ST_IC: begin
                MAeff = MAB + MAX;

                // Does this block off space for the stack?
                if (MAeff[INSTR_WIDTH-1:2] != 14'h3FFF) begin
                    WR_DM = 1'b1;
                    // DF-PU = Data Forwarding from the instruction in MC3:
                        // 1st, From the instructions that perform a write-back:
                    if ((Rj2 == Ri3) && (IR3[INSTR_WIDTH-1:10] != LD_IC ) && (IR3[INSTR_WIDTH-1:10] !=  ST_IC) && (IR3[INSTR_WIDTH-1:10] != JMP_IC)) begin
                        MM_in = R[Ri3];
                    end
                    // Next, resolve the SWAP write-back:
                    else if (Rj2 == Rj3 && IR3[INSTR_WIDTH-1:0] == SWAP_IC) begin
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
                MM_in = {SR, 4'b00};
                WR_DM = 1'b1;
                MAeff = SP;
            end
            RET_IC: begin
                MAeff = SP;
                SP = $unsigned(SP + 1'b1);
                SR = MM_out[INSTR_WIDTH-1:4];
                WR_DM = 1'b0;
            end
            IN_IC: begin
                R[Ri2] = IPDR;
            end
            OUT_IC: begin
                 case(Rj2)
                    5'd0: begin Out0 = OPDR; end
                    5'd1: begin Out1 = OPDR; end
                    5'd2: begin Out2 = OPDR; end
                    5'd3: begin Out3 = OPDR; end
                    5'd4: begin Out4 = OPDR; end
                    5'd5: begin Out5 = OPDR; end
                    5'd6: begin Out6 = OPDR; end
                    5'd7: begin Out7 = OPDR; end
                    5'd8: begin Out8 = OPDR; end
                    5'd9: begin Out9 = OPDR; end
                    5'd10: begin Out10 = OPDR; end
                    5'd11: begin Out11 = OPDR; end
                    5'd12: begin Out12 = OPDR; end
                    5'd13: begin Out13 = OPDR; end
                    5'd14: begin Out14 = OPDR; end
                    5'd15: begin Out15 = OPDR; end
                    default: begin 
                        
                    end
                endcase
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
                TSR[11] = TALUout[16]; // Carry
                TSR[10] = TALUout[15]; // Negative
                TSR[9] = ((TA[15] ~^ TB[15]) & TA[15]) ^ (TALUout[15] & (TA[15] ~^ TB[15])); // V Overflow
                if (TALUout[15:0] == 16'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
                TALUH = TALUout[15:0];
            end // ADD_IC, ADDC_IC
            SUB_IC, SUBC_IC, CMP_IC: begin
                TALUout = TA - TB;
                TSR[11] = TALUout[16]; // Carry
                TSR[10] = TALUout[15]; // Negative
                TSR[9] = ((TA[15] ~^ TB[15]) & TA[15]) ^ (TALUout[15] & (TA[15] ~^ TB[15])); // V Overflow
                if (TALUout[15:0] == 16'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
                if (IR2[15:10] == CMP_IC) begin TALUH = TALUH; end
                else begin TALUH = TALUout[15:0]; end
            end // SUB_IC, SUBC_IC

            VADD_IC, VADDC_IC: begin

                // Add the two parts of the vector independently
                TALUout[16:9] = TA[15:8] + TB[15:8];
                TALUout[8:0] = TA[7:0] + TB[7:0];


                TSR[11] = TALUout[16]; // Carry
                TSR[10] = TALUout[15]; // Negative
                TSR[9] = ((TA[15] ~^ TB[15]) & TA[15]) ^ (TALUout[15] & (TA[15] ~^ TB[15])); // V Overflow
                if (TALUout[15:8] == 8'h0000) begin TSR[8] = 1; end else begin TSR[8] = 0; end

                TSR[7] = TALUout[7]; // Carry
                TSR[6] = TALUout[7]; // Negative
                TSR[5] = ((TA[7] ~^ TB[7]) & TA[7]) ^ (TALUout[7] & (TA[7] ~^ TB[7])); // V Overflow
                if (TALUout[7:0] == 8'h0000) begin TSR[4] = 1; end else begin TSR[4] = 0; end

                TALUH = {TALUout[15:8], TALUout[7:0]};
            end // VADD_IC, VADDC_IC

            VSUB_IC, VSUBC_IC: begin

                // Add the two parts of the vector independently
                TALUout[14:8] = TA[13:7] - TB[6:0];
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

            VMUL_IC: begin
                TALUout[16:9] = TA[15:8] * TB[15:8];
                TALUout[8:0]  = TA[7:0]  * TB[7:0];

                // Top half of Vector
                TSR[11] = TALUout[16]; // Carry
                TSR[10] = TALUout[15]; // Negative
                TSR[9] = ((TA[14] ~^ TB[14]) & TA[14]) ^ (TALUout[14] & (TA[14] ~^ TB[14])); // V Overflow
                if (TALUout[16:9] == 8'd0) begin TSR[8] = 1'b1; end else begin TSR[8] = 1'b0; end

                // Bottom half of vector
                TSR[7] = TALUout[8]; // Carry
                TSR[6] = TALUout[7]; // Negative
                TSR[5] = ((TA[6] ~^ TB[6]) & TA[6]) ^ (TALUout[6] & (TA[6] ~^ TB[6])); // V Overflow
                if (TALUout[8:0] == 8'd0) begin TSR[4] = 1'b1; end else begin TSR[4] = 1'b0; end

                TALUH = {TALUout[15:9], TALUout[7:0]};
            end


            VDIV_IC: begin
                TALUout[16:9] = TA[15:8] / TB[15:8];
                TALUout[8:0]  = TA[7:0]  / TB[7:0];

                // Top half of Vector
                TSR[11] = TALUout[16]; // Carry
                TSR[10] = TALUout[15]; // Negative
                TSR[9] = ((TA[14] ~^ TB[14]) & TA[14]) ^ (TALUout[14] & (TA[14] ~^ TB[14])); // V Overflow
                if (TALUout[16:9] == 8'd0) begin TSR[8] = 1'b1; end else begin TSR[8] = 1'b0; end

                // Bottom half of vector
                TSR[7] = TALUout[8]; // Carry
                TSR[6] = TALUout[7]; // Negative
                TSR[5] = ((TA[6] ~^ TB[6]) & TA[6]) ^ (TALUout[6] & (TA[6] ~^ TB[6])); // V Overflow
                if (TALUout[8:0] == 8'd0) begin TSR[4] = 1'b1; end else begin TSR[4] = 1'b0; end

                TALUH = {TALUout[15:9], TALUout[7:0]};
            end

            MUL_IC: begin
                TALUout = TA * TB;
                TSR[11] = TALUout[16]; // Carry
                TSR[10] = TALUout[15]; // Negative
                TSR[9] = ((TA[15] ~^ TB[15]) & TA[15]) ^ (TALUout[15] & (TA[15] ~^ TB[15])); // V Overflow
                if (TALUout[31:0] == 32'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
                TALUH = TALUout[31:16];
                TALUL = TALUout[15:0];
            end // MUL_IC
            DIV_IC: begin
                TALUout = TA / TB;
                TALUL = TA % TB;
                TSR[11] = TALUout[16]; // Carry
                TSR[10] = TALUout[15]; // Negative
                TSR[9] = ((TA[15] ~^ TB[15]) & TA[15]) ^ (TALUout[15] & (TA[15] ~^ TB[15])); // V Overflow
                if (TALUout[15:0] == 16'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
                TALUH = TALUout[15:0];
            end // DIV_IC
            NOT_IC: begin
                TALUH = ~TA; //Carry and Overflow are not affected by ~
                TSR[10] = TALUH[15]; // Negative
                if (TALUout[15:0] == 16'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
            end // NOT_IC
            AND_IC: begin
                TALUH = TA & TB; //Carry and Overflow are not affected by &
                TSR[10] = TALUH[15]; // Negative
                if (TALUout[15:0] == 16'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
            end // AND_IC
            OR_IC: begin
                TALUH = TA | TB; //Carry and Overflow are not affected by |
                TSR[10] = TALUH[15]; // Negative
                if (TALUout[15:0] == 16'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
            end // OR_IC
            XOR_IC: begin
                TALUH = TA ^ TB; //Carry and Overflow are not affected by |
                TSR[10] = TALUH[15]; // Negative
                if (TALUout[15:0] == 16'h0000) begin
                    TSR[8] = 1; 
                end
                else begin
                    TSR[8] = 0; // Zero
                end
            end // XOR_IC
            SHRL_IC: begin
                if(TA[15] == 1'b1) TALUout = {16'b11111111111111, TA} >> TB;
                else TALUout = {16'b00000000000000, TA} >> TB;
                TALUH = TALUout[15:0];
                TSR[10] = TALUout[15]; // Negative
                if (TALUout[15:0] == 16'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\

            end // SHRL_IC
            ROTL_IC:
                begin
                    TALUout = {TA,TA} << TB;
                    TALUH = TALUout[31:16];
                    TSR[10] = TALUH[15]; // Negative
                    if (TALUH[15:0] == 16'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end // ROTL_IC
            SRA_IC: begin
                    if(TA[15] == 1'b1) TALUout = {16'hFFFF, TA} >> TB;
                    else TALUout = {16'h0000, TA} >> TB;
                    TALUH = TALUout[15:0];
                    TSR[10] = TALUout[15]; // Negative
                    if (TALUout[15:0] == 16'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end
            ROTR_IC:
                begin
                TALUout = {{TA, TA} >> TB};
                TALUH = TALUout[15:0];
                TSR[10] = TALUH[15]; // Negative
                if (TALUH[15:0] == 16'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end // ROTR_IC
            RLN_IC:
                begin
							//		[33:18]	17	  [16:1]  0
                    TALUS = {TA, TSR[10], TA, TSR[10]} << TB;
                    TALUH = TALUS[33:18];	
                    TSR[10] = TALUH[15]; // Negative
                    if (TALUH[15:0] == 16'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end // RLN_IC
            RLZ_IC:
                begin
                    TALUS = {TA, TSR[8], TA, TSR[8]} << TB;
                    TALUH = TALUS[33:18];
                    TSR[10] = TALUH[15]; // Negative
                    if (TALUH[15:0] == 16'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end // RLZ_IC
            RRN_IC:
                begin
                    TALUS = {TSR[10], TA, TSR[10], TA} >> TB;
                    TALUH = TALUS[15:0];
                    TSR[10] = TALUS[16]; // Negative
                    if (TALUH[15:0] == 16'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end //RRN_IC

            RRC_IC:
                begin
                    TALUS = {TSR[11], TA, TSR[11], TA} >> TB;
                    TALUH = TALUS[15:0];
                    TSR[11] = TALUS[16]; // Negative
                    if (TALUH[15:0] == 16'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end //RRN_IC
            RRZ_IC:
                begin
                    TALUS = {TSR[8], TA, TSR[8], TA} >> TB;
                    TALUH = TALUS[15:0];
                    TSR[10] = TALUH[15]; // Negative
                    TSR[8] = TALUS[16];
                    // if (TALUH[13:0] == 14'h0000) TSR[8] = 1; else TSR[8] = 0; // Zero\
                end //RRZ_IC
            NOP_IC: begin
                PC = PC + 1'b0;
            end

            FPADD_IC: begin
                TFP = FPAdd_q;
                enable_add = 1'b0;
            end

            FPSUB_IC: begin
                TFP = FPSub_q;
                enable_sub = 1'b0;
            end
            
            FPMUL_IC: begin
                TFP = FPMul_q;
                enable_mul = 1'b0;
            end
            
            FPDIV_IC: begin
                TFP = FPDiv_q;
                enable_div = 1'b0;
            end

            default: begin // Default case should not be reached
                `ifdef SIMULATION
                $display("ERROR: Default Case Selection Reached from MC2 , OPCODE: %b @ %t",IR2[15:10], $time());
                `endif
            end //default
        endcase // IR2[15:12]
    end // stall_mc2
//----------------------------------------------------------------------------
// MACHINE CYCLE 1
//----------------------------------------------------------------------------
    if ((stall_mc1 == 0) && (IR1 != 16'hffff)) begin // MC1, or Operand Fetch for manip inst, or Address_Fetch for transfer and flow control inst
        case (IR1[INSTR_WIDTH-1:10]) // Decode the OpCode of the IW
            LD_IC, ST_IC: begin
                // MAeff = PC;
                MAB = PM_out; // Load MAB with base address constant value embedded in IW-field; the value 0 emulates the Register Direct AM
                PC = PC + 1'b1;// Increment the PC to point to the location of the next IW
                // stall_mc0 = 1;
                if (Ri1 == 0) begin
                    MAX = 0; 
                end
                // TODO: double check that this data forward should be here or with the MAX = R[Ri1] at the else at the end
                else if (Ri1 == 1) MAX = PC;
                else if (Ri1 == 2) MAX = SP;
                else begin
                    if ((Ri1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC)) begin
                        MAX = TALUH;
                    end
                    else begin MAX = R[Ri1]; end
                end
            end //LD_IC, ST_IC
            
            JMP_IC: begin
                

                // MAeff = PC;
                MAB = PM_out; // Load MAB with base address constant value embedded in IW-field; the value 0 emulates the Register Direct AM
                // PC = PC + 1'b1;// Increment the PC to point to the location of the next IW
                // stall_mc0 = 1;
                if (Ri1 == 0) begin
                    MAX = 0; 
                end
                // TODO: double check that this data forward should be here or with the MAX = R[Ri1] at the else at the end
                else if (Ri1 == 1) MAX = PC;
                else if (Ri1 == 2) MAX = SP;
                else begin
                    if ((Ri1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC)) begin
                        MAX = TALUH;
                    end
                    else begin MAX = R[Ri1]; end
                end
                // Branch Prediction stuff for JMP_IC
                for (k = 0; k < 32; k = k + 1) begin branchingRFClone[k] = R[k]; end
                BPAddr = MAB[7:0] + MAX[7:0];
                BPJumpType = IR1[4:0];
                BP_en = 1'b1;
                TPC = PC + 1'b1;

            end //LD_IC, ST_IC, JMP_IC
            CALL_IC: begin
                PC = PC + 1'b1;
                SP = $unsigned(SP - 1'b1);
                if (Ri1 == 0) MAX = 0; 
                else if (Ri1 == 1) MAX = PC;
                else if (Ri1 == 2) MAX = SP;
                else MAX = R[Ri1]; 	//Load MAX
                MAB = PM_out;
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
                case(Rj1)
                    5'd0: begin IPDR = In0; end
                    5'd1: begin IPDR = In1; end
                    5'd2: begin IPDR = In2; end
                    5'd3: begin IPDR = In3; end
                    5'd4: begin IPDR = In4; end 
                    5'd5: begin IPDR = In5; end
                    5'd6: begin IPDR = In6; end
                    5'd7: begin IPDR = In7; end
                    5'd8: begin IPDR = In8; end
                    5'd9: begin IPDR = In9; end
                    5'd10: begin IPDR = In10; end
                    5'd11: begin IPDR = In11; end
                    5'd12: begin IPDR = In12; end
                    5'd13: begin IPDR = In13; end
                    5'd14: begin IPDR = In14; end
                    5'd15: begin IPDR = In15; end
                    default: begin IPDR = IPDR; end
                endcase
            end
            OUT_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 16'hffff)) OPDR = TALUH[15:0];
                else OPDR = R[Ri1];
            end
            CPY_IC: begin
                if ((Rj1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC) && (IR2[15:10] != LD_IC) && (IR2[15:10] != ST_IC) && (IR2[15:10] != JMP_IC)) begin
                    TB = TALUH; // <-- DF-FU = Data Forwarding from the instruction in MC2
                end
                else begin
                    TB = R[Rj1];
                end
            end //CPY_IC
            NOT_IC, SRA_IC, RRC_IC, RRN_IC, RRZ_IC, SHRL_IC, ROTL_IC, RLN_IC, RLZ_IC, ROTR_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC)  && (IR2[15:10] != LD_IC) && (IR2[15:10] != ST_IC) && (IR2[15:10] != JMP_IC)) begin
                    TA = TALUH; // <-- DF-FU = Data Forwarding from the instruction in MC2
                end
                else begin
                    TA = R[Ri1];
                end
                TB = Rj1;
            end // NOT_IC, SRA_IC, RRC_IC
            ADDC_IC, SUBC_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC)  && (IR2[15:10] != LD_IC) && (IR2[15:10] != ST_IC)  && (IR2[15:10] != JMP_IC)) begin
                    TA = TALUH; // <-- DF-FU
                end
                else begin
                    TA = R[Ri1]; 
                end
                TB = {11'b0000000000, IR1[4:0]};
            end // ADDC_IC, SUBC_IC

            VADDC_IC, VSUBC_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC)) begin
                    TA = TALUH; // <-- DF-FU
                end
                else begin
                    TA = R[Ri1]; 
                end
                TB = {11'b0000000000, IR1[4:0]};
            end // ADDC_IC, SUBC_IC

            VMUL_IC, VDIV_IC: begin
                // populate TA and TB with the proper registers
                // Check for data forwarding issues in Ri
                if ((Ri1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC) && (IR2[15:10] != JMP_IC) && (IR2[15:10] != LD_IC) && (IR2[15:10] != ST_IC)) begin
                    TA = TALUH;
                end
                else begin
                    TA = R[Ri1];
                end

                // Check for data forwarding issues in Rj
                if ((Rj1 == Rj2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC) && (IR2[15:10] != LD_IC) && (IR2[15:10] != ST_IC) && (IR2[15:10] != JMP_IC) && (IR2[15:14] != 2'b01)) begin
                    TB = TALUH;
                end
                else begin
                    TB = R[Rj1];
                end
            end    
            
            // TODO: Check to make sure VADD and VSUB should be in here, get a hunch they shouldnt
            ADD_IC, SUB_IC, AND_IC, OR_IC, XOR_IC, VADD_IC, VSUB_IC: begin
                if((IR2[15:10] == MUL_IC) || (IR2[15:10] == DIV_IC) || (IR2[15:10] == SWAP_IC)) begin
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
                    if ((Ri1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC) && (IR2[15:10] != LD_IC) && (IR2[15:10] != ST_IC) && (IR2[15:10] != JMP_IC)) begin TA = TALUH; end
                    else begin TA = R[Ri1]; end
                    
                    if ((Rj1 == Rj2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC) && (IR2[15:14] != 2'b01) && (IR2[15:10] != LD_IC) && (IR2[15:10] != ST_IC)) begin TB = TALUH; end
                    else begin TB = R[Rj1]; end
                end
            end

            CMP_IC: begin
                if ((Ri1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC)) begin TA = TALUH; end
                else begin TA = R[Ri1]; end

                TB = Rj1;    
            end

            SWAP_IC, MUL_IC, DIV_IC: begin
                // DF-FU; Ri2 below is right for every previous instruction that returns a result in Ri2; 
                // need to modify for a previous SWAP if the value is to be Rj2
                if ((Ri1 == Ri2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC) && (IR2[15:10] != LD_IC) && (IR2[15:10] != ST_IC) && (IR2[15:10] != JMP_IC)) begin
                    TA = TALUH; 
                end
                else begin
                    TA = R[Ri1];
                end
                if ((Rj1 == Rj2) && (IR2 != 16'hFFFF) && (IR2[15:10] != NOP_IC) && (IR2[15:14] != 2'b01) && (IR2[15:10] != LD_IC) && (IR2[15:10] != ST_IC) && (IR2[15:10] != JMP_IC)) begin
                    TB = TALUH; 
                end
                else begin
                    TB = R[Rj1]; 
                end
             
            end // SWAP_IC, ADD_IC, SUB_IC, AND_IC, OR_IC, XOR_IC, MUL_IC, DIV_IC,

            NOP_IC: begin
                PC = PC + 1'b0;
            end

            FPADD_IC: begin
                enable_add = 1'b1;
                if ((Ri1 == Ri2)) begin
                    case(IR2[15:10])
                        FPADD_IC: begin FPAdd_a = FPAdd_q; end
                        FPSUB_IC: begin FPAdd_a = FPSub_q; end
                        FPMUL_IC: begin FPAdd_a = FPMul_q; end
                        FPDIV_IC: begin FPAdd_a = FPDiv_q; end
                        default: begin FPAdd_a = FPR[Ri1]; end
                    endcase
                end
                else begin FPAdd_a = FPR[Ri1]; end

                if ((Rj1 == Ri2)) begin
                    case(IR2[15:10])
                        FPADD_IC: begin FPAdd_b = FPAdd_q; end
                        FPSUB_IC: begin FPAdd_b = FPSub_q; end
                        FPMUL_IC: begin FPAdd_b = FPMul_q; end
                        FPDIV_IC: begin FPAdd_b = FPDiv_q; end
                        default: begin FPAdd_b = FPR[Rj1]; end
                    endcase
                end
                else begin FPAdd_b = FPR[Rj1]; end
            end

            FPSUB_IC: begin
                enable_sub = 1'b1;
                if ((Ri1 == Ri2)) begin
                    case(IR2[15:10])
                        FPADD_IC: begin FPSub_a = FPAdd_q; end
                        FPSUB_IC: begin FPSub_a = FPSub_q; end
                        FPMUL_IC: begin FPSub_a = FPMul_q; end
                        FPDIV_IC: begin FPSub_a = FPDiv_q; end
                        default: begin FPSub_a = FPR[Ri1]; end
                    endcase
                end
                else begin FPSub_a = FPR[Ri1]; end

                if ((Rj1 == Ri2)) begin
                    case(IR2[15:10])
                        FPADD_IC: begin FPSub_b = FPAdd_q; end
                        FPSUB_IC: begin FPSub_b = FPSub_q; end
                        FPMUL_IC: begin FPSub_b = FPMul_q; end
                        FPDIV_IC: begin FPSub_b = FPDiv_q; end
                        default: begin FPSub_b = FPR[Rj1]; end
                    endcase
                end
                else begin FPSub_b = FPR[Rj1]; end
            end
            
            FPMUL_IC: begin
                enable_mul = 1'b1;
                if ((Ri1 == Ri2)) begin
                    case(IR2[15:10])
                        FPADD_IC: begin FPMul_a = FPAdd_q; end
                        FPSUB_IC: begin FPMul_a = FPSub_q; end
                        FPMUL_IC: begin FPMul_a = FPMul_q; end
                        FPDIV_IC: begin FPMul_a = FPDiv_q; end
                        default: begin FPMul_a = FPR[Ri1]; end
                    endcase
                end
                else begin FPMul_a = FPR[Ri1]; end

                if ((Rj1 == Ri2)) begin
                    case(IR2[15:10])
                        FPADD_IC: begin FPMul_b = FPAdd_q; end
                        FPSUB_IC: begin FPMul_b = FPSub_q; end
                        FPMUL_IC: begin FPMul_b = FPMul_q; end
                        FPDIV_IC: begin FPMul_b = FPDiv_q; end
                        default: begin FPMul_b = FPR[Rj1]; end
                    endcase
                end
                else begin FPMul_b = FPR[Rj1]; end
            end
            
            FPDIV_IC: begin
                enable_div = 1'b1;
                if ((Ri1 == Ri2)) begin
                    case(IR2[15:10])
                        FPADD_IC: begin FPDiv_a = FPAdd_q; end
                        FPSUB_IC: begin FPDiv_a = FPSub_q; end
                        FPMUL_IC: begin FPDiv_a = FPMul_q; end
                        FPDIV_IC: begin FPDiv_a = FPDiv_q; end
                        default: begin FPDiv_a = FPR[Ri1]; end
                    endcase
                end
                else begin FPDiv_a = FPR[Ri1]; end

                if ((Rj1 == Ri2)) begin
                    case(IR2[15:10])
                        FPADD_IC: begin FPDiv_b = FPAdd_q; end
                        FPSUB_IC: begin FPDiv_b = FPSub_q; end
                        FPMUL_IC: begin FPDiv_b = FPMul_q; end
                        FPDIV_IC: begin FPDiv_b = FPDiv_q; end
                        default: begin FPDiv_b = FPR[Rj1]; end
                    endcase
                end
                else begin FPDiv_b = FPR[Rj1]; end
            end

            default: begin // Default case should not be reached
                `ifdef SIMULATION
                $display("ERROR: Default Case Selection Reached from MC1 , OPCODE: %b @ %t",IR1[15:10], $time());
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


    if (stall_mc3 == 0) begin
        IR4 = IR3;
    end


    if ((stall_mc2 == 0) /*&& 
        (IR3[INSTR_WIDTH-1:10] != JMP_IC)  && 
        (IR3[INSTR_WIDTH-1:10] != LD_IC)    && 
        (IR3[INSTR_WIDTH-1:10] != ST_IC)    && 
        (IR3[INSTR_WIDTH-1:10] != CALL_IC)  && 
        (IR3[INSTR_WIDTH-1:10] != RET_IC)*/) begin 


        // if(IR2[15:10] == JMP_IC && jumpTaken) begin
        //     PC = MAB + MAX;
        // end

        IR3 = IR2;
        Ri3 = Ri2;
        Rj3 = Rj2;
        stall_mc3 = 0;
    end 
    // Instruction in MC2 is stalled and IR3 is loaded with the "don't care IW"    
    else begin 
        stall_mc2 =1; 
        IR3 = 16'hffff; 
    end 
    // Instruction in MC1 can move to MC2; Rj2 may need to be = Ri1 for certain instruction sequences
    if ((stall_mc1 == 0) && 
        /*(IR2[INSTR_WIDTH-1:10] != JMP_IC)   && */
        (IR2[INSTR_WIDTH-1:10] != LD_IC)    && 
        (IR2[INSTR_WIDTH-1:10] != ST_IC)    && 
        (IR2[INSTR_WIDTH-1:10] != CALL_IC)  && 
        (IR2[INSTR_WIDTH-1:10] != RET_IC)) begin 

        

        IR2 = IR1;
        Ri2 = Ri1;
        Rj2 = Rj1;
        stall_mc2 = 0;
    end
    // Instruction in MC1 is stalled and IR2 is loaded with the "don't care IW"    
    else begin
        stall_mc1 = 1;
        IR2 = 16'hffff;
    end 


    // if(~pred_correct && IR4[15:10] == JMP_IC) begin
    // end


    // Instruction in MC0 can move to MC1;     
    if ((stall_mc0 == 0)        && 
        (IR1[INSTR_WIDTH-1:10] != JMP_IC)   &&  
        (IR1[INSTR_WIDTH-1:10] != LD_IC)    && 
        (IR1[INSTR_WIDTH-1:10] != ST_IC)    && 
        (IR1[INSTR_WIDTH-1:10] != CALL_IC)  && 
        (IR1[INSTR_WIDTH-1:10] != RET_IC)) begin
        
        // Below: IW0 is fetched directly into IR1, Ri1, and Rj1
       
        IR1 = PM_out; 
        Ri1 = PM_out[9:5];
        Rj1 = PM_out[4:0]; 
        PC = PC + 1'b1; 
        if(IR1[15:10] == JMP_IC) begin BP_en = 1'b1; end
        // MAeff = PC;
        stall_mc1 = 0; 
    end
    // Instruction in MC0 is stalled and IR1 is loaded with the "don't care IW"    
    else begin 
        stall_mc0 = 1; 
        IR1 = 16'hffff; 
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
    if (/*(IR3 == 14'h3fff) || */
        (IR3[INSTR_WIDTH-1:10] == LD_IC)    || 
        (IR3[INSTR_WIDTH-1:10] == ST_IC)    || 
        (IR3[INSTR_WIDTH-1:10] == JMP_IC)   || 
        (IR4[INSTR_WIDTH-1:10] == CALL_IC)  || 
        (IR4[INSTR_WIDTH-1:10] == RET_IC)) begin
        stall_mc0 = 0; 
        // MAeff = PC;

        // after this also reset the Ri1 Ri2 Ri3 and Rj1 Rj2 Rj3 regs
        // Ri2 = 4'd0;
        // Rj2 = 4'd0;
        // Ri3 = 4'd0;
        // Rj3 = 4'd0;
    end

    if (IR4[15:10] == JMP_IC && ~pred_correct) begin
        PC = TPC;
        BP_en = 1'b0; 
        // stall_mc3 = 1'b1;
        // stall_mc2 = 1'b1;
        // stall_mc1 = 1'b1;
        IR1 = 16'hffff;
        Ri1 = 5'b11111;
        Rj1 = 5'b11111;
        for(k = 0; k < 32; k = k + 1) begin R[k] = branchingRFClone[k]; end

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
		  
        IR1 = MM_out;
        Ri1 = MM_out[9:5];
        Rj1 = MM_out[4:0];
        PC = PC + 1'b1;
        MAeff = PC;
        stall_mc1 = 0;
        stall_mc0 = 1;
        IR2 = 16'hffff;
        IR3 = 16'hffff;
    end
    else if (stall_mc1 == 0) begin
        IR2 = IR1;
        Ri2 = Ri1;
        Rj2 = Rj1;
        stall_mc2 = 0;
        stall_mc1 = 1;
        IR1 = 16'hffff;
        IR3 = 16'hffff;
    end
    else if (stall_mc2 == 0) begin
        IR3 = IR2;
        Ri3 = Ri2;
        Rj3 = Ri3;
        stall_mc3 = 0;
        stall_mc2 = 1;
        IR2 = 16'hffff;
        IR1 = 16'hffff;
    end
    else if (stall_mc3 == 0) begin
        stall_mc0 = 0;
        stall_mc3 = 1;
    end
`endif // ifndef DISABLE_PIPELINE
end // reset
end // my_CPU
endmodule
