`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;
import reference_pkg::*;
native_if bus();
watchdog_timer dut(.pclk(bus.pclk),.presetn(bus.presetn),.psel(bus.psel),.penable(bus.penable),.pwrite(bus.pwrite),.paddr(bus.paddr),.pwdata(bus.pwdata),.prdata(bus.prdata),.pready(bus.pready),.pslverr(bus.pslverr),.wdt_clk(bus.wdt_clk),.wdt_rstn(bus.wdt_rstn),.cpu_dbg_halt(bus.cpu_dbg_halt),.cpu_commit_pc(bus.cpu_commit_pc),.cpu_commit_valid(bus.cpu_commit_valid),.wdt_reset(bus.wdt_reset),.reset_scope(bus.reset_scope),.trace_event_id(bus.trace_event_id),.trace_data(bus.trace_data));
dvbench_model predictor_model(.pclk(bus.pclk),.presetn(bus.presetn),.psel(bus.psel),.penable(bus.penable),.pwrite(bus.pwrite),.paddr(bus.paddr),.pwdata(bus.pwdata),.prdata(bus.exp_prdata),.pready(bus.exp_pready),.pslverr(bus.exp_pslverr),.wdt_clk(bus.wdt_clk),.wdt_rstn(bus.wdt_rstn),.cpu_dbg_halt(bus.cpu_dbg_halt),.cpu_commit_pc(bus.cpu_commit_pc),.cpu_commit_valid(bus.cpu_commit_valid),.wdt_reset(bus.exp_wdt_reset),.reset_scope(bus.exp_reset_scope),.trace_event_id(bus.exp_trace_event_id),.trace_data(bus.exp_trace_data));
initial begin
  uvm_config_db#(virtual native_if)::set(null,"*","bus",bus);
  run_test("dvbench_test");
end
endmodule
