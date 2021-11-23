// top level CPU (will be connected to MEMORY in testbench)
module mips_cpu_bus (
	input logic clk,    
	input logic reset, 
	output logic active,
	output logic[31:0] register_v0,

	// avalon memory mapped bus controller (master)
	output logic[31:0] address,
	output loigc write,
	output logic read,
	input logic waitrequest,
	output logic[31:0] writedata,
	output logic[31:0] byteenable,
	input logic[31:0] readdata
);



endmodule : mips_cpu_bus
