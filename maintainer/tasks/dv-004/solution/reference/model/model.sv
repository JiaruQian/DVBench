`timescale 1ns/1ps
module dvbench_model(
  input logic [32:0] auto_in_0_a_bits_address,
  input logic auto_in_0_a_bits_corrupt,
  input logic [63:0] auto_in_0_a_bits_data,
  input logic [7:0] auto_in_0_a_bits_mask,
  input logic [2:0] auto_in_0_a_bits_opcode,
  input logic [2:0] auto_in_0_a_bits_param,
  input logic [3:0] auto_in_0_a_bits_size,
  input logic [3:0] auto_in_0_a_bits_source,
  output logic auto_in_0_a_ready,
  input logic auto_in_0_a_valid,
  output logic auto_in_0_d_bits_corrupt,
  output logic [63:0] auto_in_0_d_bits_data,
  output logic auto_in_0_d_bits_denied,
  output logic [2:0] auto_in_0_d_bits_opcode,
  output logic [1:0] auto_in_0_d_bits_param,
  output logic [1:0] auto_in_0_d_bits_sink,
  output logic [3:0] auto_in_0_d_bits_size,
  output logic [3:0] auto_in_0_d_bits_source,
  input logic auto_in_0_d_ready,
  output logic auto_in_0_d_valid,
  input logic [32:0] auto_in_1_a_bits_address,
  input logic auto_in_1_a_bits_corrupt,
  input logic [63:0] auto_in_1_a_bits_data,
  input logic [7:0] auto_in_1_a_bits_mask,
  input logic [2:0] auto_in_1_a_bits_opcode,
  input logic [2:0] auto_in_1_a_bits_param,
  input logic [3:0] auto_in_1_a_bits_size,
  input logic [4:0] auto_in_1_a_bits_source,
  output logic auto_in_1_a_ready,
  input logic auto_in_1_a_valid,
  output logic [32:0] auto_in_1_b_bits_address,
  output logic [1:0] auto_in_1_b_bits_param,
  input logic auto_in_1_b_ready,
  output logic auto_in_1_b_valid,
  input logic [32:0] auto_in_1_c_bits_address,
  input logic auto_in_1_c_bits_corrupt,
  input logic [63:0] auto_in_1_c_bits_data,
  input logic [2:0] auto_in_1_c_bits_opcode,
  input logic [2:0] auto_in_1_c_bits_param,
  input logic [3:0] auto_in_1_c_bits_size,
  input logic [4:0] auto_in_1_c_bits_source,
  output logic auto_in_1_c_ready,
  input logic auto_in_1_c_valid,
  output logic auto_in_1_d_bits_corrupt,
  output logic [63:0] auto_in_1_d_bits_data,
  output logic auto_in_1_d_bits_denied,
  output logic [2:0] auto_in_1_d_bits_opcode,
  output logic [1:0] auto_in_1_d_bits_param,
  output logic [1:0] auto_in_1_d_bits_sink,
  output logic [3:0] auto_in_1_d_bits_size,
  output logic [4:0] auto_in_1_d_bits_source,
  input logic auto_in_1_d_ready,
  output logic auto_in_1_d_valid,
  input logic [1:0] auto_in_1_e_bits_sink,
  input logic auto_in_1_e_valid,
  output logic [32:0] auto_out_0_a_bits_address,
  output logic auto_out_0_a_bits_corrupt,
  output logic [63:0] auto_out_0_a_bits_data,
  output logic [7:0] auto_out_0_a_bits_mask,
  output logic [2:0] auto_out_0_a_bits_opcode,
  output logic [2:0] auto_out_0_a_bits_param,
  output logic [3:0] auto_out_0_a_bits_size,
  output logic [3:0] auto_out_0_a_bits_source,
  input logic auto_out_0_a_ready,
  output logic auto_out_0_a_valid,
  input logic auto_out_0_d_bits_corrupt,
  input logic [63:0] auto_out_0_d_bits_data,
  input logic auto_out_0_d_bits_denied,
  input logic [2:0] auto_out_0_d_bits_opcode,
  input logic [1:0] auto_out_0_d_bits_param,
  input logic [1:0] auto_out_0_d_bits_sink,
  input logic [3:0] auto_out_0_d_bits_size,
  input logic [3:0] auto_out_0_d_bits_source,
  output logic auto_out_0_d_ready,
  input logic auto_out_0_d_valid,
  output logic [32:0] auto_out_1_a_bits_address,
  output logic auto_out_1_a_bits_corrupt,
  output logic [63:0] auto_out_1_a_bits_data,
  output logic [7:0] auto_out_1_a_bits_mask,
  output logic [2:0] auto_out_1_a_bits_opcode,
  output logic [2:0] auto_out_1_a_bits_param,
  output logic [3:0] auto_out_1_a_bits_size,
  output logic [4:0] auto_out_1_a_bits_source,
  input logic auto_out_1_a_ready,
  output logic auto_out_1_a_valid,
  input logic [32:0] auto_out_1_b_bits_address,
  input logic [1:0] auto_out_1_b_bits_param,
  output logic auto_out_1_b_ready,
  input logic auto_out_1_b_valid,
  output logic [32:0] auto_out_1_c_bits_address,
  output logic auto_out_1_c_bits_corrupt,
  output logic [63:0] auto_out_1_c_bits_data,
  output logic [2:0] auto_out_1_c_bits_opcode,
  output logic [2:0] auto_out_1_c_bits_param,
  output logic [3:0] auto_out_1_c_bits_size,
  output logic [4:0] auto_out_1_c_bits_source,
  input logic auto_out_1_c_ready,
  output logic auto_out_1_c_valid,
  input logic auto_out_1_d_bits_corrupt,
  input logic [63:0] auto_out_1_d_bits_data,
  input logic auto_out_1_d_bits_denied,
  input logic [2:0] auto_out_1_d_bits_opcode,
  input logic [1:0] auto_out_1_d_bits_param,
  input logic [1:0] auto_out_1_d_bits_sink,
  input logic [3:0] auto_out_1_d_bits_size,
  input logic [4:0] auto_out_1_d_bits_source,
  output logic auto_out_1_d_ready,
  input logic auto_out_1_d_valid,
  output logic [1:0] auto_out_1_e_bits_sink,
  output logic auto_out_1_e_valid,
  input logic clock,
  input logic reset
);
  assign auto_in_0_a_ready = auto_out_0_a_ready;
  assign auto_in_0_d_bits_corrupt = auto_out_0_d_bits_corrupt;
  assign auto_in_0_d_bits_data = auto_out_0_d_bits_data;
  assign auto_in_0_d_bits_denied = auto_out_0_d_bits_denied;
  assign auto_in_0_d_bits_opcode = auto_out_0_d_bits_opcode;
  assign auto_in_0_d_bits_param = auto_out_0_d_bits_param;
  assign auto_in_0_d_bits_sink = auto_out_0_d_bits_sink;
  assign auto_in_0_d_bits_size = auto_out_0_d_bits_size;
  assign auto_in_0_d_bits_source = auto_out_0_d_bits_source;
  assign auto_in_0_d_valid = auto_out_0_d_valid;
  assign auto_in_1_a_ready = auto_out_1_a_ready;
  assign auto_in_1_b_bits_address = auto_out_1_b_bits_address;
  assign auto_in_1_b_bits_param = auto_out_1_b_bits_param;
  assign auto_in_1_b_valid = auto_out_1_b_valid;
  assign auto_in_1_c_ready = auto_out_1_c_ready;
  assign auto_in_1_d_bits_corrupt = auto_out_1_d_bits_corrupt;
  assign auto_in_1_d_bits_data = auto_out_1_d_bits_data;
  assign auto_in_1_d_bits_denied = auto_out_1_d_bits_denied;
  assign auto_in_1_d_bits_opcode = auto_out_1_d_bits_opcode;
  assign auto_in_1_d_bits_param = auto_out_1_d_bits_param;
  assign auto_in_1_d_bits_sink = auto_out_1_d_bits_sink;
  assign auto_in_1_d_bits_size = auto_out_1_d_bits_size;
  assign auto_in_1_d_bits_source = auto_out_1_d_bits_source;
  assign auto_in_1_d_valid = auto_out_1_d_valid;
  assign auto_out_0_a_bits_address = auto_in_0_a_bits_address;
  assign auto_out_0_a_bits_corrupt = auto_in_0_a_bits_corrupt;
  assign auto_out_0_a_bits_data = auto_in_0_a_bits_data;
  assign auto_out_0_a_bits_mask = auto_in_0_a_bits_mask;
  assign auto_out_0_a_bits_opcode = auto_in_0_a_bits_opcode;
  assign auto_out_0_a_bits_param = auto_in_0_a_bits_param;
  assign auto_out_0_a_bits_size = auto_in_0_a_bits_size;
  assign auto_out_0_a_bits_source = auto_in_0_a_bits_source;
  assign auto_out_0_a_valid = auto_in_0_a_valid;
  assign auto_out_0_d_ready = auto_in_0_d_ready;
  assign auto_out_1_a_bits_address = auto_in_1_a_bits_address;
  assign auto_out_1_a_bits_corrupt = auto_in_1_a_bits_corrupt;
  assign auto_out_1_a_bits_data = auto_in_1_a_bits_data;
  assign auto_out_1_a_bits_mask = auto_in_1_a_bits_mask;
  assign auto_out_1_a_bits_opcode = auto_in_1_a_bits_opcode;
  assign auto_out_1_a_bits_param = auto_in_1_a_bits_param;
  assign auto_out_1_a_bits_size = auto_in_1_a_bits_size;
  assign auto_out_1_a_bits_source = auto_in_1_a_bits_source;
  assign auto_out_1_a_valid = auto_in_1_a_valid;
  assign auto_out_1_b_ready = auto_in_1_b_ready;
  assign auto_out_1_c_bits_address = auto_in_1_c_bits_address;
  assign auto_out_1_c_bits_corrupt = auto_in_1_c_bits_corrupt;
  assign auto_out_1_c_bits_data = auto_in_1_c_bits_data;
  assign auto_out_1_c_bits_opcode = auto_in_1_c_bits_opcode;
  assign auto_out_1_c_bits_param = auto_in_1_c_bits_param;
  assign auto_out_1_c_bits_size = auto_in_1_c_bits_size;
  assign auto_out_1_c_bits_source = auto_in_1_c_bits_source;
  assign auto_out_1_c_valid = auto_in_1_c_valid;
  assign auto_out_1_d_ready = auto_in_1_d_ready;
  assign auto_out_1_e_bits_sink = auto_in_1_e_bits_sink;
  assign auto_out_1_e_valid = auto_in_1_e_valid;
endmodule
