`timescale 1ns/1ps
package aluexe_pkg;
bit stop_requested=0;
import uvm_pkg::*;
`include "uvm_macros.svh"
class aluexe_item extends uvm_sequence_item;
  `uvm_object_utils(aluexe_item)
  int index;
  bit hardening_request;
  bit performance_active;
  logic [1:0] performance_done;
  bit performance_read;
  logic [31:0] performance_value;
  logic [635:0] actual, expected;
  function new(string name="aluexe_item"); super.new(name); endfunction
endclass
class aluexe_sequence extends uvm_sequence #(aluexe_item);
  `uvm_object_utils(aluexe_sequence)
  function new(string name="aluexe_sequence"); super.new(name); endfunction
  task body();
    for(int index=0;index<203896;index++) begin
      aluexe_item item=aluexe_item::type_id::create("item");
      if(stop_requested) break;
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
      @(negedge vif.nvdla_core_clk); vif.prepare(item.index);
      #3; seq_item_port.item_done();
    end
  endtask
endclass
class aluexe_monitor extends uvm_component;
  `uvm_component_utils(aluexe_monitor)
  virtual aluexe_if vif;
  uvm_analysis_port #(aluexe_item) observed;
  covergroup behavior with function sample(bit reset_n,bit csb_valid,bit csb_write,bit nonposted,bit[4:0] register_index,bit read_valid,bit read_ready,bit write_valid,bit write_ready,bit packet_kind,bit response_valid,bit response_ready,bit complete,bit[1:0] interrupt_value);
    option.per_instance=1;
    reset_cp:coverpoint reset_n;
    csb_cp:coverpoint csb_valid;
    csb_write_cp:coverpoint csb_write;
    nonposted_cp:coverpoint nonposted;
    register_cp:coverpoint register_index;
    read_valid_cp:coverpoint read_valid;
    read_ready_cp:coverpoint read_ready;
    write_valid_cp:coverpoint write_valid;
    write_ready_cp:coverpoint write_ready;
    packet_cp:coverpoint packet_kind;
    response_valid_cp:coverpoint response_valid;
    response_ready_cp:coverpoint response_ready;
    complete_cp:coverpoint complete;
    interrupt_cp:coverpoint interrupt_value;
    read_handshake:cross read_valid_cp,read_ready_cp;
    write_handshake:cross write_valid_cp,write_ready_cp,packet_cp;
    response_handshake:cross response_valid_cp,response_ready_cp;
  endgroup
  function new(string name,uvm_component parent);super.new(name,parent);observed=new("observed",this);behavior=new();endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual aluexe_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      aluexe_item item;
      @(negedge vif.nvdla_core_clk); #2;
      item=aluexe_item::type_id::create("observed_item");
      item.actual=vif.actual_bus; item.expected=vif.expected_bus;
      item.performance_active=vif.performance_active;
      item.performance_done=vif.expected_bdma2glb_done_intr_pd;
      item.performance_read=item.performance_active && vif.expected_bdma2csb_resp_valid && vif.expected_bdma2csb_resp_pd[33:32]==0;
      item.performance_value=vif.expected_bdma2csb_resp_pd[31:0];
      item.hardening_request=vif.hardening_active && vif.nvdla_core_rstn && vif.expected_bdma2mcif_rd_req_valid && vif.bdma2mcif_rd_req_ready; observed.write(item);
      behavior.sample(vif.nvdla_core_rstn,vif.csb2bdma_req_pvld,vif.csb2bdma_req_pd[54],vif.csb2bdma_req_pd[55],vif.csb2bdma_req_pd[4:0],vif.bdma2mcif_rd_req_valid,vif.bdma2mcif_rd_req_ready,vif.bdma2mcif_wr_req_valid,vif.bdma2mcif_wr_req_ready,vif.bdma2mcif_wr_req_pd[514],vif.mcif2bdma_rd_rsp_valid,vif.mcif2bdma_rd_rsp_ready,vif.mcif2bdma_wr_rsp_complete,vif.bdma2glb_done_intr_pd);
    end
  endtask
endclass
class aluexe_scoreboard extends uvm_component;
  `uvm_component_utils(aluexe_scoreboard)
  uvm_analysis_imp #(aluexe_item,aluexe_scoreboard) received;
  int observations, mismatches, hardening_requests, performance_completions, wide_counter_reads;
  function new(string name,uvm_component parent); super.new(name,parent); received=new("received",this); endfunction
  function void write(aluexe_item item);
    bit differs;
    observations++;
    if(item.performance_active && item.performance_done!=0) performance_completions++;
    if(item.performance_read && item.performance_value>65535) wide_counter_reads++;
    if(item.hardening_request) hardening_requests++;
    differs=0;
    for(int bit_index=0;bit_index<$bits(item.expected);bit_index++) begin
      if((item.expected[bit_index]===1'b0 || item.expected[bit_index]===1'b1) && item.actual[bit_index]!==item.expected[bit_index]) differs=1;
    end
    if(differs) begin
      stop_requested=1;
      mismatches++; `uvm_error("MODEL_MISMATCH",$sformatf("sample=%0d actual=%h expected=%h",observations,item.actual,item.expected))
    end
  endfunction
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if(observations<203896 && mismatches==0) `uvm_error("VACUITY",$sformatf("only %0d observations",observations))
    if(mismatches==0 && hardening_requests!=65537) `uvm_error("LONG_LOAD_VACUITY",$sformatf("expected 65537 requests, observed %0d",hardening_requests))
    if(mismatches==0 && (performance_completions!=2 || wide_counter_reads!=4)) `uvm_error("PERFORMANCE_VACUITY",$sformatf("completions=%0d wide_counter_reads=%0d",performance_completions,wide_counter_reads))
    `uvm_info("CHECK_SUMMARY",$sformatf("observations=%0d mismatches=%0d",observations,mismatches),UVM_LOW)
  endfunction
  function void report_phase(uvm_phase phase);
    uvm_report_server server;
    super.report_phase(phase); server=uvm_report_server::get_server();
    if(observations>=203896 && mismatches==0 && server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
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
