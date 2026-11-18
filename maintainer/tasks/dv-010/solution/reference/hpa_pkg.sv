`timescale 1ns/1ps
package hpa_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class hpa_item extends uvm_sequence_item;
    `uvm_object_utils(hpa_item)
    int mode;
    int observations;
    rand logic reset;
    rand logic io_in_1_valid;
    rand logic [2:0] io_in_1_bits_opcode;
    rand logic [2:0] io_in_1_bits_param;
    rand logic [7:0] io_in_1_bits_size;
    rand logic [7:0] io_in_1_bits_source;
    rand logic [63:0] io_in_1_bits_data;
    rand logic io_in_1_bits_corrupt;
    rand logic [8:0] io_in_1_bits_union;
    rand logic io_in_1_bits_last;
    rand logic io_in_4_valid;
    rand logic [2:0] io_in_4_bits_opcode;
    rand logic [2:0] io_in_4_bits_param;
    rand logic [7:0] io_in_4_bits_size;
    rand logic [7:0] io_in_4_bits_source;
    rand logic [63:0] io_in_4_bits_address;
    rand logic [63:0] io_in_4_bits_data;
    rand logic io_in_4_bits_corrupt;
    rand logic [8:0] io_in_4_bits_union;
    rand logic io_in_4_bits_last;
    rand logic io_out_ready;
    logic io_in_1_ready;
    logic io_in_4_ready;
    logic io_out_valid;
    logic [2:0] io_out_bits_chanId;
    logic [2:0] io_out_bits_opcode;
    logic [2:0] io_out_bits_param;
    logic [7:0] io_out_bits_size;
    logic [7:0] io_out_bits_source;
    logic [63:0] io_out_bits_address;
    logic [63:0] io_out_bits_data;
    logic io_out_bits_corrupt;
    logic [8:0] io_out_bits_union;
    logic io_out_bits_last;
    logic expected_io_in_1_ready;
    logic expected_io_in_4_ready;
    logic expected_io_out_valid;
    logic [2:0] expected_io_out_bits_chanId;
    logic [2:0] expected_io_out_bits_opcode;
    logic [2:0] expected_io_out_bits_param;
    logic [7:0] expected_io_out_bits_size;
    logic [7:0] expected_io_out_bits_source;
    logic [63:0] expected_io_out_bits_address;
    logic [63:0] expected_io_out_bits_data;
    logic expected_io_out_bits_corrupt;
    logic [8:0] expected_io_out_bits_union;
    logic expected_io_out_bits_last;
    function new(string name="hpa_item"); super.new(name); endfunction
  endclass
  class hpa_driver extends uvm_driver #(hpa_item);
    `uvm_component_utils(hpa_driver)
    virtual hpa_if vif;
    function new(string name, uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual hpa_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
    endfunction
    task run_phase(uvm_phase phase);
      hpa_item item;
      forever begin
        seq_item_port.get_next_item(item);
        @(negedge vif.clock);
        vif.reset = item.reset;
        vif.io_in_1_valid = item.io_in_1_valid;
        vif.io_in_1_bits_opcode = item.io_in_1_bits_opcode;
        vif.io_in_1_bits_param = item.io_in_1_bits_param;
        vif.io_in_1_bits_size = item.io_in_1_bits_size;
        vif.io_in_1_bits_source = item.io_in_1_bits_source;
        vif.io_in_1_bits_data = item.io_in_1_bits_data;
        vif.io_in_1_bits_corrupt = item.io_in_1_bits_corrupt;
        vif.io_in_1_bits_union = item.io_in_1_bits_union;
        vif.io_in_1_bits_last = item.io_in_1_bits_last;
        vif.io_in_4_valid = item.io_in_4_valid;
        vif.io_in_4_bits_opcode = item.io_in_4_bits_opcode;
        vif.io_in_4_bits_param = item.io_in_4_bits_param;
        vif.io_in_4_bits_size = item.io_in_4_bits_size;
        vif.io_in_4_bits_source = item.io_in_4_bits_source;
        vif.io_in_4_bits_address = item.io_in_4_bits_address;
        vif.io_in_4_bits_data = item.io_in_4_bits_data;
        vif.io_in_4_bits_corrupt = item.io_in_4_bits_corrupt;
        vif.io_in_4_bits_union = item.io_in_4_bits_union;
        vif.io_in_4_bits_last = item.io_in_4_bits_last;
        vif.io_out_ready = item.io_out_ready;
        if (item.mode==1) begin
          #1 vif.reset=1;
          #2 vif.reset=0;
        end
        @(posedge vif.clock);
        #3;
        seq_item_port.item_done();
      end
    endtask
  endclass
  class hpa_monitor extends uvm_monitor;
    `uvm_component_utils(hpa_monitor)
    virtual hpa_if vif;
    uvm_analysis_port #(hpa_item) observed;
    function new(string name, uvm_component parent); super.new(name,parent); observed=new("observed",this); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual hpa_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
    endfunction
    task capture();
      hpa_item item=hpa_item::type_id::create("sample");
      item.reset=vif.reset;
      item.io_in_1_valid=vif.io_in_1_valid;
      item.io_in_1_bits_opcode=vif.io_in_1_bits_opcode;
      item.io_in_1_bits_param=vif.io_in_1_bits_param;
      item.io_in_1_bits_size=vif.io_in_1_bits_size;
      item.io_in_1_bits_source=vif.io_in_1_bits_source;
      item.io_in_1_bits_data=vif.io_in_1_bits_data;
      item.io_in_1_bits_corrupt=vif.io_in_1_bits_corrupt;
      item.io_in_1_bits_union=vif.io_in_1_bits_union;
      item.io_in_1_bits_last=vif.io_in_1_bits_last;
      item.io_in_4_valid=vif.io_in_4_valid;
      item.io_in_4_bits_opcode=vif.io_in_4_bits_opcode;
      item.io_in_4_bits_param=vif.io_in_4_bits_param;
      item.io_in_4_bits_size=vif.io_in_4_bits_size;
      item.io_in_4_bits_source=vif.io_in_4_bits_source;
      item.io_in_4_bits_address=vif.io_in_4_bits_address;
      item.io_in_4_bits_data=vif.io_in_4_bits_data;
      item.io_in_4_bits_corrupt=vif.io_in_4_bits_corrupt;
      item.io_in_4_bits_union=vif.io_in_4_bits_union;
      item.io_in_4_bits_last=vif.io_in_4_bits_last;
      item.io_out_ready=vif.io_out_ready;
      item.io_in_1_ready=vif.io_in_1_ready;
      item.io_in_4_ready=vif.io_in_4_ready;
      item.io_out_valid=vif.io_out_valid;
      item.io_out_bits_chanId=vif.io_out_bits_chanId;
      item.io_out_bits_opcode=vif.io_out_bits_opcode;
      item.io_out_bits_param=vif.io_out_bits_param;
      item.io_out_bits_size=vif.io_out_bits_size;
      item.io_out_bits_source=vif.io_out_bits_source;
      item.io_out_bits_address=vif.io_out_bits_address;
      item.io_out_bits_data=vif.io_out_bits_data;
      item.io_out_bits_corrupt=vif.io_out_bits_corrupt;
      item.io_out_bits_union=vif.io_out_bits_union;
      item.io_out_bits_last=vif.io_out_bits_last;
      item.expected_io_in_1_ready=vif.expected_io_in_1_ready;
      item.expected_io_in_4_ready=vif.expected_io_in_4_ready;
      item.expected_io_out_valid=vif.expected_io_out_valid;
      item.expected_io_out_bits_chanId=vif.expected_io_out_bits_chanId;
      item.expected_io_out_bits_opcode=vif.expected_io_out_bits_opcode;
      item.expected_io_out_bits_param=vif.expected_io_out_bits_param;
      item.expected_io_out_bits_size=vif.expected_io_out_bits_size;
      item.expected_io_out_bits_source=vif.expected_io_out_bits_source;
      item.expected_io_out_bits_address=vif.expected_io_out_bits_address;
      item.expected_io_out_bits_data=vif.expected_io_out_bits_data;
      item.expected_io_out_bits_corrupt=vif.expected_io_out_bits_corrupt;
      item.expected_io_out_bits_union=vif.expected_io_out_bits_union;
      item.expected_io_out_bits_last=vif.expected_io_out_bits_last;
      observed.write(item);
    endtask
    task run_phase(uvm_phase phase);
      repeat(2) @(posedge vif.clock);
      forever begin
        @(negedge vif.clock); #2; capture();
        @(posedge vif.clock); #2; capture();
      end
    endtask
  endclass
  class hpa_scoreboard extends uvm_subscriber #(hpa_item);
    `uvm_component_utils(hpa_scoreboard)
    int checks;
    int failures;
    covergroup native_coverage with function sample(bit v1, bit v4, bit ready, bit last1, bit last4, bit reset);
      option.per_instance=1;
      cp_v1: coverpoint v1;
      cp_v4: coverpoint v4;
      cp_ready: coverpoint ready;
      cp_last1: coverpoint last1;
      cp_last4: coverpoint last4;
      cp_reset: coverpoint reset;
      controls: cross cp_v1,cp_v4,cp_ready,cp_last1,cp_last4;
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent); native_coverage=new(); endfunction
    function void write(hpa_item item);
      checks++;
      native_coverage.sample(item.io_in_1_valid,item.io_in_4_valid,item.io_out_ready,item.io_in_1_bits_last,item.io_in_4_bits_last,item.reset);
      if(item.io_in_1_ready !== item.expected_io_in_1_ready) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_in_1_ready actual=%h expected=%h",item.io_in_1_ready,item.expected_io_in_1_ready))
      end
      if(item.io_in_4_ready !== item.expected_io_in_4_ready) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_in_4_ready actual=%h expected=%h",item.io_in_4_ready,item.expected_io_in_4_ready))
      end
      if(item.io_out_valid !== item.expected_io_out_valid) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_valid actual=%h expected=%h",item.io_out_valid,item.expected_io_out_valid))
      end
      if(item.io_out_bits_chanId !== item.expected_io_out_bits_chanId) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_chanId actual=%h expected=%h",item.io_out_bits_chanId,item.expected_io_out_bits_chanId))
      end
      if(item.io_out_bits_opcode !== item.expected_io_out_bits_opcode) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_opcode actual=%h expected=%h",item.io_out_bits_opcode,item.expected_io_out_bits_opcode))
      end
      if(item.io_out_bits_param !== item.expected_io_out_bits_param) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_param actual=%h expected=%h",item.io_out_bits_param,item.expected_io_out_bits_param))
      end
      if(item.io_out_bits_size !== item.expected_io_out_bits_size) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_size actual=%h expected=%h",item.io_out_bits_size,item.expected_io_out_bits_size))
      end
      if(item.io_out_bits_source !== item.expected_io_out_bits_source) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_source actual=%h expected=%h",item.io_out_bits_source,item.expected_io_out_bits_source))
      end
      if(item.io_out_bits_address !== item.expected_io_out_bits_address) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_address actual=%h expected=%h",item.io_out_bits_address,item.expected_io_out_bits_address))
      end
      if(item.io_out_bits_data !== item.expected_io_out_bits_data) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_data actual=%h expected=%h",item.io_out_bits_data,item.expected_io_out_bits_data))
      end
      if(item.io_out_bits_corrupt !== item.expected_io_out_bits_corrupt) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_corrupt actual=%h expected=%h",item.io_out_bits_corrupt,item.expected_io_out_bits_corrupt))
      end
      if(item.io_out_bits_union !== item.expected_io_out_bits_union) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_union actual=%h expected=%h",item.io_out_bits_union,item.expected_io_out_bits_union))
      end
      if(item.io_out_bits_last !== item.expected_io_out_bits_last) begin
        failures++;
        if(failures<=12) `uvm_error("COMPARE",$sformatf("io_out_bits_last actual=%h expected=%h",item.io_out_bits_last,item.expected_io_out_bits_last))
      end
    endfunction
    function void check_phase(uvm_phase phase);
      if(checks<100) `uvm_error("VACUITY","insufficient independent comparisons")
      if(failures>0) `uvm_error("TOTAL",$sformatf("%0d mismatches from %0d samples",failures,checks))
    endfunction
  endclass
  class hpa_agent extends uvm_agent;
    `uvm_component_utils(hpa_agent)
    uvm_sequencer #(hpa_item) sequencer;
    hpa_driver driver;
    hpa_monitor monitor;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer=new("sequencer",this);
      driver=hpa_driver::type_id::create("driver",this);
      monitor=hpa_monitor::type_id::create("monitor",this);
    endfunction
    function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
  endclass
  class hpa_env extends uvm_env;
    `uvm_component_utils(hpa_env)
    hpa_agent agent;
    hpa_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent=hpa_agent::type_id::create("agent",this);
      scoreboard=hpa_scoreboard::type_id::create("scoreboard",this);
    endfunction
    function void connect_phase(uvm_phase phase); agent.monitor.observed.connect(scoreboard.analysis_export); endfunction
  endclass
  class hpa_sequence extends uvm_sequence #(hpa_item);
    `uvm_object_utils(hpa_sequence)
    int beat_count;
    function new(string name="hpa_sequence"); super.new(name); endfunction
    task beat(int controls,int reset_value=0,int pulse=0);
      hpa_item item=hpa_item::type_id::create("drive");
      start_item(item);
      if(!item.randomize()) `uvm_fatal("RANDOM","randomization failed")
      if(beat_count%3==0) item.io_in_1_bits_opcode='0; else if(beat_count%3==1) item.io_in_1_bits_opcode='1;
      if(beat_count%3==0) item.io_in_1_bits_param='0; else if(beat_count%3==1) item.io_in_1_bits_param='1;
      if(beat_count%3==0) item.io_in_1_bits_size='0; else if(beat_count%3==1) item.io_in_1_bits_size='1;
      if(beat_count%3==0) item.io_in_1_bits_source='0; else if(beat_count%3==1) item.io_in_1_bits_source='1;
      if(beat_count%3==0) item.io_in_1_bits_data='0; else if(beat_count%3==1) item.io_in_1_bits_data='1;
      if(beat_count%3==0) item.io_in_1_bits_corrupt='0; else if(beat_count%3==1) item.io_in_1_bits_corrupt='1;
      if(beat_count%3==0) item.io_in_1_bits_union='0; else if(beat_count%3==1) item.io_in_1_bits_union='1;
      if(beat_count%3==0) item.io_in_4_bits_opcode='0; else if(beat_count%3==1) item.io_in_4_bits_opcode='1;
      if(beat_count%3==0) item.io_in_4_bits_param='0; else if(beat_count%3==1) item.io_in_4_bits_param='1;
      if(beat_count%3==0) item.io_in_4_bits_size='0; else if(beat_count%3==1) item.io_in_4_bits_size='1;
      if(beat_count%3==0) item.io_in_4_bits_source='0; else if(beat_count%3==1) item.io_in_4_bits_source='1;
      if(beat_count%3==0) item.io_in_4_bits_address='0; else if(beat_count%3==1) item.io_in_4_bits_address='1;
      if(beat_count%3==0) item.io_in_4_bits_data='0; else if(beat_count%3==1) item.io_in_4_bits_data='1;
      if(beat_count%3==0) item.io_in_4_bits_corrupt='0; else if(beat_count%3==1) item.io_in_4_bits_corrupt='1;
      if(beat_count%3==0) item.io_in_4_bits_union='0; else if(beat_count%3==1) item.io_in_4_bits_union='1;
      beat_count++;
      item.reset=reset_value;
      item.mode=pulse;
      item.io_in_1_valid=controls[0];
      item.io_in_4_valid=controls[1];
      item.io_out_ready=controls[2];
      item.io_in_1_bits_last=controls[3];
      item.io_in_4_bits_last=controls[4];
      finish_item(item);
    endtask
    task body();
      for(int owner=0;owner<3;owner++) begin
        for(int controls=0;controls<32;controls++) begin
          beat(0,1);
          if(owner==1) beat(5);
          if(owner==2) beat(6);
          beat(controls);
          beat(31);
        end
      end
      beat(0,1); beat(6); beat(7,0,1); beat(31);
      beat(0,1); beat(5); beat(7,0,1); beat(31);
      for(int index=0;index<1000;index++) beat($urandom_range(31,0),$urandom_range(39,0)==0);
      beat(0,1); beat(24);
    endtask
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    hpa_env env;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); super.build_phase(phase); env=hpa_env::type_id::create("env",this); endfunction
    task run_phase(uvm_phase phase);
      hpa_sequence sequence_handle=hpa_sequence::type_id::create("sequence_handle");
      phase.raise_objection(this);
      repeat(3) @(posedge env.agent.driver.vif.clock);
      sequence_handle.start(env.agent.sequencer);
      repeat(3) @(posedge env.agent.driver.vif.clock);
      phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      uvm_report_server report_server=uvm_report_server::get_server();
      if(report_server.get_severity_count(UVM_ERROR)==0 && report_server.get_severity_count(UVM_FATAL)==0)
        $display("DVBench_COMPLETED");
    endfunction
  endclass
endpackage
