`timescale 1ns/1ps
package native_types;
typedef struct packed {
    logic rst;
    logic [63:0] s_axis_a_tdata;
    logic s_axis_a_tvalid;
    logic s_axis_a_tlast;
    logic [63:0] s_axis_b_tdata;
    logic s_axis_b_tvalid;
    logic s_axis_b_tlast;
    logic m_axis_c_tready;
    logic [7:0] s_axil_awaddr;
    logic s_axil_awvalid;
    logic [31:0] s_axil_wdata;
    logic [3:0] s_axil_wstrb;
    logic s_axil_wvalid;
    logic s_axil_bready;
    logic [7:0] s_axil_araddr;
    logic s_axil_arvalid;
    logic s_axil_rready;
} stimulus_t;
typedef struct packed {
    logic s_axis_a_tready;
    logic s_axis_b_tready;
    logic [255:0] m_axis_c_tdata;
    logic m_axis_c_tvalid;
    logic m_axis_c_tlast;
    logic s_axil_awready;
    logic s_axil_wready;
    logic [1:0] s_axil_bresp;
    logic s_axil_bvalid;
    logic s_axil_arready;
    logic [31:0] s_axil_rdata;
    logic [1:0] s_axil_rresp;
    logic s_axil_rvalid;
    logic irq;
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
    task latched_channel_witnesses();
      stimulus_t pins;
      virtual native_bus witness_bus;
      if(!uvm_config_db#(virtual native_bus)::get(null,"*","bus",witness_bus))
        `uvm_fatal("WITNESS_CONFIG","Missing native interface")
      for(integer witness_kind=0;witness_kind<3;witness_kind++)begin
        pins='0;pins.rst=1;step(pins,3);
        pins.rst=0;pins.s_axil_bready=1;step(pins,2);
        if(witness_kind==0)begin
          pins.s_axil_awaddr=12;pins.s_axil_awvalid=1;step(pins);
          pins.s_axil_awvalid=0;pins.s_axil_awaddr=16;step(pins,3);
          pins.s_axil_wdata=1;pins.s_axil_wvalid=1;step(pins);
          pins.s_axil_wvalid=0;step(pins,4);
          pins.s_axil_araddr=12;pins.s_axil_arvalid=1;step(pins);
          pins.s_axil_arvalid=0;step(pins);
          if(witness_bus.predicted.s_axil_rvalid!==1'b1 || witness_bus.predicted.s_axil_rdata!==32'd1)
            `uvm_error("AW_NONVACUITY","Accepted AW must retain IRQ address after live AWADDR changes")
        end else if(witness_kind==1)begin
          pins.s_axil_wdata=1;pins.s_axil_wvalid=1;step(pins);
          pins.s_axil_wvalid=0;pins.s_axil_wdata=0;step(pins,3);
          pins.s_axil_awaddr=12;pins.s_axil_awvalid=1;step(pins);
          pins.s_axil_awvalid=0;step(pins,4);
          pins.s_axil_araddr=12;pins.s_axil_arvalid=1;step(pins);
          pins.s_axil_arvalid=0;step(pins);
          if(witness_bus.predicted.s_axil_rvalid!==1'b1 || witness_bus.predicted.s_axil_rdata!==32'd1)
            `uvm_error("W_NONVACUITY","Accepted W must retain IRQ enable after live WDATA changes")
        end else begin
          pins.s_axil_araddr=16;pins.s_axil_arvalid=1;step(pins);
          pins.s_axil_arvalid=0;pins.s_axil_araddr=12;step(pins);
          if(witness_bus.predicted.s_axil_rvalid!==1'b1 || witness_bus.predicted.s_axil_rdata!==32'h10000)
            `uvm_error("AR_NONVACUITY","Accepted AR must retain VERSION address before response creation")
        end
        step(pins,3);
        pins.s_axil_rready=1;step(pins,3);
      end
    endtask
    task a_capacity_witness();
      stimulus_t pins;
      virtual native_bus witness_bus;
      if(!uvm_config_db#(virtual native_bus)::get(null,"*","bus",witness_bus))
        `uvm_fatal("CAPACITY_CONFIG","Missing native interface")
      pins='0;pins.rst=1;step(pins,3);
      pins.rst=0;pins.s_axil_bready=1;step(pins,2);
      pins.s_axil_awvalid=1;pins.s_axil_awaddr=0;
      pins.s_axil_wvalid=1;pins.s_axil_wdata=1;step(pins);
      pins.s_axil_awvalid=0;pins.s_axil_wvalid=0;step(pins,4);
      for(integer row_index=0;row_index<8;row_index++)begin
        pins.s_axis_a_tdata=0;pins.s_axis_b_tdata=0;
        pins.s_axis_a_tdata[row_index*8+:8]=1;
        for(integer column_index=0;column_index<8;column_index++)
          pins.s_axis_b_tdata[column_index*8+:8]=row_index*8+column_index+1;
        pins.s_axis_a_tvalid=1;pins.s_axis_b_tvalid=1;
        pins.s_axis_a_tlast=row_index==7;pins.s_axis_b_tlast=row_index==7;
        step(pins);
      end
      pins.s_axis_b_tvalid=0;pins.s_axis_a_tdata=0;pins.s_axis_a_tlast=0;
      step(pins,33);
      if(witness_bus.predicted.s_axis_a_tready!==1'b0 || witness_bus.predicted.m_axis_c_tvalid!==1'b1 || witness_bus.predicted.m_axis_c_tdata!==256'h0000000800000007000000060000000500000004000000030000000200000001)
        `uvm_error("CAPACITY_NONVACUITY","Unaccepted ninth A row must preserve the independently predicted first result row")
      pins.m_axis_c_tready=1;step(pins,8);
      pins.rst=1;step(pins,3);
      pins='0;step(pins,3);
    endtask
    task body();
      stimulus_t pins;

      integer random_seed;
      random_seed=1;void'($value$plusargs("ntb_random_seed=%d",random_seed));random_seed=$urandom(random_seed);
      pins='0;pins.rst=1;step(pins,3);pins.rst=0;step(pins,3);
      pins.s_axil_bready=1;pins.s_axil_rready=1;pins.m_axis_c_tready=1;
      pins.s_axil_awaddr=12;pins.s_axil_wdata=1;pins.s_axil_awvalid=1;pins.s_axil_wvalid=1;step(pins);
      pins.s_axil_awvalid=0;pins.s_axil_wvalid=0;step(pins,4);
      for(integer scenario=0;scenario<12;scenario++)begin
        pins.s_axil_awaddr=0;pins.s_axil_wdata=1;pins.s_axil_wstrb=scenario%16;
        pins.s_axil_awvalid=1;step(pins);pins.s_axil_awvalid=0;step(pins,2);
        pins.s_axil_wvalid=1;step(pins);pins.s_axil_wvalid=0;step(pins,4);
        for(integer row=0;row<8;row++)begin
          for(integer column=0;column<8;column++)begin
            pins.s_axis_a_tdata[column*8+:8]=(scenario==0)?(row==column):((scenario==1)?8'h80:$urandom);
            pins.s_axis_b_tdata[column*8+:8]=(scenario==0)?(row*8+column):((scenario==1)?8'h7f:$urandom);
          end
          pins.s_axis_a_tvalid=1;pins.s_axis_a_tlast=row==7;
          pins.s_axis_b_tvalid=(scenario%2==0);pins.s_axis_b_tlast=row==7;
          step(pins);pins.s_axis_a_tvalid=0;pins.s_axis_b_tvalid=0;
          if(scenario%3==0)step(pins,2);
        end
        pins.s_axis_a_tvalid=0;pins.s_axis_b_tvalid=0;step(pins,14);
        if(scenario%2==1)begin
          for(integer row=0;row<8;row++)begin
            for(integer column=0;column<8;column++)pins.s_axis_b_tdata[column*8+:8]=$urandom;
            pins.s_axis_b_tvalid=1;pins.s_axis_b_tlast=row==7;step(pins);
            pins.s_axis_b_tvalid=0;step(pins);
          end
        end
        for(integer cycle_index=0;cycle_index<65;cycle_index++)begin
          pins.m_axis_c_tready=(cycle_index%3!=0);step(pins);
        end
        pins.m_axis_c_tready=1;step(pins,10);
        for(integer register_index=0;register_index<6;register_index++)begin
          pins.s_axil_araddr=register_index*4;pins.s_axil_arvalid=1;pins.s_axil_rready=0;step(pins);
          pins.s_axil_arvalid=0;step(pins,3);pins.s_axil_rready=1;step(pins,2);
        end
        pins.s_axil_awaddr=4;pins.s_axil_wdata=2;pins.s_axil_awvalid=1;pins.s_axil_wvalid=1;step(pins);
        pins.s_axil_awvalid=0;pins.s_axil_wvalid=0;step(pins,5);
      end
      pins.s_axil_awaddr=0;pins.s_axil_wdata=1;pins.s_axil_awvalid=1;pins.s_axil_wvalid=1;step(pins);
      pins.s_axil_awvalid=0;pins.s_axil_wvalid=0;step(pins,6);
      pins.s_axis_a_tvalid=1;step(pins,3);pins.s_axis_a_tvalid=0;
      pins.s_axil_awaddr=0;pins.s_axil_wdata=2;pins.s_axil_awvalid=1;pins.s_axil_wvalid=1;step(pins);
      pins.s_axil_awvalid=0;pins.s_axil_wvalid=0;step(pins,6);
      pins.s_axil_araddr=8;pins.s_axil_arvalid=1;step(pins);pins.s_axil_arvalid=0;step(pins,5);
      pins.rst=1;step(pins,3);pins.rst=0;step(pins,5);
      latched_channel_witnesses();
      a_capacity_witness();

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
        if(!bus.actual.m_axis_c_tvalid) mask.m_axis_c_tdata=0; if(!bus.actual.s_axil_rvalid)mask.s_axil_rdata=0;
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
  systolic_top dut(.clk(bus.clock),.rst(bus.pins.rst),.s_axis_a_tdata(bus.pins.s_axis_a_tdata),.s_axis_a_tvalid(bus.pins.s_axis_a_tvalid),.s_axis_a_tready(bus.actual.s_axis_a_tready),.s_axis_a_tlast(bus.pins.s_axis_a_tlast),.s_axis_b_tdata(bus.pins.s_axis_b_tdata),.s_axis_b_tvalid(bus.pins.s_axis_b_tvalid),.s_axis_b_tready(bus.actual.s_axis_b_tready),.s_axis_b_tlast(bus.pins.s_axis_b_tlast),.m_axis_c_tdata(bus.actual.m_axis_c_tdata),.m_axis_c_tvalid(bus.actual.m_axis_c_tvalid),.m_axis_c_tready(bus.pins.m_axis_c_tready),.m_axis_c_tlast(bus.actual.m_axis_c_tlast),.s_axil_awaddr(bus.pins.s_axil_awaddr),.s_axil_awvalid(bus.pins.s_axil_awvalid),.s_axil_awready(bus.actual.s_axil_awready),.s_axil_wdata(bus.pins.s_axil_wdata),.s_axil_wstrb(bus.pins.s_axil_wstrb),.s_axil_wvalid(bus.pins.s_axil_wvalid),.s_axil_wready(bus.actual.s_axil_wready),.s_axil_bresp(bus.actual.s_axil_bresp),.s_axil_bvalid(bus.actual.s_axil_bvalid),.s_axil_bready(bus.pins.s_axil_bready),.s_axil_araddr(bus.pins.s_axil_araddr),.s_axil_arvalid(bus.pins.s_axil_arvalid),.s_axil_arready(bus.actual.s_axil_arready),.s_axil_rdata(bus.actual.s_axil_rdata),.s_axil_rresp(bus.actual.s_axil_rresp),.s_axil_rvalid(bus.actual.s_axil_rvalid),.s_axil_rready(bus.pins.s_axil_rready),.irq(bus.actual.irq));
  dvbench_model predictor(.clk(bus.clock),.rst(bus.pins.rst),.s_axis_a_tdata(bus.pins.s_axis_a_tdata),.s_axis_a_tvalid(bus.pins.s_axis_a_tvalid),.s_axis_a_tready(bus.predicted.s_axis_a_tready),.s_axis_a_tlast(bus.pins.s_axis_a_tlast),.s_axis_b_tdata(bus.pins.s_axis_b_tdata),.s_axis_b_tvalid(bus.pins.s_axis_b_tvalid),.s_axis_b_tready(bus.predicted.s_axis_b_tready),.s_axis_b_tlast(bus.pins.s_axis_b_tlast),.m_axis_c_tdata(bus.predicted.m_axis_c_tdata),.m_axis_c_tvalid(bus.predicted.m_axis_c_tvalid),.m_axis_c_tready(bus.pins.m_axis_c_tready),.m_axis_c_tlast(bus.predicted.m_axis_c_tlast),.s_axil_awaddr(bus.pins.s_axil_awaddr),.s_axil_awvalid(bus.pins.s_axil_awvalid),.s_axil_awready(bus.predicted.s_axil_awready),.s_axil_wdata(bus.pins.s_axil_wdata),.s_axil_wstrb(bus.pins.s_axil_wstrb),.s_axil_wvalid(bus.pins.s_axil_wvalid),.s_axil_wready(bus.predicted.s_axil_wready),.s_axil_bresp(bus.predicted.s_axil_bresp),.s_axil_bvalid(bus.predicted.s_axil_bvalid),.s_axil_bready(bus.pins.s_axil_bready),.s_axil_araddr(bus.pins.s_axil_araddr),.s_axil_arvalid(bus.pins.s_axil_arvalid),.s_axil_arready(bus.predicted.s_axil_arready),.s_axil_rdata(bus.predicted.s_axil_rdata),.s_axil_rresp(bus.predicted.s_axil_rresp),.s_axil_rvalid(bus.predicted.s_axil_rvalid),.s_axil_rready(bus.pins.s_axil_rready),.irq(bus.predicted.irq));
  initial begin uvm_config_db#(virtual native_bus)::set(null,"*","bus",bus); run_test("dvbench_test"); end
  initial begin #5000000; `uvm_fatal("WATCHDOG","reference history did not terminate") end
endmodule
