`timescale 1ns/1ps
module isolated_d;
 logic clock=0,reset=1,in_data_vld=0,suspend_0=0,suspend_1=0,suspend_2=0,hen=0,hwr_rd=0,hdrive=0;
 logic[7:0] in_data=0,hdata_w=0;
 logic[15:0] haddr=0;
 tri[7:0] hdata;
 wire error,in_suspend,data_vld_0,data_vld_1,data_vld_2;
 wire[7:0] data_0,data_1,data_2;
 assign hdata=hdrive?hdata_w:8'bz;
 dvbench_model model(.*);
 int file,trace_fd,n;
 real at_time,previous=0;
 logic nc,nr,nv,ns0,ns1,ns2,ne,nwr,nd;
 logic[7:0] ni,nw;
 logic[15:0] na;
 initial begin
   trace_fd=$fopen("replay.trace","w");
   file=$fopen("events.history","r");
   if(!file)$fatal(1,"Missing input-only history");
   while(!$feof(file))begin
     n=$fscanf(file,"%f %b %b %h %b %b %b %b %h %b %b %b %h\n",at_time,nc,nr,ni,nv,ns0,ns1,ns2,na,ne,nwr,nd,nw);
     if(n==13)begin
       #(at_time-previous);
       clock=nc;reset=nr;in_data=ni;in_data_vld=nv;suspend_0=ns0;suspend_1=ns1;suspend_2=ns2;haddr=na;hen=ne;hwr_rd=nwr;hdrive=nd;hdata_w=nw;
       previous=at_time;
       #0;
     end else if(n>0)$fatal(1,"Malformed input history");
   end
   #1;$display("NATIVE_TEST_PASS");$finish;
 end
 always @(clock)begin
   #2;
   if(trace_fd)$fdisplay(trace_fd,"%0.3f %b %b %b %b %b %h %b %h %b %h %b %b %h",$realtime,clock,reset,error,in_suspend,data_vld_0,data_0,data_vld_1,data_1,data_vld_2,data_2,hen,hwr_rd,hdata);
 end
endmodule
