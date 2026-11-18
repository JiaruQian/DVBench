`timescale 1ns/1ps
package test_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class aes_sample extends uvm_sequence_item;
`uvm_object_utils(aes_sample)
logic[127:0] actual,expected;bit valid;int phase_id,c,m;
function new(string name="aes_sample");super.new(name);endfunction
endclass
class aes_scoreboard extends uvm_component;
`uvm_component_utils(aes_scoreboard)
uvm_analysis_imp#(aes_sample,aes_scoreboard) sink;int checks=0,skips=0;
function new(string name,uvm_component parent);super.new(name,parent);sink=new("sink",this);endfunction
function void write(aes_sample s);
if(s.valid)begin checks++;
if($isunknown(s.expected) || s.actual!==s.expected)
`uvm_error("MISMATCH",$sformatf("m=%0d c=%0d phase=%0d actual=%h expected=%h",s.m,s.c,s.phase_id,s.actual,s.expected))
end else skips++;
endfunction
endclass
class aes_monitor extends uvm_component;
`uvm_component_utils(aes_monitor)
virtual aes_if vif;uvm_analysis_port#(aes_sample) observed;
function new(string name,uvm_component parent);super.new(name,parent);observed=new("observed",this);endfunction
function void build_phase(uvm_phase phase);
if(!uvm_config_db#(virtual aes_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing")
endfunction
task run_phase(uvm_phase phase);
aes_sample s;forever begin @(vif.sampled);s=new();s.actual=vif.out;s.expected=vif.expected;
s.valid=vif.valid;s.c=vif.counter;s.m=vif.maxRound;s.phase_id=vif.phase_id;observed.write(s);end
endtask
endclass
class aes_driver extends uvm_component;
`uvm_component_utils(aes_driver)
virtual aes_if vif;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);
if(!uvm_config_db#(virtual aes_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing")
endfunction
`include "driver_tasks.svh"
task run_phase(uvm_phase phase);phase.raise_objection(this);exercise();#2;phase.drop_objection(this);endtask
endclass
class dvbench_test extends uvm_test;
`uvm_component_utils(dvbench_test)
aes_driver driver;aes_monitor monitor;aes_scoreboard scoreboard;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);
driver=aes_driver::type_id::create("driver",this);
monitor=aes_monitor::type_id::create("monitor",this);
scoreboard=aes_scoreboard::type_id::create("scoreboard",this);
endfunction
function void connect_phase(uvm_phase phase);monitor.observed.connect(scoreboard.sink);endfunction
function void check_phase(uvm_phase phase);if(scoreboard.checks<3000)`uvm_error("VACUOUS","insufficient comparisons") endfunction
function void report_phase(uvm_phase phase);
`uvm_info("COUNTS",$sformatf("checks=%0d skips=%0d",scoreboard.checks,scoreboard.skips),UVM_LOW)
if(uvm_report_server::get_server().get_severity_count(UVM_ERROR)==0 &&
uvm_report_server::get_server().get_severity_count(UVM_FATAL)==0)
`uvm_info("DONE","DVBench_COMPLETED",UVM_NONE)
endfunction
endclass
endpackage
