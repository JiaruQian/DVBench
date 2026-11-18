// tb_top.sv — logic_hash test top level
`timescale 1ns/1ps

module tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  logic_hash_if if0();

  logic_hash dut (
    .clk                 (if0.clk),
    .reset_n             (if0.rst_n),
    .ecdsa_lh_wr         (if0.ecdsa_lh_wr),
    .ecdsa_lh_waddr      (if0.ecdsa_lh_waddr),
    .ecdsa_lh_wdata      (if0.ecdsa_lh_wdata),
    .ecdsa_lh_sn_wdata   (if0.ecdsa_lh_sn_wdata),
    .ecdsa_lh_ppl_wdata  (if0.ecdsa_lh_ppl_wdata),
    .irl_lh_valid        (if0.irl_lh_valid),
    .irl_lh_hdr_data     (if0.irl_lh_hdr_data),
    .irl_lh_meta_data    (if0.irl_lh_meta_data),
    .irl_lh_sop          (if0.irl_lh_sop),
    .irl_lh_eop          (if0.irl_lh_eop),
    .lh_ecdsa_hash_valid (if0.lh_ecdsa_hash_valid),
    .lh_ecdsa_hash_data  (if0.lh_ecdsa_hash_data),
    .ecdsa_lh_ready      (if0.ecdsa_lh_ready),
    .lh_pp_valid         (if0.lh_pp_valid),
    .lh_pp_hdr_data      (if0.lh_pp_hdr_data),
    .lh_pp_meta_data     (if0.lh_pp_meta_data),
    .lh_pp_sop           (if0.lh_pp_sop),
    .lh_pp_eop           (if0.lh_pp_eop),
    .lh_ecdsa_valid      (if0.lh_ecdsa_valid),
    .lh_ecdsa_hdr_data   (if0.lh_ecdsa_hdr_data),
    .lh_ecdsa_meta_data  (if0.lh_ecdsa_meta_data),
    .lh_ecdsa_sop        (if0.lh_ecdsa_sop),
    .lh_ecdsa_eop        (if0.lh_ecdsa_eop)
  );

  initial begin
    uvm_config_db#(virtual logic_hash_if)::set(null, "*", "vif", if0);
    run_test("t_main");
  end

endmodule
