module alu(
	input logic[3:0] ALUOperation,
	input logic[31:0] b,
	input logic[31:0] a,
	output logic[31:0] ALU_result,
	output logic zero
);
	typedef enum logic[3:0] {
        ADD					= 4'b0000,
		AND 				= 4'b0001,
		SUBTRACT			= 4'b0010,
        BIGGER_OR_EQUAL 	= 4'b0011,
		BIGGER 				= 4'b0100,
		SMALLER_OR_EQUAL 	= 4'b0101,
		SMALLER 			= 4'b0110,
		MULTIPLY			= 4'b0111,
		DIVIDE 				= 4'b1000,
		OR 					= 4'b1001,
		XOR 				= 4'b1010,
		SHIFT_LEFT 			= 4'b1011,
		SHIFT_RIGHT 		= 4'b1100,
		SHIFT_ARITHMETIC 	= 4'b1101
	} ALUOperation_t;

    assign zero = (ALU_result==0) ? 1 : 0;

//have to add all the basic alu instructions which are 15 in total 
	always_comb begin
		case(ALUOperation)
	        AND: 				ALU_result = a & b;
	        OR: 				ALU_result = a | b;
			XOR: 				ALU_result = a ^ b;
	        ADD: 				ALU_result = a + b;
	        SUBTRACT: 			ALU_result = a - b;
			MULTIPLY:			ALU_result = a * b;
			DIVIDE:				ALU_result = a / b;
			BIGGER_OR_EQUAL:	ALU_result = (a >= b) ? 1 : 0;
			BIGGER:				ALU_result = (a > b) ? 1 : 0;
			SMALLER_OR_EQUAL:	ALU_result = (a <= b) ? 1 : 0;
			SMALLER:			ALU_result = (a < b) ? 1 : 0;
			SHIFT_LEFT:			ALU_result = a << b;
			SHIFT_RIGHT:		ALU_result = a >> b;
			SHIFT_ARITHMETIC:	ALU_result = a >>> b;
	        //SET_ON_LESS_THAN: ALU_result = (a < b) ? 1 : 0;
	        //NOR: ALU_result = ~ (a | b); 
	        default: ALU_result = 0;
	    endcase
	end

endmodule : alu