`timescale 1ns/1ps
package native_types;
typedef struct packed {
    logic [3:0] alu_cmd;
    logic [63:0] fxu_areg_q;
    logic [63:0] fxu_breg_q;
    logic local_error_found;
} stimulus_t;
typedef struct packed {
    logic [63:0] bin_sum;
    logic bin_ovfl;
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
      for(integer command_value=0;command_value<16;command_value++) begin
        for(integer flag_value=0;flag_value<=1;flag_value++) begin
          pins='0; pins.alu_cmd=command_value; pins.local_error_found=flag_value;
          pins.fxu_areg_q=64'h7fffffffffffffff; pins.fxu_breg_q=64'h1; step(pins,1,1);
          pins.fxu_areg_q=64'h8000000000000000; pins.fxu_breg_q=64'hffffffffffffffff; step(pins,1,1);
          pins.fxu_areg_q=64'h8000000000000000; pins.fxu_breg_q=64'h1; step(pins,1,1);
          pins.fxu_areg_q=64'h7fffffffffffffff; pins.fxu_breg_q=64'hffffffffffffffff; step(pins,1,1);
          pins.fxu_areg_q=64'h000000007fffffff; pins.fxu_breg_q=64'h1; step(pins,1,1);
          pins.fxu_areg_q=64'hffffffffffffffff; pins.fxu_breg_q=64'h1; step(pins,1,1);
          pins.fxu_areg_q='0; pins.fxu_breg_q='0; step(pins,1,1);
          pins.fxu_areg_q='1; pins.fxu_breg_q='1; step(pins,1,1);
          for(integer bit_index=0;bit_index<64;bit_index++) begin
            pins.fxu_areg_q=64'b1<<bit_index;
            pins.fxu_breg_q=64'b1<<bit_index;
            step(pins,1,1);
            pins.fxu_areg_q='1;
            step(pins,1,1);
            pins.fxu_areg_q='0;
            step(pins,1,1);
            pins.fxu_areg_q=(64'b1<<bit_index)-1;
            pins.fxu_breg_q=1;
            step(pins,1,1);
          end
          for(integer sample_index=0;sample_index<512;sample_index++) begin
            pins.fxu_areg_q={$urandom,$urandom};
            pins.fxu_breg_q={$urandom,$urandom};
            step(pins,1,1);
          end
        end
      end
      pins='0; pins.alu_cmd=2; pins.fxu_areg_q=64'hfedcba9876543210; pins.fxu_breg_q=64'h123456789abcdef0;
      pins.local_error_found=1'bx; step(pins,1,1);
      pins.local_error_found=1'bz; step(pins,1,1);
      pins.alu_cmd=1; pins.fxu_breg_q='0;
      pins.local_error_found=1'bx; step(pins,1,1);
      pins.local_error_found=1'bz; step(pins,1,1);
      pins.local_error_found=0; step(pins,1,1);
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
  exdbin_mac dut(.alu_cmd(bus.pins.alu_cmd),.fxu_areg_q(bus.pins.fxu_areg_q),.fxu_breg_q(bus.pins.fxu_breg_q),.local_error_found(bus.pins.local_error_found),.bin_sum(bus.actual.bin_sum),.bin_ovfl(bus.actual.bin_ovfl));
  dvbench_model predictor(.alu_cmd(bus.pins.alu_cmd),.fxu_areg_q(bus.pins.fxu_areg_q),.fxu_breg_q(bus.pins.fxu_breg_q),.local_error_found(bus.pins.local_error_found),.bin_sum(bus.predicted.bin_sum),.bin_ovfl(bus.predicted.bin_ovfl));
  initial begin uvm_config_db#(virtual native_bus)::set(null,"*","bus",bus); run_test("dvbench_test"); end
  initial begin #5000000; `uvm_fatal("WATCHDOG","reference history did not terminate") end
endmodule
