// directory_controller_stage3_if.sv — DC stage3 interface: single clock (integer half-period), self-managed reset
// Types come from $unit (under -mfcu, backfill is compiled first, and npu_* typedefs are globally visible)
`timescale 1ns/1ps
`include "npu_coherence_defines.sv"

interface dc3_if ();

  // ---- DUT inputs (driven by driver via cb_drv) ----
  logic                                       ni_forwarded_request_network_available;
  logic                                       instr_request_pending;
  address_t                                   instr_request_address;
  logic                                       dc2_message_valid;
  logic [`DIRECTORY_MESSAGE_TYPE_WIDTH-1:0]   dc2_message_type;
  l2_cache_address_t                          dc2_message_address;
  dcache_line_t                               dc2_message_data;
  tile_address_t                              dc2_message_source;
  logic [`DIRECTORY_STATE_WIDTH-1:0]          dc2_replacement_state;
  logic [`TILE_COUNT-1:0]                     dc2_replacement_sharers_list;
  tile_address_t                              dc2_replacement_owner;
  logic                                       dc2_message_tshr_hit;
  tshr_idx_t                                  dc2_message_tshr_index;
  tshr_entry_t                                dc2_message_tshr_entry_info;
  logic                                       dc2_message_cache_hit;
  logic                                       dc2_message_cache_valid;
  logic [`DIRECTORY_STATE_WIDTH-1:0]          dc2_message_cache_state;
  logic [`TILE_COUNT-1:0]                     dc2_message_cache_sharers_list;
  tile_address_t                              dc2_message_cache_owner;
  l2_cache_tag_t                              dc2_message_cache_tag;
  dcache_line_t                               dc2_message_cache_data;
  l2_cache_way_idx_t                          dc2_message_cache_way;
  tshr_idx_t                                  tshr_empty_index;

  // ---- Instance A (TILE_ID=0/TILE_MEMORY_ID=0 default parameters) outputs ----
  logic                                       dc3_instr_request_dequeue_a;
  logic                                       dc3_pending_a;
  logic [31:0]                                dc3_pending_address_a;
  logic                                       dc3_update_cache_enable_a;
  logic                                       dc3_update_cache_validity_bit_a;
  logic [6:0]                                 dc3_update_cache_set_a;
  logic [2:0]                                 dc3_update_cache_way_a;
  logic [18:0]                                dc3_update_cache_tag_a;
  logic [`DIRECTORY_STATE_WIDTH-1:0]          dc3_update_cache_state_a;
  logic [`TILE_COUNT-1:0]                     dc3_update_cache_sharers_list_a;
  tile_address_t                              dc3_update_cache_owner_a;
  dcache_line_t                               dc3_update_cache_data_a;
  logic                                       dc3_update_plru_en_a;
  logic [6:0]                                 dc3_update_plru_set_a;
  logic [2:0]                                 dc3_update_plru_way_a;
  logic                                       dc3_update_tshr_enable_a;
  tshr_idx_t                                  dc3_update_tshr_index_a;
  tshr_entry_t                                dc3_update_tshr_entry_info_a;
  logic                                       dc3_replacement_enqueue_a;
  logic [$bits(replacement_request_t)-1:0]    dc3_replacement_request_a;
  logic                                       dc3_wb_enable_a;
  dcache_line_t                               dc3_wb_data_a;
  logic [31:0]                                dc3_wb_addr_a;
  logic [$bits(coherence_forwarded_message_t)-1:0] dc3_forwarded_request_a;
  logic                                       dc3_forwarded_request_valid_a;
  logic [`TILE_COUNT-1:0]                     dc3_forwarded_request_destinations_a;
  logic [$bits(coherence_response_message_t)-1:0]  dc3_response_a;
  logic                                       dc3_response_valid_a;
  logic                                       dc3_response_has_data_a;
  logic [`TILE_COUNT-1:0]                     dc3_response_destinations_a;

  // ---- Instance B (TILE_ID=2/TILE_MEMORY_ID=15 parameter variant) outputs ----
  logic                                       dc3_instr_request_dequeue_b;
  logic                                       dc3_pending_b;
  logic [31:0]                                dc3_pending_address_b;
  logic                                       dc3_update_cache_enable_b;
  logic                                       dc3_update_cache_validity_bit_b;
  logic [6:0]                                 dc3_update_cache_set_b;
  logic [2:0]                                 dc3_update_cache_way_b;
  logic [18:0]                                dc3_update_cache_tag_b;
  logic [`DIRECTORY_STATE_WIDTH-1:0]          dc3_update_cache_state_b;
  logic [`TILE_COUNT-1:0]                     dc3_update_cache_sharers_list_b;
  tile_address_t                              dc3_update_cache_owner_b;
  dcache_line_t                               dc3_update_cache_data_b;
  logic                                       dc3_update_plru_en_b;
  logic [6:0]                                 dc3_update_plru_set_b;
  logic [2:0]                                 dc3_update_plru_way_b;
  logic                                       dc3_update_tshr_enable_b;
  tshr_idx_t                                  dc3_update_tshr_index_b;
  tshr_entry_t                                dc3_update_tshr_entry_info_b;
  logic                                       dc3_replacement_enqueue_b;
  logic [$bits(replacement_request_t)-1:0]    dc3_replacement_request_b;
  logic                                       dc3_wb_enable_b;
  dcache_line_t                               dc3_wb_data_b;
  logic [31:0]                                dc3_wb_addr_b;
  logic [$bits(coherence_forwarded_message_t)-1:0] dc3_forwarded_request_b;
  logic                                       dc3_forwarded_request_valid_b;
  logic [`TILE_COUNT-1:0]                     dc3_forwarded_request_destinations_b;
  logic [$bits(coherence_response_message_t)-1:0]  dc3_response_b;
  logic                                       dc3_response_valid_b;
  logic                                       dc3_response_has_data_b;
  logic [`TILE_COUNT-1:0]                     dc3_response_destinations_b;

  // Clock: integer half-period (real delays trigger analog-style scheduling, ~300× slower)
  int unsigned half = 3;   // Period 6ns
  logic clk = 0;
  initial forever #(half) clk = ~clk;

  // Self-managed reset (exclusively driven by the interface; test injects F06 via pulse_reset)
  logic reset = 1;
  initial begin
    repeat (5) @(negedge clk);
    reset = 0;
  end
  task pulse_reset(int unsigned n = 4);
    @(negedge clk);      // Align to negedge to avoid a race with posedge clk (wb_en asynchronous reset)
    reset = 1;
    repeat (n) @(negedge clk);
    reset = 0;
  endtask

  // Initial input values (zeroed at t0 to avoid X during sampling)
  initial begin
    ni_forwarded_request_network_available = 0;
    instr_request_pending                  = 0;
    instr_request_address                  = '0;
    dc2_message_valid                      = 0;
    dc2_message_type                       = '0;
    dc2_message_address                    = '0;
    dc2_message_data                       = '0;
    dc2_message_source                     = '0;
    dc2_replacement_state                  = '0;
    dc2_replacement_sharers_list           = '0;
    dc2_replacement_owner                  = '0;
    dc2_message_tshr_hit                   = 0;
    dc2_message_tshr_index                 = '0;
    dc2_message_tshr_entry_info            = '0;
    dc2_message_cache_hit                  = 0;
    dc2_message_cache_valid                = 0;
    dc2_message_cache_state                = '0;
    dc2_message_cache_sharers_list         = '0;
    dc2_message_cache_owner                = '0;
    dc2_message_cache_tag                  = '0;
    dc2_message_cache_data                 = '0;
    dc2_message_cache_way                  = '0;
    tshr_empty_index                       = '0;
  end

  // Driving side: output at posedge (skew 1ns); DUT combinational outputs have stabilized when sampled at negedge
  clocking cb_drv @(posedge clk);
    default input #1step output #1;
    output ni_forwarded_request_network_available,
           instr_request_pending, instr_request_address,
           dc2_message_valid, dc2_message_type, dc2_message_address,
           dc2_message_data, dc2_message_source,
           dc2_replacement_state, dc2_replacement_sharers_list, dc2_replacement_owner,
           dc2_message_tshr_hit, dc2_message_tshr_index, dc2_message_tshr_entry_info,
           dc2_message_cache_hit, dc2_message_cache_valid, dc2_message_cache_state,
           dc2_message_cache_sharers_list, dc2_message_cache_owner, dc2_message_cache_tag,
           dc2_message_cache_data, dc2_message_cache_way,
           tshr_empty_index;
  endclocking

  // Observation side: sample raw signals at negedge (= DUT inputs for the current cycle and stabilized combinational outputs; wb registers hold values loaded in the previous cycle)
  clocking cb_mon @(negedge clk);
    default input #1step;
    input reset;
    input ni_forwarded_request_network_available,
          instr_request_pending, instr_request_address,
          dc2_message_valid, dc2_message_type, dc2_message_address,
          dc2_message_data, dc2_message_source,
          dc2_replacement_state, dc2_replacement_sharers_list, dc2_replacement_owner,
          dc2_message_tshr_hit, dc2_message_tshr_index, dc2_message_tshr_entry_info,
          dc2_message_cache_hit, dc2_message_cache_valid, dc2_message_cache_state,
          dc2_message_cache_sharers_list, dc2_message_cache_owner, dc2_message_cache_tag,
          dc2_message_cache_data, dc2_message_cache_way,
          tshr_empty_index;
    input dc3_instr_request_dequeue_a, dc3_pending_a, dc3_pending_address_a,
          dc3_update_cache_enable_a, dc3_update_cache_validity_bit_a,
          dc3_update_cache_set_a, dc3_update_cache_way_a, dc3_update_cache_tag_a,
          dc3_update_cache_state_a, dc3_update_cache_sharers_list_a,
          dc3_update_cache_owner_a, dc3_update_cache_data_a,
          dc3_update_plru_en_a, dc3_update_plru_set_a, dc3_update_plru_way_a,
          dc3_update_tshr_enable_a, dc3_update_tshr_index_a, dc3_update_tshr_entry_info_a,
          dc3_replacement_enqueue_a, dc3_replacement_request_a,
          dc3_wb_enable_a, dc3_wb_data_a, dc3_wb_addr_a,
          dc3_forwarded_request_a, dc3_forwarded_request_valid_a,
          dc3_forwarded_request_destinations_a,
          dc3_response_a, dc3_response_valid_a, dc3_response_has_data_a,
          dc3_response_destinations_a;
    input dc3_instr_request_dequeue_b, dc3_pending_b, dc3_pending_address_b,
          dc3_update_cache_enable_b, dc3_update_cache_validity_bit_b,
          dc3_update_cache_set_b, dc3_update_cache_way_b, dc3_update_cache_tag_b,
          dc3_update_cache_state_b, dc3_update_cache_sharers_list_b,
          dc3_update_cache_owner_b, dc3_update_cache_data_b,
          dc3_update_plru_en_b, dc3_update_plru_set_b, dc3_update_plru_way_b,
          dc3_update_tshr_enable_b, dc3_update_tshr_index_b, dc3_update_tshr_entry_info_b,
          dc3_replacement_enqueue_b, dc3_replacement_request_b,
          dc3_wb_enable_b, dc3_wb_data_b, dc3_wb_addr_b,
          dc3_forwarded_request_b, dc3_forwarded_request_valid_b,
          dc3_forwarded_request_destinations_b,
          dc3_response_b, dc3_response_valid_b, dc3_response_has_data_b,
          dc3_response_destinations_b;
  endclocking

endinterface
