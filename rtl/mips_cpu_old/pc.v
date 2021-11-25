module pc(
    input clk,
    input pcctl,
    input pc_prev,
    output pc_new
);
    always_ff(@posedge clk) begin
        if(pcctl) begin
            pc_new <= pc_prev; 
        end
    end

endmodule