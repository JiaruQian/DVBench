`timescale 1ns/1ps
package aluexe_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class aluexe_item extends uvm_sequence_item;
  `uvm_object_utils(aluexe_item)
  int index;
  logic [82:0] actual, expected;
  function new(string name="aluexe_item"); super.new(name); endfunction
endclass
class aluexe_sequence extends uvm_sequence #(aluexe_item);
  `uvm_object_utils(aluexe_sequence)
  function new(string name="aluexe_sequence"); super.new(name); endfunction
  task body();
    for(int index=0;index<5250;index++) begin
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
  covergroup behavior with function sample(bit reset_value,bit valid,bit ready,bit tick,bit [2:0] opcode,bit [1:0] size,bit [7:0] mask);
    option.per_instance=1;
    reset_cp:coverpoint reset_value;
    valid_cp:coverpoint valid;
    ready_cp:coverpoint ready;
    tick_cp:coverpoint tick;
    opcode_cp:coverpoint opcode { bins read={4};bins full_write={0};bins partial_write={1}; }
    size_cp:coverpoint size;
    mask_cp:coverpoint mask {bins none={0};bins all={255};bins lane[8]={[1:254]};}
    handshake:cross valid_cp,ready_cp;
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
      behavior.sample(vif.reset,vif.auto_in_a_valid,vif.auto_in_d_ready,vif.io_rtcTick,vif.auto_in_a_bits_opcode,vif.auto_in_a_bits_size,vif.auto_in_a_bits_mask);
    end
  endtask
endclass
class aluexe_scoreboard extends uvm_component;
  `uvm_component_utils(aluexe_scoreboard)
  uvm_analysis_imp #(aluexe_item,aluexe_scoreboard) received;
  int observations, mismatches;
  function new(string name,uvm_component parent); super.new(name,parent); received=new("received",this); endfunction
  function void write(aluexe_item item);
    bit differs;
    observations++;
    differs=0;
    for(int bit_index=0;bit_index<$bits(item.expected);bit_index++) begin
      if((item.expected[bit_index]===1'b0 || item.expected[bit_index]===1'b1) && item.actual[bit_index]!==item.expected[bit_index]) differs=1;
    end
    if(observations>1 && differs) begin
      mismatches++; `uvm_error("MODEL_MISMATCH",$sformatf("sample=%0d actual=%h expected=%h",observations,item.actual,item.expected))
    end
  endfunction
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if(observations<4096 && mismatches==0) `uvm_error("VACUITY",$sformatf("only %0d observations",observations))
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
    phase.raise_objection(this);
    fork
      begin sequence_item.start(env.agent.sequencer); #1; end
      begin wait(env.scoreboard.mismatches>0); env.agent.sequencer.stop_sequences(); end
    join_any
    disable fork;
    phase.drop_objection(this);
  endtask
endclass
endpackage
