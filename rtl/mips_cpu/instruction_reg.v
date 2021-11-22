module instruction_reg(
    input clk,
    input IRWrite,
    input logic[31:0] memdata,
    output logic[5:0] instr31_26,
    output logic[5:0] instr25_21,
    output logic[4:0] instr20_16,
    output logic[14:0] instr15_0
);

    always_ff(@posedge clk) begin
        if(IRWrite) begin
            instr31_26 <= memdata[31:26];
            instr25_21 <= memdata[25:21];
            instr20_16 <= memdata[20:16];
            instr15_0 <= memdata[15:0];
        end
    end
  
endmodules