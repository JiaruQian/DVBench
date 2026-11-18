`timescale 1ns/1ps
package video_pkg;
 import uvm_pkg::*;
 `include "uvm_macros.svh"
 class video_item extends uvm_sequence_item;
  `uvm_object_utils(video_item)
  logic rst=1,hs=0,vs=0,vde=0;
  logic [3:0] sw=0,btn=0;
  logic [23:0] data=0;
  int unsigned cycles=1;
  function new(string name="video_item"); super.new(name); endfunction
 endclass
 class video_observation extends uvm_sequence_item;
  `uvm_object_utils(video_observation)
  logic rst,vde; logic [3:0] sw,btn;
  logic [30:0] actual,expected;
  bit data_defined;
  function new(string name="video_observation"); super.new(name); endfunction
 endclass
 class video_driver extends uvm_driver #(video_item);
  `uvm_component_utils(video_driver)
  virtual video_if vif;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   if(!uvm_config_db#(virtual video_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing video interface")
  endfunction
  task run_phase(uvm_phase phase);
   forever begin
    seq_item_port.get_next_item(req);
    @(negedge vif.clk);
    vif.n_rst=req.rst; vif.sw=req.sw; vif.btn=req.btn; vif.i_vid_data=req.data;
    vif.i_vid_hsync=req.hs; vif.i_vid_vsync=req.vs; vif.i_vid_VDE=req.vde;
    repeat(req.cycles-1) @(negedge vif.clk);
    seq_item_port.item_done();
   end
  endtask
 endclass
 class video_monitor extends uvm_component;
  `uvm_component_utils(video_monitor)
  virtual video_if vif;
  uvm_analysis_port #(video_observation) ap;
  int warm=0; int previous_mode=0,previous_previous_mode=0;
  function new(string n,uvm_component p); super.new(n,p); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   if(!uvm_config_db#(virtual video_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing video interface")
  endfunction
  function void sample(video_observation t);
   t.rst=vif.n_rst; t.vde=vif.i_vid_VDE; t.sw=vif.sw; t.btn=vif.btn;
   t.actual={vif.led,vif.o_vid_hsync,vif.o_vid_vsync,vif.o_vid_VDE,vif.o_vid_data};
   t.expected={vif.expected_led,vif.expected_hsync,vif.expected_vsync,vif.expected_VDE,vif.expected_data};
   // Predicate uses only reset and input history; actual X never controls masking.
   t.data_defined=!vif.n_rst || warm>=2*384+8 ||
      (vif.sw[2:0]<4 && previous_mode<4 && previous_previous_mode<4);
   ap.write(t);
  endfunction
  task run_phase(uvm_phase phase);
   fork
    begin
     video_observation t=new("edge");
     forever begin
      @(posedge vif.clk); #0.2;
      if(!vif.n_rst) warm=0; else if(vif.i_vid_VDE && warm<2*384+8) warm++;
      sample(t);
      previous_previous_mode=previous_mode; previous_mode=int'(vif.sw[2:0]);
     end
    end
    begin
     video_observation t=new("between_edges_reset");
     forever begin @(negedge vif.clk); #0.2; if(!vif.n_rst) sample(t); end
    end
   join
  endtask
 endclass
 class video_scoreboard extends uvm_subscriber #(video_observation);
  `uvm_component_utils(video_scoreboard)
  longint comparisons=0,data_comparisons=0,undefined_data_points=0,mismatches=0;
  logic [9:0] last_coverage='x;
  covergroup behavior with function sample(logic [3:0] mode,logic [3:0] buttons,logic rst,logic de);
   cp_mode: coverpoint mode[2:0];
   cp_split: coverpoint mode[3];
   cp_buttons: coverpoint buttons {bins none_={0}; bins up={1}; bins down={2}; bins both_={3}; bins unused_={[4:15]};}
   cp_reset: coverpoint rst;
   cp_vde: coverpoint de;
   mode_split: cross cp_mode,cp_split;
  endgroup
  function new(string n,uvm_component p); super.new(n,p); behavior=new(); endfunction
  function void write(video_observation t);
   comparisons++;
   if(t.data_defined) data_comparisons++; else undefined_data_points++;
   if(t.actual[30:24]!==t.expected[30:24] || (t.data_defined && t.actual[23:0]!==t.expected[23:0])) begin
    mismatches++;
    if(mismatches<=32) `uvm_error("VIDEO_COMPARE",$sformatf("point=%0d mode=%h buttons=%h data_defined=%0b actual=%h expected=%h",comparisons,t.sw,t.btn,t.data_defined,t.actual,t.expected))
   end
   if(t.vde || {t.sw,t.btn,t.rst,t.vde}!==last_coverage) begin
    behavior.sample(t.sw,t.btn,t.rst,t.vde); last_coverage={t.sw,t.btn,t.rst,t.vde};
   end
  endfunction
  function void report_phase(uvm_phase phase);
   `uvm_info("VIDEO_COUNTS",$sformatf("points=%0d data_points=%0d undefined_data_points=%0d mismatches=%0d",comparisons,data_comparisons,undefined_data_points,mismatches),UVM_LOW)
   if(comparisons<1000 || data_comparisons<1000) `uvm_error("VACUITY","insufficient executed comparisons")
   if(mismatches>32) `uvm_error("VIDEO_TOTAL",$sformatf("all mismatches=%0d",mismatches))
  endfunction
 endclass
 class video_agent extends uvm_agent;
  `uvm_component_utils(video_agent)
  video_driver driver; video_monitor monitor; uvm_sequencer #(video_item) sequencer;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
   super.build_phase(phase); driver=video_driver::type_id::create("driver",this);
   monitor=video_monitor::type_id::create("monitor",this);
   sequencer=uvm_sequencer#(video_item)::type_id::create("sequencer",this);
  endfunction
  function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
 endclass
 class video_env extends uvm_env;
  `uvm_component_utils(video_env)
  video_agent agent; video_scoreboard scoreboard;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
   super.build_phase(phase); agent=video_agent::type_id::create("agent",this); scoreboard=video_scoreboard::type_id::create("scoreboard",this);
  endfunction
  function void connect_phase(uvm_phase phase); agent.monitor.ap.connect(scoreboard.analysis_export); endfunction
 endclass
 class video_sequence extends uvm_sequence #(video_item);
  `uvm_object_utils(video_sequence)
  bit extended=0,saturation=0,refined=0; int saturation_side=0;
  logic [3:0] current_mode=0,current_buttons=0;
  function new(string name="video_sequence"); super.new(name); endfunction
  task drive(logic [23:0] data=0,logic hs=0,logic vs=0,logic de=0,int unsigned cycles=1,logic rst=1);
   video_item t=video_item::type_id::create("drive");
   start_item(t); t.data=data; t.hs=hs; t.vs=vs; t.vde=de; t.cycles=cycles;
   t.rst=rst; t.sw=current_mode; t.btn=current_buttons; finish_item(t);
  endtask
  task slot(logic [3:0] mode,logic [3:0] buttons);
   current_mode=mode; current_buttons=buttons; drive(0,0,0,0,2500002);
  endtask
  task threshold_probe(int threshold);
   for(int i=-1;i<=1;i++) begin
    logic [7:0] v=8'(threshold+i);
    drive({v,v,v},0,0,0,4);
   end
   drive(24'h000000,0,0,0,4); drive(24'hffffff,0,0,0,4);
  endtask
  task window_probe();
   // Native VDE history initializes every RAM slot; no hierarchical access.
   for(int i=0;i<3*384+16;i++) drive($urandom, i%384<2,0,1);
   drive(0,0,0,0,8);
  endtask
  task default_history();
   current_mode=0; current_buttons=0; drive(0,0,0,0,4,0); drive(0,0,0,0,4);
   window_probe();
   drive(0,0,1,0); drive(0,0,0,0);
   for(int row=0;row<64;row++) begin
    current_mode={1'b0,3'(row%8)}; if(row%3==0) current_mode[3]=1;
    for(int x=0;x<384;x++) begin
     logic [23:0] pixel;
     case(x%8)
      0:pixel=0; 1:pixel=24'hffffff; 2:pixel=24'h808080;
      3:pixel=24'hff0000; 4:pixel=24'h00ff00; 5:pixel=24'h0000ff;
      default:pixel=$urandom;
     endcase
     drive(pixel,x<2,0,1);
    end
    drive(0,0,0,0,4);
   end
   // Mid-stream native synchronous reset, then one real threshold sampling slot.
   current_mode=3; current_buttons=0; drive(24'h808080,0,0,0,4,0); drive(0,0,0,0,4);
   slot(3,1); threshold_probe(133); // 128 + 5; includes 132/133/134 equality boundary.
  endtask
  task extended_history();
   slot(3,1); threshold_probe(133); // Held through a second sampling slot: no repeat.
   // Interleaving naturally samples inactive channel buttons as zero.
   for(int i=0;i<3;i++) begin
    slot(4,1); window_probe(); // Gaussian 1 -> 2 -> 0 -> 1.
    slot(6,1); window_probe(); // Sobel 0 -> 1 -> 2 -> 0.
   end
   slot(3,3); threshold_probe(138); // Both new edges: increment wins, both prev bits update.
   slot(0,0); slot(3,2); threshold_probe(133);
   current_mode=3; current_buttons=0; drive(0,0,0,0,8);
  endtask
  task refinement_history();
   // Between sample slots a short pulse is not accepted. No internal access.
   current_mode=3; current_buttons=0; drive(0,0,0,0,4,0); drive(0,0,0,0,4);
   current_buttons=1; drive(0,0,0,0,8); current_buttons=0; drive(0,0,0,0,8); threshold_probe(128);
   current_buttons=12; drive(0,0,0,0,8); current_buttons=0; drive(0,0,0,0,8); threshold_probe(128);
   slot(4,2); window_probe(); slot(6,2); window_probe();
   // Each filter name gets its own complete raster, including y beyond64,
   // blanking and hsync changes. Expected data comes from the same native model.
   for(int mode=0;mode<8;mode++) begin
    current_mode=4'(mode); current_buttons=0; drive(0,0,1,0); drive(0,0,0,0);
    for(int y=0;y<70;y++) begin
     for(int x=0;x<384;x++) drive($urandom, (x+y)%7==0,0,1);
     drive($urandom, y%2,0,0,4);
    end
   end
   // Release between two observed high samples does not create a new edge.
   current_mode=3; current_buttons=0; drive(0,0,0,0,4,0); drive(0,0,0,0,4);
   slot(3,1); threshold_probe(133);
   current_buttons=0; drive(0,0,0,0,8); current_buttons=1; drive(0,0,0,0,8);
   slot(3,1); threshold_probe(133);
  endtask
  task saturation_history();
   if(saturation_side==1) begin
    // default_history leaves threshold133. 25 accepted increments reach255.
    for(int i=0;i<25;i++) begin slot(3,0); slot(3,1); end
    threshold_probe(255); slot(3,0); slot(3,1); threshold_probe(255);
   end else if(saturation_side==2) begin
    current_mode=3; current_buttons=0; drive(0,0,0,0,4,0); drive(0,0,0,0,4);
    for(int i=0;i<26;i++) begin slot(3,0); slot(3,2); end
    threshold_probe(0); slot(3,0); slot(3,2); threshold_probe(0);
   end else begin
    for(int i=0;i<27;i++) begin slot(3,0); slot(3,1); end
    threshold_probe(255); slot(3,0); slot(3,1); threshold_probe(255);
    for(int i=0;i<53;i++) begin slot(3,0); slot(3,2); end
    threshold_probe(0); slot(3,0); slot(3,2); threshold_probe(0);
   end
  endtask
  task body();
   default_history(); if(refined) refinement_history(); if(extended) extended_history(); if(saturation) saturation_history();
   current_mode=0; current_buttons=0; drive(0,0,0,0,8);
  endtask
 endclass
 class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  video_env env;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); env=video_env::type_id::create("env",this); uvm_root::get().set_timeout(2s,1); endfunction
  virtual function void configure(video_sequence s); endfunction
  task run_phase(uvm_phase phase);
   video_sequence s=video_sequence::type_id::create("sequence"); configure(s);
   phase.raise_objection(this); s.start(env.agent.sequencer); #2; phase.drop_objection(this);
  endtask
  function void final_phase(uvm_phase phase);
   uvm_report_server srv=uvm_report_server::get_server();
   if(srv.get_severity_count(UVM_ERROR)==0 && srv.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
  endfunction
 endclass
 class dvbench_extended_test extends dvbench_test;
  `uvm_component_utils(dvbench_extended_test)
  function new(string n,uvm_component p); super.new(n,p); endfunction
  virtual function void configure(video_sequence s); s.extended=1; endfunction
 endclass
 class dvbench_saturation_test extends dvbench_test;
  `uvm_component_utils(dvbench_saturation_test)
  function new(string n,uvm_component p); super.new(n,p); endfunction
  virtual function void configure(video_sequence s); s.extended=1; s.saturation=1; endfunction
 endclass
 class dvbench_refinement_test extends dvbench_test;
  `uvm_component_utils(dvbench_refinement_test)
  function new(string n,uvm_component p); super.new(n,p); endfunction
  virtual function void configure(video_sequence s); s.refined=1; endfunction
 endclass
 class dvbench_saturation_upper_test extends dvbench_test;
  `uvm_component_utils(dvbench_saturation_upper_test)
  function new(string n,uvm_component p); super.new(n,p); endfunction
  virtual function void configure(video_sequence s); s.saturation=1; s.saturation_side=1; endfunction
 endclass
 class dvbench_saturation_lower_test extends dvbench_test;
  `uvm_component_utils(dvbench_saturation_lower_test)
  function new(string n,uvm_component p); super.new(n,p); endfunction
  virtual function void configure(video_sequence s); s.saturation=1; s.saturation_side=2; endfunction
 endclass
endpackage
