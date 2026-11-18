
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
  task body;
    dvbench_transaction item;
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
    agents=new[10];
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
  multiply #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(1)) dut0(.clk(bus0.clk),.reset(bus0.inputs[0+:1]),.a_tdata(bus0.inputs[1+:16]),.a_tlast(bus0.inputs[17+:1]),.a_tvalid(bus0.inputs[18+:1]),.a_tready(bus0.actual[0+:1]),.b_tdata(bus0.inputs[19+:16]),.b_tlast(bus0.inputs[35+:1]),.b_tvalid(bus0.inputs[36+:1]),.b_tready(bus0.actual[1+:1]),.p_tdata(bus0.actual[2+:31]),.p_tlast(bus0.actual[33+:1]),.p_tvalid(bus0.actual[34+:1]),.p_tready(bus0.inputs[37+:1]));
  dvbench_model #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(1)) predictor0(.clk(bus0.clk),.reset(bus0.inputs[0+:1]),.a_tdata(bus0.inputs[1+:16]),.a_tlast(bus0.inputs[17+:1]),.a_tvalid(bus0.inputs[18+:1]),.a_tready(bus0.expected[0+:1]),.b_tdata(bus0.inputs[19+:16]),.b_tlast(bus0.inputs[35+:1]),.b_tvalid(bus0.inputs[36+:1]),.b_tready(bus0.expected[1+:1]),.p_tdata(bus0.expected[2+:31]),.p_tlast(bus0.expected[33+:1]),.p_tvalid(bus0.expected[34+:1]),.p_tready(bus0.inputs[37+:1]));
  always_comb begin
    bus0.mask=512'h7ffffffff;
    if(!bus0.actual[34]) bus0.mask=bus0.mask & ~512'h3fffffffc;
  end
  phase12_bus bus1();
  multiply #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(0),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(1)) dut1(.clk(bus1.clk),.reset(bus1.inputs[0+:1]),.a_tdata(bus1.inputs[1+:16]),.a_tlast(bus1.inputs[17+:1]),.a_tvalid(bus1.inputs[18+:1]),.a_tready(bus1.actual[0+:1]),.b_tdata(bus1.inputs[19+:16]),.b_tlast(bus1.inputs[35+:1]),.b_tvalid(bus1.inputs[36+:1]),.b_tready(bus1.actual[1+:1]),.p_tdata(bus1.actual[2+:31]),.p_tlast(bus1.actual[33+:1]),.p_tvalid(bus1.actual[34+:1]),.p_tready(bus1.inputs[37+:1]));
  dvbench_model #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(0),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(1)) predictor1(.clk(bus1.clk),.reset(bus1.inputs[0+:1]),.a_tdata(bus1.inputs[1+:16]),.a_tlast(bus1.inputs[17+:1]),.a_tvalid(bus1.inputs[18+:1]),.a_tready(bus1.expected[0+:1]),.b_tdata(bus1.inputs[19+:16]),.b_tlast(bus1.inputs[35+:1]),.b_tvalid(bus1.inputs[36+:1]),.b_tready(bus1.expected[1+:1]),.p_tdata(bus1.expected[2+:31]),.p_tlast(bus1.expected[33+:1]),.p_tvalid(bus1.expected[34+:1]),.p_tready(bus1.inputs[37+:1]));
  always_comb begin
    bus1.mask=512'h7ffffffff;
    if(!bus1.actual[34]) bus1.mask=bus1.mask & ~512'h3fffffffc;
  end
  phase12_bus bus2();
  multiply #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(4),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(1)) dut2(.clk(bus2.clk),.reset(bus2.inputs[0+:1]),.a_tdata(bus2.inputs[1+:16]),.a_tlast(bus2.inputs[17+:1]),.a_tvalid(bus2.inputs[18+:1]),.a_tready(bus2.actual[0+:1]),.b_tdata(bus2.inputs[19+:16]),.b_tlast(bus2.inputs[35+:1]),.b_tvalid(bus2.inputs[36+:1]),.b_tready(bus2.actual[1+:1]),.p_tdata(bus2.actual[2+:31]),.p_tlast(bus2.actual[33+:1]),.p_tvalid(bus2.actual[34+:1]),.p_tready(bus2.inputs[37+:1]));
  dvbench_model #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(4),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(1)) predictor2(.clk(bus2.clk),.reset(bus2.inputs[0+:1]),.a_tdata(bus2.inputs[1+:16]),.a_tlast(bus2.inputs[17+:1]),.a_tvalid(bus2.inputs[18+:1]),.a_tready(bus2.expected[0+:1]),.b_tdata(bus2.inputs[19+:16]),.b_tlast(bus2.inputs[35+:1]),.b_tvalid(bus2.inputs[36+:1]),.b_tready(bus2.expected[1+:1]),.p_tdata(bus2.expected[2+:31]),.p_tlast(bus2.expected[33+:1]),.p_tvalid(bus2.expected[34+:1]),.p_tready(bus2.inputs[37+:1]));
  always_comb begin
    bus2.mask=512'h7ffffffff;
    if(!bus2.actual[34]) bus2.mask=bus2.mask & ~512'h3fffffffc;
  end
  phase12_bus bus3();
  multiply #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(16),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(0),.EN_ROUND(1),.SIGNED(1)) dut3(.clk(bus3.clk),.reset(bus3.inputs[0+:1]),.a_tdata(bus3.inputs[1+:16]),.a_tlast(bus3.inputs[17+:1]),.a_tvalid(bus3.inputs[18+:1]),.a_tready(bus3.actual[0+:1]),.b_tdata(bus3.inputs[19+:16]),.b_tlast(bus3.inputs[35+:1]),.b_tvalid(bus3.inputs[36+:1]),.b_tready(bus3.actual[1+:1]),.p_tdata(bus3.actual[2+:16]),.p_tlast(bus3.actual[18+:1]),.p_tvalid(bus3.actual[19+:1]),.p_tready(bus3.inputs[37+:1]));
  dvbench_model #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(16),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(0),.EN_ROUND(1),.SIGNED(1)) predictor3(.clk(bus3.clk),.reset(bus3.inputs[0+:1]),.a_tdata(bus3.inputs[1+:16]),.a_tlast(bus3.inputs[17+:1]),.a_tvalid(bus3.inputs[18+:1]),.a_tready(bus3.expected[0+:1]),.b_tdata(bus3.inputs[19+:16]),.b_tlast(bus3.inputs[35+:1]),.b_tvalid(bus3.inputs[36+:1]),.b_tready(bus3.expected[1+:1]),.p_tdata(bus3.expected[2+:16]),.p_tlast(bus3.expected[18+:1]),.p_tvalid(bus3.expected[19+:1]),.p_tready(bus3.inputs[37+:1]));
  always_comb begin
    bus3.mask=512'hfffff;
    if(!bus3.actual[19]) bus3.mask=bus3.mask & ~512'h7fffc;
  end
  phase12_bus bus4();
  multiply #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(16),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(1),.EN_ROUND(0),.SIGNED(1)) dut4(.clk(bus4.clk),.reset(bus4.inputs[0+:1]),.a_tdata(bus4.inputs[1+:16]),.a_tlast(bus4.inputs[17+:1]),.a_tvalid(bus4.inputs[18+:1]),.a_tready(bus4.actual[0+:1]),.b_tdata(bus4.inputs[19+:16]),.b_tlast(bus4.inputs[35+:1]),.b_tvalid(bus4.inputs[36+:1]),.b_tready(bus4.actual[1+:1]),.p_tdata(bus4.actual[2+:16]),.p_tlast(bus4.actual[18+:1]),.p_tvalid(bus4.actual[19+:1]),.p_tready(bus4.inputs[37+:1]));
  dvbench_model #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(16),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(1),.EN_ROUND(0),.SIGNED(1)) predictor4(.clk(bus4.clk),.reset(bus4.inputs[0+:1]),.a_tdata(bus4.inputs[1+:16]),.a_tlast(bus4.inputs[17+:1]),.a_tvalid(bus4.inputs[18+:1]),.a_tready(bus4.expected[0+:1]),.b_tdata(bus4.inputs[19+:16]),.b_tlast(bus4.inputs[35+:1]),.b_tvalid(bus4.inputs[36+:1]),.b_tready(bus4.expected[1+:1]),.p_tdata(bus4.expected[2+:16]),.p_tlast(bus4.expected[18+:1]),.p_tvalid(bus4.expected[19+:1]),.p_tready(bus4.inputs[37+:1]));
  always_comb begin
    bus4.mask=512'hfffff;
    if(!bus4.actual[19]) bus4.mask=bus4.mask & ~512'h7fffc;
  end
  phase12_bus bus5();
  multiply #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(16),.DROP_TOP_P(1),.LATENCY(1),.EN_SATURATE(1),.EN_ROUND(1),.SIGNED(1)) dut5(.clk(bus5.clk),.reset(bus5.inputs[0+:1]),.a_tdata(bus5.inputs[1+:16]),.a_tlast(bus5.inputs[17+:1]),.a_tvalid(bus5.inputs[18+:1]),.a_tready(bus5.actual[0+:1]),.b_tdata(bus5.inputs[19+:16]),.b_tlast(bus5.inputs[35+:1]),.b_tvalid(bus5.inputs[36+:1]),.b_tready(bus5.actual[1+:1]),.p_tdata(bus5.actual[2+:16]),.p_tlast(bus5.actual[18+:1]),.p_tvalid(bus5.actual[19+:1]),.p_tready(bus5.inputs[37+:1]));
  dvbench_model #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(16),.DROP_TOP_P(1),.LATENCY(1),.EN_SATURATE(1),.EN_ROUND(1),.SIGNED(1)) predictor5(.clk(bus5.clk),.reset(bus5.inputs[0+:1]),.a_tdata(bus5.inputs[1+:16]),.a_tlast(bus5.inputs[17+:1]),.a_tvalid(bus5.inputs[18+:1]),.a_tready(bus5.expected[0+:1]),.b_tdata(bus5.inputs[19+:16]),.b_tlast(bus5.inputs[35+:1]),.b_tvalid(bus5.inputs[36+:1]),.b_tready(bus5.expected[1+:1]),.p_tdata(bus5.expected[2+:16]),.p_tlast(bus5.expected[18+:1]),.p_tvalid(bus5.expected[19+:1]),.p_tready(bus5.inputs[37+:1]));
  always_comb begin
    bus5.mask=512'hfffff;
    if(!bus5.actual[19]) bus5.mask=bus5.mask & ~512'h7fffc;
  end
  phase12_bus bus6();
  multiply #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(32),.DROP_TOP_P(0),.LATENCY(2),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(0)) dut6(.clk(bus6.clk),.reset(bus6.inputs[0+:1]),.a_tdata(bus6.inputs[1+:16]),.a_tlast(bus6.inputs[17+:1]),.a_tvalid(bus6.inputs[18+:1]),.a_tready(bus6.actual[0+:1]),.b_tdata(bus6.inputs[19+:16]),.b_tlast(bus6.inputs[35+:1]),.b_tvalid(bus6.inputs[36+:1]),.b_tready(bus6.actual[1+:1]),.p_tdata(bus6.actual[2+:32]),.p_tlast(bus6.actual[34+:1]),.p_tvalid(bus6.actual[35+:1]),.p_tready(bus6.inputs[37+:1]));
  dvbench_model #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(32),.DROP_TOP_P(0),.LATENCY(2),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(0)) predictor6(.clk(bus6.clk),.reset(bus6.inputs[0+:1]),.a_tdata(bus6.inputs[1+:16]),.a_tlast(bus6.inputs[17+:1]),.a_tvalid(bus6.inputs[18+:1]),.a_tready(bus6.expected[0+:1]),.b_tdata(bus6.inputs[19+:16]),.b_tlast(bus6.inputs[35+:1]),.b_tvalid(bus6.inputs[36+:1]),.b_tready(bus6.expected[1+:1]),.p_tdata(bus6.expected[2+:32]),.p_tlast(bus6.expected[34+:1]),.p_tvalid(bus6.expected[35+:1]),.p_tready(bus6.inputs[37+:1]));
  always_comb begin
    bus6.mask=512'hfffffffff;
    if(!bus6.actual[35]) bus6.mask=bus6.mask & ~512'h7fffffffc;
  end
  phase12_bus bus7();
  multiply #(.WIDTH_A(8),.WIDTH_B(12),.WIDTH_P(20),.DROP_TOP_P(0),.LATENCY(1),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(1)) dut7(.clk(bus7.clk),.reset(bus7.inputs[0+:1]),.a_tdata(bus7.inputs[1+:8]),.a_tlast(bus7.inputs[9+:1]),.a_tvalid(bus7.inputs[10+:1]),.a_tready(bus7.actual[0+:1]),.b_tdata(bus7.inputs[11+:12]),.b_tlast(bus7.inputs[23+:1]),.b_tvalid(bus7.inputs[24+:1]),.b_tready(bus7.actual[1+:1]),.p_tdata(bus7.actual[2+:20]),.p_tlast(bus7.actual[22+:1]),.p_tvalid(bus7.actual[23+:1]),.p_tready(bus7.inputs[25+:1]));
  dvbench_model #(.WIDTH_A(8),.WIDTH_B(12),.WIDTH_P(20),.DROP_TOP_P(0),.LATENCY(1),.EN_SATURATE(0),.EN_ROUND(0),.SIGNED(1)) predictor7(.clk(bus7.clk),.reset(bus7.inputs[0+:1]),.a_tdata(bus7.inputs[1+:8]),.a_tlast(bus7.inputs[9+:1]),.a_tvalid(bus7.inputs[10+:1]),.a_tready(bus7.expected[0+:1]),.b_tdata(bus7.inputs[11+:12]),.b_tlast(bus7.inputs[23+:1]),.b_tvalid(bus7.inputs[24+:1]),.b_tready(bus7.expected[1+:1]),.p_tdata(bus7.expected[2+:20]),.p_tlast(bus7.expected[22+:1]),.p_tvalid(bus7.expected[23+:1]),.p_tready(bus7.inputs[25+:1]));
  always_comb begin
    bus7.mask=512'hffffff;
    if(!bus7.actual[23]) bus7.mask=bus7.mask & ~512'h7ffffc;
  end
  phase12_bus bus8();
  multiply #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(0),.EN_ROUND(1),.SIGNED(1)) dut8(.clk(bus8.clk),.reset(bus8.inputs[0+:1]),.a_tdata(bus8.inputs[1+:16]),.a_tlast(bus8.inputs[17+:1]),.a_tvalid(bus8.inputs[18+:1]),.a_tready(bus8.actual[0+:1]),.b_tdata(bus8.inputs[19+:16]),.b_tlast(bus8.inputs[35+:1]),.b_tvalid(bus8.inputs[36+:1]),.b_tready(bus8.actual[1+:1]),.p_tdata(bus8.actual[2+:31]),.p_tlast(bus8.actual[33+:1]),.p_tvalid(bus8.actual[34+:1]),.p_tready(bus8.inputs[37+:1]));
  dvbench_model #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(0),.EN_ROUND(1),.SIGNED(1)) predictor8(.clk(bus8.clk),.reset(bus8.inputs[0+:1]),.a_tdata(bus8.inputs[1+:16]),.a_tlast(bus8.inputs[17+:1]),.a_tvalid(bus8.inputs[18+:1]),.a_tready(bus8.expected[0+:1]),.b_tdata(bus8.inputs[19+:16]),.b_tlast(bus8.inputs[35+:1]),.b_tvalid(bus8.inputs[36+:1]),.b_tready(bus8.expected[1+:1]),.p_tdata(bus8.expected[2+:31]),.p_tlast(bus8.expected[33+:1]),.p_tvalid(bus8.expected[34+:1]),.p_tready(bus8.inputs[37+:1]));
  always_comb begin
    bus8.mask=512'h7ffffffff;
    if(!bus8.actual[34]) bus8.mask=bus8.mask & ~512'h3fffffffc;
  end
  phase12_bus bus9();
  multiply #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(1),.EN_ROUND(1),.SIGNED(1)) dut9(.clk(bus9.clk),.reset(bus9.inputs[0+:1]),.a_tdata(bus9.inputs[1+:16]),.a_tlast(bus9.inputs[17+:1]),.a_tvalid(bus9.inputs[18+:1]),.a_tready(bus9.actual[0+:1]),.b_tdata(bus9.inputs[19+:16]),.b_tlast(bus9.inputs[35+:1]),.b_tvalid(bus9.inputs[36+:1]),.b_tready(bus9.actual[1+:1]),.p_tdata(bus9.actual[2+:31]),.p_tlast(bus9.actual[33+:1]),.p_tvalid(bus9.actual[34+:1]),.p_tready(bus9.inputs[37+:1]));
  dvbench_model #(.WIDTH_A(16),.WIDTH_B(16),.WIDTH_P(31),.DROP_TOP_P(1),.LATENCY(3),.EN_SATURATE(1),.EN_ROUND(1),.SIGNED(1)) predictor9(.clk(bus9.clk),.reset(bus9.inputs[0+:1]),.a_tdata(bus9.inputs[1+:16]),.a_tlast(bus9.inputs[17+:1]),.a_tvalid(bus9.inputs[18+:1]),.a_tready(bus9.expected[0+:1]),.b_tdata(bus9.inputs[19+:16]),.b_tlast(bus9.inputs[35+:1]),.b_tvalid(bus9.inputs[36+:1]),.b_tready(bus9.expected[1+:1]),.p_tdata(bus9.expected[2+:31]),.p_tlast(bus9.expected[33+:1]),.p_tvalid(bus9.expected[34+:1]),.p_tready(bus9.inputs[37+:1]));
  always_comb begin
    bus9.mask=512'h7ffffffff;
    if(!bus9.actual[34]) bus9.mask=bus9.mask & ~512'h3fffffffc;
  end
  initial begin
    bus0.profile=0;
    bus0.kind=1;
    bus0.reset_bit=0;
    bus0.a_valid=18;
    bus0.b_valid=36;
    bus0.p_ready=37;
    bus0.a_ready=0;
    bus0.b_ready=1;
    bus0.a_hold_mask=512'h7fffe;
    bus0.b_hold_mask=512'h1ffff80000;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent0*","vif",bus0);
    bus1.profile=1;
    bus1.kind=1;
    bus1.reset_bit=0;
    bus1.a_valid=18;
    bus1.b_valid=36;
    bus1.p_ready=37;
    bus1.a_ready=0;
    bus1.b_ready=1;
    bus1.a_hold_mask=512'h7fffe;
    bus1.b_hold_mask=512'h1ffff80000;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent1*","vif",bus1);
    bus2.profile=2;
    bus2.kind=1;
    bus2.reset_bit=0;
    bus2.a_valid=18;
    bus2.b_valid=36;
    bus2.p_ready=37;
    bus2.a_ready=0;
    bus2.b_ready=1;
    bus2.a_hold_mask=512'h7fffe;
    bus2.b_hold_mask=512'h1ffff80000;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent2*","vif",bus2);
    bus3.profile=3;
    bus3.kind=1;
    bus3.reset_bit=0;
    bus3.a_valid=18;
    bus3.b_valid=36;
    bus3.p_ready=37;
    bus3.a_ready=0;
    bus3.b_ready=1;
    bus3.a_hold_mask=512'h7fffe;
    bus3.b_hold_mask=512'h1ffff80000;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent3*","vif",bus3);
    bus4.profile=4;
    bus4.kind=1;
    bus4.reset_bit=0;
    bus4.a_valid=18;
    bus4.b_valid=36;
    bus4.p_ready=37;
    bus4.a_ready=0;
    bus4.b_ready=1;
    bus4.a_hold_mask=512'h7fffe;
    bus4.b_hold_mask=512'h1ffff80000;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent4*","vif",bus4);
    bus5.profile=5;
    bus5.kind=1;
    bus5.reset_bit=0;
    bus5.a_valid=18;
    bus5.b_valid=36;
    bus5.p_ready=37;
    bus5.a_ready=0;
    bus5.b_ready=1;
    bus5.a_hold_mask=512'h7fffe;
    bus5.b_hold_mask=512'h1ffff80000;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent5*","vif",bus5);
    bus6.profile=6;
    bus6.kind=1;
    bus6.reset_bit=0;
    bus6.a_valid=18;
    bus6.b_valid=36;
    bus6.p_ready=37;
    bus6.a_ready=0;
    bus6.b_ready=1;
    bus6.a_hold_mask=512'h7fffe;
    bus6.b_hold_mask=512'h1ffff80000;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent6*","vif",bus6);
    bus7.profile=7;
    bus7.kind=1;
    bus7.reset_bit=0;
    bus7.a_valid=10;
    bus7.b_valid=24;
    bus7.p_ready=25;
    bus7.a_ready=0;
    bus7.b_ready=1;
    bus7.a_hold_mask=512'h7fe;
    bus7.b_hold_mask=512'h1fff800;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent7*","vif",bus7);
    bus8.profile=8;
    bus8.kind=1;
    bus8.reset_bit=0;
    bus8.a_valid=18;
    bus8.b_valid=36;
    bus8.p_ready=37;
    bus8.a_ready=0;
    bus8.b_ready=1;
    bus8.a_hold_mask=512'h7fffe;
    bus8.b_hold_mask=512'h1ffff80000;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent8*","vif",bus8);
    bus9.profile=9;
    bus9.kind=1;
    bus9.reset_bit=0;
    bus9.a_valid=18;
    bus9.b_valid=36;
    bus9.p_ready=37;
    bus9.a_ready=0;
    bus9.b_ready=1;
    bus9.a_hold_mask=512'h7fffe;
    bus9.b_hold_mask=512'h1ffff80000;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent9*","vif",bus9);
    run_test("dvbench_test");
  end
endmodule
