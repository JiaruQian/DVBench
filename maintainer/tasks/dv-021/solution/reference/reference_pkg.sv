`timescale 1ns/1ps
package reference_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class reference_item extends uvm_sequence_item;
  `uvm_object_utils(reference_item)
  logic [1023:0] inputs, actual, predicted, valid_mask;
  int tag; int delay_ns = 4; int clock_cycles=0; int probe_stride=1000;
  function new(string name="reference_item"); super.new(name); endfunction
endclass
class reference_driver extends uvm_driver #(reference_item);
  `uvm_component_utils(reference_driver)
  virtual reference_if vif;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual reference_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      #(req.delay_ns);
      vif.btnL = req.inputs[0 +: 1]; vif.btnR = req.inputs[1 +: 1]; vif.btnU = req.inputs[2 +: 1]; vif.btuD = req.inputs[3 +: 1]; vif.clk = req.inputs[4 +: 1]; vif.rst = req.inputs[5 +: 1]; vif.sw = req.inputs[6 +: 3];
      vif.valid_mask=req.valid_mask; vif.tag=req.tag;
      if(req.clock_cycles>0) begin
        for(int clock_index=0;clock_index<req.clock_cycles;clock_index++) begin
          vif.clk=0; #4; vif.clk=1; #1;
          if(clock_index%req.probe_stride==0 || clock_index<8 || clock_index>=req.clock_cycles-8) ->vif.observe;
          #3;
        end
        vif.clk=0;
      end
      #1; ->vif.observe;
      #1; seq_item_port.item_done();
    end
  endtask
endclass
class reference_monitor extends uvm_monitor;
  `uvm_component_utils(reference_monitor)
  virtual reference_if vif;
  uvm_analysis_port #(reference_item) ap;
  function new(string name,uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual reference_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  task run_phase(uvm_phase phase);
    reference_item item;
    forever begin
      @vif.observe; item=reference_item::type_id::create("observed");
      item.actual='0; item.actual[0 +: 4] = vif.fnd_com; item.actual[4 +: 8] = vif.fnd_data; item.actual[12 +: 8] = vif.led;
      item.valid_mask=vif.valid_mask; item.tag=vif.tag; ap.write(item);
    end
  endtask
endclass
class reference_predictor extends uvm_component;
  `uvm_component_utils(reference_predictor)
  virtual reference_if vif;
  uvm_analysis_imp #(reference_item,reference_predictor) imp;
  uvm_analysis_port #(reference_item) ap;
  function new(string name,uvm_component parent); super.new(name,parent); imp=new("imp",this); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual reference_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  function void write(reference_item item);
    item.predicted='0; item.predicted[0 +: 4] = vif.predicted_fnd_com; item.predicted[4 +: 8] = vif.predicted_fnd_data; item.predicted[12 +: 8] = vif.predicted_led;
    ap.write(item);
  endfunction
endclass
class reference_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(reference_scoreboard)
  uvm_analysis_imp #(reference_item,reference_scoreboard) imp;
  int comparisons=0, mismatches=0;
  function new(string name,uvm_component parent); super.new(name,parent); imp=new("imp",this); endfunction
  function void write(reference_item item);
    if(item.valid_mask!='0) begin
      comparisons++;
      if((item.actual & item.valid_mask) !== (item.predicted & item.valid_mask)) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE",$sformatf("tag=%0d actual=%h expected=%h mask=%h",item.tag,item.actual,item.predicted,item.valid_mask))
      end
    end
  endfunction
  function void check_phase(uvm_phase phase);
    if(comparisons==0) `uvm_error("VACUOUS","no comparisons")
    if(mismatches>12) `uvm_error("TOTAL",$sformatf("total mismatches=%0d",mismatches))
  endfunction
  function void report_phase(uvm_phase phase);
    `uvm_info("COUNTS",$sformatf("points=%0d mismatches=%0d",comparisons,mismatches),UVM_NONE)
  endfunction
endclass
class reference_checker extends uvm_subscriber #(reference_item);
  `uvm_component_utils(reference_checker)
  int observed=0;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void write(reference_item item);
    if(item.valid_mask!='0) begin
      observed++;
      if($isunknown(item.actual & item.valid_mask)) `uvm_error("FOUR_STATE","unknown valid output")
    end
  endfunction
endclass
class reference_coverage extends uvm_subscriber #(reference_item);
  `uvm_component_utils(reference_coverage)
  int tag;
  covergroup behavior; option.per_instance=1; cp_tag: coverpoint tag { bins exercised[]={[0:31]}; } endgroup
  function new(string name,uvm_component parent); super.new(name,parent); behavior=new(); endfunction
  function void write(reference_item item); tag=item.tag; behavior.sample(); endfunction
endclass
class reference_sequence extends uvm_sequence #(reference_item);
  `uvm_object_utils(reference_sequence)
  logic [1023:0] pins='0;
  int serial=0;
  function new(string name="reference_sequence"); super.new(name); endfunction
  task send(logic [1023:0] mask, int tag=0, int delay_ns=4);
    reference_item item;
    item=reference_item::type_id::create("stimulus"); start_item(item);
    item.inputs=pins; item.valid_mask=mask; item.tag=tag; item.delay_ns=delay_ns;
    serial++; finish_item(item);
  endtask
  
  task hold_native(int cycles,int tag=0,int stride=1000);
    reference_item item;
    item=reference_item::type_id::create("long_native_clock_history"); start_item(item);
    item.inputs=pins; item.valid_mask=1024'hfffff; item.tag=tag; item.clock_cycles=cycles; item.probe_stride=stride;
    finish_item(item);
  endtask
  task press(int button);
    case(button)
      0:pins[1 +: 1]=1;1:pins[0 +: 1]=1;2:pins[2 +: 1]=1;3:pins[3 +: 1]=1;
    endcase
    hold_native(850000+$urandom_range(0,5000),2+button);
    pins[1 +: 1]=0;pins[0 +: 1]=0;pins[2 +: 1]=0;pins[3 +: 1]=0;
    hold_native(850000+$urandom_range(0,5000),1);
  endtask
  task body();
    string profile;
    void'($value$plusargs("witness=%s",profile));
    if(profile=="edit_increment") begin
      pins='0;pins[5]=1;send(1024'hfffff,20);hold_native(3,20,1);
      pins[5]=0;pins[6+:3]=2;hold_native(20,20,1);
      pins[6+:3]=6;hold_native(20,20,1);
      press(2);hold_native(850000,21);
      pins[6+:3]=7;hold_native(850000,22);
      press(1);press(2);hold_native(850000,23);
      return;
    end
    pins[5 +: 1]=1; send(1024'hfffff,0); hold_native(3,0,1);
    pins[5 +: 1]=0; hold_native(20,0,1);
    pins[1 +: 1]=1; hold_native(600000,1); pins[1 +: 1]=0; hold_native(850000,1);
    press(0); hold_native(2200000,6);
    press(0); hold_native(1100000,7); press(1); press(3); press(0); hold_native(1200000,8); press(0);
    pins[6 +: 3]=1; hold_native(850000,9);
    pins[6 +: 3]=2; hold_native(1100000,10);
    pins[6 +: 3]=6; hold_native(20,11,1);
    for(int cursor=0;cursor<5;cursor++) begin press(3); press(2); press(1); end
    press(0);
    pins[6 +: 3]=4; hold_native(20,12,1);
    pins[6 +: 3]=0; hold_native(20,12,1);
    pins[6 +: 3]=2; hold_native(1100000,13);
    for(int switch_value=0;switch_value<8;switch_value++) begin pins[6 +: 3]=switch_value; send(1024'hfffff,14); end
    pins[5 +: 1]=1; send(1024'hfffff,15); pins[5 +: 1]=0; hold_native(800010,15);
    pins='0;pins[5]=1;send(1024'hfffff,20);hold_native(3,20,1);
    pins[5]=0;pins[6+:3]=6;hold_native(20,20,1);
    press(2);hold_native(850000,21);
    pins[6+:3]=7;hold_native(850000,22);
    press(1);press(2);hold_native(850000,23);
    pins[6+:3]=6;hold_native(850000,24);
  endtask

endclass
class reference_env extends uvm_env;
  `uvm_component_utils(reference_env)
  uvm_sequencer #(reference_item) sequencer;
  reference_driver driver; reference_monitor monitor; reference_predictor predictor;
  reference_scoreboard scoreboard; reference_checker checker; reference_coverage coverage;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    sequencer=uvm_sequencer#(reference_item)::type_id::create("sequencer",this);
    driver=reference_driver::type_id::create("driver",this); monitor=reference_monitor::type_id::create("monitor",this);
    predictor=reference_predictor::type_id::create("predictor",this); scoreboard=reference_scoreboard::type_id::create("scoreboard",this);
    checker=reference_checker::type_id::create("checker",this); coverage=reference_coverage::type_id::create("coverage",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.ap.connect(predictor.imp); predictor.ap.connect(scoreboard.imp);
    monitor.ap.connect(checker.analysis_export); monitor.ap.connect(coverage.analysis_export);
  endfunction
endclass
class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  reference_env env;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); env=reference_env::type_id::create("env",this); endfunction
  task run_phase(uvm_phase phase);
    reference_sequence sequence_instance;
    phase.raise_objection(this); sequence_instance=reference_sequence::type_id::create("sequence_instance");
    sequence_instance.start(env.sequencer); #20; phase.drop_objection(this);
  endtask
  function void report_phase(uvm_phase phase);
    uvm_report_server server; server=uvm_report_server::get_server();
    if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
  endfunction
endclass
endpackage
