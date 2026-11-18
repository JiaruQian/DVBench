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
      vif.az_addr = req.inputs[0 +: 22]; vif.az_be_n = req.inputs[22 +: 2]; vif.az_cs = req.inputs[24 +: 1]; vif.az_data = req.inputs[25 +: 16]; vif.az_rd_n = req.inputs[41 +: 1]; vif.az_wr_n = req.inputs[42 +: 1]; vif.clk = req.inputs[43 +: 1]; vif.reset_n = req.inputs[44 +: 1];
      vif.external_drive=req.inputs[1000];vif.external_data=req.inputs[1001 +:16];vif.valid_mask=req.valid_mask; vif.tag=req.tag;
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
      item.actual='0; item.actual[0 +: 16] = vif.za_data; item.actual[16 +: 1] = vif.za_valid; item.actual[17 +: 1] = vif.za_waitrequest; item.actual[18 +: 12] = vif.zs_addr; item.actual[30 +: 2] = vif.zs_ba; item.actual[32 +: 1] = vif.zs_cas_n; item.actual[33 +: 1] = vif.zs_cke; item.actual[34 +: 1] = vif.zs_cs_n; item.actual[35 +: 16] = vif.zs_dq; item.actual[51 +: 2] = vif.zs_dqm; item.actual[53 +: 1] = vif.zs_ras_n; item.actual[54 +: 1] = vif.zs_we_n;
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
    item.predicted='0; item.predicted[0 +: 16] = vif.predicted_za_data; item.predicted[16 +: 1] = vif.predicted_za_valid; item.predicted[17 +: 1] = vif.predicted_za_waitrequest; item.predicted[18 +: 12] = vif.predicted_zs_addr; item.predicted[30 +: 2] = vif.predicted_zs_ba; item.predicted[32 +: 1] = vif.predicted_zs_cas_n; item.predicted[33 +: 1] = vif.predicted_zs_cke; item.predicted[34 +: 1] = vif.predicted_zs_cs_n; item.predicted[35 +: 16] = vif.predicted_zs_dq; item.predicted[51 +: 2] = vif.predicted_zs_dqm; item.predicted[53 +: 1] = vif.predicted_zs_ras_n; item.predicted[54 +: 1] = vif.predicted_zs_we_n;
    ap.write(item);
  endfunction
endclass
class reference_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(reference_scoreboard)
  uvm_analysis_imp #(reference_item,reference_scoreboard) imp;
  int comparisons=0, mismatches=0;
  function new(string name,uvm_component parent); super.new(name,parent); imp=new("imp",this); endfunction
  function void write(reference_item item);
    bit mismatch;
    mismatch=0;
    for(int signal_bit=0;signal_bit<55;signal_bit++)
      if(item.valid_mask[signal_bit] && item.actual[signal_bit] !== item.predicted[signal_bit]) mismatch=1;
    if(item.valid_mask!='0) begin
      comparisons++;
      if(mismatch) begin
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
      for(int dq_bit=35;dq_bit<51;dq_bit++)
        if(item.valid_mask[dq_bit] && item.actual[dq_bit] === 1'bx) `uvm_error("DQ_UNKNOWN","X on valid DQ bit; bus contention is invalid")
      if($isunknown(item.actual & item.valid_mask & ~1024'd2251765453946880)) `uvm_error("FOUR_STATE","unknown valid output")
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
  
  virtual reference_if stimulus_if;
  task cycle_native(int tag=0);
    logic [1023:0] mask;
    pins[43 +: 1]=0; send(0,tag);
    pins[43 +: 1]=1; send(0,tag);
    mask=1024'd36028797018898432;
    if(stimulus_if.predicted_za_valid) mask[0 +: 16]='1;
    send(mask,tag);
    pins[43 +: 1]=0;send(mask,tag);
  endtask
  task idle(int cycles,int tag=0);
    pins[41 +: 1]=1;pins[42 +: 1]=1;
    repeat(cycles) cycle_native(tag);
  endtask
  task request_port(bit read_op,int address,int data,int byte_mask,int tag=1,bit both=0);
    pins[0 +: 22]=address;pins[25 +: 16]=data;pins[22 +: 2]=byte_mask;
    pins[24 +: 1]=$urandom_range(0,1);
    pins[41 +: 1]=read_op ? 0 : !both;pins[42 +: 1]=read_op;
    while(stimulus_if.predicted_za_waitrequest) cycle_native(tag);
    cycle_native(tag);
  endtask
  task body();
    if(!uvm_config_db#(virtual reference_if)::get(null,"","vif",stimulus_if)) `uvm_fatal("VIF","missing")
    pins[41 +: 1]=1;pins[42 +: 1]=1;pins[44 +: 1]=0;
    send(1024'd36028797018898432,0); pins[44 +: 1]=1;
    request_port(0,0,16'h1234,0,1);request_port(0,1,16'habcd,1,1);
    request_port(0,2,16'h8765,2,1,1);idle(40,2);
    for(int bank=0;bank<4;bank++) begin
      for(int mask=0;mask<4;mask++) request_port(0,((bank>>1)<<21)|((bank&1)<<8)|mask,$urandom,mask,3);
      request_port(0,((bank>>1)<<21)|((bank&1)<<8)|22'h1ffe00|255,$urandom,0,4);
      idle(20,4);
    end
    for(int stream_event=0;stream_event<1000;stream_event++) request_port(0,22'h4000|(stream_event%256),$urandom,stream_event%4,5);
    idle(100,5);
    pins[1000]=1;pins[1001 +:16]=$urandom;
    for(int read_event=0;read_event<1000;read_event++) request_port(1,22'h8000|(read_event%256),0,0,6);
    idle(100,6);
    request_port(1,22'h8005,0,0,7);idle(20,7);
    request_port(1,22'h8205,0,0,7);idle(20,7);
    idle(1700,8);
    pins[44 +: 1]=0;pins[41 +: 1]=1;pins[42 +: 1]=1;send(1024'd36028797018898432,9);
    pins[1000]=0;pins[44 +: 1]=1;idle(5040,9);
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
