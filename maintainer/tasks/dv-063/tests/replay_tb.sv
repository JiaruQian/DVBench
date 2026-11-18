`timescale 1ns/1ps
module replay_tb;import dvbench_stim::*;
logic clk;
logic rst;
logic load;
logic start;
logic [127:0] key;
logic [127:0] iv;
logic [127:0] iBlock;
logic [127:0] oBlock;
logic idle;
logic [386:0] pins;
assign {rst,load,start,key,iv,iBlock}=pins;
REPLAY_TARGET dut(.clk(clk),.rst(rst),.load(load),.start(start),.key(key),.iv(iv),.iBlock(iBlock),.oBlock(oBlock),.idle(idle));
initial begin clk=0;forever #5 clk=~clk;end
initial begin int seed;if(!$value$plusargs("ntb_random_seed=%d",seed))seed=1;
for(int k=0;k<6000;k++)begin @(negedge clk);pins=sample_pins(k,seed);#2;$display("HISTORY %h",pins);$display("TRACE %h",{oBlock,idle});@(posedge clk);#2;$display("HISTORY %h",pins);$display("TRACE %h",{oBlock,idle});end
$display("REPLAY_COMPLETED");$finish;end
endmodule
