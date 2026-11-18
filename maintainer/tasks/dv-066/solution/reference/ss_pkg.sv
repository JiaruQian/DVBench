`timescale 1ns/1ps
package ss_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class ss_item extends uvm_sequence_item;
`uvm_object_utils(ss_item)
bit reset_pulse;
rand logic [3:0] branch_ctl_mask_init_i;
rand logic branch_ctl_opcode_i;
rand logic [31:0] branch_ctl_pc_branch_i;
rand logic [31:0] branch_ctl_pc_execute_i;
rand logic branch_ctl_valid_i;
rand logic [2:0] branch_ctl_wid_i;
rand logic fetch_ctl_ready_i;
rand logic [3:0] if_mask_mask_i;
rand logic if_mask_valid_i;
rand logic [2:0] if_mask_wid_i;
rand logic [2:0] input_wid_i;
rand logic [31:0] pc_reconv_i;
rand logic pc_reconv_valid_i;
rand logic rst_n;
function new(string name="drive");super.new(name);endfunction
endclass
class ss_driver extends uvm_driver #(ss_item);
`uvm_component_utils(ss_driver)
virtual ss_if vif;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual ss_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")endfunction
task run_phase(uvm_phase phase);ss_item item;forever begin seq_item_port.get_next_item(item);@(negedge vif.clk);
vif.branch_ctl_mask_init_i=item.branch_ctl_mask_init_i;
vif.branch_ctl_opcode_i=item.branch_ctl_opcode_i;
vif.branch_ctl_pc_branch_i=item.branch_ctl_pc_branch_i;
vif.branch_ctl_pc_execute_i=item.branch_ctl_pc_execute_i;
vif.branch_ctl_valid_i=item.branch_ctl_valid_i;
vif.branch_ctl_wid_i=item.branch_ctl_wid_i;
vif.fetch_ctl_ready_i=item.fetch_ctl_ready_i;
vif.if_mask_mask_i=item.if_mask_mask_i;
vif.if_mask_valid_i=item.if_mask_valid_i;
vif.if_mask_wid_i=item.if_mask_wid_i;
vif.input_wid_i=item.input_wid_i;
vif.pc_reconv_i=item.pc_reconv_i;
vif.pc_reconv_valid_i=item.pc_reconv_valid_i;
vif.rst_n=item.rst_n;
if(item.reset_pulse)begin #1;vif.rst_n=0;#1;vif.rst_n=1;end
@(posedge vif.clk);#3;seq_item_port.item_done();end endtask
endclass
class ss_scoreboard extends uvm_component;
`uvm_component_utils(ss_scoreboard)
virtual ss_if vif;
int observations,mismatches;bit initialized;
covergroup activity with function sample(bit rst,bit branch_valid,bit if_valid,bit ready);
reset_cp:coverpoint rst;branch_cp:coverpoint branch_valid;if_cp:coverpoint if_valid;ready_cp:coverpoint ready;endgroup
function new(string name,uvm_component parent);super.new(name,parent);activity=new();endfunction
function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual ss_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")endfunction
task compare();if(!initialized)return;observations++;activity.sample(!vif.rst_n,vif.branch_ctl_valid_i,vif.if_mask_valid_i,vif.fetch_ctl_ready_i);
if(vif.branch_ctl_ready_o !== vif.expected_branch_ctl_ready_o)begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","branch_ctl_ready_o differs from independent stack/queue predictor")end
if(vif.complete_valid_o !== vif.expected_complete_valid_o)begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","complete_valid_o differs from independent stack/queue predictor")end
if(vif.complete_wid_o !== vif.expected_complete_wid_o)begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","complete_wid_o differs from independent stack/queue predictor")end
if(vif.fetch_ctl_jump_o !== vif.expected_fetch_ctl_jump_o)begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","fetch_ctl_jump_o differs from independent stack/queue predictor")end
if(vif.fetch_ctl_new_pc_o !== vif.expected_fetch_ctl_new_pc_o)begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","fetch_ctl_new_pc_o differs from independent stack/queue predictor")end
if(vif.fetch_ctl_valid_o !== vif.expected_fetch_ctl_valid_o)begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","fetch_ctl_valid_o differs from independent stack/queue predictor")end
if(vif.fetch_ctl_wid_o !== vif.expected_fetch_ctl_wid_o)begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","fetch_ctl_wid_o differs from independent stack/queue predictor")end
if(vif.if_mask_ready_o !== vif.expected_if_mask_ready_o)begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","if_mask_ready_o differs from independent stack/queue predictor")end
if(vif.out_mask_o !== vif.expected_out_mask_o)begin mismatches++;if(mismatches<=12) `uvm_error("COMPARE","out_mask_o differs from independent stack/queue predictor")end
endtask
task run_phase(uvm_phase phase);fork begin forever begin @(negedge vif.clk);#2;compare();@(posedge vif.clk);#2;if(!vif.rst_n)initialized=1;compare();end end begin forever begin @(negedge vif.rst_n);#0.1;initialized=1;compare();end end join endtask
function void check_phase(uvm_phase phase);if(observations<1000) `uvm_error("VACUITY","insufficient comparisons") if(mismatches>0) `uvm_error("TOTAL",$sformatf("%0d mismatches",mismatches))endfunction
endclass
class ss_sequence extends uvm_sequence #(ss_item);
`uvm_object_utils(ss_sequence)
function new(string name="stimulus");super.new(name);endfunction

    task beat(int mode=2,int opcode=0,int warp=0,int initial_mask=15,int if_mask=1,int execute_pc='h100,int recon_pc='h400,int branch_pc='h800,int branch_valid=0,int mask_valid=0,int recon_valid=0,int ready=1,int mask_warp=-1);
      ss_item item=ss_item::type_id::create("drive");
      start_item(item);if(!item.randomize()) `uvm_fatal("RANDOM","randomization failed")
      item.rst_n=(mode!=0);item.reset_pulse=(mode==4);
      if(mode!=1)begin
        item.branch_ctl_valid_i=branch_valid;item.branch_ctl_opcode_i=opcode;item.branch_ctl_wid_i=warp;
        item.branch_ctl_pc_branch_i=branch_pc;item.branch_ctl_pc_execute_i=execute_pc;item.branch_ctl_mask_init_i=initial_mask;
        item.if_mask_valid_i=mask_valid;item.if_mask_mask_i=if_mask;item.if_mask_wid_i=mask_warp<0 ? warp:mask_warp;
        item.pc_reconv_valid_i=recon_valid;item.pc_reconv_i=recon_pc;item.fetch_ctl_ready_i=ready;item.input_wid_i=warp;
      end
      finish_item(item);
    endtask
    task operation(int opcode,int warp,int initial_mask,int if_mask,int execute_pc,int recon_pc,int branch_pc);
      beat(2,opcode,warp,initial_mask,if_mask,execute_pc,recon_pc,branch_pc,1,0,1);
      beat(2,opcode,warp,initial_mask,if_mask,execute_pc,recon_pc,branch_pc,0,!opcode,0);
      repeat(4)beat(2,opcode,warp);
    endtask
    task pc_alignment_witness();
      logic [31:0] base_pc,recon_pc,execute_pc;
      for(int warp=0;warp<8;warp++) begin
        for(int base_index=0;base_index<4;base_index++) begin
          case(base_index)
            0:base_pc=32'h00000000;
            1:base_pc=32'h7ffffffc;
            2:base_pc=32'h80000000;
            3:base_pc=32'hfffffffc;
          endcase
          for(int recon_low=0;recon_low<4;recon_low++) begin
            for(int execute_low=0;execute_low<4;execute_low++) begin
              recon_pc=base_pc|32'(recon_low);
              execute_pc=base_pc|32'(execute_low);
              beat(0);
              operation(0,warp,15,1,32'h100,recon_pc,32'h800);
              operation(1,warp,15,0,execute_pc,0,0);
              operation(1,warp,15,0,recon_pc,0,0);
              operation(1,warp,15,0,recon_pc,0,0);
            end
          end
        end
      end
      beat(0);repeat(4)beat();
    endtask
    task body();
      repeat(2)beat(0);repeat(4)beat();
      pc_alignment_witness();
      for(int warp=0;warp<8;warp++)
        for(int initial_mask=0;initial_mask<16;initial_mask++)
          for(int if_mask=0;if_mask<16;if_mask++)begin
            beat(0);operation(0,warp,initial_mask,if_mask,'h100,'h400,'h800);
            for(int select=0;select<8;select++)beat(2,0,select);
          end
      for(int warp=0;warp<8;warp++)begin
        beat(0);
        for(int depth=0;depth<8;depth++)operation(0,warp,15,1,'h100+depth*16,'h400+depth*16,'h800+depth*16);
        operation(1,warp,15,0,'hdeadbeef,0,0);
        for(int depth=7;depth>=0;depth--)begin
          operation(1,warp,15,0,'h400+depth*16,0,0);operation(1,warp,15,0,'h400+depth*16,0,0);
        end
        operation(1,warp,15,0,'h400,0,0);
      end
      for(int warp=0;warp<8;warp++)begin
        beat(0);for(int depth=0;depth<14;depth++)operation(0,warp,15,7,'hfffffffc,'h400,'h800);
        operation(1,warp,15,0,'h400,0,0);
      end
      repeat(5000)beat(1);
      beat(4);repeat(10)beat();
      beat(0);repeat(10)beat();
    endtask

endclass
class dvbench_test extends uvm_test;
`uvm_component_utils(dvbench_test)
uvm_sequencer #(ss_item) sequencer;ss_driver driver;ss_scoreboard scoreboard;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);sequencer=new("sequencer",this);driver=ss_driver::type_id::create("driver",this);scoreboard=ss_scoreboard::type_id::create("scoreboard",this);endfunction
function void connect_phase(uvm_phase phase);driver.seq_item_port.connect(sequencer.seq_item_export);endfunction
task run_phase(uvm_phase phase);ss_sequence sequence_handle=ss_sequence::type_id::create("stimulus");phase.raise_objection(this);sequence_handle.start(sequencer);repeat(3)@(posedge driver.vif.clk);phase.drop_objection(this);endtask
function void report_phase(uvm_phase phase);uvm_report_server reports=uvm_report_server::get_server();if(reports.get_severity_count(UVM_ERROR)==0 && reports.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");endfunction
endclass
endpackage
