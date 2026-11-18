
package reference_pkg;
import uvm_pkg::*;
import port_types::*;
`include "uvm_macros.svh"
class command_item extends uvm_sequence_item;
 `uvm_object_utils(command_item)
 command_t pins;
 function new(string n="command_item");super.new(n);endfunction
endclass
class observation extends uvm_sequence_item;
 `uvm_object_utils(observation)
 response_t actual,expected;logic reset;int phase_kind;
 function new(string n="observation");super.new(n);endfunction
endclass
class stimulus_sequence extends uvm_sequence#(command_item);
 `uvm_object_utils(stimulus_sequence)
 function new(string n="stimulus_sequence");super.new(n);endfunction
 task drive(input command_t value);
  command_item t=command_item::type_id::create("command");
  start_item(t);t.pins=value;finish_item(t);
 endtask
 `include "histories.svh"
 `include "crc_width_witnesses.svh"
 task body();histories();crc_width_witnesses();endtask
endclass
class pin_driver extends uvm_driver#(command_item);
 `uvm_component_utils(pin_driver)
 virtual port_if vif;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);
 if(!uvm_config_db#(virtual port_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing interface")
 endfunction
 task run_phase(uvm_phase phase);
 command_item t;
 forever begin
 seq_item_port.get_next_item(t);
 @(negedge vif.clk);vif.command=t.pins;
 @(posedge vif.clk);#2;seq_item_port.item_done();
 end
 endtask
endclass
class pin_monitor extends uvm_component;
 `uvm_component_utils(pin_monitor)
 virtual port_if vif;uvm_analysis_port#(observation) ap;
 function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);endfunction
 function void build_phase(uvm_phase phase);
 if(!uvm_config_db#(virtual port_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing interface")
 endfunction
 function void capture(int phase_kind);
 observation s=observation::type_id::create("sample");
 s.actual=vif.actual;s.expected=vif.expected;s.reset=vif.command.Reset;s.phase_kind=phase_kind;ap.write(s);
 endfunction
 task run_phase(uvm_phase phase);
 fork
 forever begin @(posedge vif.clk);#1;capture(0);end
 forever begin @(negedge vif.clk);#1;capture(1);end
 forever begin @(posedge vif.command.Reset);#1;capture(2);end
 join
 endtask
endclass
class port_scoreboard extends uvm_subscriber#(observation);
 `uvm_component_utils(port_scoreboard)
 int points=0,mismatches=0,resets=0;
 covergroup observed with function sample(response_t value);
option.per_instance=1;
cp_RxValid:coverpoint value.RxValid;
cp_RxStartFrm:coverpoint value.RxStartFrm;
cp_RxEndFrm:coverpoint value.RxEndFrm;
cp_ByteCntEq0:coverpoint value.ByteCntEq0;
cp_ByteCntGreat2:coverpoint value.ByteCntGreat2;
cp_ByteCntMaxFrame:coverpoint value.ByteCntMaxFrame;
cp_CrcError:coverpoint value.CrcError;
cp_StateIdle:coverpoint value.StateIdle;
cp_StatePreamble:coverpoint value.StatePreamble;
cp_StateSFD:coverpoint value.StateSFD;
cp_StateData:coverpoint value.StateData;
cp_RxAbort:coverpoint value.RxAbort;
cp_AddressMiss:coverpoint value.AddressMiss;
endgroup
 function new(string n,uvm_component p);super.new(n,p);observed=new;endfunction
 function void write(observation s);
 points++;if(s.phase_kind==2)resets++;
 observed.sample(s.actual);
 if(s.actual!==s.expected)begin
 mismatches++;
 if(mismatches<=20)`uvm_error("COMPARE",$sformatf("point=%0d phase=%0d actual=%h expected=%h",points,s.phase_kind,s.actual,s.expected))
 end
 endfunction
 function void check_phase(uvm_phase phase);
 if(points<60000||resets<2)`uvm_error("NONVACUITY","Insufficient sampled histories/reset events")
 endfunction
 function void report_phase(uvm_phase phase);
 `uvm_info("COUNTS",$sformatf("points=%0d mismatches=%0d resets=%0d",points,mismatches,resets),UVM_NONE)
 endfunction
endclass
class port_agent extends uvm_agent;
 `uvm_component_utils(port_agent)
 uvm_sequencer#(command_item) sequencer;pin_driver driver;pin_monitor monitor;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);
 sequencer=uvm_sequencer#(command_item)::type_id::create("sequencer",this);
 driver=pin_driver::type_id::create("driver",this);monitor=pin_monitor::type_id::create("monitor",this);
 endfunction
 function void connect_phase(uvm_phase phase);driver.seq_item_port.connect(sequencer.seq_item_export);endfunction
endclass
class port_env extends uvm_env;
 `uvm_component_utils(port_env)
 port_agent agent;port_scoreboard sb;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);
 agent=port_agent::type_id::create("agent",this);sb=port_scoreboard::type_id::create("sb",this);
 endfunction
 function void connect_phase(uvm_phase phase);agent.monitor.ap.connect(sb.analysis_export);endfunction
endclass
class dvbench_test extends uvm_test;
 `uvm_component_utils(dvbench_test)
 port_env env;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);env=port_env::type_id::create("env",this);endfunction
 task run_phase(uvm_phase phase);
 stimulus_sequence seq=stimulus_sequence::type_id::create("seq");
 phase.raise_objection(this);seq.start(env.agent.sequencer);
 repeat(3)@(negedge env.agent.driver.vif.clk);
 phase.drop_objection(this);
 endtask
 function void report_phase(uvm_phase phase);
 uvm_report_server server=uvm_report_server::get_server();
 if(server.get_severity_count(UVM_ERROR)==0&&server.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");
 else $display("DVBench_FINISHED_WITH_ERRORS");
 endfunction
endclass
endpackage
