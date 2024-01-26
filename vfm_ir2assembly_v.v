module vfm_ir2assembly_v (
input      [15:0] IR         ,
input             Resetn_pin ,
output reg [111:0] ICis
);

// This module is converting the IW information into a string of ASCII characters. 
// This is ONLY needed for debugging purposes. 
// It should be eliminated when compiling/ synthesizing for FPGA implementation. 
// It is described behaviorally. 
// In the ModelSim wavform, select the display radix for this output signal to be ASCII.

// Internal wire declarations
reg [15:0] IR7to4  ;
reg [15:0] IR3to0   ;
reg [7:0] sbit     ;
reg [7:0] sbit_val ;


always @ (*) begin
    // Converting register numbers to ASCII digit character numbers
	case(IR[9:5]) 
		5'd0: IR7to4 = "0";
		5'd1: IR7to4 = "1";
		5'd2: IR7to4 = "2";
		5'd3: IR7to4 = "3";
		5'd4: IR7to4 = "4";
		5'd5: IR7to4 = "5";
		5'd6: IR7to4 = "6";
		5'd7: IR7to4 = "7";
		5'd8: IR7to4 = "8";
		5'd9: IR7to4 = "9";
		5'd10: IR7to4 = "10";
		5'd11: IR7to4 = "11";
		5'd12: IR7to4 = "12";
		5'd13: IR7to4 = "13";
		5'd14: IR7to4 = "14";
		5'd15: IR7to4 = "15";
		5'd16: IR7to4 = "16";
		5'd17: IR7to4 = "17";
		5'd18: IR7to4 = "18";
		5'd19: IR7to4 = "19";
		5'd20: IR7to4 = "20";
		5'd21: IR7to4 = "21";
		5'd22: IR7to4 = "22";
		5'd23: IR7to4 = "23";
		5'd24: IR7to4 = "24";
		5'd25: IR7to4 = "25";
		5'd26: IR7to4 = "26";
		5'd27: IR7to4 = "27";
		5'd28: IR7to4 = "28";
		5'd29: IR7to4 = "29";
		5'd30: IR7to4 = "30";
		5'd31: IR7to4 = "31";
		

	endcase

	case(IR[4:0]) 
		5'd0: IR3to0 = "0";
		5'd1: IR3to0 = "1";
		5'd2: IR3to0 = "2";
		5'd3: IR3to0 = "3";
		5'd4: IR3to0 = "4";
		5'd5: IR3to0 = "5";
		5'd6: IR3to0 = "6";
		5'd7: IR3to0 = "7";
		5'd8: IR3to0 = "8";
		5'd9: IR3to0 = "9";
		5'd10: IR3to0 = "10";
		5'd11: IR3to0 = "11";
		5'd12: IR3to0 = "12";
		5'd13: IR3to0 = "13";
		5'd14: IR3to0 = "14";
		5'd15: IR3to0 = "15";
		5'd16: IR3to0 = "16";
		5'd17: IR3to0 = "17";
		5'd18: IR3to0 = "18";
		5'd19: IR3to0 = "19";
		5'd20: IR3to0 = "20";
		5'd21: IR3to0 = "21";
		5'd22: IR3to0 = "22";
		5'd23: IR3to0 = "23";
		5'd24: IR3to0 = "24";
		5'd25: IR3to0 = "25";
		5'd26: IR3to0 = "26";
		5'd27: IR3to0 = "27";
		5'd28: IR3to0 = "28";
		5'd29: IR3to0 = "29";
		5'd30: IR3to0 = "30";
		5'd31: IR3to0 = "31";
		

	endcase

    // Similarly for the status bit and status bit value used in the (conditional) JUMP
    if          (IR[4:0] == 5'b00000) begin sbit = 8'h55; sbit_val = 8'h20; end
    else if     (IR[4:0] == 5'b10000) begin sbit = 8'h43; sbit_val = 8'h31; end
    else if     (IR[4:0] == 5'b01000) begin sbit = 8'h4E; sbit_val = 8'h31; end
    else if     (IR[4:0] == 5'b00100) begin sbit = 8'h56; sbit_val = 8'h31; end
    else if     (IR[4:0] == 5'b00010) begin sbit = 8'h5A; sbit_val = 8'h31; end
    else if     (IR[4:0] == 5'b01110) begin sbit = 8'h43; sbit_val = 8'h30; end
    else if     (IR[4:0] == 5'b10110) begin sbit = 8'h4E; sbit_val = 8'h30; end
    else if     (IR[4:0] == 5'b11010) begin sbit = 8'h56; sbit_val = 8'h30; end
    else if     (IR[4:0] == 5'b11100) begin sbit = 8'h5A; sbit_val = 8'h30; end
    else begin sbit = 8'h3f; sbit_val = 8'h3f; end

    // After the IR (IW) is passed on to the CU in MC1, the current IC/IW can be 
    // idenitified and the corresponding assembly instruction displayed.

    if (Resetn_pin == 1'b0)
        ICis = {"RESET"}; //RST;
    else if (IR == 16'hffff)
        ICis = {"STALL"}; //STALL
    else case (IR[15:10])
			6'b000000 : ICis = {"LD R", 	IR3to0, ", R", IR7to4, ":"}; //LD
			6'b000001 : ICis = {"ST R", 	IR3to0, ", R", IR7to4, ":"}; //ST
			6'b000010 : ICis = {"CPY R", 	IR7to4, ", R", IR3to0, ":"}; //CPY
			6'b000011 : ICis = {"SWP R", 	IR7to4, ", R", IR3to0, ":"}; //SWAP
			6'b000100 : ICis = {"JMP ", sbit,  8'h3D, sbit_val,  8'h3B}; //JUMP
			6'b000101 : ICis = {"ADD R",	IR7to4, ", R", IR3to0, ":"}; //ADD
			6'b000110 : ICis = {"SUB R", 	IR7to4, ", R", IR3to0, ":"}; //SUB
			6'b000111 : ICis = {"ADDC R", 	IR7to4, ", #", IR3to0, ":"}; //ADDC
			6'b001000 : ICis = {"SUBC R",	IR7to4, ", #", IR3to0, ":"}; //SUBC
			6'b001001 : ICis = {"NOT R", 	IR7to4, ":"}; //NOT
			6'b001010 : ICis = {"ANDd R", 	IR7to4, ", R", IR3to0, ":"}; //AND
			6'b001011 : ICis = {"OR R", 	IR7to4, ", R", IR3to0, ":"}; //OR
			6'b001100 : ICis = {"SRA R", 	IR7to4, ", #", IR3to0, ":"}; //SRA
			6'b001101 : ICis = {"RRC R", 	IR7to4, ", #", IR3to0, ":"}; //RRC
			6'b001110 : ICis = {"VADD R", 	IR7to4, ", R", IR3to0, ":"}; //VADD
			6'b001111 : ICis = {"VSUB R", 	IR7to4, ", R", IR3to0, ":"}; //VSUB
			6'b010000 : ICis = {"MUL R", 	IR7to4, ", R", IR3to0, ":"}; //  MUL
			6'b010001 : ICis = {"DIV R", 	IR7to4, ", R", IR3to0, ":"}; // DIV
			6'b010010 : ICis = {"XOR R", 	IR7to4, ", R", IR3to0, ":"}; // XOR
			6'b010011 : ICis = {"SHRL R", 	IR7to4, ", #", IR3to0, ":"}; // SHRL
			6'b010100 : ICis = {"SHRA R", 	IR7to4, ", #", IR3to0, ":"}; // SHRA
			6'b010101 : ICis = {"ROTL R", 	IR7to4, ", #", IR3to0, ":"}; // ROTL
			6'b010110 : ICis = {"ROTR R", 	IR7to4, ", #", IR3to0, ":"}; // ROTR
			6'b010111 : ICis = {"RLN R", 	IR7to4, ", #", IR3to0, ":"}; // RLN
			6'b011000 : ICis = {"RLZ R", 	IR7to4, ", #", IR3to0, ":"}; // RLZ
			6'b011001 : ICis = {"RRN R", 	IR7to4, ", #", IR3to0, ":"}; // RRN
			6'b011010 : ICis = {"RRZ R", 	IR7to4, ", #", IR3to0, ":"}; // RRZ
			6'b011011 : ICis = {"CALL R", 	IR7to4, " ", 8'h20,  ":"}; //CALL
			6'b011100 : ICis = {"RET",  ":"}; // RET
			6'b011101 : ICis = {"IN R", 	IR7to4, ", R", 8'h20,  ":"}; //IN
			6'b011110 : ICis = {"OUT R", 	IR7to4, ", R", IR3to0,  ":"}; // OUT
			6'b100000 : ICis = {"VADDC R", 	IR7to4, " #", IR3to0, " "};
			6'b100001 : ICis = {"VSUBC R", 	IR7to4, " #", IR3to0, " "};
			6'b110000 : ICis = {"CMP R", 	IR7to4, " #", IR3to0, " "};
			6'b111000 : ICis = {"NOP R", 	IR7to4, " R", IR3to0, " "};

	default : ICis = {"NDEF"}; //NDEF
   endcase
end
endmodule
