module vfm_ir2assembly_v (
input      [13:0] IR         ,
input             Resetn_pin ,
output reg [95:0] ICis
);

// This module is converting the IW information into a string of ASCII characters. 
// This is ONLY needed for debugging purposes. 
// It should be eliminated when compiling/ synthesizing for FPGA implementation. 
// It is described behaviorally. 
// In the ModelSim wavform, select the display radix for this output signal to be ASCII.

// Internal wire declarations
reg [7:0] IR7to4  ;
reg [7:0] IR3to0   ;
reg [7:0] sbit     ;
reg [7:0] sbit_val ;


always @ (*) begin
    // Converting register numbers to ASCII digit character numbers
    IR7to4 = 8'h30 + {2'b00, IR[7:4]};
    IR3to0 = 8'h30 + {2'b00, IR[3:0]};

    // Similarly for the status bit and status bit value used in the (conditional) JUMP
    if          (IR[3:0] == 4'b0000) begin sbit = 8'h55; sbit_val = 8'h20; end
    else if     (IR[3:0] == 4'b1000) begin sbit = 8'h43; sbit_val = 8'h31; end
    else if     (IR[3:0] == 4'b0100) begin sbit = 8'h4E; sbit_val = 8'h31; end
    else if     (IR[3:0] == 4'b0010) begin sbit = 8'h56; sbit_val = 8'h31; end
    else if     (IR[3:0] == 4'b0001) begin sbit = 8'h5A; sbit_val = 8'h31; end
    else if     (IR[3:0] == 4'b0111) begin sbit = 8'h43; sbit_val = 8'h30; end
    else if     (IR[3:0] == 4'b1011) begin sbit = 8'h4E; sbit_val = 8'h30; end
    else if     (IR[3:0] == 4'b1101) begin sbit = 8'h56; sbit_val = 8'h30; end
    else if     (IR[3:0] == 4'b1110) begin sbit = 8'h5A; sbit_val = 8'h30; end
    else begin sbit = 8'h3f; sbit_val = 8'h3f; end

    // After the IR (IW) is passed on to the CU in MC1, the current IC/IW can be 
    // idenitified and the corresponding assembly instruction displayed.

    if (Resetn_pin == 1'b0)
        ICis = {8'h52, 8'h53, 8'h54, 8'h20}; //RST;
    else if (IR == 14'h3fff)
        ICis = {8'h53, 8'h54, 8'h41, 8'h4C, 8'h4C, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20}; //STALL
    else case (IR[13:8])
			6'b000000 : ICis = {8'h4C, 8'h44, 8'h20, 8'h52, IR3to0, 8'h2c, 8'h20, 8'h4D, 8'h41,  8'h72, IR7to4, 8'h3B}; //LD
			6'b000001 : ICis = {8'h53, 8'h54, 8'h20, 8'h52, IR3to0, 8'h2c, 8'h20, 8'h4D, 8'h41,  8'h72, IR7to4, 8'h3B}; //ST
			6'b000010 : ICis = {8'h43, 8'h50, 8'h59, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; //CPY
			6'b000011 : ICis = {8'h53, 8'h57, 8'h41, 8'h50, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; //SWAP
			6'b000100 : ICis = {8'h4A, 8'h55, 8'h4D, 8'h50, 8'h20, 8'h69, 8'h66, 	8'h20, sbit,  8'h3D, sbit_val,  8'h3B}; //JUMP
			6'b000101 : ICis = {8'h41, 8'h44, 8'h44, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; //ADD
			6'b000110 : ICis = {8'h53, 8'h55, 8'h42, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; //SUB
			6'b000111 : ICis = {8'h41, 8'h44, 8'h44, 8'h43, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; //ADDC
			6'b001000 : ICis = {8'h53, 8'h55, 8'h42, 8'h43, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; //SUBC
			6'b001001 : ICis = {8'h4E, 8'h4F, 8'h54, 8'h20, 8'h20, 8'h52, IR7to4, 8'h20, 8'h20, 8'h20, 8'h20,  8'h3B}; //NOT
			6'b001010 : ICis = {8'h41, 8'h4E, 8'h44, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; //AND
			6'b001011 : ICis = {8'h4F, 8'h52, 8'h20, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; //OR
			6'b001100 : ICis = {8'h53, 8'h52, 8'h41, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; //SRA
			6'b001101 : ICis = {8'h52, 8'h52, 8'h43, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; //RRC
			6'b001110 : ICis = {8'h56, 8'h41, 8'h44, 8'h44, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; //VADD
			6'b001111 : ICis = {8'h56, 8'h53, 8'h55, 8'h42, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; //VSUB
			6'b010000 : ICis = {8'h4D, 8'h55, 8'h4C, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; //  MUL
			6'b010001 : ICis = {8'h44, 8'h49, 8'h56, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; // DIV
			6'b010010 : ICis = {8'h58, 8'h4F, 8'h52, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h52, IR3to0, 8'h3B}; // XOR
			6'b010011 : ICis = {8'h53, 8'h52, 8'h4C, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; // SHRL
			6'b010100 : ICis = {8'h53, 8'h52, 8'h41, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; // SHRA
			6'b010101 : ICis = {8'h52, 8'h4F, 8'h54, 8'h4C, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; // ROTL
			6'b010110 : ICis = {8'h52, 8'h4F, 8'h54, 8'h52, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; // ROTR
			6'b010111 : ICis = {8'h52, 8'h4C, 8'h4E, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; // RLN
			6'b011000 : ICis = {8'h52, 8'h4C, 8'h5A, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; // RLZ
			6'b011001 : ICis = {8'h52, 8'h52, 8'h4E, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; // RRN
			6'b011010 : ICis = {8'h52, 8'h52, 8'h5A, 8'h20, 8'h20, 8'h52, IR7to4, 8'h2c, 8'h20, 8'h23, IR3to0, 8'h3B}; // RRZ
			6'b011011 : ICis = {8'h43, 8'h41, 8'h4C, 8'h4C, 8'h20, 8'h52, IR7to4, 8'h20, 8'h20, 8'h20, 8'h20,  8'h3B}; //CALL
			6'b011100 : ICis = {8'h52, 8'h45, 8'h54, 8'h20, 8'h20, 8'h20, 8'h20,  8'h20, 8'h20, 8'h20, 8'h20,  8'h20}; // RET
			6'b011101 : ICis = {8'h49, 8'h4E, 8'h20, 8'h20, 8'h20, 8'h52, IR7to4, 8'h20, 8'h20, 8'h20, 8'h20,  8'h20}; //IN
			6'b011110 : ICis = {8'h4F, 8'h55, 8'h54, 8'h20, 8'h20, 8'h52, IR7to4, 8'h20, 8'h20, 8'h20, IR3to0,  8'h20}; // OUT
			6'b100000 : ICis = {"VADDC ", IR7to4, " ", IR3to0, " "};
			6'b100001 : ICis = {"VSUBC ", IR7to4, " ", IR3to0, " "};
			6'b110000 : ICis = {"CMP ", IR7to4, " ", IR3to0, " "};

	default : ICis = {8'h4E, 8'h44, 8'h45, 8'h46}; //NDEF
   endcase
end
endmodule
