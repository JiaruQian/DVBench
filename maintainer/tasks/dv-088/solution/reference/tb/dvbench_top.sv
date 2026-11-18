`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import aluexe_pkg::*;
aluexe_if vif();
NV_NVDLA_bdma dut(
.nvdla_core_clk(vif.nvdla_core_clk),
.nvdla_core_rstn(vif.nvdla_core_rstn),
.bdma2csb_resp_valid(vif.bdma2csb_resp_valid),
.bdma2csb_resp_pd(vif.bdma2csb_resp_pd),
.bdma2glb_done_intr_pd(vif.bdma2glb_done_intr_pd),
.bdma2mcif_rd_cdt_lat_fifo_pop(vif.bdma2mcif_rd_cdt_lat_fifo_pop),
.bdma2mcif_rd_req_valid(vif.bdma2mcif_rd_req_valid),
.bdma2mcif_rd_req_ready(vif.bdma2mcif_rd_req_ready),
.bdma2mcif_rd_req_pd(vif.bdma2mcif_rd_req_pd),
.bdma2mcif_wr_req_valid(vif.bdma2mcif_wr_req_valid),
.bdma2mcif_wr_req_ready(vif.bdma2mcif_wr_req_ready),
.bdma2mcif_wr_req_pd(vif.bdma2mcif_wr_req_pd),
.csb2bdma_req_pvld(vif.csb2bdma_req_pvld),
.csb2bdma_req_prdy(vif.csb2bdma_req_prdy),
.csb2bdma_req_pd(vif.csb2bdma_req_pd),
.mcif2bdma_rd_rsp_valid(vif.mcif2bdma_rd_rsp_valid),
.mcif2bdma_rd_rsp_ready(vif.mcif2bdma_rd_rsp_ready),
.mcif2bdma_rd_rsp_pd(vif.mcif2bdma_rd_rsp_pd),
.mcif2bdma_wr_rsp_complete(vif.mcif2bdma_wr_rsp_complete),
.pwrbus_ram_pd(vif.pwrbus_ram_pd),
.dla_clk_ovr_on_sync(vif.dla_clk_ovr_on_sync),
.global_clk_ovr_on_sync(vif.global_clk_ovr_on_sync),
.tmc2slcg_disable_clock_gating(vif.tmc2slcg_disable_clock_gating)
);
dvbench_model predictor(
.nvdla_core_clk(vif.nvdla_core_clk),
.nvdla_core_rstn(vif.nvdla_core_rstn),
.bdma2csb_resp_valid(vif.expected_bdma2csb_resp_valid),
.bdma2csb_resp_pd(vif.expected_bdma2csb_resp_pd),
.bdma2glb_done_intr_pd(vif.expected_bdma2glb_done_intr_pd),
.bdma2mcif_rd_cdt_lat_fifo_pop(vif.expected_bdma2mcif_rd_cdt_lat_fifo_pop),
.bdma2mcif_rd_req_valid(vif.expected_bdma2mcif_rd_req_valid),
.bdma2mcif_rd_req_ready(vif.bdma2mcif_rd_req_ready),
.bdma2mcif_rd_req_pd(vif.expected_bdma2mcif_rd_req_pd),
.bdma2mcif_wr_req_valid(vif.expected_bdma2mcif_wr_req_valid),
.bdma2mcif_wr_req_ready(vif.bdma2mcif_wr_req_ready),
.bdma2mcif_wr_req_pd(vif.expected_bdma2mcif_wr_req_pd),
.csb2bdma_req_pvld(vif.csb2bdma_req_pvld),
.csb2bdma_req_prdy(vif.expected_csb2bdma_req_prdy),
.csb2bdma_req_pd(vif.csb2bdma_req_pd),
.mcif2bdma_rd_rsp_valid(vif.mcif2bdma_rd_rsp_valid),
.mcif2bdma_rd_rsp_ready(vif.expected_mcif2bdma_rd_rsp_ready),
.mcif2bdma_rd_rsp_pd(vif.mcif2bdma_rd_rsp_pd),
.mcif2bdma_wr_rsp_complete(vif.mcif2bdma_wr_rsp_complete),
.pwrbus_ram_pd(vif.pwrbus_ram_pd),
.dla_clk_ovr_on_sync(vif.dla_clk_ovr_on_sync),
.global_clk_ovr_on_sync(vif.global_clk_ovr_on_sync),
.tmc2slcg_disable_clock_gating(vif.tmc2slcg_disable_clock_gating)
);
initial begin vif.nvdla_core_clk=0;forever #5 vif.nvdla_core_clk=~vif.nvdla_core_clk;end
initial begin uvm_config_db#(virtual aluexe_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
