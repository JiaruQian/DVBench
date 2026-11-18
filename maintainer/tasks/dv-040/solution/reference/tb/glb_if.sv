`timescale 1ns/1ps
interface glb_if;
    logic [1:0] cacc2glb_done_intr_pd=0;
    logic [1:0] cdma_dat2glb_done_intr_pd=0;
    logic [1:0] cdma_wt2glb_done_intr_pd=0;
    logic [1:0] cdp2glb_done_intr_pd=0;
    logic [62:0] csb2glb_req_pd=0;
    logic csb2glb_req_pvld=0;
    logic direct_reset_=1;
    logic nvdla_core_clk=0;
    logic nvdla_core_rstn=0;
    logic nvdla_falcon_clk=0;
    logic nvdla_falcon_rstn=0;
    logic [1:0] pdp2glb_done_intr_pd=0;
    logic [1:0] sdp2glb_done_intr_pd=0;
    logic test_mode=0;
    logic core_intr;
    logic expected_core_intr;
    logic csb2glb_req_prdy;
    logic expected_csb2glb_req_prdy;
    logic [33:0] glb2csb_resp_pd;
    logic [33:0] expected_glb2csb_resp_pd;
    logic glb2csb_resp_valid;
    logic expected_glb2csb_resp_valid;
    bit checking=0,stop_requested=0;
endinterface
