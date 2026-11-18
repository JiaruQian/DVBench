`timescale 1ns/1ps
package fifo_pkg;
 import uvm_pkg::*;
 `include "uvm_macros.svh"
 class fifo_item extends uvm_sequence_item;
   rand bit we,re,rst;
   rand bit [7:0] data;
   rand int unsigned cycles;
   constraint short_hold {cycles inside {[1:4]}; rst==0;}
   `uvm_object_utils(fifo_item)
   function new(string name="fifo_item"); super.new(name); endfunction
 endclass
 class fifo_sample extends uvm_sequence_item;
   logic full,empty,efull,eempty;
   logic [7:0] data,edata;
   bit reset,we,re;
   `uvm_object_utils(fifo_sample)
   function new(string name="fifo_sample"); super.new(name); endfunction
 endclass
 class fifo_sequence extends uvm_sequence #(fifo_item);
   `uvm_object_utils(fifo_sequence)
   function new(string name="fifo_sequence");super.new(name);endfunction
   task send(bit w,bit r,bit reset,bit[7:0] d,int n=1);
     fifo_item x=fifo_item::type_id::create("x");
     start_item(x);x.we=w;x.re=r;x.rst=reset;x.data=d;x.cycles=n;finish_item(x);
   endtask
   task body();
     fifo_item x;
     send(0,0,1,0,3);send(0,0,0,0,2);
     // Populate every storage location, including data pattern corners.
     for(int i=0;i<16;i++)send(1,0,0,8'(i*17));
     send(1,0,0,8'hf3,4); // full write rejection
     send(1,1,0,8'ha5,4); // full/interior simultaneous requests
     send(0,1,0,0,30);send(0,1,0,0,3); // drain and empty reads
     send(1,1,0,8'h3c,4); // empty simultaneous request
     repeat(3)begin
       for(int i=0;i<20;i++)send(1,0,0,8'($urandom));
       send(0,1,0,0,30);
     end
     send(1,0,0,8'h77,5);send(0,0,1,0,3);send(0,0,0,0,2);
     for(int i=0;i<16;i++)send(1,0,0,8'(255-i));
     for(int i=0;i<400;i++)begin
       x=fifo_item::type_id::create("random");start_item(x);
       if(!x.randomize())`uvm_fatal("RAND","item randomization failed")
       finish_item(x);
     end
     send(0,1,0,0,30);send(0,0,0,0,4);
   endtask
 endclass
 class fifo_driver extends uvm_driver #(fifo_item);
   `uvm_component_utils(fifo_driver)
   virtual fifo_if vif;
   function new(string n,uvm_component p);super.new(n,p);endfunction
   function void build_phase(uvm_phase p);
     super.build_phase(p);
     if(!uvm_config_db#(virtual fifo_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing fifo_if")
   endfunction
   task run_phase(uvm_phase p);
     fifo_item x;
     forever begin
       seq_item_port.get_next_item(x);
       @(negedge vif.w_clk);vif.rst=x.rst;vif.we=x.we;vif.re=x.re;vif.wdata=x.data;
       repeat(x.cycles)@(negedge vif.w_clk);
       vif.we=0;vif.re=0;
       seq_item_port.item_done();
     end
   endtask
 endclass
 class fifo_monitor extends uvm_monitor;
   `uvm_component_utils(fifo_monitor)
   virtual fifo_if vif;
   uvm_analysis_port#(fifo_sample) ap;
   function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);endfunction
   function void build_phase(uvm_phase p);
     super.build_phase(p);
     if(!uvm_config_db#(virtual fifo_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing fifo_if")
   endfunction
   task run_phase(uvm_phase p);
     fifo_sample x;
     forever begin
       @(posedge vif.w_clk or posedge vif.r_clk or posedge vif.rst);#1;
       x=fifo_sample::type_id::create("sample");
       x.full=vif.full;x.empty=vif.empty;x.data=vif.rdata;
       x.efull=vif.expected_full;x.eempty=vif.expected_empty;x.edata=vif.expected_data;
       x.reset=vif.rst;x.we=vif.we;x.re=vif.re;ap.write(x);
     end
   endtask
 endclass
 class fifo_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(fifo_scoreboard)
   uvm_analysis_imp#(fifo_sample,fifo_scoreboard) in_port;
   int unsigned points=0,data_points=0;
   covergroup operations with function sample(bit rst,bit we,bit re,bit f,bit e);
     option.per_instance=1;
     cp_reset:coverpoint rst;
     cp_ops:coverpoint {we,re};
     cp_status:coverpoint {f,e} {bins normal={0};bins empty={1};bins full={2};illegal_bins impossible={3};}
     op_status:cross cp_ops,cp_status;
   endgroup
   function new(string n,uvm_component p);super.new(n,p);in_port=new("in_port",this);operations=new;endfunction
   function void write(fifo_sample x);
     points++;operations.sample(x.reset,x.we,x.re,x.efull,x.eempty);
     if({x.full,x.empty}!=={x.efull,x.eempty})
       `uvm_error("STATUS",$sformatf("point %0d actual full/empty=%b%b expected=%b%b",points,x.full,x.empty,x.efull,x.eempty))
     if(!x.eempty && !$isunknown(x.edata))begin
       data_points++;
       if(x.data!==x.edata)`uvm_error("ORDER",$sformatf("point %0d data=%h expected=%h",points,x.data,x.edata))
     end
   endfunction
   function void check_phase(uvm_phase p);
     if(points<200 || data_points<32)`uvm_error("VACUOUS",$sformatf("insufficient checks: points=%0d data=%0d",points,data_points))
   endfunction
 endclass
 class fifo_agent extends uvm_agent;
   `uvm_component_utils(fifo_agent)
   uvm_sequencer#(fifo_item) sqr;fifo_driver drv;fifo_monitor mon;
   function new(string n,uvm_component p);super.new(n,p);endfunction
   function void build_phase(uvm_phase p);
     sqr=uvm_sequencer#(fifo_item)::type_id::create("sqr",this);
     drv=fifo_driver::type_id::create("drv",this);mon=fifo_monitor::type_id::create("mon",this);
   endfunction
   function void connect_phase(uvm_phase p);drv.seq_item_port.connect(sqr.seq_item_export);endfunction
 endclass
 class fifo_env extends uvm_env;
   `uvm_component_utils(fifo_env)
   fifo_agent agt;fifo_scoreboard scb;
   function new(string n,uvm_component p);super.new(n,p);endfunction
   function void build_phase(uvm_phase p);agt=fifo_agent::type_id::create("agt",this);scb=fifo_scoreboard::type_id::create("scb",this);endfunction
   function void connect_phase(uvm_phase p);agt.mon.ap.connect(scb.in_port);endfunction
 endclass
 class dvbench_test extends uvm_test;
   `uvm_component_utils(dvbench_test)
   fifo_env env;
   function new(string n,uvm_component p);super.new(n,p);endfunction
   function void build_phase(uvm_phase p);env=fifo_env::type_id::create("env",this);endfunction
   task run_phase(uvm_phase p);
     fifo_sequence s;
     p.raise_objection(this);s=fifo_sequence::type_id::create("sequence");s.start(env.agt.sqr);#20;p.drop_objection(this);
   endtask
   function void report_phase(uvm_phase p);
     uvm_report_server srv=uvm_report_server::get_server();
     if(srv.get_severity_count(UVM_ERROR)==0 && srv.get_severity_count(UVM_FATAL)==0) begin
       $display("FIFO_CHECK_COUNTS points=%0d data_points=%0d",env.scb.points,env.scb.data_points);
       $display("DVBench_COMPLETED");
     end
   endfunction
 endclass
endpackage
