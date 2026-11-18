`timescale 1ns/1ps
interface dvbench_if(input logic clk);
  logic [2402-1:0] stimulus='0;
  wire [65-1:0] actual,expected,mask;
endinterface

package dvbench_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class drive_item extends uvm_sequence_item;
    `uvm_object_utils(drive_item)
    bit [2402-1:0] inputs;
    int unsigned cycles;
    function new(string name="drive_item"); super.new(name); endfunction
  endclass
  class observed_item extends uvm_sequence_item;
    `uvm_object_utils(observed_item)
    logic [65-1:0] actual,expected,mask;
    longint unsigned cycle;
    function new(string name="observed_item"); super.new(name); endfunction
  endclass
  class stimulus_sequence extends uvm_sequence #(drive_item);
    `uvm_object_utils(stimulus_sequence)
    function new(string name="stimulus_sequence"); super.new(name); endfunction
    task drive(bit [2402-1:0] inputs,int unsigned cycles=1);
      drive_item item=drive_item::type_id::create("item");
      start_item(item); item.inputs=inputs; item.cycles=cycles; finish_item(item);
    endtask
    task body();
      bit [0:2399] image;
      bit enabled;
      image=0;
      drive({1'b0,1'b0,image},4);
      for(int wall_cycle=0;wall_cycle<18000;wall_cycle++) begin
        if(wall_cycle<1200) image=0;
        else if(wall_cycle<2400) image={300{8'h7f}};
        else if(wall_cycle<3600) image={300{8'h80}};
        else if(wall_cycle%97==0)
          for(int pixel=0;pixel<300;pixel++) image[pixel*8+:8]=$urandom;
        enabled=!(wall_cycle%43>=37 || (wall_cycle>=5700 && wall_cycle<5730));
        if(wall_cycle>=9000 && wall_cycle<9004) drive({1'b0,1'b0,image});
        else drive({1'b1,enabled,image});
      end
      drive({1'b1,1'b1,image},700);
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
      if(comparisons<18000 || active_samples<40) `uvm_error("NONVACUITY","Insufficient sampled activity")
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
  wire rst_b,en;
  wire [0:2399] mem;
  wire valid,expected_valid;
  wire [31:0] float_out0,float_out1,expected0,expected1;
  assign {rst_b,en,mem}=bus.stimulus;
  CNN actual_dut(.clk(clk),.rst_b(rst_b),.en(en),.mem(mem),.valid(valid),.float_out0(float_out0),.float_out1(float_out1));
  dvbench_model predictor(.clk(clk),.rst_b(rst_b),.en(en),.mem(mem),.valid(expected_valid),.float_out0(expected0),.float_out1(expected1));
  assign bus.actual={valid,float_out0,float_out1};
  assign bus.expected={expected_valid,expected0,expected1};
  assign bus.mask={1'b1,{64{expected_valid}}};
  initial begin
    uvm_config_db#(virtual dvbench_if)::set(null,"*","vif",bus);
    run_test("dvbench_test");
  end
endmodule
