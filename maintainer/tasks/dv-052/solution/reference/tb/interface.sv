`timescale 1ns/1ps
interface bench_if;
logic clk=0;always #5 clk=~clk;
logic [127:0] ciphertext;
logic [127:0] key10;
logic rst;
logic [127:0] plaintext;
logic [127:0] expected;logic valid=0;
endinterface
