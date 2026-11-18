`timescale 1ns/1ps
module dvbench_model(input logic clka,
input logic rsta,
input logic [0:0] wea,
input logic [7:0] addra,
input logic [23:0] dina,
output logic [23:0] douta,
input logic clkb,
input logic rstb,
input logic [0:0] web,
input logic [7:0] addrb,
input logic [23:0] dinb,
output logic [23:0] doutb,
output logic rsta_busy,
output logic rstb_busy);
logic [23:0] storage [0:255];
integer edges_a=0, edges_b=0;
logic previous_a=0, older_a=0, previous_b=0, older_b=0;
initial begin
  for(integer address=0;address<256;address++) storage[address]=0;
  douta=0; doutb=0; rsta_busy=0; rstb_busy=0;
end
always @(posedge clka) begin
  rsta_busy <= rsta | (edges_a>=2 && edges_a<6) | previous_a | older_a;
  older_a <= previous_a; previous_a <= rsta | (edges_a>=2 && edges_a<6);
  if(wea) storage[addra] <= dina;
  if(rsta || (edges_a>=2 && edges_a<6)) douta<=0;
  else if(wea) douta<=dina; else douta<=storage[addra];
  edges_a <= edges_a+1;
end
always @(posedge clkb) begin
  rstb_busy <= rstb | (edges_b>=2 && edges_b<6) | previous_b | older_b;
  older_b <= previous_b; previous_b <= rstb | (edges_b>=2 && edges_b<6);
  if(web) storage[addrb] <= dinb;
  if(rstb || (edges_b>=2 && edges_b<6)) doutb<=0;
  else if(web) doutb<=dinb; else doutb<=storage[addrb];
  edges_b <= edges_b+1;
end
endmodule
