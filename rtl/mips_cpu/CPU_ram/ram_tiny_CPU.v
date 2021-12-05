module ram_tiny_CPU (
    input logic clk,
    input logic[31:0] address,
    input logic[3:0] byteenable,
    input logic write,
    input logic read,
    input logic[31:0] writedata,
    output logic[31:0] readdata
);
    parameter RAM_INIT_FILE = "./CPU_ram/jump_test_byte.txt";

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
                //TODO: to shift or not to shift
                //if byteenable is 0001 in CPU, then the byte which it points in ram is byte address+3 <=> 1000
                if (byteenable[0] == 1) begin
                    memory[address + 3] <= writedata_temp[7:0];
                end
                if (byteenable[1] == 1) begin
                     writedata_temp = writedata >> 8;
                    memory[address + 2] <= writedata_temp[7:0];
                end
                if (byteenable[2] == 1) begin
                    writedata_temp = writedata >> 16;
                    memory[address + 1] <= writedata_temp[7:0];
                end
                if (byteenable[3] == 1) begin
                    writedata_temp = writedata >> 24;
                    memory[address + 0] <= writedata_temp[7:0];
                end  
            end
                    
                        //SB (alligned address (div by 4)) - byteenable shows valid byte from data 
                                                            // and which specific unalligned addr to be written into memory
                        //rt: 00 00 00 90 (big en)
                        //CPU-out : xx xx xx 90
                        // xx 90 xx xx (NO swap)
                        //mem:         (4)xx (5)90 (6)xx (7)xx byteenable: 0100 , addr: 4
                        //             (4)xx (5)xx (6)90 (7)xx byteenable: 0010 , addr: 4


                        //SH (alligned address (div by 4), BUT addr in instr is div by 2) SH $R 6($0) 
                        //                                  - byteenable shows valid bytes from data
                        //                                  - and which specific addr to be written into memory
                        //rt: 01 02 03 04 
                        //CPU-out : xx xx 03 04

                        //SH $R Offset($RB)
                        //Option A
                        // 1. select the least significant two bytes and do the endian conversion with respect to two byte(switching their places)
                        // - (because it is doing LW which is a instruction of scope of 2 bytes, half word) //
                        // - This would be different to instruction with scope of a word so 4 bytes e.g. LWL LWR LW SW
                        // 2. put them into the correct place in a 32-bits output 
                        // - according whether they are a upper two bytes and a word or a lower two bytes of a word. 

                        //Option A Example                     
                        // SH $4 18($0) $4=12 33 03 04 
                        // 1.xx xx 04 03 
                        // 2. put the selected and converted byte to 
                        // - the correspond place and produced the byteenable according the address
                        // 18 is the upper two bytes : 1100 assuming it is small endian; data-in: 04 03 xx xx
                        // result: (19)04 (18)03 (17)remain unchanged (16)remain unchanged
                    
                        // Option B
                        // SH $4 18($0) $4 = 12 33 03 04
                        // 1) take the last two least significant bytes of the register : 03 04
                        // 2) merge them to a 32'bX word : xx xx 03 04
                        // 3) apply endianness conversion/swap for the transmission between CPU(big endian) 
                        //        to MEMORY Interface(Small endian) : 04 03 xx xx
                        // 4) the address we want to store is 18, hence the alligned address for the 
                        //        specific word is 16 and byteenable is 1100
                        // 5) result in memory: (16)unchanged (17)unchanged (18)03 (19)04     
                        // Option B
                        // LH $4 18($0)
                        // 1) in memory we have: (16)12 (17)33 (18)03 (19)04     
                        // 2) the address we want to load from is 18, hence the alligned address for the 
                        //        specific word is 16 and byteenable is (LSB)1100(MSB)  
                        // 3) the output of ram interface is (LSB)04 03 xx xx(MSB)
                        // 4) apply endianness conversion when inputed in the CPU : (MSB)xx xx 03 04(LSB)
                        // 5) take the respective bytes of byteenable: (LSB)1100(MSB) : 03 04
                        // 6) sign extend them to a 32 bit word : 00 00 03 04
                        // 7) store the given work into the wanted register : $4 = 00 00 03 04        



                        //mem :      (4)xx (5)xx (6)03 (7)04 byteenable: 0011, addr: 6
                        //data-in-mem: xx xx 03 04
                        //mem :      (4)03 (5)04 (6)xx (7)xx byteenable: 1100, addr: 4
                        //data-in-memL 03 04 xx xx

                        //LWL,LWR,LW


                //BYTEENABLE => (parsed address from intruction) % 4 = {0,1,2,3} which will be {0001,0010,0100,1000} SB,LB,LBU
                //                                                                             {0011,1100}           SH,LH,LHU            

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

                        //LB (alligned address (div by 4)) - byteenable shows valid byte from data 
                                                            // and which specific unalligned addr to be written into memory
                        //mem:         (4)xx (5)90 (6)xx (7)xx byteenable: 0100 , addr: 4
                        //             (4)xx (5)xx (6)90 (7)xx byteenable: 0010 , addr: 4
                        //CPU-in/MEM-out: 
                        //rt:  00 00 00 90


                        //LH (address is a multiple of 2) - byteenable shows valid bytes from data
                        //                                                  and which specific addr to be written into memory
                        //NO:  mem :      (6)xx (7)xx (8)03  (9)04 byteenable: 0011, addr: 6
                        //YES: mem :      (8)03 (9)04 (10)xx (11)xx byteenable: 1100, addr: 8
                        //CPU-in/MEM-out: 
                        //rt:  00 00 00 90

            end

            //$display("Im reading, address = %h", address);
            /*
            readdata_temp[31:24] <= memory[address + 3];
            readdata_temp[23:16] <= memory[address + 2];
            readdata_temp[15:8] <= memory[address + 1];
            readdata_temp[7:0] <= memory[address + 0];
            */
        end
    end
    /*
    always @(*) begin
        $display("readdata_temp = %h", readdata_temp);
    end
    */
            
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