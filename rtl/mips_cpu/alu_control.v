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

	typedef enum logic[5:0]{
		JR: 6'b001000;
		ADDU: 6'b100001;
	}function_type;

	always_comb begin
		case(opcode)
			SPECIAL: case(func_code)
					JR: aluctl = 4'b0010;
					ADDU: aluctl = 4'b0010;
					AND: 6'b100100;
					OR: 6'b100101;
					XOR: 6'b100110;
			ADDIU: aluctl = 4'b0010;
			LW: aluctl = 4'b0010;
			SW: aluctl = 4'b0010;
	end

endmodule : alu_control