`timescale 1ns/1ps
module dvbench_top;logic clock_i=0;always #5 clock_i=~clock_i;logic[514:0]drive_inputs=0;wire[193:0]observed;logic[193:0]mask;
logic resetb_i;
logic start_i;
logic data_valid_i;
logic[0:4][63:0] state_i;
logic[127:0] key_i;
logic[63:0] data_i;
wire end_o;
wire cipher_valid_o;
wire[63:0] cipher_o;
wire[127:0] tag_o;
assign {resetb_i,start_i,data_valid_i,state_i,key_i,data_i}=drive_inputs;
`ifdef MODEL
dvbench_model dut(.resetb_i(resetb_i),.start_i(start_i),.data_valid_i(data_valid_i),.state_i(state_i),.key_i(key_i),.data_i(data_i),.end_o(end_o),.cipher_valid_o(cipher_valid_o),.cipher_o(cipher_o),.tag_o(tag_o),.clock_i(clock_i));
`else
ascon_top dut(.resetb_i(resetb_i),.start_i(start_i),.data_valid_i(data_valid_i),.state_i(state_i),.key_i(key_i),.data_i(data_i),.end_o(end_o),.cipher_valid_o(cipher_valid_o),.cipher_o(cipher_o),.tag_o(tag_o),.clock_i(clock_i));
`endif
assign observed={end_o,cipher_valid_o,cipher_o,tag_o};
always_comb begin mask={(observed[193]!==1'bx),(observed[192]!==1'bx),{64{observed[192]===1'b1}},{128{observed[193]===1'b1}}};for(int j=0;j<128;j++)if(observed[j]===1'bx)mask[j]=0;end
int fd,inp,point=0;task sample;point++;$fdisplay(fd,"%0d %h %h",point,observed,mask);endtask
task drive(input logic[514:0]d);@(negedge clock_i);drive_inputs=d;#1;$fdisplay(inp,"%h",d);sample();@(posedge clock_i);#1;sample();#1;endtask
`include "stimulus.svh"
initial begin fd=$fopen("trace.txt","w");inp=$fopen("inputs.txt","w");history();$fclose(fd);$fclose(inp);$finish;end
endmodule
