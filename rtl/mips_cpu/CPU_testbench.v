module CPU_testbench (
);
    logic clk, reset, active, write, read, waitrequest;
    logic[31:0] address, writedata, readdata, register_v0;
    logic[3:0] byteenable;
    logic[2:0] state;
    
    parameter TIMEOUT_CYCLES = 26;

    typedef enum logic[2:0] {
        FETCH_INSTR = 3'b000,
        DECODE = 3'b001,
        EXECUTE = 3'b010,
        MEMORY_ACCESS = 3'b011,
        WRITE_BACK = 3'b100
	} state_t;

    initial begin
        $dumpfile("CPU_testbench.vcd");
        $dumpvars(0, CPU_testbench);

        clk = 0;
        
        repeat (TIMEOUT_CYCLES) begin
            #10
            clk = ~clk;
            #10
            clk = ~clk;
        end        
    end

    initial begin
        
        reset = 0;
        
        @(negedge clk);
        reset = 1;

        @(negedge clk);
        reset = 0;
        //FETCH instr 1
        $display("FETCH         - readdata: %h, ALUOut: %h", readdata, register_v0);

        @(negedge clk);
        //DECODE instr 1
        $display("DECODE        - readdata: %h, ALUOut: %h, opcode: %b", readdata, register_v0, readdata[31:26]);
        @(negedge clk);
        //EX instr 1
        $display("EXECUTE       - readdata: %h, ALUOut: %h, opcode: %b", readdata, register_v0, readdata[31:26]);
        @(negedge clk);
        //MEMORY_ACCESS instr 1
        $display("MEMORY_ACCESS - readdata: %h, ALUOut: %h, opcode: %b", readdata, register_v0, readdata[31:26]);
        @(negedge clk);
        //WRITE_BACK instr 1
        $display("WRITE_BACK    - readdata: %h, ALUOut: %h, opcode: %b", readdata, register_v0, readdata[31:26]);
        $display("---------------------------------------------");

        repeat (TIMEOUT_CYCLES/5) begin
            @(negedge clk);
            //FETCH instr
            $display("FETCH         - readdata: %h, ALUOut: %h", readdata, register_v0);
            @(negedge clk);
            //DECODE instr
            $display("DECODE        - readdata: %h, ALUOut: %h, opcode: %b", readdata, register_v0, readdata[31:26]);
            @(negedge clk);
            //EXECUTE instr
            $display("EXECUTE       - readdata: %h, ALUOut: %h, opcode: %b", readdata, register_v0, readdata[31:26]);
            @(negedge clk);
            //MEMORY_ACCESS instr
            $display("MEMORY_ACCESS - readdata: %h, ALUOut: %h, opcode: %b", readdata, register_v0, readdata[31:26]);
            @(negedge clk);
            //WRITE_BACK instr
            $display("WRITE_BACK    - readdata: %h, ALUOut: %h, opcode: %b", readdata, register_v0, readdata[31:26]);
            $display("---------------------------------------------");
        end
        
    end

    mips_cpu_bus datapath(.clk(clk), .reset(reset), .active(active), .register_v0(register_v0),
                    .address(address), .write(write), .read(read), .writedata(writedata), 
                    .readdata(readdata), .byteenable(byteenable), .waitrequest(waitrequest),
                    .state(state) );
    ram_tiny_CPU ram(.clk(clk), .address(address), .byteenable(byteenable), 
        .write(write), .read(read), .writedata(writedata), .readdata(readdata));
    
endmodule