`timescale 1ns/1ps
package native_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class native_transaction extends uvm_sequence_item;
  `uvm_object_utils(native_transaction)
  logic [6-1:0] value;
  integer cycles;
  function new(string name="native_transaction");super.new(name);endfunction
endclass
class native_sequence extends uvm_sequence#(native_transaction);
  `uvm_object_utils(native_sequence)
  logic [6-1:0] drive=0;
  longint source_cycles=1;
  function new(string name="native_sequence");super.new(name);endfunction
  task apply(logic [6-1:0] value,integer cycles);
    native_transaction transaction;
    transaction=native_transaction::type_id::create("transaction");
    start_item(transaction);transaction.value=value;transaction.cycles=cycles;finish_item(transaction);
    source_cycles+=cycles;
    `uvm_info("NATIVE_PROGRESS",$sformatf("source_cycles=%0d simulation_time=%0t",source_cycles,$time),UVM_LOW)
  endtask
  task slow_tick(logic [6-1:0] value);
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
      @(negedge vif.CLOCK_50Mhz);vif.driven=req.value;
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
  logic [22-1:0] actual;
  logic [22-1:0] predicted;
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
      @(vif.HEX0 or vif.LCD_BLON or vif.LCD_DATA or vif.LCD_EN or vif.LCD_ON or vif.LCD_RS or vif.LCD_RW or vif.lock or vif.lock_c or vif.pred_HEX0 or vif.pred_LCD_BLON or vif.pred_LCD_DATA or vif.pred_LCD_EN or vif.pred_LCD_ON or vif.pred_LCD_RS or vif.pred_LCD_RW or vif.pred_lock or vif.pred_lock_c or vif.driven);#1;
      sample=native_observation::type_id::create("sample");
      sample.actual={vif.HEX0,vif.LCD_BLON,vif.LCD_DATA,vif.LCD_EN,vif.LCD_ON,vif.LCD_RS,vif.LCD_RW,vif.lock,vif.lock_c};sample.predicted={vif.pred_HEX0,vif.pred_LCD_BLON,vif.pred_LCD_DATA,vif.pred_LCD_EN,vif.pred_LCD_ON,vif.pred_LCD_RS,vif.pred_LCD_RW,vif.pred_lock,vif.pred_lock_c};
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
  if(vif.HEX0 !== vif.pred_HEX0) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("HEX0 actual=%h expected=%h",vif.HEX0,vif.pred_HEX0))
  end
end
if(1) begin
  if(vif.LCD_BLON !== vif.pred_LCD_BLON) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("LCD_BLON actual=%h expected=%h",vif.LCD_BLON,vif.pred_LCD_BLON))
  end
end
if(1) begin
  if(vif.LCD_DATA !== vif.pred_LCD_DATA) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("LCD_DATA actual=%h expected=%h",vif.LCD_DATA,vif.pred_LCD_DATA))
  end
end
if(1) begin
  if(vif.LCD_EN !== vif.pred_LCD_EN) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("LCD_EN actual=%h expected=%h",vif.LCD_EN,vif.pred_LCD_EN))
  end
end
if(1) begin
  if(vif.LCD_ON !== vif.pred_LCD_ON) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("LCD_ON actual=%h expected=%h",vif.LCD_ON,vif.pred_LCD_ON))
  end
end
if(1) begin
  if(vif.LCD_RS !== vif.pred_LCD_RS) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("LCD_RS actual=%h expected=%h",vif.LCD_RS,vif.pred_LCD_RS))
  end
end
if(1) begin
  if(vif.LCD_RW !== vif.pred_LCD_RW) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("LCD_RW actual=%h expected=%h",vif.LCD_RW,vif.pred_LCD_RW))
  end
end
if(1) begin
  if(vif.lock !== vif.pred_lock) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("lock actual=%h expected=%h",vif.lock,vif.pred_lock))
  end
end
if(1) begin
  if(vif.lock_c !== vif.pred_lock_c) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("lock_c actual=%h expected=%h",vif.lock_c,vif.pred_lock_c))
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
    if({vif.LCD_ON,vif.LCD_BLON,vif.LCD_RW} !== 3'b110)
                    `uvm_error("LCD_CONTROL","fixed LCD power/write signals incorrect")
                  if(!vif.KEY_0 && {vif.lock,vif.lock_c,vif.HEX0} !== {2'b00,7'b1111111})
                    `uvm_error("ASYNC_RESET","lock indicators do not clear between source edges")
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
    reset:coverpoint vif.KEY_0;
 key:coverpoint vif.keypad_input {bins digits[]={[0:9]};bins command={10};bins rejected[]={[11:15]};}
 valid:coverpoint vif.key_valid;
 open:coverpoint vif.lock;
 change:coverpoint vif.lock_c;
 seven_segment:coverpoint vif.HEX0 {bins blank={7'b1111111};bins digits[]={7'b1000000,7'b1111001,7'b0100100,7'b0110000,7'b0011001,7'b0010010,7'b0000010,7'b1111000,7'b0000000,7'b0010000};bins command={7'b1000110};}
 lcd_operation:coverpoint {vif.LCD_RS,vif.LCD_EN};
 lcd_command:coverpoint vif.LCD_DATA iff(!vif.LCD_RS && vif.LCD_EN) {bins initialization[]={8'h38,8'h08,8'h01,8'h06,8'h0c};bins addresses[]={8'h80,8'hc0};}
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
