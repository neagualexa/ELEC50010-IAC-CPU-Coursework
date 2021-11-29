module pc(
    input logic clk,
    input logic reset,
    input logic pcctl,
    input logic[31:0] pc_prev,
    output logic[31:0] pc_new

);
    always_ff @(posedge clk) begin
        if(reset) begin
            pc_new <= 32'h00000000; //change this to reset value
        end
        else if(pcctl) begin
            pc_new <= pc_prev; 
        end
    end

endmodule