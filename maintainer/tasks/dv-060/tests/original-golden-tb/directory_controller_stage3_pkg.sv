// directory_controller_stage3_pkg.sv — Complete DC stage3 UVM environment
// Structure: txn / obs / ROM reference copy / combinational predictor / driver / monitor(A,B) / scoreboard(cycle-by-cycle comparison of two instances)
//       / coverage / env / seq_lib(nine-dimensional features) / tests
`timescale 1ns/1ps
`include "npu_coherence_defines.sv"

// Note: no package wrapper is used—classes are declared directly in $unit (-mfcu compilation unit) scope,
// sharing the same scope and mutual visibility with the typedefs/enums of npu_coherence_defines (VCS package scope cannot see $unit types,
// and does not support import $unit::*; testing confirmed that classes declared in $unit + UVM factory registration work correctly)
import uvm_pkg::*;
`include "uvm_macros.svh"

  `uvm_analysis_imp_decl(_a)
  `uvm_analysis_imp_decl(_b)

  // ------------------------------------------------------------------
  // Common enums / package-level variables
  // ------------------------------------------------------------------
  typedef enum int {
    PH_SWEEP, PH_SEL, PH_INSTR, PH_WB, PH_BOUND, PH_RAND
  } phase_e;

  typedef enum int { SEL_TSHR = 0, SEL_CACHE = 1, SEL_REPL = 2, SEL_N = 3 } sel_e;

  // Message destination routing (one of requestor/owner/memory/sharers)
  typedef enum int { ROUTE_REQ = 0, ROUTE_OWNER = 1, ROUTE_MEM = 2, ROUTE_SHARERS = 3 } route_e;

  phase_e cur_phase = PH_SWEEP;

  localparam int TC = `TILE_COUNT;              // 16
  localparam int MW = `DIRECTORY_MESSAGE_TYPE_WIDTH; // 5
  localparam int SW = `DIRECTORY_STATE_WIDTH;        // 3

  // ------------------------------------------------------------------
  // Transaction: snapshot of all input ports + drive cycle control
  // ------------------------------------------------------------------
  class dc3_txn extends uvm_sequence_item;

    rand logic                                       ni_avail;
    rand logic                                       instr_request_pending;
    rand address_t                                   instr_request_address;
    rand logic                                       dc2_message_valid;
    rand logic [MW-1:0]                              dc2_message_type;
    rand l2_cache_address_t                          dc2_message_address;
    rand dcache_line_t                               dc2_message_data;
    rand tile_address_t                              dc2_message_source;
    rand logic [SW-1:0]                              dc2_replacement_state;
    rand logic [TC-1:0]                              dc2_replacement_sharers_list;
    rand tile_address_t                              dc2_replacement_owner;
    rand logic                                       dc2_message_tshr_hit;
    rand tshr_idx_t                                  dc2_message_tshr_index;
    rand tshr_entry_t                                dc2_message_tshr_entry_info;
    rand logic                                       dc2_message_cache_hit;
    rand logic                                       dc2_message_cache_valid;
    rand logic [SW-1:0]                              dc2_message_cache_state;
    rand logic [TC-1:0]                              dc2_message_cache_sharers_list;
    rand tile_address_t                              dc2_message_cache_owner;
    rand l2_cache_tag_t                              dc2_message_cache_tag;
    rand dcache_line_t                               dc2_message_cache_data;
    rand l2_cache_way_idx_t                          dc2_message_cache_way;
    rand tshr_idx_t                                  tshr_empty_index;
    rand int unsigned                                hold;
    rand int unsigned                                gap;

    constraint c_def {
      dc2_message_type inside {[0:16]};
      hold == 0;
      gap == 0;
      soft ni_avail == 1;
    }

    `uvm_object_utils_begin(dc3_txn)
      `uvm_field_int(dc2_message_type, UVM_ALL_ON)
      `uvm_field_int(dc2_message_valid, UVM_ALL_ON)
      `uvm_field_int(dc2_message_tshr_hit, UVM_ALL_ON)
      `uvm_field_int(dc2_message_cache_hit, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "dc3_txn");
      super.new(name);
    endfunction

    function string mtype_str();
      return $sformatf("st-path msg=%0d src=%0d", dc2_message_type, 4'(dc2_message_source));
    endfunction
  endclass

  // ------------------------------------------------------------------
  // Observation transaction: inherited input snapshot + outputs from one side + reset flag
  // ------------------------------------------------------------------
  class dc3_obs extends dc3_txn;
    bit          reset;
    // Outputs
    logic        instr_deq;
    logic        pending;
    logic [31:0] pending_address;
    logic        tshr_en;
    logic [3:0]  tshr_idx_o;
    logic [$bits(tshr_entry_t)-1:0] tshr_e;
    logic        cache_en, cache_vbit;
    logic [6:0]  cache_set;
    logic [2:0]  cache_way;
    logic [18:0] cache_tag;
    logic [2:0]  cache_state;
    logic [TC-1:0] cache_sharers;
    logic [3:0]  cache_owner;
    logic [$bits(dcache_line_t)-1:0] cache_data;
    logic        plru_en;
    logic [6:0]  plru_set;
    logic [2:0]  plru_way;
    logic        repl_en;
    logic [$bits(replacement_request_t)-1:0] repl_req;
    logic        wb_en;
    logic [$bits(dcache_line_t)-1:0] wb_data;
    logic [31:0] wb_addr;
    logic [$bits(coherence_forwarded_message_t)-1:0] fwd;
    logic        fwd_valid;
    logic [TC-1:0] fwd_dest;
    logic [$bits(coherence_response_message_t)-1:0] resp;
    logic        resp_valid;
    logic        resp_has_data;
    logic [TC-1:0] resp_dest;

    `uvm_object_utils(dc3_obs)
    function new(string name = "dc3_obs");
      super.new(name);
    endfunction
  endclass

  // ------------------------------------------------------------------
  // ROM reference copy (port the casex table of directory_protocol_rom entry by entry)
  // ------------------------------------------------------------------
  function automatic directory_protocol_rom_entry_t dc3_rom(
      logic [SW-1:0] st, logic [MW-1:0] rq, logic fo, logic os_);
    directory_protocol_rom_entry_t o;
    o.stall                             = 1'b0;
    o.current_state_is_stable           = 1'b1;
    o.next_state_is_stable              = 1'b1;
    o.next_state                        = directory_state_t'(st);
    o.message_response_send             = 1'b0;
    o.message_response_type             = '0;
    o.message_response_has_data         = 1'b0;
    o.message_response_to_requestor     = 1'b0;
    o.message_response_to_owner         = 1'b0;
    o.message_response_to_sharers       = 1'b0;
    o.message_response_to_memory        = 1'b0;
    o.message_response_add_wb           = 1'b0;
    o.message_forwarded_send            = 1'b0;
    o.message_forwarded_type            = '0;
    o.message_forwarded_to_requestor    = 1'b0;
    o.message_forwarded_to_owner        = 1'b0;
    o.message_forwarded_to_sharers      = 1'b0;
    o.message_forwarded_to_memory       = 1'b0;
    o.sharers_add_requestor             = 1'b0;
    o.sharers_add_owner                 = 1'b0;
    o.sharers_remove_requestor          = 1'b0;
    o.sharers_clear                     = 1'b0;
    o.owner_set_requestor               = 1'b0;
    o.owner_clear                       = 1'b0;
    o.store_data                        = 1'b0;
    o.invalidate_cache_way              = 1'b0;

    casex ({st, rq, fo, os_})

      // ---------------- STATE I ----------------
      {STATE_I, REPLACEMENT, 1'b?, 1'b?}: begin
        o.message_response_send         = 1'b1;
        o.message_response_type         = MESSAGE_WB;
        o.message_response_has_data     = 1'b1;
        o.message_response_to_memory    = 1'b1;
        o.next_state                    = STATE_MN_A;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_I, MESSAGE_DIR_FLUSH, 1'b?, 1'b?}: begin
        o.message_response_send         = 1'b1;
        o.message_response_type         = MESSAGE_WB;
        o.message_response_has_data     = 1'b1;
        o.message_response_to_memory    = 1'b1;
        o.next_state                    = STATE_I;
      end
      {STATE_I, MESSAGE_GETS, 1'b?, 1'b?}: begin
        o.message_response_send         = 1'b1;
        o.message_response_type         = MESSAGE_DATA;
        o.message_response_has_data     = 1'b1;
        o.message_response_to_requestor = 1'b1;
        o.sharers_add_requestor         = 1'b1;
        o.next_state                    = STATE_S;
      end
      {STATE_I, MESSAGE_GETM, 1'b?, 1'b?}: begin
        o.message_response_send         = 1'b1;
        o.message_response_type         = MESSAGE_DATA;
        o.message_response_has_data     = 1'b1;
        o.message_response_to_requestor = 1'b1;
        o.owner_set_requestor           = 1'b1;
        o.next_state                    = STATE_M;
      end
      {STATE_I, MESSAGE_PUTS, 1'b?, 1'b0}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_I, MESSAGE_PUTS, 1'b?, 1'b1}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_I, MESSAGE_PUTM, 1'b1, 1'b?}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_I, MESSAGE_PUTM, 1'b0, 1'b?}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_I, MESSAGE_DATA, 1'b?, 1'b?}: begin
        o.stall = 1'b0; // NOT ADMITTED (no RTL side effects, debug flag only)
      end
      {STATE_I, MESSAGE_WB, 1'b?, 1'b?}: begin
      end
      {STATE_I, MESSAGE_MC_ACK, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end

      // ---------------- STATE S ----------------
      {STATE_S, REPLACEMENT, 1'b?, 1'b?}: begin
        o.message_forwarded_send        = 1'b1;
        o.message_forwarded_type        = MESSAGE_BACKINV;
        o.message_forwarded_to_sharers  = 1'b1;
        o.message_response_send         = 1'b1;
        o.message_response_type         = MESSAGE_WB;
        o.message_response_has_data     = 1'b1;
        o.message_response_to_memory    = 1'b1;
        o.next_state                    = STATE_SN_A;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_S, MESSAGE_DIR_FLUSH, 1'b?, 1'b?}: begin
        o.message_response_send         = 1'b1;
        o.message_response_type         = MESSAGE_WB;
        o.message_response_has_data     = 1'b1;
        o.message_response_to_memory    = 1'b1;
        o.next_state                    = STATE_I;
      end
      {STATE_S, MESSAGE_GETS, 1'b?, 1'b?}: begin
        o.message_response_send         = 1'b1;
        o.message_response_type         = MESSAGE_DATA;
        o.message_response_has_data     = 1'b1;
        o.message_response_to_requestor = 1'b1;
        o.sharers_add_requestor         = 1'b1;
      end
      {STATE_S, MESSAGE_GETM, 1'b?, 1'b?}: begin
        o.message_response_send         = 1'b1;
        o.message_response_type         = MESSAGE_DATA;
        o.message_response_has_data     = 1'b1;
        o.message_response_to_requestor = 1'b1;
        o.message_forwarded_send        = 1;
        o.message_forwarded_type        = MESSAGE_INV;
        o.message_forwarded_to_sharers  = 1;
        o.sharers_clear                 = 1'b1;
        o.owner_set_requestor           = 1'b1;
        o.next_state                    = STATE_M;
      end
      {STATE_S, MESSAGE_PUTS, 1'b?, 1'b0}: begin
        o.sharers_remove_requestor      = 1'b1;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_S, MESSAGE_PUTS, 1'b?, 1'b1}: begin
        o.sharers_remove_requestor      = 1'b1;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
        o.next_state                    = STATE_I;
      end
      {STATE_S, MESSAGE_PUTM, 1'b1, 1'b?}: begin
      end
      {STATE_S, MESSAGE_PUTM, 1'b0, 1'b?}: begin
        o.sharers_remove_requestor      = 1'b1;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_S, MESSAGE_DATA, 1'b?, 1'b?}: begin
      end
      {STATE_S, MESSAGE_WB, 1'b?, 1'b?}: begin
      end
      {STATE_S, MESSAGE_MC_ACK, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end

      // ---------------- STATE M ----------------
      {STATE_M, REPLACEMENT, 1'b?, 1'b?}: begin
        o.message_forwarded_send        = 1'b1;
        o.message_forwarded_type        = MESSAGE_BACKINV;
        o.message_forwarded_to_owner    = 1'b1;
        o.next_state                    = STATE_MN_A;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_M, MESSAGE_DIR_FLUSH, 1'b?, 1'b?}: begin
        o.message_forwarded_send        = 1'b1;
        o.message_forwarded_type        = MESSAGE_FWD_FLUSH;
        o.message_forwarded_to_owner    = 1'b1;
        o.next_state                    = STATE_M;
      end
      {STATE_M, MESSAGE_GETS, 1'b?, 1'b?}: begin
        o.message_forwarded_send        = 1;
        o.message_forwarded_type        = MESSAGE_FWD_GETS;
        o.message_forwarded_to_owner    = 1;
        o.sharers_add_requestor         = 1'b1;
        o.sharers_add_owner             = 1'b1;
        o.owner_clear                   = 1'b1;
        o.next_state                    = STATE_S_D;
        o.next_state_is_stable          = 1'b0;
        o.invalidate_cache_way          = 1;
      end
      {STATE_M, MESSAGE_GETM, 1'b?, 1'b?}: begin
        o.message_forwarded_send        = 1;
        o.message_forwarded_type        = MESSAGE_FWD_GETM;
        o.message_forwarded_to_owner    = 1;
        o.owner_set_requestor           = 1'b1;
      end
      {STATE_M, MESSAGE_PUTS, 1'b?, 1'b0}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_M, MESSAGE_PUTS, 1'b?, 1'b1}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_M, MESSAGE_PUTM, 1'b1, 1'b?}: begin
        o.store_data                    = 1'b1;
        o.owner_clear                   = 1'b1;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
        o.next_state                    = STATE_I;
      end
      {STATE_M, MESSAGE_PUTM, 1'b0, 1'b?}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_M, MESSAGE_DATA, 1'b?, 1'b?}: begin
      end
      {STATE_M, MESSAGE_WB, 1'b?, 1'b?}: begin
      end
      {STATE_M, MESSAGE_MC_ACK, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end

      // ---------------- STATE S_D ----------------
      {STATE_S_D, REPLACEMENT, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_S_D, MESSAGE_GETS, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_S_D, MESSAGE_GETM, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_S_D, MESSAGE_PUTS, 1'b?, 1'b0}: begin
        o.sharers_remove_requestor      = 1'b1;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_S_D, MESSAGE_PUTS, 1'b?, 1'b1}: begin
        o.sharers_remove_requestor      = 1'b1;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_S_D, MESSAGE_PUTM, 1'b1, 1'b?}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_S_D, MESSAGE_PUTM, 1'b0, 1'b?}: begin
        o.sharers_remove_requestor      = 1'b1;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
        o.current_state_is_stable       = 1'b0;
      end
      {STATE_S_D, MESSAGE_DATA, 1'b?, 1'b?}: begin
        o.store_data                    = 1'b1;
        o.next_state                    = STATE_S;
        o.current_state_is_stable       = 1'b0;
      end
      {STATE_S_D, MESSAGE_WB, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end

      // ---------------- STATE N ----------------
      {STATE_N, REPLACEMENT, 1'b?, 1'b?}: begin
      end
      {STATE_N, MESSAGE_GETS, 1'b?, 1'b?}: begin
        o.sharers_add_requestor         = 1'b1;
        o.message_forwarded_send        = 1'b1;
        o.message_forwarded_type        = MESSAGE_FWD_GETS;
        o.message_forwarded_to_memory   = 1'b1;
        o.next_state                    = STATE_NS_D;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_N, MESSAGE_GETM, 1'b?, 1'b?}: begin
        o.owner_set_requestor           = 1'b1;
        o.message_forwarded_send        = 1'b1;
        o.message_forwarded_type        = MESSAGE_FWD_GETM;
        o.message_forwarded_to_memory   = 1'b1;
        o.next_state                    = STATE_M;
      end
      {STATE_N, MESSAGE_PUTS, 1'b?, 1'b0}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_N, MESSAGE_PUTS, 1'b?, 1'b1}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_N, MESSAGE_PUTM, 1'b1, 1'b?}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_N, MESSAGE_PUTM, 1'b0, 1'b?}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_N, MESSAGE_DATA, 1'b?, 1'b?}: begin
      end
      {STATE_N, MESSAGE_WB, 1'b?, 1'b?}: begin
      end
      {STATE_N, MESSAGE_MC_ACK, 1'b?, 1'b?}: begin
      end
      {STATE_N, MESSAGE_DIR_FLUSH, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end

      // ---------------- STATE MN_A ----------------
      {STATE_MN_A, REPLACEMENT, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_MN_A, MESSAGE_GETS, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_MN_A, MESSAGE_GETM, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_MN_A, MESSAGE_PUTS, 1'b?, 1'b0}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_MN_A, MESSAGE_PUTS, 1'b?, 1'b1}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_MN_A, MESSAGE_PUTM, 1'b1, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
        o.message_response_add_wb       = 1;
      end
      {STATE_MN_A, MESSAGE_PUTM, 1'b0, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_MN_A, MESSAGE_DATA, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_MN_A, MESSAGE_WB, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_MN_A, MESSAGE_MC_ACK, 1'b?, 1'b?}: begin
        o.next_state                    = STATE_N;
        o.current_state_is_stable       = 1'b0;
        o.invalidate_cache_way          = 1;
      end

      // ---------------- STATE SN_A ----------------
      {STATE_SN_A, REPLACEMENT, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_SN_A, MESSAGE_GETS, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_SN_A, MESSAGE_GETM, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_SN_A, MESSAGE_PUTS, 1'b?, 1'b0}: begin
        o.sharers_remove_requestor      = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_SN_A, MESSAGE_PUTS, 1'b?, 1'b1}: begin
        o.sharers_remove_requestor      = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_SN_A, MESSAGE_PUTM, 1'b1, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_SN_A, MESSAGE_PUTM, 1'b0, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_SN_A, MESSAGE_DATA, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_SN_A, MESSAGE_WB, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_SN_A, MESSAGE_MC_ACK, 1'b?, 1'b?}: begin
        o.next_state                    = STATE_N;
        o.current_state_is_stable       = 1'b0;
        o.invalidate_cache_way          = 1;
      end

      // ---------------- STATE NS_D ----------------
      {STATE_NS_D, REPLACEMENT, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_NS_D, MESSAGE_GETS, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_NS_D, MESSAGE_GETM, 1'b?, 1'b?}: begin
        o.stall                         = 1'b1;
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end
      {STATE_NS_D, MESSAGE_PUTS, 1'b?, 1'b0}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_NS_D, MESSAGE_PUTS, 1'b?, 1'b1}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_NS_D, MESSAGE_PUTM, 1'b1, 1'b?}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_NS_D, MESSAGE_PUTM, 1'b0, 1'b?}: begin
        o.message_response_send         = 1;
        o.message_response_type         = MESSAGE_PUTACK;
        o.message_response_to_requestor = 1;
      end
      {STATE_NS_D, MESSAGE_DATA, 1'b?, 1'b?}: begin
        o.store_data                    = 1'b1;
        o.next_state                    = STATE_S;
        o.current_state_is_stable       = 1'b0;
      end
      {STATE_NS_D, MESSAGE_WB, 1'b?, 1'b?}: begin
        o.current_state_is_stable       = 1'b0;
        o.next_state_is_stable          = 1'b0;
      end

      // ---------------- Others ----------------
      {'h?, MESSAGE_WB_GEN, 1'b?, 1'b?}: begin
        o.message_response_send         = 1'b1;
        o.message_response_type         = MESSAGE_WB;
        o.message_response_has_data     = 1'b1;
        o.message_response_to_memory    = 1'b1;
      end

      default: begin
      end
    endcase
    return o;
  endfunction

  // one-hot (equivalent copy of idx_to_oh LSB0)
  function automatic logic [TC-1:0] oh16(logic [3:0] idx);
    logic [TC-1:0] r;
    for (int i = 0; i < TC; i++) r[i] = (int'(idx) == i);
    return r;
  endfunction

  // ------------------------------------------------------------------
  // Prediction result structure
  // ------------------------------------------------------------------
  typedef struct {
    logic        pending;
    logic [31:0] pending_address;
    logic        instr_deq;
    logic        tshr_en;
    logic [3:0]  tshr_idx;
    tshr_entry_t tshr_e;
    logic        cache_en, cache_vbit;
    logic [6:0]  cache_set;
    logic [2:0]  cache_way;
    logic [18:0] cache_tag;
    logic [2:0]  cache_state;
    logic [TC-1:0] cache_sharers;
    logic [3:0]  cache_owner;
    dcache_line_t cache_data;
    logic        plru_en;
    logic [6:0]  plru_set;
    logic [2:0]  plru_way;
    logic        repl_en;
    replacement_request_t repl_req;
    logic        wb_en;
    dcache_line_t wb_data;
    logic [31:0] wb_addr;
    coherence_forwarded_message_t fwd;
    logic        fwd_valid;
    logic [TC-1:0] fwd_dest;
    coherence_response_message_t resp;
    logic        resp_valid;
    logic        resp_has_data;
    logic [TC-1:0] resp_dest;
    logic        add_wb;
  } dc3_exp_t;

  // ------------------------------------------------------------------
  // Combinational predictor: port all DUT output equations (variable tid/tmid parameters, supporting cycle-by-cycle comparison of two instances)
  // ------------------------------------------------------------------
  function automatic dc3_exp_t dc3_predict(dc3_txn t, int tid, int tmid);
    dc3_exp_t          e;
    directory_protocol_rom_entry_t o;
    logic              is_repl;
    logic [31:0]       caddr;
    logic [SW-1:0]     cs;
    logic [TC-1:0]     csh, req_oh, own_oh, mem_oh, nsh;
    tile_address_t     cown, nown;
    dcache_line_t      ndata;
    logic [3:0]        cnt;
    logic              css, nss, cuie;
    logic              talloc, tdel, tupd;
    logic              upd, dea, alc, do_repl;
    coherence_forwarded_message_t cf, inf;

    is_repl = (t.dc2_message_type == REPLACEMENT);

    if (t.dc2_message_tshr_hit) begin
      caddr = 32'(t.dc2_message_address);
      cs    = SW'(t.dc2_message_tshr_entry_info.state);
      csh   = t.dc2_message_tshr_entry_info.sharers_list;
      cown  = t.dc2_message_tshr_entry_info.owner;
    end else if (t.dc2_message_cache_hit) begin
      caddr = 32'(t.dc2_message_address);
      cs    = t.dc2_message_cache_state;
      csh   = t.dc2_message_cache_sharers_list;
      cown  = t.dc2_message_cache_owner;
    end else if (is_repl) begin
      caddr = 32'(t.dc2_message_address);
      cs    = t.dc2_replacement_state;
      csh   = t.dc2_replacement_sharers_list;
      cown  = t.dc2_replacement_owner;
    end else begin
      caddr = 32'(t.dc2_message_address);
      cs    = '0;
      csh   = '0;
      cown  = tile_address_t'(tmid);
    end

    e.pending        = t.dc2_message_valid | t.instr_request_pending;
    e.pending_address = t.dc2_message_valid ? 32'(t.dc2_message_address)
                                            : 32'(t.instr_request_address);

    req_oh = oh16(4'(t.dc2_message_source));
    own_oh = oh16(4'(cown));
    mem_oh = oh16(4'(tile_address_t'(tmid)));

    cnt = '0;
    for (int i = 0; i < TC; i++) cnt = 4'(cnt + csh[i]);

    o   = dc3_rom(cs, t.dc2_message_type, (t.dc2_message_source == cown), (cnt == 4'd1));
    css = o.current_state_is_stable;
    nss = o.next_state_is_stable;

    nsh = ( ( csh | ( ({TC{o.sharers_add_requestor}} & req_oh) |
                      ({TC{o.sharers_add_owner}} & own_oh) ) ) )
          & ( ~({TC{o.sharers_clear}} & {TC{1'b1}}) & ~({TC{o.sharers_remove_requestor}} & req_oh) );
    nown  = o.owner_clear ? tile_address_t'(tid)
                          : o.owner_set_requestor ? t.dc2_message_source : cown;
    ndata = o.store_data ? t.dc2_message_data : t.dc2_message_cache_data;

    cuie = (cs != SW'(o.next_state)) | o.owner_clear | o.owner_set_requestor |
           o.sharers_add_owner | o.sharers_add_requestor | o.sharers_clear |
           o.sharers_remove_requestor;

    // TSHR
    talloc = css & ~nss;
    tupd   = ~css & ~nss & cuie;
    tdel   = ~css & nss;
    e.tshr_e.valid          = (talloc | tupd) & ~tdel;
    e.tshr_e.state          = directory_state_t'(o.next_state);
    e.tshr_e.address.tag    = t.dc2_message_address.tag;
    e.tshr_e.address.index  = t.dc2_message_address.index;
    e.tshr_e.address.offset = t.dc2_message_address.offset;
    e.tshr_e.sharers_list   = nsh;
    e.tshr_e.owner          = nown;
    e.tshr_en  = t.dc2_message_valid && (talloc || tupd || tdel);
    e.tshr_idx = talloc ? t.tshr_empty_index : t.dc2_message_tshr_index;

    // Cache
    upd = t.dc2_message_cache_hit & css & nss & (cuie | o.store_data);
    dea = talloc & t.dc2_message_cache_hit;
    alc = nss & (cuie | o.store_data) & ~(tdel & o.invalidate_cache_way) & ~upd;
    e.cache_en      = t.dc2_message_valid && !is_repl && (alc || upd || dea);
    e.cache_vbit    = ~o.invalidate_cache_way;
    e.cache_set     = t.dc2_message_address.index;
    e.cache_way     = 3'(t.dc2_message_cache_way);
    e.cache_tag     = t.dc2_message_address.tag;
    e.cache_state   = SW'(o.next_state);
    e.cache_sharers = nsh;
    e.cache_owner   = 4'(nown);
    e.cache_data    = ndata;

    // PLRU
    e.plru_en  = t.dc2_message_valid;
    e.plru_set = t.dc2_message_address.index;
    e.plru_way = 3'(t.dc2_message_cache_way);

    // Forwarded
    cf.source            = t.dc2_message_source;
    cf.packet_type       = message_forwarded_requests_enum_t'(o.message_forwarded_type);
    cf.memory_address    = dcache_address_t'(caddr);
    cf.req_is_uncoherent = 1'b0;
    cf.requestor         = DCACHE;
    e.fwd_dest           = o.message_forwarded_to_requestor ? req_oh :
                           o.message_forwarded_to_owner      ? own_oh :
                           o.message_forwarded_to_memory     ? mem_oh : csh;

    inf.source            = tile_address_t'(tid);
    inf.packet_type       = FWD_GETS;
    inf.memory_address    = dcache_address_t'(32'(t.instr_request_address));
    inf.req_is_uncoherent = 1'b1;
    inf.requestor         = ICACHE;

    if (t.dc2_message_valid && o.message_forwarded_send) begin
      e.fwd_valid = 1'b1;
      e.fwd       = cf;
      e.instr_deq = 1'b0;
    end else if (t.instr_request_pending & t.ni_avail) begin
      e.fwd_valid = 1'b1;
      e.fwd       = inf;
      e.fwd_dest  = mem_oh;
      e.instr_deq = 1'b1;
    end else begin
      e.fwd_valid = 1'b0;
      e.fwd       = '0;
      e.fwd_dest  = '0;
      e.instr_deq = 1'b0;
    end

    // Response
    e.resp_valid            = t.dc2_message_valid && o.message_response_send;
    e.resp.source           = t.dc2_message_source;
    e.resp.packet_type      = message_responses_enum_t'(o.message_response_type);
    e.resp.memory_address   = dcache_address_t'(caddr);
    e.resp.data             = t.dc2_message_cache_hit & !is_repl ?
                              t.dc2_message_cache_data : t.dc2_message_data;
    e.resp.dirty_mask       = {$bits(dcache_store_mask_t){1'b1}};
    e.resp.from_directory   = 1'b1;
    e.resp.sharers_count    = cnt;
    e.resp.req_is_uncoherent= 1'b0;
    e.resp.requestor        = DCACHE;
    e.resp_has_data         = o.message_response_has_data;
    e.resp_dest             = o.message_response_to_requestor ? req_oh :
                              o.message_response_to_owner      ? own_oh :
                              o.message_response_to_memory     ? mem_oh : csh;

    // Sleep queue（replacement）
    do_repl   = t.dc2_message_valid && ((alc || upd) && !dea) && !is_repl &&
                !t.dc2_message_cache_hit && t.dc2_message_cache_valid;
    e.repl_req.source                  = t.dc2_message_source;
    e.repl_req.memory_address.tag      = t.dc2_message_cache_tag;
    e.repl_req.memory_address.index    = t.dc2_message_address.index;
    e.repl_req.memory_address.offset   = '0;
    e.repl_req.data                    = t.dc2_message_cache_data;
    e.repl_req.state                   = directory_state_t'(t.dc2_message_cache_state);
    e.repl_req.sharers_list            = t.dc2_message_cache_sharers_list;
    e.repl_req.owner                   = t.dc2_message_cache_owner;
    e.repl_en = t.dc2_message_valid && do_repl;

    // WB (registered for one cycle; scoreboard models it using add_wb and current-cycle data)
    e.add_wb  = o.message_response_add_wb;
    e.wb_data = t.dc2_message_data;
    e.wb_addr = 32'(t.dc2_message_address);
    return e;
  endfunction

  // ------------------------------------------------------------------
  // Driver
  // ------------------------------------------------------------------
  class dc3_driver extends uvm_driver #(dc3_txn);
    `uvm_component_utils(dc3_driver)
    virtual dc3_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual dc3_if)::get(this, "", "vif", vif))
        `uvm_fatal("DRV", "vif not set")
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      @(vif.cb_mon);
      while (vif.cb_mon.reset) @(vif.cb_mon);
      forever begin
        seq_item_port.get_next_item(req);
        drive(req);
        seq_item_port.item_done();
        while (vif.cb_mon.reset) @(vif.cb_mon);
      end
    endtask

    task drive(dc3_txn t);
      vif.cb_drv.ni_forwarded_request_network_available <= t.ni_avail;
      vif.cb_drv.instr_request_pending                  <= t.instr_request_pending;
      vif.cb_drv.instr_request_address                  <= t.instr_request_address;
      vif.cb_drv.dc2_message_valid                      <= t.dc2_message_valid;
      vif.cb_drv.dc2_message_type                       <= t.dc2_message_type;
      vif.cb_drv.dc2_message_address                    <= t.dc2_message_address;
      vif.cb_drv.dc2_message_data                       <= t.dc2_message_data;
      vif.cb_drv.dc2_message_source                     <= t.dc2_message_source;
      vif.cb_drv.dc2_replacement_state                  <= t.dc2_replacement_state;
      vif.cb_drv.dc2_replacement_sharers_list           <= t.dc2_replacement_sharers_list;
      vif.cb_drv.dc2_replacement_owner                  <= t.dc2_replacement_owner;
      vif.cb_drv.dc2_message_tshr_hit                   <= t.dc2_message_tshr_hit;
      vif.cb_drv.dc2_message_tshr_index                 <= t.dc2_message_tshr_index;
      vif.cb_drv.dc2_message_tshr_entry_info            <= t.dc2_message_tshr_entry_info;
      vif.cb_drv.dc2_message_cache_hit                  <= t.dc2_message_cache_hit;
      vif.cb_drv.dc2_message_cache_valid                <= t.dc2_message_cache_valid;
      vif.cb_drv.dc2_message_cache_state                <= t.dc2_message_cache_state;
      vif.cb_drv.dc2_message_cache_sharers_list         <= t.dc2_message_cache_sharers_list;
      vif.cb_drv.dc2_message_cache_owner                <= t.dc2_message_cache_owner;
      vif.cb_drv.dc2_message_cache_tag                  <= t.dc2_message_cache_tag;
      vif.cb_drv.dc2_message_cache_data                 <= t.dc2_message_cache_data;
      vif.cb_drv.dc2_message_cache_way                  <= t.dc2_message_cache_way;
      vif.cb_drv.tshr_empty_index                       <= t.tshr_empty_index;
      repeat (t.hold + 1) @(vif.cb_drv);
      if (t.gap > 0) begin
        vif.cb_drv.dc2_message_valid     <= 1'b0;
        vif.cb_drv.instr_request_pending <= 1'b0;
        repeat (t.gap) @(vif.cb_drv);
      end
    endtask
  endclass

  // ------------------------------------------------------------------
  // Monitor (is_b=0 → instance A outputs; is_b=1 → instance B outputs)
  // ------------------------------------------------------------------
  class dc3_monitor extends uvm_component;
    `uvm_component_utils(dc3_monitor)
    virtual dc3_if vif;
    bit             is_b;
    uvm_analysis_port #(dc3_obs) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual dc3_if)::get(this, "", "vif", vif))
        `uvm_fatal("MON", "vif not set")
    endfunction

    task run_phase(uvm_phase phase);
      dc3_obs o;
      super.run_phase(phase);
      forever begin
        @(vif.cb_mon);
        o = dc3_obs::type_id::create("obs");
        o.reset = vif.cb_mon.reset;
        // Input snapshot
        o.ni_avail                   = vif.cb_mon.ni_forwarded_request_network_available;
        o.instr_request_pending      = vif.cb_mon.instr_request_pending;
        o.instr_request_address      = vif.cb_mon.instr_request_address;
        o.dc2_message_valid          = vif.cb_mon.dc2_message_valid;
        o.dc2_message_type           = vif.cb_mon.dc2_message_type;
        o.dc2_message_address        = vif.cb_mon.dc2_message_address;
        o.dc2_message_data           = vif.cb_mon.dc2_message_data;
        o.dc2_message_source         = vif.cb_mon.dc2_message_source;
        o.dc2_replacement_state      = vif.cb_mon.dc2_replacement_state;
        o.dc2_replacement_sharers_list = vif.cb_mon.dc2_replacement_sharers_list;
        o.dc2_replacement_owner      = vif.cb_mon.dc2_replacement_owner;
        o.dc2_message_tshr_hit       = vif.cb_mon.dc2_message_tshr_hit;
        o.dc2_message_tshr_index     = vif.cb_mon.dc2_message_tshr_index;
        o.dc2_message_tshr_entry_info= vif.cb_mon.dc2_message_tshr_entry_info;
        o.dc2_message_cache_hit      = vif.cb_mon.dc2_message_cache_hit;
        o.dc2_message_cache_valid    = vif.cb_mon.dc2_message_cache_valid;
        o.dc2_message_cache_state    = vif.cb_mon.dc2_message_cache_state;
        o.dc2_message_cache_sharers_list = vif.cb_mon.dc2_message_cache_sharers_list;
        o.dc2_message_cache_owner    = vif.cb_mon.dc2_message_cache_owner;
        o.dc2_message_cache_tag      = vif.cb_mon.dc2_message_cache_tag;
        o.dc2_message_cache_data     = vif.cb_mon.dc2_message_cache_data;
        o.dc2_message_cache_way      = vif.cb_mon.dc2_message_cache_way;
        o.tshr_empty_index           = vif.cb_mon.tshr_empty_index;
        if (!is_b) begin
          o.instr_deq       = vif.cb_mon.dc3_instr_request_dequeue_a;
          o.pending         = vif.cb_mon.dc3_pending_a;
          o.pending_address = vif.cb_mon.dc3_pending_address_a;
          o.cache_en        = vif.cb_mon.dc3_update_cache_enable_a;
          o.cache_vbit      = vif.cb_mon.dc3_update_cache_validity_bit_a;
          o.cache_set       = vif.cb_mon.dc3_update_cache_set_a;
          o.cache_way       = vif.cb_mon.dc3_update_cache_way_a;
          o.cache_tag       = vif.cb_mon.dc3_update_cache_tag_a;
          o.cache_state     = vif.cb_mon.dc3_update_cache_state_a;
          o.cache_sharers   = vif.cb_mon.dc3_update_cache_sharers_list_a;
          o.cache_owner     = 4'(vif.cb_mon.dc3_update_cache_owner_a);
          o.cache_data      = vif.cb_mon.dc3_update_cache_data_a;
          o.plru_en         = vif.cb_mon.dc3_update_plru_en_a;
          o.plru_set        = vif.cb_mon.dc3_update_plru_set_a;
          o.plru_way        = vif.cb_mon.dc3_update_plru_way_a;
          o.tshr_en         = vif.cb_mon.dc3_update_tshr_enable_a;
          o.tshr_idx_o      = vif.cb_mon.dc3_update_tshr_index_a;
          o.tshr_e          = vif.cb_mon.dc3_update_tshr_entry_info_a;
          o.repl_en         = vif.cb_mon.dc3_replacement_enqueue_a;
          o.repl_req        = vif.cb_mon.dc3_replacement_request_a;
          o.wb_en           = vif.cb_mon.dc3_wb_enable_a;
          o.wb_data         = vif.cb_mon.dc3_wb_data_a;
          o.wb_addr         = vif.cb_mon.dc3_wb_addr_a;
          o.fwd             = vif.cb_mon.dc3_forwarded_request_a;
          o.fwd_valid       = vif.cb_mon.dc3_forwarded_request_valid_a;
          o.fwd_dest        = vif.cb_mon.dc3_forwarded_request_destinations_a;
          o.resp            = vif.cb_mon.dc3_response_a;
          o.resp_valid      = vif.cb_mon.dc3_response_valid_a;
          o.resp_has_data   = vif.cb_mon.dc3_response_has_data_a;
          o.resp_dest       = vif.cb_mon.dc3_response_destinations_a;
        end else begin
          o.instr_deq       = vif.cb_mon.dc3_instr_request_dequeue_b;
          o.pending         = vif.cb_mon.dc3_pending_b;
          o.pending_address = vif.cb_mon.dc3_pending_address_b;
          o.cache_en        = vif.cb_mon.dc3_update_cache_enable_b;
          o.cache_vbit      = vif.cb_mon.dc3_update_cache_validity_bit_b;
          o.cache_set       = vif.cb_mon.dc3_update_cache_set_b;
          o.cache_way       = vif.cb_mon.dc3_update_cache_way_b;
          o.cache_tag       = vif.cb_mon.dc3_update_cache_tag_b;
          o.cache_state     = vif.cb_mon.dc3_update_cache_state_b;
          o.cache_sharers   = vif.cb_mon.dc3_update_cache_sharers_list_b;
          o.cache_owner     = 4'(vif.cb_mon.dc3_update_cache_owner_b);
          o.cache_data      = vif.cb_mon.dc3_update_cache_data_b;
          o.plru_en         = vif.cb_mon.dc3_update_plru_en_b;
          o.plru_set        = vif.cb_mon.dc3_update_plru_set_b;
          o.plru_way        = vif.cb_mon.dc3_update_plru_way_b;
          o.tshr_en         = vif.cb_mon.dc3_update_tshr_enable_b;
          o.tshr_idx_o      = vif.cb_mon.dc3_update_tshr_index_b;
          o.tshr_e          = vif.cb_mon.dc3_update_tshr_entry_info_b;
          o.repl_en         = vif.cb_mon.dc3_replacement_enqueue_b;
          o.repl_req        = vif.cb_mon.dc3_replacement_request_b;
          o.wb_en           = vif.cb_mon.dc3_wb_enable_b;
          o.wb_data         = vif.cb_mon.dc3_wb_data_b;
          o.wb_addr         = vif.cb_mon.dc3_wb_addr_b;
          o.fwd             = vif.cb_mon.dc3_forwarded_request_b;
          o.fwd_valid       = vif.cb_mon.dc3_forwarded_request_valid_b;
          o.fwd_dest        = vif.cb_mon.dc3_forwarded_request_destinations_b;
          o.resp            = vif.cb_mon.dc3_response_b;
          o.resp_valid      = vif.cb_mon.dc3_response_valid_b;
          o.resp_has_data   = vif.cb_mon.dc3_response_has_data_b;
          o.resp_dest       = vif.cb_mon.dc3_response_destinations_b;
        end
        ap.write(o);
      end
    endtask
  endclass

  // ------------------------------------------------------------------
  // Scoreboard: cycle-by-cycle comparison of two instances (A: TILE_ID=0/MEM=0; B: TILE_ID=2/MEM=15)
  // ------------------------------------------------------------------
  class dc3_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(dc3_scoreboard)
    uvm_analysis_imp_a #(dc3_obs, dc3_scoreboard) imp_a;
    uvm_analysis_imp_b #(dc3_obs, dc3_scoreboard) imp_b;
    dc3_obs prev_a, prev_b;
    int     errors;
    int     checked;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp_a = new("imp_a", this);
      imp_b = new("imp_b", this);
    endfunction

    function void chk(string tag, string what, logic [1023:0] e, logic [1023:0] a);
      checked++;
      if (e !== a) begin
        errors++;
        `uvm_error("SB", $sformatf("%s.%s exp=%h act=%h", tag, what, e, a))
      end
    endfunction

    function void write_a(dc3_obs o);
      do_check(o, 0, 0, prev_a, "A");
      prev_a = o;
    endfunction

    function void write_b(dc3_obs o);
      do_check(o, 2, 15, prev_b, "B");
      prev_b = o;
    endfunction

    function void do_check(dc3_obs o, int tid, int tmid, dc3_obs prev, string tag);
      dc3_exp_t e = dc3_predict(o, tid, tmid);
      chk(tag, "pending",          1024'(e.pending),         1024'(o.pending));
      chk(tag, "pending_address",  1024'(e.pending_address), 1024'(o.pending_address));
      chk(tag, "instr_deq",        1024'(e.instr_deq),       1024'(o.instr_deq));
      chk(tag, "tshr_en",          1024'(e.tshr_en),         1024'(o.tshr_en));
      chk(tag, "tshr_idx",         1024'(e.tshr_idx),        1024'(o.tshr_idx_o));
      chk(tag, "tshr_entry",       1024'(e.tshr_e),          1024'(o.tshr_e));
      chk(tag, "cache_en",         1024'(e.cache_en),        1024'(o.cache_en));
      chk(tag, "cache_vbit",       1024'(e.cache_vbit),      1024'(o.cache_vbit));
      chk(tag, "cache_set",        1024'(e.cache_set),       1024'(o.cache_set));
      chk(tag, "cache_way",        1024'(e.cache_way),       1024'(o.cache_way));
      chk(tag, "cache_tag",        1024'(e.cache_tag),       1024'(o.cache_tag));
      chk(tag, "cache_state",      1024'(e.cache_state),     1024'(o.cache_state));
      chk(tag, "cache_sharers",    1024'(e.cache_sharers),   1024'(o.cache_sharers));
      chk(tag, "cache_owner",      1024'(e.cache_owner),     1024'(o.cache_owner));
      chk(tag, "cache_data",       1024'(e.cache_data),      1024'(o.cache_data));
      chk(tag, "plru_en",          1024'(e.plru_en),         1024'(o.plru_en));
      chk(tag, "plru_set",         1024'(e.plru_set),        1024'(o.plru_set));
      chk(tag, "plru_way",         1024'(e.plru_way),        1024'(o.plru_way));
      chk(tag, "repl_en",          1024'(e.repl_en),         1024'(o.repl_en));
      chk(tag, "repl_req",         1024'(e.repl_req),        1024'(o.repl_req));
      chk(tag, "fwd_valid",        1024'(e.fwd_valid),       1024'(o.fwd_valid));
      chk(tag, "fwd",              1024'(e.fwd),             1024'(o.fwd));
      chk(tag, "fwd_dest",         1024'(e.fwd_dest),        1024'(o.fwd_dest));
      chk(tag, "resp_valid",       1024'(e.resp_valid),      1024'(o.resp_valid));
      chk(tag, "resp",             1024'(e.resp),            1024'(o.resp));
      chk(tag, "resp_has_data",    1024'(e.resp_has_data),   1024'(o.resp_has_data));
      chk(tag, "resp_dest",        1024'(e.resp_dest),       1024'(o.resp_dest));
      // WB registered outputs: wb_en ← previous-cycle add_wb (asynchronous reset clears 0); wb_data/wb_addr ← previous-cycle inputs
      if (o.reset) begin
        chk(tag, "wb_en(rst)", 1024'(1'b0), 1024'(o.wb_en));
      end else if (prev != null) begin
        dc3_exp_t pe = dc3_predict(prev, tid, tmid);
        chk(tag, "wb_en",    1024'(pe.add_wb),            1024'(o.wb_en));
        chk(tag, "wb_data",  1024'(prev.dc2_message_data),1024'(o.wb_data));
        chk(tag, "wb_addr",  1024'(32'(prev.dc2_message_address)), 1024'(o.wb_addr));
      end else begin
        chk(tag, "wb_en(first)", 1024'(1'b0), 1024'(o.wb_en));
      end
    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("SB", $sformatf("checked=%0d fields, errors=%0d", checked, errors), UVM_LOW)
    endfunction
  endclass

  // ------------------------------------------------------------------
  // Coverage (functional coverage; the URG overall score is code coverage, while this is a nine-dimensional feature metric)
  // ------------------------------------------------------------------
  class dc3_cov extends uvm_subscriber #(dc3_obs);
    `uvm_component_utils(dc3_cov)

    phase_e      ph;
    logic [SW-1:0] cs;
    logic [MW-1:0] rq;
    logic [SW-1:0] nstate;
    bit          fo, os_, vld, ip, na, ch, cv, rs;
    sel_e        sel;
    route_e      froute, rroute;
    bit          fwd_v, resp_v, te, ce, re, deq, wbe;
    logic [3:0]  ftype, rtype;

    covergroup cg;
      option.per_instance = 1;
      cp_phase   : coverpoint ph;
      cp_state   : coverpoint cs iff (vld);
      cp_msg     : coverpoint rq iff (vld) {
        illegal_bins msg_illegal = {[17:31]};
      }
      cp_nstate  : coverpoint nstate iff (vld);
      cp_from_own: coverpoint fo iff (vld);
      cp_one_sh  : coverpoint os_ iff (vld);
      cp_valid   : coverpoint vld;
      cp_ip_na   : cross ip, na;
      cp_hit     : coverpoint ch iff (vld);
      cp_cvalid  : coverpoint cv iff (vld);
      cp_sel     : coverpoint sel iff (vld);
      cp_reset   : coverpoint rs;
      cp_fwd_v   : coverpoint fwd_v;
      cp_fwd_type: coverpoint ftype iff (fwd_v) {
        illegal_bins fwd_illegal = {[0:3], 7, [9:14]};
      }
      cp_fwd_route: coverpoint froute iff (fwd_v) {
        illegal_bins fwd_route_illegal = {ROUTE_REQ};
      }
      cp_resp_v  : coverpoint resp_v;
      cp_resp_typ: coverpoint rtype iff (resp_v) {
        illegal_bins resp_illegal = {[0:6], 8, [12:13], 15};
        ignore_bins  resp_unemitted = {10, 14};  // INV_ACK/MC_ACK are input messages, not response outputs from this directory controller
      }
      cp_resp_route: coverpoint rroute iff (resp_v) {
        illegal_bins resp_route_illegal = {ROUTE_OWNER, ROUTE_SHARERS};
      }
      cp_tshr_en : coverpoint te;
      cp_cache_en: coverpoint ce;
      cp_repl_en : coverpoint re;
      cp_deq     : coverpoint deq;
      cp_wb_en   : coverpoint wbe;
      x_state_msg: cross cp_state, cp_msg;
      x_reset_wb : cross cp_reset, cp_wb_en {
        illegal_bins rst_wb_illegal = binsof(cp_reset) intersect {1} && binsof(cp_wb_en) intersect {1};
      }
    endgroup

    function new(string name, uvm_component parent);
      super.new(name, parent);
      cg = new();
    endfunction

    function void write(dc3_obs t);
      logic [SW-1:0] lcs;
      logic [TC-1:0] lsh;
      logic [3:0]    lcnt;
      logic          lis_repl;
      directory_protocol_rom_entry_t rom_o;
      lcs = '0; lsh = '0; lcnt = '0;
      lis_repl = (t.dc2_message_type == REPLACEMENT);
      if (t.dc2_message_tshr_hit) begin
        lcs = SW'(t.dc2_message_tshr_entry_info.state);
        lsh = t.dc2_message_tshr_entry_info.sharers_list;
      end else if (t.dc2_message_cache_hit) begin
        lcs = t.dc2_message_cache_state;
        lsh = t.dc2_message_cache_sharers_list;
      end else if (lis_repl) begin
        lcs = t.dc2_replacement_state;
        lsh = t.dc2_replacement_sharers_list;
      end else begin
        lcs = '0;
        lsh = '0;
      end
      for (int i = 0; i < TC; i++) lcnt = 4'(lcnt + lsh[i]);
      cs = lcs;
      rq = t.dc2_message_type;
      fo = (t.dc2_message_source == (t.dc2_message_tshr_hit ? t.dc2_message_tshr_entry_info.owner :
             t.dc2_message_cache_hit ? t.dc2_message_cache_owner :
             lis_repl ? t.dc2_replacement_owner : tile_address_t'(0)));
      os_ = (lcnt == 4'd1);
      vld = t.dc2_message_valid;
      ip  = t.instr_request_pending;
      na  = t.ni_avail;
      ch  = t.dc2_message_cache_hit;
      cv  = t.dc2_message_cache_valid;
      rs  = t.reset;
      sel = t.dc2_message_tshr_hit ? SEL_TSHR : t.dc2_message_cache_hit ? SEL_CACHE :
            lis_repl ? SEL_REPL : SEL_N;
      ph    = cur_phase;
      fwd_v = t.fwd_valid;
      resp_v= t.resp_valid;
      te    = t.tshr_en;
      ce    = t.cache_en;
      re    = t.repl_en;
      deq   = t.instr_deq;
      wbe   = t.wb_en;
      nstate = t.cache_state;
      // packet_type is a 4bit enum: fwd follows source(4)+ptype(4), i.e. [38:35]; resp follows source(4)+ptype(4)+count(4)+addr(32), i.e. [43:40]
      ftype = 4'(t.fwd >> 35);
      rtype = 4'(t.resp >> 40);
      // destination routing (replicates the message generator's one-of-four selection; instruction-fetch path is fixed to memory)
      rom_o = dc3_rom(cs, rq, fo, os_);
      if (vld && rom_o.message_forwarded_send)
        froute = rom_o.message_forwarded_to_requestor ? ROUTE_REQ :
                 rom_o.message_forwarded_to_owner      ? ROUTE_OWNER :
                 rom_o.message_forwarded_to_memory     ? ROUTE_MEM :
                                                          ROUTE_SHARERS;
      else if (ip && na)
        froute = ROUTE_MEM;
      else
        froute = ROUTE_REQ;
      if (vld && rom_o.message_response_send)
        rroute = rom_o.message_response_to_requestor ? ROUTE_REQ :
                 rom_o.message_response_to_owner      ? ROUTE_OWNER :
                 rom_o.message_response_to_memory     ? ROUTE_MEM :
                                                          ROUTE_SHARERS;
      else
        rroute = ROUTE_REQ;
      cg.sample();
    endfunction
  endclass

  // ------------------------------------------------------------------
  // Agent / Env
  // ------------------------------------------------------------------
  class dc3_agent extends uvm_agent;
    `uvm_component_utils(dc3_agent)
    dc3_driver    drv;
    dc3_monitor   mon;
    uvm_sequencer #(dc3_txn) sqr;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv = dc3_driver::type_id::create("drv", this);
      mon = dc3_monitor::type_id::create("mon", this);
      sqr = new("sqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class dc3_env extends uvm_env;
    `uvm_component_utils(dc3_env)
    dc3_agent      ag;
    dc3_monitor    mon_b;
    dc3_scoreboard sb;
    dc3_cov        cov;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ag     = dc3_agent::type_id::create("ag", this);
      mon_b  = dc3_monitor::type_id::create("mon_b", this);
      mon_b.is_b = 1;
      sb     = dc3_scoreboard::type_id::create("sb", this);
      cov    = dc3_cov::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      ag.mon.ap.connect(sb.imp_a);
      mon_b.ap.connect(sb.imp_b);
      ag.mon.ap.connect(cov.analysis_export);
    endfunction
  endclass

  // ------------------------------------------------------------------
  // Sequence library
  // ------------------------------------------------------------------
  class dc3_base_seq extends uvm_sequence #(dc3_txn);
    `uvm_object_utils(dc3_base_seq)
    function new(string name = "dc3_base_seq");
      super.new(name);
    endfunction

    // Override control fields according to directed intent after randomization
    function dc3_txn mk();
      dc3_txn t = dc3_txn::type_id::create("t");
      void'(t.randomize());
      t.ni_avail = 1;
      return t;
    endfunction

    task beat(dc3_txn t);
      start_item(t);
      finish_item(t);
    endtask
  endclass

  // F03/F04-1: Full ROM table sweep for the TSHR path (8 states × 17 messages + from_owner/one_sharer variants)
  class s_rom_sweep extends dc3_base_seq;
    `uvm_object_utils(s_rom_sweep)
    function new(string name = "s_rom_sweep");
      super.new(name);
    endfunction

    task body();
      int msgs[17] = '{MESSAGE_GETS, MESSAGE_GETM, MESSAGE_PUTS, MESSAGE_PUTM,
                       MESSAGE_FWD_GETS, MESSAGE_FWD_GETM, MESSAGE_INV, MESSAGE_PUTACK,
                       MESSAGE_BACKINV, MESSAGE_DATA, MESSAGE_INV_ACK, MESSAGE_WB,
                       REPLACEMENT, MESSAGE_DIR_FLUSH, MESSAGE_MC_ACK, MESSAGE_FWD_FLUSH,
                       MESSAGE_WB_GEN};
      for (int st = 0; st < 8; st++) begin
        for (int j = 0; j < 17; j++) begin
          dc3_txn t = mk();
          t.dc2_message_valid        = 1;
          t.dc2_message_type         = msgs[j];
          t.dc2_message_tshr_hit     = 1;
          t.dc2_message_cache_hit    = 0;
          t.dc2_message_source       = tile_address_t'(3);
          t.dc2_message_tshr_entry_info.state         = directory_state_t'(st);
          t.dc2_message_tshr_entry_info.sharers_list  = '0;
          t.dc2_message_tshr_entry_info.owner         = '0;
          t.dc2_message_cache_valid  = 1;
          beat(t);
        end
      end
      // from_owner variant (source == owner)
      begin
        int fmsgs[4] = '{MESSAGE_PUTS, MESSAGE_PUTM, MESSAGE_DATA, MESSAGE_WB};
        for (int st = 0; st < 8; st++) begin
          for (int j = 0; j < 4; j++) begin
            dc3_txn t = mk();
            t.dc2_message_valid        = 1;
            t.dc2_message_type         = fmsgs[j];
            t.dc2_message_tshr_hit     = 1;
            t.dc2_message_cache_hit    = 0;
            t.dc2_message_source       = tile_address_t'(5);
            t.dc2_message_tshr_entry_info.state         = directory_state_t'(st);
            t.dc2_message_tshr_entry_info.sharers_list  = '0;
            t.dc2_message_tshr_entry_info.owner         = tile_address_t'(5);
            beat(t);
          end
        end
      end
      // one_sharer variant (single sharer bit = requestor)
      for (int st = 0; st < 8; st++) begin
        dc3_txn t = mk();
        t.dc2_message_valid        = 1;
        t.dc2_message_type         = MESSAGE_PUTS;
        t.dc2_message_tshr_hit     = 1;
        t.dc2_message_cache_hit    = 0;
        t.dc2_message_source       = tile_address_t'(9);
        t.dc2_message_tshr_entry_info.state         = directory_state_t'(st);
        t.dc2_message_tshr_entry_info.sharers_list  = 16'h0200;
        t.dc2_message_tshr_entry_info.owner         = '0;
        beat(t);
      end
    endtask
  endclass

  // F04-2/3: cache-hit selection path / replacement selection path / N default path / priority
  class s_sel_modes extends dc3_base_seq;
    `uvm_object_utils(s_sel_modes)
    function new(string name = "s_sel_modes");
      super.new(name);
    endfunction

    task body();
      // cache hit path (state comes from cache_*)
      int cmsgs[6] = '{MESSAGE_GETS, MESSAGE_GETM, MESSAGE_PUTM, MESSAGE_DATA,
                       MESSAGE_MC_ACK, REPLACEMENT};
      for (int st = 0; st < 8; st++) begin
        for (int j = 0; j < 6; j++) begin
          dc3_txn t = mk();
          t.dc2_message_valid        = 1;
          t.dc2_message_type         = cmsgs[j];
          t.dc2_message_tshr_hit     = 0;
          t.dc2_message_cache_hit    = 1;
          t.dc2_message_cache_valid  = 1;
          t.dc2_message_source       = tile_address_t'(7);
          t.dc2_message_cache_state        = SW'(st);
          t.dc2_message_cache_sharers_list = 16'h0081;
          t.dc2_message_cache_owner        = tile_address_t'(1);
          beat(t);
        end
      end
      // cache path from_owner
      for (int st = 0; st < 8; st++) begin
        dc3_txn t = mk();
        t.dc2_message_valid        = 1;
        t.dc2_message_type         = MESSAGE_PUTM;
        t.dc2_message_tshr_hit     = 0;
        t.dc2_message_cache_hit    = 1;
        t.dc2_message_source       = tile_address_t'(2);
        t.dc2_message_cache_state  = SW'(st);
        t.dc2_message_cache_owner  = tile_address_t'(2);
        beat(t);
      end
      // replacement selection path (state comes from dc2_replacement_*)
      for (int st = 0; st < 8; st++) begin
        dc3_txn t = mk();
        t.dc2_message_valid     = 1;
        t.dc2_message_type      = REPLACEMENT;
        t.dc2_message_tshr_hit  = 0;
        t.dc2_message_cache_hit = 0;
        t.dc2_replacement_state           = SW'(st);
        t.dc2_replacement_sharers_list    = 16'h1002;
        t.dc2_replacement_owner           = tile_address_t'(6);
        beat(t);
      end
      // N default path (no hit and not replacement)
      begin
        int nmsgs[3] = '{MESSAGE_GETS, MESSAGE_GETM, MESSAGE_PUTS};
        for (int j = 0; j < 3; j++) begin
          dc3_txn t = mk();
          t.dc2_message_valid     = 1;
          t.dc2_message_type      = nmsgs[j];
          t.dc2_message_tshr_hit  = 0;
          t.dc2_message_cache_hit = 0;
          beat(t);
        end
      end
      // Priority: tshr_hit & cache_hit in the same cycle (tshr wins)
      begin
        int pmsgs[2] = '{MESSAGE_GETS, MESSAGE_GETM};
        for (int j = 0; j < 2; j++) begin
          dc3_txn t = mk();
          t.dc2_message_valid        = 1;
          t.dc2_message_type         = pmsgs[j];
          t.dc2_message_tshr_hit     = 1;
          t.dc2_message_cache_hit    = 1;
          t.dc2_message_tshr_entry_info.state         = STATE_M;
          t.dc2_message_tshr_entry_info.sharers_list  = '0;
          t.dc2_message_tshr_entry_info.owner         = tile_address_t'(4);
          t.dc2_message_cache_state        = STATE_S;
          t.dc2_message_cache_sharers_list = 16'h3;
          t.dc2_message_cache_owner        = '0;
          beat(t);
        end
      end
    endtask
  endclass

  // F01/F05: Instruction fetch request path and NI backpressure
  class s_instr extends dc3_base_seq;
    `uvm_object_utils(s_instr)
    function new(string name = "s_instr");
      super.new(name);
    endfunction

    task body();
      // pending & available (multiple times, with addresses including 0/all 1/random)
      for (int k = 0; k < 4; k++) begin
        dc3_txn t = mk();
        t.dc2_message_valid      = 0;
        t.instr_request_pending  = 1;
        t.ni_avail               = 1;
        t.instr_request_address  = (k == 0) ? 32'h0000_0000 :
                                   (k == 1) ? 32'hFFFF_FFFF :
                                   (k == 2) ? 32'h8000_0000 : 32'h1234_5678;
        t.hold = (k == 2) ? 2 : 0;
        beat(t);
      end
      // pending & !available (hold, do not dequeue)
      for (int k = 0; k < 2; k++) begin
        dc3_txn t = mk();
        t.dc2_message_valid      = 0;
        t.instr_request_pending  = 1;
        t.ni_avail               = 0;
        t.hold                   = 1;
        beat(t);
      end
      // !pending & available (pure idle)
      begin
        dc3_txn t = mk();
        t.dc2_message_valid      = 0;
        t.instr_request_pending  = 0;
        t.ni_avail               = 1;
        t.gap                    = 1;
        beat(t);
      end
      // dc2 valid and instruction fetch in the same cycle (dc2 has priority)
      for (int k = 0; k < 2; k++) begin
        dc3_txn t = mk();
        t.dc2_message_valid      = 1;
        t.dc2_message_type       = (k == 0) ? MESSAGE_GETS : MESSAGE_PUTS;
        t.dc2_message_tshr_hit   = 1;
        t.dc2_message_tshr_entry_info.state = (k == 0) ? STATE_N : STATE_S;
        t.dc2_message_tshr_entry_info.sharers_list = (k == 1) ? 16'h0004 : '0;
        t.instr_request_pending  = 1;
        t.ni_avail               = 1;
        beat(t);
      end
    endtask
  endclass

  // F06/F07: WB path (registered add_wb) and reset behavior
  class s_wb_reset extends dc3_base_seq;
    `uvm_object_utils(s_wb_reset)
    virtual dc3_if vif;
    function new(string name = "s_wb_reset");
      super.new(name);
    endfunction

    task body();
      if (vif == null)
        void'(uvm_config_db#(virtual dc3_if)::get(null, "*", "vif", vif));
      // MN_A + PUTM(from owner) → add_wb=1 → next cycle wb_enable=1, hold is maintained
      begin
        dc3_txn t = mk();
        t.dc2_message_valid        = 1;
        t.dc2_message_type         = MESSAGE_PUTM;
        t.dc2_message_tshr_hit     = 1;
        t.dc2_message_source       = tile_address_t'(11);
        t.dc2_message_tshr_entry_info.state        = STATE_MN_A;
        t.dc2_message_tshr_entry_info.sharers_list = '0;
        t.dc2_message_tshr_entry_info.owner        = tile_address_t'(11);
        t.hold = 3;
        beat(t);
      end
      // Observe wb_enable falling back during an idle cycle
      begin
        dc3_txn t = mk();
        t.dc2_message_valid      = 0;
        t.instr_request_pending  = 0;
        t.gap                    = 2;
        beat(t);
      end
      // MN_A+PUTM from a non-owner (no add_wb)
      begin
        dc3_txn t = mk();
        t.dc2_message_valid        = 1;
        t.dc2_message_type         = MESSAGE_PUTM;
        t.dc2_message_tshr_hit     = 1;
        t.dc2_message_source       = tile_address_t'(3);
        t.dc2_message_tshr_entry_info.state        = STATE_MN_A;
        t.dc2_message_tshr_entry_info.sharers_list = '0;
        t.dc2_message_tshr_entry_info.owner        = tile_address_t'(8);
        beat(t);
      end
      // Reset during transfer: after driving add_wb high, pulse_reset; wb_enable should be asynchronously cleared to 0
      begin
        dc3_txn t = mk();
        t.dc2_message_valid        = 1;
        t.dc2_message_type         = MESSAGE_PUTM;
        t.dc2_message_tshr_hit     = 1;
        t.dc2_message_source       = tile_address_t'(11);
        t.dc2_message_tshr_entry_info.state        = STATE_MN_A;
        t.dc2_message_tshr_entry_info.owner        = tile_address_t'(11);
        beat(t);
      end
      vif.pulse_reset(4);
      // Clean recovery after reset release
      begin
        dc3_txn t = mk();
        t.dc2_message_valid        = 1;
        t.dc2_message_type         = MESSAGE_GETS;
        t.dc2_message_tshr_hit     = 1;
        t.dc2_message_tshr_entry_info.state        = STATE_I;
        t.dc2_message_tshr_entry_info.sharers_list = '0;
        t.dc2_message_tshr_entry_info.owner        = '0;
        beat(t);
      end
    endtask
  endclass

  // F02/F08: Boundary data (0/all 1/walking bits) and source/owner sweep (one-hot and bit toggles)
  class s_boundary extends dc3_base_seq;
    `uvm_object_utils(s_boundary)
    function new(string name = "s_boundary");
      super.new(name);
    endfunction

    task body();
      // Data/address 0 and all 1
      for (int k = 0; k < 2; k++) begin
        dc3_txn t = mk();
        t.dc2_message_valid   = 1;
        t.dc2_message_type    = MESSAGE_PUTM;
        t.dc2_message_tshr_hit= 1;
        t.dc2_message_source  = tile_address_t'(1);
        t.dc2_message_tshr_entry_info.state        = STATE_M;
        t.dc2_message_tshr_entry_info.sharers_list = 16'h0002;
        t.dc2_message_tshr_entry_info.owner        = tile_address_t'(1);
        t.dc2_message_data    = k ? '1 : '0;
        t.dc2_message_cache_data = k ? '0 : '1;
        t.dc2_message_address = k ? '1 : '0;
        t.hold = 1;
        beat(t);
      end
      // sharers all 1 (count 16→4bit wraps around to 0)
      begin
        dc3_txn t = mk();
        t.dc2_message_valid        = 1;
        t.dc2_message_type         = MESSAGE_GETS;
        t.dc2_message_tshr_hit     = 1;
        t.dc2_message_tshr_entry_info.state        = STATE_S;
        t.dc2_message_tshr_entry_info.sharers_list = '1;
        t.dc2_message_tshr_entry_info.owner        = '0;
        beat(t);
      end
      // walking-one sharers (cover toggles of every sharers bit)
      for (int b = 0; b < 4; b++) begin
        dc3_txn t = mk();
        t.dc2_message_valid        = 1;
        t.dc2_message_type         = MESSAGE_GETM;
        t.dc2_message_tshr_hit     = 1;
        t.dc2_message_source       = tile_address_t'(b * 3);
        t.dc2_message_tshr_entry_info.state        = STATE_S;
        t.dc2_message_tshr_entry_info.sharers_list = 16'h1 << (b * 4);
        t.dc2_message_tshr_entry_info.owner        = tile_address_t'(15 - b);
        beat(t);
      end
      // Full source sweep (requestor_oh / destination toggles)
      for (int s = 0; s < 16; s++) begin
        dc3_txn t = mk();
        t.dc2_message_valid        = 1;
        t.dc2_message_type         = MESSAGE_GETS;
        t.dc2_message_tshr_hit     = 1;
        t.dc2_message_source       = tile_address_t'(s);
        t.dc2_message_tshr_entry_info.state        = STATE_S;
        t.dc2_message_tshr_entry_info.sharers_list = 16'h5555;
        t.dc2_message_tshr_entry_info.owner        = tile_address_t'(s);
        beat(t);
      end
      // replacement boundaries (cache_valid=0/1 × tag/way extrema)
      for (int k = 0; k < 2; k++) begin
        dc3_txn t = mk();
        t.dc2_message_valid     = 1;
        t.dc2_message_type      = MESSAGE_GETM;
        t.dc2_message_tshr_hit  = 0;
        t.dc2_message_cache_hit = 0;
        t.dc2_message_cache_valid = k;
        t.dc2_message_cache_tag   = k ? '1 : '0;
        t.dc2_message_cache_way   = k ? '1 : '0;
        t.dc2_message_address     = k ? '1 : '0;
        beat(t);
      end
    endtask
  endclass

  // F02: Random stimulus (fill toggle/cond coverage holes)
  class s_random extends dc3_base_seq;
    `uvm_object_utils(s_random)
    int unsigned n = 60;
    function new(string name = "s_random");
      super.new(name);
    endfunction

    task body();
      for (int k = 0; k < n; k++) begin
        dc3_txn t = dc3_txn::type_id::create("t");
        void'(t.randomize() with {
          dc2_message_valid dist {1 := 9, 0 := 1};
          dc2_message_tshr_hit  dist {1 := 4, 0 := 6};
          dc2_message_cache_hit dist {1 := 4, 0 := 6};
          dc2_message_cache_valid dist {1 := 6, 0 := 4};
          hold dist {0 := 8, 1 := 2};
          gap dist {0 := 8, 1 := 2};
        });
        beat(t);
      end
    endtask
  endclass

  // ------------------------------------------------------------------
  // Tests
  // ------------------------------------------------------------------
  class t_main extends uvm_test;
    `uvm_component_utils(t_main)
    dc3_env env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = dc3_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      s_rom_sweep s1;
      s_sel_modes s2;
      s_instr     s3;
      s_wb_reset  s4;
      s_boundary  s5;
      s_random    s6;
      phase.raise_objection(this);

      cur_phase = PH_SWEEP;
      s1 = s_rom_sweep::type_id::create("s1");   s1.start(env.ag.sqr);
      cur_phase = PH_SEL;
      s2 = s_sel_modes::type_id::create("s2");   s2.start(env.ag.sqr);
      cur_phase = PH_INSTR;
      s3 = s_instr::type_id::create("s3");       s3.start(env.ag.sqr);
      cur_phase = PH_WB;
      s4 = s_wb_reset::type_id::create("s4");    s4.start(env.ag.sqr);
      cur_phase = PH_BOUND;
      s5 = s_boundary::type_id::create("s5");    s5.start(env.ag.sqr);
      cur_phase = PH_RAND;
      s6 = s_random::type_id::create("s6");      s6.start(env.ag.sqr);

      #200;
      phase.drop_objection(this);
    endtask
  endclass

  class t_random extends uvm_test;
    `uvm_component_utils(t_random)
    dc3_env env;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = dc3_env::type_id::create("env", this);
    endfunction
    task run_phase(uvm_phase phase);
      s_random s;
      phase.raise_objection(this);
      cur_phase = PH_RAND;
      s = s_random::type_id::create("s");
      s.n = 120;
      s.start(env.ag.sqr);
      #200;
      phase.drop_objection(this);
    endtask
  endclass

  class t_reset extends uvm_test;
    `uvm_component_utils(t_reset)
    dc3_env env;
    virtual dc3_if vif;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = dc3_env::type_id::create("env", this);
    endfunction
    task run_phase(uvm_phase phase);
      s_wb_reset s;
      phase.raise_objection(this);
      void'(uvm_config_db#(virtual dc3_if)::get(this, "*", "vif", vif));
      cur_phase = PH_WB;
      s = s_wb_reset::type_id::create("s");
      s.start(env.ag.sqr);
      vif.pulse_reset(2);
      #200;
      phase.drop_objection(this);
    endtask
  endclass
