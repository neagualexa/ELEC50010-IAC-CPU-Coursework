module PCmux3to1 (
    input logic[31:0] ALU_result,
    input logic[31:0] Jump_address,
    input logic[31:0] ALUOut,
    input logic[1:0] PCSource,
    output logic[31:0] PC,
);

    always @(*) begin
        case(PCSource):
            0: PC = ALU_result;
            1: PC = ALUOut;
            2: PC = Jump_address;
        endcase
    end
    
endmodule