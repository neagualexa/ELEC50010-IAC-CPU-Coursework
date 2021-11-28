// jr addu addui lw sw
module control_signal_simplified(
	input logic[5:0] opcode,
	input logic[5:0] func_code,
	input logic[2:0] state,
	output logic RegDst,
	output logic RegWrite,
	output logic ALUSrcA,
	output logic[1:0] ALUSrcB,
	output logic[3:0] ALUctl,
	output logic[1:0] PCSource,
	output logic PCWrite,
	output logic PCWriteCond,
	output logic IorD,
	output logic MemRead,
	output logic MemWrite,
	output logic MemtoReg,
	output logic IRWrite
	
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
        WRITE_BACK = 3'b100
	} state_t;

	typedef enum logic[5:0] {
      	ADDU = 6'b100001,
		ADDIU = 6'b001001,
		JR = 6'b001000,
		LW = 6'b100011,
		SW = 6'b101011
	} opcode_t;


	assign final_code = (opcode == 0) ? func_code : opcode;
	
	//ADDU 000000 100001
	//ADDIU 001001
	//JR 000000 001000
	//LW 100011
	//SW 101011

	
	initial begin
		MemRead = 0;
		MemWrite = 0;
		IRWrite = 0; 
		RegWrite = 0;
	end

	always @(state) begin
		RegDst = 0;
		RegWrite = 0;
		ALUSrcA = 1;
		ALUSrcB = 0;
		ALUctl = 0;
		PCSource = 0;
		PCWrite = 0;
		PCWriteCond = 0;
		IorD = 0;
		IRWrite = 0;
		MemRead = 0;
		MemWrite = 0;
		MemtoReg = 0;
	// we should set everything to their default values for every instruction fetched ????????????????? make sure
		//$display("Final code: %b, state: %d", final_code, state);

		if(state==FETCH_INSTR) begin //Two function need to be done in IF 1.instruction_register<=memory(pc) 2.pc+4
		
			ALUSrcA = 0; //ALU To compute PC+4
			ALUSrcB = 2'b01;
			ALUctl = ADD;

			PCWrite = 1; //PC
			PCSource = 0; 

			MemRead = 1;  //To fetch memory
			IorD = 0;	  // selecting address = PC
		end
		else if(state==DECODE) begin // 1.reading RA and RB(TOP LEVEL) 2.calculatr ALUOut<= PC+signextend(IR[15:0])(Branching/R-type)(TOP LEVEL)
			
			ALUSrcA = 0; //ALU To compute PC+signextend(IR[15:0])
			ALUSrcB = 2'b10;
			ALUctl = ADD;

			PCWrite = 0; //close PC
			
			MemRead = 0;  
			IRWrite = 1;  // is 1 in  DECODE stage	
		end
		else if(state==EXECUTE) begin
			
			//Branch/JUMP instruction should be completed in the stage
			//ALU related operation, so it could be R or I-type
			//final-code should be opcode for I-type/J-type and function-code for R-type 
			case(final_code)
				//arithmetic purpose operation
				ADDU: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = ADD;
				end
				ADDIU: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b10; //picking 2 without the left-shift unit
					ALUctl = ADD;
				end
				//LW SW(Memory reference)
				LW: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b11; //picking 3 with the left-shift unit => so that we an address which is div by 4
 					ALUctl = ADD;
				end
				SW: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b11; //picking 3 with the left-shift unit
					ALUctl = ADD;
				end
				//JR (JUMPINGGGGG) ;)
				JR: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00; //picking 0: register B which should be 0. 0 register 
					// MUST ASSUME register rs is div by 4 for a good jump 
					// would make a bus check by ANDing the address from rs with hFFF0 (just cause)
					ALUctl = ADD;
				end
			endcase	 
		end
		else if(state==MEMORY_ACCESS) begin
			//R-type could be complete in this round(not implementing it here because that would be gross)
			//fetching data and writing data
			

			case(final_code)
				LW: begin //Load data to the MDR
					//$display("IN  LW");
					IorD = 1;
					MemRead = 1;
				end
				SW: begin //store data
					IorD = 1;
					MemWrite = 1;
				end
				//R-type end here
				ADDU: begin
					RegWrite = 1;
					RegDst = 1;
					MemtoReg = 0;//ALU To register
				end
				ADDIU: begin
					RegWrite = 1;
					RegDst = 0;
					MemtoReg = 0;
				end
			endcase
			
		end
		else if(state==WRITE_BACK) begin
			RegWrite = 1;
			case(final_code)
				//R U 1.Loading data to reg or 2.ALUOut to reg
				LW: begin
					RegDst = 0; //depends on the format of the mips
					MemtoReg = 1; //memory To register
				end

				
			endcase
		end
	end
endmodule : control_signal_simplified