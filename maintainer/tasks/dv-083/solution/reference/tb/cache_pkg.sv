package cache_native_pkg;
 import uvm_pkg::*;
 `include "uvm_macros.svh"
 class access_item extends uvm_sequence_item;
  `uvm_object_utils(access_item)
  int mode;bit reset,flush;bit[31:0]addr,data;bit[3:0]be;bit write_en;int delay_cycles;
  function new(string n="access_item");super.new(n);endfunction
 endclass
 class cache_sequence extends uvm_sequence#(access_item);
  `uvm_object_utils(cache_sequence)
  function new(string n="cache_sequence");super.new(n);endfunction
  task body();access_item t;
   for(int i=0;i<104;i++)begin
    t=access_item::type_id::create("t");start_item(t);
    t.reset=(i==0 || i==53);t.flush=(i==31 || i==78);
    t.mode=(i>=96)?(i-95):0;
    t.addr=((i%8)*16)+((i/8)%3)*8192+(i%4)*4;
    t.data=$urandom();t.be=i%16;t.write_en=(i%3!=0);t.delay_cycles=$urandom_range(0,3);
    finish_item(t);
   end
  endtask
 endclass
 class native_driver extends uvm_driver#(access_item);
  `uvm_component_utils(native_driver)
  virtual cache_native_if vif;int operations=0;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);if(!uvm_config_db#(virtual cache_native_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing") endfunction
  task tick();@(negedge vif.clk);endtask
  task run_phase(uvm_phase phase);int cycles;
   forever begin
    seq_item_port.get_next_item(req);tick();
    vif.lq=0;vif.sq=0;vif.rr=0;vif.flush=0;vif.sa=0;vif.sm=0;vif.sx=0;
    if(req.reset)begin vif.rst=1;repeat(3)tick();vif.rst=0;repeat(520)tick();end
    else if(req.flush)begin vif.flush=1;tick();vif.flush=0;repeat(520)tick();end
    else begin
     if(req.mode==6)begin
      vif.ax=req.addr^32'h100000;tick();vif.am=req.addr^32'h100000;
      vif.sd=req.data;vif.be=4'hf;vif.sq=1;tick();vif.sq=0;repeat(2)tick();
     end
     if(req.mode==7)begin
      vif.ax=req.addr^32'h100000;tick();vif.am=req.addr^32'h100000;
      vif.sm=1;vif.lq=1;tick();vif.lq=0;repeat(2)tick();vif.sm=0;
     end

     vif.ax=req.addr;tick();vif.am=req.addr;vif.lq=1;
     if(req.mode==2)vif.flush=1;
     tick();vif.lq=0;vif.flush=0;
     if(vif.stall===1'b1)begin
      repeat(2)tick();
      if(req.mode==3)begin
       vif.rst=1;repeat(3)tick();vif.rst=0;repeat(520)tick();
       vif.ax=req.addr;tick();vif.am=req.addr;vif.lq=1;tick();vif.lq=0;repeat(2)tick();
      end
      for(int j=0;j<4;j++)begin
       repeat(req.delay_cycles)tick();if(req.mode==4)vif.flush=1;vif.rr=1;vif.rd=(req.addr & 32'hfffffff0)^32'hb579d123^(32'h1020304*j);tick();vif.rr=0;vif.flush=0;
      end
      vif.sa=1;repeat(2)tick();vif.sa=0;repeat(3)tick();
     end
     if(req.mode==8)begin
      for(int k=0;k<4;k++)begin vif.ax=(req.addr & 32'hfffffff0)+(k*4);tick();end
      vif.ax=req.addr;tick();
     end
     if(req.mode==1)begin vif.ax=req.addr^32'd4;tick();end
     if(req.write_en || req.mode==1)begin
      vif.sd=req.data;vif.be=req.be;vif.sq=1;tick();vif.sq=0;repeat(2)tick();
     end
     if(req.mode==5)begin vif.ax=req.addr^32'hf0000003;tick();vif.am=req.addr^32'hf0000003;vif.lq=1;tick();vif.lq=0;tick();end
     vif.sx=1;vif.ax=req.addr^32'h100;repeat(2)tick();vif.sx=0;vif.ax=req.addr;tick();
     vif.sm=1;vif.sq=1;vif.sd=~req.data;tick();vif.sm=0;vif.sq=0;repeat(2)tick();
    end
    operations++;seq_item_port.item_done();
   end
  endtask
 endclass
 class sample_item extends uvm_sequence_item;
  logic[3:0]actual_ctrl,expected_ctrl;logic[31:0]address,expected_address,data,expected_data;
  `uvm_object_utils(sample_item)
  function new(string n="sample_item");super.new(n);endfunction
 endclass
 class native_monitor extends uvm_monitor;
  `uvm_component_utils(native_monitor)
  virtual cache_native_if vif;uvm_analysis_port#(sample_item)ap;bit armed=0;
  function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);endfunction
  function void build_phase(uvm_phase p);if(!uvm_config_db#(virtual cache_native_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing") endfunction
  task run_phase(uvm_phase p);sample_item s;
   forever begin @(posedge vif.clk);#2;if(vif.rst)armed=1;
    if(armed)begin
     s=sample_item::type_id::create("s");s.actual_ctrl={vif.stall,vif.restart,vif.req,vif.refilling};s.expected_ctrl={vif.estall,vif.erestart,vif.ereq,vif.erefilling};
     s.address=vif.addr;s.expected_address=vif.eaddr;s.data=vif.data;s.expected_data=vif.edata;ap.write(s);
    end
   end
  endtask
 endclass
 class native_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(native_scoreboard)
  uvm_analysis_imp#(sample_item,native_scoreboard)imp;int points=0,errors=0,requests=0,restarts=0;longint masked_data_bits=0,masked_address_bits=0,compared_data_bits=0,compared_address_bits=0;
  covergroup cg with function sample(sample_item s);
   coverpoint s.actual_ctrl;coverpoint s.data {bins zeros={0};bins allones={32'hffffffff};bins other=default;}
  endgroup
  function new(string n,uvm_component p);super.new(n,p);imp=new("imp",this);cg=new;endfunction
  function bit defined_mismatch(input logic[31:0] actual,expected);
   for(int j=0;j<32;j++)if(expected[j]===1'b0 || expected[j]===1'b1)if(actual[j]!==expected[j])return 1;
   return 0;
  endfunction
  function void write(sample_item s);
   points++;cg.sample(s);if(s.actual_ctrl[2])requests++;if(s.actual_ctrl[1])restarts++;
   for(int j=0;j<32;j++)begin
    if(s.expected_data[j]===1'b0 || s.expected_data[j]===1'b1)compared_data_bits++;else masked_data_bits++;
    if(s.expected_address[j]===1'b0 || s.expected_address[j]===1'b1)compared_address_bits++;else masked_address_bits++;
   end
   if(s.actual_ctrl!==s.expected_ctrl || defined_mismatch(s.address,s.expected_address) || defined_mismatch(s.data,s.expected_data))begin errors++;if(errors<=20)`uvm_error("COMPARE",$sformatf("point=%0d ctrl=%b/%b address=%h/%h data=%h/%h",points,s.actual_ctrl,s.expected_ctrl,s.address,s.expected_address,s.data,s.expected_data)) end
  endfunction
  function void check_phase(uvm_phase p);if(points<3000 || requests<10 || restarts<10)`uvm_error("VACUITY","insufficient cache/refill activity") endfunction
  function void report_phase(uvm_phase p);`uvm_info("COUNTS",$sformatf("points=%0d errors=%0d requests=%0d restarts=%0d masked_data_bits=%0d masked_address_bits=%0d compared_data_bits=%0d compared_address_bits=%0d",points,errors,requests,restarts,masked_data_bits,masked_address_bits,compared_data_bits,compared_address_bits),UVM_NONE) endfunction
 endclass
 class native_agent extends uvm_agent;
  `uvm_component_utils(native_agent)
  uvm_sequencer#(access_item)sq;native_driver drv;native_monitor mon;native_scoreboard sb;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);sq=new("sq",this);drv=native_driver::type_id::create("drv",this);mon=native_monitor::type_id::create("mon",this);sb=native_scoreboard::type_id::create("sb",this);endfunction
  function void connect_phase(uvm_phase p);drv.seq_item_port.connect(sq.seq_item_export);mon.ap.connect(sb.imp);endfunction
 endclass
 class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  native_agent agent0,agent1;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);agent0=native_agent::type_id::create("agent0",this);agent1=native_agent::type_id::create("agent1",this);endfunction
  task run_phase(uvm_phase p);cache_sequence s0,s1;p.raise_objection(this);s0=cache_sequence::type_id::create("s0");s1=cache_sequence::type_id::create("s1");fork s0.start(agent0.sq);s1.start(agent1.sq);join #30;p.drop_objection(this);endtask
  function void report_phase(uvm_phase p);uvm_report_server rs;rs=uvm_report_server::get_server();if(rs.get_severity_count(UVM_ERROR)==0 && rs.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");endfunction
 endclass
endpackage
