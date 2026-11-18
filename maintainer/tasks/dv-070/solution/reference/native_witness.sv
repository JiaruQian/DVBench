`timescale 1ns/1ps
interface elevator_bus;
  logic clk=0;
  always #5 clk=~clk;
  logic rst=1;
  logic [4:0] destinations=0;
  logic [26:0] actual;
endinterface
package elevator_witness_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    virtual elevator_bus bus;
    time released_at;
    int checks;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(virtual elevator_bus)::get(this,"","bus",bus))
        `uvm_fatal("CONFIG","missing native bus")
    endfunction
    task reset_run(bit[4:0] destinations);
      @(negedge bus.clk);#1;bus.rst=0;bus.destinations=0;
      #40;
      @(negedge bus.clk);#1;
      check_pins(27'h7ff0000,0,"asynchronous LED reset");
      bus.destinations=destinations;bus.rst=1;released_at=$time;
    endtask
    task at_tick(int tick_number);
      time target_time;
      target_time=released_at+5+(time'(1000000)+time'(tick_number-1)*2000002)*10;
      if(target_time<$time) `uvm_fatal("TIMELINE","nonmonotonic native witness")
      #(target_time-$time);
    endtask
    task check_pins(logic[26:0] mask,logic[26:0] expected,string label);
      checks++;
      if((bus.actual&mask)!==expected)
        `uvm_error("NATIVE_WITNESS",$sformatf("%s time=%0t actual=%h mask=%h expected=%h",label,$time,bus.actual,mask,expected))
    endtask
    task floor_view(logic[6:0] glyph,string label);
      wait(bus.actual[7:0]===8'hfe);#1;
      check_pins(27'h000fe00,{11'b0,glyph,9'b0},label);
    endtask
    task run_phase(uvm_phase phase);
      string profile;
      phase.raise_objection(this);
      void'($value$plusargs("witness=%s",profile));
      if(profile=="insertion") begin
        reset_run(5'b10000);
        at_tick(5);check_pins(27'h7fe0000,27'h4200000,"floor4 accepted");
        bus.destinations=5'b00010;
        at_tick(6);check_pins(27'h7fe0000,27'h4a40000,"upward floor1 insertion LEDs");
        reset_run(5'b10000);
        at_tick(5);bus.destinations=5'b01000;
        at_tick(6);check_pins(27'h7fe0000,27'h6300000,"upward floor3 insertion LEDs");
      end else if(profile=="travel") begin
        reset_run(5'b10000);
        at_tick(254);bus.destinations=5'b00100;
        at_tick(510);check_pins(27'h0010000,27'h0010000,"inserted floor2 stop busy");
        floor_view(7'b0010010,"floor2 during stop");
        at_tick(757);check_pins(27'h0010000,27'h0010000,"full second counting window");
      end else if(profile=="descent") begin
        reset_run(5'b00010);
        at_tick(506);floor_view(7'b1001111,"floor1 before return");
        bus.destinations=5'b00001;
        at_tick(508);check_pins(27'h0420000,27'h0420000,"floor0 inside/outside request pair");
        at_tick(760);floor_view(7'b0000001,"ordinary descending floor1 to0");
      end else if(profile=="ordinary_descent") begin
        reset_run(5'b00100);
        at_tick(760);floor_view(7'b0010010,"floor2 before ordinary return");
        bus.destinations=5'b00001;
        at_tick(762);check_pins(27'h0420000,27'h0420000,"floor0 return request pair");
        at_tick(1266);floor_view(7'b0000001,"ordinary descending floor1 to0");
      end else `uvm_fatal("PROFILE","explicit native witness required")
      if(checks<3) `uvm_error("VACUITY","missing native checks")
      phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      uvm_report_server server=uvm_report_server::get_server();
      `uvm_info("WITNESS_COUNT",$sformatf("checks=%0d",checks),UVM_LOW)
      if(checks>=3&&server.get_severity_count(UVM_ERROR)==0&&server.get_severity_count(UVM_FATAL)==0)
        $display("DVBench_COMPLETED");
    endfunction
  endclass
endpackage
module dvbench_top;
  import uvm_pkg::*;
  import elevator_witness_pkg::*;
  elevator_bus bus();
  top_module dut(.clk(bus.clk),.rst(bus.rst),.floor_0_p(1'b0),.floor_1_p(1'b0),.floor_2_p(1'b0),.floor_3_p(1'b0),.floor_4_p(1'b0),.floor_0_d(bus.destinations[0]),.floor_1_d(bus.destinations[1]),.floor_2_d(bus.destinations[2]),.floor_3_d(bus.destinations[3]),.floor_4_d(bus.destinations[4]),.direction_1(1'b1),.direction_2(1'b1),.direction_3(1'b1),.led_inside_4(bus.actual[26]),.led_inside_3(bus.actual[25]),.led_inside_2(bus.actual[24]),.led_inside_1(bus.actual[23]),.led_inside_0(bus.actual[22]),.led_outside_4(bus.actual[21]),.led_outside_3(bus.actual[20]),.led_outside_2(bus.actual[19]),.led_outside_1(bus.actual[18]),.led_outside_0(bus.actual[17]),.led_busy(bus.actual[16]),.a_out(bus.actual[15]),.b_out(bus.actual[14]),.c_out(bus.actual[13]),.d_out(bus.actual[12]),.e_out(bus.actual[11]),.f_out(bus.actual[10]),.g_out(bus.actual[9]),.p_out(bus.actual[8]),.an(bus.actual[7:0]));
  initial begin
    uvm_config_db#(virtual elevator_bus)::set(null,"*","bus",bus);
    run_test("dvbench_test");
  end
  initial begin #30000000000;`uvm_fatal("WATCHDOG","native timeline did not drain") end
endmodule
