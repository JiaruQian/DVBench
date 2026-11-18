`timescale 1ns/1ps
module dvbench_model(
  input logic clk,
  input logic [5:0] ctrl_alu_fn_i,
  input logic [7:0] ctrl_reg_idxw_i,
  input logic ctrl_reverse_i,
  input logic [2:0] ctrl_wid_i,
  input logic ctrl_wvd_i,
  input logic ctrl_wxd_i,
  input logic [127:0] in1_i,
  input logic [127:0] in2_i,
  input logic [127:0] in3_i,
  output logic in_ready_o,
  input logic in_valid_i,
  input logic [3:0] mask_i,
  input logic outv_ready_i,
  output logic [7:0] outv_reg_idxw_o,
  output logic outv_valid_o,
  output logic [2:0] outv_warp_id_o,
  output logic [127:0] outv_wb_wxd_rd_o,
  output logic [3:0] outv_wvd_mask_o,
  output logic outv_wvd_o,
  input logic outx_ready_i,
  output logic [7:0] outx_reg_idwx_o,
  output logic outx_valid_o,
  output logic [2:0] outx_warp_id_o,
  output logic [31:0] outx_wb_wxd_rd_o,
  output logic outx_wxd_o,
  input logic rst_n
);

  typedef struct packed {
    logic [127:0] values;
    logic [3:0] mask;
    logic [2:0] warp;
    logic [7:0] destination;
    logic vector_write,scalar_write;
  } result_record;
  result_record first_metadata,second_result,scalar_buffer,vector_buffer;
  logic [5:0] first_function;
  logic [127:0] first_addend;
  logic first_valid,second_valid,scalar_full,vector_full;
  logic scalar_capacity,vector_capacity,sink_capacity,advance_first,advance_second;
  logic push_scalar,push_vector,pop_scalar,pop_vector;
  logic [31:0] left_operand[4],right_operand[4],add_operand[4],left_magnitude[4],right_magnitude[4];
  logic [63:0] delayed_magnitude[4],corrected_product[4],mac_value[4];
  logic negative_left[4],negative_right[4];
  logic [127:0] computed_values;
  always_comb begin
    scalar_capacity=!scalar_full || outx_ready_i;
    vector_capacity=!vector_full || outv_ready_i;
    sink_capacity=second_result.scalar_write ? scalar_capacity : vector_capacity;
    in_ready_o=!(first_valid && second_valid && !sink_capacity);
    advance_first=in_valid_i && in_ready_o;
    advance_second=first_valid && (!second_valid || sink_capacity);
    push_scalar=second_valid && second_result.scalar_write && scalar_capacity;
    push_vector=second_valid && second_result.vector_write && vector_capacity;
    pop_scalar=scalar_full && outx_ready_i;
    pop_vector=vector_full && outv_ready_i;
    for(int lane=0;lane<4;lane++) begin
      left_operand[lane]=ctrl_reverse_i ? in2_i[lane*32+:32] : in1_i[lane*32+:32];
      right_operand[lane]=ctrl_reverse_i ? in1_i[lane*32+:32] : in2_i[lane*32+:32];
      add_operand[lane]=in3_i[lane*32+:32];
      if(ctrl_alu_fn_i==26 || ctrl_alu_fn_i==27) begin
        add_operand[lane]=left_operand[lane]; left_operand[lane]=in3_i[lane*32+:32];
      end
      negative_left[lane]=(ctrl_alu_fn_i==21 || ctrl_alu_fn_i==23) && left_operand[lane][31];
      negative_right[lane]=ctrl_alu_fn_i==21 && right_operand[lane][31];
      left_magnitude[lane]=negative_left[lane] ? -left_operand[lane] : left_operand[lane];
      right_magnitude[lane]=negative_right[lane] ? -right_operand[lane] : right_operand[lane];
      corrected_product[lane]=(negative_left[lane] ^ negative_right[lane]) ? -delayed_magnitude[lane] : delayed_magnitude[lane];
      mac_value[lane]=(first_function==24 || first_function==26) ? corrected_product[lane]+{32'b0,first_addend[lane*32+:32]} : {32'b0,first_addend[lane*32+:32]}-corrected_product[lane];
      if(first_function[4:2]==6) computed_values[lane*32+:32]=mac_value[lane][31:0];
      else if(first_function==21 || first_function==22 || first_function==23) computed_values[lane*32+:32]=corrected_product[lane][63:32];
      else computed_values[lane*32+:32]=corrected_product[lane][31:0];
    end
    outx_valid_o=scalar_full; outv_valid_o=vector_full;
    outx_wb_wxd_rd_o=scalar_buffer.values[31:0]; outx_wxd_o=scalar_buffer.scalar_write;
    outx_reg_idwx_o=scalar_buffer.destination; outx_warp_id_o=scalar_buffer.warp;
    outv_wb_wxd_rd_o=vector_buffer.values; outv_wvd_o=vector_buffer.vector_write;
    outv_wvd_mask_o=vector_buffer.mask; outv_reg_idxw_o=vector_buffer.destination; outv_warp_id_o=vector_buffer.warp;
  end
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      first_metadata<='0;second_result<='0;scalar_buffer<='0;vector_buffer<='0;
      first_function<=0;first_addend<=0;first_valid<=0;second_valid<=0;scalar_full<=0;vector_full<=0;
      for(int lane=0;lane<4;lane++) delayed_magnitude[lane]<=0;
    end
    else begin
      for(int lane=0;lane<4;lane++) delayed_magnitude[lane]<={32'b0,left_magnitude[lane]}*{32'b0,right_magnitude[lane]};
      if(in_ready_o) first_valid<=in_valid_i;
      if(!second_valid || sink_capacity) second_valid<=first_valid;
      if(advance_first) begin
        first_metadata.mask<=mask_i; first_metadata.warp<=ctrl_wid_i; first_metadata.destination<=ctrl_reg_idxw_i;
        first_metadata.vector_write<=ctrl_wvd_i; first_metadata.scalar_write<=ctrl_wxd_i;
        first_function<=ctrl_alu_fn_i;
        for(int lane=0;lane<4;lane++) first_addend[lane*32+:32]<=add_operand[lane];
      end
      if(advance_second) begin
        second_result<=first_metadata; second_result.values<=computed_values;
      end
      if(push_scalar) scalar_buffer<=second_result;
      if(push_vector) vector_buffer<=second_result;
      scalar_full<=(scalar_full && !pop_scalar) || push_scalar;
      vector_full<=(vector_full && !pop_vector) || push_vector;
    end
  end
endmodule
