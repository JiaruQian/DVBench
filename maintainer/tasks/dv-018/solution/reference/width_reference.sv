`timescale 1ns/1ps
interface width_bus;
  logic clock=0, rst_n=1, wr_vld=0, rd_ready=0, wr_last=0, wr_align_last=0;
  logic [7:0] wr_data=0;
  wire [10:0] actual[3], expected[3];
  always #5 clock=~clock;
endinterface

package width_reference_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    virtual width_bus bus;
    int comparisons=0, mismatches=0;
    function new(string name, uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(virtual width_bus)::get(this,"","bus",bus)) `uvm_fatal("CONFIG","Missing native interface")
    endfunction
    function void compare_outputs();
      for(int profile=0;profile<3;profile++) begin
        comparisons++;
        if(bus.actual[profile] !== bus.expected[profile]) begin
          mismatches++;
          if(mismatches<=12) `uvm_error("MISMATCH",$sformatf("profile=%0d input=%h/%b%b%b%b reset=%b actual=%h expected=%h",profile,bus.wr_data,bus.wr_vld,bus.rd_ready,bus.wr_last,bus.wr_align_last,bus.rst_n,bus.actual[profile],bus.expected[profile]))
        end
      end
    endfunction
    task send(bit valid_value, bit ready_value, bit last_value, bit align_value, bit[7:0] data_value);
      @(negedge bus.clock);
      bus.wr_vld=valid_value; bus.rd_ready=ready_value;
      bus.wr_last=last_value; bus.wr_align_last=align_value; bus.wr_data=data_value;
      #1; compare_outputs();
      @(posedge bus.clock); #1; compare_outputs();
    endtask
    task reset_native();
      @(negedge bus.clock); #2; bus.rst_n=0;
      #1; compare_outputs();
      @(negedge bus.clock); #2; bus.rst_n=1;
    endtask
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      reset_native();
      send(1,1,0,0,8'ha5); send(1,1,0,0,8'h5a);
      send(1,1,0,0,8'hbc); send(1,1,0,0,8'h6d);
      reset_native();
      send(1,1,0,1,8'ha5); send(1,1,0,0,8'h5a);
      reset_native();
      send(1,0,0,0,8'ha5); send(1,1,0,0,8'hb6);
      send(1,1,0,1,8'h5a);
      reset_native();
      send(1,1,1,0,8'ha5); send(1,1,1,0,8'hb6);
      for(int repetition=0;repetition<32;repetition++) begin
        for(int controls=0;controls<16;controls++) begin
          repeat(4) send(controls[3],controls[2],controls[1],controls[0],$urandom);
        end
        reset_native();
      end
      repeat(512) send($urandom_range(0,1),$urandom_range(0,1),$urandom_range(0,1),$urandom_range(0,1),$urandom);
      send(0,1,0,0,0);
      phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      `uvm_info("COUNTS",$sformatf("profiles=3 comparisons=%0d mismatches=%0d",comparisons,mismatches),UVM_LOW)
      if(comparisons<1000) `uvm_error("VACUITY","Insufficient native comparisons")
      if(mismatches==0 && comparisons>=1000) $display("DVBench_COMPLETED");
    endfunction
  endclass
endpackage

module dvbench_top;
  import uvm_pkg::*;
  import width_reference_pkg::*;
  width_bus bus();
  for(genvar profile=0;profile<3;profile++) begin: profiles
    localparam INPUT_WIDTH=profile==0?4:8;
    localparam OUTPUT_WIDTH=profile==1?4:8;
    wire [OUTPUT_WIDTH-1:0] data_actual,data_expected;
    wire valid_actual,last_actual,ready_actual,valid_expected,last_expected,ready_expected;
    width_convert #(.ISIZE(INPUT_WIDTH),.OSIZE(OUTPUT_WIDTH)) dut(.clock(bus.clock),.rst_n(bus.rst_n),.wr_data(bus.wr_data[INPUT_WIDTH-1:0]),.wr_vld(bus.wr_vld),.wr_ready(ready_actual),.wr_last(bus.wr_last),.wr_align_last(bus.wr_align_last),.rd_data(data_actual),.rd_vld(valid_actual),.rd_ready(bus.rd_ready),.rd_last(last_actual));
    dvbench_model #(.ISIZE(INPUT_WIDTH),.OSIZE(OUTPUT_WIDTH)) predictor(.clock(bus.clock),.rst_n(bus.rst_n),.wr_data(bus.wr_data[INPUT_WIDTH-1:0]),.wr_vld(bus.wr_vld),.wr_ready(ready_expected),.wr_last(bus.wr_last),.wr_align_last(bus.wr_align_last),.rd_data(data_expected),.rd_vld(valid_expected),.rd_ready(bus.rd_ready),.rd_last(last_expected));
    assign bus.actual[profile]={{(8-OUTPUT_WIDTH){1'b0}},data_actual,valid_actual,last_actual,ready_actual};
    assign bus.expected[profile]={{(8-OUTPUT_WIDTH){1'b0}},data_expected,valid_expected,last_expected,ready_expected};
  end
  initial begin
    uvm_config_db#(virtual width_bus)::set(null,"*","bus",bus);
    run_test("dvbench_test");
  end
  initial begin #1000000; `uvm_fatal("WATCHDOG","Reference failed to drain") end
endmodule
