`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;
import timer_pkg::*;
timer_if vif();
always #5 vif.HCLK=~vif.HCLK;
apb_timer_unit dut(.HCLK(vif.HCLK),.HRESETn(vif.HRESETn),.PADDR(vif.PADDR),.PWDATA(vif.PWDATA),.PWRITE(vif.PWRITE),.PSEL(vif.PSEL),.PENABLE(vif.PENABLE),.dft_cg_enable_i(vif.dft_cg_enable_i),.ref_clk_i(vif.ref_clk_i),.event_lo_i(vif.event_lo_i),.event_hi_i(vif.event_hi_i),.PRDATA(vif.PRDATA),.PREADY(vif.PREADY),.PSLVERR(vif.PSLVERR),.timer_val_lo_o(vif.timer_val_lo_o),.irq_lo_o(vif.irq_lo_o),.irq_hi_o(vif.irq_hi_o),.busy_o(vif.busy_o));
dvbench_model predictor(.HCLK(vif.HCLK),.HRESETn(vif.HRESETn),.PADDR(vif.PADDR),.PWDATA(vif.PWDATA),.PWRITE(vif.PWRITE),.PSEL(vif.PSEL),.PENABLE(vif.PENABLE),.dft_cg_enable_i(vif.dft_cg_enable_i),.ref_clk_i(vif.ref_clk_i),.event_lo_i(vif.event_lo_i),.event_hi_i(vif.event_hi_i),.PRDATA(vif.expected_PRDATA),.PREADY(vif.expected_PREADY),.PSLVERR(vif.expected_PSLVERR),.timer_val_lo_o(vif.expected_timer_val_lo_o),.irq_lo_o(vif.expected_irq_lo_o),.irq_hi_o(vif.expected_irq_hi_o),.busy_o(vif.expected_busy_o));
initial begin uvm_config_db#(virtual timer_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
