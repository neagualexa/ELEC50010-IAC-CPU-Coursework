module alu_tb();
    logic[3:0] ALUOperation;
	logic[31:0] b;
	logic[31:0] a;
	logic[31:0] ALU_result;
	logic zero;

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

    initial begin
        #10
        a = 32'd10;
        b = 32'd2;
        ALUOperation = ADD;
        #10
        assert(ALU_result == 12) $display("Successful - ADD") else $display("Error - ADD");
        ALUOperation = SUBTRACT;
        #10
        assert(ALU_result == 8) $display("Successful - SUBTRACT") else $display("Error - SUBTRACT");

        #10
        a = 32'h00FF;
        b = 32'h10F0;
        ALUOperation = AND;
        #10
        assert(ALU_result == 32'h00F0) $display("Successful - AND") else $display("Error - AND");
        ALUOperation = OR;
        #10
        assert(ALU_result == 32'h10FF) $display("Successful - OR") else $display("Error - OR");
        ALUOperation = XOR;
        #10
        assert(ALU_result == 32'h100F) $display("Successful - XOR") else $display("Error - XOR");

        #10
        a = 32'd10;
        b = 32'd2;
        ALUOperation = MULTIPLY;
        #10
        assert(ALU_result == 20) $display("Successful - MULTIPLY") else $display("Error - MULTIPLY");
        ALUOperation = DIVIDE;
        #10
        assert(ALU_result == 5) $display("Successful - DIVIDE") else $display("Error - DIVIDE");
        ALUOperation = BIGGER;
        #10
        assert(ALU_result == 1) $display("Successful - BIGGER") else $display("Error - BIGGER");
        ALUOperation = SMALLER;
        #10
        assert(ALU_result == 0) $display("Successful - SMALLER") else $display("Error - SMALLER");
        ALUOperation = BIGGER_OR_EQUAL;
        #10
        assert(ALU_result == 1) $display("Successful - BIGGER_OR_EQUAL") else $display("Error - BIGGER_OR_EQUAL");
        ALUOperation = SMALLER_OR_EQUAL;
        #10
        assert(ALU_result == 0) $display("Successful - SMALLER_OR_EQUAL") else $display("Error - SMALLER_OR_EQUAL");

        #10
        a = 32'h8040;
        b = 32'd2;
        ALUOperation = SHIFT_LEFT;
        #10
        assert(ALU_result == 32'h2010) $display("Successful - SHIFT_LEFT") else $display("Error - SHIFT_LEFT");
        ALUOperation = SHIFT_RIGHT;
        #10
        assert(ALU_result == 32'h0100) $display("Successful - SHIFT_RIGHT") else $display("Error - SHIFT_RIGHT");
        ALUOperation = SHIFT_ARITHMETIC;
        #10
        assert(ALU_result == 32'hE010) $display("Successful - SHIFT_ARITHMETIC") else $display("Error - SHIFT_ARITHMETIC");
    end

    alu dut(
        .ALUOperation(ALUOperation), .b(b),
        .a(a),.ALU_result(ALU_result), .zero(zero)
    );

endmodule