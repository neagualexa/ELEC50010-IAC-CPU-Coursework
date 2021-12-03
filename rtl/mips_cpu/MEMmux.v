module MEMmux (
    input logic [31:0]PC,
    input logic IorD,
    input logic[31:0] ALUOut,
    input logic[5:0] opcode,
    output logic[3:0] byteenable,
    output logic[31:0] address
);
  typedef enum logic[5:0] {
		//load/store
	LB	= 6'b100000,
	LH 	= 6'b100001,
	LWL	= 6'b100010,
	LW 	= 6'b100011,
	LBU	= 6'b100100,
	LHU	= 6'b100101,
	LWR = 6'b100110,
	SB  = 6'b101000,
	SH	= 6'b101001,
	SW 	= 6'b101011
  } memory_reference_opcode_list;
  assign address = (IorD == 0) ? PC : {ALUOut[31:2],2'b00}; //MEMmux2to1
    
	assign byteenable = (IorD == 0)? 4'b1111:
            (opcode == LW || opcode == SW)? 4'b1111:
            (ALUOut[1:0]==2'b00)?  4'b0001:
            (ALUOut[1:0]==2'b01)?  4'b0010:
            (ALUOut[1:0]==2'b10)?  4'b0100:
            (ALUOut[1:0]==2'b11)?  4'b1000:4'bxxxx; 

endmodule