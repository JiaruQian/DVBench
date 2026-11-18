`timescale 1ns/1ps
module dvbench_model(
  input logic clock,
  input logic reset,
  output logic io_in_1_ready,
  input logic io_in_1_valid,
  input logic [2:0] io_in_1_bits_opcode,
  input logic [2:0] io_in_1_bits_param,
  input logic [7:0] io_in_1_bits_size,
  input logic [7:0] io_in_1_bits_source,
  input logic [63:0] io_in_1_bits_data,
  input logic io_in_1_bits_corrupt,
  input logic [8:0] io_in_1_bits_union,
  input logic io_in_1_bits_last,
  output logic io_in_4_ready,
  input logic io_in_4_valid,
  input logic [2:0] io_in_4_bits_opcode,
  input logic [2:0] io_in_4_bits_param,
  input logic [7:0] io_in_4_bits_size,
  input logic [7:0] io_in_4_bits_source,
  input logic [63:0] io_in_4_bits_address,
  input logic [63:0] io_in_4_bits_data,
  input logic io_in_4_bits_corrupt,
  input logic [8:0] io_in_4_bits_union,
  input logic io_in_4_bits_last,
  input logic io_out_ready,
  output logic io_out_valid,
  output logic [2:0] io_out_bits_chanId,
  output logic [2:0] io_out_bits_opcode,
  output logic [2:0] io_out_bits_param,
  output logic [7:0] io_out_bits_size,
  output logic [7:0] io_out_bits_source,
  output logic [63:0] io_out_bits_address,
  output logic [63:0] io_out_bits_data,
  output logic io_out_bits_corrupt,
  output logic [8:0] io_out_bits_union,
  output logic io_out_bits_last
);
  typedef enum logic [1:0] {AVAILABLE, PACKET_ONE, PACKET_FOUR} ownership_t;
  ownership_t ownership;
  logic select_one;
  always_comb select_one = (ownership == PACKET_ONE) || ((ownership == AVAILABLE) && io_in_1_valid);
  always @(posedge clock) begin
    if (reset) ownership <= AVAILABLE;
    else if (io_out_ready && (select_one ? io_in_1_valid : io_in_4_valid)) begin
      if (select_one ? io_in_1_bits_last : io_in_4_bits_last) ownership <= AVAILABLE;
      else if (select_one) ownership <= PACKET_ONE;
      else ownership <= PACKET_FOUR;
    end
  end
  assign io_in_1_ready = io_out_ready && select_one;
  assign io_in_4_ready = io_out_ready && !select_one;
  assign io_out_valid = select_one ? io_in_1_valid : io_in_4_valid;
  assign io_out_bits_chanId = select_one ? 3'd3 : 3'd0;
  assign io_out_bits_address = select_one ? 64'd0 : io_in_4_bits_address;
  assign io_out_bits_opcode = select_one ? io_in_1_bits_opcode : io_in_4_bits_opcode;
  assign io_out_bits_param = select_one ? io_in_1_bits_param : io_in_4_bits_param;
  assign io_out_bits_size = select_one ? io_in_1_bits_size : io_in_4_bits_size;
  assign io_out_bits_source = select_one ? io_in_1_bits_source : io_in_4_bits_source;
  assign io_out_bits_data = select_one ? io_in_1_bits_data : io_in_4_bits_data;
  assign io_out_bits_corrupt = select_one ? io_in_1_bits_corrupt : io_in_4_bits_corrupt;
  assign io_out_bits_union = select_one ? io_in_1_bits_union : io_in_4_bits_union;
  assign io_out_bits_last = select_one ? io_in_1_bits_last : io_in_4_bits_last;
endmodule
