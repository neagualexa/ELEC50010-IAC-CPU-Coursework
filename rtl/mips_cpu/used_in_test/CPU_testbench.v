module CPU_testbench (
);
    logic clk;
    logic reset;
    logic active;

    logic write;
    logic read;
    logic waitrequest;

    logic[31:0] address;
    logic[31:0] writedata;
    logic[31:0] readdata;
    logic[3:0] byteenable;

    logic[31:0] register_v0;
    
    parameter TIMEOUT_CYCLES = 100;
    parameter TEST_ID = "XXX_X";
    parameter INSTRUCTION = "XXX";
    parameter RAM_INIT_FILE = "";
	
    logic[31:0] writedata_from_CPU;
    logic[31:0] readdata_from_RAM;
    logic[31:0] writedata_to_RAM;
    logic[31:0] readdata_to_CPU;

    integer counter;

    initial begin
        $dumpfile("CPU_testbench.vcd");
        $dumpvars(0, CPU_testbench);

        clk = 0;
        counter = 1;
        //waitrequest = 0;
        
        repeat (TIMEOUT_CYCLES) begin
            #5
            clk = ~clk;
            #5
            clk = ~clk;
        end       

        $fatal(2, "did not finish within %d cycles", TIMEOUT_CYCLES); 
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
        assert(active == 1) else $fatal(1, "CPU didn't go active after reset");
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
        counter = 1+counter;
        

        while (active == 1) begin
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
            $display(" RESULT: Instruction %d has result($v0) : %h, active = %d", counter, register_v0, active);
            counter = 1+counter;            
        end

        @(negedge clk);
        $display(" RESULT: %h", register_v0);
        $finish;
        
    end
    
    //assign readdata_to_CPU = readdata;

	assign readdata_to_CPU [7:0] = readdata[31:24];
	assign readdata_to_CPU [15:8] = readdata[23:16];
	assign readdata_to_CPU [23:16] = readdata[15:8];
	assign readdata_to_CPU [31:24] = readdata[7:0];
    

    mips_cpu_bus datapath(  .clk(clk),
                            .reset(reset), 
                            .active(active), 
                            .register_v0(register_v0),
                            .address(address),
                            .write(write),
                            .read(read),
                            .waitrequest(waitrequest),
                            .writedata(writedata), 
                            .byteenable(byteenable),
                            .readdata(readdata));

    ram_tiny_CPU ram(   .clk(clk),
                        .address(address),
                        .byteenable(byteenable), 
                        .write(write),
                        .read(read),
                        .writedata(writedata),
                        .readdata(readdata),
                        .waitrequest(waitrequest));
    

endmodule
