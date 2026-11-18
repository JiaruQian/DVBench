`timescale 1ns/1ps
module replay_tb;import dvbench_stim::*;
logic clk_i;
logic rst_ni;
logic instr_req_i;
logic instr_gnt_o;
logic [31:0] instr_addr_i;
logic instr_rvalid_o;
logic [31:0] instr_rdata_o;
logic flush_i;
logic flush_ack_o;
logic mem_req_valid_o;
logic [31:0] mem_req_addr_o;
logic [7:0] mem_req_len_o;
logic [2:0] mem_req_size_o;
logic mem_req_ack_i;
logic mem_rsp_valid_i;
logic [255:0] mem_rsp_data_i;
logic mem_rsp_last_i;
logic miss_o;
logic miss_event_o;
logic [293:0] pins;
assign {rst_ni,instr_req_i,instr_addr_i,flush_i,mem_req_ack_i,mem_rsp_valid_i,mem_rsp_data_i,mem_rsp_last_i}=pins;
REPLAY_TARGET dut(.clk_i(clk_i),.rst_ni(rst_ni),.instr_req_i(instr_req_i),.instr_gnt_o(instr_gnt_o),.instr_addr_i(instr_addr_i),.instr_rvalid_o(instr_rvalid_o),.instr_rdata_o(instr_rdata_o),.flush_i(flush_i),.flush_ack_o(flush_ack_o),.mem_req_valid_o(mem_req_valid_o),.mem_req_addr_o(mem_req_addr_o),.mem_req_len_o(mem_req_len_o),.mem_req_size_o(mem_req_size_o),.mem_req_ack_i(mem_req_ack_i),.mem_rsp_valid_i(mem_rsp_valid_i),.mem_rsp_data_i(mem_rsp_data_i),.mem_rsp_last_i(mem_rsp_last_i),.miss_o(miss_o),.miss_event_o(miss_event_o));
initial begin clk_i=0;forever #5 clk_i=~clk_i;end
initial begin int seed;if(!$value$plusargs("ntb_random_seed=%d",seed))seed=1;
for(int k=0;k<4200;k++)begin @(negedge clk_i);pins=sample_pins(k,seed);#2;$display("HISTORY %h",pins);$display("TRACE %h",{instr_gnt_o,instr_rvalid_o,instr_rdata_o,flush_ack_o,mem_req_valid_o,mem_req_addr_o,mem_req_len_o,mem_req_size_o,miss_o,miss_event_o});@(posedge clk_i);#2;$display("HISTORY %h",pins);$display("TRACE %h",{instr_gnt_o,instr_rvalid_o,instr_rdata_o,flush_ack_o,mem_req_valid_o,mem_req_addr_o,mem_req_len_o,mem_req_size_o,miss_o,miss_event_o});end
$display("REPLAY_COMPLETED");$finish;end
endmodule
