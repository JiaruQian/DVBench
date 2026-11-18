package dvbench_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class fft_item extends uvm_sequence_item;
    `uvm_object_utils(fft_item)
    logic rst, m_we, s_re, check_en;
    logic [4:0] m_addr, s_addr;
    logic [15:0] m_data;
    logic [31:0] actual, expected;
    function new(string name="fft_item"); super.new(name); endfunction
  endclass

  class fft_driver extends uvm_driver #(fft_item);
    `uvm_component_utils(fft_driver)
    virtual fft_if vif;
    function new(string n,uvm_component p); super.new(n,p); endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        @(negedge vif.clk);
        vif.rst=req.rst; vif.m_we=req.m_we; vif.m_addr=req.m_addr;
        vif.m_data=req.m_data; vif.s_re=req.s_re; vif.s_addr=req.s_addr;
        vif.check_en=req.check_en;
        @(posedge vif.clk); #2;
        seq_item_port.item_done();
      end
    endtask
  endclass

  class fft_monitor extends uvm_monitor;
    `uvm_component_utils(fft_monitor)
    virtual fft_if vif;
    uvm_analysis_port #(fft_item) ap;
    function new(string n,uvm_component p); super.new(n,p); ap=new("ap",this); endfunction
    task run_phase(uvm_phase phase);
      fft_item item;
      forever begin
        @(posedge vif.clk); #1;
        item=fft_item::type_id::create("observed");
        item.rst=vif.rst; item.m_we=vif.m_we; item.m_addr=vif.m_addr;
        item.m_data=vif.m_data; item.s_re=vif.s_re; item.s_addr=vif.s_addr;
        item.check_en=vif.check_en; item.actual=vif.dut_data; item.expected=vif.model_data;
        ap.write(item);
      end
    endtask
  endclass

  class fft_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fft_scoreboard)
    uvm_analysis_imp #(fft_item,fft_scoreboard) imp;
    int comparisons;
    function new(string n,uvm_component p); super.new(n,p); imp=new("imp",this); endfunction
    function void write(fft_item item);
      if (item.check_en) begin
        comparisons++;
        if ($isunknown(item.actual) || $isunknown(item.expected) || item.actual !== item.expected)
          `uvm_error("FFT_COMPARE",$sformatf("read=%0b reset=%0b addr=%0d actual=%08x expected=%08x",
            item.s_re,item.rst,item.s_addr,item.actual,item.expected))
      end
    endfunction
    function void check_phase(uvm_phase phase);
      if(comparisons<200) `uvm_error("VACUITY","insufficient valid port comparisons")
      $display("FFT_COMPARISONS=%0d",comparisons);
    endfunction
  endclass

  class fft_coverage extends uvm_subscriber #(fft_item);
    `uvm_component_utils(fft_coverage)
    fft_item sample;
    covergroup pins;
      option.per_instance=1;
      write_address: coverpoint sample.m_addr iff(sample.m_we) { bins address[]={[0:31]}; }
      read_address: coverpoint sample.s_addr iff(sample.s_re && sample.check_en) {bins address[]={[0:31]};}
      sign: coverpoint sample.m_data[15] iff(sample.m_we);
      extrema: coverpoint sample.m_data iff(sample.m_we) {
        bins zero={0}; bins posmax={16'h7fff}; bins negmax={16'h8000};
        bins negative={16'h8001}; bins other=default;
      }
      reset: coverpoint sample.rst;
      read_enable: coverpoint sample.s_re;
      reset_read: cross reset,read_enable;
    endgroup
    function new(string n,uvm_component p); super.new(n,p); pins=new; endfunction
    function void write(fft_item item); sample=item; pins.sample(); endfunction
  endclass

  class fft_env extends uvm_env;
    `uvm_component_utils(fft_env)
    uvm_sequencer #(fft_item) sequencer;
    fft_driver driver;
    fft_monitor monitor;
    fft_scoreboard scoreboard;
    fft_coverage coverage;
    virtual fft_if vif;
    function new(string n,uvm_component p); super.new(n,p); endfunction
    function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(virtual fft_if)::get(this,"","vif",vif))
        `uvm_fatal("NOVIF","fft_if missing")
      sequencer=new("sequencer",this);
      driver=fft_driver::type_id::create("driver",this);
      monitor=fft_monitor::type_id::create("monitor",this);
      scoreboard=fft_scoreboard::type_id::create("scoreboard",this);
      coverage=fft_coverage::type_id::create("coverage",this);
      driver.vif=vif; monitor.vif=vif;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
      monitor.ap.connect(scoreboard.imp);
      monitor.ap.connect(coverage.analysis_export);
    endfunction
  endclass

  class fft_sequence extends uvm_sequence #(fft_item);
    `uvm_object_utils(fft_sequence)
    logic [31:0] input_digest=0;
    function new(string n="fft_sequence"); super.new(n); endfunction
    task tick(input bit reset=0,we=0,input logic[4:0] wa=0,
      input logic[15:0] data=0,input bit re=0,input logic[4:0] ra=0,input bit check=0);
      fft_item item=fft_item::type_id::create("drive");
      start_item(item);
      item.rst=reset; item.m_we=we; item.m_addr=wa; item.m_data=data;
      item.s_re=re; item.s_addr=ra; item.check_en=check;
      input_digest={input_digest[26:0],input_digest[31:27]} ^ {data,wa,ra,reset,we,re,check,2'b0};
      finish_item(item);
    endtask
    task frame(input int pattern);
      logic[15:0] data[32];
      int order[32],j,tmp;
      for(int i=0;i<32;i++) begin
        order[i]=i;
        case(pattern)
          0:data[i]=0;
          1:data[i]=(i==0)?16'h0100:0;
          2:data[i]=$urandom;
          3:data[i]=i[0]?16'h8001:16'h7fff;
          4:data[i]=(i==17)?16'h8000:0;
          default:data[i]=$urandom;
        endcase
      end
      for(int i=31;i>0;i--) begin
        j=$urandom_range(i,0); tmp=order[i]; order[i]=order[j]; order[j]=tmp;
      end
      for(int i=0;i<32;i++) tick(0,1,order[i],data[order[i]]);
      repeat(20) tick();
      for(int i=0;i<32;i++) tick(0,0,0,0,1,31-i,1);
      for(int i=0;i<32;i++) tick(0,0,i,$urandom,0,i,1);
      for(int i=0;i<32;i++) tick(0,0,0,0,1,i,1);
      tick(0,0,0,0,0,0,1);
    endtask
    task body();
      tick(1); tick(1); tick();
      for(int p=0;p<5;p++) frame(p);
      tick(1,0,0,0,0,17,1); tick(1,0,0,0,0,3,1);
      tick(0,0,0,0,0,9,1);
      frame(5);
      $display("FFT_INPUT_DIGEST=%08x",input_digest);
    endtask
  endclass

  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    fft_env env;
    function new(string n="dvbench_test",uvm_component p=null); super.new(n,p); endfunction
    function void build_phase(uvm_phase phase);
      env=fft_env::type_id::create("env",this);
      uvm_root::get().set_timeout(300us,1);
    endfunction
    task run_phase(uvm_phase phase);
      fft_sequence sequence_h=fft_sequence::type_id::create("sequence_h");
      phase.raise_objection(this);
      sequence_h.start(env.sequencer);
      phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      uvm_report_server server=uvm_report_server::get_server();
      if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)
        $display("DVBench_COMPLETED");
    endfunction
  endclass
endpackage
