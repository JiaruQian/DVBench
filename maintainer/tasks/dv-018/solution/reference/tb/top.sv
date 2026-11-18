`timescale 1ns/1ps
module dvbench_top;
`include "uvm_macros.svh"
import uvm_pkg::*;
import dvbench_pkg::*;
dvbench_if bus();
logic  clock;
logic [7:0] rd_data;
logic  rd_last;
logic  rd_ready;
logic  rd_vld;
logic  rst_n;
logic  wr_align_last;
logic [3:0] wr_data;
logic  wr_last;
logic  wr_ready;
logic  wr_vld;
logic [7:0] predicted_rd_data;
logic  predicted_rd_last;
logic  predicted_rd_vld;
logic  predicted_wr_ready;
assign {clock, rd_ready, rst_n, wr_align_last, wr_data, wr_last, wr_vld} = bus.input_state;
assign bus.actual_state = {rd_data, rd_last, rd_vld, wr_ready};
assign bus.expected_state = {predicted_rd_data, predicted_rd_last, predicted_rd_vld, predicted_wr_ready};
width_convert #(.ISIZE(4),.OSIZE(8)) dut(.clock(clock),.rd_data(rd_data),.rd_last(rd_last),.rd_ready(rd_ready),.rd_vld(rd_vld),.rst_n(rst_n),.wr_align_last(wr_align_last),.wr_data(wr_data),.wr_last(wr_last),.wr_ready(wr_ready),.wr_vld(wr_vld));
dvbench_model #(.ISIZE(4),.OSIZE(8)) predictor(.clock(clock),.rd_data(predicted_rd_data),.rd_last(predicted_rd_last),.rd_ready(rd_ready),.rd_vld(predicted_rd_vld),.rst_n(rst_n),.wr_align_last(wr_align_last),.wr_data(wr_data),.wr_last(wr_last),.wr_ready(predicted_wr_ready),.wr_vld(wr_vld));
always_comb begin
bus.compare_mask='1;
end
always @(posedge clock or negedge rst_n) begin #3; ->bus.sample_ready; end
initial begin
    uvm_config_db#(virtual dvbench_if)::set(null,"*","vif",bus);
    run_test("dvbench_test");
end
initial begin #1000000; `uvm_fatal("WATCHDOG","Reference did not terminate") end
endmodule
