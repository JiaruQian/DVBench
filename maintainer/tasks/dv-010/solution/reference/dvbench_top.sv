`timescale 1ns/1ps
module dvbench_top;
  import uvm_pkg::*;
  import hpa_pkg::*;
  logic clock=0;
  always #5 clock=~clock;
  hpa_if vif(clock);
  HellaPeekingArbiter dut (
    .clock(vif.clock),
    .reset(vif.reset),
    .io_in_1_ready(vif.io_in_1_ready),
    .io_in_1_valid(vif.io_in_1_valid),
    .io_in_1_bits_opcode(vif.io_in_1_bits_opcode),
    .io_in_1_bits_param(vif.io_in_1_bits_param),
    .io_in_1_bits_size(vif.io_in_1_bits_size),
    .io_in_1_bits_source(vif.io_in_1_bits_source),
    .io_in_1_bits_data(vif.io_in_1_bits_data),
    .io_in_1_bits_corrupt(vif.io_in_1_bits_corrupt),
    .io_in_1_bits_union(vif.io_in_1_bits_union),
    .io_in_1_bits_last(vif.io_in_1_bits_last),
    .io_in_4_ready(vif.io_in_4_ready),
    .io_in_4_valid(vif.io_in_4_valid),
    .io_in_4_bits_opcode(vif.io_in_4_bits_opcode),
    .io_in_4_bits_param(vif.io_in_4_bits_param),
    .io_in_4_bits_size(vif.io_in_4_bits_size),
    .io_in_4_bits_source(vif.io_in_4_bits_source),
    .io_in_4_bits_address(vif.io_in_4_bits_address),
    .io_in_4_bits_data(vif.io_in_4_bits_data),
    .io_in_4_bits_corrupt(vif.io_in_4_bits_corrupt),
    .io_in_4_bits_union(vif.io_in_4_bits_union),
    .io_in_4_bits_last(vif.io_in_4_bits_last),
    .io_out_ready(vif.io_out_ready),
    .io_out_valid(vif.io_out_valid),
    .io_out_bits_chanId(vif.io_out_bits_chanId),
    .io_out_bits_opcode(vif.io_out_bits_opcode),
    .io_out_bits_param(vif.io_out_bits_param),
    .io_out_bits_size(vif.io_out_bits_size),
    .io_out_bits_source(vif.io_out_bits_source),
    .io_out_bits_address(vif.io_out_bits_address),
    .io_out_bits_data(vif.io_out_bits_data),
    .io_out_bits_corrupt(vif.io_out_bits_corrupt),
    .io_out_bits_union(vif.io_out_bits_union),
    .io_out_bits_last(vif.io_out_bits_last)
  );
  dvbench_model model (
    .clock(vif.clock),
    .reset(vif.reset),
    .io_in_1_ready(vif.expected_io_in_1_ready),
    .io_in_1_valid(vif.io_in_1_valid),
    .io_in_1_bits_opcode(vif.io_in_1_bits_opcode),
    .io_in_1_bits_param(vif.io_in_1_bits_param),
    .io_in_1_bits_size(vif.io_in_1_bits_size),
    .io_in_1_bits_source(vif.io_in_1_bits_source),
    .io_in_1_bits_data(vif.io_in_1_bits_data),
    .io_in_1_bits_corrupt(vif.io_in_1_bits_corrupt),
    .io_in_1_bits_union(vif.io_in_1_bits_union),
    .io_in_1_bits_last(vif.io_in_1_bits_last),
    .io_in_4_ready(vif.expected_io_in_4_ready),
    .io_in_4_valid(vif.io_in_4_valid),
    .io_in_4_bits_opcode(vif.io_in_4_bits_opcode),
    .io_in_4_bits_param(vif.io_in_4_bits_param),
    .io_in_4_bits_size(vif.io_in_4_bits_size),
    .io_in_4_bits_source(vif.io_in_4_bits_source),
    .io_in_4_bits_address(vif.io_in_4_bits_address),
    .io_in_4_bits_data(vif.io_in_4_bits_data),
    .io_in_4_bits_corrupt(vif.io_in_4_bits_corrupt),
    .io_in_4_bits_union(vif.io_in_4_bits_union),
    .io_in_4_bits_last(vif.io_in_4_bits_last),
    .io_out_ready(vif.io_out_ready),
    .io_out_valid(vif.expected_io_out_valid),
    .io_out_bits_chanId(vif.expected_io_out_bits_chanId),
    .io_out_bits_opcode(vif.expected_io_out_bits_opcode),
    .io_out_bits_param(vif.expected_io_out_bits_param),
    .io_out_bits_size(vif.expected_io_out_bits_size),
    .io_out_bits_source(vif.expected_io_out_bits_source),
    .io_out_bits_address(vif.expected_io_out_bits_address),
    .io_out_bits_data(vif.expected_io_out_bits_data),
    .io_out_bits_corrupt(vif.expected_io_out_bits_corrupt),
    .io_out_bits_union(vif.expected_io_out_bits_union),
    .io_out_bits_last(vif.expected_io_out_bits_last)
  );
  initial begin
    vif.reset=0;
    vif.io_in_1_valid=0;
    vif.io_in_1_bits_opcode=0;
    vif.io_in_1_bits_param=0;
    vif.io_in_1_bits_size=0;
    vif.io_in_1_bits_source=0;
    vif.io_in_1_bits_data=0;
    vif.io_in_1_bits_corrupt=0;
    vif.io_in_1_bits_union=0;
    vif.io_in_1_bits_last=0;
    vif.io_in_4_valid=0;
    vif.io_in_4_bits_opcode=0;
    vif.io_in_4_bits_param=0;
    vif.io_in_4_bits_size=0;
    vif.io_in_4_bits_source=0;
    vif.io_in_4_bits_address=0;
    vif.io_in_4_bits_data=0;
    vif.io_in_4_bits_corrupt=0;
    vif.io_in_4_bits_union=0;
    vif.io_in_4_bits_last=0;
    vif.io_out_ready=0;
    vif.reset=1;
    uvm_config_db#(virtual hpa_if)::set(null,"*","vif",vif);
    run_test("dvbench_test");
  end
endmodule
