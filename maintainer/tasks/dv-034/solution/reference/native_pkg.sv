`timescale 1ns/1ps
package native_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class native_transaction extends uvm_sequence_item;
  `uvm_object_utils(native_transaction)
  logic [8-1:0] value;
  integer cycles;
  function new(string name="native_transaction");super.new(name);endfunction
endclass
class native_sequence extends uvm_sequence#(native_transaction);
  `uvm_object_utils(native_sequence)
  logic [8-1:0] drive=0;
  longint source_cycles=1;
  function new(string name="native_sequence");super.new(name);endfunction
  task apply(logic [8-1:0] value,integer cycles);
    native_transaction transaction;
    transaction=native_transaction::type_id::create("transaction");
    start_item(transaction);transaction.value=value;transaction.cycles=cycles;finish_item(transaction);
    source_cycles+=cycles;
  endtask
  task slow_tick(logic [8-1:0] value);
    longint next_tick;
    if(source_cycles<25000000)next_tick=25000000;
    else next_tick=25000000+((source_cycles-25000000)/50000000+1)*50000000;
    apply(value,next_tick-source_cycles);
  endtask
  task body();
    `include "stimulus.svh"
  endtask
endclass
class native_driver extends uvm_driver#(native_transaction);
  `uvm_component_utils(native_driver)
  virtual native_if vif;
  logic [63:0] history_hash=64'hcbf29ce484222325;
  longint unsigned driven_cycles=0;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","driver interface missing")
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      @(negedge vif.clock);vif.driven=req.value;
      history_hash=(history_hash ^ req.value ^ req.cycles)*64'h100000001b3;
      driven_cycles+=req.cycles;
      #(10ns*req.cycles-5ns);
      seq_item_port.item_done();
    end
  endtask
  function void report_phase(uvm_phase phase);
    `uvm_info("INPUT_HISTORY",$sformatf("hash=%h cycles=%0d",history_hash,driven_cycles),UVM_LOW)
  endfunction
endclass
class native_observation extends uvm_sequence_item;
  `uvm_object_utils(native_observation)
  logic [33-1:0] actual;
  logic [33-1:0] predicted;
  function new(string name="native_observation");super.new(name);endfunction
endclass
class native_monitor extends uvm_monitor;
  `uvm_component_utils(native_monitor)
  virtual native_if vif;
  uvm_analysis_port#(native_observation) observations;
  function new(string name,uvm_component parent);super.new(name,parent);observations=new("observations",this);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","monitor interface missing")
  endfunction
  task run_phase(uvm_phase phase);
    native_observation sample;
    forever begin
      @(posedge vif.clock or vif.alarm_sound or vif.ls_hour or vif.ls_minute or vif.ms_hour or vif.ms_minute or vif.pred_alarm_sound or vif.pred_ls_hour or vif.pred_ls_minute or vif.pred_ms_hour or vif.pred_ms_minute or vif.driven);#1;
      sample=native_observation::type_id::create("sample");
      sample.actual={vif.alarm_sound,vif.ls_hour,vif.ls_minute,vif.ms_hour,vif.ms_minute};sample.predicted={vif.pred_alarm_sound,vif.pred_ls_hour,vif.pred_ls_minute,vif.pred_ms_hour,vif.pred_ms_minute};
      observations.write(sample);
    end
  endtask
