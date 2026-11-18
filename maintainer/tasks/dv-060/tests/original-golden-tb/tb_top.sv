// tb_top.sv — directory_controller_stage3 UVM top level
// dut_a: Default parameters TILE_ID=0/TILE_MEMORY_ID=0 (cycle-by-cycle comparison of all outputs)
// dut_b: TILE_ID=2/TILE_MEMORY_ID=15 (F08 parameter dimension, same stimulus, cycle-by-cycle comparison with a parameterized predictor)
`timescale 1ns/1ps

module tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  dc3_if vif();

  directory_controller_stage3 #(
    .TILE_ID       (0),
    .TILE_MEMORY_ID(0)
  ) dut_a (
    .clk(vif.clk),
    .reset(vif.reset),

    .ni_forwarded_request_network_available(vif.ni_forwarded_request_network_available),
    .instr_request_pending(vif.instr_request_pending),
    .instr_request_address(vif.instr_request_address),
    .dc2_message_valid(vif.dc2_message_valid),
    .dc2_message_type(vif.dc2_message_type),
    .dc2_message_address(vif.dc2_message_address),
    .dc2_message_data(vif.dc2_message_data),
    .dc2_message_source(vif.dc2_message_source),
    .dc2_replacement_state(vif.dc2_replacement_state),
    .dc2_replacement_sharers_list(vif.dc2_replacement_sharers_list),
    .dc2_replacement_owner(vif.dc2_replacement_owner),
    .dc2_message_tshr_hit(vif.dc2_message_tshr_hit),
    .dc2_message_tshr_index(vif.dc2_message_tshr_index),
    .dc2_message_tshr_entry_info(vif.dc2_message_tshr_entry_info),
    .dc2_message_cache_hit(vif.dc2_message_cache_hit),
    .dc2_message_cache_valid(vif.dc2_message_cache_valid),
    .dc2_message_cache_state(vif.dc2_message_cache_state),
    .dc2_message_cache_sharers_list(vif.dc2_message_cache_sharers_list),
    .dc2_message_cache_owner(vif.dc2_message_cache_owner),
    .dc2_message_cache_tag(vif.dc2_message_cache_tag),
    .dc2_message_cache_data(vif.dc2_message_cache_data),
    .dc2_message_cache_way(vif.dc2_message_cache_way),
    .tshr_empty_index(vif.tshr_empty_index),

    .dc3_instr_request_dequeue(vif.dc3_instr_request_dequeue_a),
    .dc3_pending(vif.dc3_pending_a),
    .dc3_pending_address(vif.dc3_pending_address_a),
    .dc3_update_cache_enable(vif.dc3_update_cache_enable_a),
    .dc3_update_cache_validity_bit(vif.dc3_update_cache_validity_bit_a),
    .dc3_update_cache_set(vif.dc3_update_cache_set_a),
    .dc3_update_cache_way(vif.dc3_update_cache_way_a),
    .dc3_update_cache_tag(vif.dc3_update_cache_tag_a),
    .dc3_update_cache_state(vif.dc3_update_cache_state_a),
    .dc3_update_cache_sharers_list(vif.dc3_update_cache_sharers_list_a),
    .dc3_update_cache_owner(vif.dc3_update_cache_owner_a),
    .dc3_update_cache_data(vif.dc3_update_cache_data_a),
    .dc3_update_plru_en(vif.dc3_update_plru_en_a),
    .dc3_update_plru_set(vif.dc3_update_plru_set_a),
    .dc3_update_plru_way(vif.dc3_update_plru_way_a),
    .dc3_update_tshr_enable(vif.dc3_update_tshr_enable_a),
    .dc3_update_tshr_index(vif.dc3_update_tshr_index_a),
    .dc3_update_tshr_entry_info(vif.dc3_update_tshr_entry_info_a),
    .dc3_replacement_enqueue(vif.dc3_replacement_enqueue_a),
    .dc3_replacement_request(vif.dc3_replacement_request_a),
    .dc3_wb_enable(vif.dc3_wb_enable_a),
    .dc3_wb_data(vif.dc3_wb_data_a),
    .dc3_wb_addr(vif.dc3_wb_addr_a),
    .dc3_forwarded_request(vif.dc3_forwarded_request_a),
    .dc3_forwarded_request_valid(vif.dc3_forwarded_request_valid_a),
    .dc3_forwarded_request_destinations(vif.dc3_forwarded_request_destinations_a),
    .dc3_response(vif.dc3_response_a),
    .dc3_response_valid(vif.dc3_response_valid_a),
    .dc3_response_has_data(vif.dc3_response_has_data_a),
    .dc3_response_destinations(vif.dc3_response_destinations_a)
  );

  directory_controller_stage3 #(
    .TILE_ID       (2),
    .TILE_MEMORY_ID(15)
  ) dut_b (
    .clk(vif.clk),
    .reset(vif.reset),

    .ni_forwarded_request_network_available(vif.ni_forwarded_request_network_available),
    .instr_request_pending(vif.instr_request_pending),
    .instr_request_address(vif.instr_request_address),
    .dc2_message_valid(vif.dc2_message_valid),
    .dc2_message_type(vif.dc2_message_type),
    .dc2_message_address(vif.dc2_message_address),
    .dc2_message_data(vif.dc2_message_data),
    .dc2_message_source(vif.dc2_message_source),
    .dc2_replacement_state(vif.dc2_replacement_state),
    .dc2_replacement_sharers_list(vif.dc2_replacement_sharers_list),
    .dc2_replacement_owner(vif.dc2_replacement_owner),
    .dc2_message_tshr_hit(vif.dc2_message_tshr_hit),
    .dc2_message_tshr_index(vif.dc2_message_tshr_index),
    .dc2_message_tshr_entry_info(vif.dc2_message_tshr_entry_info),
    .dc2_message_cache_hit(vif.dc2_message_cache_hit),
    .dc2_message_cache_valid(vif.dc2_message_cache_valid),
    .dc2_message_cache_state(vif.dc2_message_cache_state),
    .dc2_message_cache_sharers_list(vif.dc2_message_cache_sharers_list),
    .dc2_message_cache_owner(vif.dc2_message_cache_owner),
    .dc2_message_cache_tag(vif.dc2_message_cache_tag),
    .dc2_message_cache_data(vif.dc2_message_cache_data),
    .dc2_message_cache_way(vif.dc2_message_cache_way),
    .tshr_empty_index(vif.tshr_empty_index),

    .dc3_instr_request_dequeue(vif.dc3_instr_request_dequeue_b),
    .dc3_pending(vif.dc3_pending_b),
    .dc3_pending_address(vif.dc3_pending_address_b),
    .dc3_update_cache_enable(vif.dc3_update_cache_enable_b),
    .dc3_update_cache_validity_bit(vif.dc3_update_cache_validity_bit_b),
    .dc3_update_cache_set(vif.dc3_update_cache_set_b),
    .dc3_update_cache_way(vif.dc3_update_cache_way_b),
    .dc3_update_cache_tag(vif.dc3_update_cache_tag_b),
    .dc3_update_cache_state(vif.dc3_update_cache_state_b),
    .dc3_update_cache_sharers_list(vif.dc3_update_cache_sharers_list_b),
    .dc3_update_cache_owner(vif.dc3_update_cache_owner_b),
    .dc3_update_cache_data(vif.dc3_update_cache_data_b),
    .dc3_update_plru_en(vif.dc3_update_plru_en_b),
    .dc3_update_plru_set(vif.dc3_update_plru_set_b),
    .dc3_update_plru_way(vif.dc3_update_plru_way_b),
    .dc3_update_tshr_enable(vif.dc3_update_tshr_enable_b),
    .dc3_update_tshr_index(vif.dc3_update_tshr_index_b),
    .dc3_update_tshr_entry_info(vif.dc3_update_tshr_entry_info_b),
    .dc3_replacement_enqueue(vif.dc3_replacement_enqueue_b),
    .dc3_replacement_request(vif.dc3_replacement_request_b),
    .dc3_wb_enable(vif.dc3_wb_enable_b),
    .dc3_wb_data(vif.dc3_wb_data_b),
    .dc3_wb_addr(vif.dc3_wb_addr_b),
    .dc3_forwarded_request(vif.dc3_forwarded_request_b),
    .dc3_forwarded_request_valid(vif.dc3_forwarded_request_valid_b),
    .dc3_forwarded_request_destinations(vif.dc3_forwarded_request_destinations_b),
    .dc3_response(vif.dc3_response_b),
    .dc3_response_valid(vif.dc3_response_valid_b),
    .dc3_response_has_data(vif.dc3_response_has_data_b),
    .dc3_response_destinations(vif.dc3_response_destinations_b)
  );

  initial begin
    uvm_config_db#(virtual dc3_if)::set(null, "*", "vif", vif);
    run_test("t_main");   // Default comprehensive test (acceptance does not pass +UVM_TESTNAME)
  end

endmodule
