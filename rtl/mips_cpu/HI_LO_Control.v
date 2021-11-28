module HI_LO_Control(
    input opcode,
    input func_code,
    input clk,
    input regA,
    input reset,
    input ALU_MULT_result,
    output HI,
    output LO,

);
    logic HI_Write,LO_Write; // no need for those as we do the assignments in always_ff
    logic[31:0] HI, LO,
    logic[5:0] final_code;
    assign final_code = (opcode==0) ? func_code : opcode;

    typedef enum logic[5:0]{
        MTHI	= 6'b010001;
	    MTLO	= 6'b010011;
        MULT	= 6'b011000;
		MULTU	= 6'b011001;
    }final_code_list;
    

    always_ff @(posedge clk) begin
        if (final_code != 0) begin
            case(final_code):
                MTHI: begin
                    HI <= regA;
                end

                MTLO: begin
                    LO <= regA;
                end

                MULT: begin
                    HI <= ALU_MULT_result[63:32];
                    LO <= ALU_MULT_result[31:0];
                end

                MULTU: begin
                    HI <= ALU_MULT_result[63:32];
                    LO <= ALU_MULT_result[31:0];
                end
        end
    end

endmodule