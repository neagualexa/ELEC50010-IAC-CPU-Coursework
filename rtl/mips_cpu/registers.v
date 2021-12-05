module registers(
    input logic clk,
    input logic reset,
    input logic RegWrite,
    input logic[4:0] readR1,
    input logic[4:0] readR2,
    input logic[4:0] writeR,
    input logic[31:0] writedata,
    output logic[31:0] readdata1,
    output logic[31:0] readdata2,
    input logic [3:0] byteenable,
    input logic [5:0] opcode,
);

    reg[31:0] register[31:0];
    assign readdata1 = register[readR1];
    assign readdata2 = register[readR2];
    logic [31:0] writedata_merged;

    typedef enum logic[5:0] {
        LUI		= 6'b001111,    
		LB		= 6'b100000,
		LH 		= 6'b100001,
		LWL		= 6'b100010,
		LW 		= 6'b100011,
		LBU		= 6'b100100,
		LHU		= 6'b100101,
		LWR		= 6'b100110
    } opcode_list;

    always @(*) begin
        //always format: xx xx xx AA
        if (opcode == LB)
            writedata_merged = (writedata[7] == 1) : {24'b1, writedata[7:0]} ? {24'b0, writedata[7:0]};
        else if (opcode == LBU)
            writedata_merged = {24'b0, writedata[7:0]};
        
        //always format: xx xx AA BB
        else if (opcode == LH)
            writedata_merged = (writedata[15] == 1) : {16'b1, writedata[15:0]} ? {16'b0, writedata[15:0]};
        else if (opcode == LHU)
            writedata_merged = {16'b0, writedata[15:0]};
    end

    always_ff @(posedge clk) begin
        integer i;

        if(reset) begin
            for(i=0; i<32; i=i+1) begin
                register[i] <= 0;
            end
        end

        else if(RegWrite) begin
            if (writedata[31:16] != 16'bXX || writedata[15:0] != 16'bXX) begin
                if (byteenable == 4'b1100) begin
                    //LWL
                    register[writeR][31:16] <= writedata[15:0];
                end
                else if (byteenable == 4'b0011) begin
                    //LWR
                    register[writeR][15:0] <= writedata[31:16];
                end 
            end
            else begin
                //LH, LHU
                if (byteenable == 4'b1100) begin
                    //always 16 bit halfword at alligned effective address => always (x*4) and (x*4+1) addresses
                    // no byteenable = 0011 (that is only possible for LWR)
                    register[writeR] <= writedata_merged;
                end
            end
            
            if (byteenable == 1 || byteenable == 2 || byteenable == 4 || byteenable == 8) begin
                //LB (byte signed extended), LBU(byte zero extended)
                if (byteenable[0] == 1) begin
                    register[writeR] <= {24'b0, writedata[7:0]};
                end
                else if (byteenable[1] == 1) begin
                    register[writeR] <= {24'b0, writedata[15:8]};
                end
                else if (byteenable[2] == 1) begin
                    register[writeR] <= {24'b0, writedata[23:16]};
                end
                else if (byteenable[3] == 1) begin
                    register[writeR] <= {24'b0, writedata[31:24]};
                end  
            end
            else begin
            	//LW, LH(2 bytes sign-extended)
            	//LHU (2 bytes zero-extended)
            	//LUI (2 bytes on top and zeros for the rest)
            	register[writeR] <= writedata;
            end
        end
    end

endmodule
