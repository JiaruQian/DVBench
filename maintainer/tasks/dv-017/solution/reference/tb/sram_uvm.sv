`timescale 1ns/1ps
interface sram_if #(int N=4,AW=12,DW=32)(input logic clk);

 logic rst_n=0;
 logic [N-1:0] req='0,wr='0;
 logic [AW-1:0] addr[N]='{default:'0};
 logic [DW-1:0] wd[N]='{default:'0},wm[N]='{default:'0};
 logic rv=0;
 logic [DW-1:0] rd='0;
 logic [1:0] err='0;
 logic [N-1:0] gnt,rvalid,egnt,ervalid;
 logic [DW-1:0] rdata[N],erdata[N];
 logic [1:0] error[N],eerror[N];
 logic sreq,swrite,esreq,eswrite;
 logic [AW-1:0] saddr,esaddr;
 logic [DW-1:0] swdata,swmask,eswdata,eswmask;
endinterface

package sram_uvm_pkg;
 import uvm_pkg::*;
 `include "uvm_macros.svh"
 int unsigned diagnostic_lines=0;
 class sram_tx #(int N=4,AW=12,DW=32) extends uvm_sequence_item;
  `uvm_object_param_utils(sram_tx #(N,AW,DW))
  bit rst_n=1;
  rand bit [N-1:0] req,wr;
  rand bit [AW-1:0] addr[N];
  rand bit [DW-1:0] wd[N],wm[N];
  rand bit rv;
  rand bit [DW-1:0] rd;
  rand bit [1:0] err;
  logic [N-1:0] gnt,rvalid,egnt,ervalid;
  logic [DW-1:0] rdata[N],erdata[N];
  logic [1:0] error[N],eerror[N];
  logic sreq,swrite,esreq,eswrite;
  logic [AW-1:0] saddr,esaddr;
  logic [DW-1:0] swdata,swmask,eswdata,eswmask;
  function new(string n="sram_tx");super.new(n);endfunction
 endclass
 class sram_driver #(int N=4,AW=12,DW=32) extends uvm_driver #(sram_tx #(N,AW,DW));
  `uvm_component_param_utils(sram_driver #(N,AW,DW))
  virtual sram_if #(N,AW,DW) vif;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   if(!uvm_config_db#(virtual sram_if #(N,AW,DW))::get(this,"","vif",vif))
    `uvm_fatal("NOVIF","driver vif missing")
  endfunction
  task run_phase(uvm_phase phase);
   sram_tx #(N,AW,DW) t;
   forever begin
    seq_item_port.get_next_item(t);@(negedge vif.clk);
    vif.rst_n=t.rst_n;vif.req=t.req;vif.wr=t.wr;
    vif.rv=t.rv;vif.rd=t.rd;vif.err=t.err;
    for(int p=0;p<N;p++)begin vif.addr[p]=t.addr[p];vif.wd[p]=t.wd[p];vif.wm[p]=t.wm[p];end
    #2;seq_item_port.item_done();
   end
  endtask
 endclass
 class sram_monitor #(int N=4,AW=12,DW=32) extends uvm_monitor;
  `uvm_component_param_utils(sram_monitor #(N,AW,DW))
  virtual sram_if #(N,AW,DW) vif;
  uvm_analysis_port #(sram_tx #(N,AW,DW)) ap;
  function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);endfunction
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   if(!uvm_config_db#(virtual sram_if #(N,AW,DW))::get(this,"","vif",vif))
    `uvm_fatal("NOVIF","monitor vif missing")
  endfunction
  task run_phase(uvm_phase phase);
   sram_tx #(N,AW,DW) t;
   forever begin
    @(negedge vif.clk);#1;t=new("observation");
    t.rst_n=vif.rst_n;
    t.req=vif.req;
    t.wr=vif.wr;
    t.rv=vif.rv;
    t.rd=vif.rd;
    t.err=vif.err;
    t.gnt=vif.gnt;
    t.rvalid=vif.rvalid;
    t.egnt=vif.egnt;
    t.ervalid=vif.ervalid;
    t.sreq=vif.sreq;
    t.swrite=vif.swrite;
    t.saddr=vif.saddr;
    t.swdata=vif.swdata;
    t.swmask=vif.swmask;
    t.esreq=vif.esreq;
    t.eswrite=vif.eswrite;
    t.esaddr=vif.esaddr;
    t.eswdata=vif.eswdata;
    t.eswmask=vif.eswmask;
    for(int p=0;p<N;p++)begin
     t.addr[p]=vif.addr[p];
     t.wd[p]=vif.wd[p];
     t.wm[p]=vif.wm[p];
     t.rdata[p]=vif.rdata[p];
     t.error[p]=vif.error[p];
     t.erdata[p]=vif.erdata[p];
     t.eerror[p]=vif.eerror[p];

    end
    ap.write(t);
   end
  endtask
 endclass
 class sram_scoreboard #(int N=4,AW=12,DW=32) extends uvm_subscriber #(sram_tx #(N,AW,DW));
  `uvm_component_param_utils(sram_scoreboard #(N,AW,DW))
  int unsigned samples=0,checks=0,commands=0,returns=0,errs=0;
  int unsigned pending=0,release_edges=0,first_read=0,full_pop_push=0;
  bit last_quiet=0;
  int unsigned req_count,winner_bin,occ_bin,error_bin,mask_bin,write_bin,reset_bin,rv_bin;
  bit first_read_bin,full_pop_push_bin;
  covergroup cg;
   option.per_instance=1;
   cp_req:coverpoint req_count {bins counts[]={[0:N]};}
   cp_winner:coverpoint winner_bin {bins ports[]={[0:N-1]};bins idle={N};}
   cp_occ:coverpoint occ_bin {bins levels[]={[0:4]};}
   cp_error:coverpoint error_bin {bins codes[]={[0:3]};}
   cp_mask:coverpoint mask_bin {bins zero={0};bins ones={1};bins mixed={2};}
   cp_write:coverpoint write_bin {bins read={0};bins write={1};}
   cp_reset:coverpoint reset_bin {bins asserted={0};bins released={1};}
   cp_rv:coverpoint rv_bin {bins low={0};bins high={1};}
   cp_first_read:coverpoint first_read_bin {bins hit={1};}
   cp_full_pop_push:coverpoint full_pop_push_bin {bins hit={1};}
   x_port_write:cross cp_winner,cp_write;
  endgroup
  function new(string n,uvm_component p);super.new(n,p);cg=new();endfunction
  function void fail(string field_name,string detail);
   errs++;
   diagnostic_lines++;
   `uvm_error("SRAM_COMPARE",{field_name,": ",detail})
  endfunction
  function void write(sram_tx #(N,AW,DW) t);
   bit under_rst,push_owner,pop_owner;
   int unsigned before_count;
   samples++;checks+=3+2*N;
   if(t.gnt!==t.egnt)fail("grant",$sformatf("actual=%b expected=%b req=%b",t.gnt,t.egnt,t.req));
   if(t.sreq!==t.esreq)fail("request",$sformatf("actual=%b expected=%b",t.sreq,t.esreq));
   if(t.rvalid!==t.ervalid)fail("response owner",$sformatf("actual=%b expected=%b rv=%b",t.rvalid,t.ervalid,t.rv));
   if(t.esreq)begin
    commands++;checks+=4;
    if(t.saddr!==t.esaddr)fail("address",$sformatf("actual=%h expected=%h",t.saddr,t.esaddr));
    if(t.swrite!==t.eswrite)fail("write",$sformatf("actual=%b expected=%b",t.swrite,t.eswrite));
    if(t.swdata!==t.eswdata)fail("write data",$sformatf("actual=%h expected=%h",t.swdata,t.eswdata));
    if(t.swmask!==t.eswmask)fail("write mask",$sformatf("actual=%h expected=%h",t.swmask,t.eswmask));
   end
   for(int p=0;p<N;p++)begin
    if(t.rdata[p]!==t.erdata[p])fail("broadcast data",$sformatf("port=%0d actual=%h expected=%h",p,t.rdata[p],t.erdata[p]));
    if(t.error[p]!==t.eerror[p])fail("broadcast error",$sformatf("port=%0d actual=%b expected=%b",p,t.error[p],t.eerror[p]));
   end
   if($isunknown(t.gnt)||!$onehot0(t.gnt))fail("protocol",$sformatf("grant not onehot0: %b",t.gnt));
   if((t.gnt&~t.req)!=='0)fail("protocol","grant outside request");
   if(t.sreq!==( |t.req))fail("protocol","request OR mismatch");
   req_count=$countones(t.req);winner_bin=N;
   for(int p=0;p<N;p++)if(t.egnt[p])winner_bin=p;
   occ_bin=pending;error_bin=t.err;
   mask_bin=(t.eswmask=='0)?0:((t.eswmask=='1)?1:2);
   write_bin=t.eswrite;reset_bin=t.rst_n;rv_bin=t.rv;
   first_read_bin=0;full_pop_push_bin=0;
   // This snapshot describes the following accepting posedge. Advance only
   // coverage/drain history now; next snapshot sees the completed posedge.
   if(!t.rst_n)begin pending=0;release_edges=0;end
   else begin
    before_count=pending;under_rst=(release_edges==0);release_edges++;
    first_read_bin=under_rst&&t.esreq&&!t.eswrite;
    full_pop_push_bin=!under_rst&&before_count==4&&t.rv&&t.esreq&&!t.eswrite;
    if(first_read_bin)first_read++;
    if(full_pop_push_bin)full_pop_push++;
    pop_owner=!under_rst&&before_count>0&&t.rv;
    push_owner=!under_rst&&before_count<4&&t.esreq&&!t.eswrite;
    pending=before_count+int'(push_owner)-int'(pop_owner);
    if(pop_owner)returns++;
   end
   cg.sample();last_quiet=t.rst_n&&pending==0&&t.req=='0&&!t.rv;
  endfunction
  function void check_phase(uvm_phase phase);
   super.check_phase(phase);
   if(samples<1200||commands==0||returns==0)fail("nonvacuity",$sformatf("samples=%0d commands=%0d returns=%0d",samples,commands,returns));
   if(first_read==0||full_pop_push==0)fail("directed coverage","missing warmup or full pop/push");
   if(pending!=0||!last_quiet)fail("drain",$sformatf("pending=%0d quiet=%b",pending,last_quiet));
  endfunction
  function void report_phase(uvm_phase phase);
   super.report_phase(phase);
   `uvm_info("SRAM_STATS",$sformatf("samples=%0d checks=%0d commands=%0d returns=%0d errors=%0d warmup=%0d full_pop_push=%0d pending=%0d functional_coverage=%0.2f",samples,checks,commands,returns,errs,first_read,full_pop_push,pending,cg.get_inst_coverage()),UVM_LOW)
  endfunction
 endclass
 class sram_agent #(int N=4,AW=12,DW=32) extends uvm_agent;
  `uvm_component_param_utils(sram_agent #(N,AW,DW))
  sram_driver #(N,AW,DW) drv;
  sram_monitor #(N,AW,DW) mon;
  uvm_sequencer #(sram_tx #(N,AW,DW)) sqr;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   drv=sram_driver #(N,AW,DW)::type_id::create("drv",this);
   mon=sram_monitor #(N,AW,DW)::type_id::create("mon",this);
   sqr=new("sqr",this);
  endfunction
  function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
 endclass
 class sram_env #(int N=4,AW=12,DW=32) extends uvm_env;
  `uvm_component_param_utils(sram_env #(N,AW,DW))
  sram_agent #(N,AW,DW) agent;
  sram_scoreboard #(N,AW,DW) sb;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   agent=sram_agent #(N,AW,DW)::type_id::create("agent",this);
   sb=sram_scoreboard #(N,AW,DW)::type_id::create("sb",this);
  endfunction
  function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);agent.mon.ap.connect(sb.analysis_export);
  endfunction
 endclass
 class sram_sequence #(int N=4,AW=12,DW=32) extends uvm_sequence #(sram_tx #(N,AW,DW));
  `uvm_object_param_utils(sram_sequence #(N,AW,DW))
  function new(string n="sram_sequence");super.new(n);endfunction
  function bit[N-1:0] one(int p);return 1<<p;endfunction
  task send(bit rn=1,bit[N-1:0] r='0,bit[N-1:0] w='0,bit rv=0,int abase=0,
            bit[DW-1:0] data='0,bit[DW-1:0] mask='1,
            bit[DW-1:0] response='0,bit[1:0] e=0);
   sram_tx #(N,AW,DW) t;
   t=new("directed");start_item(t);
   t.rst_n=rn;t.req=r;t.wr=w;t.rv=rv;t.rd=response;t.err=e;
   for(int p=0;p<N;p++)begin
    t.addr[p]=AW'(abase+17*p);t.wd[p]=data^DW'(32'h01020408*p);t.wm[p]=mask;
   end
   finish_item(t);
  endtask
  task clean_reset();send(0);send(0);send(1);send(1);endtask
  task body();
   sram_tx #(N,AW,DW) block_t,t;
   clean_reset();
   // First release-edge owner is discarded; second is accepted.
   send(0);send(0);
   send(1,one(0),'0,0,'h781);send(1,one(1),'0,0,'h782);
   send(1,'0,'0,1,0,'0,'1,32'hA1A2A3A4,1);
   send(1,'0,'0,1,0,'0,'1,32'hB1B2B3B4,2);send(1);
   clean_reset();
   send(1,one(0),one(0),0,0,32'h10203040);
   send(1,one(N-1),one(N-1),0,'h120,32'h50607080);send(1);
   clean_reset();
   send(1,one(0)|one(N-1),one(N-1),0,'h200,32'h12345678);send(1);
   clean_reset();
   send(1,one(0),one(0),0,'h300,32'hCAFEBABE);send(1);
   clean_reset();
   send(1,one(0),one(0),0,0,'0,'0);
   send(1,one(0),one(0),0,(1<<AW)-1,'1,'1);
   send(1,one(0),one(0),0,'h123,32'h55AA33CC,32'h00FF0FF0);
   send(1,one(N-1),one(N-1),0,'h321,32'hCC33AA55,32'hFF00F00F);send(1);
   clean_reset();
   send(1,one(0),'0,0,'h401);send(1,one(1),'0,0,'h402);
   send(1,'0,'0,1,0,'0,'1,32'h11223344,0);
   send(1,'0,'0,1,0,'0,'1,32'h55667788,3);
   send(1,'0,'0,1,0,'0,'1,32'h99AABBCC,2);send(1);
   // Full queue, overflow, full pop/push drop, then nonfull pop/push.
   clean_reset();
   for(int k=0;k<4;k++)send(1,one(k%N),'0,0,'h500+k);
   send(1,one(0),'0,0,'h510);
   send(1,one(1),'0,1,'h511,'0,'1,32'h01234567,1);
   send(1,one(0),'0,1,'h512,'0,'1,32'h89ABCDEF,2);
   for(int k=0;k<4;k++)send(1,'0,'0,1,0,'0,'1,32'hF0000000+k,2'(k));
   send(1);
   clean_reset();
   send(1,one(0),'0,0,'h601);send(1,one(1),'0,0,'h602);
   send(0,'1,'0,1,'h603,'0,'1,32'h33445566,3);
   send(0,one(N-1),one(N-1),0,'h604,32'h778899AA);
   send(1,one(0),'0,1,'h605,'0,'1,32'hBBCCDDEE,1);
   send(1,one(1),'0,0,'h606);
   send(1,'0,'0,1,0,'0,'1,32'h10293847,0);
   send(1,'0,'0,1,0,'0,'1,32'h56473829,3);send(1);
   for(int k=0;k<4;k++)send(1,'0,'0,0,0,'0,'1,32'h13579BDF^(32'h11111111*k),2'(k));
   clean_reset();
   for(int k=0;k<3*N;k++)send(1,'1,'1,0,'h700+k,32'hA5000000+k,32'h5AA55AA5);
   for(int k=0;k<1200;k++)begin
    if(k%N==0)begin
     block_t=new("random_block");
     if(!block_t.randomize())`uvm_fatal("RANDOMIZE","random block failed")
    end
    t=new("random_cycle");start_item(t);
    t.rst_n=1;t.req=block_t.req;t.wr=block_t.wr;
    for(int p=0;p<N;p++)begin t.addr[p]=block_t.addr[p];t.wd[p]=block_t.wd[p];t.wm[p]=block_t.wm[p];end
    t.rv=($urandom_range(0,3)!=0);t.rd=$urandom();t.err=2'($urandom_range(0,3));
    finish_item(t);
   end
   // Eight drain cycles: at most four accepted owners then four quiet.
   for(int k=0;k<8;k++)send(1,'0,'0,k<4,0,'0,'1,$urandom(),2'(k));
  endtask
 endclass
 class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  sram_env #(4,12,32) e0,e1;
  sram_env #(2,12,32) e2;
  function new(string n="dvbench_test",uvm_component p=null);super.new(n,p);endfunction
  function void build_phase(uvm_phase phase);
   uvm_report_server rs;
   super.build_phase(phase);
   e0=sram_env #(4,12,32)::type_id::create("e0",this);
   e1=sram_env #(4,12,32)::type_id::create("e1",this);
   e2=sram_env #(2,12,32)::type_id::create("e2",this);
   rs=uvm_report_server::get_server();rs.set_max_quit_count(0);
  endfunction
  task run_phase(uvm_phase phase);
   sram_sequence #(4,12,32) s0,s1;
   sram_sequence #(2,12,32) s2;
   virtual sram_if #(4,12,32) v;
   phase.raise_objection(this);
   s0=new("default_ppc");s1=new("masked_ppc");s2=new("masked_tree");
   fork s0.start(e0.agent.sqr);s1.start(e1.agent.sqr);s2.start(e2.agent.sqr);join
   if(!uvm_config_db#(virtual sram_if #(4,12,32))::get(this,"e0","vif",v))
    `uvm_fatal("NOVIF","test drain clock missing")
   @(posedge v.clk);#2;
   phase.drop_objection(this);
  endtask
  function void report_phase(uvm_phase phase);
   uvm_report_server rs;
   super.report_phase(phase);rs=uvm_report_server::get_server();
   if(rs.get_severity_count(UVM_ERROR)==0&&rs.get_severity_count(UVM_FATAL)==0)
    $display("DVBench_COMPLETED");
  endfunction
 endclass
endpackage
module sram_profile #(parameter int N=4,AW=12,DW=32,parameter bit MASK=0,
                      parameter IMPL="PPC")(sram_if v);
prim_sram_arbiter #(.N(N),.SramAw(AW),.SramDw(DW),.ArbiterImpl(IMPL),.EnMask(MASK)) dut (
 .clk_i(v.clk),
 .rst_ni(v.rst_n),
 .req_i(v.req),
 .req_addr_i(v.addr),
 .req_write_i(v.wr),
 .req_wdata_i(v.wd),
 .req_wmask_i(v.wm),
 .sram_rvalid_i(v.rv),
 .sram_rdata_i(v.rd),
 .sram_rerror_i(v.err),
 .gnt_o(v.gnt),
 .rsp_rvalid_o(v.rvalid),
 .rsp_rdata_o(v.rdata),
 .rsp_error_o(v.error),
 .sram_req_o(v.sreq),
 .sram_addr_o(v.saddr),
 .sram_write_o(v.swrite),
 .sram_wdata_o(v.swdata),
 .sram_wmask_o(v.swmask));
dvbench_model #(.N(N),.SramAw(AW),.SramDw(DW),.ArbiterImpl(IMPL),.EnMask(MASK)) predictor (
 .clk_i(v.clk),
 .rst_ni(v.rst_n),
 .req_i(v.req),
 .req_addr_i(v.addr),
 .req_write_i(v.wr),
 .req_wdata_i(v.wd),
 .req_wmask_i(v.wm),
 .sram_rvalid_i(v.rv),
 .sram_rdata_i(v.rd),
 .sram_rerror_i(v.err),
 .gnt_o(v.egnt),
 .rsp_rvalid_o(v.ervalid),
 .rsp_rdata_o(v.erdata),
 .rsp_error_o(v.eerror),
 .sram_req_o(v.esreq),
 .sram_addr_o(v.esaddr),
 .sram_write_o(v.eswrite),
 .sram_wdata_o(v.eswdata),
 .sram_wmask_o(v.eswmask));
endmodule
module dvbench_top;
 import uvm_pkg::*;
 import sram_uvm_pkg::*;
 logic clk=0;always #5 clk=~clk;
 sram_if #(4,12,32) if0(clk);
 sram_if #(4,12,32) if1(clk);
 sram_if #(2,12,32) if2(clk);
 sram_profile #(.N(4),.MASK(0),.IMPL("PPC")) p0(if0);
 sram_profile #(.N(4),.MASK(1),.IMPL("PPC")) p1(if1);
 sram_profile #(.N(2),.MASK(1),.IMPL("BINTREE")) p2(if2);
 initial begin
  uvm_config_db#(virtual sram_if #(4,12,32))::set(null,"uvm_test_top.e0*","vif",if0);
  uvm_config_db#(virtual sram_if #(4,12,32))::set(null,"uvm_test_top.e1*","vif",if1);
  uvm_config_db#(virtual sram_if #(2,12,32))::set(null,"uvm_test_top.e2*","vif",if2);
  run_test("dvbench_test");
 end
endmodule
