`timescale 1ns/1ps
interface firmware_bus;
logic i_clk=0;
logic i_rstn=0;
logic [31:0] input_data=0;
wire result_valid;
wire [31:0] result_data;
wire expected_valid;
wire [31:0] expected_data;
endinterface

package firmware_reference_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

class firmware_item extends uvm_sequence_item;
`uvm_object_utils(firmware_item)
int session;
int cycles;
function new(string name="firmware_item");super.new(name);endfunction
endclass

class firmware_sequence extends uvm_sequence#(firmware_item);
`uvm_object_utils(firmware_sequence)
function new(string name="firmware_sequence");super.new(name);endfunction
task body();
    firmware_item item;
    for (int session=0;session<48;session++) begin
        item=firmware_item::type_id::create("item");
        start_item(item);
        item.session=session;
        case(session%8)
            0:item.cycles=20;
            1:item.cycles=21;
            2:item.cycles=65;
            3:item.cycles=66;
            4:item.cycles=67;
            5:item.cycles=160;
            6:item.cycles=240;
            7:item.cycles=400;
        endcase
        finish_item(item);
    end
endtask
endclass

class firmware_driver extends uvm_driver#(firmware_item);
`uvm_component_utils(firmware_driver)
virtual firmware_bus bus;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual firmware_bus)::get(this,"","bus",bus))
        `uvm_fatal("CONFIG","missing bus")
endfunction
task run_phase(uvm_phase phase);
    firmware_item item;
    bus.i_rstn=1;
    #1;bus.i_rstn=0;
    repeat(3) @(negedge bus.i_clk);
    forever begin
        seq_item_port.get_next_item(item);
        bus.i_rstn=1;
        for(int edge_index=1;edge_index<=item.cycles;edge_index++) begin
            bus.input_data=$urandom;
            if(edge_index==21) begin
                case(item.session%6)
                    0:bus.input_data=0;
                    1:bus.input_data=32'hfffffffc;
                    2:bus.input_data=32'hffffffff;
                    3:bus.input_data=32'h7fffffff;
                    4:bus.input_data=32'h80000000;
                    5:bus.input_data=$urandom;
                endcase
            end
            @(negedge bus.i_clk);
        end
        #1;bus.i_rstn=0;
        #2;
        if(bus.result_valid!==0 || bus.result_data!==0)
            `uvm_error("ASYNC_RESET","outputs did not clear between clock edges")
        if(item.session%2) begin
            #1;bus.i_rstn=1;
        end else begin
            repeat(3) @(negedge bus.i_clk);
        end
        seq_item_port.item_done();
    end
endtask
endclass

class firmware_sample extends uvm_sequence_item;
`uvm_object_utils(firmware_sample)
logic reset_n;
logic actual_valid,expected_valid;
logic [31:0] actual_data,expected_data;
function new(string name="firmware_sample");super.new(name);endfunction
endclass

class firmware_monitor extends uvm_component;
`uvm_component_utils(firmware_monitor)
virtual firmware_bus bus;
uvm_analysis_port#(firmware_sample) observed;
function new(string name,uvm_component parent);super.new(name,parent);observed=new("observed",this);endfunction
function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual firmware_bus)::get(this,"","bus",bus))
        `uvm_fatal("CONFIG","missing bus")
endfunction
task run_phase(uvm_phase phase);
    firmware_sample sample;
    forever begin
        @(posedge bus.i_clk);#1;
        sample=firmware_sample::type_id::create("sample");
        sample.reset_n=bus.i_rstn;
        sample.actual_valid=bus.result_valid;
        sample.actual_data=bus.result_data;
        sample.expected_valid=bus.expected_valid;
        sample.expected_data=bus.expected_data;
        observed.write(sample);
    end
endtask
endclass

class firmware_scoreboard extends uvm_subscriber#(firmware_sample);
`uvm_component_utils(firmware_scoreboard)
int checked=0;
int mismatches=0;
int expected_results=0;
int reset_samples=0;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void write(firmware_sample sample);
    checked++;
    if(sample.expected_valid===1) expected_results++;
    if(sample.reset_n===0) reset_samples++;
    if(sample.actual_valid!==sample.expected_valid || sample.actual_data!==sample.expected_data) begin
        mismatches++;
        if(mismatches<=20)
            `uvm_error("COMPARE",$sformatf("sample=%0d actual=%b/%h expected=%b/%h",checked,sample.actual_valid,sample.actual_data,sample.expected_valid,sample.expected_data))
    end
endfunction
function void check_phase(uvm_phase phase);
    if(checked<6000 || expected_results!=30 || reset_samples<20)
        `uvm_error("NONVACUITY",$sformatf("checked=%0d expected_results=%0d resets=%0d",checked,expected_results,reset_samples))
