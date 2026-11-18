
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
    for(int directed=0;directed<18432;directed++) begin
      int pattern;
      logic [31:0] edge_value;
      item=dvbench_transaction::type_id::create("directed_item");
      start_item(item);
      for(int word_index=0;word_index<16;word_index++) item.payload[word_index*32+:32]=$urandom;
      pattern=directed/512;
      case(pattern)
        0: edge_value=0;
        1: edge_value=32'hffffffff;
        2: edge_value=32'hcafef00d;
        3: edge_value=32'hcafef00c;
        default: edge_value=32'h1<<(pattern-4);
      endcase
      item.payload[6:0]=directed%128;
      item.payload[7+:32]=edge_value;
      item.payload[39+:32]=edge_value;
      item.payload[71]=(directed/128)%2;
      item.payload[72+:33]={edge_value[0],edge_value};
      item.payload[105+:33]={edge_value[0],edge_value};
      item.payload[138]=(directed/256)%2;
      finish_item(item);
    end
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
    agents=new[4];
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
    $display("DVBench_OBSERVATIONS samples=%0d mismatches=%0d",env.scoreboard.samples,env.scoreboard.mismatches);
    if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0 && env.scoreboard.samples>0) $display("DVBench_COMPLETED");
  endfunction
endclass

module dvbench_top;
  phase12_bus bus0();
  ibex_alu_mut #(.RV32B(0)) dut0(.operator_i(bus0.inputs[0+:7]),.operand_a_i(bus0.inputs[7+:32]),.operand_b_i(bus0.inputs[39+:32]),.instr_first_cycle_i(bus0.inputs[71+:1]),.multdiv_operand_a_i(bus0.inputs[72+:33]),.multdiv_operand_b_i(bus0.inputs[105+:33]),.multdiv_sel_i(bus0.inputs[138+:1]),.imd_val_q_i(bus0.inputs[139+:64]),.imd_val_d_o(bus0.actual[0+:64]),.imd_val_we_o(bus0.actual[64+:2]),.adder_result_o(bus0.actual[66+:32]),.adder_result_ext_o(bus0.actual[98+:34]),.result_o(bus0.actual[132+:32]),.comparison_result_o(bus0.actual[164+:1]),.is_equal_result_o(bus0.actual[165+:1]));
  dvbench_model #(.RV32B(0)) predictor0(.operator_i(bus0.inputs[0+:7]),.operand_a_i(bus0.inputs[7+:32]),.operand_b_i(bus0.inputs[39+:32]),.instr_first_cycle_i(bus0.inputs[71+:1]),.multdiv_operand_a_i(bus0.inputs[72+:33]),.multdiv_operand_b_i(bus0.inputs[105+:33]),.multdiv_sel_i(bus0.inputs[138+:1]),.imd_val_q_i(bus0.inputs[139+:64]),.imd_val_d_o(bus0.expected[0+:64]),.imd_val_we_o(bus0.expected[64+:2]),.adder_result_o(bus0.expected[66+:32]),.adder_result_ext_o(bus0.expected[98+:34]),.result_o(bus0.expected[132+:32]),.comparison_result_o(bus0.expected[164+:1]),.is_equal_result_o(bus0.expected[165+:1]));
  always_comb begin
    bus0.mask=512'h3fffffffffffffffffffffffffffffffffffffffff;
  end
  phase12_bus bus1();
  ibex_alu_mut #(.RV32B(1)) dut1(.operator_i(bus1.inputs[0+:7]),.operand_a_i(bus1.inputs[7+:32]),.operand_b_i(bus1.inputs[39+:32]),.instr_first_cycle_i(bus1.inputs[71+:1]),.multdiv_operand_a_i(bus1.inputs[72+:33]),.multdiv_operand_b_i(bus1.inputs[105+:33]),.multdiv_sel_i(bus1.inputs[138+:1]),.imd_val_q_i(bus1.inputs[139+:64]),.imd_val_d_o(bus1.actual[0+:64]),.imd_val_we_o(bus1.actual[64+:2]),.adder_result_o(bus1.actual[66+:32]),.adder_result_ext_o(bus1.actual[98+:34]),.result_o(bus1.actual[132+:32]),.comparison_result_o(bus1.actual[164+:1]),.is_equal_result_o(bus1.actual[165+:1]));
  dvbench_model #(.RV32B(1)) predictor1(.operator_i(bus1.inputs[0+:7]),.operand_a_i(bus1.inputs[7+:32]),.operand_b_i(bus1.inputs[39+:32]),.instr_first_cycle_i(bus1.inputs[71+:1]),.multdiv_operand_a_i(bus1.inputs[72+:33]),.multdiv_operand_b_i(bus1.inputs[105+:33]),.multdiv_sel_i(bus1.inputs[138+:1]),.imd_val_q_i(bus1.inputs[139+:64]),.imd_val_d_o(bus1.expected[0+:64]),.imd_val_we_o(bus1.expected[64+:2]),.adder_result_o(bus1.expected[66+:32]),.adder_result_ext_o(bus1.expected[98+:34]),.result_o(bus1.expected[132+:32]),.comparison_result_o(bus1.expected[164+:1]),.is_equal_result_o(bus1.expected[165+:1]));
  always_comb begin
    bus1.mask=512'h3fffffffffffffffffffffffffffffffffffffffff;
  end
  phase12_bus bus2();
  ibex_alu_mut #(.RV32B(2)) dut2(.operator_i(bus2.inputs[0+:7]),.operand_a_i(bus2.inputs[7+:32]),.operand_b_i(bus2.inputs[39+:32]),.instr_first_cycle_i(bus2.inputs[71+:1]),.multdiv_operand_a_i(bus2.inputs[72+:33]),.multdiv_operand_b_i(bus2.inputs[105+:33]),.multdiv_sel_i(bus2.inputs[138+:1]),.imd_val_q_i(bus2.inputs[139+:64]),.imd_val_d_o(bus2.actual[0+:64]),.imd_val_we_o(bus2.actual[64+:2]),.adder_result_o(bus2.actual[66+:32]),.adder_result_ext_o(bus2.actual[98+:34]),.result_o(bus2.actual[132+:32]),.comparison_result_o(bus2.actual[164+:1]),.is_equal_result_o(bus2.actual[165+:1]));
  dvbench_model #(.RV32B(2)) predictor2(.operator_i(bus2.inputs[0+:7]),.operand_a_i(bus2.inputs[7+:32]),.operand_b_i(bus2.inputs[39+:32]),.instr_first_cycle_i(bus2.inputs[71+:1]),.multdiv_operand_a_i(bus2.inputs[72+:33]),.multdiv_operand_b_i(bus2.inputs[105+:33]),.multdiv_sel_i(bus2.inputs[138+:1]),.imd_val_q_i(bus2.inputs[139+:64]),.imd_val_d_o(bus2.expected[0+:64]),.imd_val_we_o(bus2.expected[64+:2]),.adder_result_o(bus2.expected[66+:32]),.adder_result_ext_o(bus2.expected[98+:34]),.result_o(bus2.expected[132+:32]),.comparison_result_o(bus2.expected[164+:1]),.is_equal_result_o(bus2.expected[165+:1]));
  always_comb begin
    bus2.mask=512'h3fffffffffffffffffffffffffffffffffffffffff;
  end
  phase12_bus bus3();
  ibex_alu_mut #(.RV32B(3)) dut3(.operator_i(bus3.inputs[0+:7]),.operand_a_i(bus3.inputs[7+:32]),.operand_b_i(bus3.inputs[39+:32]),.instr_first_cycle_i(bus3.inputs[71+:1]),.multdiv_operand_a_i(bus3.inputs[72+:33]),.multdiv_operand_b_i(bus3.inputs[105+:33]),.multdiv_sel_i(bus3.inputs[138+:1]),.imd_val_q_i(bus3.inputs[139+:64]),.imd_val_d_o(bus3.actual[0+:64]),.imd_val_we_o(bus3.actual[64+:2]),.adder_result_o(bus3.actual[66+:32]),.adder_result_ext_o(bus3.actual[98+:34]),.result_o(bus3.actual[132+:32]),.comparison_result_o(bus3.actual[164+:1]),.is_equal_result_o(bus3.actual[165+:1]));
  dvbench_model #(.RV32B(3)) predictor3(.operator_i(bus3.inputs[0+:7]),.operand_a_i(bus3.inputs[7+:32]),.operand_b_i(bus3.inputs[39+:32]),.instr_first_cycle_i(bus3.inputs[71+:1]),.multdiv_operand_a_i(bus3.inputs[72+:33]),.multdiv_operand_b_i(bus3.inputs[105+:33]),.multdiv_sel_i(bus3.inputs[138+:1]),.imd_val_q_i(bus3.inputs[139+:64]),.imd_val_d_o(bus3.expected[0+:64]),.imd_val_we_o(bus3.expected[64+:2]),.adder_result_o(bus3.expected[66+:32]),.adder_result_ext_o(bus3.expected[98+:34]),.result_o(bus3.expected[132+:32]),.comparison_result_o(bus3.expected[164+:1]),.is_equal_result_o(bus3.expected[165+:1]));
  always_comb begin
    bus3.mask=512'h3fffffffffffffffffffffffffffffffffffffffff;
  end
  initial begin
    bus0.profile=0;
    bus0.kind=0;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent0*","vif",bus0);
    bus1.profile=1;
    bus1.kind=0;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent1*","vif",bus1);
    bus2.profile=2;
    bus2.kind=0;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent2*","vif",bus2);
    bus3.profile=3;
    bus3.kind=0;
    uvm_config_db#(virtual phase12_bus)::set(null,"uvm_test_top.env.agent3*","vif",bus3);
    run_test("dvbench_test");
  end
endmodule
