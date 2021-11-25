module registers(
    input logic clk,
    input logic reset,
    input logic RegWrite,
    input logic[4:0] readR1,
    input logic[4:0] readR2,
    input logic[4:0] writeR,
    input logic[31:0] writedata,
    output logic[31:0] readdata1,
    output logic[31:0] readdata2
);

    reg[31:0] register[31:0];
    assign readdata1 = register[readR1];
    assign readdata2 = register[readR2];

    always_ff @(posedge clk) begin
        integer i;

        if(reset) begin
            for(i=0; i<32; i=i+1) begin
                register[i] <= 0;
            end
        end

        else if(RegWrite) begin
            register[writeR] <= writedata;
        end
    end

endmodule