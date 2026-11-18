`timescale 1ns/1ps
package vmult_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class vmult_item extends uvm_sequence_item;
    `uvm_object_utils(vmult_item)
    bit reset_pulse;
    rand logic [5:0] ctrl_alu_fn_i;
    rand logic [7:0] ctrl_reg_idxw_i;
    rand logic ctrl_reverse_i;
    rand logic [2:0] ctrl_wid_i;
    rand logic ctrl_wvd_i;
    rand logic ctrl_wxd_i;
    rand logic [127:0] in1_i;
    rand logic [127:0] in2_i;
    rand logic [127:0] in3_i;
    rand logic in_valid_i;
    rand logic [3:0] mask_i;
    rand logic outv_ready_i;
    rand logic outx_ready_i;
    rand logic rst_n;
    function new(string name="vmult_item"); super.new(name); endfunction
  endclass
  class vmult_driver extends uvm_driver #(vmult_item);
    `uvm_component_utils(vmult_driver)
    virtual vmult_if vif;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual vmult_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task run_phase(uvm_phase phase); vmult_item item; forever begin seq_item_port.get_next_item(item); @(negedge vif.clk);
      vif.ctrl_alu_fn_i=item.ctrl_alu_fn_i;
      vif.ctrl_reg_idxw_i=item.ctrl_reg_idxw_i;
      vif.ctrl_reverse_i=item.ctrl_reverse_i;
      vif.ctrl_wid_i=item.ctrl_wid_i;
      vif.ctrl_wvd_i=item.ctrl_wvd_i;
      vif.ctrl_wxd_i=item.ctrl_wxd_i;
      vif.in1_i=item.in1_i;
      vif.in2_i=item.in2_i;
      vif.in3_i=item.in3_i;
      vif.in_valid_i=item.in_valid_i;
      vif.mask_i=item.mask_i;
      vif.outv_ready_i=item.outv_ready_i;
      vif.outx_ready_i=item.outx_ready_i;
      vif.rst_n=item.rst_n;
      if(item.reset_pulse) begin #1;vif.rst_n=0;#1;vif.rst_n=1;end
      @(posedge vif.clk); #3; seq_item_port.item_done(); end endtask
  endclass
  class vmult_scoreboard extends uvm_component;
    `uvm_component_utils(vmult_scoreboard)
    virtual vmult_if vif;
    int observations,mismatches; bit initialized;
    covergroup activity with function sample(bit reset,bit valid,bit[5:0] function_code,bit reverse,bit scalar_write,bit vector_write,bit scalar_ready,bit vector_ready);
      reset_cp:coverpoint reset; valid_cp:coverpoint valid; function_cp:coverpoint function_code;reverse_cp:coverpoint reverse;write_cp:coverpoint {scalar_write,vector_write};ready_cp:coverpoint {scalar_ready,vector_ready};
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent);activity=new(); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual vmult_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task compare(); if(!initialized)return; observations++;activity.sample(!vif.rst_n,vif.in_valid_i,vif.ctrl_alu_fn_i,vif.ctrl_reverse_i,vif.ctrl_wxd_i,vif.ctrl_wvd_i,vif.outx_ready_i,vif.outv_ready_i);
      if(vif.in_ready_o !== vif.expected_in_ready_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","in_ready_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outv_reg_idxw_o !== vif.expected_outv_reg_idxw_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outv_reg_idxw_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outv_valid_o !== vif.expected_outv_valid_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outv_valid_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outv_warp_id_o !== vif.expected_outv_warp_id_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outv_warp_id_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outv_wb_wxd_rd_o !== vif.expected_outv_wb_wxd_rd_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outv_wb_wxd_rd_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outv_wvd_mask_o !== vif.expected_outv_wvd_mask_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outv_wvd_mask_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outv_wvd_o !== vif.expected_outv_wvd_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outv_wvd_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outx_reg_idwx_o !== vif.expected_outx_reg_idwx_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outx_reg_idwx_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outx_valid_o !== vif.expected_outx_valid_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outx_valid_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outx_warp_id_o !== vif.expected_outx_warp_id_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outx_warp_id_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outx_wb_wxd_rd_o !== vif.expected_outx_wb_wxd_rd_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outx_wb_wxd_rd_o differs from independent magnitude/pipeline/FIFO predictor") end
      if(vif.outx_wxd_o !== vif.expected_outx_wxd_o) begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","outx_wxd_o differs from independent magnitude/pipeline/FIFO predictor") end
    endtask
    task run_phase(uvm_phase phase);forever begin @(negedge vif.clk);#2;compare();@(posedge vif.clk);#2;if(!vif.rst_n)initialized=1;compare();end endtask
    function void check_phase(uvm_phase phase);if(observations<1000) `uvm_error("VACUITY","insufficient comparisons") if(mismatches>0) `uvm_error("TOTAL",$sformatf("%0d mismatches",mismatches))endfunction
  endclass

  class vmult_sequence extends uvm_sequence #(vmult_item);
    `uvm_object_utils(vmult_sequence)
    function new(string name="vmult_sequence");super.new(name);endfunction
    task beat(int mode=1,int function_code=20,int reverse=0,int flags=1,int ready=3,int pattern=-1);
      vmult_item item=vmult_item::type_id::create("drive");
      start_item(item);if(!item.randomize()) `uvm_fatal("RANDOM","randomization failed")
      item.reset_pulse=(mode==4);item.rst_n=(mode!=0);
      if(mode!=3) begin
        item.ctrl_alu_fn_i=function_code;item.ctrl_reverse_i=reverse;
        item.ctrl_wxd_i=flags[1];item.ctrl_wvd_i=flags[0];
        item.outx_ready_i=ready[1];item.outv_ready_i=ready[0];item.in_valid_i=(mode==1 || mode==4);
      end
      if(pattern>=0) begin
        for(int lane=0;lane<4;lane++) begin
          case((pattern+lane)%8)
            0:begin item.in1_i[lane*32+:32]=0;item.in2_i[lane*32+:32]='1;item.in3_i[lane*32+:32]=0;end
            1:begin item.in1_i[lane*32+:32]=1;item.in2_i[lane*32+:32]='h80000000;item.in3_i[lane*32+:32]='1;end
            2:begin item.in1_i[lane*32+:32]='hffffffff;item.in2_i[lane*32+:32]='hffffffff;item.in3_i[lane*32+:32]=1;end
            3:begin item.in1_i[lane*32+:32]='h80000000;item.in2_i[lane*32+:32]=2;item.in3_i[lane*32+:32]='h7fffffff;end
            4:begin item.in1_i[lane*32+:32]='h7fffffff;item.in2_i[lane*32+:32]='h80000001;item.in3_i[lane*32+:32]='h80000000;end
            5:begin item.in1_i[lane*32+:32]='haaaaaaaa;item.in2_i[lane*32+:32]='h55555555;item.in3_i[lane*32+:32]='haaaaaaaa;end
            6:begin item.in1_i[lane*32+:32]='h12345678;item.in2_i[lane*32+:32]='h87654321;item.in3_i[lane*32+:32]='hffffffff;end
            7:begin item.in1_i[lane*32+:32]='h80000001;item.in2_i[lane*32+:32]='h7fffffff;item.in3_i[lane*32+:32]='h55555555;end
          endcase
        end
        item.mask_i=(pattern+function_code)%16;item.ctrl_reg_idxw_i=pattern*17;item.ctrl_wid_i=pattern;
      end
      finish_item(item);
    endtask
    task body();
      repeat(2)beat(0);repeat(5)beat(2);
      for(int function_code=0;function_code<64;function_code++)
        for(int reverse=0;reverse<2;reverse++)
          for(int flags=0;flags<4;flags++) begin
            for(int pattern=0;pattern<8;pattern++)beat(1,function_code,reverse,flags,3,pattern);
            repeat(5)beat(2);
          end
      for(int ready=0;ready<4;ready++) begin
        repeat(80)beat(1,23,1,3,ready);
        repeat(20)beat(2);
        repeat(80)beat(1,26,0,1,ready);
        repeat(20)beat(2);
      end
      repeat(5000)beat(3);
      repeat(8)beat(1,21,0,2,0);
      beat(4);repeat(10)beat(2);
      repeat(2)beat(0);repeat(10)beat(2);
    endtask
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    uvm_sequencer #(vmult_item) sequencer;vmult_driver driver;vmult_scoreboard scoreboard;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    function void build_phase(uvm_phase phase);sequencer=new("sequencer",this);driver=vmult_driver::type_id::create("driver",this);scoreboard=vmult_scoreboard::type_id::create("scoreboard",this);endfunction
    function void connect_phase(uvm_phase phase);driver.seq_item_port.connect(sequencer.seq_item_export);endfunction
    task run_phase(uvm_phase phase);vmult_sequence sequence_handle=vmult_sequence::type_id::create("sequence_handle");phase.raise_objection(this);sequence_handle.start(sequencer);repeat(3)@(posedge driver.vif.clk);phase.drop_objection(this);endtask
    function void report_phase(uvm_phase phase);uvm_report_server reports=uvm_report_server::get_server();if(reports.get_severity_count(UVM_ERROR)==0 && reports.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");endfunction
  endclass
endpackage
