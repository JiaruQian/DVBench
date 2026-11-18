`timescale 1ns/1ps
interface ethernet_bus;
  logic Clk=0; always #5 Clk=~Clk;
  logic Reset=1, clk_en=1, iEmpty=1;
  logic [15:0] i8Data=0;
  logic [7:0] data, expected_data;
  logic enabled, expected_enabled, error, expected_error, complete, expected_complete, read_clock, expected_read_clock;
  logic [2:0] diagnostic, expected_diagnostic;
  logic [8:0] address, expected_address;
endinterface
package dvbench_ethernet_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class ethernet_transaction extends uvm_sequence_item;
    `uvm_object_utils(ethernet_transaction)
    bit reset, enabled, empty;
    bit [15:0] data;
    function new(string name="ethernet_transaction"); super.new(name); endfunction
  endclass
  class ethernet_sequence extends uvm_sequence #(ethernet_transaction);
    `uvm_object_utils(ethernet_sequence)
    function new(string name="ethernet_sequence"); super.new(name); endfunction
    task send(bit reset, enabled, empty, bit [15:0] data);
      ethernet_transaction transaction=ethernet_transaction::type_id::create("transaction");
      start_item(transaction);
      transaction.reset=reset; transaction.enabled=enabled; transaction.empty=empty; transaction.data=data;
      finish_item(transaction);
    endtask
    task body();
      
      repeat (3) send(1,1,1,0);
      for (int idle_index=0; idle_index<12; idle_index++) send(0,idle_index[0],1,16'ha55a);
      for (int frame_index=0; frame_index<10; frame_index++) begin
        int payload_length;
        case (frame_index)
          0: payload_length=1;
          1: payload_length=2;
          2: payload_length=3;
          3: payload_length=31;
          4: payload_length=64;
          5: payload_length=255;
          6: payload_length=512;
          7: payload_length=1024;
          8: payload_length=1025;
          9: payload_length=17;
        endcase
        for (int beat=0; beat<payload_length+65; beat++) begin
          bit empty;
          bit [15:0] data;
          empty=(beat>=21+payload_length);
          data={8'(beat^frame_index),8'(255-beat+frame_index)};
          if (beat%7==3 || beat==23) begin
            send(0,0,empty,data);
            send(0,0,empty,data);
          end
          send(0,1,empty,data);
        end
        repeat (3) send(0,1,1,0);
      end
      for (int interrupted_phase=0; interrupted_phase<7; interrupted_phase++) begin
        int offset;
        case (interrupted_phase)
          0: offset=0;
          1: offset=4;
          2: offset=8;
          3: offset=15;
          4: offset=30;
          5: offset=41;
          6: offset=47;
        endcase
        send(1,0,1,0);
        for (int beat=0; beat<offset; beat++) send(0,1,beat>=39,16'h96c3);
        send(1,0,1,0);
        repeat(4) send(0,1,1,0);
      end
      for (int boundary=0; boundary<40; boundary++) begin
        send(1,1,1,0);
        for (int beat=0; beat<80; beat++) begin
          send(0,1,beat==boundary,16'h5ac3);
          if (beat==boundary) begin
            send(0,0,0,16'hc35a);
            send(0,1,0,16'ha639);
          end
        end
      end
      for (int random_cycle=0; random_cycle<512; random_cycle++)
        send(random_cycle%103==0,$urandom_range(0,1),$urandom_range(0,1),$urandom);
      repeat (3) send(1,1,1,0);

    endtask
  endclass
  class ethernet_driver extends uvm_driver #(ethernet_transaction);
    `uvm_component_utils(ethernet_driver)
    virtual ethernet_bus bus;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual ethernet_bus)::get(this,"","bus",bus)) `uvm_fatal("CONFIG","bus absent")
    endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge bus.Clk); #1;
        bus.Reset=req.reset; bus.clk_en=req.enabled; bus.iEmpty=req.empty; bus.i8Data=req.data;
        @(posedge bus.Clk); #2;
        seq_item_port.item_done();
      end
    endtask
  endclass
  class ethernet_snapshot extends uvm_sequence_item;
    `uvm_object_utils(ethernet_snapshot)
    logic [7:0] data, expected_data;
    logic [3:0] flags, expected_flags;
    logic [2:0] diagnostic, expected_diagnostic;
    logic [8:0] address, expected_address;
    bit rising, reset, clock_enabled;
    function new(string name="ethernet_snapshot"); super.new(name); endfunction
  endclass
  class ethernet_monitor extends uvm_monitor;
    `uvm_component_utils(ethernet_monitor)
    virtual ethernet_bus bus;
    uvm_analysis_port #(ethernet_snapshot) observations;
    function new(string name,uvm_component parent);
      super.new(name,parent); observations=new("observations",this);
    endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual ethernet_bus)::get(this,"","bus",bus)) `uvm_fatal("CONFIG","bus absent")
    endfunction
    task run_phase(uvm_phase phase);
      ethernet_snapshot snapshot;
      forever begin
        @(posedge bus.Clk or negedge bus.Clk); #1;
        if (!bus.Clk) #2;
        snapshot=ethernet_snapshot::type_id::create("snapshot");
        snapshot.data=bus.data; snapshot.expected_data=bus.expected_data;
        snapshot.flags={bus.enabled,bus.error,bus.complete,bus.read_clock};
        snapshot.expected_flags={bus.expected_enabled,bus.expected_error,bus.expected_complete,bus.expected_read_clock};
        snapshot.diagnostic=bus.diagnostic; snapshot.expected_diagnostic=bus.expected_diagnostic;
        snapshot.address=bus.address; snapshot.expected_address=bus.expected_address;
        snapshot.rising=bus.Clk; snapshot.reset=bus.Reset; snapshot.clock_enabled=bus.clk_en;
        observations.write(snapshot);
      end
    endtask
  endclass
  class ethernet_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ethernet_scoreboard)
    uvm_analysis_imp #(ethernet_snapshot,ethernet_scoreboard) input_port;
    int comparisons=0, valid_comparisons=0, falling_comparisons=0;
    covergroup behavior with function sample(bit rising, bit reset, bit enabled, logic [2:0] phase, logic [8:0] address);
      edge_kind: coverpoint rising;
      reset_value: coverpoint reset;
      enable_value: coverpoint enabled;
      phases: coverpoint phase { bins stages[]={[0:6]}; }
      addresses: coverpoint address { bins domain[]={[0:511]}; }
      stage_pause: cross phases,enable_value;
    endgroup
    function new(string name,uvm_component parent);
      super.new(name,parent); input_port=new("input_port",this); behavior=new;
    endfunction
    function void write(ethernet_snapshot snapshot);
      comparisons++;
      if (!snapshot.rising) falling_comparisons++;
      if ({snapshot.flags,snapshot.diagnostic,snapshot.address} !== {snapshot.expected_flags,snapshot.expected_diagnostic,snapshot.expected_address})
        `uvm_error("CONTROL",$sformatf("flags=%b/%b phase=%d/%d address=%d/%d rising=%b",snapshot.flags,snapshot.expected_flags,snapshot.diagnostic,snapshot.expected_diagnostic,snapshot.address,snapshot.expected_address,snapshot.rising))
      if (snapshot.expected_flags[3]===1'b1) begin
        valid_comparisons++;
        if (snapshot.data !== snapshot.expected_data)
          `uvm_error("FRAME",$sformatf("data=%h expected=%h phase=%d",snapshot.data,snapshot.expected_data,snapshot.diagnostic))
      end
      behavior.sample(snapshot.rising,snapshot.reset,snapshot.clock_enabled,snapshot.diagnostic,snapshot.address);
    endfunction
    function void check_phase(uvm_phase phase);
      if (comparisons<8000 || valid_comparisons<5000 || falling_comparisons<4000)
        `uvm_error("VACUITY","insufficient pin and frame comparisons")
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("EVIDENCE",$sformatf("comparisons=%0d valid_comparisons=%0d falling_comparisons=%0d functional_coverage=%0.2f",comparisons,valid_comparisons,falling_comparisons,behavior.get_inst_coverage()),UVM_LOW)
    endfunction
  endclass
  class ethernet_agent extends uvm_agent;
    `uvm_component_utils(ethernet_agent)
    ethernet_driver driver;
    ethernet_monitor monitor;
    uvm_sequencer #(ethernet_transaction) sequencer;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      driver=ethernet_driver::type_id::create("driver",this);
      monitor=ethernet_monitor::type_id::create("monitor",this);
      sequencer=new("sequencer",this);
    endfunction
    function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
  endclass
  class ethernet_environment extends uvm_env;
    `uvm_component_utils(ethernet_environment)
    ethernet_agent agent;
    ethernet_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      agent=ethernet_agent::type_id::create("agent",this);
      scoreboard=ethernet_scoreboard::type_id::create("scoreboard",this);
    endfunction
    function void connect_phase(uvm_phase phase); agent.monitor.observations.connect(scoreboard.input_port); endfunction
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    ethernet_environment environment;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); environment=ethernet_environment::type_id::create("environment",this); endfunction
    task run_phase(uvm_phase phase);
      ethernet_sequence sequence_object=ethernet_sequence::type_id::create("sequence_object");
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
  import dvbench_ethernet_pkg::*;
  ethernet_bus bus();
  IEEE802TX dut(.Reset(bus.Reset),.Clk(bus.Clk),.clk_en(bus.clk_en),.iEmpty(bus.iEmpty),.i8Data(bus.i8Data),.gmii_txd(bus.data),.gmii_tx_en(bus.enabled),.gmii_tx_er(bus.error),.complete(bus.complete),.oRead(bus.read_clock),.diagnostic(bus.diagnostic),.Addres(bus.address));
  dvbench_model predictor(.Reset(bus.Reset),.Clk(bus.Clk),.clk_en(bus.clk_en),.iEmpty(bus.iEmpty),.i8Data(bus.i8Data),.gmii_txd(bus.expected_data),.gmii_tx_en(bus.expected_enabled),.gmii_tx_er(bus.expected_error),.complete(bus.expected_complete),.oRead(bus.expected_read_clock),.diagnostic(bus.expected_diagnostic),.Addres(bus.expected_address));
  initial begin
    uvm_config_db#(virtual ethernet_bus)::set(null,"*","bus",bus);
    run_test("dvbench_test");
  end
  initial begin
    #400000;
    `uvm_fatal("WATCHDOG","verification failed to drain")
  end
endmodule
