// jr addu addui lw sw
module control_signal (
	input logic[5:0] opcode,
	input logic[5:0] func_code,
	input logic[2:0] state,
	output RegDst,
	output RegWrite,
	output ALUSrcA,
	output logic[1:0] ALUSrcB,
	output logic[3:0] ALUctl,
	output logic[1:0] PCSource,
	output PCWrite,
	output PCWriteCond,
	output IorD,
	output MemRead,
	output MemWrite,
	output MemtoReg,
	output IRWrite,
	output unsign,
	output [3:0]byteenable, // added a new output byteenable 11/28 (would be use in memory access state)
);

	logic[5:0] final_code;

	typedef enum logic[3:0] {
        ADD 					= 4'b0000,
        AND 					= 4'b0001,
        SUBTRACT 				= 4'b0010,
        SET_GREATER_OR_EQUAL	= 4'b0011,
		SET_ON_GREATER_THAN 	= 4'b0100,
		SET_LESS_OR_EQUAL 		= 4'b0101,
        SET_ON_LESS_THAN 		= 4'b0110,
		MULTIPLY 				= 4'b0111,
		DIVIDE 					= 4'b1000,
        OR 						= 4'b1001,
		XOR 					= 4'b1010,
		SHIFT_LEFT 				= 4'b1011,
		SHIFT_RIGHT 			= 4'b1100,
		SHIFT_RIGHT_SIGNED 		= 4'b1101,
	} ALUOperation_t;

	typedef enum logic[2:0] {
        FETCH_INSTR 			= 3'b000,
        DECODE 					= 3'b001,
        EXECUTE 				= 3'b010,
        MEMORY_ACCESS 			= 3'b011,
        WRITE_BACK 				= 3'b100,
    } state_t;

	assign final_code = (opcode==0)? func_code : opcode;
	
	typedef enum logic[5:0] {
		//R Type
		ADDU 	= 6'b100001;
		AND		= 6'b100100;
		DIV		= 6'b011010;
		DIVU	= 6'b011011;
		MULT	= 6'b011000;
		MULTU	= 6'b011001;
		OR		= 6'b100101;
		SUBU	= 6'b100011;
		XOR		= 6'b100110;

		MTHI	= 6'b010001;
		MTLO	= 6'b010011;

		SLL		= 6'b000000;
		SLLV	= 6'b000100;
		SLT 	= 6'b101010;
		SLTU	= 6'b101011;
		SRA		= 6'b000011;
		SRAV	= 6'b000111;
		SRL		= 6'b000010;
		SRLV	= 6'b000110;

		//I Types
		ADDIU 	= 6'b001001;
		SLTI 	= 6'b001010;
		SLTIU 	= 6'b001011;
		ANDI 	= 6'b001100;
		ORI 	= 6'b001101;
		XORI 	= 6'b001110;

		//load/store
		LW 		= 6'b100011;
		SW 		= 6'b101011;

		//Jumps
		JR 		= 6'b001000;
		JALR	= 6'b001001;

	} final_code_list;
	
	initial begin
		MemRead = 0;
		MemWrite = 0;
		IRWrite = 0; 
		RegWrite = 0;
	end

	always_comb begin

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
		unsign = 0;
	// we should set everything to their default values for every instruction fetched ????????????????? make sure
		

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
			IRWrite = 0; //currently close IR

			MemRead = 0;  
			IRWrite = 1;  // is 1 in  DECODE stage	
		end
		else if(state==EXECUTE) begin
			//Branch/JUMP instruction should be completed in the stage
			//ALU related operation, so it could be R or I-type
			//final-code should be opcode for I-type/J-type and function-code for R-type 
			case(final_code):
				//arithmetic purpose operation
				
				//R-ALU-TYPE
				ADDU: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = ADD;
					unsign = 1;
				end

				AND: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = AND;
				end
				
				DIV: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = DIVIDE;
				end

				DIVU: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = DIVIDE;
					unsign = 1;
				end

				MULT: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = MULTIPLY;
				end

				MULTU: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = MULTIPLY;
					unsign = 1;
				end

				OR: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = OR;
				end

				XOR: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = XOR;
				end

				SUBU: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b00;
					ALUctl = SUBTRACT;
					unsign = 1;
				end


				//I-TYPE //R-ALU-TYPE
				ADDIU: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b10; //picking 2 without the left-shift unit
					ALUctl = ADD;
					unsign = 1;
				end

				SLTI: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b10; //picking 2 without the left-shift unit (Sign Extend)
					ALUctl = SET_ON_LESS_THAN;
				end

				SLTIU: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b10; //picking 2 without the left-shift unit (Sign Extend)
					ALUctl = SET_ON_LESS_THAN;
					unsign = 1;
				end

				ANDI: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b10; //picking 2 without the left-shift unit (Sign Extend)
					ALUctl = AND;
				end

				ORI: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b10; //picking 2 without the left-shift unit (Sign Extend)
					ALUctl = OR;
				end

				XORI: begin
					ALUSrcA = 1;
					ALUSrcB = 2'b10; //picking 2 without the left-shift unit (Sign Extend)
					ALUctl = XOR;
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

			//no need?????? RegDst and MemtoReg are already set to 0 when initialised in this state loop
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
endmodule : control_signal