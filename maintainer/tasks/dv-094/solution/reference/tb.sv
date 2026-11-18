`timescale 1ns/1ps
package native_types;
typedef struct packed {
    logic i_ntt_presetn;
    logic [7:0] i_ntt_paddr;
    logic i_ntt_psel;
    logic i_ntt_penable;
    logic i_ntt_pwrite;
    logic [31:0] i_ntt_pwdata;
    logic [3:0] i_ntt_pstrb;
} stimulus_t;
typedef struct packed {
    logic [31:0] o_ntt_prdata;
    logic o_ntt_pready;
    logic o_ntt_pslverr;
    logic o_ntt_irq;
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

    task short_reset(stimulus_t pins);
      native_transaction transaction=native_transaction::type_id::create("short_reset");
      start_item(transaction); transaction.pins=pins; transaction.cycles=0; transaction.check_result=0; finish_item(transaction);
    endtask
    task hardened_histories();
      stimulus_t pins;
      pins='0;step(pins,2);pins.i_ntt_presetn=1;step(pins,2);
      pins.i_ntt_psel=1;pins.i_ntt_penable=1;pins.i_ntt_pwrite=1;pins.i_ntt_pstrb=3;
      for(int address_index=0;address_index<256;address_index++) begin
        pins.i_ntt_paddr=8;pins.i_ntt_pwdata=address_index;step(pins);
        pins.i_ntt_paddr=12;pins.i_ntt_pwdata=16'h1234;step(pins);
        pins.i_ntt_penable=0;step(pins,2);pins.i_ntt_penable=1;
      end
      for(int high_strobes=1;high_strobes<4;high_strobes++) begin
        pins.i_ntt_paddr=8;pins.i_ntt_pwrite=1;pins.i_ntt_pstrb=1;pins.i_ntt_pwdata=high_strobes;step(pins);
        pins.i_ntt_paddr=12;pins.i_ntt_pstrb=3;pins.i_ntt_pwdata=16'h1234;step(pins);
        pins.i_ntt_penable=0;step(pins,2);pins.i_ntt_penable=1;
        pins.i_ntt_paddr=12;pins.i_ntt_pstrb=3;pins.i_ntt_pwdata=16'habcd;step(pins);
        pins.i_ntt_pstrb=high_strobes<<2;pins.i_ntt_pwdata=32'hff00ee00;step(pins);
        pins.i_ntt_pwrite=0;pins.i_ntt_pstrb=0;step(pins,2,1);
      end
      for(int mode_index=0;mode_index<4;mode_index++) begin
        pins='0;step(pins,2);pins.i_ntt_presetn=1;step(pins);
        pins.i_ntt_psel=1;pins.i_ntt_penable=1;pins.i_ntt_pwrite=1;pins.i_ntt_pstrb=1;
        pins.i_ntt_paddr=0;pins.i_ntt_pwdata=(mode_index<<1)|1;step(pins);
        pins.i_ntt_pwrite=0;pins.i_ntt_paddr=4;step(pins,12);
        pins.i_ntt_pwrite=1;pins.i_ntt_paddr=8;pins.i_ntt_pwdata=255;step(pins);
        pins.i_ntt_pwrite=0;pins.i_ntt_paddr=8;pins.i_ntt_penable=0;pins.i_ntt_presetn=0;short_reset(pins);
        pins.i_ntt_presetn=1;step(pins,2,1);
        pins.i_ntt_paddr=0;step(pins,1,1);
        pins.i_ntt_paddr=4;step(pins,1,1);
      end
    endtask

    task body();
      stimulus_t pins;

      integer random_seed;
      random_seed=1;void'($value$plusargs("ntb_random_seed=%d",random_seed));random_seed=$urandom(random_seed);
      pins='0;step(pins,3);pins.i_ntt_presetn=1;step(pins,3);
      pins.i_ntt_psel=1;pins.i_ntt_penable=1;pins.i_ntt_pwrite=1;pins.i_ntt_pstrb=15;
      for(integer scenario=0;scenario<3;scenario++) begin
        for(integer address_index=0;address_index<256;address_index++) begin
          pins.i_ntt_paddr=8;pins.i_ntt_pwdata=address_index;step(pins);
          pins.i_ntt_paddr=12;
          case(scenario)
            0:pins.i_ntt_pwdata=(address_index*137+3329);
            1:pins.i_ntt_pwdata=$urandom;
            2:pins.i_ntt_pwdata=address_index==0?1:0;
          endcase
          step(pins);pins.i_ntt_penable=0;step(pins);pins.i_ntt_penable=1;
        end
        pins.i_ntt_paddr=0;pins.i_ntt_pwdata=11;step(pins);
        pins.i_ntt_pwrite=0;pins.i_ntt_paddr=4;step(pins,5);
        pins.i_ntt_paddr=12;step(pins,2);
        pins.i_ntt_paddr=0;pins.i_ntt_pwrite=1;pins.i_ntt_pwdata=3;step(pins);
        pins.i_ntt_pwrite=0;pins.i_ntt_paddr=4;step(pins,5140);
        for(integer address_index=0;address_index<256;address_index++)begin
          pins.i_ntt_pwrite=1;pins.i_ntt_paddr=8;pins.i_ntt_pwdata=address_index;step(pins);
          pins.i_ntt_pwrite=0;pins.i_ntt_paddr=12;step(pins);
        end
        pins.i_ntt_pwrite=1;pins.i_ntt_paddr=0;pins.i_ntt_pwdata=10;step(pins);
      end
      for(integer mode_index=0;mode_index<4;mode_index++)begin
        pins.i_ntt_paddr=0;pins.i_ntt_pwrite=1;pins.i_ntt_pwdata=(mode_index<<1)|9;step(pins);
        pins.i_ntt_pwrite=0;pins.i_ntt_paddr=4;step(pins,5150);
      end
      pins.i_ntt_pwrite=1;pins.i_ntt_paddr=8;pins.i_ntt_pwdata=17;step(pins);
      pins.i_ntt_paddr=12;pins.i_ntt_pwdata=16'hac35;pins.i_ntt_pstrb=1;step(pins);
      pins.i_ntt_penable=0;step(pins);pins.i_ntt_penable=1;
      pins.i_ntt_pwrite=0;step(pins,2);
      pins.i_ntt_pwrite=1;pins.i_ntt_paddr=12;pins.i_ntt_pwdata=16'h4d00;pins.i_ntt_pstrb=2;step(pins);
      pins.i_ntt_penable=0;step(pins);pins.i_ntt_penable=1;pins.i_ntt_pwrite=0;step(pins,2);
      pins.i_ntt_paddr=3;step(pins);pins.i_ntt_paddr=255;step(pins);
      pins.i_ntt_pwrite=1;pins.i_ntt_paddr=0;pins.i_ntt_pstrb=15;pins.i_ntt_pwdata=3;step(pins);
      pins.i_ntt_pwrite=0;pins.i_ntt_paddr=4;step(pins,100);
      pins.i_ntt_presetn=0;step(pins,2);pins.i_ntt_presetn=1;step(pins,4);
      pins.i_ntt_pwrite=1;pins.i_ntt_paddr=8;pins.i_ntt_pwdata=17;step(pins);
      pins.i_ntt_pwrite=0;pins.i_ntt_paddr=12;step(pins,4);
      hardened_histories();

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
        if(req.cycles==0) begin
          #1; bus.pins.i_ntt_presetn=1; #1; ->bus.observe;
        end else repeat(req.cycles) begin @(posedge bus.clock); #1; ->bus.observe; end
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
    integer comparisons=0,changes=0,known_witnesses=0,reset_witnesses=0;
    observation_t previous_actual;
    covergroup observations with function sample(bit changed,bit mismatch);
      activity: coverpoint changed;
      comparison_result: coverpoint mismatch;
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent); observed=new("observed",this); observations=new; endfunction
    function void write(native_snapshot snapshot);
      bit mismatch;
      comparisons++;
      if(snapshot.pins.i_ntt_psel && !snapshot.pins.i_ntt_pwrite && snapshot.pins.i_ntt_paddr==12 && snapshot.predicted.o_ntt_prdata===32'h0000abcd) known_witnesses++;
      if(snapshot.pins.i_ntt_psel && !snapshot.pins.i_ntt_pwrite && snapshot.pins.i_ntt_paddr==8 && snapshot.predicted.o_ntt_prdata===0) reset_witnesses++;
      if((snapshot.actual&snapshot.mask)!==previous_actual) changes++;
      previous_actual=snapshot.actual&snapshot.mask;
      mismatch=((snapshot.actual&snapshot.mask)!==(snapshot.predicted&snapshot.mask));
      observations.sample(changes>0,mismatch);
      if(mismatch) `uvm_error("NATIVE_COMPARE",$sformatf("sample=%0d actual=%h expected=%h mask=%h inputs=%h",comparisons,snapshot.actual,snapshot.predicted,snapshot.mask,snapshot.pins))
    endfunction
    function void check_phase(uvm_phase phase);
      if(known_witnesses<3 || reset_witnesses<4) `uvm_error("PROBE_VACUITY","Missing independently predicted write-retention or reset witnesses")
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
  apb_ntt_wrapper dut(.i_ntt_pclk(bus.clock),.i_ntt_presetn(bus.pins.i_ntt_presetn),.i_ntt_paddr(bus.pins.i_ntt_paddr),.i_ntt_psel(bus.pins.i_ntt_psel),.i_ntt_penable(bus.pins.i_ntt_penable),.i_ntt_pwrite(bus.pins.i_ntt_pwrite),.i_ntt_pwdata(bus.pins.i_ntt_pwdata),.i_ntt_pstrb(bus.pins.i_ntt_pstrb),.o_ntt_prdata(bus.actual.o_ntt_prdata),.o_ntt_pready(bus.actual.o_ntt_pready),.o_ntt_pslverr(bus.actual.o_ntt_pslverr),.o_ntt_irq(bus.actual.o_ntt_irq));
  dvbench_model predictor(.i_ntt_pclk(bus.clock),.i_ntt_presetn(bus.pins.i_ntt_presetn),.i_ntt_paddr(bus.pins.i_ntt_paddr),.i_ntt_psel(bus.pins.i_ntt_psel),.i_ntt_penable(bus.pins.i_ntt_penable),.i_ntt_pwrite(bus.pins.i_ntt_pwrite),.i_ntt_pwdata(bus.pins.i_ntt_pwdata),.i_ntt_pstrb(bus.pins.i_ntt_pstrb),.o_ntt_prdata(bus.predicted.o_ntt_prdata),.o_ntt_pready(bus.predicted.o_ntt_pready),.o_ntt_pslverr(bus.predicted.o_ntt_pslverr),.o_ntt_irq(bus.predicted.o_ntt_irq));
  initial begin uvm_config_db#(virtual native_bus)::set(null,"*","bus",bus); run_test("dvbench_test"); end
  initial begin #5000000; `uvm_fatal("WATCHDOG","reference history did not terminate") end
endmodule
