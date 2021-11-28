module HI_LO_Control( // added states & reset
    input logic opcode,
    input logic[2:0] state,
    input logic func_code,
    input logic clk,
    input logic regA,
    input logic reset,
    input logic ALU_MULTorDIV_result,
    output logic HI,
    output logic LO,

);
    // no need for those as we do the assignments in always_ff
    logic[31:0] HI, LO,
    logic[5:0] final_code;
    assign final_code = (opcode==0) ? func_code : opcode;

    typedef enum logic[2:0] {
        FETCH_INSTR 			= 3'b000,
        DECODE 					= 3'b001,
        EXECUTE 				= 3'b010,
        MEMORY_ACCESS 			= 3'b011,
        WRITE_BACK 				= 3'b100,
    } state_t;

    typedef enum logic[5:0]{
        MTHI	= 6'b010001;
	    MTLO	= 6'b010011;
        MULT	= 6'b011000;
		MULTU	= 6'b011001;
        DIV     = 6'b011010;
        DIVU    = 6'b011011;
    }final_code_list;
    

    always_ff @(posedge clk) begin
        if(reset) begin
            LO <= 0;
            HI <= 0;
        end
        if (final_code != 0 && state == EXECUTE) begin
            case(final_code):
                MTHI: begin
                    HI <= regA;
                end
                MTLO: begin
                    LO <= regA;
                end
                MULT: begin
                    HI <= ALU_MULTorDIV_result[63:32];
                    LO <= ALU_MULTorDIV_result[31:0];
                end
                MULTU: begin
                    HI <= ALU_MULTorDIV_result[63:32];
                    LO <= ALU_MULTorDIV_result[31:0];
                end
                DIV: begin
                    HI <= ALU_MULTorDIV_result[63:32];
                    LO <= ALU_MULTorDIV_result[31:0];
                end
                DIVU: begin
                    HI <= ALU_MULTorDIV_result[63:32];
                    LO <= ALU_MULTorDIV_result[31:0];
                end
            endcase
        end
    end

endmodule