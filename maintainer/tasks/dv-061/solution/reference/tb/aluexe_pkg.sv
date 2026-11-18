`timescale 1ns/1ps
package aluexe_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class aluexe_item extends uvm_sequence_item;
  `uvm_object_utils(aluexe_item)
  int index;
  logic [714:0] actual, expected;
  function new(string name="aluexe_item"); super.new(name); endfunction
endclass
class aluexe_sequence extends uvm_sequence #(aluexe_item);
  `uvm_object_utils(aluexe_sequence)
  function new(string name="aluexe_sequence"); super.new(name); endfunction
  task body();
    for(int index=0;index<4096;index++) begin
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
      @(negedge vif.clock); vif.prepare(item.index);
      #3; seq_item_port.item_done();
    end
  endtask
endclass
class aluexe_monitor extends uvm_component;
  `uvm_component_utils(aluexe_monitor)
  virtual aluexe_if vif;
  uvm_analysis_port #(aluexe_item) observed;
  covergroup behavior with function sample(bit reset_value,bit enq,bit deq,bit redirect,bit mispredict,bit [2:0] cfi,bit [5:0] query_index);
    option.per_instance=1;
    reset_cp:coverpoint reset_value;
    enq_cp:coverpoint enq;
    deq_cp:coverpoint deq;
    redirect_cp:coverpoint redirect;
    mispredict_cp:coverpoint mispredict;
    cfi_cp:coverpoint cfi {bins each_type[]={[0:7]};}
    index_cp:coverpoint query_index {bins every_index[]={[0:63]};}
    redirect_mispredict:cross redirect_cp,mispredict_cp;
  endgroup
  function new(string name,uvm_component parent);super.new(name,parent);observed=new("observed",this);behavior=new();endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual aluexe_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      aluexe_item item;
      @(negedge vif.clock); #2;
      item=aluexe_item::type_id::create("observed_item");
      item.actual=vif.actual_bus; item.expected=vif.expected_bus; observed.write(item);
      behavior.sample(vif.reset,vif.io_enq_valid,vif.io_deq_valid,vif.io_redirect_valid,vif.io_brupdate_b2_mispredict,vif.io_enq_bits_cfi_type,vif.io_get_ftq_pc_0_ftq_idx);
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
