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
	typedef enum logic[5:0] {
		ADDU = 6'b100001;
		ADDIU = 6'b001001;
		JR = 6'b001000;
		LW = 6'b100011;
		SW = 6'b101011;
	} final_code_list;
	
	initial begin
		MemRead = 0;
		MemWrite = 0;
		IRWrite = 0;
		RegWrite = 0;
	end

	always_comb begin
		if(state==FETCH_INSTR) begin //Two function need to be done in IF 1.instruction_register<=memory(pc) 2.pc+4
			ALUSreA = 0; //ALU To compute PC+4
			ALUSreB = 1;
			ALUctl = ADD;

			PCWrite = 1; //PC
			PCSource = 0; 

			MemRead = 1;  //To fetch memory
			IRWrite = 1;  //Write IR
			IorD = 0;	  // selecting address = PC
		end
		else if(state==DECODE) begin // 1.reading RA and RB(TOP LEVEL) 2.calculatr ALUOut<= PC+signextend(IR[15:0])(Branching/R-type)(TOP LEVEL)
			ALUSrcA = 0; //ALU To compute PC+signextend(IR[15:0])
			ALUSrcB = 2;
			ALUctl = ADD;

			PCWrite = 0; //close PC
			IRWrite = 0; //currently close IR

			MemRead = 0;  
			IRWrite = 0;  
			IorD = 0;	  			
		end
		// else if(state==EXECUTE) begin //1. change PC if operation is Branch/Jump 2.update ALUOut for indirect addressing(memory reference) 3. update the result to ALUOUT(R-Type)
		// 	//PCWrite = (final_code==Branch type) 1:0; 
		// 	//PCSource = (final_code==Branch type)? 2'b01:0; // Currently only jump is implemented
		// 	PCWrite = (final_code == 6'b001000)? 1:0;
		// 	PCSource = (final_code==6'b001000)? 2'b10:0; // Currently only jump is implemented
		// 	IRWrite = 0;
			
		// end
		else if(state==EXECUTE) begin
			//Branch/JUMP instruction should be completed in the stage
			//ALU related operation, so it could be R or I-type
			case(final_code):
				//arithmetic purpose operation
				ADDU: begin
					//RegDst = 1;
					ALUSreA = 1;
					ALUSreB = 0;
					ALUctl = ADD;
				end
				ADDIU: begin
					ALUSrcA = 1;
					ALUSrcB = 2; //picking 2 without the left-shift unit
					ALUctl = ADD;
				end
				//LW SW(Memory reference)
				LW: begin
					ALUSrcA = 1;
					ALUSrcB = 3; //picking 3 with the left-shift unit
					ALUctl = ADD;
				end
				SW: begin
					ALUSrcA = 1;
					ALUSrcB = 3; //picking 3 with the left-shift unit
					ALUctl = ADD;
				end
				//JR (JUMPINGGGGG)
				JR: begin
					ALUSrcA = 1;
					ALUSrcB = 0; //picking 0: register B which should be 0. 0 register
					ALUctl = ADD;
				end
			endcase	 
		end
		// else if(state==MEMORY_ACCESS) begin
		// 	//R-type should/could be complete in this round
		// 	PCWrite = 0;
			
		// 	MemRead = (final_code == 6'b100011)? 1:0;
		// 	MemWrite = (final_code == 6'b101011)? 1:0;

		// 	MemtoReg = (opcode == 0)? 0: i-tpye;
		// 	RegWrite = (opcode == 0)? 0: i-type;
			
		// 	IorD = 1;
		// end
		else if(state==MEMORY_ACCESS) begin
			//R-type could be complete in this round(not implementing it here because that would be gross)
			//fetching data
			case(final_code):
				LW: begin //Load data to the MDR
					IorD = 1;
	 				MemtoReg = 1;
				end
				SW: begin //store data
					IorD = 1;
					MemWrite = 1;
				end
			endcase
			
		end
		else if(state==WRITE_BACK) begin
			RegWrite = 1;
			case(final_code):
				//R U 1.Loading data to reg or 2.ALUOut to reg
				LW: begin
					RegDst = 0; //depends on the format of the mips
					MemtoReg = 1; //memory To register
				end
				ADD: begin
					RegDst = 0;
					MemtoReg = 0;//ALU To register
				end
				ADDIU: begin
					RegDst = 0;
					MemtoReg = 0;
				end
				
			endcase
		end
	end

	// always_comb begin
	// 	//R type
	// 	if(opcode == 0) begin
	// 		//addu
	// 		if(func_code==6'b100001) begin
	// 			RegDst = 1;
	// 			ALUSreA = 1;
	// 			ALUSreB = 0;
	// 			ALUctl = ADD;		
	// 		end	
	// 	end
	// 	//addiu
	// 	if(opcode==6'b001001) begin
	// 		RegDst = 0
	// 		if (STATE == WRITE_BACK)begin
	// 			RegWrite = 1
	// 		end
    //         //MemWrite = 0;
	// 		//MemtoReg = 0;
			
				
	// 	end
	// 	//lw 
	// 	if(opcode == 6'b100011) begin //execute: aluout=A+IR sign extended; 
	// 								  //mem_acc: mdr=mem[ALUout]; write: rt=mdr
	// 		RegDst = 0;
	// 		RegWrite = 1;
	// 		ALUSreA = 1;
	// 		ALUSreB = 2'b10;
	// 		ALUctl = ADD;
	// 		//PCWrite = 
	// 		//PCWriteCond =
	// 		IorD = 0; //address of ALUout through PC
	// 		//MemRead = ((FETCH_INSTR==1) | (MEMORY_ACCESS)) ? 1 : 0;
	// 		MemWrite = 0;
	// 		MemtoReg = 1;
	// 	end

	// 	//sw
	// 	if(opcode == 6'b101011) begin
	// 		RegDst = X;
	// 		RegWrite = 0;
	// 		ALUSrcA = 1;
	// 		ALUSrcB = 2'b10;
	// 		MemtoReg = X;
	// 		ALUctl = ADD;
			
	// 	end
	// end

endmodule : control_signal