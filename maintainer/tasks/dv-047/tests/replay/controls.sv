module zero_model(input[127:0] in,input[255:0] Key,input[5:0] counter,input clk,output[127:0] out,input[5:0] maxRound);assign out=0;endmodule
module delay_model(input[127:0] in,input[255:0] Key,input[5:0] counter,input clk,output reg[127:0] out,input[5:0] maxRound);
wire[127:0] correct;dvbench_model m(.out(correct),.*);always @(posedge clk)out<=correct;endmodule
