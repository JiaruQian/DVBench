`timescale 1ns/1ps
interface aes_if;
logic[127:0] in;logic[255:0] Key;logic[5:0] counter,maxRound;logic clk=0;
wire[127:0] out,expected;bit valid;integer phase_id;event sampled;
endinterface
