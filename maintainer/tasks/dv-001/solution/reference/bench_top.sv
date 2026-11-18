`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*; import bench_pkg::*;
bench_if vif();
top  dut(.screen(vif.screen), .opcode(vif.opcode), .A(vif.A), .B(vif.B), .carry_in(vif.carry_in), .carry_out(vif.carry_out), .overflow(vif.overflow), .bcd(vif.bcd), .error(vif.error));
dvbench_model  predictor(.screen(vif.screen), .opcode(vif.opcode), .A(vif.A), .B(vif.B), .carry_in(vif.carry_in), .carry_out(vif.pred_carry_out), .overflow(vif.pred_overflow), .bcd(vif.pred_bcd), .error(vif.pred_error));
initial begin uvm_config_db#(virtual bench_if)::set(null,"*","vif",vif); run_test("dvbench_test"); end
endmodule
