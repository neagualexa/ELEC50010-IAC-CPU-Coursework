module CPU_testbench (
);
    logic clk, reset, active, write, read, waitrequest;
    logic[31:0] address, writedata, readdata, register_v0;
    logic[3:0] byteenable;
    logic[2:0] state;
    
    parameter TIMEOUT_CYCLES = 23*5+1;

    typedef enum logic[2:0] {
        FETCH_INSTR = 3'b000,
        DECODE = 3'b001,
        EXECUTE = 3'b010,
        MEMORY_ACCESS = 3'b011,
        WRITE_BACK = 3'b100
	} state_t;
	
    logic[31:0] writedata_from_CPU, readdata_from_RAM, writedata_to_RAM, readdata_to_CPU;
    integer counter;

    initial begin
        $dumpfile("CPU_testbench.vcd");
        $dumpvars(0, CPU_testbench);

        clk = 0;
        counter = 1;
        waitrequest = 0;
        
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
        $display(" OUT:  ------------------- %d --------------------------", counter);
        $display(" OUT:  FETCH         - readdata_to_CPU: %h, ALUOut: %h, opcode: %b",readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);

        @(negedge clk);
        //DECODE instr 1
        $display(" OUT:  DECODE        - readdata_to_CPU: %h, ALUOut: %h, opcode: %b", readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);
        @(negedge clk);
        //EX instr 1
        $display(" OUT:  EXECUTE       - readdata_to_CPU: %h, ALUOut: %h opcode: %b", readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);
        @(negedge clk);
        //MEMORY_ACCESS instr 1
        $display(" OUT:  MEMORY_ACCESS - readdata_to_CPU: %h, ALUOut: %h opcode: %b", readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);
        @(negedge clk);
        //WRITE_BACK instr 1
        $display(" OUT:  WRITE_BACK    - readdata_to_CPU: %h, ALUOut: %h opcode: %b", readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);
        $display(" RESULT: Instruction %d has result($v0) : %h", counter, register_v0);
        counter = 1+counter;
        

        repeat (TIMEOUT_CYCLES/5) begin
            @(negedge clk);
            $display(" OUT:  ------------------- %d --------------------------", counter);
            //FETCH instr
            $display(" OUT:  FETCH         - readdata_to_CPU: %h, ALUOut: %h, opcode: %b",readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);
            
            @(negedge clk);
            //DECODE instr
            $display(" OUT:  DECODE        - readdata_to_CPU: %h, ALUOut: %h opcode: %b", readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);
            
            @(negedge clk);
            //EXECUTE instr
            $display(" OUT:  EXECUTE       - readdata_to_CPU: %h, ALUOut: %h opcode: %b", readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);
            
            @(negedge clk);
            //MEMORY_ACCESS instr
            $display(" OUT:  MEMORY_ACCESS - readdata_to_CPU: %h, ALUOut: %h opcode: %b", readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);
            
            @(negedge clk);
            //WRITE_BACK instr
            $display(" OUT:  WRITE_BACK    - readdata_to_CPU: %h, ALUOut: %h opcode: %b", readdata_to_CPU, register_v0, readdata_to_CPU[31:26]);
            $display(" RESULT: Instruction %d has result($v0) : %h", counter, register_v0);
            counter = 1+counter;            
        end
        
    end
    

	assign readdata_to_CPU [7:0] = readdata[31:24];
	assign readdata_to_CPU [15:8] = readdata[23:16];
	assign readdata_to_CPU [23:16] = readdata[15:8];
	assign readdata_to_CPU [31:24] = readdata[7:0];
    

    mips_cpu_bus datapath(.clk(clk), .reset(reset), .active(active), .register_v0(register_v0),
                    .address(address), .write(write), .read(read), .writedata(writedata), 
                    .readdata(readdata), .byteenable(byteenable), .waitrequest(waitrequest)
                    //.state(state) 
                    );
    ram_tiny_CPU ram(.clk(clk), .address(address), .byteenable(byteenable), 
        .write(write), .read(read), .writedata(writedata), .readdata(readdata));
    

endmodule
