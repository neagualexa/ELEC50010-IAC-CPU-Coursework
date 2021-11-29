module ram_tiny_CPU (
    input logic clk,
    input logic[31:0] address,
    input logic[3:0] byteenable,
    input logic write,
    input logic read,
    input logic[31:0] writedata,
    output logic[31:0] readdata
);
    parameter RAM_INIT_FILE = "./CPU_ram/Mult_test.txt";

    reg [31:0] memory [4095 :0];

    initial begin
        integer i;
        /* Initialise to zero by default */
        for (i=0; i<4096; i++) begin
            memory[i]=0;
        end
        /* Load contents from file if specified */
        
        $display("RAM : INIT : Loading RAM contents from %s", RAM_INIT_FILE);
        $readmemh(RAM_INIT_FILE, memory);
        
    end

    /* Combinatorial read path. */
    always @(posedge clk) begin
        //$display("RAM : INFO : read=%h, addr = %h, mem=%h", read, address, memory[address]);
        if (write) begin
            memory[address] <= writedata;
        end
        else if(read) begin
            readdata <= memory[address]; // Read-after-write mode
        end
    end
endmodule
    