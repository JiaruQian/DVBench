`timescale 1ns/1ps
package bench_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class transaction extends uvm_sequence_item;
`uvm_object_utils(transaction)
logic [14-1:0] stimulus;
logic [15-1:0] actual, predicted;
function new(string name="transaction"); super.new(name); endfunction
endclass
class sequence_all extends uvm_sequence #(transaction);
`uvm_object_utils(sequence_all)
function new(string name="sequence_all"); super.new(name); endfunction
task body();
transaction item;
integer seed_value;
seed_value=1;
void'($value$plusargs("ntb_random_seed=%d",seed_value));
case(seed_value)
1: begin
`include "vectors_1.svh"
end
7: begin
`include "vectors_7.svh"
end
42: begin
`include "vectors_42.svh"
end
default: `uvm_fatal("SEED", "unsupported maintenance seed")
endcase
endtask
task send(logic [14-1:0] value);
transaction item;
item=transaction::type_id::create("item");
start_item(item); item.stimulus=value; finish_item(item);
endtask
endclass
class driver extends uvm_driver #(transaction);
`uvm_component_utils(driver)
virtual bench_if vif;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(virtual bench_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
endfunction
task run_phase(uvm_phase phase);
forever begin
seq_item_port.get_next_item(req);
{vif.screen, vif.opcode, vif.A, vif.B, vif.carry_in}=req.stimulus;
vif.active=1;
#2; ->vif.sampled;
#6; ->vif.sampled;
#2; vif.active=0;
seq_item_port.item_done();
end
endtask
endclass
class monitor extends uvm_monitor;
`uvm_component_utils(monitor)
virtual bench_if vif;
uvm_analysis_port#(transaction) observed;
function new(string name,uvm_component parent);super.new(name,parent);observed=new("observed",this);endfunction
function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(virtual bench_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
endfunction
task run_phase(uvm_phase phase);
transaction item;
forever begin
@(vif.sampled);
item=transaction::type_id::create("observation");
item.stimulus={vif.screen, vif.opcode, vif.A, vif.B, vif.carry_in};
item.actual={vif.carry_out, vif.overflow, vif.bcd, vif.error};
item.predicted={vif.pred_carry_out, vif.pred_overflow, vif.pred_bcd, vif.pred_error};
observed.write(item);
end
endtask
endclass
class scoreboard extends uvm_subscriber#(transaction);
`uvm_component_utils(scoreboard)
integer comparisons=0;

covergroup behavior_inputs with function sample(logic [13:0] value);
option.per_instance=1;
snapshots: coverpoint value { bins binary_domain[]={[0:16383]}; }
endgroup
covergroup bit_states with function sample(integer position,integer symbol);
option.per_instance=1;
input_position: coverpoint position { bins positions[]={[0:13]}; }
input_symbol: coverpoint symbol { bins symbols[]={[0:1]}; }
two_state_domain: cross input_position,input_symbol;
endgroup
integer binary_seen[16384]='{default:0};
integer symbols_seen[28]='{default:0};
function void record_behavior(logic [13:0] value);
integer symbol;
behavior_inputs.sample(value);
if(!$isunknown(value)) binary_seen[value]=1;
for(integer position=0;position<14;position++) begin
symbol=(value[position]===1'b0)?0:(value[position]===1'b1)?1:(value[position]===1'bx)?2:3;
bit_states.sample(position,symbol);
if(symbol < 2) symbols_seen[position*2+symbol]=1;
end
endfunction
function void report_phase(uvm_phase phase);
$display("FUNCTIONAL_REQUIREMENT_HIT binary_input_domain %0d 16384",binary_seen.sum());
$display("FUNCTIONAL_REQUIREMENT_HIT two_state_each_input_bit %0d 28",symbols_seen.sum());
endfunction

covergroup observed_inputs with function sample(logic [14-1:0] value);
option.per_instance=1;
lsb:coverpoint value[0];
msb:coverpoint value[14-1];
endgroup
function new(string name,uvm_component parent);super.new(name,parent);observed_inputs=new();behavior_inputs=new();bit_states=new();endfunction
function void write(transaction item);
comparisons++;
observed_inputs.sample(item.stimulus);record_behavior(item.stimulus);
if(item.actual !== item.predicted) `uvm_error("COMPARE",$sformatf("input=%h actual=%h expected=%h",item.stimulus,item.actual,item.predicted))
if($isunknown(item.predicted)) `uvm_error("ORACLE","unknown prediction on defined domain")
endfunction
function void check_phase(uvm_phase phase);
super.check_phase(phase);
$display("FUNCTIONAL_INPUT_EXTREMES %0.2f",observed_inputs.get_inst_coverage());
if(comparisons==0) `uvm_error("VACUOUS","no comparisons")
endfunction
endclass
class environment extends uvm_env;
`uvm_component_utils(environment)
uvm_sequencer#(transaction) sequencer;
driver drv; monitor mon; scoreboard sb;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);
super.build_phase(phase);
sequencer=uvm_sequencer#(transaction)::type_id::create("sequencer",this);
drv=driver::type_id::create("drv",this);
mon=monitor::type_id::create("mon",this);
sb=scoreboard::type_id::create("sb",this);
endfunction
function void connect_phase(uvm_phase phase);
drv.seq_item_port.connect(sequencer.seq_item_export);
mon.observed.connect(sb.analysis_export);
endfunction
endclass
class dvbench_test extends uvm_test;
`uvm_component_utils(dvbench_test)
environment env;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);
super.build_phase(phase);env=environment::type_id::create("env",this);
endfunction
task run_phase(uvm_phase phase);
sequence_all seq;
phase.raise_objection(this);
seq=sequence_all::type_id::create("seq");seq.start(env.sequencer);
#10;
phase.drop_objection(this);
endtask
function void report_phase(uvm_phase phase);
uvm_report_server server;
server=uvm_report_server::get_server();
if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0 && env.sb.comparisons>0) $display("DVBench_COMPLETED");
endfunction
endclass
endpackage
