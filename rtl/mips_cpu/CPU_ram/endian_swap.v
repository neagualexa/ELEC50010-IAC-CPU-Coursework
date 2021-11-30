module endian_swap (
input logic [31:0] writedata_from_CPU,
input logic [31:0] readata_from_RAM,
output logic [31:0] writedata_to_RAM,
output logic [31:0] readata_to_CPU
);

assign writedata_to_RAM [7:0] <= writedata_from_CPU [31:24];
assign writedata_to_RAM [15:8] <= writedata_from_CPU [23:16];
assign writedata_to_RAM [23:16] <= writedata_from_CPU [15:8];
assign writedata_to_RAM [31:24] <= writedata_from_CPU [7:0];

assign readata_to_CPU [7:0] <= readata_from_RAM [31:24];
assign readata_to_CPU [15:8] <= readata_from_RAM [23:16];
assign readata_to_CPU [23:16] <= readata_from_RAM [15:8];
assign readata_to_CPU [31:24] <= readata_from_RAM [7:0];



endmodule