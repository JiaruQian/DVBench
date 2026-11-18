package dvbench_pkg;
import uvm_pkg::*;import dvbench_stim::*;
`include "uvm_macros.svh"
class dvbench_item extends uvm_sequence_item;
 logic [387-1:0] pins;logic [129-1:0] actual,expected;
 `uvm_object_utils(dvbench_item)
 function new(string name="dvbench_item");super.new(name);endfunction
endclass
class dvbench_sequence extends uvm_sequence #(dvbench_item);
 `uvm_object_utils(dvbench_sequence)
 function new(string name="dvbench_sequence");super.new(name);endfunction
 task body();dvbench_item t;int seed;if(!$value$plusargs("ntb_random_seed=%d",seed))seed=1;
 for(int k=0;k<6440;k++)begin t=dvbench_item::type_id::create("t");start_item(t);t.pins=sample_pins(k,seed);finish_item(t);end
 endtask
endclass
class dvbench_driver extends uvm_driver #(dvbench_item);
 `uvm_component_utils(dvbench_driver)
 virtual dvbench_if vif;
 function new(string name,uvm_component p);super.new(name,p);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);if(!uvm_config_db#(virtual dvbench_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing") endfunction
 task run_phase(uvm_phase p);forever begin seq_item_port.get_next_item(req);@(negedge vif.clk);vif.pins=req.pins;#1;seq_item_port.item_done();end endtask
endclass
class dvbench_monitor extends uvm_monitor;
 `uvm_component_utils(dvbench_monitor)
 virtual dvbench_if vif;uvm_analysis_port #(dvbench_item) ap;
 function new(string name,uvm_component p);super.new(name,p);ap=new("ap",this);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);if(!uvm_config_db#(virtual dvbench_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing") endfunction
 task run_phase(uvm_phase p);dvbench_item t;@(negedge vif.clk);forever begin #2;t=dvbench_item::type_id::create("observed");t.pins=vif.pins;t.actual=vif.actual;t.expected=vif.expected;ap.write(t);@(vif.clk);end endtask
endclass
class dvbench_scoreboard extends uvm_scoreboard;
 `uvm_component_utils(dvbench_scoreboard)
 uvm_analysis_imp #(dvbench_item,dvbench_scoreboard) imp;int checks,errors;
 covergroup pins_cg with function sample(logic [387-1:0] pins,logic [129-1:0] observed);
  option.per_instance=1;cp_input:coverpoint pins[7:0];cp_output:coverpoint observed[7:0];
 endgroup
 function new(string name,uvm_component p);super.new(name,p);imp=new("imp",this);pins_cg=new;endfunction
 function void write(dvbench_item t);checks++;pins_cg.sample(t.pins,t.actual);if(t.actual!==t.expected)begin errors++;if(errors<30)`uvm_error("MISMATCH",$sformatf("point=%0d pins=%h actual=%h expected=%h",checks,t.pins,t.actual,t.expected))end endfunction
 function void check_phase(uvm_phase p);if(checks<2*6000-2)`uvm_error("VACUOUS",$sformatf("checks=%0d",checks))endfunction
 function void report_phase(uvm_phase p);`uvm_info("COUNTS",$sformatf("checks=%0d mismatches=%0d functional_coverage=%f",checks,errors,pins_cg.get_inst_coverage()),UVM_NONE) if(errors==0 && checks>=2*6000-2)$display("DVBench_COMPLETED");endfunction
endclass
class dvbench_agent extends uvm_agent;
 `uvm_component_utils(dvbench_agent)
 uvm_sequencer #(dvbench_item) sqr;dvbench_driver drv;dvbench_monitor mon;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);sqr=new("sqr",this);drv=dvbench_driver::type_id::create("drv",this);mon=dvbench_monitor::type_id::create("mon",this);endfunction
 function void connect_phase(uvm_phase p);drv.seq_item_port.connect(sqr.seq_item_export);endfunction
endclass
class dvbench_env extends uvm_env;
 `uvm_component_utils(dvbench_env)
 dvbench_agent agt;dvbench_scoreboard sb;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);agt=dvbench_agent::type_id::create("agt",this);sb=dvbench_scoreboard::type_id::create("sb",this);endfunction
 function void connect_phase(uvm_phase p);agt.mon.ap.connect(sb.imp);endfunction
endclass
class dvbench_test extends uvm_test;
 `uvm_component_utils(dvbench_test)
 dvbench_env env;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase p);super.build_phase(p);env=dvbench_env::type_id::create("env",this);endfunction
 task run_phase(uvm_phase p);dvbench_sequence s;p.raise_objection(this);s=dvbench_sequence::type_id::create("s");s.start(env.agt.sqr);repeat(2)@(posedge env.agt.drv.vif.clk);#3;p.drop_objection(this);endtask
endclass
endpackage
module dvbench_top;import uvm_pkg::*;import dvbench_pkg::*;
dvbench_if vif();AesCTR dut(.clk(vif.clk),.rst(vif.rst),.load(vif.load),.start(vif.start),.key(vif.key),.iv(vif.iv),.iBlock(vif.iBlock),.oBlock(vif.oBlock),.idle(vif.idle));dvbench_model model(.clk(vif.clk),.rst(vif.rst),.load(vif.load),.start(vif.start),.key(vif.key),.iv(vif.iv),.iBlock(vif.iBlock),.oBlock(vif.exp_oBlock),.idle(vif.exp_idle));
initial begin uvm_config_db#(virtual dvbench_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
