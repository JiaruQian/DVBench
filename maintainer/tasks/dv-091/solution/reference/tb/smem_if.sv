`timescale 1ns/1ps
interface smem_if;
        logic clk=0;
        logic rst_n=0;
        logic core_req_valid_i=0;
        logic [2:0] core_req_instrid_i=0;
        logic core_req_iswrite_i=0;
        logic [23:0] core_req_tag_i=0;
        logic [4:0] core_req_setidx_i=0;
        logic [3:0] core_req_activemask_i=0;
        logic [3:0] core_req_blockoffset_i=0;
        logic [15:0] core_req_wordoffset1h_i=0;
        logic [127:0] core_req_data_i=0;
        logic core_rsp_ready_i=0;
        logic core_req_ready_o;
        logic expected_core_req_ready_o;
        logic core_rsp_valid_o;
        logic expected_core_rsp_valid_o;
        logic core_rsp_iswrite_o;
        logic expected_core_rsp_iswrite_o;
        logic [2:0] core_rsp_instrid_o;
        logic [2:0] expected_core_rsp_instrid_o;
        logic [127:0] core_rsp_data_o;
        logic [127:0] expected_core_rsp_data_o;
        logic [3:0] core_rsp_activemask_o;
        logic [3:0] expected_core_rsp_activemask_o;
    bit checking=0,stop_requested=0;
endinterface
