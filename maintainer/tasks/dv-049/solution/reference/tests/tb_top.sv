// tb_top.sv -- XGMII 10G PCS TX UVM top
module dvbench_top;
  import uvm_pkg::*;
  import pcs10g_pkg::*;

  pcs10g_if vif ();

  xgmii_pcs_10g_tx #(.XGMII_DATA_W(64)) dut (
    .clk        (vif.clk),
    .nreset     (vif.nreset),
    .xgmii_txd_i(vif.txd),
    .xgmii_txc_i(vif.txc),
    .ready_o    (vif.ready_o),
    .data_o     (vif.data_o)
  );

  dvbench_model #(.XGMII_DATA_W(64)) expected_model (
    .clk(vif.clk),.nreset(vif.nreset),.xgmii_txd_i(vif.txd),.xgmii_txc_i(vif.txc),
    .ready_o(vif.expected_ready),.data_o(vif.expected_data));
  initial begin
    uvm_config_db #(virtual pcs10g_if)::set(null, "*", "vif", vif);
    run_test("dvbench_test");
  end
endmodule
