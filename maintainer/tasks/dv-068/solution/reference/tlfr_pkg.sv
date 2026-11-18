`timescale 1ns/1ps
package tlfr_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class tlfr_item extends uvm_sequence_item;
    `uvm_object_utils(tlfr_item)
    rand logic [12:0] auto_in_a_bits_address;
    rand logic auto_in_a_bits_corrupt;
    rand logic [63:0] auto_in_a_bits_data;
    rand logic [7:0] auto_in_a_bits_mask;
    rand logic [2:0] auto_in_a_bits_opcode;
    rand logic [2:0] auto_in_a_bits_param;
    rand logic [2:0] auto_in_a_bits_size;
    rand logic [5:0] auto_in_a_bits_source;
    rand logic auto_in_a_valid;
    rand logic auto_in_d_ready;
    rand logic auto_out_a_ready;
    rand logic [63:0] auto_out_d_bits_data;
    rand logic [2:0] auto_out_d_bits_opcode;
    rand logic [1:0] auto_out_d_bits_size;
    rand logic [9:0] auto_out_d_bits_source;
    rand logic auto_out_d_valid;
    rand logic reset;
    function new(string name="tlfr_item"); super.new(name); endfunction
  endclass
  class tlfr_driver extends uvm_driver #(tlfr_item);
    `uvm_component_utils(tlfr_driver)
    virtual tlfr_if vif;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual tlfr_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task run_phase(uvm_phase phase); tlfr_item item; forever begin seq_item_port.get_next_item(item); @(negedge vif.clock);
      vif.auto_in_a_bits_address=item.auto_in_a_bits_address;
      vif.auto_in_a_bits_corrupt=item.auto_in_a_bits_corrupt;
      vif.auto_in_a_bits_data=item.auto_in_a_bits_data;
      vif.auto_in_a_bits_mask=item.auto_in_a_bits_mask;
      vif.auto_in_a_bits_opcode=item.auto_in_a_bits_opcode;
      vif.auto_in_a_bits_param=item.auto_in_a_bits_param;
      vif.auto_in_a_bits_size=item.auto_in_a_bits_size;
      vif.auto_in_a_bits_source=item.auto_in_a_bits_source;
      vif.auto_in_a_valid=item.auto_in_a_valid;
      vif.auto_in_d_ready=item.auto_in_d_ready;
      vif.auto_out_a_ready=item.auto_out_a_ready;
      vif.auto_out_d_bits_data=item.auto_out_d_bits_data;
      vif.auto_out_d_bits_opcode=item.auto_out_d_bits_opcode;
      vif.auto_out_d_bits_size=item.auto_out_d_bits_size;
      vif.auto_out_d_bits_source=item.auto_out_d_bits_source;
      vif.auto_out_d_valid=item.auto_out_d_valid;
      vif.reset=item.reset;
      @(posedge vif.clock); #3; seq_item_port.item_done(); end endtask
  endclass
  class tlfr_scoreboard extends uvm_component;
    `uvm_component_utils(tlfr_scoreboard)
    virtual tlfr_if vif;
    int observations,mismatches; bit initialized;
    covergroup activity with function sample(bit rst,bit av,bit dv,bit[2:0] sz,bit[2:0] op);
      reset_cp: coverpoint rst; a_valid_cp: coverpoint av; d_valid_cp: coverpoint dv; size_cp: coverpoint sz; opcode_cp: coverpoint op;
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent); activity=new(); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual tlfr_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task compare(); if(!initialized) return; observations++; activity.sample(vif.reset,vif.auto_in_a_valid,vif.auto_out_d_valid,vif.auto_in_a_bits_size,vif.auto_in_a_bits_opcode);
      if(vif.auto_in_a_ready !== vif.expected_auto_in_a_ready) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_in_a_ready differs from independent transaction predictor") end
      if(vif.auto_in_d_bits_data !== vif.expected_auto_in_d_bits_data) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_in_d_bits_data differs from independent transaction predictor") end
      if(vif.auto_in_d_bits_opcode !== vif.expected_auto_in_d_bits_opcode) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_in_d_bits_opcode differs from independent transaction predictor") end
      if(vif.auto_in_d_bits_size !== vif.expected_auto_in_d_bits_size) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_in_d_bits_size differs from independent transaction predictor") end
      if(vif.auto_in_d_bits_source !== vif.expected_auto_in_d_bits_source) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_in_d_bits_source differs from independent transaction predictor") end
      if(vif.auto_in_d_valid !== vif.expected_auto_in_d_valid) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_in_d_valid differs from independent transaction predictor") end
      if(vif.auto_out_a_bits_address !== vif.expected_auto_out_a_bits_address) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_a_bits_address differs from independent transaction predictor") end
      if(vif.auto_out_a_bits_corrupt !== vif.expected_auto_out_a_bits_corrupt) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_a_bits_corrupt differs from independent transaction predictor") end
      if(vif.auto_out_a_bits_data !== vif.expected_auto_out_a_bits_data) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_a_bits_data differs from independent transaction predictor") end
      if(vif.auto_out_a_bits_mask !== vif.expected_auto_out_a_bits_mask) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_a_bits_mask differs from independent transaction predictor") end
      if(vif.auto_out_a_bits_opcode !== vif.expected_auto_out_a_bits_opcode) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_a_bits_opcode differs from independent transaction predictor") end
      if(vif.auto_out_a_bits_param !== vif.expected_auto_out_a_bits_param) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_a_bits_param differs from independent transaction predictor") end
      if(vif.auto_out_a_bits_size !== vif.expected_auto_out_a_bits_size) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_a_bits_size differs from independent transaction predictor") end
      if(vif.auto_out_a_bits_source !== vif.expected_auto_out_a_bits_source) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_a_bits_source differs from independent transaction predictor") end
      if(vif.auto_out_a_valid !== vif.expected_auto_out_a_valid) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_a_valid differs from independent transaction predictor") end
      if(vif.auto_out_d_ready !== vif.expected_auto_out_d_ready) begin mismatches++; if(mismatches<=12) `uvm_error("COMPARE","auto_out_d_ready differs from independent transaction predictor") end
    endtask
    task run_phase(uvm_phase phase); forever begin @(negedge vif.clock); #2; compare(); @(posedge vif.clock); #2; if(vif.reset) initialized=1; compare(); end endtask
    function void check_phase(uvm_phase phase); if(observations<1000 && mismatches==0) `uvm_error("VACUITY","insufficient comparisons") if(mismatches>0) `uvm_error("TOTAL",$sformatf("%0d mismatches",mismatches)) endfunction
  endclass

  class tlfr_sequence extends uvm_sequence #(tlfr_item);
    `uvm_object_utils(tlfr_sequence)
    function new(string name="tlfr_sequence"); super.new(name); endfunction
    task beat(int mode=1,int op=4,int size=3,int source=0,int address='h1000,int mask=255,int av=0,int ar=1,int dv=0,int dr=1,int dop=1,int ds=3,int dsource=0);
      tlfr_item item=tlfr_item::type_id::create("drive");
      start_item(item); if(!item.randomize()) `uvm_fatal("RANDOM","randomization failed")
      item.reset=(mode==0 || mode==2);
      if(mode==2) begin
        item.auto_out_d_bits_size=ds; item.auto_out_d_bits_source=dsource;
        item.auto_in_a_bits_data=source[0] ? '1:'0; item.auto_out_d_bits_data=source[0] ? '0:'1;
      end
      if(mode!=2) begin
        item.auto_in_a_bits_opcode=op; item.auto_in_a_bits_param=0; item.auto_in_a_bits_size=size;
        item.auto_in_a_bits_source=source; item.auto_in_a_bits_address=address; item.auto_in_a_bits_mask=mask;
        item.auto_in_a_bits_corrupt=(op==4 ? 0 : source[0]); item.auto_in_a_valid=av; item.auto_out_a_ready=ar;
        item.auto_out_d_valid=dv; item.auto_in_d_ready=dr; item.auto_out_d_bits_opcode=dop;
        item.auto_out_d_bits_size=ds; item.auto_out_d_bits_source=dsource;
      end
      finish_item(item);
    endtask
    task transaction(int op,int size,int source,int lane,int pattern,bit restart=1,bit phase=1);
      int count,mask,address;
      count=size<4 ? 1 : 1<<(size-3);
      address='h1000 | ((lane<<size)&'hfff);
      mask=size>=3 ? 255 : ((1<<(1<<size))-1)<<(address&7);
      if(op==1) mask &= pattern;
      if(restart) begin beat(0); beat(0); end
      beat();
      for(int index=0;index<count;index++) begin
        beat(1,op,size,source,address,mask,(op!=4 || index==0),0);
        beat(1,op,size,source,address,mask,(op!=4 || index==0),1);
      end
      beat();
      for(int index=0;index<count;index++) begin
        if(op==4 || index==count-1) beat(1,4,3,0,'h1000,255,0,1,1,0,(op==4 ? 1:0),(size<3 ? size:3),(source<<4)|(phase<<3)|(count-1-index));
        beat(1,4,3,0,'h1000,255,0,1,1,1,(op==4 ? 1:0),(size<3 ? size:3),(source<<4)|(phase<<3)|(count-1-index));
      end
      repeat(3) beat();
    endtask
    task body();
      beat(0); beat(0);
      repeat(200) beat(2);
      for(int fragment=0;fragment<8;fragment++)
        for(int size=0;size<4;size++) beat(.mode(2),.source(fragment),.ds(size),.dsource(fragment));
      beat(0); beat(0); beat();
      for(int opcode_index=0;opcode_index<3;opcode_index++)
        for(int size=0;size<7;size++)
          for(int sample=0;sample<6;sample++)
            transaction(opcode_index==2 ? 4:opcode_index,size,sample<3 ? sample:sample==3 ? 9:sample==4 ? 16:47,sample, sample[0] ? 'haa:'h55);
      transaction(4,6,32,0,255);
      transaction(0,5,33,1,255,0,0);
      transaction(4,4,34,2,255,0,1);
      for(int fragment=1;fragment<8;fragment++) begin
        beat(0); beat();
        beat(1,4,3,0,'h1000,255,0,1,1,0,0,3,fragment);
        for(int tail=0;tail<9;tail++) beat(1,4,3,0,'h1000,255,0,1,0,1,1,tail%4,tail);
      end
      beat(0); repeat(5) beat();
    endtask
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    uvm_sequencer #(tlfr_item) sequencer; tlfr_driver driver; tlfr_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); sequencer=new("sequencer",this); driver=tlfr_driver::type_id::create("driver",this); scoreboard=tlfr_scoreboard::type_id::create("scoreboard",this); endfunction
    function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
    task run_phase(uvm_phase phase);
      tlfr_sequence sequence_handle=tlfr_sequence::type_id::create("sequence_handle");
      phase.raise_objection(this);
      fork
        begin sequence_handle.start(sequencer); repeat(3) @(posedge driver.vif.clock); end
        begin wait(scoreboard.mismatches>0); end
      join_any
      disable fork;
      sequencer.stop_sequences();
      phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase); uvm_report_server reports=uvm_report_server::get_server(); if(reports.get_severity_count(UVM_ERROR)==0 && reports.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED"); endfunction
  endclass
endpackage
