module ram_tiny_CPU (
    input logic clk,
    input logic[31:0] address,
    input logic[3:0] byteenable,
    input logic write,
    input logic read,
    input logic[31:0] writedata,
    output logic[31:0] readdata
);
    parameter RAM_INIT_FILE = "./CPU_ram/shifts_byte.txt";

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
    
    always @(*) begin
    	$display("ram: readdata = %h", readdata);
    end

    /* Combinatorial read path. */
    always @(posedge clk) begin
        //$display("RAM : INFO : read=%h, addr = %h, mem=%h", read, address, memory[address]);
        if (write) begin
            /*
            if (byteenable != 0) begin
                
            end
            else begin
                memory[address + 0] <= writedata [7:0];
                memory[address + 1] <= writedata [15:8];
                memory[address + 2] <= writedata [23:16];
                memory[address + 3] <= writedata [31:24]; 
            end
            */
            memory[address + 0] <= writedata [7:0];
            memory[address + 1] <= writedata [15:8];
            memory[address + 2] <= writedata [23:16];
            memory[address + 3] <= writedata [31:24]; 
                
            //memory[address] <= writedata;
        end
        else if(read) begin
            /*if (byteenable != 0) begin
                
            end
            else begin
                readdata [31:24] <= memory[address + 0];
                readdata [23:16] <= memory[address + 1];
                readdata [15:8] <= memory[address + 2];
                readdata [7:0] <= memory[address + 3];
            end
            */
            readdata [7:0] <= memory[address + 0];
            readdata [15:8] <= memory[address + 1];
            readdata [23:16] <= memory[address + 2];
            readdata [31:24] <= memory[address + 3];
                
            //readdata <= memory[address];
             // Read-after-write mode
        end
    end
endmodule
    
