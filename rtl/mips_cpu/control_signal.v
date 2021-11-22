// jr addu addui lw sw
module control_signal (
	input logic[5:0] opcode,
	input logic[5:0] func_code,
	input logic[2:0] state,
	output RegDst,
	output RegWrite,
	output ALUSreA,
	output logic[1:0] ALUSreB,
	output logic[3:0] ALUctl,
	output logic[1:0] PCSource,
	output PCWrite,
	output PCWriteCond,
	output IorD,
	output MemRead,
	output MemWrite,
	output MemtoReg,
	output IRWrite
);

	logic[5:0] final_code;

	typedef enum logic[3:0] {
        AND = 4'b0000,
        OR = 4'b0001,
        ADD = 4'b0010,
        SUBTRACT = 4'b0110,
        SET_ON_LESS_THAN = 4'b0111,
        NOR = 4'b1100 
	} ALUOperation_t;

	typedef enum logic[2:0] {
        FETCH_INSTR = 3'b000,
        DECODE = 3'b001,
        EXECUTE = 3'b010,
        MEMORY_ACCESS = 3'b011,
        WRITE_BACK = 3'b100,
    } state_t;

	assign final_code = (opcode==0)? func_code : opcode;
	
	//ADDU 000000 100001
	//ADDIU 001001
	//JR 001000
	//LW 100011
	//SW 101011
	
	
	always_comb begin
		if(state==FETCH_INSTR) begin
			PCSource = 0;//To compute PC+4
			PCWrite = 1;
			MemRead = 1;
			IRWrite = 1;
			IorD = 0;
		end
		else if(state==DECODE) begin
			PCWrite = 0;
			
		end
		else if(state==EXECUTE) begin
			PCWrite = 0;
			
		end
		else if(state==MEMORY_ACCESS) begin
			PCWrite = 1;
			PCSource = (final_code==6'b001000)? 2'b10:0; // Currently only jump is implemented
			MemRead = (final_code == 6'b100011)? 1:0;
			MemWrite = (final_code == 6'b101011)? 1:0;

			MemtoReg = (opcode == 0)? 0: i-tpye;
			RegWrite = (opcode == 0)? 0: i-type;
			
			IorD = 1;
			
		end
		else if(state==WRITE_BACK) begin
			PCWrite = 0;
			MemtoReg = (final_code == 6'b100011)? 1:0;
			RegWrite = (final_code == 6'b100011)? 1:0;
		end
	end
	
	always_comb begin
		//R type
		if(opcode == 0) begin
			//addu
			if(func_code==6'b100001) begin
				RegDst = 1;
				ALUSreA = 1;
				ALUSreB = 0;
				ALUctl = ADD;		
			end	
		end
		//addiu
		if(opcode==6'b001001) begin
			RegDst = 0
			if (STATE == WRITE_BACK)begin
				RegWrite = 1
			end
            //MemWrite = 0;
			//MemtoReg = 0;
			ALUSrcA = 1;
			ALUSrcB = 2'b10;
			ALUctl = ADD;
				
		end
		//lw 
		if(opcode == 6'b100011) begin //execute: aluout=A+IR sign extended; 
									  //mem_acc: mdr=mem[ALUout]; write: rt=mdr
			RegDst = 0;
			RegWrite = 1;
			ALUSreA = 1;
			ALUSreB = 2'b10;
			ALUctl = ADD;
			//PCWrite = 
			//PCWriteCond =
			IorD = 0; //address of ALUout through PC
			//MemRead = ((FETCH_INSTR==1) | (MEMORY_ACCESS)) ? 1 : 0;
			MemWrite = 0;
			MemtoReg = 1;
		end

		//sw
		if(opcode == 6'b101011) begin
			RegDst = X;
			RegWrite = 0;
			ALUSrcA = 1;
			ALUSrcB = 2'b10;
			MemtoReg = X;
			ALUctl = ADD;
			
		end
	end

endmodule : control_signal