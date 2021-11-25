module alu_tb();
    logic[3:0] ALUOperation;
	logic[31:0] b;
	logic[31:0] a;
	logic[31:0] ALU_result;
	logic zero;

    

    alu dut(
        .ALUOperation(ALUOperation), .b(b),
        .a(a),.ALU_result(ALU_result), .zero(zero)
    );

endmodule