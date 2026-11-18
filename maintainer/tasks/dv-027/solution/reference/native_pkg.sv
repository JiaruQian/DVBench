package native_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class native_transaction extends uvm_sequence_item;
    `uvm_object_utils(native_transaction)
    logic [20:0] inputs;
    logic [155:0] actual;
    integer scenario;
    function new(string name="native_transaction"); super.new(name); endfunction
  endclass
  class native_sequence extends uvm_sequence #(native_transaction);
    `uvm_object_utils(native_sequence)
    function new(string name="native_sequence"); super.new(name); endfunction
    integer system_halfperiod=5,pixel_halfperiod=7;
integer time_index=0, scenario=0, seed=1, pixel_count;
logic  clk;
logic  i_camera_reset;
logic  i_clk_locked;
logic  i_enable;
logic  i_hsync;
logic  i_image_debug_en;
logic  i_memory_ready;
logic  i_pix_clk;
logic [7:0] i_pix_data;
logic  i_reset_counts;
logic  i_rfifo_activate;
logic  i_rfifo_strobe;
logic  i_vsync;
logic  rst;
task advance(integer duration);
  repeat(duration) begin
    time_index++;
    if (time_index%system_halfperiod==0) clk=~clk; if (time_index%pixel_halfperiod==0) i_pix_clk=~i_pix_clk;
    send_event();
  end
