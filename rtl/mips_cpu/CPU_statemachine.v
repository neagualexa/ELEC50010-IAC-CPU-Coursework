module CPU_statemachine (
    input reset,
    input clk,
    input stall,
    output logic[2:0] state,
);
    
    typedef enum logic[2:0] {
        FETCH_INSTR = 3'b000,
        DECODE = 3'b001,
        EXECUTE = 3'b010,
        MEMORY_ACCESS = 3'b011,
        WRITE_BACK = 3'b100,
    } state_t;
    
    always_ff @(posdege clk) begin
        if(reset) begin 
            state <= FETCH_INSTR;
        end
        else if(stall) begin 
            state <= state;
        end
        else begin
            if(state==FETCH_INSTR) state <= DECODE;
            if(state==DECODE) state <= EXECUTE;
            if(state==EXECUTE) state <= MEMORY_ACCESS;
            if(state==MEMORY_ACCESS) state <= WRITE_BACK;
            if(state==WRITE_BACK) state <= FETCH_INSTR;
        end
    end
    
endmodule