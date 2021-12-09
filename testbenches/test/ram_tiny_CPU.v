module ram_tiny_CPU (
    input logic clk,
    input logic[31:0] address,
    input logic[3:0] byteenable,
    input logic write,
    input logic read,
    input logic[31:0] writedata,
    output logic[31:0] readdata
);
    parameter RAM_INIT_FILE = "./INITIALISED_FILE.txt";

    reg [7:0] memory [4095 :0];

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
    
    /*
    always @(*) begin
    	$display("ram: read = %b", read);
    end
    */

    /* Combinatorial read path. */
    logic[31:0] writedata_temp, readdata_temp_shift, readdata_temp;
    always @(posedge clk) begin
        //$display("RAM : INFO : read=%h, addr = %h, mem=%h", read, address, memory[address]);
        if (write) begin          
            writedata_temp = writedata;
            if (byteenable != 0) begin
                if (byteenable[0] == 1) begin
                    memory[address + 0] <= writedata_temp[7:0];
                end
                if (byteenable[1] == 1) begin
                     writedata_temp = writedata >> 8;
                    memory[address + 1] <= writedata_temp[7:0];
                end
                if (byteenable[2] == 1) begin
                    writedata_temp = writedata >> 16;
                    memory[address + 2] = writedata_temp[7:0];
                end
                if (byteenable[3] == 1) begin
                    writedata_temp = writedata >> 24;
                    memory[address + 3] = writedata_temp[7:0];
                end  
            end
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
            //memory[address + 0] <= writedata [7:0];
            //memory[address + 1] <= writedata [15:8];
            //memory[address + 2] <= writedata [23:16];
            //memory[address + 3] <= writedata [31:24]; 
                
            //memory[address] <= writedata;
        end
        else if(read) begin
            //$display("Im reading, address = %h", address);
            readdata_temp[31:24] <= memory[address + 3];
            readdata_temp[23:16] <= memory[address + 2];
            readdata_temp[15:8] <= memory[address + 1];
            readdata_temp[7:0] <= memory[address + 0];
        end
    end
    /*
    always @(*) begin
        $display("readdata_temp = %h", readdata_temp);
    end
    */
    always@(*) begin
        if (byteenable != 0) begin
            if (byteenable[3] == 1) begin

                readdata [7:0] = readdata_temp[31:24];
                //$display("ram: readdata = %h, byteenable = %b", readdata, byteenable);
            end
            if (byteenable[2] == 1) begin
                readdata_temp_shift = readdata;
                readdata = readdata_temp_shift << 8;
                readdata [7:0] = readdata_temp[23:16];
                //$display("ram: readdata = %h, byteenable = %b", readdata, byteenable);
            end
            if (byteenable[1] == 1) begin
                readdata_temp_shift = readdata;
                readdata = readdata_temp_shift << 8;
                readdata[7:0] = readdata_temp[15:8];
                //$display("ram: readdata = %h, byteenable = %b", readdata, byteenable);
            end
            if (byteenable[0] == 1) begin
                readdata_temp_shift = readdata;
                readdata = readdata_temp_shift << 8;
                readdata [7:0] = readdata_temp[7:0];
                //$display("ram: readdata = %h, byteenable = %b", readdata, byteenable);
            end 
        end
    end
            
            // else begin
            //     readdata [31:24] <= memory[address + 0];
            //     readdata [23:16] <= memory[address + 1];
            //     readdata [15:8] <= memory[address + 2];
            //     readdata [7:0] <= memory[address + 3];
            // end
    
            //readdata [7:0] <= memory[address + 0];
            //readdata [15:8] <= memory[address + 1];
            //readdata [23:16] <= memory[address + 2];
            //readdata [31:24] <= memory[address + 3];
            
            
            // BTYEENABLE CASE
            // byteenable = 0011; //LH SH LHU

            // byteenable = 1100; //LWL
            // byteenable = 0011; //LWR

            // byteenable = 1111; // LW SW
            
            // byteenable = 0001; // LB SB LBU 
            // byteenable = 0010; // 
            // byteenable = 0100; // 
            // byteenable = 1000; //
                
endmodule
    
/* EF 00 00 00 / 00 00 00 EF
    1100 / EF GH 00 00 / 00 00 GH EF
if (byteenable[3] == 1) begin
    readdata [7:0] <= memory[address + 3];
end
if (byteenable[2] == 1) begin
    readata = readdata << 8;
    readdata [7:0] <= memory[address + 2];
end
if (byteenable[1] == 1) begin
    readata = readdata << 8;
    readdata [7:0] <= memory[address + 1];
end
if (byteenable[0] == 1) begin
    readata = readdata << 8;
    readdata [7:0] <= memory[address + 0];
end

write


*/
