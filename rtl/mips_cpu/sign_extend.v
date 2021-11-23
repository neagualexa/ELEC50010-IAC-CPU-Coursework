module sign_extend (
input logic[15:0] instruction,
ouput logic [31:0] sign_extended,
);
endmodule

always begin
    if (instruction [15] == 1) begin
        assign sign_extended = 32'hFF00 + instruction;
    end
    else begin
        assign sign_extended = 32'h0000 + instruction;
    end
end