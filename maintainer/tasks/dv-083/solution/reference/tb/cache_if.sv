interface cache_native_if;
 logic clk=0;always #5 clk=~clk;
 logic rst=0,sa=0,sx=0,sm=0,lq=0,sq=0,rr=0,flush=0;
 logic[31:0] ax=0,am=0,sd=0,rd=0;logic[3:0]be=0;
 wire stall,restart,req,refilling,estall,erestart,ereq,erefilling;
 wire[31:0]addr,data,eaddr,edata;
 integer trace_cycle=0;
 string trace_previous="",trace_current;
 always @(negedge clk)begin
  trace_cycle++;#1;
  trace_current=$sformatf("rst=%b sa=%b sx=%b sm=%b ax=%h am=%h lq=%b sq=%b sd=%h be=%h rr=%b rd=%h flush=%b",rst,sa,sx,sm,ax,am,lq,sq,sd,be,rr,rd,flush);
  if(trace_current!=trace_previous)begin
   $display("DVBench_NATIVE_DRIVE scope=%m cycle=%0d %s",trace_cycle,trace_current);
   trace_previous=trace_current;
  end
 end
 string sample_previous="",sample_current;
 always @(posedge clk)begin
  #2;sample_current=$sformatf("ctrl=%b address=%h data=%h",{stall,restart,req,refilling},addr,data);
  if(sample_current!=sample_previous)begin
   $display("DVBench_NATIVE_SAMPLE scope=%m cycle=%0d %s",trace_cycle,sample_current);
   sample_previous=sample_current;
  end
 end
endinterface
