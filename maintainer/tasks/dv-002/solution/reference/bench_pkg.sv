`timescale 1ns/1ps
package bench_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class transaction extends uvm_sequence_item;
`uvm_object_utils(transaction)
logic [67-1:0] stimulus;
logic [40-1:0] actual, predicted;
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
task send(logic [67-1:0] value);
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
{vif.dbg_halt_st, vif.exec_cycle, vif.inst_alu, vif.inst_bw, vif.inst_jmp, vif.inst_so, vif.op_dst, vif.op_src, vif.status}=req.stimulus;
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
item.stimulus={vif.dbg_halt_st, vif.exec_cycle, vif.inst_alu, vif.inst_bw, vif.inst_jmp, vif.inst_so, vif.op_dst, vif.op_src, vif.status};
item.actual={vif.alu_out, vif.alu_out_add, vif.alu_stat, vif.alu_stat_wr};
item.predicted={vif.pred_alu_out, vif.pred_alu_out_add, vif.pred_alu_stat, vif.pred_alu_stat_wr};
observed.write(item);
end
endtask
endclass
class scoreboard extends uvm_subscriber#(transaction);
`uvm_component_utils(scoreboard)
integer comparisons=0;

covergroup behavior_inputs with function sample(logic [66:0] value);
option.per_instance=1;
execution: coverpoint value[65];
byte_mode: coverpoint value[52];
source_invert: coverpoint value[53];
source_shaping: cross execution,byte_mode,source_invert;
jumps: coverpoint value[51:44] { bins combinations[]={[0:255]}; }
old_flags: coverpoint value[3:0] { bins combinations[]={[0:15]}; }
jump_history: cross jumps,old_flags;
increments: coverpoint value[55:54] { bins combinations[]={[0:3]}; }
old_carry: coverpoint value[0];
increment_controls: cross execution,increments,old_carry;
decimal_source: coverpoint value[7:4] iff(value[60]&&!value[56]&&!value[43]&&!value[66]) { bins nibbles[]={[0:15]}; }
decimal_destination: coverpoint value[23:20] iff(value[60]&&!value[56]&&!value[43]&&!value[66]) { bins nibbles[]={[0:15]}; }
decimal_carry: coverpoint value[0] iff(value[60]&&!value[56]&&!value[43]&&!value[66]);
decimal_low_group: cross decimal_source,decimal_destination,decimal_carry;
short_paths: coverpoint {value[39],value[37],value[63],value[59:57]} { bins combinations[]={[0:63]}; }
status_paths: coverpoint {value[63],value[61],value[59]} { bins combinations[]={[0:7]}; }
status_priority: cross status_paths,byte_mode;
write_control: coverpoint {value[65],value[62]} { bins combinations[]={[0:3]}; }
endgroup
integer shaped_seen[8]='{default:0};
integer jump_seen[4096]='{default:0};
integer increment_seen[16]='{default:0};
integer decimal_seen[512]='{default:0};
integer short_seen[64]='{default:0};
integer flag_seen[16]='{default:0};
integer write_seen[4]='{default:0};
function void record_behavior(logic [66:0] value);
behavior_inputs.sample(value);
shaped_seen[{value[65],value[52],value[53]}]=1;
jump_seen[{value[51:44],value[3:0]}]=1;
increment_seen[{value[65],value[55:54],value[0]}]=1;
if(value[60]&&!value[56]&&!value[43]&&!value[66]) decimal_seen[{value[7:4],value[23:20],value[0]}]=1;
short_seen[{value[39],value[37],value[63],value[59:57]}]=1;
flag_seen[{value[63],value[61],value[59],value[52]}]=1;
write_seen[{value[65],value[62]}]=1;
endfunction
function void report_phase(uvm_phase phase);
$display("FUNCTIONAL_REQUIREMENT_HIT source_shaping %0d 8",shaped_seen.sum());
$display("FUNCTIONAL_REQUIREMENT_HIT jump_status %0d 4096",jump_seen.sum());
$display("FUNCTIONAL_REQUIREMENT_HIT increment_controls %0d 16",increment_seen.sum());
$display("FUNCTIONAL_REQUIREMENT_HIT dadd_low_nibble_carry %0d 512",decimal_seen.sum());
$display("FUNCTIONAL_REQUIREMENT_HIT short_selectors %0d 64",short_seen.sum());
$display("FUNCTIONAL_REQUIREMENT_HIT status_priority_byte %0d 16",flag_seen.sum());
$display("FUNCTIONAL_REQUIREMENT_HIT flag_write_controls %0d 4",write_seen.sum());
endfunction

covergroup observed_inputs with function sample(logic [67-1:0] value);
option.per_instance=1;
lsb:coverpoint value[0];
msb:coverpoint value[67-1];
endgroup
function new(string name,uvm_component parent);super.new(name,parent);observed_inputs=new();behavior_inputs=new();endfunction
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
