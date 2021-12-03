// jr addu addui lw sw
module control_signal_simplified (
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
	output logic IRWrite,
	output logic unsign,
	output logic fixed_shift,
	output logic[3:0] byteenable // added a new output byteenable 11/28 (would be use in memory access state)
);

	//logic[5:0] final_code;

	typedef enum logic[3:0] {
        ADD 					= 4'b0000,
        LOGICAL_AND 			= 4'b0001,
        SUBTRACT 				= 4'b0010,
        SET_GREATER_OR_EQUAL	= 4'b0011,
		SET_ON_GREATER_THAN 	= 4'b0100,
		SET_LESS_OR_EQUAL 		= 4'b0101,
        SET_ON_LESS_THAN 		= 4'b0110,
		MULTIPLY 				= 4'b0111,
		DIVIDE 					= 4'b1000,
        LOGICAL_OR 				= 4'b1001,
		LOGICAL_XOR 			= 4'b1010,
		SHIFT_LEFT 				= 4'b1011,
		SHIFT_RIGHT 			= 4'b1100,
		SHIFT_RIGHT_SIGNED 		= 4'b1101
	} ALUOperation_t;

	typedef enum logic[2:0]{
        FETCH_INSTR 			= 3'b000,
        DECODE 					= 3'b001,
        EXECUTE 				= 3'b010,
        MEMORY_ACCESS 			= 3'b011,
        WRITE_BACK 				= 3'b100
    } state_t;
	
	typedef enum logic[5:0] {
		//R Type - func_code
		ADDU 	= 6'b100001,
		AND		= 6'b100100, 
		DIV		= 6'b011010,
		DIVU	= 6'b011011,
		MULT	= 6'b011000,
		MULTU	= 6'b011001,
		OR		= 6'b100101,
		SUBU	= 6'b100011,
		XOR		= 6'b100110,

		MTHI	= 6'b010001,
		MTLO	= 6'b010011,

		SLL		= 6'b000000,
		SLLV	= 6'b000100,
		SLT 	= 6'b101010,
		SLTU	= 6'b101011,
		SRA		= 6'b000011,
		SRAV	= 6'b000111,
		SRL		= 6'b000010,
		SRLV	= 6'b000110,

		JALR	= 6'b001001
	} func_code_list;

	typedef enum logic[5:0] {
		//I Types - opcode
		ADDIU 	= 6'b001001,
		SLTI 	= 6'b001010,
		SLTIU 	= 6'b001011,
		ANDI 	= 6'b001100,
		ORI 	= 6'b001101,
		XORI 	= 6'b001110,

		//load/store
		LUI		= 6'b001111,
		LB		= 6'b100000,
		LH 		= 6'b100001,
		LWL		= 6'b100010,
		LW 		= 6'b100011,
		LBU		= 6'b100100,
		LHU		= 6'b100101,
		LWR		= 6'b100110,
		SB      = 6'b101000,
		SH		= 6'b101001,
		SW 		= 6'b101011,
		//Jumps
		JR 		= 6'b001000
	} opcode_list;

	//assign final_code = (opcode==0) ? func_code : opcode;
	//assign final_code = (opcode==1) ? rt[4:0] : opcode; //BLTZ, BGEZ, BLTZAL, BGEZAL
	
	initial begin //Initiate block
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
		fixed_shift = 0;
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

			MemRead = 0;  
			IRWrite = 1;  // is 1 in  DECODE stage	
		end
		else if(state==EXECUTE) begin
			//Branch/JUMP instruction should be completed in the stage
			//ALU related operation, so it could be R or I-type
			//final-code should be opcode for I-type/J-type and function-code for R-type 
			//write LO and HI if needed : MTHI,MTLO,DIV,DIVU,MULT,MULTU
			if (opcode == 0) begin
				case(func_code)
					//arithmetic purpose operation
					
					//R-ALU-TYPE
					ADDU: begin //u here is a misnomer => no overflow check but A or B are signed
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 0;
						ALUctl = ADD;
					end

					AND: begin 							//might need to be change
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 0;
						ALUctl = LOGICAL_AND;
					end
					
					DIV: begin // sign number
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 0;
						ALUctl = DIVIDE;
					end

					DIVU: begin // u mean treat A and B as unsign number
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 1;
						ALUctl = DIVIDE;
					end

					MULT: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 0;
						ALUctl = MULTIPLY;
					end

					MULTU: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 1;
						ALUctl = MULTIPLY;
					end

					OR: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 0;
						ALUctl = LOGICAL_OR;	
					end

					XOR: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 0;
						ALUctl = LOGICAL_XOR;
					end

					SUBU: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 1;
						ALUctl = SUBTRACT;
					end

					SLT: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 0;
						ALUctl = SET_ON_LESS_THAN;
					end

					SLTU: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						unsign = 1;
						ALUctl = SET_ON_LESS_THAN;
					end

					SLL: begin 							
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						fixed_shift = 1;
						ALUctl = SHIFT_LEFT;
						unsign = 0;
					end

					SLLV: begin 							
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						fixed_shift = 0;
						ALUctl = SHIFT_LEFT;
						unsign = 0;
					end

					SRL: begin 							
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						fixed_shift = 1;
						ALUctl = SHIFT_RIGHT;
						unsign = 0;
					end

					SRLV: begin 							
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						fixed_shift = 0;
						ALUctl = SHIFT_RIGHT;
						unsign = 0;
					end

					SRA: begin 							
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						fixed_shift = 1;
						ALUctl = SHIFT_RIGHT_SIGNED;
						unsign = 0;
					end

					SRAV: begin 							
						ALUSrcA = 1;
						ALUSrcB = 2'b00;
						fixed_shift = 0;
						ALUctl = SHIFT_RIGHT_SIGNED;
						unsign = 0;
					end

					//default: ALUctl = 4'hX;
				endcase
			end
			else if (opcode > 1) begin
				case(opcode)
					//I-TYPE
					ADDIU: begin //Put the sum of register rs and the sign-extended immediate into register rt
						ALUSrcA = 1;
						ALUSrcB = 2'b10; //picking 2 without the left-shift unit
						unsign = 0;  // u here is a misnomer
						ALUctl = ADD;
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
						ALUSrcB = 2'b10; //picking 2 without the left-shift unit (Zero-Extend)
						ALUctl = LOGICAL_AND;
					end

					ORI: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b10; //picking 2 without the left-shift unit (Zero-Extend)
						ALUctl = LOGICAL_OR;
					end

					XORI: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b10; //picking 2 without the left-shift unit (Zero-Extend)
						ALUctl = LOGICAL_XOR;
					end
					

					//LW SW(Memory reference)
					LW, SW: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b10; // shift left 2 is not needed
						//ALUSrcB = 2'b11; picking 3 with the left-shift unit => so that we an address which is div by 4
						ALUctl = ADD;
					end

					SB: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b10;
						//ALUSrcB = 2'b11;
						ALUctl = ADD;
					end

					LB: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b10;
						
					end

					LWL: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b10;
						ALUctl = ADD;
					end

					//JR (JUMPINGGGGG) ;)
					JR: begin
						ALUSrcA = 1;
						ALUSrcB = 2'b00; //picking 0: register B which should be 0. 0 register 
						// MUST ASSUME register rs is div by 4 for a good jump 
						// would make a bus check by ANDing the address from rs with hFFF0 (just cause)


						// FOR JUMP AND RELATED INSTRUCTION : BRANCH DELAYED INSTRUCTION EXECUT FIRST

						
						ALUctl = ADD;
					end
				endcase
			end 
		end
		else if(state==MEMORY_ACCESS) begin
			//fetching data and writing data
			if (opcode == 0) begin
				case(func_code)
					ADDU,SUBU: begin
						RegWrite = 1;
						RegDst = 1;
						MemtoReg = 0;//ALU To register
					end
					AND,XOR,OR: begin
						RegWrite = 1;
						RegDst = 1;
						MemtoReg = 0;
					end
					SLL, SLLV, SRL, SRLV, SRA, SRAV: begin
						RegWrite = 1;
						RegDst = 1;
						MemtoReg = 0;
					end
					SLT, SLTU: begin
						RegWrite = 1;
						RegDst = 1;
						MemtoReg = 0;
					end			
				endcase
			end
			else if (opcode == 1) begin
			//JUMP
			end
			else begin
				case(opcode)
					LW: begin //Load data to the MDR
						IorD = 1;
						MemRead = 1; 
					end

					LWL: begin //Load data on the left to unaligned word
						
					end
					
					SB: begin
						IorD = 1;
						MemWrite = 1;
					end
					
					SW: begin //store data
						IorD = 1;
						MemWrite = 1;
					end

					ADDIU: begin
						RegWrite = 1;
						RegDst = 0;
						MemtoReg = 0;
					end

					SLTI,SLTIU: begin
						RegWrite = 1;
						RegDst = 0;
						MemtoReg = 0;
					end

					ANDI,ORI,XORI: begin
						RegWrite = 1;
						RegDst = 0;
						MemtoReg = 0;
					end
		
				endcase
			end
			
		end
		else if(state==WRITE_BACK) begin
			if (opcode > 1) begin	
				case(opcode)
					//R U 1.Loading data to reg or 2.ALUOut to reg
					LW: begin
						RegWrite = 1;
						RegDst = 0; //depends on the format of the mips
						MemtoReg = 1; //memory To register
					end
				endcase
			end
		end
	end
endmodule : control_signal_simplified
