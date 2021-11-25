//jr addu addiu lw sw
module alu_control (
	input logic[5:0] func_code,
	input logic[5:0] opcode,
	output logic[3:0] aluctl
);

	typedef enum logic[5:0]{
		SPECIAL: 6'b000000;
		REGIMM: 6'b000001;
		ADDIU: 6'b001001;
		LW: 6'b100011;
		SW: 6'b101011;

		J: 6'b000010;
		JAL: 6'b000011;
		BEQ: 6'b000100;
		BNE: 6'b000101;

		ANDI: 6'b001100;
		ORI: 6'b001101;	
		XORI: 6'b001110;
		LUI: 6'b001111;	
	}opcode_type;

	// for R types => function code
	typedef enum logic[5:0]{
		JR: 6'b001000;
		ADDU: 6'b100001;
	}function_type;

	// for REGIMM types => rt code
	
	always_comb begin
		//we should always add default cases!!!!!!!!!
		case(opcode)
			SPECIAL: case(func_code)
					JR: aluctl = 4'b0010; //ADD
					ADDU: aluctl = 4'b0010; //ADD
			//shouldn't these be here?
			/*
			AND: 4'b0000;
			OR: 4'b0001;
			XOR: 4'b; //we need an xor ALUOperation and not just 'nor', 'and' and 'or' for (A+B)(notA+notB)
			*/
					AND: 6'b100100;
					OR: 6'b100101;
					XOR: 6'b100110;
					//default: 6'bXXXXXX;
			ADDIU: aluctl = 4'b0010; //ADD
			LW: aluctl = 4'b0010; //ADD
			SW: aluctl = 4'b0010; //ADD
			//default: aluctl = 4'bXXXX;
	end

endmodule : alu_control