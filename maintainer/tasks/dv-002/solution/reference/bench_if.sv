`timescale 1ns/1ps
interface bench_if;
logic dbg_halt_st;
logic exec_cycle;
logic [11:0] inst_alu;
logic inst_bw;
logic [7:0] inst_jmp;
logic [7:0] inst_so;
logic [15:0] op_dst;
logic [15:0] op_src;
logic [3:0] status;
logic [15:0] alu_out;
logic [15:0] alu_out_add;
logic [3:0] alu_stat;
logic [3:0] alu_stat_wr;
logic [15:0] pred_alu_out;
logic [15:0] pred_alu_out_add;
logic [3:0] pred_alu_stat;
logic [3:0] pred_alu_stat_wr;
event sampled; logic active=0;
endinterface
