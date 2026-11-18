`timescale 1ns/1ps
package verify_pkg;
import uvm_pkg::*;`include "uvm_macros.svh"
class observation extends uvm_sequence_item;
 `uvm_object_utils(observation)
 logic[257:0] actual,expected;
 logic rst,cmd_i,cmd_n,md,rd,vld;
 function new(string n="observation");super.new(n);endfunction
endclass
class suite_request extends uvm_sequence_item;
 `uvm_object_utils(suite_request)
 function new(string n="suite_request");super.new(n);endfunction
endclass
class suite_sequence extends uvm_sequence#(suite_request);
 `uvm_object_utils(suite_sequence)
 function new(string n="suite_sequence");super.new(n);endfunction
 task body();suite_request r=suite_request::type_id::create("suite");start_item(r);finish_item(r);endtask
endclass
class driver extends uvm_driver#(suite_request);
 `uvm_component_utils(driver)
 virtual native_if vif;bit finished=0;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);
  if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif))`uvm_fatal("CFG","missing vif")
 endfunction
 task run_phase(uvm_phase phase);
 suite_request r;forever begin seq_item_port.get_next_item(r);vif.exercise();seq_item_port.item_done();finished=1;end
 endtask
endclass
class monitor extends uvm_component;
 `uvm_component_utils(monitor)
 virtual native_if vif;uvm_analysis_port#(observation) ap;
 function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);endfunction
 function void build_phase(uvm_phase phase);
  if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif))`uvm_fatal("CFG","missing vif")
 endfunction
 task run_phase(uvm_phase phase);
  forever begin
   @(posedge vif.clk or negedge vif.reset_n);#1;
   begin observation t=new();t.actual={vif.ready,vif.digest,vif.digest_valid};t.expected={vif.exp_ready,vif.exp_digest,vif.exp_digest_valid};t.rst=vif.reset_n;t.cmd_i=vif.init;t.cmd_n=vif.next;t.md=vif.mode;t.rd=vif.ready;t.vld=vif.digest_valid;ap.write(t);end
  end
 endtask
endclass
class scoreboard extends uvm_component;
 `uvm_component_utils(scoreboard)
 uvm_analysis_imp#(observation,scoreboard) imp;int checked=0,bad=0;
 function new(string n,uvm_component p);super.new(n,p);imp=new("imp",this);endfunction
 function void write(observation t);
  checked++;
  if(t.actual!==t.expected)begin
   bad++;if(bad<=20)`uvm_error("PORT_MISMATCH",$sformatf("sample=%0d actual=%h expected=%h",checked,t.actual,t.expected))
  end
 endfunction
 function void report_phase(uvm_phase phase);
  $display("DVBench_SAMPLES %0d mismatches %0d",checked,bad);
  if(checked<100)`uvm_error("VACUOUS","insufficient observations")
 endfunction
endclass
class protocol_checker extends uvm_subscriber#(observation);
 `uvm_component_utils(protocol_checker)
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void write(observation t);
  if(!t.rst && t.actual!=={1'b1,256'b0,1'b0})`uvm_error("RESET","asynchronous reset output mismatch")
  if(t.rst && !t.rd && t.vld)`uvm_error("PROTOCOL","valid cannot remain set while busy")
 endfunction
endclass
class functional_coverage extends uvm_subscriber#(observation);
 `uvm_component_utils(functional_coverage)
 covergroup operations with function sample(bit rst,bit i,bit n,bit md,bit rd,bit vld);
  reset:coverpoint rst;
  command:coverpoint {i,n};
  mode:coverpoint md;
  ready:coverpoint rd;
  valid:coverpoint vld;
  command_mode:cross command,mode;
 endgroup
 function new(string n,uvm_component p);super.new(n,p);operations=new();endfunction
 function void write(observation t);operations.sample(t.rst,t.cmd_i,t.cmd_n,t.md,t.rd,t.vld);endfunction
 function void report_phase(uvm_phase phase);$display("DVBench_FUNCTIONAL_COVERAGE %0.2f",operations.get_inst_coverage());endfunction
endclass
class native_agent extends uvm_agent;
 `uvm_component_utils(native_agent)
 driver d;monitor m;uvm_sequencer#(suite_request) sqr;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);
  d=driver::type_id::create("d",this);m=monitor::type_id::create("m",this);sqr=new("sqr",this);
 endfunction
 function void connect_phase(uvm_phase phase);d.seq_item_port.connect(sqr.seq_item_export);endfunction
endclass
class native_env extends uvm_env;
 `uvm_component_utils(native_env)
 native_agent a;scoreboard s;protocol_checker c;functional_coverage cov;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);
  a=native_agent::type_id::create("a",this);s=scoreboard::type_id::create("s",this);
  c=protocol_checker::type_id::create("c",this);cov=functional_coverage::type_id::create("cov",this);
 endfunction
 function void connect_phase(uvm_phase phase);a.m.ap.connect(s.imp);a.m.ap.connect(c.analysis_export);a.m.ap.connect(cov.analysis_export);endfunction
endclass
class dvbench_test extends uvm_test;
 `uvm_component_utils(dvbench_test)
 native_env e;
 function new(string n="dvbench_test",uvm_component p=null);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);e=native_env::type_id::create("e",this);endfunction
 task run_phase(uvm_phase phase);suite_sequence seq;phase.raise_objection(this);seq=suite_sequence::type_id::create("seq");seq.start(e.a.sqr);#3;phase.drop_objection(this);endtask
 function void report_phase(uvm_phase phase);
  if(uvm_report_server::get_server().get_severity_count(UVM_ERROR)==0&&uvm_report_server::get_server().get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");
 endfunction
endclass
endpackage
