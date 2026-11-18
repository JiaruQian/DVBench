`timescale 1ns/1ps
interface dvbench_if(input logic clk);
  logic [48-1:0] stimulus='0;
  wire [216-1:0] actual,expected,mask;
endinterface

package dvbench_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class drive_item extends uvm_sequence_item;
    `uvm_object_utils(drive_item)
    bit [48-1:0] inputs;
    int unsigned cycles;
    function new(string name="drive_item"); super.new(name); endfunction
  endclass
  class observed_item extends uvm_sequence_item;
    `uvm_object_utils(observed_item)
    logic [216-1:0] actual,expected,mask;
    longint unsigned cycle;
    function new(string name="observed_item"); super.new(name); endfunction
  endclass
  class stimulus_sequence extends uvm_sequence #(drive_item);
    `uvm_object_utils(stimulus_sequence)
    function new(string name="stimulus_sequence"); super.new(name); endfunction
    task drive(bit [48-1:0] inputs,int unsigned cycles=1);
      drive_item item=drive_item::type_id::create("item");
      start_item(item); item.inputs=inputs; item.cycles=cycles; finish_item(item);
    endtask
    task send(input bit reset_value,input bit [15:0] distance,input bit strobe,input bit [15:0] angle,input bit sweep,input bit [11:0] logo,input bit bank,input int cycles=1);
      drive({reset_value,distance,strobe,angle,sweep,logo,bank},cycles);
    endtask
    task body();
      send(1,0,0,0,0,12'h15a,0,10);
      send(0,0,0,0,0,12'h15a,0,65560);
      for(int hit_index=0;hit_index<24;hit_index++) begin
        send(0,817,1,16'h6837,0,12'h15a,0);
        send(0,817,0,16'h6837,0,12'h15a,0,7);
      end
      for(int hit_index=0;hit_index<256;hit_index++) begin
        send(0,hit_index*257,1,hit_index*256+37,0,hit_index,0);
        send(0,0,0,0,0,hit_index,0,6);
      end
      send(0,0,0,0,0,12'ha53,0,1680000);
      send(0,0,0,0,1,12'h72c,1);
      for(int hit_index=0;hit_index<300;hit_index++) begin
        send(0,$urandom,1,$urandom,hit_index==150,$urandom,1);
        send(0,0,0,0,0,$urandom,1,hit_index%5+1);
      end
      send(0,0,0,0,0,12'h4ae,1,70000);
      send(0,0,0,0,0,12'h4ae,1,1680000);
      for(int hit_index=0;hit_index<600;hit_index++)
        send(0,$urandom,1,$urandom,0,$urandom,hit_index%2);
      send(0,0,0,0,0,12'hf96,0,1680000);
      send(1,0,1,0,1,0,0,5);
      send(0,0,0,0,0,12'h136,1,65560);
      send(0,0,0,0,0,12'h136,1,1680000);
    endtask
  endclass
  class native_driver extends uvm_driver #(drive_item);
    `uvm_component_utils(native_driver)
    virtual dvbench_if vif;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual dvbench_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","Missing native interface")
    endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge vif.clk); vif.stimulus=req.inputs;
        repeat(req.cycles) @(posedge vif.clk);
        seq_item_port.item_done();
      end
    endtask
  endclass
  class native_monitor extends uvm_monitor;
    `uvm_component_utils(native_monitor)
    virtual dvbench_if vif;
    uvm_analysis_port#(observed_item) observations;
    longint unsigned cycle=0;
    function new(string name,uvm_component parent); super.new(name,parent); observations=new("observations",this); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual dvbench_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","Missing native interface")
    endfunction
    task run_phase(uvm_phase phase);
      observed_item sample;
      forever begin
        @(posedge vif.clk); #1; cycle++;
        if(cycle>40) begin
          sample=observed_item::type_id::create("sample");
          sample.actual=vif.actual; sample.expected=vif.expected; sample.mask=vif.mask; sample.cycle=cycle;
          observations.write(sample);
        end
      end
    endtask
  endclass
  class independent_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(independent_scoreboard)
    uvm_analysis_imp#(observed_item,independent_scoreboard) observations;
    longint unsigned comparisons=0,mismatches=0,active_samples=0;
    function new(string name,uvm_component parent); super.new(name,parent); observations=new("observations",this); endfunction
    function void write(observed_item sample);
      comparisons++;
      if(sample.actual!=0 && sample.mask!=0) active_samples++;
      if((sample.actual&sample.mask)!==(sample.expected&sample.mask)) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("PREDICTION",$sformatf("cycle=%0d actual=%h expected=%h mask=%h",sample.cycle,sample.actual,sample.expected,sample.mask))
      end
    endfunction
    function void check_phase(uvm_phase phase);
      super.check_phase(phase);
      if(comparisons<6000000 || active_samples<1000) `uvm_error("NONVACUITY","Insufficient sampled activity")
    endfunction
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      $display("REFERENCE_RESULT comparisons=%0d mismatches=%0d active_samples=%0d",comparisons,mismatches,active_samples);
    endfunction
  endclass
  class native_agent extends uvm_agent;
    `uvm_component_utils(native_agent)
    uvm_sequencer#(drive_item) sequencer;
    native_driver driver;
    native_monitor monitor;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer=uvm_sequencer#(drive_item)::type_id::create("sequencer",this);
      driver=native_driver::type_id::create("driver",this);
      monitor=native_monitor::type_id::create("monitor",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase); driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
  endclass
  class verification_environment extends uvm_env;
    `uvm_component_utils(verification_environment)
    native_agent agent;
    independent_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent=native_agent::type_id::create("agent",this);
      scoreboard=independent_scoreboard::type_id::create("scoreboard",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase); agent.monitor.observations.connect(scoreboard.observations);
    endfunction
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    verification_environment environment;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); environment=verification_environment::type_id::create("environment",this);
    endfunction
    task run_phase(uvm_phase phase);
      stimulus_sequence sequence_instance=stimulus_sequence::type_id::create("sequence_instance");
      phase.raise_objection(this); sequence_instance.start(environment.agent.sequencer);
      #20; phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      uvm_report_server server;
      super.report_phase(phase); server=uvm_report_server::get_server();
      if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) begin
        $display("DVBench_COMPLETED"); $display("NATIVE_TEST_PASS");
      end
    endfunction
  endclass
endpackage

module dvbench_top;
  import uvm_pkg::*;
  import dvbench_pkg::*;
  reg clk=0;
  always #5 clk=~clk;
  dvbench_if bus(clk);
  wire rst_sys,dist_vld,sweep_wrap,logo_buf_sel;
  wire [15:0] dist_mm,theta_q15;
  wire [11:0] logo_rgb;
  assign {rst_sys,dist_mm,dist_vld,theta_q15,sweep_wrap,logo_rgb,logo_buf_sel}=bus.stimulus;
  wire [0:0] actual_0_pix_clk;
  wire [9:0] actual_0_hcount;
  wire [9:0] actual_0_vcount;
  wire [0:0] actual_0_active_video;
  wire [0:0] actual_0_frame_tick;
  wire [0:0] actual_0_vga_hsync_n;
  wire [0:0] actual_0_vga_vsync_n;
  wire [11:0] actual_0_rgb_plot;
  wire [8:0] actual_0_logo_x;
  wire [7:0] actual_0_logo_y;
  vga_range_plot_top #(.R_MAX_MM(2000)) actual_0(.clk_100mhz(clk),.rst_sys(rst_sys),.dist_mm(dist_mm),.dist_vld(dist_vld),.theta_q15(theta_q15),.sweep_wrap(sweep_wrap),.logo_rgb(logo_rgb),.logo_buf_sel(logo_buf_sel),.pix_clk(actual_0_pix_clk),.hcount(actual_0_hcount),.vcount(actual_0_vcount),.active_video(actual_0_active_video),.frame_tick(actual_0_frame_tick),.vga_hsync_n(actual_0_vga_hsync_n),.vga_vsync_n(actual_0_vga_vsync_n),.rgb_plot(actual_0_rgb_plot),.logo_x(actual_0_logo_x),.logo_y(actual_0_logo_y));
  assign bus.actual[0+:54]={actual_0_pix_clk,actual_0_hcount,actual_0_vcount,actual_0_active_video,actual_0_frame_tick,actual_0_vga_hsync_n,actual_0_vga_vsync_n,actual_0_rgb_plot,actual_0_logo_x,actual_0_logo_y};
  wire [0:0] expected_0_pix_clk;
  wire [9:0] expected_0_hcount;
  wire [9:0] expected_0_vcount;
  wire [0:0] expected_0_active_video;
  wire [0:0] expected_0_frame_tick;
  wire [0:0] expected_0_vga_hsync_n;
  wire [0:0] expected_0_vga_vsync_n;
  wire [11:0] expected_0_rgb_plot;
  wire [8:0] expected_0_logo_x;
  wire [7:0] expected_0_logo_y;
  dvbench_model #(.R_MAX_MM(2000)) expected_0(.clk_100mhz(clk),.rst_sys(rst_sys),.dist_mm(dist_mm),.dist_vld(dist_vld),.theta_q15(theta_q15),.sweep_wrap(sweep_wrap),.logo_rgb(logo_rgb),.logo_buf_sel(logo_buf_sel),.pix_clk(expected_0_pix_clk),.hcount(expected_0_hcount),.vcount(expected_0_vcount),.active_video(expected_0_active_video),.frame_tick(expected_0_frame_tick),.vga_hsync_n(expected_0_vga_hsync_n),.vga_vsync_n(expected_0_vga_vsync_n),.rgb_plot(expected_0_rgb_plot),.logo_x(expected_0_logo_x),.logo_y(expected_0_logo_y));
  assign bus.expected[0+:54]={expected_0_pix_clk,expected_0_hcount,expected_0_vcount,expected_0_active_video,expected_0_frame_tick,expected_0_vga_hsync_n,expected_0_vga_vsync_n,expected_0_rgb_plot,expected_0_logo_x,expected_0_logo_y};
  wire [0:0] actual_1_pix_clk;
  wire [9:0] actual_1_hcount;
  wire [9:0] actual_1_vcount;
  wire [0:0] actual_1_active_video;
  wire [0:0] actual_1_frame_tick;
  wire [0:0] actual_1_vga_hsync_n;
  wire [0:0] actual_1_vga_vsync_n;
  wire [11:0] actual_1_rgb_plot;
  wire [8:0] actual_1_logo_x;
  wire [7:0] actual_1_logo_y;
  vga_range_plot_top #(.R_MAX_MM(255)) actual_1(.clk_100mhz(clk),.rst_sys(rst_sys),.dist_mm(dist_mm),.dist_vld(dist_vld),.theta_q15(theta_q15),.sweep_wrap(sweep_wrap),.logo_rgb(logo_rgb),.logo_buf_sel(logo_buf_sel),.pix_clk(actual_1_pix_clk),.hcount(actual_1_hcount),.vcount(actual_1_vcount),.active_video(actual_1_active_video),.frame_tick(actual_1_frame_tick),.vga_hsync_n(actual_1_vga_hsync_n),.vga_vsync_n(actual_1_vga_vsync_n),.rgb_plot(actual_1_rgb_plot),.logo_x(actual_1_logo_x),.logo_y(actual_1_logo_y));
  assign bus.actual[54+:54]={actual_1_pix_clk,actual_1_hcount,actual_1_vcount,actual_1_active_video,actual_1_frame_tick,actual_1_vga_hsync_n,actual_1_vga_vsync_n,actual_1_rgb_plot,actual_1_logo_x,actual_1_logo_y};
  wire [0:0] expected_1_pix_clk;
  wire [9:0] expected_1_hcount;
  wire [9:0] expected_1_vcount;
  wire [0:0] expected_1_active_video;
  wire [0:0] expected_1_frame_tick;
  wire [0:0] expected_1_vga_hsync_n;
  wire [0:0] expected_1_vga_vsync_n;
  wire [11:0] expected_1_rgb_plot;
  wire [8:0] expected_1_logo_x;
  wire [7:0] expected_1_logo_y;
  dvbench_model #(.R_MAX_MM(255)) expected_1(.clk_100mhz(clk),.rst_sys(rst_sys),.dist_mm(dist_mm),.dist_vld(dist_vld),.theta_q15(theta_q15),.sweep_wrap(sweep_wrap),.logo_rgb(logo_rgb),.logo_buf_sel(logo_buf_sel),.pix_clk(expected_1_pix_clk),.hcount(expected_1_hcount),.vcount(expected_1_vcount),.active_video(expected_1_active_video),.frame_tick(expected_1_frame_tick),.vga_hsync_n(expected_1_vga_hsync_n),.vga_vsync_n(expected_1_vga_vsync_n),.rgb_plot(expected_1_rgb_plot),.logo_x(expected_1_logo_x),.logo_y(expected_1_logo_y));
  assign bus.expected[54+:54]={expected_1_pix_clk,expected_1_hcount,expected_1_vcount,expected_1_active_video,expected_1_frame_tick,expected_1_vga_hsync_n,expected_1_vga_vsync_n,expected_1_rgb_plot,expected_1_logo_x,expected_1_logo_y};
  wire [0:0] actual_2_pix_clk;
  wire [9:0] actual_2_hcount;
  wire [9:0] actual_2_vcount;
  wire [0:0] actual_2_active_video;
  wire [0:0] actual_2_frame_tick;
  wire [0:0] actual_2_vga_hsync_n;
  wire [0:0] actual_2_vga_vsync_n;
  wire [11:0] actual_2_rgb_plot;
  wire [8:0] actual_2_logo_x;
  wire [7:0] actual_2_logo_y;
  vga_range_plot_top #(.R_MAX_MM(0)) actual_2(.clk_100mhz(clk),.rst_sys(rst_sys),.dist_mm(dist_mm),.dist_vld(dist_vld),.theta_q15(theta_q15),.sweep_wrap(sweep_wrap),.logo_rgb(logo_rgb),.logo_buf_sel(logo_buf_sel),.pix_clk(actual_2_pix_clk),.hcount(actual_2_hcount),.vcount(actual_2_vcount),.active_video(actual_2_active_video),.frame_tick(actual_2_frame_tick),.vga_hsync_n(actual_2_vga_hsync_n),.vga_vsync_n(actual_2_vga_vsync_n),.rgb_plot(actual_2_rgb_plot),.logo_x(actual_2_logo_x),.logo_y(actual_2_logo_y));
  assign bus.actual[108+:54]={actual_2_pix_clk,actual_2_hcount,actual_2_vcount,actual_2_active_video,actual_2_frame_tick,actual_2_vga_hsync_n,actual_2_vga_vsync_n,actual_2_rgb_plot,actual_2_logo_x,actual_2_logo_y};
  wire [0:0] expected_2_pix_clk;
  wire [9:0] expected_2_hcount;
  wire [9:0] expected_2_vcount;
  wire [0:0] expected_2_active_video;
  wire [0:0] expected_2_frame_tick;
  wire [0:0] expected_2_vga_hsync_n;
  wire [0:0] expected_2_vga_vsync_n;
  wire [11:0] expected_2_rgb_plot;
  wire [8:0] expected_2_logo_x;
  wire [7:0] expected_2_logo_y;
  dvbench_model #(.R_MAX_MM(0)) expected_2(.clk_100mhz(clk),.rst_sys(rst_sys),.dist_mm(dist_mm),.dist_vld(dist_vld),.theta_q15(theta_q15),.sweep_wrap(sweep_wrap),.logo_rgb(logo_rgb),.logo_buf_sel(logo_buf_sel),.pix_clk(expected_2_pix_clk),.hcount(expected_2_hcount),.vcount(expected_2_vcount),.active_video(expected_2_active_video),.frame_tick(expected_2_frame_tick),.vga_hsync_n(expected_2_vga_hsync_n),.vga_vsync_n(expected_2_vga_vsync_n),.rgb_plot(expected_2_rgb_plot),.logo_x(expected_2_logo_x),.logo_y(expected_2_logo_y));
  assign bus.expected[108+:54]={expected_2_pix_clk,expected_2_hcount,expected_2_vcount,expected_2_active_video,expected_2_frame_tick,expected_2_vga_hsync_n,expected_2_vga_vsync_n,expected_2_rgb_plot,expected_2_logo_x,expected_2_logo_y};
  wire [0:0] actual_3_pix_clk;
  wire [9:0] actual_3_hcount;
  wire [9:0] actual_3_vcount;
  wire [0:0] actual_3_active_video;
  wire [0:0] actual_3_frame_tick;
  wire [0:0] actual_3_vga_hsync_n;
  wire [0:0] actual_3_vga_vsync_n;
  wire [11:0] actual_3_rgb_plot;
  wire [8:0] actual_3_logo_x;
  wire [7:0] actual_3_logo_y;
  vga_range_plot_top #(.R_MAX_MM(65535)) actual_3(.clk_100mhz(clk),.rst_sys(rst_sys),.dist_mm(dist_mm),.dist_vld(dist_vld),.theta_q15(theta_q15),.sweep_wrap(sweep_wrap),.logo_rgb(logo_rgb),.logo_buf_sel(logo_buf_sel),.pix_clk(actual_3_pix_clk),.hcount(actual_3_hcount),.vcount(actual_3_vcount),.active_video(actual_3_active_video),.frame_tick(actual_3_frame_tick),.vga_hsync_n(actual_3_vga_hsync_n),.vga_vsync_n(actual_3_vga_vsync_n),.rgb_plot(actual_3_rgb_plot),.logo_x(actual_3_logo_x),.logo_y(actual_3_logo_y));
  assign bus.actual[162+:54]={actual_3_pix_clk,actual_3_hcount,actual_3_vcount,actual_3_active_video,actual_3_frame_tick,actual_3_vga_hsync_n,actual_3_vga_vsync_n,actual_3_rgb_plot,actual_3_logo_x,actual_3_logo_y};
  wire [0:0] expected_3_pix_clk;
  wire [9:0] expected_3_hcount;
  wire [9:0] expected_3_vcount;
  wire [0:0] expected_3_active_video;
  wire [0:0] expected_3_frame_tick;
  wire [0:0] expected_3_vga_hsync_n;
  wire [0:0] expected_3_vga_vsync_n;
  wire [11:0] expected_3_rgb_plot;
  wire [8:0] expected_3_logo_x;
  wire [7:0] expected_3_logo_y;
  dvbench_model #(.R_MAX_MM(65535)) expected_3(.clk_100mhz(clk),.rst_sys(rst_sys),.dist_mm(dist_mm),.dist_vld(dist_vld),.theta_q15(theta_q15),.sweep_wrap(sweep_wrap),.logo_rgb(logo_rgb),.logo_buf_sel(logo_buf_sel),.pix_clk(expected_3_pix_clk),.hcount(expected_3_hcount),.vcount(expected_3_vcount),.active_video(expected_3_active_video),.frame_tick(expected_3_frame_tick),.vga_hsync_n(expected_3_vga_hsync_n),.vga_vsync_n(expected_3_vga_vsync_n),.rgb_plot(expected_3_rgb_plot),.logo_x(expected_3_logo_x),.logo_y(expected_3_logo_y));
  assign bus.expected[162+:54]={expected_3_pix_clk,expected_3_hcount,expected_3_vcount,expected_3_active_video,expected_3_frame_tick,expected_3_vga_hsync_n,expected_3_vga_vsync_n,expected_3_rgb_plot,expected_3_logo_x,expected_3_logo_y};
  assign bus.mask='1;
  initial begin
    uvm_config_db#(virtual dvbench_if)::set(null,"*","vif",bus);
    run_test("dvbench_test");
  end
endmodule
