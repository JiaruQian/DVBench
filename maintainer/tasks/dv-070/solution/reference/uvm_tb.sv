`timescale 1ns/1ps
interface elevator_bus;
  logic clk=0; always #5 clk=~clk;
  logic rst=1;
  logic [4:0] destinations=0;
  logic [26:0] actual, predicted;
  event observe;
endinterface
package dvbench_elevator_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class elevator_transaction extends uvm_sequence_item;
    `uvm_object_utils(elevator_transaction)
    bit reset_pin;
    bit [4:0] destinations;
    int cycles;
    function new(string name="elevator_transaction"); super.new(name); endfunction
  endclass
  class elevator_sequence extends uvm_sequence #(elevator_transaction);
    `uvm_object_utils(elevator_sequence)
    function new(string name="elevator_sequence"); super.new(name); endfunction
    task send(bit reset_pin, bit [4:0] destinations, int cycles);
      elevator_transaction transaction=elevator_transaction::type_id::create("transaction");
      start_item(transaction);
      transaction.reset_pin=reset_pin; transaction.destinations=destinations; transaction.cycles=cycles;
      finish_item(transaction);
    endtask
    task body();
      string profile;
      void'($value$plusargs("witness=%s", profile));
      send(0,0,4);
      if(profile=="insertion") begin
        send(1,5'b10000,10000000);
        send(1,5'b00010,10000000);
        send(0,0,4);
        send(1,5'b10000,10000000);
        send(1,5'b01000,10000000);
      end else if(profile=="travel") begin
        send(1,5'b10000,10000000);
        send(1,5'b00010,600000000);
      end else if(profile=="descent") begin
        send(1,5'b00010,1050000000);
        send(1,5'b00001,20000000);
      end else `uvm_fatal("PROFILE","Missing explicit qualification profile")
      send(0,0,4);
    endtask
  endclass
  class elevator_driver extends uvm_driver #(elevator_transaction);
    `uvm_component_utils(elevator_driver)
    virtual elevator_bus bus;
    bit initialized=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual elevator_bus)::get(this,"","bus",bus)) `uvm_fatal("CONFIG","bus absent")
    endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge bus.clk); #1;
        bus.rst=req.reset_pin; bus.destinations=req.destinations;
        #1; if (initialized) ->bus.observe;
        #(time'(req.cycles)*10-5); ->bus.observe;
        initialized=1;
        seq_item_port.item_done();
      end
    endtask
  endclass
  class elevator_snapshot extends uvm_sequence_item;
    `uvm_object_utils(elevator_snapshot)
    logic [26:0] actual, predicted;
    bit reset_pin;
    function new(string name="elevator_snapshot"); super.new(name); endfunction
  endclass
  class elevator_monitor extends uvm_monitor;
    `uvm_component_utils(elevator_monitor)
    virtual elevator_bus bus;
    uvm_analysis_port #(elevator_snapshot) observations;
    function new(string name,uvm_component parent); super.new(name,parent); observations=new("observations",this); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual elevator_bus)::get(this,"","bus",bus)) `uvm_fatal("CONFIG","bus absent")
    endfunction
    task sample();
      elevator_snapshot snapshot=elevator_snapshot::type_id::create("snapshot");
      snapshot.actual=bus.actual; snapshot.predicted=bus.predicted; snapshot.reset_pin=bus.rst;
      observations.write(snapshot);
    endtask
    task run_phase(uvm_phase phase);
      fork
        forever begin @(bus.observe); sample(); end
        forever begin #100002; sample(); end
      join
    endtask
  endclass
  class elevator_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(elevator_scoreboard)
    uvm_analysis_imp #(elevator_snapshot,elevator_scoreboard) input_port;
    int comparisons, reset_comparisons, accepted_comparisons, busy_comparisons, mismatches;
    covergroup behavior with function sample(bit reset_pin, bit [4:0] leds, bit busy, bit [7:0] an);
      reset_values: coverpoint reset_pin;
      destinations: coverpoint leds { bins empty={0}; bins floor_1={2}; bins floor_2={4}; bins floor_3={8}; bins floor_4={16}; }
      busy_values: coverpoint busy;
      scan: coverpoint an { bins blank={255}; bins digits[]={254,253,251,247,239,223,191,127}; }
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent); input_port=new("input_port",this); behavior=new; endfunction
    function void write(elevator_snapshot snapshot);
      comparisons++;
      if (!snapshot.reset_pin) reset_comparisons++;
      if (snapshot.predicted[26:22]!=0) accepted_comparisons++;
      if (snapshot.predicted[16]) busy_comparisons++;
      if (snapshot.actual !== snapshot.predicted && mismatches++<20)
        `uvm_error("PINS",$sformatf("actual=%h predicted=%h rst=%b",snapshot.actual,snapshot.predicted,snapshot.reset_pin))
      behavior.sample(snapshot.reset_pin,snapshot.actual[26:22],snapshot.actual[16],snapshot.actual[7:0]);
    endfunction
    function void check_phase(uvm_phase phase);
      if (comparisons<3000 || accepted_comparisons<1000 || reset_comparisons<3 || busy_comparisons<10)
        `uvm_error("VACUITY","insufficient reset/request/scan/busy observations")
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("EVIDENCE",$sformatf("comparisons=%0d reset_comparisons=%0d accepted_comparisons=%0d busy_comparisons=%0d functional_coverage=%0.2f",comparisons,reset_comparisons,accepted_comparisons,busy_comparisons,behavior.get_inst_coverage()),UVM_LOW)
    endfunction
  endclass
  class elevator_agent extends uvm_agent;
    `uvm_component_utils(elevator_agent)
    elevator_driver driver; elevator_monitor monitor; uvm_sequencer #(elevator_transaction) sequencer;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      driver=elevator_driver::type_id::create("driver",this); monitor=elevator_monitor::type_id::create("monitor",this); sequencer=new("sequencer",this);
    endfunction
    function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
  endclass
  class elevator_environment extends uvm_env;
    `uvm_component_utils(elevator_environment)
    elevator_agent agent; elevator_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); agent=elevator_agent::type_id::create("agent",this); scoreboard=elevator_scoreboard::type_id::create("scoreboard",this); endfunction
    function void connect_phase(uvm_phase phase); agent.monitor.observations.connect(scoreboard.input_port); endfunction
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    elevator_environment environment;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); environment=elevator_environment::type_id::create("environment",this); endfunction
    task run_phase(uvm_phase phase);
      elevator_sequence sequence_object=elevator_sequence::type_id::create("sequence_object");
      phase.raise_objection(this); sequence_object.start(environment.agent.sequencer); phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      uvm_report_server report_server=uvm_report_server::get_server();
      if (report_server.get_severity_count(UVM_ERROR)==0 && report_server.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
    endfunction
  endclass
endpackage
module dvbench_top;
  import uvm_pkg::*; import dvbench_elevator_pkg::*;
  elevator_bus bus();
  top_module dut(.clk(bus.clk),.rst(bus.rst),.floor_0_p(1'b0),.floor_1_p(1'b0),.floor_2_p(1'b0),.floor_3_p(1'b0),.floor_4_p(1'b0),.floor_0_d(bus.destinations[0]),.floor_1_d(bus.destinations[1]),.floor_2_d(bus.destinations[2]),.floor_3_d(bus.destinations[3]),.floor_4_d(bus.destinations[4]),.direction_1(1'b1),.direction_2(1'b1),.direction_3(1'b1),.led_inside_4(bus.actual[26]),.led_inside_3(bus.actual[25]),.led_inside_2(bus.actual[24]),.led_inside_1(bus.actual[23]),.led_inside_0(bus.actual[22]),.led_outside_4(bus.actual[21]),.led_outside_3(bus.actual[20]),.led_outside_2(bus.actual[19]),.led_outside_1(bus.actual[18]),.led_outside_0(bus.actual[17]),.led_busy(bus.actual[16]),.a_out(bus.actual[15]),.b_out(bus.actual[14]),.c_out(bus.actual[13]),.d_out(bus.actual[12]),.e_out(bus.actual[11]),.f_out(bus.actual[10]),.g_out(bus.actual[9]),.p_out(bus.actual[8]),.an(bus.actual[7:0]));
  dvbench_model predictor(.clk(bus.clk),.rst(bus.rst),.floor_0_p(1'b0),.floor_1_p(1'b0),.floor_2_p(1'b0),.floor_3_p(1'b0),.floor_4_p(1'b0),.floor_0_d(bus.destinations[0]),.floor_1_d(bus.destinations[1]),.floor_2_d(bus.destinations[2]),.floor_3_d(bus.destinations[3]),.floor_4_d(bus.destinations[4]),.direction_1(1'b1),.direction_2(1'b1),.direction_3(1'b1),.led_inside_4(bus.predicted[26]),.led_inside_3(bus.predicted[25]),.led_inside_2(bus.predicted[24]),.led_inside_1(bus.predicted[23]),.led_inside_0(bus.predicted[22]),.led_outside_4(bus.predicted[21]),.led_outside_3(bus.predicted[20]),.led_outside_2(bus.predicted[19]),.led_outside_1(bus.predicted[18]),.led_outside_0(bus.predicted[17]),.led_busy(bus.predicted[16]),.a_out(bus.predicted[15]),.b_out(bus.predicted[14]),.c_out(bus.predicted[13]),.d_out(bus.predicted[12]),.e_out(bus.predicted[11]),.f_out(bus.predicted[10]),.g_out(bus.predicted[9]),.p_out(bus.predicted[8]),.an(bus.predicted[7:0]));
  initial begin uvm_config_db#(virtual elevator_bus)::set(null,"*","bus",bus); run_test("dvbench_test"); end
  initial begin #12000000000; `uvm_fatal("WATCHDOG","early history failed to drain") end
endmodule
