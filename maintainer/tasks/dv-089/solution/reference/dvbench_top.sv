`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;
import cpu_reference_pkg::*;
cpu_bus bus();
initial bus.clk_i=0;
always #5 bus.clk_i=~bus.clk_i;
wire  exp_i_req_valid_o;
wire [31:0] exp_i_req_addr_o;
wire  exp_i_rsp_ready_o;
wire  exp_d_req_valid_o;
wire [31:0] exp_d_req_addr_o;
wire  exp_d_req_write_o;
wire [31:0] exp_d_req_wdata_o;
wire [3:0] exp_d_req_wstrb_o;
wire  exp_d_rsp_ready_o;
wire  exp_halted_o;
wire  exp_trap_o;
wire [7:0] exp_trap_cause_o;
wire [31:0] exp_trap_badaddr_o;
wire  exp_retire_valid_o;
wire [31:0] exp_retire_pc_o;
wire [31:0] exp_retire_instruction_o;
cpu_core dut(.clk_i(bus.clk_i),.rst_i(bus.rst_i),.i_req_valid_o(bus.i_req_valid_o),.i_req_ready_i(bus.i_req_ready_i),.i_req_addr_o(bus.i_req_addr_o),.i_rsp_valid_i(bus.i_rsp_valid_i),.i_rsp_ready_o(bus.i_rsp_ready_o),.i_rsp_rdata_i(bus.i_rsp_rdata_i),.i_rsp_error_i(bus.i_rsp_error_i),.d_req_valid_o(bus.d_req_valid_o),.d_req_ready_i(bus.d_req_ready_i),.d_req_addr_o(bus.d_req_addr_o),.d_req_write_o(bus.d_req_write_o),.d_req_wdata_o(bus.d_req_wdata_o),.d_req_wstrb_o(bus.d_req_wstrb_o),.d_rsp_valid_i(bus.d_rsp_valid_i),.d_rsp_ready_o(bus.d_rsp_ready_o),.d_rsp_rdata_i(bus.d_rsp_rdata_i),.d_rsp_error_i(bus.d_rsp_error_i),.timer_irq_i(bus.timer_irq_i),.external_irq_i(bus.external_irq_i),.halted_o(bus.halted_o),.trap_o(bus.trap_o),.trap_cause_o(bus.trap_cause_o),.trap_badaddr_o(bus.trap_badaddr_o),.retire_valid_o(bus.retire_valid_o),.retire_pc_o(bus.retire_pc_o),.retire_instruction_o(bus.retire_instruction_o));
dvbench_model predictor(.clk_i(bus.clk_i),.rst_i(bus.rst_i),.i_req_valid_o(bus.exp_i_req_valid_o),.i_req_ready_i(bus.i_req_ready_i),.i_req_addr_o(bus.exp_i_req_addr_o),.i_rsp_valid_i(bus.i_rsp_valid_i),.i_rsp_ready_o(bus.exp_i_rsp_ready_o),.i_rsp_rdata_i(bus.i_rsp_rdata_i),.i_rsp_error_i(bus.i_rsp_error_i),.d_req_valid_o(bus.exp_d_req_valid_o),.d_req_ready_i(bus.d_req_ready_i),.d_req_addr_o(bus.exp_d_req_addr_o),.d_req_write_o(bus.exp_d_req_write_o),.d_req_wdata_o(bus.exp_d_req_wdata_o),.d_req_wstrb_o(bus.exp_d_req_wstrb_o),.d_rsp_valid_i(bus.d_rsp_valid_i),.d_rsp_ready_o(bus.exp_d_rsp_ready_o),.d_rsp_rdata_i(bus.d_rsp_rdata_i),.d_rsp_error_i(bus.d_rsp_error_i),.timer_irq_i(bus.timer_irq_i),.external_irq_i(bus.external_irq_i),.halted_o(bus.exp_halted_o),.trap_o(bus.exp_trap_o),.trap_cause_o(bus.exp_trap_cause_o),.trap_badaddr_o(bus.exp_trap_badaddr_o),.retire_valid_o(bus.exp_retire_valid_o),.retire_pc_o(bus.exp_retire_pc_o),.retire_instruction_o(bus.exp_retire_instruction_o));
initial begin uvm_config_db#(virtual cpu_bus)::set(null,"*","bus",bus);run_test("dvbench_test");end
endmodule
