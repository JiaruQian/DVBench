`timescale 1ns/1ps
module replay_top;
reg[127:0] in;reg[255:0] Key;reg[5:0] counter,maxRound;reg clk=0;
wire[127:0] out;
`IMPL u(.*);
integer f,rc,valid,n=0,p=0;string name;
initial begin
if(!$value$plusargs("VECTORS=%s",name))$fatal;
f=$fopen(name,"r");if(!f)$fatal;
while(!$feof(f))begin
rc=$fscanf(f,"%d %d %h %h %d\n",counter,maxRound,in,Key,valid);
if(rc==5)begin
#2;if(valid)begin $display("TRACE %0d %032h",p,out);n++;end p++;
#1;clk=1;#2;if(valid)begin $display("TRACE %0d %032h",p,out);n++;end p++;
#1;clk=0;
end end
$fclose(f);$display("D_REPLAY_COMPLETED %0d",n);$finish;end
endmodule
