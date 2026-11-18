
`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
interface phase12_bus;
  logic [511:0] inputs='0;
  wire [511:0] actual;
  wire [511:0] expected;
  logic [511:0] mask;
  bit clk=0;
  bit reset_seen=0;
  bit hold_a=0,hold_b=0;
  int profile,kind,reset_bit,a_valid,b_valid,p_ready,a_ready,b_ready;
  logic [511:0] a_hold_mask,b_hold_mask;
  event observed;
  task automatic step(logic [511:0] request);
    if(kind==1) begin
      if(hold_a) request=(request & ~a_hold_mask)|(inputs & a_hold_mask);
      if(hold_b) request=(request & ~b_hold_mask)|(inputs & b_hold_mask);
    end
    clk=0;
    inputs=request;
    #2;
    if(kind==0 || reset_seen) ->observed;
    if(kind!=0) begin
      if(kind==1) begin
        hold_a=inputs[a_valid] && !actual[a_ready];
        hold_b=inputs[b_valid] && !actual[b_ready];
      end
      clk=1;
      if(inputs[reset_bit]) begin reset_seen=1; hold_a=0; hold_b=0; end
      #2;
      if(reset_seen) ->observed;
      clk=0;
      #2;
      if(reset_seen) ->observed;
    end
    #2;
  endtask
endinterface
class dvbench_transaction extends uvm_sequence_item;
  `uvm_object_utils(dvbench_transaction)
  logic [511:0] payload,actual,expected,mask;
  int profile;
  function new(string name="dvbench_transaction");super.new(name);endfunction
endclass
class dvbench_sequence extends uvm_sequence #(dvbench_transaction);
  `uvm_object_utils(dvbench_sequence)
  virtual phase12_bus vif;
  function new(string name="dvbench_sequence");super.new(name);endfunction
  task directed(bit reset_value, bit strobe, bit write_value, bit[2:0] address, bit[31:0] data_value);
    dvbench_transaction item;
    item=dvbench_transaction::type_id::create("directed");
    start_item(item);item.payload='0;
    item.payload[0]=reset_value;item.payload[1+:32]=data_value;
    item.payload[37+:3]=address;item.payload[43]=strobe;item.payload[45]=write_value;
    finish_item(item);
  endtask
  task body;
    dvbench_transaction item;
    directed(1,0,0,0,0);directed(0,0,0,0,0);
    directed(0,1,1,2,3);directed(0,1,1,1,0);
    directed(0,1,1,0,7);
    repeat(16) directed(0,1,0,1,0);
    directed(0,1,0,0,0);directed(1,0,0,0,0);
    for(int sample=0;sample<6500;sample++) begin
      item=dvbench_transaction::type_id::create("item");
      start_item(item);
      for(int word_index=0;word_index<16;word_index++) item.payload[word_index*32+:32]=$urandom;
      if(vif.kind!=0) begin
        item.payload[vif.reset_bit]=(sample<3 || (sample>=6400 && sample<6403) || (sample<6400 && $urandom_range(0,196)==0));
      end
      if(vif.kind==1 && sample>=6400) begin
        item.payload[vif.a_valid]=0;item.payload[vif.b_valid]=0;item.payload[vif.p_ready]=1;
      end
      if(vif.kind==0) begin
        item.payload[6:0]=sample%128;
        if(sample%37==0) item.payload[7+:32]=32'hcafef00d;
        if(sample%41==0) item.payload[7+:32]=32'hcafef00c;
      end
      finish_item(item);
    end
  endtask
endclass
class dvbench_driver extends uvm_driver #(dvbench_transaction);
  `uvm_component_utils(dvbench_driver)
  virtual phase12_bus vif;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual phase12_bus)::get(this,"","vif",vif)) `uvm_fatal("CONFIG","vif missing")
  endfunction
  task run_phase(uvm_phase phase);
    dvbench_transaction item;
    forever begin seq_item_port.get_next_item(item);vif.step(item.payload);seq_item_port.item_done();end
  endtask
endclass
class dvbench_monitor extends uvm_monitor;
  `uvm_component_utils(dvbench_monitor)
  virtual phase12_bus vif;
  uvm_analysis_port#(dvbench_transaction) observations;
  function new(string name,uvm_component parent);super.new(name,parent);observations=new("observations",this);endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual phase12_bus)::get(this,"","vif",vif)) `uvm_fatal("CONFIG","vif missing")
  endfunction
  task run_phase(uvm_phase phase);
    dvbench_transaction item;
    forever begin
      @(vif.observed);
      item=dvbench_transaction::type_id::create("observation");
      item.payload=vif.inputs;item.actual=vif.actual;item.expected=vif.expected;item.mask=vif.mask;item.profile=vif.profile;
      observations.write(item);
    end
  endtask
endclass
class dvbench_scoreboard extends uvm_subscriber#(dvbench_transaction);
  `uvm_component_utils(dvbench_scoreboard)
  int samples=0,mismatches=0;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void write(dvbench_transaction item);
    samples++;
    if((item.actual & item.mask)!==(item.expected & item.mask)) begin
      mismatches++;
      if(mismatches<20) `uvm_error("PORT_MISMATCH",$sformatf("profile=%0d sample=%0d actual=%h expected=%h mask=%h",item.profile,samples,item.actual,item.expected,item.mask))
    end
  endfunction
  function void check_phase(uvm_phase phase);
    if(samples==0) `uvm_error("VACUOUS","no observations")
  endfunction
