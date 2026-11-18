`timescale 1ns/1ps
package pins_pkg;
import uvm_pkg::*;`include "uvm_macros.svh"
class pin_item extends uvm_sequence_item;
 `uvm_object_utils(pin_item)
 logic[514:0]d;logic[193:0]a,e,m;
 function new(string n="pin_item");super.new(n);endfunction
endclass
class history_sequence extends uvm_sequence#(pin_item);
 `uvm_object_utils(history_sequence)
 function new(string n="history_sequence");super.new(n);endfunction
 task drive(input logic[514:0]d);pin_item t=pin_item::type_id::create("t");start_item(t);t.d=d;finish_item(t);endtask
 `include "stimulus.svh"
 task body();history();endtask
endclass
class pin_driver extends uvm_driver#(pin_item);
 `uvm_component_utils(pin_driver)
 virtual pins_if v;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);if(!uvm_config_db#(virtual pins_if)::get(this,"","vif",v))`uvm_fatal("VIF","missing")endfunction
 task run_phase(uvm_phase p);pin_item t;forever begin seq_item_port.get_next_item(t);@(negedge v.clock_i);v.drive_inputs=t.d;@(posedge v.clock_i);#2;seq_item_port.item_done();end endtask
endclass
class pin_monitor extends uvm_monitor;
 `uvm_component_utils(pin_monitor)
 virtual pins_if v;uvm_analysis_port#(pin_item)ap;
 function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);if(!uvm_config_db#(virtual pins_if)::get(this,"","vif",v))`uvm_fatal("VIF","missing")endfunction
 task run_phase(uvm_phase p);pin_item t;forever begin @(v.clock_i);#1;t=new;t.a=v.actual;t.e=v.expected;t.m=v.mask;t.d=v.drive_inputs;ap.write(t);end endtask
endclass
class pin_scoreboard extends uvm_scoreboard;
 `uvm_component_utils(pin_scoreboard)
 uvm_analysis_imp#(pin_item,pin_scoreboard)imp;int points=0,mismatches=0,checked=0;
 function new(string n,uvm_component p);super.new(n,p);imp=new("imp",this);endfunction
 function void write(pin_item t);points++;if(|t.m)checked++;if((t.a&t.m)!==(t.e&t.m))begin mismatches++;if(mismatches<=20)`uvm_error("COMPARE",$sformatf("point=%0d input=%h actual=%h expected=%h mask=%h",points,t.d,t.a,t.e,t.m))end endfunction
 function void report_phase(uvm_phase p);`uvm_info("COUNTS",$sformatf("points=%0d checked=%0d mismatches=%0d",points,checked,mismatches),UVM_NONE)if(points<100||checked<100)`uvm_error("VACUOUS","too few checked observations")endfunction
endclass
class pin_coverage extends uvm_subscriber#(pin_item);
 `uvm_component_utils(pin_coverage)
 logic[7:0]input_low;logic any_valid;
 covergroup cg;option.per_instance=1;cp_low:coverpoint input_low{bins low[16]={[0:255]};}cp_checked:coverpoint any_valid;endgroup
 function new(string n,uvm_component p);super.new(n,p);cg=new;endfunction
 function void write(pin_item t);input_low=t.d[7:0];any_valid=|t.m;cg.sample();endfunction
endclass
class pin_agent extends uvm_agent;
 `uvm_component_utils(pin_agent)
 uvm_sequencer#(pin_item)s;pin_driver d;pin_monitor m;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);s=new("s",this);d=pin_driver::type_id::create("d",this);m=pin_monitor::type_id::create("m",this);endfunction
 function void connect_phase(uvm_phase p);d.seq_item_port.connect(s.seq_item_export);endfunction
endclass
class pin_env extends uvm_env;
 `uvm_component_utils(pin_env)
 pin_agent a;pin_scoreboard sb;pin_coverage cov;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);a=pin_agent::type_id::create("a",this);sb=pin_scoreboard::type_id::create("sb",this);cov=pin_coverage::type_id::create("cov",this);endfunction
 function void connect_phase(uvm_phase p);a.m.ap.connect(sb.imp);a.m.ap.connect(cov.analysis_export);endfunction
endclass
class dvbench_test extends uvm_test;
 `uvm_component_utils(dvbench_test)
 pin_env env;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);env=pin_env::type_id::create("env",this);endfunction
 task run_phase(uvm_phase p);history_sequence s=new;p.raise_objection(this);s.start(env.a.s);#3;p.drop_objection(this);endtask
 function void report_phase(uvm_phase p);if(env.sb.mismatches==0&&env.sb.checked>=100)`uvm_info("DVBench_COMPLETED","DVBench_COMPLETED",UVM_NONE)endfunction
endclass
endpackage
