module registers(
    input clk,
    input RegWrite,
    input logic[4:0] readR1,
    input logic[4:0] readR2,
    input logic[4:0] writeR,
    input logic[4:0] writedata,
    output logic[31:0] readdata1,
    output logic[31:0] readdata2
);
    reg[31:0] register[31:0];
    assign readdata1 = register[readR1];
    assign readdata2 = register[readR2];

    always_ff(@posedge clk) begin
        if(RegWrite) begin
            register[writeR] <= writedata;
        end
    end

endmodule