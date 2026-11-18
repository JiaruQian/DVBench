// logic_hash_if.sv — logic_hash interface (single clock, self-held reset, integer half-period)
`timescale 1ns/1ps

interface logic_hash_if ();

  import meta_package::*;

  logic rst_n = 0;

  // ---- ecdsa write side (RAM programming: hash / serial_num / ppl) ----
  logic          ecdsa_lh_wr;
  logic [11:0]   ecdsa_lh_waddr;    // `FID_NBITS
  logic [255:0]  ecdsa_lh_wdata;    // `LOGIC_HASH_NBITS
  logic [63:0]   ecdsa_lh_sn_wdata; // `SERIAL_NUM_NBITS
  logic [5:0]    ecdsa_lh_ppl_wdata;// `PPL_NBITS
  logic          ecdsa_lh_ready;    // Unused by the DUT; driven only according to the protocol

  // ---- irl input stream side ----
  logic            irl_lh_valid;
  logic [127:0]    irl_lh_hdr_data; // `DATA_PATH_NBITS
  irl_lh_meta_type irl_lh_meta_data;
  logic            irl_lh_sop;
  logic            irl_lh_eop;

  // ---- Output: hash ----
  logic          lh_ecdsa_hash_valid;
  logic [255:0]  lh_ecdsa_hash_data;

  // ---- Output: pp ----
  logic            lh_pp_valid;
  logic [127:0]    lh_pp_hdr_data;
  lh_pp_meta_type  lh_pp_meta_data;
  logic            lh_pp_sop;
  logic            lh_pp_eop;

  // ---- Output: ecdsa ----
  logic              lh_ecdsa_valid;
  logic [127:0]      lh_ecdsa_hdr_data;
  lh_ecdsa_meta_type lh_ecdsa_meta_data;
  logic              lh_ecdsa_sop;
  logic              lh_ecdsa_eop;

  // Integer half-period clock (real delays trigger analog-style scheduling, ~300× slower)
  int unsigned half = 5;   // Period 10ns
  logic clk = 0;
  initial forever #(half) clk = ~clk;

  // Self-held reset: after deassertion, the DUT needs ~4097 cycles to complete RAM zero-initialization
  initial begin
    repeat (8) @(posedge clk);
    rst_n = 1;
  end

  task pulse_reset();   // F07: reset pulse at the end
    rst_n = 0;
    repeat (6) @(posedge clk);
    rst_n = 1;
  endtask

  clocking cb @(posedge clk);
    default input #1step output #1;
    output ecdsa_lh_wr, ecdsa_lh_waddr, ecdsa_lh_wdata, ecdsa_lh_sn_wdata,
           ecdsa_lh_ppl_wdata, ecdsa_lh_ready,
           irl_lh_valid, irl_lh_hdr_data, irl_lh_meta_data, irl_lh_sop, irl_lh_eop;
    input  lh_ecdsa_hash_valid, lh_ecdsa_hash_data,
           lh_pp_valid, lh_pp_hdr_data, lh_pp_meta_data, lh_pp_sop, lh_pp_eop,
           lh_ecdsa_valid, lh_ecdsa_hdr_data, lh_ecdsa_meta_data, lh_ecdsa_sop, lh_ecdsa_eop;
  endclocking

endinterface
