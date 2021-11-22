module alu(
	input logic[3:0] ALUOperation,
	input logic[31:0] b,
	input logic[31:0] a,
	output logic[31:0] ALU_result,
	output zero
);
	typedef enum logic[3:0] {
        AND = 4'b0000,
        OR = 4'b0001,
        ADD = 4'b0010,
        SUBTRACT = 4'b0110,
        SET_ON_LESS_THAN = 4'b0111,
        NOR = 4'b1100 
	} ALUOperation_t;

    assign zero = (ALU_result==0)? 1:0;

	always_comb begin
		case(ALUOperation)
	        AND: ALU_result = a & b;
	        OR: ALU_result = a | b;
	        ADD: ALU_result = a + b;
	        SUBTRACT: ALU_result = a - b;
	        SET_ON_LESS_THAN: ALU_result = (A<B)? 1:0;
	        NOR: ALU_result = ~(a | b); 
	        default: ALU_result = 0;
	    endcase
	end

endmodule : alu