endtask

    task send_event();
      native_transaction transaction;
      transaction=native_transaction::type_id::create("transaction");
      start_item(transaction); transaction.inputs={clk,i_camera_reset,i_clk_locked,i_enable,i_hsync,i_image_debug_en,i_memory_ready,i_pix_clk,i_pix_data,i_reset_counts,i_rfifo_activate,i_rfifo_strobe,i_vsync,rst}; transaction.scenario=scenario; finish_item(transaction);
    endtask

    virtual native_if pc5_pins;
    task pc5_reset();
      system_halfperiod=5; pixel_halfperiod=7;
      rst=1; i_camera_reset=0; i_clk_locked=0;
      i_rfifo_activate=0; i_rfifo_strobe=0;
      i_enable=0; i_memory_ready=0; i_hsync=0; i_vsync=0;
      advance(280);
      rst=0; i_camera_reset=1; i_clk_locked=1;
      advance(700);
    endtask
    task pc5_pixel(logic[7:0] value);
      while(i_pix_clk!==0) advance(1);
      i_pix_data=value; advance(2*pixel_halfperiod);
    endtask
    task pc5_pipeline_histories();
      if(!uvm_config_db#(virtual native_if)::get(null,"*","pins",pc5_pins))
        `uvm_fatal("CONFIG","Missing camera interface")
      scenario=20; pc5_reset();
      if(pc5_pins.expected_o_inactive!==1)
        `uvm_error("NONVACUITY","Empty FIFO must be visible before synchronous-reset pulse")
      rst=1; send_event();
      if(pc5_pins.expected_o_inactive!==1)
        `uvm_error("NONVACUITY","No-edge reset must preserve synchronized inactive output")
      rst=0; send_event(); advance(70);
      for(int trial=0;trial<4;trial++) begin
        scenario=21+trial; pc5_reset();
        i_enable=1; i_memory_ready=1; advance(140);
        i_vsync=1; i_hsync=1;
        for(int octet=0;octet<4;octet++) pc5_pixel(seed+octet*43+trial*17);
        i_enable=0;
        pc5_pixel(8'h5c);
        if(pc5_pins.expected_debug[5]!==1)
          `uvm_error("NONVACUITY","Completed pixel word must drain despite enable low")
        pc5_pixel(8'h5c);
        i_enable=1; i_hsync=0; advance(140);
        i_rfifo_activate=1; advance(100); i_rfifo_strobe=1; advance(40);
        i_rfifo_strobe=0; advance(30); i_rfifo_activate=0; advance(280);
        pc5_reset(); i_enable=1; i_memory_ready=1; advance(140);
        i_vsync=1; i_hsync=1;
        for(int octet=0;octet<4;octet++) pc5_pixel(seed+octet*31+trial*19);
        i_memory_ready=0;
        for(int octet=0;octet<4;octet++) pc5_pixel(seed+8'h80+octet*23+trial*29);
        pc5_pixel(8'h9a);
        if(pc5_pins.expected_debug[5]!==1)
          `uvm_error("NONVACUITY","Active frame must accept a word while memory_ready is low")
        i_hsync=0; advance(140);
        i_rfifo_activate=1; advance(100); i_rfifo_strobe=1; advance(60);
        i_rfifo_strobe=0; advance(30); i_rfifo_activate=0; advance(280);
      end
    endtask

    task body();
      clk='0;
i_camera_reset='0;
i_clk_locked='0;
i_enable='0;
i_hsync='0;
i_image_debug_en='0;
i_memory_ready='0;
i_pix_clk='0;
i_pix_data='0;
i_reset_counts='0;
i_rfifo_activate='0;
i_rfifo_strobe='0;
i_vsync='0;
rst='0;
      if($value$plusargs("ntb_random_seed=%d",seed)) begin end
            rst=1; i_camera_reset=0; i_clk_locked=0;
      advance(280);
      rst=0; i_camera_reset=1; i_clk_locked=1;
      i_enable=0; i_memory_ready=0; i_vsync=1; i_hsync=1;
      scenario=19;
      advance(14*65537);
      i_hsync=0; advance(28);
      rst=1; i_camera_reset=0; i_clk_locked=0;
      i_vsync=0; i_hsync=0; advance(280);
      rst=0; i_camera_reset=1; i_clk_locked=1; i_enable=1; i_memory_ready=1;
      advance(700);
      for (integer run_index=0; run_index<12; run_index++) begin
        scenario=run_index;
        i_image_debug_en=(run_index%3 == 1);
        if (run_index%4 == 0) begin
          i_memory_ready=0; advance(14*(run_index+1)); i_memory_ready=1; advance(280);
        end
        i_vsync=1;
        for (integer line_index=0; line_index<4; line_index++) begin
          pixel_count = run_index == 8 ? 16384 : run_index == 9 ? 16404 : ((run_index*7+line_index*3)%31)+1;
          for (integer pixel_index=0; pixel_index<pixel_count; pixel_index++) begin
            while (i_pix_clk !== 0) advance(1);
            i_hsync=1;
            i_pix_data=(pixel_index*29+seed*17+line_index*53+run_index)%256;
            advance(14);
          end
          i_hsync=0; advance(280);
          if (line_index%2 == 1 || run_index%2 == 0) begin
            i_rfifo_activate=1; advance(100);
            for (integer read_index=0; read_index<(pixel_count/4)+8; read_index++) begin
              i_rfifo_strobe=1; advance(10);
              if (read_index%3 != 1) begin i_rfifo_strobe=0; advance(20); end
            end
            i_rfifo_strobe=0; advance(50); i_rfifo_activate=0; advance(700);
          end
        end
        i_vsync=0; i_hsync=0;
        advance(700);
        i_rfifo_activate=1; i_rfifo_strobe=1; advance(100); i_rfifo_strobe=0; advance(30); i_rfifo_activate=0; advance(700);
        i_reset_counts=1; advance(28); i_reset_counts=0;
        if (run_index == 3) begin rst=1; advance(140); rst=0; advance(700); end
        if (run_index == 5) begin i_camera_reset=0; advance(140); i_camera_reset=1; advance(700); end
        if (run_index == 7) begin i_clk_locked=0; advance(280); i_clk_locked=1; advance(700); end
        i_enable=0; i_vsync=1; i_hsync=1; advance(70); i_hsync=0; i_vsync=0; advance(280); i_enable=1;
      end


      for(integer boundary_index=0;boundary_index<7;boundary_index++) begin
        scenario=12+boundary_index;
        system_halfperiod=4+boundary_index%3;pixel_halfperiod=6+boundary_index%4;
        rst=1; i_camera_reset=0; i_clk_locked=0; i_rfifo_activate=0; i_rfifo_strobe=0;
        i_hsync=0; i_vsync=0; advance(280);
        rst=0; i_camera_reset=1; i_clk_locked=1; i_memory_ready=1; i_enable=1; advance(700);
        i_vsync=1;
        for(integer line_index=0;line_index<3;line_index++) begin
          pixel_count=boundary_index==0 ? line_index+1 : boundary_index==1 ? 4 : boundary_index==2 ? 5 : boundary_index==3 ? 7 : boundary_index==4 ? 16380 : boundary_index==5 ? 16384 : 16388;
          for(integer pixel_index=0;pixel_index<pixel_count;pixel_index++) begin
            while(i_pix_clk!==0) advance(1);
            i_hsync=1; i_pix_data=(pixel_index*37+seed*11+line_index*79)%256; advance(2*pixel_halfperiod);
            if(pixel_index==2 && boundary_index==2) begin i_enable=0;advance(70);i_enable=1;end
          end
          i_hsync=0;advance(280);
        end
        i_vsync=0;advance(700);
        for(integer bank_index=0;bank_index<2;bank_index++) begin
          i_rfifo_activate=1;advance(100);
          for(integer read_index=0;read_index<4104;read_index++) begin
            i_rfifo_strobe=1;advance(2*system_halfperiod);
            if(read_index%7==0) begin i_rfifo_strobe=0;advance(30);end
          end
          i_rfifo_strobe=0;advance(50);i_rfifo_activate=0;advance(700);
        end
        i_vsync=1;i_hsync=1;advance(112);i_hsync=0;advance(280);i_vsync=0;advance(700);
        i_reset_counts=1;i_hsync=1;advance(28);i_hsync=0;advance(14);i_reset_counts=0;advance(280);
      end
      pc5_pipeline_histories();
    endtask
  endclass

  class native_driver extends uvm_driver #(native_transaction);
    `uvm_component_utils(native_driver)
    virtual native_if pins;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(virtual native_if)::get(this,"","pins",pins)) `uvm_fatal("CONFIG","pins")
    endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        {pins.clk,pins.i_camera_reset,pins.i_clk_locked,pins.i_enable,pins.i_hsync,pins.i_image_debug_en,pins.i_memory_ready,pins.i_pix_clk,pins.i_pix_data,pins.i_reset_counts,pins.i_rfifo_activate,pins.i_rfifo_strobe,pins.i_vsync,pins.rst}=req.inputs; pins.scenario=req.scenario;
        #0.1; pins.sample_toggle=~pins.sample_toggle; #0.9;
        seq_item_port.item_done();
      end
    endtask
  endclass
  class native_monitor extends uvm_component;
    `uvm_component_utils(native_monitor)
    virtual native_if pins;
    uvm_analysis_port #(native_transaction) observations;
    function new(string name,uvm_component parent); super.new(name,parent); observations=new("observations",this); endfunction
    function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(virtual native_if)::get(this,"","pins",pins)) `uvm_fatal("CONFIG","pins")
    endfunction
    task run_phase(uvm_phase phase);
      native_transaction transaction;
      forever begin
        @(pins.sample_toggle);
        transaction=native_transaction::type_id::create("observed");
        transaction.inputs={pins.clk,pins.i_camera_reset,pins.i_clk_locked,pins.i_enable,pins.i_hsync,pins.i_image_debug_en,pins.i_memory_ready,pins.i_pix_clk,pins.i_pix_data,pins.i_reset_counts,pins.i_rfifo_activate,pins.i_rfifo_strobe,pins.i_vsync,pins.rst}; transaction.actual={pins.actual_debug,pins.actual_o_busy,pins.actual_o_captured,pins.actual_o_inactive,pins.actual_o_pixel_count,pins.actual_o_rfifo_data,pins.actual_o_rfifo_ready,pins.actual_o_rfifo_size,pins.actual_o_row_count}; transaction.scenario=pins.scenario;
        observations.write(transaction);
      end
    endtask
  endclass
  class native_predictor extends uvm_component;
    `uvm_component_utils(native_predictor)
    virtual native_if pins;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(virtual native_if)::get(this,"","pins",pins)) `uvm_fatal("CONFIG","pins")
    endfunction
    function logic [155:0] predict(); return {pins.expected_debug,pins.expected_o_busy,pins.expected_o_captured,pins.expected_o_inactive,pins.expected_o_pixel_count,pins.expected_o_rfifo_data,pins.expected_o_rfifo_ready,pins.expected_o_rfifo_size,pins.expected_o_row_count}; endfunction
  endclass
  class native_scoreboard extends uvm_subscriber #(native_transaction);
    `uvm_component_utils(native_scoreboard)
    native_predictor predictor;
    integer samples=0, differences=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void write(native_transaction transaction);
      logic [155:0] expected;
      samples++; expected=predictor.predict();
      if(transaction.actual !== expected) begin
        differences++;
        if(differences<=25) `uvm_error("NATIVE_DIFF",$sformatf("sample=%0d scenario=%0d input=%h actual=%h expected=%h",samples,transaction.scenario,transaction.inputs,transaction.actual,expected))
      end
    endfunction
    function void check_phase(uvm_phase phase);
      $display("MODEL_COMPARISON differences=%0d samples=%0d",differences,samples);
      if(samples<100 || differences>0) `uvm_error("CHECK_SUMMARY",$sformatf("differences=%0d samples=%0d",differences,samples))
    endfunction
  endclass
  class native_checker extends uvm_subscriber #(native_transaction);
    `uvm_component_utils(native_checker)
    integer received=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void write(native_transaction transaction); received++; endfunction
    function void check_phase(uvm_phase phase); if(received<100) `uvm_error("VACUOUS","insufficient input history") endfunction
  endclass
  class native_coverage extends uvm_subscriber #(native_transaction);
    `uvm_component_utils(native_coverage)
    covergroup scenarios with function sample(integer scenario);
      histories: coverpoint scenario { bins histories[]={[0:18]}; }
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent); scenarios=new(); endfunction
    function void write(native_transaction transaction); scenarios.sample(transaction.scenario); endfunction
  endclass
  class native_env extends uvm_env;
    `uvm_component_utils(native_env)
    uvm_sequencer #(native_transaction) sequencer;
    native_driver driver; native_monitor monitor; native_predictor predictor; native_scoreboard scoreboard; native_checker checker; native_coverage coverage;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      sequencer=new("sequencer",this);
      driver=native_driver::type_id::create("driver",this); monitor=native_monitor::type_id::create("monitor",this);
      predictor=native_predictor::type_id::create("predictor",this); scoreboard=native_scoreboard::type_id::create("scoreboard",this);
      checker=native_checker::type_id::create("checker",this); coverage=native_coverage::type_id::create("coverage",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export); scoreboard.predictor=predictor;
      monitor.observations.connect(scoreboard.analysis_export); monitor.observations.connect(checker.analysis_export); monitor.observations.connect(coverage.analysis_export);
    endfunction
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    native_env environment;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); environment=native_env::type_id::create("environment",this); endfunction
    task run_phase(uvm_phase phase);
      native_sequence sequence_instance;
      phase.raise_objection(this); sequence_instance=native_sequence::type_id::create("sequence_instance");
      sequence_instance.start(environment.sequencer); #2; phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
      uvm_report_server server; server=uvm_report_server::get_server();
      if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
    endfunction
  endclass
endpackage
