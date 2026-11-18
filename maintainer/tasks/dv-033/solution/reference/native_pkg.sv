package native_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class native_transaction extends uvm_sequence_item;
    `uvm_object_utils(native_transaction)
    logic [69:0] inputs;
    logic [414:0] actual;
    integer scenario;
    function new(string name="native_transaction"); super.new(name); endfunction
  endclass
  class native_sequence extends uvm_sequence #(native_transaction);
    `uvm_object_utils(native_sequence)
    function new(string name="native_sequence"); super.new(name); endfunction
    integer time_index=0, scenario=0, seed=1, pixel_count;
logic  SPI_CLK;
logic  SPI_MOSI;
logic  SPI_SS_IO;
logic  clk_sd;
logic  clk_sys;
logic [7:0] conf_chr;
logic [-1:0] conf_str;
logic  sd_conf;
logic [7:0] sd_din;
logic [31:0] sd_lba;
logic [1:0] sd_rd;
logic  sd_sdhc;
logic [1:0] sd_wr;
logic [7:0] serial_data;
logic  serial_strobe;
task advance(integer duration);
  repeat(duration) begin
    time_index++;
    if (time_index%5==0) clk_sys=~clk_sys; if (time_index%7==0) clk_sd=~clk_sd;
    send_event();
  end
endtask
task spi_byte(input logic [7:0] value);
  for(integer bit_index=7;bit_index>=0;bit_index--) begin
    SPI_CLK=0; SPI_MOSI=value[bit_index]; advance(50);
    SPI_CLK=1; advance(50);
  end
endtask

    task send_event();
      native_transaction transaction;
      transaction=native_transaction::type_id::create("transaction");
      start_item(transaction); transaction.inputs={SPI_CLK,SPI_MOSI,SPI_SS_IO,clk_sd,clk_sys,conf_chr,conf_str,sd_conf,sd_din,sd_lba,sd_rd,sd_sdhc,sd_wr,serial_data,serial_strobe}; transaction.scenario=scenario; finish_item(transaction);
    endtask
    task body();
      SPI_CLK='0;
