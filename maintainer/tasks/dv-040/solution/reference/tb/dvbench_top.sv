`timescale 1ns/1ps
module dvbench_top;
    import uvm_pkg::*;
    import glb_pkg::*;
    glb_if vif();
    always #5 vif.nvdla_core_clk=~vif.nvdla_core_clk;
    always #7 vif.nvdla_falcon_clk=~vif.nvdla_falcon_clk;
    NV_NVDLA_glb dut(
        .cacc2glb_done_intr_pd(vif.cacc2glb_done_intr_pd),
        .cdma_dat2glb_done_intr_pd(vif.cdma_dat2glb_done_intr_pd),
        .cdma_wt2glb_done_intr_pd(vif.cdma_wt2glb_done_intr_pd),
        .cdp2glb_done_intr_pd(vif.cdp2glb_done_intr_pd),
        .csb2glb_req_pd(vif.csb2glb_req_pd),
        .csb2glb_req_pvld(vif.csb2glb_req_pvld),
        .direct_reset_(vif.direct_reset_),
        .nvdla_core_clk(vif.nvdla_core_clk),
        .nvdla_core_rstn(vif.nvdla_core_rstn),
        .nvdla_falcon_clk(vif.nvdla_falcon_clk),
        .nvdla_falcon_rstn(vif.nvdla_falcon_rstn),
        .pdp2glb_done_intr_pd(vif.pdp2glb_done_intr_pd),
        .sdp2glb_done_intr_pd(vif.sdp2glb_done_intr_pd),
        .test_mode(vif.test_mode),
        .core_intr(vif.core_intr),
        .csb2glb_req_prdy(vif.csb2glb_req_prdy),
        .glb2csb_resp_pd(vif.glb2csb_resp_pd),
        .glb2csb_resp_valid(vif.glb2csb_resp_valid)
    );
    dvbench_model predictor(
        .cacc2glb_done_intr_pd(vif.cacc2glb_done_intr_pd),
        .cdma_dat2glb_done_intr_pd(vif.cdma_dat2glb_done_intr_pd),
        .cdma_wt2glb_done_intr_pd(vif.cdma_wt2glb_done_intr_pd),
        .cdp2glb_done_intr_pd(vif.cdp2glb_done_intr_pd),
        .csb2glb_req_pd(vif.csb2glb_req_pd),
        .csb2glb_req_pvld(vif.csb2glb_req_pvld),
        .direct_reset_(vif.direct_reset_),
        .nvdla_core_clk(vif.nvdla_core_clk),
        .nvdla_core_rstn(vif.nvdla_core_rstn),
        .nvdla_falcon_clk(vif.nvdla_falcon_clk),
        .nvdla_falcon_rstn(vif.nvdla_falcon_rstn),
        .pdp2glb_done_intr_pd(vif.pdp2glb_done_intr_pd),
        .sdp2glb_done_intr_pd(vif.sdp2glb_done_intr_pd),
        .test_mode(vif.test_mode),
        .core_intr(vif.expected_core_intr),
        .csb2glb_req_prdy(vif.expected_csb2glb_req_prdy),
        .glb2csb_resp_pd(vif.expected_glb2csb_resp_pd),
        .glb2csb_resp_valid(vif.expected_glb2csb_resp_valid)
    );
    initial begin
        uvm_config_db#(virtual glb_if)::set(null,"*","vif",vif);
        run_test("dvbench_test");
    end
endmodule
