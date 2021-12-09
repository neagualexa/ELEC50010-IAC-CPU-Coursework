module ram_tiny_CPU (
    input logic clk,
    input logic[31:0] address,
    input logic[3:0] byteenable,
    input logic write,
    input logic read,
    input logic[31:0] writedata,
    output logic waitrequest,
    output logic[31:0] readdata
);

    //parameter RAM_DATA_FILE = "../../testbenches/addiu_1.txt";
    parameter RAM_INIT_FILE = "./INITIALISED_FILE.txt";

//must change the size of memory to e4*10^6
    reg [31:0] memory [65535:0];

    initial begin
        integer i;
        /* Initialise to zero by default */
        for (i=0; i<100; i++) begin
            memory[i]=0;
        end

        //Load contents from file if specified
        if (RAM_INIT_FILE != "") begin
            $display("RAM : INIT : Loading RAM contents from %s", RAM_INIT_FILE);
            //$readmemh(RAM_DATA_FILE, memory);
            $readmemh(RAM_INIT_FILE, memory);
        end
        
    end
    

    always @(*) begin
    	$display("ram: read = %b, wordaddress = %h, readdata = %h", read, word_address, readdata);
    end
    

    logic[31:0] word_address;
    assign word_address = (address-32'hbfc00000)/4;

    logic[31:0] writedata_temp, readdata_temp_shift, readdata_temp;
    logic[7:0] readdata_3, readdata_2, readdata_1, readdata_0;

    assign readdata_temp = memory[word_address];

    assign readdata_3 = (byteenable[3] == 1) ? readdata_temp[7:0] : 8'h00;
    assign readdata_2 = (byteenable[2] ==1) ? readdata_temp[15:8] : 8'h00;
    assign readdata_1 = (byteenable[1] ==1) ? readdata_temp[23:16] : 8'h00;
    assign readdata_0 = (byteenable[0] ==1) ? readdata_temp[31:24] : 8'h00;

    
    logic[7:0] writedata_3, writedata_2, writedata_1, writedata_0;


    assign writedata_3 = (byteenable[3]) ? writedata[7:0] : readdata_temp[31:24];
    assign writedata_2 = (byteenable[2]) ? writedata[15:8] : readdata_temp[23:16];
    assign writedata_1 = (byteenable[1]) ? writedata[23:16] : readdata_temp[15:8];
    assign writedata_0 = (byteenable[0]) ? writedata[31:24] : readdata_temp[7:0];

    /*if (byteenable[3]) begin
        assign writedata_3 = writedata[31:24];
    end
    else begin
        assign writedata_3 = readdata_temp[31:24];
    end
    if (byteenable[2]) begin
        assign writedata_2 = writedata[23:16];
    end
    else begin
        assign writedata_2 = readdata_temp[23:16];
    end
    if (byteenable[1]) begin
        assign writedata_1 = writedata[15:8];
    end
    else begin
        assign writedata_1 = readdata_temp[15:8];
    end
    if (byteenable[0]) begin
        assign writedata_0 = writedata[7:0];
    end
    else begin
        assign writedata_0 = readdata_temp[7:0];
    end*/




    /* synchronous read path. */
    
    always_ff @(posedge clk) begin
        //$display("RAM : INFO : read=%h, addr = %h, mem=%h", read, address, memory[address]);
        //waitrequest <= $urandom_range(0, 1);
        waitrequest <= 0;
        if (waitrequest) begin 
            readdata <= 32'hxxxxxxxx;
        end
        else if (write) begin

            memory[word_address] <= {writedata_3, writedata_2, writedata_1, writedata_0};
        end
        else if(read) begin
            //$display("Im reading, address = %h", address);
            readdata <= {readdata_3, readdata_2, readdata_1, readdata_0};
        end
    end
endmodule
