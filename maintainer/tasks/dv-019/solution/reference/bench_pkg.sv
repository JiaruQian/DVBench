`timescale 1ns/1ps
package bench_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class observation extends uvm_sequence_item;
`uvm_object_utils(observation)
logic [29-1:0] actual,predicted;
function new(string name="observation");super.new(name);endfunction
endclass
class driver extends uvm_component;
`uvm_component_utils(driver)
virtual bench_if vif;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
task run_phase(uvm_phase phase);
phase.raise_objection(this);vif.stimulate();#1;phase.drop_objection(this);
endtask
endclass
class monitor extends uvm_monitor;
`uvm_component_utils(monitor)
virtual bench_if vif;
uvm_analysis_port#(observation) observed;
function new(string name,uvm_component parent);super.new(name,parent);observed=new("observed",this);endfunction
task run_phase(uvm_phase phase);
observation item;
forever begin @(vif.sampled);item=observation::type_id::create("item");item.actual=vif.actual;item.predicted=vif.predicted;observed.write(item);if(item.actual!==item.predicted) vif.stop_requested=1;end
endtask
endclass
class scoreboard extends uvm_subscriber#(observation);
`uvm_component_utils(scoreboard)
integer comparisons=0,mismatches=0,known_comparisons=0;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void write(observation item);
comparisons++;
if(comparisons%200000==0) $display("DVBENCH_PROGRESS points=%0d mismatches=%0d",comparisons,mismatches);
if(!$isunknown(item.predicted)) known_comparisons++;
if(item.actual!==item.predicted) begin
mismatches++;
if(mismatches<21) `uvm_error("COMPARE",$sformatf("point=%0d actual=%h expected=%h",comparisons,item.actual,item.predicted))
end
endfunction
function void check_phase(uvm_phase phase);
if(comparisons<100 || known_comparisons<100) `uvm_error("VACUITY","insufficient comparisons")
endfunction
function void report_phase(uvm_phase phase);
$display("DVBENCH_DIFFERENTIAL mismatches=%0d points=%0d known=%0d",mismatches,comparisons,known_comparisons);
endfunction
endclass
class dvbench_test extends uvm_test;
`uvm_component_utils(dvbench_test)
driver stimulus_driver;monitor observation_monitor;scoreboard comparison_scoreboard;
virtual bench_if vif;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(virtual bench_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
stimulus_driver=driver::type_id::create("stimulus_driver",this);
observation_monitor=monitor::type_id::create("observation_monitor",this);
comparison_scoreboard=scoreboard::type_id::create("comparison_scoreboard",this);
stimulus_driver.vif=vif;observation_monitor.vif=vif;
endfunction
function void connect_phase(uvm_phase phase);observation_monitor.observed.connect(comparison_scoreboard.analysis_export);endfunction
function void report_phase(uvm_phase phase);
if(uvm_report_server::get_server().get_severity_count(UVM_ERROR)==0 && uvm_report_server::get_server().get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
endfunction
endclass
endpackage
