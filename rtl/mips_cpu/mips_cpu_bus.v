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
	assign instr15_11 = readdata[15:11];
	
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
	logic IorD, MemRead, MemWrite, MemtoReg, IRWrite, unsign;

	//ALUmux4to1
	logic[31:0] ALUB;
	logic[31:0] readdata1;
	logic[31:0] readdata2;
	
	assign writedata = regB;


	//BLOCKS

	CPU_statemachine stm(.reset(reset), .clk(clk), .stall(stall), .state(state));

	assign pc_ctl = (PCWriteCond & zero) | PCWrite;
	pc pc1(.clk(clk), .reset(reset), .pcctl(pc_ctl), .pc_prev(pc_in), .pc_new(PC));
	
	//Control signals
	
	//assign opcode = Decodemux2to1[31:26];
	//assign func_code = Decodemux2to1[5:0];
	assign full_instr = {instr31_26, instr25_21, instr20_16, instr15_0};
	assign Decodemux2to1 = (state == 3'b001) ? readdata : full_instr; 

	control_signal_simplified control(
		.opcode(Decodemux2to1[31:26]), .func_code(Decodemux2to1[5:0]), .state(state),
		.RegDst(RegDst), .RegWrite(RegWrite), .ALUSrcA(ALUSrcA), 
		.ALUSrcB(ALUSrcB), .ALUctl(ALUctl), .PCSource(PCSource),
		.PCWrite(PCWrite), .PCWriteCond(PCWriteCond), .IorD(IorD), 
		.MemRead(read), .MemWrite(write), .MemtoReg(MemtoReg),
		.IRWrite(IRWrite), .unsign(unsign)
	);
	
	//MUXes
	assign MEMmux2to1 = (IorD == 0) ? PC : ALUOut;
	assign address = MEMmux2to1;
	assign Regmux2to1 = (RegDst == 0) ? Decodemux2to1[20:16] : Decodemux2to1[15:11];
	assign RegWritemux2to1 = (MemtoReg == 0) ? ALUOut : readdata;
	assign ALUAmux2to1 = (ALUSrcA == 0) ? PC : regA; 
	
	
	//ALUmux4to1
	ALUmux4to1 ALUmux4to1(
		.register_b(readdata2), .immediate(instr15_0), .ALUSrcB(ALUSrcB), 
		.ALUB(ALUB), .opcode(Decodemux2to1[31:26])
	);

	//IR
	instruction_reg IR(
		.clk(clk), .reset(reset), .IRWrite(IRWrite), .memdata(readdata),
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
		.ALU_result(ALU_result), .zero(zero), .ALU_MULTorDIV_result(ALU_MULTorDIV_result)
	);

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
	
endmodule : mips_cpu_bus
