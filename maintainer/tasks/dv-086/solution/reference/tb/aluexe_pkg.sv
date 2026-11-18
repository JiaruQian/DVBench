`timescale 1ns/1ps
package aluexe_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class aluexe_item extends uvm_sequence_item;
  `uvm_object_utils(aluexe_item)
  int index;
  logic [139:0] actual, expected;
  function new(string name="aluexe_item"); super.new(name); endfunction
endclass
class aluexe_sequence extends uvm_sequence #(aluexe_item);
  `uvm_object_utils(aluexe_sequence)
  function new(string name="aluexe_sequence"); super.new(name); endfunction
  task body();
    for(int index=0;index<13312;index++) begin
      aluexe_item item=aluexe_item::type_id::create("item");
      start_item(item); item.index=index; finish_item(item);
    end
  endtask
endclass
class aluexe_driver extends uvm_driver #(aluexe_item);
  `uvm_component_utils(aluexe_driver)
  virtual aluexe_if vif;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual aluexe_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  task run_phase(uvm_phase phase);
    vif.drive('0);
    forever begin
      aluexe_item item;
      seq_item_port.get_next_item(item);
      @(negedge vif.clk); vif.prepare(item.index);
      if(item.index>=12288) begin
        if((item.index-12288)%32==6) begin
          fork
            begin
              @(posedge vif.clk);#2;
              vif.mem_rsp_d_data_i=~vif.mem_rsp_d_data_i;
            end
          join_none
        end
        if((item.index-12288)%32==14) begin
          #1;vif.invalid_i=1;
          #1;vif.invalid_i=0;
        end
        if((item.index-12288)%32==12 || (item.index-12288)%32==20) begin
          if(vif.expected_core_rsp_valid_o!==1'b1 || vif.expected_core_rsp_status_o!==1'b0 || vif.expected_core_rsp_data_o!==vif.mem_rsp_d_data_i)
            `uvm_error("EDGE_NONVACUITY","Independent line must hit and retain the original edge-sampled refill after off-clock invalidate and high-clock data changes")
        end
      end
      #3; seq_item_port.item_done();
    end
  endtask
endclass
class aluexe_monitor extends uvm_component;
  `uvm_component_utils(aluexe_monitor)
  virtual aluexe_if vif;
  uvm_analysis_port #(aluexe_item) observed;
  covergroup behavior with function sample(bit reset_n,bit request_valid,bit response_valid,bit mem_valid,bit mem_ready,bit flush,bit invalidate,bit[4:0] set_index,bit[2:0] offset,bit[2:0] warp,bit[1:0] mask_value);
    option.per_instance=1;
    reset_cp:coverpoint reset_n;
    request_cp:coverpoint request_valid;
    response_cp:coverpoint response_valid;
    mem_valid_cp:coverpoint mem_valid;
    mem_ready_cp:coverpoint mem_ready;
    flush_cp:coverpoint flush;
    invalid_cp:coverpoint invalidate;
    set_cp:coverpoint set_index;
    offset_cp:coverpoint offset;
    warp_cp:coverpoint warp;
    mask_cp:coverpoint mask_value;
    memory_handshake:cross mem_valid_cp,mem_ready_cp;
    request_flush:cross request_cp,flush_cp;
  endgroup
  function new(string name,uvm_component parent);super.new(name,parent);observed=new("observed",this);behavior=new();endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual aluexe_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      aluexe_item item;
      @(negedge vif.clk); #2;
      item=aluexe_item::type_id::create("observed_item");
      item.actual=vif.actual_bus; item.expected=vif.expected_bus; observed.write(item);
      behavior.sample(vif.rst_n,vif.core_req_valid_i,vif.core_rsp_valid_o,vif.mem_req_valid_o,vif.mem_req_ready_i,vif.flush_pipe_valid_i,vif.invalid_i,vif.core_req_addr_i[7:3],vif.core_req_addr_i[2:0],vif.core_req_wid_i,vif.core_req_mask_i);
    end
  endtask
endclass
class aluexe_scoreboard extends uvm_component;
  `uvm_component_utils(aluexe_scoreboard)
  uvm_analysis_imp #(aluexe_item,aluexe_scoreboard) received;
  int observations, mismatches;
  function new(string name,uvm_component parent); super.new(name,parent); received=new("received",this); endfunction
  function void write(aluexe_item item);
    observations++;
    if(item.actual !== item.expected) begin
      mismatches++; `uvm_error("MODEL_MISMATCH",$sformatf("sample=%0d actual=%h expected=%h",observations,item.actual,item.expected))
    end
  endfunction
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if(observations<4096) `uvm_error("VACUITY",$sformatf("only %0d observations",observations))
    `uvm_info("CHECK_SUMMARY",$sformatf("observations=%0d mismatches=%0d",observations,mismatches),UVM_LOW)
  endfunction
  function void report_phase(uvm_phase phase);
    uvm_report_server server;
    super.report_phase(phase); server=uvm_report_server::get_server();
    if(observations>=4096 && mismatches==0 && server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
  endfunction
endclass
class aluexe_agent extends uvm_agent;
  `uvm_component_utils(aluexe_agent)
  uvm_sequencer #(aluexe_item) sequencer;
  aluexe_driver driver;
  aluexe_monitor monitor;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); sequencer=uvm_sequencer#(aluexe_item)::type_id::create("sequencer",this);
    driver=aluexe_driver::type_id::create("driver",this); monitor=aluexe_monitor::type_id::create("monitor",this);
  endfunction
  function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
endclass
class aluexe_env extends uvm_env;
  `uvm_component_utils(aluexe_env)
  aluexe_agent agent;
  aluexe_scoreboard scoreboard;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); agent=aluexe_agent::type_id::create("agent",this); scoreboard=aluexe_scoreboard::type_id::create("scoreboard",this);
  endfunction
  function void connect_phase(uvm_phase phase); agent.monitor.observed.connect(scoreboard.received); endfunction
endclass
class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  aluexe_env env;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); env=aluexe_env::type_id::create("env",this); endfunction
  task run_phase(uvm_phase phase);
    aluexe_sequence sequence_item=aluexe_sequence::type_id::create("sequence_item");
    phase.raise_objection(this); sequence_item.start(env.agent.sequencer); #1; phase.drop_objection(this);
  endtask
endclass
endpackage
