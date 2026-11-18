`timescale 1ns/1ps
package native_types;
typedef struct packed {
    logic rst;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic we;
    logic rd;
} stimulus_t;
typedef struct packed {
    logic [31:0] rdata;
} observation_t;
endpackage
interface native_bus;
  import native_types::*;
  logic clock=0;
  always #5 clock=~clock;
  stimulus_t pins='0;
  observation_t actual,predicted;
  bit check_result=0;
  event observe;
endinterface
package reference_pkg;
  import native_types::*;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class native_transaction extends uvm_sequence_item;
    `uvm_object_utils(native_transaction)
    stimulus_t pins;
    integer cycles;
    bit check_result;
    function new(string name="native_transaction"); super.new(name); endfunction
  endclass
  class native_sequence extends uvm_sequence #(native_transaction);
    `uvm_object_utils(native_sequence)
    function new(string name="native_sequence"); super.new(name); endfunction
    task step(stimulus_t pins, integer cycles=1, bit check_result=0);
      native_transaction transaction=native_transaction::type_id::create("transaction");
      start_item(transaction); transaction.pins=pins; transaction.cycles=cycles; transaction.check_result=check_result; finish_item(transaction);
    endtask
    task body();
      stimulus_t pins;
      pins='0; pins.rst=1;step(pins,3,1);pins.rst=0;step(pins,2,1);
      for(integer operation=0;operation<24;operation++) begin
        integer lane_total,byte_total;
        if(operation==3) begin
          pins.we=0;pins.rd=1;pins.addr=32'h94;step(pins,1,1);
          pins.rst=1;step(pins,2,1);pins.rst=0;step(pins,2,1);
        end
        lane_total=(operation==0 || operation==2 || operation==3)?1:((operation==1)?17:((operation<12)?16+(operation%2):1+$urandom_range(0,16)));
        byte_total=(operation==0 || operation==2 || operation==3)?3:1+(operation%8);
        pins.we=1;pins.rd=1;pins.addr=32'h88;pins.wdata=lane_total;step(pins,1,1);
        pins.addr=32'h8c;pins.wdata=byte_total;step(pins,1,1);
        for(integer lane_index=0;lane_index<lane_total;lane_index++) begin
          pins.addr=32'h100+8*lane_index+(operation%4);
          pins.wdata=(operation==0 || operation==2 || operation==3 || operation==4)?0:((operation==5)?32'hffffffff:((operation==6)?32'haaaa5555:$urandom));step(pins,1,1);
          pins.addr=32'h100+8*lane_index+4+(operation%4);
          pins.wdata=(operation==0 || operation==2 || operation==3)?32'h61626300:((operation==4)?0:((operation==5)?32'hffffffff:((operation==6)?32'h5555aaaa:$urandom)));step(pins,1,1);
        end
        pins.addr=32'h90;pins.wdata=0;step(pins,2,1);
        pins.addr=32'h90;pins.wdata=1;step(pins,1,1);pins.we=0;
        pins.rd=1;pins.addr=32'h94;step(pins,5,1);
        pins.we=1;pins.addr=32'h90;pins.wdata=1;step(pins,1,1);
        pins.we=0;pins.addr=32'h94;step(pins,lane_total+35,1);
        for(integer read_index=0;read_index<8;read_index++) begin pins.addr=32'ha0+4*read_index;step(pins,1,1);end
        pins.addr=32'h194;step(pins,1,1);pins.rd=0;step(pins,1,1);
        pins.addr=32'ha1;pins.rd=1;step(pins,1,1);
        pins.addr=32'hff;pins.rd=1;step(pins,1,1);pins.rd=0;
        if(operation%7==6) begin
          pins.we=1;pins.addr=32'h90;pins.wdata=1;step(pins,1,1);
          pins.we=0;pins.rd=1;pins.addr=32'ha0;step(pins,10,1);
          pins.rst=1;step(pins,2,1);pins.rst=0;step(pins,2,1);
        end
      end
      pins.we=0;pins.rd=1;pins.addr=32'h94;step(pins,1,1);
      pins.rst=1;step(pins,2,1);pins.rst=0;step(pins,2,1);

    endtask
  endclass
  class native_driver extends uvm_driver #(native_transaction);
    `uvm_component_utils(native_driver)
    virtual native_bus bus;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(virtual native_bus)::get(this,"","bus",bus)) `uvm_fatal("CONFIG","missing bus")
    endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge bus.clock); #1; bus.pins=req.pins; bus.check_result=req.check_result;
        #1; ->bus.observe;
        repeat(req.cycles) begin @(posedge bus.clock); #1; ->bus.observe; end
        seq_item_port.item_done();
      end
    endtask
  endclass
  class native_snapshot extends uvm_sequence_item;
    `uvm_object_utils(native_snapshot)
    stimulus_t pins;
    observation_t actual,predicted,mask;
    function new(string name="native_snapshot"); super.new(name); endfunction
  endclass
  class native_monitor extends uvm_monitor;
    `uvm_component_utils(native_monitor)
    virtual native_bus bus;
    uvm_analysis_port #(native_snapshot) observed;
    function new(string name,uvm_component parent); super.new(name,parent); observed=new("observed",this); endfunction
    function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(virtual native_bus)::get(this,"","bus",bus)) `uvm_fatal("CONFIG","missing bus")
    endfunction
    task run_phase(uvm_phase phase);
      forever begin
        native_snapshot snapshot;
        observation_t mask;
        @(bus.observe);
        snapshot=native_snapshot::type_id::create("snapshot"); mask='1;
        
        snapshot.pins=bus.pins; snapshot.actual=bus.actual; snapshot.predicted=bus.predicted; snapshot.mask=mask;
        observed.write(snapshot);
      end
    endtask
  endclass
  class native_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(native_scoreboard)
    uvm_analysis_imp #(native_snapshot,native_scoreboard) observed;
    integer comparisons=0,changes=0;
    observation_t previous_actual;
    covergroup observations with function sample(bit changed,bit mismatch);
      activity: coverpoint changed;
      comparison_result: coverpoint mismatch;
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent); observed=new("observed",this); observations=new; endfunction
    function void write(native_snapshot snapshot);
      bit mismatch;
      comparisons++;
      if((snapshot.actual&snapshot.mask)!==previous_actual) changes++;
      previous_actual=snapshot.actual&snapshot.mask;
      mismatch=((snapshot.actual&snapshot.mask)!==(snapshot.predicted&snapshot.mask));
      observations.sample(changes>0,mismatch);
      if(mismatch) `uvm_error("NATIVE_COMPARE",$sformatf("sample=%0d actual=%h expected=%h mask=%h inputs=%h",comparisons,snapshot.actual,snapshot.predicted,snapshot.mask,snapshot.pins))
    endfunction
    function void check_phase(uvm_phase phase);
      if(comparisons<100 || changes<5) `uvm_error("VACUITY","missing meaningful input/output history")
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("EVIDENCE",$sformatf("comparisons=%0d changes=%0d",comparisons,changes),UVM_LOW)
    endfunction
  endclass
  class native_agent extends uvm_agent;
    `uvm_component_utils(native_agent)
    native_driver driver; native_monitor monitor; uvm_sequencer #(native_transaction) sequencer;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      driver=native_driver::type_id::create("driver",this); monitor=native_monitor::type_id::create("monitor",this); sequencer=new("sequencer",this);
    endfunction
    function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
  endclass
  class native_environment extends uvm_env;
    `uvm_component_utils(native_environment)
    native_agent agent; native_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); agent=native_agent::type_id::create("agent",this); scoreboard=native_scoreboard::type_id::create("scoreboard",this); endfunction
    function void connect_phase(uvm_phase phase); agent.monitor.observed.connect(scoreboard.observed); endfunction
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    native_environment environment;
    function new(string name="dvbench_test",uvm_component parent=null); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); environment=native_environment::type_id::create("environment",this); endfunction
    task run_phase(uvm_phase phase);
      native_sequence sequence_object=native_sequence::type_id::create("sequence_object");
      phase.raise_objection(this); sequence_object.start(environment.agent.sequencer); #2; phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      uvm_report_server server=uvm_report_server::get_server();
      if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
    endfunction
  endclass
endpackage
module dvbench_top;
  import uvm_pkg::*; import reference_pkg::*;
  native_bus bus();
  sha3_mmio dut(.clk(bus.clock),.rst(bus.pins.rst),.addr(bus.pins.addr),.wdata(bus.pins.wdata),.we(bus.pins.we),.rd(bus.pins.rd),.rdata(bus.actual.rdata));
  dvbench_model predictor(.clk(bus.clock),.rst(bus.pins.rst),.addr(bus.pins.addr),.wdata(bus.pins.wdata),.we(bus.pins.we),.rd(bus.pins.rd),.rdata(bus.predicted.rdata));
  initial begin uvm_config_db#(virtual native_bus)::set(null,"*","bus",bus); run_test("dvbench_test"); end
  initial begin #5000000; `uvm_fatal("WATCHDOG","reference history did not terminate") end
endmodule
