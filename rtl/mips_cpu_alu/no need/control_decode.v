module control_decode(
input logic [5:0] op,
input logic [2:0] state,
input logic [5:0] function_code,
output logic PCwrite, MemRead, MemWrite, IorD, PCWriteCond, MemtoReg, ALUSrcA, RegWrite, RegDst, IRWrite,
output logic [1:0] ALUSrcB, PCSource,
output logic [3:0] ALUOp
);

always @(op) begin
    PCwrite <= 0;
    MemRead <= 0;
    MemWrite <= 0;
    IorD <= 0;
    PCWriteCond <= 0;
    MemtoReg <= 0;
    IRWrite <= 0;
    RegDst <= 0;
    RegWrite <= 0;
    ALUSrcA <= 1;
    ALUSrcB <= 0;
    ALUOp <= 0;
    PCSource <= 0;
    case (op)
        6'b000000: case (state)
                        3'b000 : MemRead <= 1,//RegWrite <= 1, PCWrite <= 1;general ALU op r-type is 1
                        3'b001 : IRWrite <= 1,
                        3'b010 :
                        3'b011 : PCSrc <= 2'b10 //For jr, what if ADDU? then pcsrc needs to be different
                        3'b100 : PCWrite <= 1, RegWrite <= 1
        6'b001001: case (state) 
                        3'b000 : MemRead <= 1
                        3'b001 : IRWrite <= 1
                        3'b010 : ALUSrcB <= 2'b10
                        3'b011 : PCSrc <=
                        3'b100 : PCWrite <= 1//ALUSrcB <= 2'b10; //ADDIU
        6'b100011: case (state)
                        3'b000 : MemRead <= 1
                        3'b001 : IRWrite <= 1, IorD <= 1,
                        3'b010 : MemRead <= 1, ALUSrcB <= 2'b10
                        3'b011 : MemtoReg <= 1, PCSrc <=
                        3'b100 : PCWrite <= 1, RegWrite <= 1, //RegWrite <= 1, RegDst <= 0, MemtoReg <= 1, MemRead <= 1, ALUSrcB <= 2'b10; //LW
        6'b101011: case (state)
                        3'b000 : MemRead <= 1
                        3'b001 :
                        3'b010 : MemWrite <= 1, ALUSrcB <= 2'b10
                        3'b011 : PCSrc <=
                        3'b100 : PCWrite <= 1//MemWrite <= 1, ALUSrcB <= 2'b10, ; //SW
    endcase
    
end





endmodule

// addiu, addu, jr, lw, sw
// Signals which are a set value for atleat one cycle on state IRWrite, MemRead, PCWrite