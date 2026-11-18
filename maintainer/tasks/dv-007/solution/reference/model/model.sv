`timescale 1ns/1ps
module dvbench_model  (
input logic R0_addr,
input logic R0_en,
input logic R0_clk,
output logic [335:0] R0_data,
input logic W0_addr,
input logic W0_en,
input logic W0_clk,
input logic [335:0] W0_data,
input logic [335:0] W0_mask
);
logic [335:0] words [0:1];
integer bit_index;
always @(posedge W0_clk) begin
  if (W0_en) for (bit_index=0;bit_index<336;bit_index=bit_index+1)
    if (W0_mask[bit_index]) words[W0_addr][bit_index] <= W0_data[bit_index];
end
assign R0_data = R0_en ? words[R0_addr] : {336{1'bx}};
endmodule
