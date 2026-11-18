`timescale 1ns/1ps
package csbm_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class csbm_item extends uvm_sequence_item;
`uvm_object_utils(csbm_item)
bit pause_core,pause_falcon,pulse_core,pulse_falcon;
rand logic nvdla_core_rstn;
rand logic nvdla_falcon_rstn;
rand logic [31:0] pwrbus_ram_pd;
rand logic csb2nvdla_valid;
rand logic [15:0] csb2nvdla_addr;
rand logic [31:0] csb2nvdla_wdat;
rand logic csb2nvdla_write;
rand logic csb2nvdla_nposted;
rand logic csb2cfgrom_req_prdy;
rand logic cfgrom2csb_resp_valid;
rand logic [33:0] cfgrom2csb_resp_pd;
rand logic csb2glb_req_prdy;
rand logic glb2csb_resp_valid;
rand logic [33:0] glb2csb_resp_pd;
rand logic csb2mcif_req_prdy;
rand logic mcif2csb_resp_valid;
rand logic [33:0] mcif2csb_resp_pd;
rand logic csb2cdma_req_prdy;
rand logic cdma2csb_resp_valid;
rand logic [33:0] cdma2csb_resp_pd;
rand logic csb2csc_req_prdy;
rand logic csc2csb_resp_valid;
rand logic [33:0] csc2csb_resp_pd;
rand logic csb2cmac_a_req_prdy;
rand logic cmac_a2csb_resp_valid;
rand logic [33:0] cmac_a2csb_resp_pd;
rand logic csb2cmac_b_req_prdy;
rand logic cmac_b2csb_resp_valid;
rand logic [33:0] cmac_b2csb_resp_pd;
rand logic csb2cacc_req_prdy;
rand logic cacc2csb_resp_valid;
rand logic [33:0] cacc2csb_resp_pd;
rand logic csb2sdp_rdma_req_prdy;
rand logic sdp_rdma2csb_resp_valid;
rand logic [33:0] sdp_rdma2csb_resp_pd;
rand logic csb2sdp_req_prdy;
rand logic sdp2csb_resp_valid;
rand logic [33:0] sdp2csb_resp_pd;
rand logic csb2pdp_rdma_req_prdy;
rand logic pdp_rdma2csb_resp_valid;
rand logic [33:0] pdp_rdma2csb_resp_pd;
rand logic csb2pdp_req_prdy;
rand logic pdp2csb_resp_valid;
rand logic [33:0] pdp2csb_resp_pd;
rand logic csb2cdp_rdma_req_prdy;
rand logic cdp_rdma2csb_resp_valid;
rand logic [33:0] cdp_rdma2csb_resp_pd;
rand logic csb2cdp_req_prdy;
rand logic cdp2csb_resp_valid;
rand logic [33:0] cdp2csb_resp_pd;
function new(string name="native");super.new(name);endfunction
endclass
class csbm_driver extends uvm_driver #(csbm_item);
`uvm_component_utils(csbm_driver)
virtual csbm_if vif;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual csbm_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")endfunction
task run_phase(uvm_phase phase);csbm_item item;forever begin seq_item_port.get_next_item(item);#14.3;
if(item.pause_core&&vif.core_enabled)begin if(vif.nvdla_core_clk)@(negedge vif.nvdla_core_clk);vif.core_enabled=0;end else if(!item.pause_core)vif.core_enabled=1;
if(item.pause_falcon&&vif.falcon_enabled)begin if(vif.nvdla_falcon_clk)@(negedge vif.nvdla_falcon_clk);vif.falcon_enabled=0;end else if(!item.pause_falcon)vif.falcon_enabled=1;
vif.nvdla_core_rstn=item.nvdla_core_rstn;
vif.nvdla_falcon_rstn=item.nvdla_falcon_rstn;
vif.pwrbus_ram_pd=item.pwrbus_ram_pd;
vif.csb2nvdla_valid=item.csb2nvdla_valid;
vif.csb2nvdla_addr=item.csb2nvdla_addr;
vif.csb2nvdla_wdat=item.csb2nvdla_wdat;
vif.csb2nvdla_write=item.csb2nvdla_write;
vif.csb2nvdla_nposted=item.csb2nvdla_nposted;
vif.csb2cfgrom_req_prdy=item.csb2cfgrom_req_prdy;
vif.cfgrom2csb_resp_valid=item.cfgrom2csb_resp_valid;
vif.cfgrom2csb_resp_pd=item.cfgrom2csb_resp_pd;
vif.csb2glb_req_prdy=item.csb2glb_req_prdy;
vif.glb2csb_resp_valid=item.glb2csb_resp_valid;
vif.glb2csb_resp_pd=item.glb2csb_resp_pd;
vif.csb2mcif_req_prdy=item.csb2mcif_req_prdy;
vif.mcif2csb_resp_valid=item.mcif2csb_resp_valid;
vif.mcif2csb_resp_pd=item.mcif2csb_resp_pd;
vif.csb2cdma_req_prdy=item.csb2cdma_req_prdy;
vif.cdma2csb_resp_valid=item.cdma2csb_resp_valid;
vif.cdma2csb_resp_pd=item.cdma2csb_resp_pd;
vif.csb2csc_req_prdy=item.csb2csc_req_prdy;
vif.csc2csb_resp_valid=item.csc2csb_resp_valid;
vif.csc2csb_resp_pd=item.csc2csb_resp_pd;
vif.csb2cmac_a_req_prdy=item.csb2cmac_a_req_prdy;
vif.cmac_a2csb_resp_valid=item.cmac_a2csb_resp_valid;
vif.cmac_a2csb_resp_pd=item.cmac_a2csb_resp_pd;
vif.csb2cmac_b_req_prdy=item.csb2cmac_b_req_prdy;
vif.cmac_b2csb_resp_valid=item.cmac_b2csb_resp_valid;
vif.cmac_b2csb_resp_pd=item.cmac_b2csb_resp_pd;
vif.csb2cacc_req_prdy=item.csb2cacc_req_prdy;
vif.cacc2csb_resp_valid=item.cacc2csb_resp_valid;
vif.cacc2csb_resp_pd=item.cacc2csb_resp_pd;
vif.csb2sdp_rdma_req_prdy=item.csb2sdp_rdma_req_prdy;
vif.sdp_rdma2csb_resp_valid=item.sdp_rdma2csb_resp_valid;
vif.sdp_rdma2csb_resp_pd=item.sdp_rdma2csb_resp_pd;
vif.csb2sdp_req_prdy=item.csb2sdp_req_prdy;
vif.sdp2csb_resp_valid=item.sdp2csb_resp_valid;
vif.sdp2csb_resp_pd=item.sdp2csb_resp_pd;
vif.csb2pdp_rdma_req_prdy=item.csb2pdp_rdma_req_prdy;
vif.pdp_rdma2csb_resp_valid=item.pdp_rdma2csb_resp_valid;
vif.pdp_rdma2csb_resp_pd=item.pdp_rdma2csb_resp_pd;
vif.csb2pdp_req_prdy=item.csb2pdp_req_prdy;
vif.pdp2csb_resp_valid=item.pdp2csb_resp_valid;
vif.pdp2csb_resp_pd=item.pdp2csb_resp_pd;
vif.csb2cdp_rdma_req_prdy=item.csb2cdp_rdma_req_prdy;
vif.cdp_rdma2csb_resp_valid=item.cdp_rdma2csb_resp_valid;
vif.cdp_rdma2csb_resp_pd=item.cdp_rdma2csb_resp_pd;
vif.csb2cdp_req_prdy=item.csb2cdp_req_prdy;
vif.cdp2csb_resp_valid=item.cdp2csb_resp_valid;
vif.cdp2csb_resp_pd=item.cdp2csb_resp_pd;
if(item.pulse_core||item.pulse_falcon)begin wait(!vif.nvdla_core_clk&&!vif.nvdla_falcon_clk);#0.05;if(item.pulse_core)vif.nvdla_core_rstn=0;if(item.pulse_falcon)vif.nvdla_falcon_rstn=0;#0.1;if(item.pulse_core)vif.nvdla_core_rstn=1;if(item.pulse_falcon)vif.nvdla_falcon_rstn=1;end
#0.7;seq_item_port.item_done();end endtask
endclass
class csbm_scoreboard extends uvm_component;
`uvm_component_utils(csbm_scoreboard)
virtual csbm_if vif;int observations,mismatches;bit initialized;
covergroup activity with function sample(bit request_valid,bit request_ready,bit read_valid,bit write_valid);
request_cp:coverpoint request_valid;ready_cp:coverpoint request_ready;read_cp:coverpoint read_valid;write_cp:coverpoint write_valid;endgroup
function new(string name,uvm_component parent);super.new(name,parent);activity=new();endfunction
function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual csbm_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")endfunction
task compare();if(!initialized)return;observations++;activity.sample(vif.csb2nvdla_valid,vif.csb2nvdla_ready,vif.nvdla2csb_valid,vif.nvdla2csb_wr_complete);
if(vif.csb2nvdla_ready !== vif.expected_csb2nvdla_ready)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2nvdla_ready differs from independent event-ticket model")end
if(vif.nvdla2csb_valid !== vif.expected_nvdla2csb_valid)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","nvdla2csb_valid differs from independent event-ticket model")end
if(vif.nvdla2csb_data !== vif.expected_nvdla2csb_data)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","nvdla2csb_data differs from independent event-ticket model")end
if(vif.nvdla2csb_wr_complete !== vif.expected_nvdla2csb_wr_complete)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","nvdla2csb_wr_complete differs from independent event-ticket model")end
if(vif.csb2cfgrom_req_pvld !== vif.expected_csb2cfgrom_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cfgrom_req_pvld differs from independent event-ticket model")end
if(vif.csb2cfgrom_req_pd !== vif.expected_csb2cfgrom_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cfgrom_req_pd differs from independent event-ticket model")end
if(vif.csb2glb_req_pvld !== vif.expected_csb2glb_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2glb_req_pvld differs from independent event-ticket model")end
if(vif.csb2glb_req_pd !== vif.expected_csb2glb_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2glb_req_pd differs from independent event-ticket model")end
if(vif.csb2mcif_req_pvld !== vif.expected_csb2mcif_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2mcif_req_pvld differs from independent event-ticket model")end
if(vif.csb2mcif_req_pd !== vif.expected_csb2mcif_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2mcif_req_pd differs from independent event-ticket model")end
if(vif.csb2cdma_req_pvld !== vif.expected_csb2cdma_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cdma_req_pvld differs from independent event-ticket model")end
if(vif.csb2cdma_req_pd !== vif.expected_csb2cdma_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cdma_req_pd differs from independent event-ticket model")end
if(vif.csb2csc_req_pvld !== vif.expected_csb2csc_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2csc_req_pvld differs from independent event-ticket model")end
if(vif.csb2csc_req_pd !== vif.expected_csb2csc_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2csc_req_pd differs from independent event-ticket model")end
if(vif.csb2cmac_a_req_pvld !== vif.expected_csb2cmac_a_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cmac_a_req_pvld differs from independent event-ticket model")end
if(vif.csb2cmac_a_req_pd !== vif.expected_csb2cmac_a_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cmac_a_req_pd differs from independent event-ticket model")end
if(vif.csb2cmac_b_req_pvld !== vif.expected_csb2cmac_b_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cmac_b_req_pvld differs from independent event-ticket model")end
if(vif.csb2cmac_b_req_pd !== vif.expected_csb2cmac_b_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cmac_b_req_pd differs from independent event-ticket model")end
if(vif.csb2cacc_req_pvld !== vif.expected_csb2cacc_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cacc_req_pvld differs from independent event-ticket model")end
if(vif.csb2cacc_req_pd !== vif.expected_csb2cacc_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cacc_req_pd differs from independent event-ticket model")end
if(vif.csb2sdp_rdma_req_pvld !== vif.expected_csb2sdp_rdma_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2sdp_rdma_req_pvld differs from independent event-ticket model")end
if(vif.csb2sdp_rdma_req_pd !== vif.expected_csb2sdp_rdma_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2sdp_rdma_req_pd differs from independent event-ticket model")end
if(vif.csb2sdp_req_pvld !== vif.expected_csb2sdp_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2sdp_req_pvld differs from independent event-ticket model")end
if(vif.csb2sdp_req_pd !== vif.expected_csb2sdp_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2sdp_req_pd differs from independent event-ticket model")end
if(vif.csb2pdp_rdma_req_pvld !== vif.expected_csb2pdp_rdma_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2pdp_rdma_req_pvld differs from independent event-ticket model")end
if(vif.csb2pdp_rdma_req_pd !== vif.expected_csb2pdp_rdma_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2pdp_rdma_req_pd differs from independent event-ticket model")end
if(vif.csb2pdp_req_pvld !== vif.expected_csb2pdp_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2pdp_req_pvld differs from independent event-ticket model")end
if(vif.csb2pdp_req_pd !== vif.expected_csb2pdp_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2pdp_req_pd differs from independent event-ticket model")end
if(vif.csb2cdp_rdma_req_pvld !== vif.expected_csb2cdp_rdma_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cdp_rdma_req_pvld differs from independent event-ticket model")end
if(vif.csb2cdp_rdma_req_pd !== vif.expected_csb2cdp_rdma_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cdp_rdma_req_pd differs from independent event-ticket model")end
if(vif.csb2cdp_req_pvld !== vif.expected_csb2cdp_req_pvld)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cdp_req_pvld differs from independent event-ticket model")end
if(vif.csb2cdp_req_pd !== vif.expected_csb2cdp_req_pd)begin mismatches++;if(mismatches<=12) `uvm_error("NATIVE","csb2cdp_req_pd differs from independent event-ticket model")end
endtask
task run_phase(uvm_phase phase);fork begin forever begin @(vif.nvdla_core_clk or vif.nvdla_falcon_clk);#0.2;if(!vif.nvdla_core_rstn&&!vif.nvdla_falcon_rstn)initialized=1;compare();end end begin forever begin @(negedge vif.nvdla_core_rstn or negedge vif.nvdla_falcon_rstn);#0.01;compare();end end join endtask
function void check_phase(uvm_phase phase);if(observations<1000) `uvm_error("VACUITY","insufficient comparisons")if(mismatches>0) `uvm_error("TOTAL",$sformatf("%0d native differences",mismatches))endfunction
endclass
class csbm_sequence extends uvm_sequence #(csbm_item);
`uvm_object_utils(csbm_sequence)
function new(string name="stimulus");super.new(name);endfunction
task beat(input int mode=1,input int page=0,input int offset=0,input int flags=0,input int stalled=-1,input int reply=-1,input bit pause_core=0,input bit pause_falcon=0);
csbm_item item=csbm_item::type_id::create("native");start_item(item);
item.nvdla_core_rstn=0;
item.nvdla_falcon_rstn=0;
item.pwrbus_ram_pd=0;
item.csb2nvdla_valid=0;
item.csb2nvdla_addr=0;
item.csb2nvdla_wdat=0;
item.csb2nvdla_write=0;
item.csb2nvdla_nposted=0;
item.csb2cfgrom_req_prdy=0;
item.cfgrom2csb_resp_valid=0;
item.cfgrom2csb_resp_pd=0;
item.csb2glb_req_prdy=0;
item.glb2csb_resp_valid=0;
item.glb2csb_resp_pd=0;
item.csb2mcif_req_prdy=0;
item.mcif2csb_resp_valid=0;
item.mcif2csb_resp_pd=0;
item.csb2cdma_req_prdy=0;
item.cdma2csb_resp_valid=0;
item.cdma2csb_resp_pd=0;
item.csb2csc_req_prdy=0;
item.csc2csb_resp_valid=0;
item.csc2csb_resp_pd=0;
item.csb2cmac_a_req_prdy=0;
item.cmac_a2csb_resp_valid=0;
item.cmac_a2csb_resp_pd=0;
item.csb2cmac_b_req_prdy=0;
item.cmac_b2csb_resp_valid=0;
item.cmac_b2csb_resp_pd=0;
item.csb2cacc_req_prdy=0;
item.cacc2csb_resp_valid=0;
item.cacc2csb_resp_pd=0;
item.csb2sdp_rdma_req_prdy=0;
item.sdp_rdma2csb_resp_valid=0;
item.sdp_rdma2csb_resp_pd=0;
item.csb2sdp_req_prdy=0;
item.sdp2csb_resp_valid=0;
item.sdp2csb_resp_pd=0;
item.csb2pdp_rdma_req_prdy=0;
item.pdp_rdma2csb_resp_valid=0;
item.pdp_rdma2csb_resp_pd=0;
item.csb2pdp_req_prdy=0;
item.pdp2csb_resp_valid=0;
item.pdp2csb_resp_pd=0;
item.csb2cdp_rdma_req_prdy=0;
item.cdp_rdma2csb_resp_valid=0;
item.cdp_rdma2csb_resp_pd=0;
item.csb2cdp_req_prdy=0;
item.cdp2csb_resp_valid=0;
item.cdp2csb_resp_pd=0;
item.nvdla_core_rstn=(mode!=0&&mode!=5);item.nvdla_falcon_rstn=(mode!=0&&mode!=6);item.pause_core=pause_core;item.pause_falcon=pause_falcon;item.pulse_core=(mode==3||mode==4);item.pulse_falcon=(mode==3||mode==7);
item.csb2nvdla_valid=(mode==2);item.csb2nvdla_addr=(page<<10)|offset;item.csb2nvdla_wdat=$urandom;item.csb2nvdla_write=flags[0];item.csb2nvdla_nposted=flags[1];item.pwrbus_ram_pd=$urandom;
item.csb2cfgrom_req_prdy=(stalled!=0);item.cfgrom2csb_resp_valid=(reply==0);item.cfgrom2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2glb_req_prdy=(stalled!=1);item.glb2csb_resp_valid=(reply==1);item.glb2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2mcif_req_prdy=(stalled!=2);item.mcif2csb_resp_valid=(reply==2);item.mcif2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2cdma_req_prdy=(stalled!=3);item.cdma2csb_resp_valid=(reply==3);item.cdma2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2csc_req_prdy=(stalled!=4);item.csc2csb_resp_valid=(reply==4);item.csc2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2cmac_a_req_prdy=(stalled!=5);item.cmac_a2csb_resp_valid=(reply==5);item.cmac_a2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2cmac_b_req_prdy=(stalled!=6);item.cmac_b2csb_resp_valid=(reply==6);item.cmac_b2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2cacc_req_prdy=(stalled!=7);item.cacc2csb_resp_valid=(reply==7);item.cacc2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2sdp_rdma_req_prdy=(stalled!=8);item.sdp_rdma2csb_resp_valid=(reply==8);item.sdp_rdma2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2sdp_req_prdy=(stalled!=9);item.sdp2csb_resp_valid=(reply==9);item.sdp2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2pdp_rdma_req_prdy=(stalled!=10);item.pdp_rdma2csb_resp_valid=(reply==10);item.pdp_rdma2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2pdp_req_prdy=(stalled!=11);item.pdp2csb_resp_valid=(reply==11);item.pdp2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2cdp_rdma_req_prdy=(stalled!=12);item.cdp_rdma2csb_resp_valid=(reply==12);item.cdp_rdma2csb_resp_pd={flags[0],1'b0,$urandom};
item.csb2cdp_req_prdy=(stalled!=13);item.cdp2csb_resp_valid=(reply==13);item.cdp2csb_resp_pd={flags[0],1'b0,$urandom};
if(mode==8)begin
item.pwrbus_ram_pd=$urandom;
item.csb2nvdla_valid=$urandom;
item.csb2nvdla_addr=$urandom;
item.csb2nvdla_wdat=$urandom;
item.csb2nvdla_write=$urandom;
item.csb2nvdla_nposted=$urandom;
item.csb2cfgrom_req_prdy=$urandom;
item.cfgrom2csb_resp_valid=$urandom;
item.cfgrom2csb_resp_pd={$urandom,$urandom};
item.csb2glb_req_prdy=$urandom;
item.glb2csb_resp_valid=$urandom;
item.glb2csb_resp_pd={$urandom,$urandom};
item.csb2mcif_req_prdy=$urandom;
item.mcif2csb_resp_valid=$urandom;
item.mcif2csb_resp_pd={$urandom,$urandom};
item.csb2cdma_req_prdy=$urandom;
item.cdma2csb_resp_valid=$urandom;
item.cdma2csb_resp_pd={$urandom,$urandom};
item.csb2csc_req_prdy=$urandom;
item.csc2csb_resp_valid=$urandom;
item.csc2csb_resp_pd={$urandom,$urandom};
item.csb2cmac_a_req_prdy=$urandom;
item.cmac_a2csb_resp_valid=$urandom;
item.cmac_a2csb_resp_pd={$urandom,$urandom};
item.csb2cmac_b_req_prdy=$urandom;
item.cmac_b2csb_resp_valid=$urandom;
item.cmac_b2csb_resp_pd={$urandom,$urandom};
item.csb2cacc_req_prdy=$urandom;
item.cacc2csb_resp_valid=$urandom;
item.cacc2csb_resp_pd={$urandom,$urandom};
item.csb2sdp_rdma_req_prdy=$urandom;
item.sdp_rdma2csb_resp_valid=$urandom;
item.sdp_rdma2csb_resp_pd={$urandom,$urandom};
item.csb2sdp_req_prdy=$urandom;
item.sdp2csb_resp_valid=$urandom;
item.sdp2csb_resp_pd={$urandom,$urandom};
item.csb2pdp_rdma_req_prdy=$urandom;
item.pdp_rdma2csb_resp_valid=$urandom;
item.pdp_rdma2csb_resp_pd={$urandom,$urandom};
item.csb2pdp_req_prdy=$urandom;
item.pdp2csb_resp_valid=$urandom;
item.pdp2csb_resp_pd={$urandom,$urandom};
item.csb2cdp_rdma_req_prdy=$urandom;
item.cdp_rdma2csb_resp_valid=$urandom;
item.cdp_rdma2csb_resp_pd={$urandom,$urandom};
item.csb2cdp_req_prdy=$urandom;
item.cdp2csb_resp_valid=$urandom;
item.cdp2csb_resp_pd={$urandom,$urandom};
end
finish_item(item);endtask
task body();
repeat(5)beat(0);repeat(20)beat();
for(int page=0;page<64;page++)for(int flags=0;flags<4;flags++)begin beat(2,page,(page*17+flags*341)%1024,flags);repeat(18)beat();end
for(int client_index=0;client_index<14;client_index++)begin beat(2,client_index,1023,3,client_index);repeat(24)beat(1,0,0,0,client_index);repeat(6)beat();for(int flags=0;flags<2;flags++)begin beat(1,0,0,flags,-1,client_index);repeat(24)beat();end end
for(int burst=0;burst<4;burst++)begin for(int index=0;index<10;index++)beat(2,(index+burst)%14,index*19,burst,-1,-1,1,0);repeat(4)beat(1,0,0,0,-1,-1,1,0);repeat(80)beat();end
for(int burst=0;burst<4;burst++)begin for(int index=0;index<10;index++)beat(1,0,0,index%2,-1,index%14,0,1);repeat(8)beat(1,0,0,0,-1,-1,0,1);repeat(80)beat();end
repeat(2000)beat(8);beat(3);repeat(80)beat();repeat(200)beat(8);beat(4);repeat(80)beat();repeat(200)beat(8);beat(7);repeat(80)beat();
repeat(4)beat(5);repeat(80)beat();repeat(4)beat(6);repeat(80)beat();repeat(5)beat(0);repeat(80)beat();
endtask
endclass
class dvbench_test extends uvm_test;
`uvm_component_utils(dvbench_test)
uvm_sequencer #(csbm_item) sequencer;csbm_driver driver;csbm_scoreboard scoreboard;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);sequencer=new("sequencer",this);driver=csbm_driver::type_id::create("driver",this);scoreboard=csbm_scoreboard::type_id::create("scoreboard",this);endfunction
function void connect_phase(uvm_phase phase);driver.seq_item_port.connect(sequencer.seq_item_export);endfunction
task run_phase(uvm_phase phase);csbm_sequence sequence_handle=csbm_sequence::type_id::create("stimulus");phase.raise_objection(this);sequence_handle.start(sequencer);#100;phase.drop_objection(this);endtask
function void report_phase(uvm_phase phase);uvm_report_server reports=uvm_report_server::get_server();if(reports.get_severity_count(UVM_ERROR)==0&&reports.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");endfunction
endclass
endpackage
