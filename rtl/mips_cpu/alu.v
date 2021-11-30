module alu(
	input logic[3:0] ALUOperation,
	input logic[31:0] a,
	input logic[31:0] b,
	input logic unsign,
	input logic fixed_shift,
	input logic[4:0] instr10_6,
	output logic[31:0] ALU_result,
	output logic[63:0] ALU_MULTorDIV_result,
	output logic zero
);

/*
	ALU_MULTorDIV_result {} {}
	DIV / => top {} & ALU_result
	DIV % => bottom {}
*/

	logic[32:0] ALU_temp_result, B_unsign, A_unsign, quotient_unsign, remainder_unsign;
	logic[65:0] ALU_temp_MULTorDIV_result;
	logic[31:0] remainder, quotient;
	logic [63:0] A_extend, B_extend;

	
	typedef enum logic[3:0] {
        ADD 					= 4'b0000,
        LOGICAL_AND 			= 4'b0001,
        SUBTRACT 				= 4'b0010,
        SET_GREATER_OR_EQUAL	= 4'b0011,
		SET_ON_GREATER_THAN 	= 4'b0100,
		SET_LESS_OR_EQUAL 		= 4'b0101,
        SET_ON_LESS_THAN 		= 4'b0110,
		MULTIPLY 				= 4'b0111,
		DIVIDE 					= 4'b1000,
        LOGICAL_OR 				= 4'b1001,
		LOGICAL_XOR 			= 4'b1010,
		SHIFT_LEFT 				= 4'b1011,
		SHIFT_RIGHT 			= 4'b1100,
		SHIFT_RIGHT_SIGNED 		= 4'b1101
	} ALUOperation_t;

	assign A_unsign = {1'b0 + a};
	assign B_unsign = {1'b0 + b};
    assign zero = (ALU_temp_result==0) ? 1 : 0;
	
//have to add all the basic alu instructions which are 15 in total 
	always @(*) begin
		if(unsign) begin 
			case(ALUOperation)
				// LOGICAL_AND: 			ALU_temp_result = A_unsign & B_unsign;  //bitwise 
				// LOGICAL_OR: 			ALU_temp_result = A_unsign | B_unsign;
				// LOGICAL_XOR: 			ALU_temp_result = A_unsign ^ B_unsign;
				// ADD: 					ALU_temp_result = A_unsign + B_unsign;  //we might not need this
				SUBTRACT: 				ALU_temp_result = A_unsign - B_unsign;
				MULTIPLY:				begin 									//mandatory
											ALU_temp_MULTorDIV_result = A_unsign * B_unsign; // create[63:0] variable = A * B then divide variable to HI and LO regs
											ALU_MULTorDIV_result = ALU_temp_MULTorDIV_result[63:0];
										end
				DIVIDE:					begin									//mandatory
											quotient_unsign = A_unsign / B_unsign; 
											remainder_unsign = A_unsign % B_unsign;
											ALU_MULTorDIV_result = {quotient_unsign[31:0], remainder_unsign[31:0]};
										end
				//SET_GREATER_OR_EQUAL:	ALU_temp_result = (A_unsign >= B_unsign) ? 0 : 1;
				//SET_ON_GREATER_THAN:	ALU_temp_result = (A_unsign > B_unsign) ? 0 : 1;
				//SET_LESS_OR_EQUAL:		ALU_temp_result = (A_unsign <= B_unsign) ? 0 : 1;
				SET_ON_LESS_THAN:		ALU_temp_result = (A_unsign < B_unsign) ? 1 : 0; // For less then IF a < b result need to be 1 unfortunaly
				// SHIFT_RIGHT:			ALU_temp_result = A_unsign >> B_unsign; 
				// SHIFT_LEFT:				ALU_temp_result = A_unsign << B_unsign;
				// SHIFT_RIGHT_SIGNED:		ALU_temp_result = A_unsign >>> B_unsign;
				//NOR: ALU_temp_result = ~ (a | b); 
				default: ALU_temp_result = 0;
			endcase
			ALU_result = ALU_temp_result[31:0];
		end 
		else begin
			case(ALUOperation)
				LOGICAL_AND: 			ALU_result = a & b;
				LOGICAL_OR: 			ALU_result = a | b;
				LOGICAL_XOR: 			ALU_result = a ^ b;
				ADD: 					ALU_result = a + b;
				SUBTRACT: 				ALU_result = a - b;
				MULTIPLY:				begin
											A_extend = (a[31] == 1) ? {32'hFFFFFFFF, a} : {32'h0, a};
											B_extend = (b[31] == 1) ? {32'hFFFFFFFF, b} : {32'h0, b};
											ALU_MULTorDIV_result = A_extend * B_extend;
										end
				DIVIDE:					begin 										
											remainder = a % b;
											quotient = a / b;
											ALU_MULTorDIV_result = {quotient, remainder};
										end				
				SET_GREATER_OR_EQUAL:	ALU_result = (a >= b) ? 0 : 1;
				SET_ON_GREATER_THAN:	ALU_result = (a > b) ? 0 : 1;
				SET_LESS_OR_EQUAL:		ALU_result = (a <= b) ? 0 : 1;
				SET_ON_LESS_THAN:		ALU_result = (a < b) ? 1 : 0; // For less then IF a < b result need to be 1 unfortunaly
				// SHIFTS can be done by a fixed immediate or by a value of a register
				SHIFT_RIGHT:			ALU_result = (fixed_shift == 1) ? b >> instr10_6 : b >> a;
				SHIFT_LEFT:				ALU_result = (fixed_shift == 1) ? b << instr10_6 : b << a;
				SHIFT_RIGHT_SIGNED:		ALU_result = (fixed_shift == 1) ? b >>> instr10_6 : b >>> a;
				//NOR: ALU_temp_result = ~ (a | b); 
				default: ALU_result = 0;
			endcase
		end
		//$display("a = %b", a);
		//$display("b = %b", b);
	end

endmodule : alu