endfunction
function void report_phase(uvm_phase phase);
    $display("REFERENCE_PORT_COUNTS compared=%0d mismatches=%0d results=%0d resets=%0d",checked,mismatches,expected_results,reset_samples);
endfunction
endclass

class firmware_coverage extends uvm_subscriber#(firmware_sample);
`uvm_component_utils(firmware_coverage)
covergroup observations with function sample(logic reset_n,logic valid,logic [31:0] data);
    reset_state:coverpoint reset_n;
    result_event:coverpoint valid;
    result_patterns:coverpoint data iff(valid) {
        bins zero={0};bins low_value={3};bins signed_boundary={32'h80000003};
        bins other=default;
    }
endgroup
function new(string name,uvm_component parent);super.new(name,parent);observations=new();endfunction
function void write(firmware_sample sample);observations.sample(sample.reset_n,sample.actual_valid,sample.actual_data);endfunction
endclass

class firmware_agent extends uvm_agent;
`uvm_component_utils(firmware_agent)
firmware_driver driver;
firmware_monitor monitor;
uvm_sequencer#(firmware_item) sequencer;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);
    driver=firmware_driver::type_id::create("driver",this);
    monitor=firmware_monitor::type_id::create("monitor",this);
    sequencer=new("sequencer",this);
endfunction
function void connect_phase(uvm_phase phase);driver.seq_item_port.connect(sequencer.seq_item_export);endfunction
endclass

class firmware_env extends uvm_env;
`uvm_component_utils(firmware_env)
firmware_agent agent;
firmware_scoreboard scoreboard;
firmware_coverage coverage;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);
    agent=firmware_agent::type_id::create("agent",this);
    scoreboard=firmware_scoreboard::type_id::create("scoreboard",this);
    coverage=firmware_coverage::type_id::create("coverage",this);
endfunction
function void connect_phase(uvm_phase phase);
    agent.monitor.observed.connect(scoreboard.analysis_export);
    agent.monitor.observed.connect(coverage.analysis_export);
endfunction
endclass

class dvbench_test extends uvm_test;
`uvm_component_utils(dvbench_test)
firmware_env env;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);env=firmware_env::type_id::create("env",this);endfunction
task run_phase(uvm_phase phase);
    firmware_sequence sequence_all;
    phase.raise_objection(this);
    sequence_all=firmware_sequence::type_id::create("sequence_all");
    sequence_all.start(env.agent.sequencer);
    phase.drop_objection(this);
endtask
function void report_phase(uvm_phase phase);
    uvm_report_server server=uvm_report_server::get_server();
    if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)
        $display("DVBench_COMPLETED");
endfunction
endclass
endpackage

module dvbench_top;
import uvm_pkg::*;
import firmware_reference_pkg::*;
firmware_bus bus();
always #5 bus.i_clk=~bus.i_clk;
pipelined_riscv_core dut(.i_clk(bus.i_clk),.i_rstn(bus.i_rstn),.input_data(bus.input_data),.result_valid(bus.result_valid),.result_data(bus.result_data));
dvbench_model predictor(.i_clk(bus.i_clk),.i_rstn(bus.i_rstn),.input_data(bus.input_data),.result_valid(bus.expected_valid),.result_data(bus.expected_data));
initial begin
    uvm_config_db#(virtual firmware_bus)::set(null,"*","bus",bus);
    run_test("dvbench_test");
end
endmodule
