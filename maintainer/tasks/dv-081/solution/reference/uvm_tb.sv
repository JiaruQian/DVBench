`timescale 1ns/1ps
interface dvbench_if(input logic clk);
  logic [33-1:0] stimulus='0;
  wire [297-1:0] actual,expected,mask;
endinterface

package dvbench_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class drive_item extends uvm_sequence_item;
    `uvm_object_utils(drive_item)
    bit [33-1:0] inputs;
    int unsigned cycles;
    function new(string name="drive_item"); super.new(name); endfunction
  endclass
  class observed_item extends uvm_sequence_item;
    `uvm_object_utils(observed_item)
    logic [297-1:0] actual,expected,mask;
    longint unsigned cycle;
    function new(string name="observed_item"); super.new(name); endfunction
  endclass
  class stimulus_sequence extends uvm_sequence #(drive_item);
    `uvm_object_utils(stimulus_sequence)
    function new(string name="stimulus_sequence"); super.new(name); endfunction
    task drive(bit [33-1:0] inputs,int unsigned cycles=1);
      drive_item item=drive_item::type_id::create("item");
      start_item(item); item.inputs=inputs; item.cycles=cycles; finish_item(item);
    endtask
    task body();
      drive({1'b0,32'b0},4);
      for(int wall_cycle=0;wall_cycle<8000;wall_cycle++) begin
        if(wall_cycle%950<64)
          drive({(wall_cycle%950>3),(wall_cycle<950 ? 32'h13579bdf : 32'h0)});
        else
          drive({(wall_cycle%950>3),$urandom});
      end
      drive({1'b1,32'h80000000},1000);
    endtask
  endclass
  class native_driver extends uvm_driver #(drive_item);
    `uvm_component_utils(native_driver)
    virtual dvbench_if vif;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual dvbench_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","Missing native interface")
    endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge vif.clk); vif.stimulus=req.inputs;
        repeat(req.cycles) @(posedge vif.clk);
        seq_item_port.item_done();
      end
    endtask
  endclass
  class native_monitor extends uvm_monitor;
    `uvm_component_utils(native_monitor)
    virtual dvbench_if vif;
    uvm_analysis_port#(observed_item) observations;
    longint unsigned cycle=0;
    function new(string name,uvm_component parent); super.new(name,parent); observations=new("observations",this); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual dvbench_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","Missing native interface")
    endfunction
    task run_phase(uvm_phase phase);
      observed_item sample;
      forever begin
        @(posedge vif.clk); #1; cycle++;
        if(cycle>2) begin
          sample=observed_item::type_id::create("sample");
          sample.actual=vif.actual; sample.expected=vif.expected; sample.mask=vif.mask; sample.cycle=cycle;
          observations.write(sample);
        end
      end
    endtask
  endclass
  class independent_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(independent_scoreboard)
    uvm_analysis_imp#(observed_item,independent_scoreboard) observations;
    longint unsigned comparisons=0,mismatches=0,active_samples=0;
    function new(string name,uvm_component parent); super.new(name,parent); observations=new("observations",this); endfunction
    function void write(observed_item sample);
      comparisons++;
      if(sample.actual!=0 && sample.mask!=0) active_samples++;
      if((sample.actual&sample.mask)!==(sample.expected&sample.mask)) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("PREDICTION",$sformatf("cycle=%0d actual=%h expected=%h mask=%h",sample.cycle,sample.actual,sample.expected,sample.mask))
      end
    endfunction
    function void check_phase(uvm_phase phase);
      super.check_phase(phase);
      if(comparisons<8000 || active_samples<100) `uvm_error("NONVACUITY","Insufficient sampled activity")
    endfunction
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      $display("REFERENCE_RESULT comparisons=%0d mismatches=%0d active_samples=%0d",comparisons,mismatches,active_samples);
    endfunction
  endclass
  class native_agent extends uvm_agent;
    `uvm_component_utils(native_agent)
    uvm_sequencer#(drive_item) sequencer;
    native_driver driver;
    native_monitor monitor;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer=uvm_sequencer#(drive_item)::type_id::create("sequencer",this);
      driver=native_driver::type_id::create("driver",this);
      monitor=native_monitor::type_id::create("monitor",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase); driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
  endclass
  class verification_environment extends uvm_env;
    `uvm_component_utils(verification_environment)
    native_agent agent;
    independent_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent=native_agent::type_id::create("agent",this);
      scoreboard=independent_scoreboard::type_id::create("scoreboard",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase); agent.monitor.observations.connect(scoreboard.observations);
    endfunction
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    verification_environment environment;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); environment=verification_environment::type_id::create("environment",this);
    endfunction
    task run_phase(uvm_phase phase);
      stimulus_sequence sequence_instance=stimulus_sequence::type_id::create("sequence_instance");
      phase.raise_objection(this); sequence_instance.start(environment.agent.sequencer);
      #20; phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      uvm_report_server server;
      super.report_phase(phase); server=uvm_report_server::get_server();
      if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) begin
        $display("DVBench_COMPLETED"); $display("NATIVE_TEST_PASS");
      end
    endfunction
  endclass
endpackage

module dvbench_top;
  import uvm_pkg::*;
  import dvbench_pkg::*;
  reg clk=0;
  always #5 clk=~clk;
  dvbench_if bus(clk);
  wire rst;
  wire [31:0] input_data;
  assign {rst,input_data}=bus.stimulus;
  wire valid_0,expected_valid_0;
  wire [31:0] data_0,expected_data_0;
  Top #(.PROGRAM_FILE("isa_0.mem")) actual_0(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(valid_0),.result_data(data_0));
  dvbench_model #(.PROGRAM_FILE("isa_0.mem")) predictor_0(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(expected_valid_0),.result_data(expected_data_0));
  assign bus.actual[0+:33]={valid_0,data_0};
  assign bus.expected[0+:33]={expected_valid_0,expected_data_0};
  wire valid_1,expected_valid_1;
  wire [31:0] data_1,expected_data_1;
  Top #(.PROGRAM_FILE("isa_1.mem")) actual_1(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(valid_1),.result_data(data_1));
  dvbench_model #(.PROGRAM_FILE("isa_1.mem")) predictor_1(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(expected_valid_1),.result_data(expected_data_1));
  assign bus.actual[33+:33]={valid_1,data_1};
  assign bus.expected[33+:33]={expected_valid_1,expected_data_1};
  wire valid_2,expected_valid_2;
  wire [31:0] data_2,expected_data_2;
  Top #(.PROGRAM_FILE("isa_2.mem")) actual_2(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(valid_2),.result_data(data_2));
  dvbench_model #(.PROGRAM_FILE("isa_2.mem")) predictor_2(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(expected_valid_2),.result_data(expected_data_2));
  assign bus.actual[66+:33]={valid_2,data_2};
  assign bus.expected[66+:33]={expected_valid_2,expected_data_2};
  wire valid_3,expected_valid_3;
  wire [31:0] data_3,expected_data_3;
  Top #(.PROGRAM_FILE("isa_3.mem")) actual_3(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(valid_3),.result_data(data_3));
  dvbench_model #(.PROGRAM_FILE("isa_3.mem")) predictor_3(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(expected_valid_3),.result_data(expected_data_3));
  assign bus.actual[99+:33]={valid_3,data_3};
  assign bus.expected[99+:33]={expected_valid_3,expected_data_3};
  wire valid_4,expected_valid_4;
  wire [31:0] data_4,expected_data_4;
  Top #(.PROGRAM_FILE("program.mem")) actual_4(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(valid_4),.result_data(data_4));
  dvbench_model #(.PROGRAM_FILE("program.mem")) predictor_4(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(expected_valid_4),.result_data(expected_data_4));
  assign bus.actual[132+:33]={valid_4,data_4};
  assign bus.expected[132+:33]={expected_valid_4,expected_data_4};
  wire valid_5,expected_valid_5;
  wire [31:0] data_5,expected_data_5;
  Top #(.PROGRAM_FILE("")) actual_5(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(valid_5),.result_data(data_5));
  dvbench_model #(.PROGRAM_FILE("")) predictor_5(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(expected_valid_5),.result_data(expected_data_5));
  assign bus.actual[165+:33]={valid_5,data_5};
  assign bus.expected[165+:33]={expected_valid_5,expected_data_5};
  wire valid_6,expected_valid_6;
  wire [31:0] data_6,expected_data_6;
  Top #(.PROGRAM_FILE("isa_shifts.mem")) actual_6(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(valid_6),.result_data(data_6));
  dvbench_model #(.PROGRAM_FILE("isa_shifts.mem")) predictor_6(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(expected_valid_6),.result_data(expected_data_6));
  assign bus.actual[198+:33]={valid_6,data_6};
  assign bus.expected[198+:33]={expected_valid_6,expected_data_6};
  wire valid_7,expected_valid_7;
  wire [31:0] data_7,expected_data_7;
  Top #(.PROGRAM_FILE("isa_boundaries.mem")) actual_7(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(valid_7),.result_data(data_7));
  dvbench_model #(.PROGRAM_FILE("isa_boundaries.mem")) predictor_7(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(expected_valid_7),.result_data(expected_data_7));
  assign bus.actual[231+:33]={valid_7,data_7};
  assign bus.expected[231+:33]={expected_valid_7,expected_data_7};
  wire valid_8,expected_valid_8;
  wire [31:0] data_8,expected_data_8;
  Top #(.PROGRAM_FILE("isa_persistence.mem")) actual_8(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(valid_8),.result_data(data_8));
  dvbench_model #(.PROGRAM_FILE("isa_persistence.mem")) predictor_8(.clk(clk),.rst(rst),.input_data(input_data),.result_valid(expected_valid_8),.result_data(expected_data_8));
  assign bus.actual[264+:33]={valid_8,data_8};
  assign bus.expected[264+:33]={expected_valid_8,expected_data_8};
  assign bus.mask='1;
  initial begin
    uvm_config_db#(virtual dvbench_if)::set(null,"*","vif",bus);
    run_test("dvbench_test");
  end
endmodule
