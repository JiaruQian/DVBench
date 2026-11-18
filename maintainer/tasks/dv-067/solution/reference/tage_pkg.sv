`timescale 1ns/1ps
package tage_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class tage_item extends uvm_sequence_item;
    `uvm_object_utils(tage_item)
    rand logic [63:0] io_f1_req_ghist;
    rand logic [39:0] io_f1_req_pc;
    rand logic io_f1_req_valid;
    rand logic io_update_alloc_0;
    rand logic io_update_alloc_1;
    rand logic io_update_alloc_2;
    rand logic io_update_alloc_3;
    rand logic [63:0] io_update_hist;
    rand logic io_update_mask_0;
    rand logic io_update_mask_1;
    rand logic io_update_mask_2;
    rand logic io_update_mask_3;
    rand logic [2:0] io_update_old_ctr_0;
    rand logic [2:0] io_update_old_ctr_1;
    rand logic [2:0] io_update_old_ctr_2;
    rand logic [2:0] io_update_old_ctr_3;
    rand logic [39:0] io_update_pc;
    rand logic io_update_taken_0;
    rand logic io_update_taken_1;
    rand logic io_update_taken_2;
    rand logic io_update_taken_3;
    rand logic [1:0] io_update_u_0;
    rand logic [1:0] io_update_u_1;
    rand logic [1:0] io_update_u_2;
    rand logic [1:0] io_update_u_3;
    rand logic io_update_u_mask_0;
    rand logic io_update_u_mask_1;
    rand logic io_update_u_mask_2;
    rand logic io_update_u_mask_3;
    rand logic reset;
    function new(string name="tage_item"); super.new(name); endfunction
  endclass
  class tage_driver extends uvm_driver #(tage_item);
    `uvm_component_utils(tage_driver)
    virtual tage_if vif;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual tage_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task run_phase(uvm_phase phase); tage_item item; forever begin seq_item_port.get_next_item(item); @(negedge vif.clock);
      vif.io_f1_req_ghist=item.io_f1_req_ghist;
      vif.io_f1_req_pc=item.io_f1_req_pc;
      vif.io_f1_req_valid=item.io_f1_req_valid;
      vif.io_update_alloc_0=item.io_update_alloc_0;
      vif.io_update_alloc_1=item.io_update_alloc_1;
      vif.io_update_alloc_2=item.io_update_alloc_2;
      vif.io_update_alloc_3=item.io_update_alloc_3;
      vif.io_update_hist=item.io_update_hist;
      vif.io_update_mask_0=item.io_update_mask_0;
      vif.io_update_mask_1=item.io_update_mask_1;
      vif.io_update_mask_2=item.io_update_mask_2;
      vif.io_update_mask_3=item.io_update_mask_3;
      vif.io_update_old_ctr_0=item.io_update_old_ctr_0;
      vif.io_update_old_ctr_1=item.io_update_old_ctr_1;
      vif.io_update_old_ctr_2=item.io_update_old_ctr_2;
      vif.io_update_old_ctr_3=item.io_update_old_ctr_3;
      vif.io_update_pc=item.io_update_pc;
      vif.io_update_taken_0=item.io_update_taken_0;
      vif.io_update_taken_1=item.io_update_taken_1;
      vif.io_update_taken_2=item.io_update_taken_2;
      vif.io_update_taken_3=item.io_update_taken_3;
      vif.io_update_u_0=item.io_update_u_0;
      vif.io_update_u_1=item.io_update_u_1;
      vif.io_update_u_2=item.io_update_u_2;
      vif.io_update_u_3=item.io_update_u_3;
      vif.io_update_u_mask_0=item.io_update_u_mask_0;
      vif.io_update_u_mask_1=item.io_update_u_mask_1;
      vif.io_update_u_mask_2=item.io_update_u_mask_2;
      vif.io_update_u_mask_3=item.io_update_u_mask_3;
      vif.reset=item.reset;
      @(posedge vif.clock); #3; seq_item_port.item_done(); end endtask
  endclass
  class tage_scoreboard extends uvm_component;
    `uvm_component_utils(tage_scoreboard)
    virtual tage_if vif;
    int observations,mismatches;
    bit initialized;
    covergroup activity with function sample(bit reset,bit valid,bit[3:0] masks,bit[3:0] useful_masks);
      reset_cp: coverpoint reset;
      read_cp: coverpoint valid;
      writes_cp: coverpoint masks;
      usefulness_cp: coverpoint useful_masks;
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent); activity=new(); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual tage_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task compare(); if(!initialized) return; observations++;
      activity.sample(vif.reset,vif.io_f1_req_valid,{vif.io_update_mask_3,vif.io_update_mask_2,vif.io_update_mask_1,vif.io_update_mask_0},{vif.io_update_u_mask_3,vif.io_update_u_mask_2,vif.io_update_u_mask_1,vif.io_update_u_mask_0});
      if(vif.io_f3_resp_0_bits_ctr !== vif.expected_io_f3_resp_0_bits_ctr) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_0_bits_ctr differs from independent table predictor") end
      if(vif.io_f3_resp_0_bits_u !== vif.expected_io_f3_resp_0_bits_u) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_0_bits_u differs from independent table predictor") end
      if(vif.io_f3_resp_0_valid !== vif.expected_io_f3_resp_0_valid) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_0_valid differs from independent table predictor") end
      if(vif.io_f3_resp_1_bits_ctr !== vif.expected_io_f3_resp_1_bits_ctr) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_1_bits_ctr differs from independent table predictor") end
      if(vif.io_f3_resp_1_bits_u !== vif.expected_io_f3_resp_1_bits_u) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_1_bits_u differs from independent table predictor") end
      if(vif.io_f3_resp_1_valid !== vif.expected_io_f3_resp_1_valid) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_1_valid differs from independent table predictor") end
      if(vif.io_f3_resp_2_bits_ctr !== vif.expected_io_f3_resp_2_bits_ctr) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_2_bits_ctr differs from independent table predictor") end
      if(vif.io_f3_resp_2_bits_u !== vif.expected_io_f3_resp_2_bits_u) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_2_bits_u differs from independent table predictor") end
      if(vif.io_f3_resp_2_valid !== vif.expected_io_f3_resp_2_valid) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_2_valid differs from independent table predictor") end
      if(vif.io_f3_resp_3_bits_ctr !== vif.expected_io_f3_resp_3_bits_ctr) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_3_bits_ctr differs from independent table predictor") end
      if(vif.io_f3_resp_3_bits_u !== vif.expected_io_f3_resp_3_bits_u) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_3_bits_u differs from independent table predictor") end
      if(vif.io_f3_resp_3_valid !== vif.expected_io_f3_resp_3_valid) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","io_f3_resp_3_valid differs from independent table predictor") end
    endtask
    task run_phase(uvm_phase phase); forever begin @(negedge vif.clock); #2; compare(); @(posedge vif.clock); #2; if(vif.reset) initialized=1; compare(); end endtask
    function void check_phase(uvm_phase phase); if(observations<1000) `uvm_error("VACUITY","insufficient comparisons") if(mismatches>0) `uvm_error("TOTAL",$sformatf("%0d mismatches",mismatches)) endfunction
  endclass
  class tage_sequence extends uvm_sequence #(tage_item);
    `uvm_object_utils(tage_sequence)
    function new(string name="tage_sequence"); super.new(name); endfunction
    task beat(int mode,int index=0,int tag=3,int mask=15,int taken=15,int allocation=15,int u_mask=15,int useful=3,int old=7);
      tage_item item=tage_item::type_id::create("drive");
      start_item(item); if(!item.randomize()) `uvm_fatal("RANDOM","randomization failed")
      item.reset=(mode==0);
      if(mode!=4) begin
        item.io_f1_req_valid=1; item.io_f1_req_pc=(tag<<11)|(index<<4); item.io_f1_req_ghist=0;
        item.io_update_pc=(tag<<11)|(index<<4); item.io_update_hist=0;
        item.io_update_mask_0=(mode==1 ? mask[0] : 0); item.io_update_alloc_0=allocation[0]; item.io_update_taken_0=taken[0];
        item.io_update_u_mask_0=(mode==1 ? u_mask[0] : 0); item.io_update_u_0=useful; item.io_update_old_ctr_0=old;
        item.io_update_mask_1=(mode==1 ? mask[1] : 0); item.io_update_alloc_1=allocation[1]; item.io_update_taken_1=taken[1];
        item.io_update_u_mask_1=(mode==1 ? u_mask[1] : 0); item.io_update_u_1=useful; item.io_update_old_ctr_1=old;
        item.io_update_mask_2=(mode==1 ? mask[2] : 0); item.io_update_alloc_2=allocation[2]; item.io_update_taken_2=taken[2];
        item.io_update_u_mask_2=(mode==1 ? u_mask[2] : 0); item.io_update_u_2=useful; item.io_update_old_ctr_2=old;
        item.io_update_mask_3=(mode==1 ? mask[3] : 0); item.io_update_alloc_3=allocation[3]; item.io_update_taken_3=taken[3];
        item.io_update_u_mask_3=(mode==1 ? u_mask[3] : 0); item.io_update_u_3=useful; item.io_update_old_ctr_3=old;
      end
      finish_item(item);
    endtask
    task reset_high_aging_collision();
      beat(0);
      repeat(128) beat(2,2,3);
      beat(1,2,3,15,15,15,15,3);
      repeat(266238) beat(2,2,3);
      beat(0,2,3);
      repeat(132) beat(2,2,3);
    endtask
    task body();
      repeat(2) beat(0); repeat(132) beat(2);
      for(int index=0;index<128;index++) beat(1,index,3);
      for(int old=0;old<8;old++) begin
        beat(1,old,10+old,15,15,0,15,3,old); beat(2,old,10+old);
        beat(1,old,10+old,15,0,0,15,2,7-old); beat(2,old,10+old);
      end
      for(int mask=0;mask<16;mask++) begin
        beat(1,31,7,mask,mask,15,15-mask,mask%4,0); beat(2,31,7);
        beat(1,32,8,15,15,15,15,3);
        repeat(10) beat(1,31,7,mask,mask,0,mask,mask%4,0); beat(2,31,7);
      end
      for(int index=0;index<2000;index++) beat(4);
      for(int index=0;index<128;index++) beat(1,index,3,15,15,15,15,3);
      for(int cycle=0;cycle<270000;cycle++) beat(2,cycle%128,3);
      repeat(2) beat(0); repeat(132) beat(2);
      for(int index=0;index<128;index++) beat(2,index,3);
      reset_high_aging_collision();
    endtask
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    uvm_sequencer #(tage_item) sequencer; tage_driver driver; tage_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); sequencer=new("sequencer",this); driver=tage_driver::type_id::create("driver",this); scoreboard=tage_scoreboard::type_id::create("scoreboard",this); endfunction
    function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
    task run_phase(uvm_phase phase); tage_sequence sequence_handle=tage_sequence::type_id::create("sequence_handle"); phase.raise_objection(this); sequence_handle.start(sequencer); repeat(3) @(posedge driver.vif.clock); phase.drop_objection(this); endtask
    function void report_phase(uvm_phase phase); uvm_report_server reports=uvm_report_server::get_server(); if(reports.get_severity_count(UVM_ERROR)==0 && reports.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED"); endfunction
  endclass
endpackage
