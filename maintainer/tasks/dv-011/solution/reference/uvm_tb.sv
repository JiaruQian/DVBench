`timescale 1ns/1ps
interface vga_bus;
  logic Clock = 0;
  logic Reset = 1;
  logic Enabled = 0;
  logic OutVisible, OutFP, OutSP, OutBP, OutMax;
  logic [9:0] OutCounter;
  logic ExpectedVisible, ExpectedFP, ExpectedSP, ExpectedBP, ExpectedMax;
  logic [9:0] ExpectedCounter;
  always #5 Clock = ~Clock;
endinterface

package dvbench_vga_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class vga_transaction extends uvm_sequence_item;
    rand bit reset;
    rand bit enabled;
    `uvm_object_utils(vga_transaction)
    function new(string name="vga_transaction"); super.new(name); endfunction
  endclass
  class vga_sequence extends uvm_sequence #(vga_transaction);
    `uvm_object_utils(vga_sequence)
    function new(string name="vga_sequence"); super.new(name); endfunction
    task send(bit reset, bit enabled);
      vga_transaction transaction = vga_transaction::type_id::create("transaction");
      start_item(transaction);
      transaction.reset = reset;
      transaction.enabled = enabled;
      finish_item(transaction);
    endtask
    task body();
      send(1,0);
      repeat (525) begin
        send(0,0);
        send(0,1);
      end
      for (int target=0; target<=524; target++) begin
        for (int enable_case=0; enable_case<=1; enable_case++) begin
          send(1,0);
          if (target==0) repeat (524) send(0,1);
          else repeat (target-1) send(0,1);
          send(1,enable_case);
        end
      end
      repeat (7) send(0,0);
      send(1,1);
      send(1,0);
      repeat (600) begin
        send(0,$urandom_range(0,1));
      end
      repeat (600) send(0,1);
      send(0,0);
    endtask
  endclass
  class vga_driver extends uvm_driver #(vga_transaction);
    `uvm_component_utils(vga_driver)
    virtual vga_bus bus;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vga_bus)::get(this,"","bus",bus)) `uvm_fatal("CONFIG","bus absent")
    endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge bus.Clock);
        bus.Reset = req.reset;
        bus.Enabled = req.enabled;
        @(posedge bus.Clock);
        #2;
        seq_item_port.item_done();
      end
    endtask
  endclass
  class vga_snapshot extends uvm_sequence_item;
    `uvm_object_utils(vga_snapshot)
    logic [9:0] actual_counter, expected_counter;
    logic [4:0] actual_flags, expected_flags;
    bit reset, enabled;
    function new(string name="vga_snapshot"); super.new(name); endfunction
  endclass
  class vga_monitor extends uvm_monitor;
    `uvm_component_utils(vga_monitor)
    virtual vga_bus bus;
    uvm_analysis_port #(vga_snapshot) observations;
    function new(string name,uvm_component parent);
      super.new(name,parent); observations=new("observations",this);
    endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vga_bus)::get(this,"","bus",bus)) `uvm_fatal("CONFIG","bus absent")
    endfunction
    task run_phase(uvm_phase phase);
      vga_snapshot snapshot;
      forever begin
        @(posedge bus.Clock); #1;
        snapshot=vga_snapshot::type_id::create("snapshot");
        snapshot.actual_counter=bus.OutCounter;
        snapshot.expected_counter=bus.ExpectedCounter;
        snapshot.actual_flags={bus.OutMax,bus.OutBP,bus.OutSP,bus.OutFP,bus.OutVisible};
        snapshot.expected_flags={bus.ExpectedMax,bus.ExpectedBP,bus.ExpectedSP,bus.ExpectedFP,bus.ExpectedVisible};
        snapshot.reset=bus.Reset; snapshot.enabled=bus.Enabled;
        observations.write(snapshot);
      end
    endtask
  endclass
  class vga_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(vga_scoreboard)
    uvm_analysis_imp #(vga_snapshot,vga_scoreboard) input_port;
    int checks=0;
    int prediction_failures=0, phase_failures=0;
    bit seen_counter[525];
    bit seen_transition[525][2][2];
    logic [9:0] previous_expected;
    bit previous_valid=0;
    covergroup behavior with function sample(int counter, bit reset, bit enabled);
      count: coverpoint counter { bins legal[]={[0:524]}; }
      reset_value: coverpoint reset;
      enable_value: coverpoint enabled;
      reset_enable: cross reset_value, enable_value;
    endgroup
    function new(string name,uvm_component parent);
      super.new(name,parent); input_port=new("input_port",this); behavior=new;
    endfunction
    function void compare_snapshot(vga_snapshot snapshot);
      checks++;
      if (snapshot.actual_counter !== snapshot.expected_counter || snapshot.actual_flags !== snapshot.expected_flags) begin
        prediction_failures++;
        if(prediction_failures<=10) `uvm_error("PREDICTION",$sformatf("count actual=%0d expected=%0d flags actual=%b expected=%b",snapshot.actual_counter,snapshot.expected_counter,snapshot.actual_flags,snapshot.expected_flags))
      end
      if (!$onehot(snapshot.actual_flags[3:0])) begin
        phase_failures++;
        if(phase_failures<=10) `uvm_error("PHASE","phase is not one-hot")
      end
      if (snapshot.expected_counter <= 524) seen_counter[snapshot.expected_counter]=1;
      if (previous_valid && previous_expected <= 524) begin
        seen_transition[previous_expected][snapshot.reset][snapshot.enabled]=1;
        behavior.sample(previous_expected,snapshot.reset,snapshot.enabled);
      end
      previous_expected=snapshot.expected_counter;
      previous_valid=1;
    endfunction
    function void write(vga_snapshot snapshot); compare_snapshot(snapshot); endfunction
    function void check_phase(uvm_phase phase);
      if (checks < 2000) `uvm_error("VACUITY","too few comparisons")
      foreach (seen_counter[index]) if (!seen_counter[index]) `uvm_error("COVERAGE",$sformatf("unvisited counter=%0d",index))
      foreach (seen_transition[counter,reset,enabled])
        if (!seen_transition[counter][reset][enabled])
          `uvm_error("COVERAGE",$sformatf("unvisited transition before=%0d reset=%0d enabled=%0d",counter,reset,enabled))
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("EVIDENCE",$sformatf("comparisons=%0d prediction_failures=%0d phase_failures=%0d functional_coverage=%0.2f",checks,prediction_failures,phase_failures,behavior.get_inst_coverage()),UVM_LOW)
    endfunction
  endclass
  class vga_agent extends uvm_agent;
    `uvm_component_utils(vga_agent)
    vga_driver driver;
    vga_monitor monitor;
    uvm_sequencer #(vga_transaction) sequencer;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      driver=vga_driver::type_id::create("driver",this);
      monitor=vga_monitor::type_id::create("monitor",this);
      sequencer=new("sequencer",this);
    endfunction
    function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
  endclass
  class vga_environment extends uvm_env;
    `uvm_component_utils(vga_environment)
    vga_agent agent;
    vga_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      agent=vga_agent::type_id::create("agent",this);
      scoreboard=vga_scoreboard::type_id::create("scoreboard",this);
    endfunction
    function void connect_phase(uvm_phase phase); agent.monitor.observations.connect(scoreboard.input_port); endfunction
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    vga_environment environment;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); environment=vga_environment::type_id::create("environment",this); endfunction
    task run_phase(uvm_phase phase);
      vga_sequence sequence_object=vga_sequence::type_id::create("sequence_object");
      phase.raise_objection(this);
      sequence_object.start(environment.agent.sequencer);
      phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      uvm_report_server report_server=uvm_report_server::get_server();
      if (report_server.get_severity_count(UVM_ERROR)==0 && report_server.get_severity_count(UVM_FATAL)==0)
        $display("DVBench_COMPLETED");
    endfunction
  endclass
endpackage

module dvbench_top;
  import uvm_pkg::*;
  import dvbench_vga_pkg::*;
  vga_bus bus();
  VGASyncModule_TopLevel dut(.Clock(bus.Clock),.Reset(bus.Reset),.Enabled(bus.Enabled),.OutVisible(bus.OutVisible),.OutFP(bus.OutFP),.OutSP(bus.OutSP),.OutBP(bus.OutBP),.OutMax(bus.OutMax),.OutCounter(bus.OutCounter));
  dvbench_model predictor(.Clock(bus.Clock),.Reset(bus.Reset),.Enabled(bus.Enabled),.OutVisible(bus.ExpectedVisible),.OutFP(bus.ExpectedFP),.OutSP(bus.ExpectedSP),.OutBP(bus.ExpectedBP),.OutMax(bus.ExpectedMax),.OutCounter(bus.ExpectedCounter));
  initial begin
    uvm_config_db#(virtual vga_bus)::set(null,"*","bus",bus);
    run_test("dvbench_test");
  end
  initial begin
    #4000000;
    `uvm_fatal("WATCHDOG","verification failed to drain")
  end
endmodule
