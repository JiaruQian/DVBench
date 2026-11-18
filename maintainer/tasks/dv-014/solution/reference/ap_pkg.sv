`timescale 1ns/1ps
package ap_pkg;
 import uvm_pkg::*;`include "uvm_macros.svh"
 class ap_item extends uvm_sequence_item;
  bit rst_n;int unsigned cycles;
  `uvm_object_utils(ap_item)
  function new(string n="ap_item");super.new(n);endfunction
 endclass
 class ap_sample extends uvm_sequence_item;
  logic scl,sda,escl,esda;logic[3:0] led,eled;logic[5:0] sel,esel;logic[7:0] seg,eseg;
  bit reset,display_valid;integer reads,stops;
  `uvm_object_utils(ap_sample)
  function new(string n="ap_sample");super.new(n);endfunction
 endclass
 class ap_sequence extends uvm_sequence#(ap_item);
  `uvm_object_utils(ap_sequence)
  function new(string n="ap_sequence");super.new(n);endfunction
  task send(bit reset_n,int unsigned cycles);
   ap_item x=ap_item::type_id::create("x");start_item(x);x.rst_n=reset_n;x.cycles=cycles;finish_item(x);
  endtask
  task body();send(0,32);send(1,17750000);endtask
 endclass
 class ap_driver extends uvm_driver#(ap_item);
  `uvm_component_utils(ap_driver)
  virtual ap_if vif;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);
   if(!uvm_config_db#(virtual ap_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing native ap_if")
  endfunction
  task run_phase(uvm_phase p);
   ap_item x;
   forever begin seq_item_port.get_next_item(x);@(negedge vif.sys_clk);vif.rst_n=x.rst_n;
    repeat(x.cycles)@(negedge vif.sys_clk);seq_item_port.item_done();end
  endtask
 endclass
 class ap_monitor extends uvm_monitor;
  `uvm_component_utils(ap_monitor)
  virtual ap_if vif;uvm_analysis_port#(ap_sample) ap;time release_time=0;bit display_ready=0;
  function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);endfunction
  function void build_phase(uvm_phase p);
   if(!uvm_config_db#(virtual ap_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing native ap_if")
  endfunction
  task run_phase(uvm_phase p);
   ap_sample x;
   fork
    forever begin @(posedge vif.rst_n);release_time=$time;end
    forever begin
     wait(vif.rst_n && vif.expected_stops>=5 && vif.expected_reads>=4);
     #16000;if(vif.rst_n)display_ready=1;
     wait(!vif.rst_n);display_ready=0;
    end
    forever begin
     @(vif.scl or vif.sda or vif.expected_scl or vif.expected_sda or vif.led or vif.expected_led or vif.sel or vif.expected_sel or vif.seg or vif.expected_seg or vif.rst_n);#1;
     if($time>1)begin
     x=ap_sample::type_id::create("sample");
     x.scl=vif.scl;x.sda=vif.sda;x.escl=vif.expected_scl;x.esda=vif.expected_sda;
     x.led=vif.led;x.eled=vif.expected_led;x.sel=vif.sel;x.esel=vif.expected_sel;x.seg=vif.seg;x.eseg=vif.expected_seg;
     x.reset=!vif.rst_n;x.display_valid=vif.rst_n && display_ready;
     x.reads=vif.actual_reads;x.stops=vif.actual_stops;ap.write(x);
     end
    end
   join
  endtask
 endclass
 class ap_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ap_scoreboard)
  uvm_analysis_imp#(ap_sample,ap_scoreboard) in_port;int unsigned points=0,display_points=0;integer reads=0,stops=0;
  covergroup outputs with function sample(bit rst,bit[3:0] led,bit[5:0] sel);
   reset:coverpoint rst;
   proximity:coverpoint led {bins zero={0};bins low={1};bins mid_level={3};bins high={7};bins max={15};}
   scan:coverpoint sel {bins p0={6'b111110};bins p1={6'b111101};bins p2={6'b111011};bins p3={6'b110111};bins p4={6'b101111};bins p5={6'b011111};}
  endgroup
  function new(string n,uvm_component p);super.new(n,p);in_port=new("in_port",this);outputs=new;endfunction
  function void write(ap_sample x);
   points++;reads=x.reads;stops=x.stops;outputs.sample(x.reset,x.led,x.sel);
   if({x.scl,x.sda,x.led,x.sel}!=={x.escl,x.esda,x.eled,x.esel})
    `uvm_error("PINS",$sformatf("point=%0d actual scl/sda/led/sel=%b%b/%h/%h expected=%b%b/%h/%h",points,x.scl,x.sda,x.led,x.sel,x.escl,x.esda,x.eled,x.esel))
   if(x.reset || x.display_valid)begin
    display_points++;
    if(x.seg!==x.eseg)`uvm_error("DISPLAY",$sformatf("point=%0d actual segment=%h expected=%h",points,x.seg,x.eseg))
   end
  endfunction
  function void check_phase(uvm_phase p);
   if(points<500 || display_points<12 || reads<12 || stops<13)
    `uvm_error("VACUOUS",$sformatf("points=%0d display=%0d reads=%0d stops=%0d",points,display_points,reads,stops))
  endfunction
 endclass
 class ap_agent extends uvm_agent;
  `uvm_component_utils(ap_agent)
  uvm_sequencer#(ap_item) sqr;ap_driver drv;ap_monitor mon;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);
   sqr=uvm_sequencer#(ap_item)::type_id::create("sqr",this);drv=ap_driver::type_id::create("drv",this);mon=ap_monitor::type_id::create("mon",this);
  endfunction
  function void connect_phase(uvm_phase p);drv.seq_item_port.connect(sqr.seq_item_export);endfunction
 endclass
 class ap_env extends uvm_env;
  `uvm_component_utils(ap_env)
  ap_agent agt;ap_scoreboard scb;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);agt=ap_agent::type_id::create("agt",this);scb=ap_scoreboard::type_id::create("scb",this);endfunction
  function void connect_phase(uvm_phase p);agt.mon.ap.connect(scb.in_port);endfunction
 endclass
 class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  ap_env env;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);env=ap_env::type_id::create("env",this);endfunction
  task run_phase(uvm_phase p);
   ap_sequence s;p.raise_objection(this);s=ap_sequence::type_id::create("sequence");s.start(env.agt.sqr);#100;p.drop_objection(this);
  endtask
  function void report_phase(uvm_phase p);
   uvm_report_server srv=uvm_report_server::get_server();
   if(srv.get_severity_count(UVM_ERROR)==0 && srv.get_severity_count(UVM_FATAL)==0)begin
    $display("AP_CHECK_COUNTS points=%0d display=%0d reads=%0d stops=%0d",env.scb.points,env.scb.display_points,env.scb.reads,env.scb.stops);
    $display("DVBench_COMPLETED");
   end
  endfunction
 endclass
endpackage
