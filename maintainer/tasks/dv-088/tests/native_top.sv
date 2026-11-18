`timescale 1ns/1ps
module native_top;
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
integer index, seed, ignored, mismatches;
initial begin
 seed=1; ignored=$value$plusargs("SEED=%d",seed); ignored=$urandom(seed); mismatches=0; vif.drive('0);
 for(index=0;index<4096;index=index+1) begin
 @(negedge vif.nvdla_core_clk); vif.prepare(index); #2;
 if(vif.actual_bus !== vif.expected_bus) begin
  mismatches=mismatches+1; if(mismatches<5) $display("MISMATCH sample=%0d actual=%h expected=%h",index,vif.actual_bus,vif.expected_bus);
 end
 end
 $display("OBSERVATIONS=4096 MISMATCHES=%0d",mismatches);
 if(mismatches) $fatal(1,"MODEL_MISMATCH");
 $display("BASELINE_PASS"); $finish;
end
endmodule
