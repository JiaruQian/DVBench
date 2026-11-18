interface jpeg_native_if(input logic clk);
 logic rst_n=1,start=0;logic[1023:0]bs[3];logic[10:0]len[3];logic[12:0]block_num=1;
 wire[511:0]R,G,B,eR,eG,eB;wire done,edone,trig,etrig;wire[10:0]bits,ebits;
endinterface
