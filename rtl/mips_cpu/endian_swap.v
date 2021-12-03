// LB
// LH
// LWL
// LW
// LBU
// LHU
// LWR
// SB
// SH
// SW 
module endian_swap (
input logic [31:0] writedata_from_CPU,
input logic [31:0] readdata_from_RAM,
input logic [5:0] opcode,
input logic [3:0] byteenable_from_CPU,
output logic [31:0] writedata_to_RAM,
output logic [31:0] readdata_to_CPU

);
 
    typedef enum logic[5:0]{
        LW = 6'b100011,
        SW = 6'b101011
    } opcode_list;

    
        
    assign    writedata_to_RAM [7:0] = writedata_from_CPU [31:24];
    assign    writedata_to_RAM [15:8] = writedata_from_CPU [23:16];
    assign    writedata_to_RAM [23:16] = writedata_from_CPU [15:8];
    assign    writedata_to_RAM [31:24] = writedata_from_CPU [7:0];
    
    
    assign    readdata_to_CPU [7:0] = readdata_from_RAM [31:24];
    assign    readdata_to_CPU [15:8] = readdata_from_RAM [23:16];
    assign    readdata_to_CPU [23:16] = readdata_from_RAM [15:8];
    assign    readdata_to_CPU [31:24] = readdata_from_RAM [7:0];
  

endmodule