endclass
class native_predictor extends uvm_component;
  `uvm_component_utils(native_predictor)
  uvm_analysis_imp#(native_observation,native_predictor) observations;
  uvm_analysis_port#(native_observation) predictions;
  function new(string name,uvm_component parent);
    super.new(name,parent);observations=new("observations",this);predictions=new("predictions",this);
  endfunction
  function void write(native_observation sample);predictions.write(sample);endfunction
endclass
class native_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(native_scoreboard)
  virtual native_if vif;
  integer comparisons=0;
  integer mismatches=0;
  uvm_analysis_imp#(native_observation,native_scoreboard) predictions;
  function new(string name,uvm_component parent);super.new(name,parent);predictions=new("predictions",this);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","scoreboard interface missing")
  endfunction
  function void write(native_observation sample);
    if($time<30)return;
    comparisons++;
    if(1) begin
  if(vif.alarm_sound !== vif.pred_alarm_sound) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("alarm_sound actual=%h expected=%h",vif.alarm_sound,vif.pred_alarm_sound))
  end
end
if(1) begin
  if(vif.ls_hour !== vif.pred_ls_hour) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("ls_hour actual=%h expected=%h",vif.ls_hour,vif.pred_ls_hour))
  end
end
if(1) begin
  if(vif.ls_minute !== vif.pred_ls_minute) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("ls_minute actual=%h expected=%h",vif.ls_minute,vif.pred_ls_minute))
  end
end
if(1) begin
  if(vif.ms_hour !== vif.pred_ms_hour) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("ms_hour actual=%h expected=%h",vif.ms_hour,vif.pred_ms_hour))
  end
end
if(1) begin
  if(vif.ms_minute !== vif.pred_ms_minute) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("ms_minute actual=%h expected=%h",vif.ms_minute,vif.pred_ms_minute))
  end
end

  endfunction
  function void check_phase(uvm_phase phase);
    if(comparisons==0) `uvm_error("VACUOUS","no comparison performed")
    `uvm_info("COUNTS",$sformatf("compared=%0d mismatched=%0d",comparisons,mismatches),UVM_LOW)
  endfunction
endclass
class native_checker extends uvm_subscriber#(native_observation);
  `uvm_component_utils(native_checker)
  integer observed=0;
  integer checked=0;
  virtual native_if vif;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","checker interface missing")
  endfunction
  function void write(native_observation sample);
    observed++;
    if($time<30)return;
    if(vif.reset && {vif.ms_hour,vif.ls_hour,vif.ms_minute,vif.ls_minute,vif.alarm_sound} !== {32'h30303030,1'b1})
                    `uvm_error("ASYNC_RESET","reset outputs failed to settle between source edges")
                  if(!vif.reset && (vif.ms_hour>8'h32 || vif.ls_hour>8'h39 || vif.ms_minute>8'h35 || vif.ls_minute>8'h39 ||
                      vif.ms_hour<8'h30 || vif.ls_hour<8'h30 || vif.ms_minute<8'h30 || vif.ls_minute<8'h30))
                    `uvm_error("DIGIT_DOMAIN","ASCII time digit outside legal domain")
    checked++;
  endfunction
  function void check_phase(uvm_phase phase);
    if(checked==0) `uvm_error("CHECKER","no protocol observation")
  endfunction
endclass
class native_coverage extends uvm_subscriber#(native_observation);
  `uvm_component_utils(native_coverage)
  logic [7:0] observed;
  virtual native_if vif;
  covergroup output_events;
    option.per_instance=1;
    reset:coverpoint vif.reset;
 speed:coverpoint vif.fastwatch;
 units:coverpoint vif.ls_minute {bins decimal[]={[8'h30:8'h39]};bins carry=(8'h39=>8'h30);}
 tens:coverpoint vif.ms_minute {bins decimal[]={[8'h30:8'h35]};}
 hour_units:coverpoint vif.ls_hour {bins decimal[]={[8'h30:8'h39]};}
 hour_tens:coverpoint vif.ms_hour {bins decimal[]={[8'h30:8'h32]};}
 sound:coverpoint vif.alarm_sound;
 key:coverpoint vif.key {bins legal[]={[0:10]};}
 buttons:coverpoint {vif.time_button,vif.alarm_button};
  endgroup
  function new(string name,uvm_component parent);super.new(name,parent);output_events=new;endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","coverage interface missing")
  endfunction
  function void write(native_observation sample);observed=sample.actual;output_events.sample();endfunction
endclass
class native_env extends uvm_env;
  `uvm_component_utils(native_env)
  uvm_sequencer#(native_transaction) sequencer;
  native_driver driver;
  native_monitor monitor;
  native_predictor predictor;
  native_scoreboard scoreboard;
  native_checker checker;
  native_coverage coverage;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer=uvm_sequencer#(native_transaction)::type_id::create("sequencer",this);
    driver=native_driver::type_id::create("driver",this);
    monitor=native_monitor::type_id::create("monitor",this);
    predictor=native_predictor::type_id::create("predictor",this);
    scoreboard=native_scoreboard::type_id::create("scoreboard",this);
    checker=native_checker::type_id::create("checker",this);
    coverage=native_coverage::type_id::create("coverage",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.observations.connect(predictor.observations);
    predictor.predictions.connect(scoreboard.predictions);
    monitor.observations.connect(checker.analysis_export);
    monitor.observations.connect(coverage.analysis_export);
  endfunction
endclass
class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  native_env environment;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);environment=native_env::type_id::create("environment",this);endfunction
  task run_phase(uvm_phase phase);
    native_sequence active_sequence;
    phase.raise_objection(this);active_sequence=native_sequence::type_id::create("active_sequence");
    active_sequence.start(environment.sequencer);#30;phase.drop_objection(this);
  endtask
  function void report_phase(uvm_phase phase);
    uvm_report_server server;
    server=uvm_report_server::get_server();
    if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)
      $display("DVBench_COMPLETED");
    $display("DVBench_END_OF_RUN");
  endfunction
endclass
endpackage
