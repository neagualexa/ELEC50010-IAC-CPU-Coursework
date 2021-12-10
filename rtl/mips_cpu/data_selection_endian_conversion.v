module data_selection_endian_conversion (
  //Address Input
  input logic IorD,
  input logic [31:0]PC,
  input logic[31:0] ALUOut,

  input logic[5:0] opcode,
  input logic[31:0] writedata_non_processed, //reg B (rt)
  input logic[31:0] readdata_non_processed,

  output logic[31:0] writedata_processed,
  output logic[31:0] readdata_processed,
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

  always @(*) begin
    if(IorD == 0) begin
      byteenable = 4'b1111;
      readdata_processed[7:0] = readdata_non_processed[31:24];
      readdata_processed[15:8] = readdata_non_processed[23:16];
      readdata_processed[23:16] = readdata_non_processed[15:8];
      readdata_processed[31:24] = readdata_non_processed[7:0];
    end
    else begin
      case(opcode)
    LW,SW: begin
      byteenable = 4'b1111;
      writedata_processed[7:0] = writedata_non_processed[31:24];
      writedata_processed[15:8] = writedata_non_processed[23:16];
      writedata_processed[23:16] = writedata_non_processed[15:8];
      writedata_processed[31:24] = writedata_non_processed[7:0];

      readdata_processed[7:0] = readdata_non_processed[31:24];
      readdata_processed[15:8] = readdata_non_processed[23:16];
      readdata_processed[23:16] = readdata_non_processed[15:8];
      readdata_processed[31:24] = readdata_non_processed[7:0];
    end
    LB,SB: begin
      if(ALUOut[1:0]==2'b00) begin
        byteenable = 4'b0001;
        writedata_processed[7:0] = writedata_non_processed[7:0];  
        readdata_processed = readdata_non_processed[7:0]; 
      end
      else if(ALUOut[1:0]==2'b01) begin
        byteenable = 4'b0010;
        writedata_processed[15:8] = writedata_non_processed[7:0];
        readdata_processed = readdata_non_processed[15:8];
      end
      else if(ALUOut[1:0]==2'b10) begin
        byteenable = 4'b0100;
        writedata_processed[23:16] = writedata_non_processed[7:0];
        readdata_processed = readdata_non_processed[23:16];
      end
      else if(ALUOut[1:0]==2'b11) begin
        byteenable = 4'b1000;
        writedata_processed[31:24] = writedata_non_processed[7:0];
        readdata_processed = readdata_non_processed[31:24];
      end   
    end
    LBU: begin
      if(ALUOut[1:0]==2'b00) begin
        byteenable = 4'b0001; 
        readdata_processed = {24'b0,readdata_non_processed[7:0]}; 
      end
      else if(ALUOut[1:0]==2'b01) begin
        byteenable = 4'b0010;
        readdata_processed = {24'b0,readdata_non_processed[15:8]};
      end
      else if(ALUOut[1:0]==2'b10) begin
        byteenable = 4'b0100;
        readdata_processed = {24'b0,readdata_non_processed[23:16]};
      end
      else if(ALUOut[1:0]==2'b11) begin
        byteenable = 4'b1000;
        readdata_processed = {24'b0,readdata_non_processed[31:24]};
      end 
    end
    LH,SH: begin
      if(ALUOut[1:0]==0) begin
        byteenable = 4'b0011;
        writedata_processed[7:0] = writedata_non_processed[15:8];
        writedata_processed[15:8] = writedata_non_processed[7:0];
        //readdata_processed[7:0] = readdata_non_processed[15:8];
        //readdata_processed[15:8] = readdata_non_processed[7:0];
        readdata_processed = {readdata_non_processed[7:0],readdata_non_processed[15:8]};//hopfully it perform sign extend
      end
      else if(ALUOut[1:0]==2'b10) begin
        byteenable = 4'b1100;
        writedata_processed[23:16] = writedata_non_processed[15:8];
        writedata_processed[31:24] = writedata_non_processed[7:0];
        //readdata_processed[7:0] = readdata_non_processed[31:24];
        //readdata_processed[15:8] = readdata_non_processed[23:16];
        readdata_processed = {readdata_non_processed[23:16],readdata_non_processed[31:24]};
      end 
    end
    LHU: begin
      if(ALUOut[1:0]==2'b00) begin
        byteenable = 4'b0011;
        //readdata_processed[7:0] = readdata_non_processed[15:8];
        //readdata_processed[15:8] = readdata_non_processed[7:0];
        readdata_processed = {16'b0,readdata_non_processed[7:0],readdata_non_processed[15:8]};
      end
      else if(ALUOut[1:0]==2'b10) begin
        byteenable = 4'b1100;
        //readdata_processed[7:0] = readdata_non_processed[31:24];
        //readdata_processed[15:8] = readdata_non_processed[23:16];
        readdata_processed = {16'b0,readdata_non_processed[23:16],readdata_non_processed[31:24]};
      end 
    end
    LWL: begin
      if(ALUOut[1:0]==2'b00) begin
        byteenable = 4'b1111; 
        readdata_processed[7:0] = readdata_non_processed[31:24]; //invert
        readdata_processed[15:8] = readdata_non_processed[23:16];
        readdata_processed[23:16] = readdata_non_processed[15:8];
        readdata_processed[31:24] = readdata_non_processed[7:0];
      end
      if(ALUOut[1:0]==2'b01) begin
        byteenable = 4'b1110;
        readdata_processed[7:0] = writedata_non_processed[7:0]; 
        readdata_processed[15:8] = readdata_non_processed[31:24];//invert
        readdata_processed[23:16] = readdata_non_processed[23:16];
        readdata_processed[31:24] = readdata_non_processed[15:8];
      end
      if(ALUOut[1:0]==2'b10) begin
        byteenable = 4'b1100;
        readdata_processed[7:0] = writedata_non_processed[7:0];
        readdata_processed[15:8] = writedata_non_processed[15:8];
        readdata_processed[23:16] = readdata_non_processed[31:24]; //invert
        readdata_processed[31:24] = readdata_non_processed[23:16];
      end
      if(ALUOut[1:0]==2'b11) begin
        byteenable = 4'b1000;
        readdata_processed[7:0] = writedata_non_processed[7:0]; 
        readdata_processed[15:8] = writedata_non_processed[15:8]; 
        readdata_processed[23:16] = writedata_non_processed[23:16]; 
        readdata_processed[31:24] = readdata_non_processed[31:24];//invert
      end
    end
    LWR: begin
      if(ALUOut[1:0]==0) begin
        byteenable = 4'b0001; 
        readdata_processed[7:0] = readdata_non_processed[7:0];// 
        readdata_processed[15:8] = writedata_non_processed[15:8]; 
        readdata_processed[23:16] = writedata_non_processed[23:16]; 
        readdata_processed[31:24] = writedata_non_processed[31:24];
      end
      if(ALUOut[1:0]==1) begin
        byteenable = 4'b0011;
        readdata_processed[7:0] = readdata_non_processed[15:8];// 
        readdata_processed[15:8] = readdata_non_processed[7:0];//invert
        readdata_processed[23:16] = writedata_non_processed[23:16];
        readdata_processed[31:24] = writedata_non_processed[31:24];
      end
      if(ALUOut[1:0]==2) begin
        byteenable = 4'b0111;
        readdata_processed[7:0] = readdata_non_processed[23:16];//
        readdata_processed[15:8] = readdata_non_processed[15:8];//
        readdata_processed[23:16] = readdata_non_processed[7:0];//
        readdata_processed[31:24] = writedata_non_processed[31:24];
      end
      if(ALUOut[1:0]==3) begin
        byteenable = 4'b1111;
        readdata_processed[7:0] = readdata_non_processed[31:24]; //invert
        readdata_processed[15:8] = readdata_non_processed[23:16];
        readdata_processed[23:16] = readdata_non_processed[15:8];
        readdata_processed[31:24] = readdata_non_processed[7:0];
      end
    end
    endcase  
    end
  end

endmodule