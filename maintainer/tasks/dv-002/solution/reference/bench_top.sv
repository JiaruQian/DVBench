`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*; import bench_pkg::*;
bench_if vif();
omsp_alu  dut(.dbg_halt_st(vif.dbg_halt_st), .exec_cycle(vif.exec_cycle), .inst_alu(vif.inst_alu), .inst_bw(vif.inst_bw), .inst_jmp(vif.inst_jmp), .inst_so(vif.inst_so), .op_dst(vif.op_dst), .op_src(vif.op_src), .status(vif.status), .alu_out(vif.alu_out), .alu_out_add(vif.alu_out_add), .alu_stat(vif.alu_stat), .alu_stat_wr(vif.alu_stat_wr));
dvbench_model  predictor(.dbg_halt_st(vif.dbg_halt_st), .exec_cycle(vif.exec_cycle), .inst_alu(vif.inst_alu), .inst_bw(vif.inst_bw), .inst_jmp(vif.inst_jmp), .inst_so(vif.inst_so), .op_dst(vif.op_dst), .op_src(vif.op_src), .status(vif.status), .alu_out(vif.pred_alu_out), .alu_out_add(vif.pred_alu_out_add), .alu_stat(vif.pred_alu_stat), .alu_stat_wr(vif.pred_alu_stat_wr));
initial begin uvm_config_db#(virtual bench_if)::set(null,"*","vif",vif); run_test("dvbench_test"); end
endmodule
