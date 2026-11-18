`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*; import reference_pkg::*;
reference_if vif();
montre_sdram dut(.az_addr(vif.az_addr),.az_be_n(vif.az_be_n),.az_cs(vif.az_cs),.az_data(vif.az_data),.az_rd_n(vif.az_rd_n),.az_wr_n(vif.az_wr_n),.clk(vif.clk),.reset_n(vif.reset_n),.za_data(vif.za_data),.za_valid(vif.za_valid),.za_waitrequest(vif.za_waitrequest),.zs_addr(vif.zs_addr),.zs_ba(vif.zs_ba),.zs_cas_n(vif.zs_cas_n),.zs_cke(vif.zs_cke),.zs_cs_n(vif.zs_cs_n),.zs_dq(vif.zs_dq),.zs_dqm(vif.zs_dqm),.zs_ras_n(vif.zs_ras_n),.zs_we_n(vif.zs_we_n));
dvbench_model predictor_model(.az_addr(vif.az_addr),.az_be_n(vif.az_be_n),.az_cs(vif.az_cs),.az_data(vif.az_data),.az_rd_n(vif.az_rd_n),.az_wr_n(vif.az_wr_n),.clk(vif.clk),.reset_n(vif.reset_n),.za_data(vif.predicted_za_data),.za_valid(vif.predicted_za_valid),.za_waitrequest(vif.predicted_za_waitrequest),.zs_addr(vif.predicted_zs_addr),.zs_ba(vif.predicted_zs_ba),.zs_cas_n(vif.predicted_zs_cas_n),.zs_cke(vif.predicted_zs_cke),.zs_cs_n(vif.predicted_zs_cs_n),.zs_dq(vif.predicted_zs_dq),.zs_dqm(vif.predicted_zs_dqm),.zs_ras_n(vif.predicted_zs_ras_n),.zs_we_n(vif.predicted_zs_we_n));
initial begin uvm_config_db#(virtual reference_if)::set(null,"*","vif",vif); run_test("dvbench_test"); end
endmodule
