module sign_extend (
input logic[15:0] instruction,
ouput logic [31:0] sign_extended,
);
endmodule

always begin
    if (instruction [15] == 1) begin
        assign sign_extended = 32'b11111111111111110000000000000000 + instruction
    end
    else begin
        assign sign_extended = instruction>>16
    end


end