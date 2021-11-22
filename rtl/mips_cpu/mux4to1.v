module mux4to1 (
    input logic[31:0] register_b,
    input logic[31:0] sign_extend,
    input logic[31:0] shift_2,
    input logic[1:0] ALUSrcB,
    output ALUB,
 );

    always @(*) begin
        case(ALUSrcB)
            0: ALUB = register_b;
            1: ALUB = 32'b100;
            2: ALUB = sign_extend;
            default: ALUB = shift_2; 
        endcase   
    end
endmodule