endclass
class dvbench_coverage extends uvm_subscriber#(dvbench_transaction);
  `uvm_component_utils(dvbench_coverage)
  int profile;
  bit [7:0] input_class;
  covergroup activity;
    option.per_instance=1;
    coverpoint profile;
    coverpoint input_class;
  endgroup
  function new(string name,uvm_component parent);super.new(name,parent);activity=new;endfunction
  function void write(dvbench_transaction item);profile=item.profile;input_class=item.payload[7:0];activity.sample();endfunction
endclass
class dvbench_agent extends uvm_agent;
  `uvm_component_utils(dvbench_agent)
  uvm_sequencer#(dvbench_transaction) sequencer;
  dvbench_driver driver;
  dvbench_monitor monitor;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    sequencer=uvm_sequencer#(dvbench_transaction)::type_id::create("sequencer",this);
    driver=dvbench_driver::type_id::create("driver",this);
    monitor=dvbench_monitor::type_id::create("monitor",this);
  endfunction
  function void connect_phase(uvm_phase phase);driver.seq_item_port.connect(sequencer.seq_item_export);endfunction
endclass
class dvbench_env extends uvm_env;
  `uvm_component_utils(dvbench_env)
  dvbench_agent agents[];
  dvbench_scoreboard scoreboard;
  dvbench_coverage coverage;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    agents=new[2];
    foreach(agents[index]) agents[index]=dvbench_agent::type_id::create($sformatf("agent%0d",index),this);
    scoreboard=dvbench_scoreboard::type_id::create("scoreboard",this);
    coverage=dvbench_coverage::type_id::create("coverage",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    foreach(agents[index]) begin agents[index].monitor.observations.connect(scoreboard.analysis_export);agents[index].monitor.observations.connect(coverage.analysis_export);end
  endfunction
endclass
class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  dvbench_env env;
  function new(string name="dvbench_test",uvm_component parent=null);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);env=dvbench_env::type_id::create("env",this);endfunction
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    foreach(env.agents[index]) begin
      automatic int profile_index=index;
      fork
        begin
          dvbench_sequence stimulus_sequence;
          stimulus_sequence=dvbench_sequence::type_id::create($sformatf("sequence%0d",profile_index));
          stimulus_sequence.vif=env.agents[profile_index].driver.vif;
          stimulus_sequence.start(env.agents[profile_index].sequencer);
        end
      join_none
    end
    wait fork;
    #20;
    phase.drop_objection(this);
  endtask
  function void report_phase(uvm_phase phase);
    uvm_report_server server;
    server=uvm_report_server::get_server();
    if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0 && env.scoreboard.samples>0) $display("DVBench_COMPLETED");
  endfunction
endclass

module dvbench_top;
  phase12_bus bus0();
  timer #(.PRESCALER_WIDTH(8),.Dw(32),.Aw(3),.SELw(4),.TAGw(3),.CNTw(32)) dut0(.clk(bus0.clk),.reset(bus0.inputs[0+:1]),.sa_dat_i(bus0.inputs[1+:32]),.sa_sel_i(bus0.inputs[33+:4]),.sa_addr_i(bus0.inputs[37+:3]),.sa_tag_i(bus0.inputs[40+:3]),.sa_stb_i(bus0.inputs[43+:1]),.sa_cyc_i(bus0.inputs[44+:1]),.sa_we_i(bus0.inputs[45+:1]),.sa_dat_o(bus0.actual[0+:32]),.sa_ack_o(bus0.actual[32+:1]),.sa_err_o(bus0.actual[33+:1]),.sa_rty_o(bus0.actual[34+:1]),.irq(bus0.actual[35+:1]));
  dvbench_model #(.PRESCALER_WIDTH(8),.Dw(32),.Aw(3),.SELw(4),.TAGw(3),.CNTw(32)) predictor0(.clk(bus0.clk),.reset(bus0.inputs[0+:1]),.sa_dat_i(bus0.inputs[1+:32]),.sa_sel_i(bus0.inputs[33+:4]),.sa_addr_i(bus0.inputs[37+:3]),.sa_tag_i(bus0.inputs[40+:3]),.sa_stb_i(bus0.inputs[43+:1]),.sa_cyc_i(bus0.inputs[44+:1]),.sa_we_i(bus0.inputs[45+:1]),.sa_dat_o(bus0.expected[0+:32]),.sa_ack_o(bus0.expected[32+:1]),.sa_err_o(bus0.expected[33+:1]),.sa_rty_o(bus0.expected[34+:1]),.irq(bus0.expected[35+:1]));
  always_comb begin
    bus0.mask=512'hfffffffff;
  end
  phase12_bus bus1();
  timer #(.PRESCALER_WIDTH(4),.Dw(32),.Aw(3),.SELw(4),.TAGw(3),.CNTw(8)) dut1(.clk(bus1.clk),.reset(bus1.inputs[0+:1]),.sa_dat_i(bus1.inputs[1+:32]),.sa_sel_i(bus1.inputs[33+:4]),.sa_addr_i(bus1.inputs[37+:3]),.sa_tag_i(bus1.inputs[40+:3]),.sa_stb_i(bus1.inputs[43+:1]),.sa_cyc_i(bus1.inputs[44+:1]),.sa_we_i(bus1.inputs[45+:1]),.sa_dat_o(bus1.actual[0+:32]),.sa_ack_o(bus1.actual[32+:1]),.sa_err_o(bus1.actual[33+:1]),.sa_rty_o(bus1.actual[34+:1]),.irq(bus1.actual[35+:1]));
  dvbench_model #(.PRESCALER_WIDTH(4),.Dw(32),.Aw(3),.SELw(4),.TAGw(3),.CNTw(8)) predictor1(.clk(bus1.clk),.reset(bus1.inputs[0+:1]),.sa_dat_i(bus1.inputs[1+:32]),.sa_sel_i(bus1.inputs[33+:4]),.sa_addr_i(bus1.inputs[37+:3]),.sa_tag_i(bus1.inputs[40+:3]),.sa_stb_i(bus1.inputs[43+:1]),.sa_cyc_i(bus1.inputs[44+:1]),.sa_we_i(bus1.inputs[45+:1]),.sa_dat_o(bus1.expected[0+:32]),.sa_ack_o(bus1.expected[32+:1]),.sa_err_o(bus1.expected[33+:1]),.sa_rty_o(bus1.expected[34+:1]),.irq(bus1.expected[35+:1]));
  always_comb begin
    bus1.mask=512'hfffffffff;
  end
  initial begin
    bus0.profile=0;
    bus0.kind=2;
    bus0.reset_bit=0;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent0*","vif",bus0);
    bus1.profile=1;
    bus1.kind=2;
    bus1.reset_bit=0;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent1*","vif",bus1);
    run_test("dvbench_test");
  end
endmodule
