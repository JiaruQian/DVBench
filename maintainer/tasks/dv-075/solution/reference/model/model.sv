// Independent byte-queue predictor. No DUT instance, outputs, or golden traces.
module dvbench_model #(
 parameter ADDRESS_BITS=32, LENGTH_BITS=32, MAX_BURST=256,
 parameter STREAM_BIG_ENDIAN="TRUE", MEM_BIG_ENDIAN="TRUE"
)(input aclk,aresetn,
 input [ADDRESS_BITS-1:0] cmd_address,input [LENGTH_BITS-1:0] cmd_bytes,input cmd_valid,output logic cmd_ready,
 output logic [3:0] axi_m_arid,output logic [ADDRESS_BITS-1:0] axi_m_araddr,
 output logic [7:0] axi_m_arlen,output logic [2:0] axi_m_arsize,output logic [1:0] axi_m_arburst,
 output logic axi_m_arvalid,input axi_m_arready,
 input [3:0] axi_m_rid,input [31:0] axi_m_rdata,input [1:0] axi_m_rresp,input axi_m_rlast,axi_m_rvalid,
 output wire axi_m_rready,output wire [31:0] dout_tdata,output wire [3:0] dout_tkeep,
 output wire dout_tlast,dout_tvalid,input dout_tready);
 typedef struct packed {logic last;logic [3:0] keep;logic [31:0] data;} beat;
 beat storage[16], peek, stage;
 byte unsigned bytes_q[$];
 int wp,rp,rs1,rs2,ws1,ws2;
 bit full,empty,busy,stage_valid,stage_last,tail;
 int phase,remain,fetch,words,index,off,nb,phase_next;
 logic [LENGTH_BITS-1:0] span;
 bit [3:0] mask;
 int wn,rn,oldwp,oldrp,newsize,take;
 bit accept,consume,reload,final_input,oldtail,oldvalid,oldlast;
 byte unsigned discard;
 assign axi_m_rready=busy&&!full;
 assign dout_tvalid=!empty;
 assign dout_tdata=peek.data;
 assign dout_tkeep=peek.keep;
 assign dout_tlast=peek.last;
 always @(posedge aclk or negedge aresetn) begin
  if(!aresetn) begin
   cmd_ready=1;axi_m_arid=0;axi_m_araddr='x;axi_m_arlen='x;
   axi_m_arsize=2;axi_m_arburst=1;axi_m_arvalid=0;
   phase=0;remain=0;fetch=0;words=0;index=0;off=0;nb=0;
   wp=0;rp=0;rs1=0;rs2=0;ws1=0;ws2=0;full=0;empty=1;peek='0;
   busy=0;stage_valid=0;stage_last=0;tail=0;stage='0;bytes_q.delete();
  end else begin
   // Observable address scheduling, including the initial setup intervals.
   phase_next=phase;
   case(phase)
    0: if(cmd_valid) phase_next=1;
    1: phase_next=(remain!=0)?2:0;
    2: phase_next=3;
    3: if(axi_m_arready) phase_next=4;
    4: phase_next=(remain!=0)?2:5;
    5: if(!empty&&peek.last&&dout_tready) phase_next=0;
   endcase
   accept=axi_m_rvalid&&busy&&!full;
   consume=stage_valid&&!full;
   final_input=(index==words-1);
   oldtail=tail;oldvalid=stage_valid;oldlast=stage_last;
   reload=!busy&&(!stage_valid||(stage_last&&!full));
   // FIFO timing is modeled by ordinal pointers and two synchronization delays,
   // without Gray coding, DUT storage, or internal hierarchy.
   oldwp=wp;oldrp=rp;
   wn=(wp+(consume?1:0))%32;
   rn=(rp+((!empty&&dout_tready)?1:0))%32;
   peek=storage[rn%16];
   if(consume) storage[wp%16]=stage;
   full=(((wn-rs2+32)%32)==16);empty=(rn==ws2);
   rs2=rs1;rs1=oldrp;ws2=ws1;ws1=oldwp;wp=wn;rp=rn;
   // Queue transformation selects physical byte lanes using the public masks.
   if(consume) begin
    take=(bytes_q.size()>4)?4:bytes_q.size();
    repeat(take) discard=bytes_q.pop_front();
   end
   if(accept) begin
    mask=15;
    if(index==0) begin
     mask=0;
     for(int k=off;k<4;k++) if(words!=1 || nb%4==0 || k<off+(nb%4)) mask[k]=1;
    end else if(final_input) begin
     take=(off+nb)%4;mask=(take==0)?15:((1<<take)-1);
    end
    for(int j=0;j<4;j++) begin
     take=(MEM_BIG_ENDIAN=="TRUE")?3-j:j;
     if(mask[take]) bytes_q.push_back(axi_m_rdata[8*take+:8]);
    end
   end
   newsize=bytes_q.size();
   if(accept&&final_input&&newsize>4)tail=1;
   else if(consume&&oldlast)tail=0;
   stage_valid=(newsize>=4)||(accept&&final_input)||(newsize>0&&oldtail);
   if(!(newsize>=4 || accept&&final_input || newsize>0&&oldtail) && !consume)
    stage_valid=oldvalid;
   if(accept&&final_input&&newsize<=4)stage_last=1;
   else if(consume)stage_last=(!oldlast&&oldtail);
   stage.data=0;stage.keep=0;stage.last=stage_last;
   for(int j=0;j<4&&j<newsize;j++) begin
    take=(STREAM_BIG_ENDIAN=="TRUE")?3-j:j;
    stage.data[8*take+:8]=bytes_q[j];stage.keep[take]=1;
   end
   if(accept&&final_input)busy=0;
   else if(axi_m_rvalid&&(!oldtail||(consume&&oldlast)))busy=1;
   if(reload)bytes_q.delete();
   if(phase_next==1) begin
    off=cmd_address%4;nb=cmd_bytes;
    span=(cmd_bytes==0)?0:cmd_bytes+off;
    words=(span>>2)+((span%4)!=0);remain=words;index=0;
    axi_m_araddr=(cmd_address>>2)<<2;cmd_ready=0;
   end else if(accept)index++;
   case(phase_next)
    0: cmd_ready=1;
    2: fetch=(remain>MAX_BURST)?MAX_BURST:remain;
    3: begin axi_m_arvalid=1;axi_m_arlen=fetch-1;end
    4: begin axi_m_arvalid=0;axi_m_araddr+=4*fetch;remain-=fetch;end
   endcase
   phase=phase_next;
  end
 end
endmodule
