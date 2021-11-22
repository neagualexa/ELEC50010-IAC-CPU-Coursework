module register_kevin (
	input logic[31:0] register[31:0]	
);
	logic count;
	initial begin
		count = 0;
		repeat (32) begin
			register[count] = 0;
			count = count + 1;
		end
	end
	



endmodule : register_kevin