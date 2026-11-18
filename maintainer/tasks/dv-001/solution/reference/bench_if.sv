`timescale 1ns/1ps
interface bench_if;
logic [1:0] screen;
logic [2:0] opcode;
logic [3:0] A;
logic [3:0] B;
logic carry_in;
logic carry_out;
logic overflow;
logic [11:0] bcd;
logic error;
logic pred_carry_out;
logic pred_overflow;
logic [11:0] pred_bcd;
logic pred_error;
event sampled; logic active=0;
endinterface
