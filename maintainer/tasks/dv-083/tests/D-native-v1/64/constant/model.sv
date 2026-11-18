`timescale 1ns/1ps
module dvbench_model #(parameter associativity=1, sets=512, bytes_per_line=16, base_address=0, limit=0)
(input clk_i,rst_i,stall_a,stall_x,stall_m,input [31:0] address_x,address_m,input load_q_m,store_q_m,
 input [31:0] store_data,input [3:0] store_byte_select,input refill_ready,input [31:0] refill_data,input dflush,
 output stall_request,output reg restart_request,refill_request,output reg [31:0] refill_address,output reg refilling,output [31:0] load_data);

 assign stall_request=0;assign load_data=0;initial begin restart_request=0;refill_request=0;refill_address=0;refilling=0;end
endmodule