SPI_MOSI='0;
SPI_SS_IO='0;
clk_sd='0;
clk_sys='0;
conf_chr='0;
conf_str='0;
sd_conf='0;
sd_din='0;
sd_lba='0;
sd_rd='0;
sd_sdhc='0;
sd_wr='0;
serial_data='0;
serial_strobe='0;
      if($value$plusargs("ntb_random_seed=%d",seed)) begin end
            SPI_CLK=1; SPI_SS_IO=1; conf_chr=8'h9d; sd_conf=1; sd_sdhc=1; sd_din=8'hc7;
      advance(400);
      for(integer run_index=0;run_index<12;run_index++) begin
        scenario=run_index;
        for(integer joy_index=0;joy_index<5;joy_index++) begin
          SPI_SS_IO=0; advance(100); spi_byte(8'h60+joy_index);
          for(integer octet=0;octet<6;octet++) spi_byte(run_index*17+octet*29+seed);
          SPI_SS_IO=1; advance(400);
        end
        SPI_SS_IO=0; advance(100); spi_byte(8'h01); spi_byte(seed+run_index*19); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h1a); spi_byte(run_index); spi_byte(8'ha3^seed); spi_byte(8'h75^run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h15); spi_byte(1); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h15); spi_byte(0); SPI_SS_IO=1; advance(400);
        for(integer octet=0;octet<run_index+1;octet++) begin
          serial_data=octet*13+seed; serial_strobe=1; advance(20); serial_strobe=0; advance(20);
        end
        SPI_SS_IO=0; advance(100); spi_byte(8'h1b); for(integer octet=0;octet<30;octet++) spi_byte(0); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h1e); for(integer octet=0;octet<6;octet++) spi_byte((seed+octet*31+run_index)&8'hfe); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h22); for(integer octet=0;octet<10;octet++) spi_byte(seed+octet+run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h21); spi_byte(8'hff-run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h05); spi_byte(8'he0); spi_byte(8'hf0); spi_byte(8'h75^run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h05); spi_byte(8'h1c+run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h70+(run_index%2)); spi_byte(8'h38^run_index); spi_byte(8'h80^seed); spi_byte(8'hfe-run_index); spi_byte(8'hfa); SPI_SS_IO=1; advance(400);
        sd_lba=32'h12345678^(seed*run_index); sd_rd=run_index%4; sd_wr=(run_index+1)%4;
        SPI_SS_IO=0; advance(100); spi_byte(8'h16); sd_lba=32'habcdef12; for(integer octet=0;octet<8;octet++) spi_byte(0); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h14); for(integer octet=0;octet<8;octet++) begin conf_chr=octet*11+seed; spi_byte(0); end SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h1c); spi_byte(run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h1d); for(integer octet=0;octet<6;octet++) spi_byte(octet*53+seed); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h17); for(integer octet=0;octet<(run_index==11 ? 1030 : 7);octet++) spi_byte(octet+seed); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h19); for(integer octet=0;octet<8;octet++) spi_byte(octet*7+seed); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h18); for(integer octet=0;octet<(run_index==11 ? 520 : 7);octet++) begin sd_din=octet+seed; spi_byte(0); end SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'hff); spi_byte(8'h5a); SPI_SS_IO=1; advance(400);
      end


      for(integer length_index=0;length_index<5;length_index++) begin
        scenario=12+length_index;
        SPI_SS_IO=0;advance(100);spi_byte(8'h15);spi_byte(1);SPI_SS_IO=1;advance(400);
        SPI_SS_IO=0;advance(100);spi_byte(8'h15);spi_byte(0);SPI_SS_IO=1;advance(400);
        pixel_count=length_index==0 ? 0 : length_index==1 ? 1 : length_index==2 ? 63 : length_index==3 ? 64 : 65;
        for(integer octet=0;octet<pixel_count;octet++) begin
          serial_data=octet*19+seed;serial_strobe=1;advance(20);serial_strobe=0;advance(20);
        end
        SPI_SS_IO=0;advance(100);spi_byte(8'h1b);for(integer octet=0;octet<140;octet++) spi_byte(0);SPI_SS_IO=1;advance(400);
      end
      for(integer index=0;index<16;index++) begin
        scenario=17;
        SPI_SS_IO=0;advance(100);spi_byte(8'h1a);spi_byte(index);spi_byte(seed^index);SPI_SS_IO=1;advance(400);
        SPI_SS_IO=0;advance(100);spi_byte(8'h1a);spi_byte(index);spi_byte(seed+index);spi_byte(8'h80^index);spi_byte(0);SPI_SS_IO=1;advance(400);
      end
      for(integer joy_index=0;joy_index<5;joy_index++) begin
        scenario=18;
        for(integer length=1;length<5;length++) begin
          SPI_SS_IO=0;advance(100);spi_byte(8'h60+joy_index);for(integer octet=0;octet<length;octet++) spi_byte(seed+octet*47);SPI_SS_IO=1;advance(400);
        end
      end
      for(integer length=0;length<6;length++) begin
        scenario=19;
        SPI_SS_IO=0;advance(100);spi_byte(8'h70+(length%2));for(integer octet=0;octet<length;octet++) spi_byte(seed+octet*31);SPI_SS_IO=1;advance(400);
        SPI_SS_IO=0;advance(100);spi_byte(8'h1d);for(integer octet=0;octet<length;octet++) spi_byte(seed+octet*41);SPI_SS_IO=1;advance(400);
      end
      scenario=20;
      SPI_SS_IO=0;advance(100);spi_byte(8'h05);spi_byte(8'he0);SPI_SS_IO=1;advance(400);
      SPI_SS_IO=0;advance(100);spi_byte(8'h05);spi_byte(8'h1c);spi_byte(8'hf0);spi_byte(8'hf0);spi_byte(8'h75);SPI_SS_IO=1;advance(400);
      for(integer drive=0;drive<2;drive++) begin
        sd_wr=0;advance(100);sd_wr=1<<drive;advance(100);sd_wr=0;advance(100);
      end
      scenario=21;
      SPI_SS_IO=0;advance(100);spi_byte(8'h17);SPI_SS_IO=1;advance(400);
      SPI_SS_IO=0;advance(100);spi_byte(8'h19);SPI_SS_IO=1;advance(400);
      SPI_SS_IO=0;advance(100);spi_byte(8'hff);SPI_CLK=0;SPI_MOSI=1;advance(50);SPI_CLK=1;advance(50);SPI_SS_IO=1;advance(400);
      scenario=23;
      SPI_SS_IO=0;advance(100);spi_byte(8'h15);spi_byte(1);SPI_SS_IO=1;advance(400);
      SPI_SS_IO=0;advance(100);spi_byte(8'h15);spi_byte(0);SPI_SS_IO=1;advance(400);
      SPI_SS_IO=0;advance(100);spi_byte(8'hff);
      serial_data=8'h39;serial_strobe=1;advance(20);serial_strobe=0;advance(20);
      serial_data=8'ha6;serial_strobe=1;advance(20);serial_strobe=0;advance(20);
      SPI_SS_IO=1;advance(400);
      SPI_SS_IO=0;advance(100);spi_byte(8'h1b);repeat(8)spi_byte(0);SPI_SS_IO=1;advance(400);
      scenario=22;
      for(integer identity=0;identity<2;identity++) begin
        for(integer polarity=0;polarity<2;polarity++) begin
          SPI_SS_IO=0;advance(100);spi_byte(8'h70+identity);
          spi_byte(polarity ? 8'h28 : 8'h18);
          spi_byte(8'h83^seed);spi_byte(8'h46+seed);spi_byte(8'h0a);
          SPI_SS_IO=1;advance(400);
        end
      end
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
        {pins.SPI_CLK,pins.SPI_MOSI,pins.SPI_SS_IO,pins.clk_sd,pins.clk_sys,pins.conf_chr,pins.conf_str,pins.sd_conf,pins.sd_din,pins.sd_lba,pins.sd_rd,pins.sd_sdhc,pins.sd_wr,pins.serial_data,pins.serial_strobe}=req.inputs; pins.scenario=req.scenario;
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
        transaction.inputs={pins.SPI_CLK,pins.SPI_MOSI,pins.SPI_SS_IO,pins.clk_sd,pins.clk_sys,pins.conf_chr,pins.conf_str,pins.sd_conf,pins.sd_din,pins.sd_lba,pins.sd_rd,pins.sd_sdhc,pins.sd_wr,pins.serial_data,pins.serial_strobe}; transaction.actual={pins.actual_SPI_MISO,pins.actual_buttons,pins.actual_conf_addr,pins.actual_core_mod,pins.actual_img_mounted,pins.actual_img_size,pins.actual_joystick_0,pins.actual_joystick_1,pins.actual_joystick_2,pins.actual_joystick_3,pins.actual_joystick_4,pins.actual_joystick_analog_0,pins.actual_joystick_analog_1,pins.actual_key_code,pins.actual_key_extended,pins.actual_key_pressed,pins.actual_key_strobe,pins.actual_mouse_flags,pins.actual_mouse_idx,pins.actual_mouse_strobe,pins.actual_mouse_x,pins.actual_mouse_y,pins.actual_mouse_z,pins.actual_no_csync,pins.actual_ps2_kbd_clk,pins.actual_ps2_kbd_data,pins.actual_ps2_mouse_clk,pins.actual_ps2_mouse_data,pins.actual_rtc,pins.actual_scandoubler_disable,pins.actual_sd_ack,pins.actual_sd_ack_conf,pins.actual_sd_buff_addr,pins.actual_sd_din_strobe,pins.actual_sd_dout,pins.actual_sd_dout_strobe,pins.actual_status,pins.actual_switches,pins.actual_ypbpr}; transaction.scenario=pins.scenario;
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
    function logic [414:0] predict(); return {pins.expected_SPI_MISO,pins.expected_buttons,pins.expected_conf_addr,pins.expected_core_mod,pins.expected_img_mounted,pins.expected_img_size,pins.expected_joystick_0,pins.expected_joystick_1,pins.expected_joystick_2,pins.expected_joystick_3,pins.expected_joystick_4,pins.expected_joystick_analog_0,pins.expected_joystick_analog_1,pins.expected_key_code,pins.expected_key_extended,pins.expected_key_pressed,pins.expected_key_strobe,pins.expected_mouse_flags,pins.expected_mouse_idx,pins.expected_mouse_strobe,pins.expected_mouse_x,pins.expected_mouse_y,pins.expected_mouse_z,pins.expected_no_csync,pins.expected_ps2_kbd_clk,pins.expected_ps2_kbd_data,pins.expected_ps2_mouse_clk,pins.expected_ps2_mouse_data,pins.expected_rtc,pins.expected_scandoubler_disable,pins.expected_sd_ack,pins.expected_sd_ack_conf,pins.expected_sd_buff_addr,pins.expected_sd_din_strobe,pins.expected_sd_dout,pins.expected_sd_dout_strobe,pins.expected_status,pins.expected_switches,pins.expected_ypbpr}; endfunction
  endclass
  class native_scoreboard extends uvm_subscriber #(native_transaction);
    `uvm_component_utils(native_scoreboard)
    native_predictor predictor;
    integer samples=0, differences=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void write(native_transaction transaction);
      logic [414:0] expected;
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
      histories: coverpoint scenario { bins histories[]={[0:22]}; }
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
