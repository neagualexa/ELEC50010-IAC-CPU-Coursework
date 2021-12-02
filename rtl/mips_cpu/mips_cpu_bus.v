// top level CPU (will be connected to MEMORY in testbench)
module mips_cpu_bus (
	input logic clk,    
	input logic reset, 
	output logic active,
	output logic[31:0] register_v0,

	// avalon memory mapped bus controller (master)
	output logic[31:0] address,
	output logic write,
	output logic read,
	input logic waitrequest,
	output logic[31:0] writedata,
	output logic[3:0] byteenable,
	input logic[31:0] readdata,

	output logic[2:0] state

);

	//VARIABLES
	
	////state machine
	logic stall; //not implemented yet
	//logic[2:0] state;
	
	//instruction register
	logic[5:0] instr31_26;
    	logic[4:0] instr25_21;
    	logic[4:0] instr20_16;
    	logic[15:0] instr15_0;
	logic[4:0] instr15_11;
	logic[4:0] instr10_6;
	assign instr15_11 = readdata_to_CPU[15:11];
	assign instr10_6 = readdata_to_CPU[10:6];
	
	//pc
	logic pc_ctl;
	logic[31:0] pc_in, PC;

	//register file
	logic[4:0] readR1, readR2;
	
	//variables for mux
	logic[31:0] MEMmux2to1;
	logic[31:0] Decodemux2to1;
	logic[31:0] ALUAmux2to1;
	logic[4:0] Regmux2to1;
	logic[31:0] RegWritemux2to1;
	logic[31:0] full_instr;

	//ALU Variable
    logic[31:0] ALU_result;
	logic[63:0] ALU_MULTorDIV_result;
	logic[3:0] ALUctrl;
	logic zero;
	assign register_v0 = ALUOut;  //FOR DEBUGGING CURRENTLY, but actually reg v0 is reg of index 2 in reg file							
	logic[31:0] HI, LO;

	//reg A & B & ALUout
	logic[31:0] regA, regB, ALUOut;
	
	//control logic for MUXes
	logic[5:0] opcode, func_code;
	logic RegDst, RegWrite, ALUSrcA;
	logic[1:0] ALUSrcB, PCSource;
	logic[3:0] ALUctl;
	logic PCWrite, PCWriteCond; //combines in gates and added into PC block for conditional jumps
	logic IorD, MemtoReg, IRWrite, unsign, fixed_shift;

	//ALUmux4to1
	logic[31:0] ALUB;
	logic[31:0] readdata1;
	logic[31:0] readdata2;
	
	
	logic[31:0] writedata_from_CPU, readdata_from_RAM, writedata_to_RAM, readdata_to_CPU;
	assign writedata_from_CPU = regB;


	//BLOCKS

	CPU_statemachine stm(.reset(reset), .clk(clk), .stall(stall), .state(state));

	assign pc_ctl = (PCWriteCond & zero) | PCWrite;
	pc pc1(.clk(clk), .reset(reset), .pcctl(pc_ctl), .pc_prev(pc_in), .pc_new(PC));
	
	//Control signals
	
	//assign opcode = Decodemux2to1[31:26];
	//assign func_code = Decodemux2to1[5:0];
	assign full_instr = {instr31_26, instr25_21, instr20_16, instr15_0};
	assign Decodemux2to1 = (state == 3'b001) ? readdata_to_CPU : full_instr; 

	control_signal_simplified control(
		.opcode(Decodemux2to1[31:26]), .func_code(Decodemux2to1[5:0]), .state(state),
		.RegDst(RegDst), .RegWrite(RegWrite), .ALUSrcA(ALUSrcA), 
		.ALUSrcB(ALUSrcB), .ALUctl(ALUctl), .PCSource(PCSource),
		.PCWrite(PCWrite), .PCWriteCond(PCWriteCond), .IorD(IorD), 
		.MemRead(read), .MemWrite(write), .MemtoReg(MemtoReg),
		.IRWrite(IRWrite), .unsign(unsign), .fixed_shift(fixed_shift)
	);
	
	//MUXes
	assign address = (IorD == 0) ? PC : ALUOut; //MEMmux2to1
	//assign address = MEMmux2to1;
	assign Regmux2to1 = (RegDst == 0) ? Decodemux2to1[20:16] : Decodemux2to1[15:11];
	assign RegWritemux2to1 = (MemtoReg == 0) ? ALUOut : readdata_to_CPU;
	assign ALUAmux2to1 = (ALUSrcA == 0) ? PC : regA; 

	
	//ALUmux4to1
	ALUmux4to1 ALUmux4to1(
		.register_b(readdata2), .immediate(instr15_0), .ALUSrcB(ALUSrcB), 
		.ALUB(ALUB), .opcode(Decodemux2to1[31:26])
	);

	//IR
	instruction_reg IR(
		.clk(clk), .reset(reset), .IRWrite(IRWrite), .memdata(readdata_to_CPU),
		.instr31_26(instr31_26), .instr25_21(instr25_21), .instr20_16(instr20_16),
		.instr15_0(instr15_0)
	);

	//register files
	assign readR1 = Decodemux2to1[25:21];
	assign readR2 = Decodemux2to1[20:16];
	registers regfile(
		.clk(clk), .reset(reset), .RegWrite(RegWrite), .readR1(readR1), 
		.readR2(readR2), .writeR(Regmux2to1), .writedata(RegWritemux2to1),
		.readdata1(readdata1), .readdata2(readdata2)
	);
	
	//registers A & B & ALUOut
	always_ff @(posedge clk) begin
		if (reset == 1) begin
			regA <= 0;
			regB <= 0;
			ALUOut <= 0;
		end 
		else begin
			regA <= readdata1;
			regB <= readdata2;
			ALUOut <= ALU_result;
		end
	end
	
	//ALU
	alu ALU(
		.ALUOperation(ALUctl), .a(ALUAmux2to1), .b(ALUB), .unsign(unsign),
		.ALU_result(ALU_result), .zero(zero), .ALU_MULTorDIV_result(ALU_MULTorDIV_result),
		.instr10_6(instr10_6), .fixed_shift(fixed_shift)
	);

	/*
	always @(*) begin
		//$display("ALU_MULTorDIV_result = %h", ALU_MULTorDIV_result);
		//$display("ALUA = %b, ALUB = %b", ALUAmux2to1, ALUB);
		//$display("state = %b, full_instr = %h, readR1 = %h, regA = %h, RegWrite = %h", state, full_instr, readR1, regA, RegWrite);
		//$display("ALU_result = %h", ALU_result);
		$display("writedata_from_CPU = %h, writedata = %h", writedata_from_CPU, writedata);
		$display("readdata_to_CPU = %h, readdata = %h", readdata_to_CPU, readdata);
	end
	*/
	

	//HI LO registers
	HI_LO_Control HI_LO_Control(
		.clk(clk), .reset(reset), .opcode(Decodemux2to1[31:26]), .func_code(Decodemux2to1[5:0]),
		.regA(regA), .ALU_MULTorDIV_result(ALU_MULTorDIV_result), .HI(HI), .LO(LO), .state(state)
	);

	//rightmost mux
	PCmux3to1 pcmux(
		.ALU_result(ALU_result), .ALUOut(ALUOut), .PCSource(PCSource), .PC_in(PC),
		.instr25_21(Decodemux2to1[25:21]), .instr20_16(Decodemux2to1[20:16]), .instr15_0(Decodemux2to1[15:0]),
    	.PC_out(pc_in)
	);
	
	endian_swap swap(
    		.writedata_from_CPU(writedata_from_CPU), .readdata_from_RAM(readdata), 
    		.writedata_to_RAM(writedata), .readdata_to_CPU(readdata_to_CPU)
    	);
    
	
endmodule : mips_cpu_bus
