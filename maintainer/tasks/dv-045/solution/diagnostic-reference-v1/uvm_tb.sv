`timescale 1ns/1ps
function automatic string phase12_input_directory();
  integer seed_value;
  seed_value=1;
  if ($value$plusargs("ntb_random_seed=%d",seed_value)) begin end
  return $sformatf("/input/submission/stimuli/seed%0d",seed_value);
endfunction
`ifndef DVBENCH_REPLAY
`include "uvm_macros.svh"
import uvm_pkg::*;
`endif
interface dvbench_interface;
  logic clock_value=0;
  logic [2047:0] inputs=0;
  wire [2047:0] actual,expected;
  bit initialized=0,finished=0;
  integer sample_count=0,variant_id=0,row_count=0;
  integer phase=0;
  event sample_event;
  integer output_file;
  task automatic observe;
    if (initialized) begin
`ifdef DVBENCH_REPLAY
      $fdisplay(output_file,"%h",304'(actual));
`else
      ->sample_event;
`endif
      sample_count++;
    end
    #1;
  endtask
  task automatic step(input logic [2047:0] payload);
    inputs=payload;
    #2;
    phase=0;
    observe();

    clock_value=1;
    #2;
    phase=1;
    observe();
    clock_value=0;
    #2;
    row_count++;
    if(row_count>=400) initialized=1;
    phase=2;
    observe();
  endtask
endinterface
`ifndef DVBENCH_REPLAY
class dvbench_transaction extends uvm_sequence_item;
  logic [2047:0] payload,actual,expected;
  integer phase;
  `uvm_object_utils(dvbench_transaction)
  function new(string name="dvbench_transaction"); super.new(name); endfunction
endclass
class dvbench_sequence extends uvm_sequence #(dvbench_transaction);
  `uvm_object_utils(dvbench_sequence)
  string input_path;
  function new(string name="dvbench_sequence"); super.new(name); endfunction
  task body;
    integer input_file,scan_count;
        logic [0:0] column_0;
    logic [0:0] column_1;
    logic [0:0] column_2;
    logic [0:0] column_3;
    logic [0:0] column_4;
    logic [0:0] column_5;
    logic [0:0] column_6;
    logic [0:0] column_7;
    logic [0:0] column_8;
    logic [0:0] column_9;
    logic [0:0] column_10;
    logic [0:0] column_11;
    logic [0:0] column_12;
    logic [0:0] column_13;
    logic [0:0] column_14;
    logic [0:0] column_15;
    logic [0:0] column_16;
    logic [0:0] column_17;
    logic [0:0] column_18;
    logic [0:0] column_19;
    logic [0:0] column_20;
    logic [0:0] column_21;
    logic [0:0] column_22;
    logic [0:0] column_23;
    logic [0:0] column_24;
    logic [0:0] column_25;
    logic [0:0] column_26;
    logic [0:0] column_27;
    logic [0:0] column_28;
    logic [0:0] column_29;
    logic [0:0] column_30;
    logic [0:0] column_31;
    logic [0:0] column_32;
    logic [0:0] column_33;
    logic [0:0] column_34;
    logic [0:0] column_35;
    logic [0:0] column_36;
    logic [0:0] column_37;
    logic [0:0] column_38;
    logic [0:0] column_39;
    dvbench_transaction transaction;
    input_file=$fopen(input_path,"r");
    if (!input_file) `uvm_fatal("INPUT","input trace missing")
    while (!$feof(input_file)) begin
      scan_count=$fscanf(input_file,"%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h\n",column_0,column_1,column_2,column_3,column_4,column_5,column_6,column_7,column_8,column_9,column_10,column_11,column_12,column_13,column_14,column_15,column_16,column_17,column_18,column_19,column_20,column_21,column_22,column_23,column_24,column_25,column_26,column_27,column_28,column_29,column_30,column_31,column_32,column_33,column_34,column_35,column_36,column_37,column_38,column_39);
      if (scan_count==40) begin
        transaction=dvbench_transaction::type_id::create("transaction");
        start_item(transaction);
        transaction.payload={column_39,column_38,column_37,column_36,column_35,column_34,column_33,column_32,column_31,column_30,column_29,column_28,column_27,column_26,column_25,column_24,column_23,column_22,column_21,column_20,column_19,column_18,column_17,column_16,column_15,column_14,column_13,column_12,column_11,column_10,column_9,column_8,column_7,column_6,column_5,column_4,column_3,column_2,column_1,column_0};
        finish_item(transaction);
      end else if (scan_count!=-1) `uvm_fatal("INPUT","invalid record")
    end
    $fclose(input_file);
  endtask
endclass
class dvbench_driver extends uvm_driver #(dvbench_transaction);
  `uvm_component_utils(dvbench_driver)
  virtual dvbench_interface vif;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  task run_phase(uvm_phase phase);
    dvbench_transaction transaction;
    forever begin
      seq_item_port.get_next_item(transaction);
      vif.step(transaction.payload);
      seq_item_port.item_done();
    end
  endtask
endclass
class dvbench_monitor extends uvm_monitor;
  `uvm_component_utils(dvbench_monitor)
  virtual dvbench_interface vif;
  uvm_analysis_port #(dvbench_transaction) observed;
  function new(string name,uvm_component parent); super.new(name,parent); observed=new("observed",this); endfunction
  task run_phase(uvm_phase phase);
    dvbench_transaction transaction;
    forever begin
      @(vif.sample_event);
      transaction=dvbench_transaction::type_id::create("sample");
      transaction.payload=vif.inputs;
      transaction.actual=vif.actual;
      transaction.expected=vif.expected;
      transaction.phase=vif.phase;
      observed.write(transaction);
    end
  endtask
endclass
class dvbench_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dvbench_scoreboard)
  uvm_analysis_imp #(dvbench_transaction,dvbench_scoreboard) checked;
  integer comparisons=0,failures=0;
  function new(string name,uvm_component parent); super.new(name,parent); checked=new("checked",this); endfunction
  function void write(dvbench_transaction transaction);
    comparisons++;
    if (transaction.actual!==transaction.expected || $isunknown(transaction.expected)) begin
      if (failures<16) `uvm_error("PORT_MISMATCH",$sformatf("sample=%0d phase=%0d actual=%h expected=%h",comparisons-1,transaction.phase,transaction.actual,transaction.expected))
      failures++;
    end
  endfunction
endclass
class dvbench_coverage extends uvm_subscriber #(dvbench_transaction);
  `uvm_component_utils(dvbench_coverage)
  integer sample_phase,input_weight;
  bit sample_reset;
  covergroup functional;
    option.per_instance=1;
    cp_phase: coverpoint sample_phase { bins before_edge={0}; bins after_edge={1}; bins after_falling={2}; bins pulse_high={3}; bins pulse_release={4}; }
    cp_weight: coverpoint input_weight { bins zero={0}; bins low={[1:8]}; bins rest={[9:2048]}; }
    cp_reset: coverpoint sample_reset;
    phase_reset: cross cp_phase,cp_reset;
  endgroup
  function new(string name,uvm_component parent); super.new(name,parent); functional=new(); endfunction
  function void write(dvbench_transaction transaction);
    sample_phase=transaction.phase;
    input_weight=$countones(transaction.payload);
    sample_reset=transaction.payload[0];
    functional.sample();
  endfunction
endclass
class dvbench_agent extends uvm_agent;
  `uvm_component_utils(dvbench_agent)
  dvbench_driver driver;
  dvbench_monitor monitor;
  uvm_sequencer #(dvbench_transaction) sequencer;
  virtual dvbench_interface vif;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver=dvbench_driver::type_id::create("driver",this);
    monitor=dvbench_monitor::type_id::create("monitor",this);
    sequencer=new("sequencer",this);
    driver.vif=vif;
    monitor.vif=vif;
  endfunction
  function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
endclass
class dvbench_environment extends uvm_env;
  `uvm_component_utils(dvbench_environment)
  dvbench_agent agent;
  dvbench_scoreboard scoreboard;
  dvbench_coverage coverage;
  virtual dvbench_interface vif;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent=dvbench_agent::type_id::create("agent",this);
    agent.vif=vif;
    scoreboard=dvbench_scoreboard::type_id::create("scoreboard",this);
    coverage=dvbench_coverage::type_id::create("coverage",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    agent.monitor.observed.connect(scoreboard.checked);
    agent.monitor.observed.connect(coverage.analysis_export);
  endfunction
endclass
class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  dvbench_environment environments[];
  integer variant_count;
  function new(string name="dvbench_test",uvm_component parent=null); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    virtual dvbench_interface vif;
    super.build_phase(phase);
    set_report_max_quit_count(0);
    if (!uvm_config_db#(int)::get(this,"","variant_count",variant_count)) `uvm_fatal("CONFIG","variant count missing")
    environments=new[variant_count];
    foreach (environments[index]) begin
      if (!uvm_config_db#(virtual dvbench_interface)::get(this,"",$sformatf("vif%0d",index),vif)) `uvm_fatal("CONFIG","interface missing")
      environments[index]=dvbench_environment::type_id::create($sformatf("environment%0d",index),this);
      environments[index].vif=vif;
    end
  endfunction
  task run_phase(uvm_phase phase);
    string input_directory;
    dvbench_sequence sequence_value;
    phase.raise_objection(this);
    if (!$value$plusargs("INPUT_DIR=%s",input_directory)) input_directory=phase12_input_directory();
    foreach (environments[index]) begin
      sequence_value=dvbench_sequence::type_id::create("sequence_value");
      sequence_value.input_path=$sformatf("%s/variant%0d.inputs",input_directory,index);
      sequence_value.start(environments[index].agent.sequencer);
      environments[index].vif.finished=1;
    end
    #2;
    phase.drop_objection(this);
  endtask
  function void report_phase(uvm_phase phase);
    uvm_report_server server;
    server=uvm_report_server::get_server();
    foreach (environments[index]) begin
      if (!environments[index].vif.finished || environments[index].scoreboard.comparisons==0) `uvm_error("INCOMPLETE","missing comparisons")
      `uvm_info("COUNTS",$sformatf("variant=%0d comparisons=%0d failures=%0d",index,environments[index].scoreboard.comparisons,environments[index].scoreboard.failures),UVM_NONE)
    end
    if (server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)
      `uvm_info("COMPLETE","DVBench_COMPLETED",UVM_NONE)
  endfunction
endclass
`endif

module dvbench_scenario(output wire finished);
  dvbench_interface bus();
  assign finished=bus.finished;
  wire GND;
  assign GND=bus.inputs[0+:1];
  wire VDD;
  assign VDD=bus.inputs[1+:1];
  wire CK;
  assign CK=bus.clock_value;
  wire g35;
  assign g35=bus.inputs[2+:1];
  wire g36;
  assign g36=bus.inputs[3+:1];
  wire g6744;
  assign g6744=bus.inputs[4+:1];
  wire g6745;
  assign g6745=bus.inputs[5+:1];
  wire g6746;
  assign g6746=bus.inputs[6+:1];
  wire g6747;
  assign g6747=bus.inputs[7+:1];
  wire g6748;
  assign g6748=bus.inputs[8+:1];
  wire g6749;
  assign g6749=bus.inputs[9+:1];
  wire g6750;
  assign g6750=bus.inputs[10+:1];
  wire g6751;
  assign g6751=bus.inputs[11+:1];
  wire g6752;
  assign g6752=bus.inputs[12+:1];
  wire g6753;
  assign g6753=bus.inputs[13+:1];
  wire g84;
  assign g84=bus.inputs[14+:1];
  wire g120;
  assign g120=bus.inputs[15+:1];
  wire g5;
  assign g5=bus.inputs[16+:1];
  wire g113;
  assign g113=bus.inputs[17+:1];
  wire g126;
  assign g126=bus.inputs[18+:1];
  wire g99;
  assign g99=bus.inputs[19+:1];
  wire g53;
  assign g53=bus.inputs[20+:1];
  wire g116;
  assign g116=bus.inputs[21+:1];
  wire g92;
  assign g92=bus.inputs[22+:1];
  wire g56;
  assign g56=bus.inputs[23+:1];
  wire g91;
  assign g91=bus.inputs[24+:1];
  wire g44;
  assign g44=bus.inputs[25+:1];
  wire g57;
  assign g57=bus.inputs[26+:1];
  wire g100;
  assign g100=bus.inputs[27+:1];
  wire g54;
  assign g54=bus.inputs[28+:1];
  wire g124;
  assign g124=bus.inputs[29+:1];
  wire g125;
  assign g125=bus.inputs[30+:1];
  wire g114;
  assign g114=bus.inputs[31+:1];
  wire g134;
  assign g134=bus.inputs[32+:1];
  wire g72;
  assign g72=bus.inputs[33+:1];
  wire g115;
  assign g115=bus.inputs[34+:1];
  wire g135;
  assign g135=bus.inputs[35+:1];
  wire g90;
  assign g90=bus.inputs[36+:1];
  wire g127;
  assign g127=bus.inputs[37+:1];
  wire g64;
  assign g64=bus.inputs[38+:1];
  wire g73;
  assign g73=bus.inputs[39+:1];
  wire g7243;
  wire expected_g7243;
  wire g7245;
  wire expected_g7245;
  wire g7257;
  wire expected_g7257;
  wire g7260;
  wire expected_g7260;
  wire g7540;
  wire expected_g7540;
  wire g7916;
  wire expected_g7916;
  wire g7946;
  wire expected_g7946;
  wire g8132;
  wire expected_g8132;
  wire g8178;
  wire expected_g8178;
  wire g8215;
  wire expected_g8215;
  wire g8235;
  wire expected_g8235;
  wire g8277;
  wire expected_g8277;
  wire g8279;
  wire expected_g8279;
  wire g8283;
  wire expected_g8283;
  wire g8291;
  wire expected_g8291;
  wire g8342;
  wire expected_g8342;
  wire g8344;
  wire expected_g8344;
  wire g8353;
  wire expected_g8353;
  wire g8358;
  wire expected_g8358;
  wire g8398;
  wire expected_g8398;
  wire g8403;
  wire expected_g8403;
  wire g8416;
  wire expected_g8416;
  wire g8475;
  wire expected_g8475;
  wire g8719;
  wire expected_g8719;
  wire g8783;
  wire expected_g8783;
  wire g8784;
  wire expected_g8784;
  wire g8785;
  wire expected_g8785;
  wire g8786;
  wire expected_g8786;
  wire g8787;
  wire expected_g8787;
  wire g8788;
  wire expected_g8788;
  wire g8789;
  wire expected_g8789;
  wire g8839;
  wire expected_g8839;
  wire g8870;
  wire expected_g8870;
  wire g8915;
  wire expected_g8915;
  wire g8916;
  wire expected_g8916;
  wire g8917;
  wire expected_g8917;
  wire g8918;
  wire expected_g8918;
  wire g8919;
  wire expected_g8919;
  wire g8920;
  wire expected_g8920;
  wire g9019;
  wire expected_g9019;
  wire g9048;
  wire expected_g9048;
  wire g9251;
  wire expected_g9251;
  wire g9497;
  wire expected_g9497;
  wire g9553;
  wire expected_g9553;
  wire g9555;
  wire expected_g9555;
  wire g9615;
  wire expected_g9615;
  wire g9617;
  wire expected_g9617;
  wire g9680;
  wire expected_g9680;
  wire g9682;
  wire expected_g9682;
  wire g9741;
  wire expected_g9741;
  wire g9743;
  wire expected_g9743;
  wire g9817;
  wire expected_g9817;
  wire g10122;
  wire expected_g10122;
  wire g10306;
  wire expected_g10306;
  wire g10500;
  wire expected_g10500;
  wire g10527;
  wire expected_g10527;
  wire g11349;
  wire expected_g11349;
  wire g11388;
  wire expected_g11388;
  wire g11418;
  wire expected_g11418;
  wire g11447;
  wire expected_g11447;
  wire g11678;
  wire expected_g11678;
  wire g11770;
  wire expected_g11770;
  wire g12184;
  wire expected_g12184;
  wire g12238;
  wire expected_g12238;
  wire g12300;
  wire expected_g12300;
  wire g12350;
  wire expected_g12350;
  wire g12368;
  wire expected_g12368;
  wire g12422;
  wire expected_g12422;
  wire g12470;
  wire expected_g12470;
  wire g12832;
  wire expected_g12832;
  wire g12919;
  wire expected_g12919;
  wire g12923;
  wire expected_g12923;
  wire g13039;
  wire expected_g13039;
  wire g13049;
  wire expected_g13049;
  wire g13068;
  wire expected_g13068;
  wire g13085;
  wire expected_g13085;
  wire g13099;
  wire expected_g13099;
  wire g13259;
  wire expected_g13259;
  wire g13272;
  wire expected_g13272;
  wire g13865;
  wire expected_g13865;
  wire g13881;
  wire expected_g13881;
  wire g13895;
  wire expected_g13895;
  wire g13906;
  wire expected_g13906;
  wire g13926;
  wire expected_g13926;
  wire g13966;
  wire expected_g13966;
  wire g14096;
  wire expected_g14096;
  wire g14125;
  wire expected_g14125;
  wire g14147;
  wire expected_g14147;
  wire g14167;
  wire expected_g14167;
  wire g14189;
  wire expected_g14189;
  wire g14201;
  wire expected_g14201;
  wire g14217;
  wire expected_g14217;
  wire g14421;
  wire expected_g14421;
  wire g14451;
  wire expected_g14451;
  wire g14518;
  wire expected_g14518;
  wire g14597;
  wire expected_g14597;
  wire g14635;
  wire expected_g14635;
  wire g14662;
  wire expected_g14662;
  wire g14673;
  wire expected_g14673;
  wire g14694;
  wire expected_g14694;
  wire g14705;
  wire expected_g14705;
  wire g14738;
  wire expected_g14738;
  wire g14749;
  wire expected_g14749;
  wire g14779;
  wire expected_g14779;
  wire g14828;
  wire expected_g14828;
  wire g16603;
  wire expected_g16603;
  wire g16624;
  wire expected_g16624;
  wire g16627;
  wire expected_g16627;
  wire g16656;
  wire expected_g16656;
  wire g16659;
  wire expected_g16659;
  wire g16686;
  wire expected_g16686;
  wire g16693;
  wire expected_g16693;
  wire g16718;
  wire expected_g16718;
  wire g16722;
  wire expected_g16722;
  wire g16744;
  wire expected_g16744;
  wire g16748;
  wire expected_g16748;
  wire g16775;
  wire expected_g16775;
  wire g16874;
  wire expected_g16874;
  wire g16924;
  wire expected_g16924;
  wire g16955;
  wire expected_g16955;
  wire g17291;
  wire expected_g17291;
  wire g17316;
  wire expected_g17316;
  wire g17320;
  wire expected_g17320;
  wire g17400;
  wire expected_g17400;
  wire g17404;
  wire expected_g17404;
  wire g17423;
  wire expected_g17423;
  wire g17519;
  wire expected_g17519;
  wire g17577;
  wire expected_g17577;
  wire g17580;
  wire expected_g17580;
  wire g17604;
  wire expected_g17604;
  wire g17607;
  wire expected_g17607;
  wire g17639;
  wire expected_g17639;
  wire g17646;
  wire expected_g17646;
  wire g17649;
  wire expected_g17649;
  wire g17674;
  wire expected_g17674;
  wire g17678;
  wire expected_g17678;
  wire g17685;
  wire expected_g17685;
  wire g17688;
  wire expected_g17688;
  wire g17711;
  wire expected_g17711;
  wire g17715;
  wire expected_g17715;
  wire g17722;
  wire expected_g17722;
  wire g17739;
  wire expected_g17739;
  wire g17743;
  wire expected_g17743;
  wire g17760;
  wire expected_g17760;
  wire g17764;
  wire expected_g17764;
  wire g17778;
  wire expected_g17778;
  wire g17787;
  wire expected_g17787;
  wire g17813;
  wire expected_g17813;
  wire g17819;
  wire expected_g17819;
  wire g17845;
  wire expected_g17845;
  wire g17871;
  wire expected_g17871;
  wire g18092;
  wire expected_g18092;
  wire g18094;
  wire expected_g18094;
  wire g18095;
  wire expected_g18095;
  wire g18096;
  wire expected_g18096;
  wire g18097;
  wire expected_g18097;
  wire g18098;
  wire expected_g18098;
  wire g18099;
  wire expected_g18099;
  wire g18100;
  wire expected_g18100;
  wire g18101;
  wire expected_g18101;
  wire g18881;
  wire expected_g18881;
  wire g19334;
  wire expected_g19334;
  wire g19357;
  wire expected_g19357;
  wire g20049;
  wire expected_g20049;
  wire g20557;
  wire expected_g20557;
  wire g20652;
  wire expected_g20652;
  wire g20654;
  wire expected_g20654;
  wire g20763;
  wire expected_g20763;
  wire g20899;
  wire expected_g20899;
  wire g20901;
  wire expected_g20901;
  wire g21176;
  wire expected_g21176;
  wire g21245;
  wire expected_g21245;
  wire g21270;
  wire expected_g21270;
  wire g21292;
  wire expected_g21292;
  wire g21698;
  wire expected_g21698;
  wire g21727;
  wire expected_g21727;
  wire g23002;
  wire expected_g23002;
  wire g23190;
  wire expected_g23190;
  wire g23612;
  wire expected_g23612;
  wire g23652;
  wire expected_g23652;
  wire g23683;
  wire expected_g23683;
  wire g23759;
  wire expected_g23759;
  wire g24151;
  wire expected_g24151;
  wire g25114;
  wire expected_g25114;
  wire g25167;
  wire expected_g25167;
  wire g25219;
  wire expected_g25219;
  wire g25259;
  wire expected_g25259;
  wire g25582;
  wire expected_g25582;
  wire g25583;
  wire expected_g25583;
  wire g25584;
  wire expected_g25584;
  wire g25585;
  wire expected_g25585;
  wire g25586;
  wire expected_g25586;
  wire g25587;
  wire expected_g25587;
  wire g25588;
  wire expected_g25588;
  wire g25589;
  wire expected_g25589;
  wire g25590;
  wire expected_g25590;
  wire g26801;
  wire expected_g26801;
  wire g26875;
  wire expected_g26875;
  wire g26876;
  wire expected_g26876;
  wire g26877;
  wire expected_g26877;
  wire g27831;
  wire expected_g27831;
  wire g28030;
  wire expected_g28030;
  wire g28041;
  wire expected_g28041;
  wire g28042;
  wire expected_g28042;
  wire g28753;
  wire expected_g28753;
  wire g29210;
  wire expected_g29210;
  wire g29211;
  wire expected_g29211;
  wire g29212;
  wire expected_g29212;
  wire g29213;
  wire expected_g29213;
  wire g29214;
  wire expected_g29214;
  wire g29215;
  wire expected_g29215;
  wire g29216;
  wire expected_g29216;
  wire g29217;
  wire expected_g29217;
  wire g29218;
  wire expected_g29218;
  wire g29219;
  wire expected_g29219;
  wire g29220;
  wire expected_g29220;
  wire g29221;
  wire expected_g29221;
  wire g30327;
  wire expected_g30327;
  wire g30329;
  wire expected_g30329;
  wire g30330;
  wire expected_g30330;
  wire g30331;
  wire expected_g30331;
  wire g30332;
  wire expected_g30332;
  wire g31521;
  wire expected_g31521;
  wire g31656;
  wire expected_g31656;
  wire g31665;
  wire expected_g31665;
  wire g31793;
  wire expected_g31793;
  wire g31860;
  wire expected_g31860;
  wire g31861;
  wire expected_g31861;
  wire g31862;
  wire expected_g31862;
  wire g31863;
  wire expected_g31863;
  wire g32185;
  wire expected_g32185;
  wire g32429;
  wire expected_g32429;
  wire g32454;
  wire expected_g32454;
  wire g32975;
  wire expected_g32975;
  wire g33079;
  wire expected_g33079;
  wire g33435;
  wire expected_g33435;
  wire g33533;
  wire expected_g33533;
  wire g33636;
  wire expected_g33636;
  wire g33659;
  wire expected_g33659;
  wire g33874;
  wire expected_g33874;
  wire g33894;
  wire expected_g33894;
  wire g33935;
  wire expected_g33935;
  wire g33945;
  wire expected_g33945;
  wire g33946;
  wire expected_g33946;
  wire g33947;
  wire expected_g33947;
  wire g33948;
  wire expected_g33948;
  wire g33949;
  wire expected_g33949;
  wire g33950;
  wire expected_g33950;
  wire g33959;
  wire expected_g33959;
  wire g34201;
  wire expected_g34201;
  wire g34221;
  wire expected_g34221;
  wire g34232;
  wire expected_g34232;
  wire g34233;
  wire expected_g34233;
  wire g34234;
  wire expected_g34234;
  wire g34235;
  wire expected_g34235;
  wire g34236;
  wire expected_g34236;
  wire g34237;
  wire expected_g34237;
  wire g34238;
  wire expected_g34238;
  wire g34239;
  wire expected_g34239;
  wire g34240;
  wire expected_g34240;
  wire g34383;
  wire expected_g34383;
  wire g34425;
  wire expected_g34425;
  wire g34435;
  wire expected_g34435;
  wire g34436;
  wire expected_g34436;
  wire g34437;
  wire expected_g34437;
  wire g34597;
  wire expected_g34597;
  wire g34788;
  wire expected_g34788;
  wire g34839;
  wire expected_g34839;
  wire g34913;
  wire expected_g34913;
  wire g34915;
  wire expected_g34915;
  wire g34917;
  wire expected_g34917;
  wire g34919;
  wire expected_g34919;
  wire g34921;
  wire expected_g34921;
  wire g34923;
  wire expected_g34923;
  wire g34925;
  wire expected_g34925;
  wire g34927;
  wire expected_g34927;
  wire g34956;
  wire expected_g34956;
  wire g34972;
  wire expected_g34972;
  wire g24168;
  wire expected_g24168;
  wire g24178;
  wire expected_g24178;
  wire g12833;
  wire expected_g12833;
  wire g24174;
  wire expected_g24174;
  wire g24181;
  wire expected_g24181;
  wire g24172;
  wire expected_g24172;
  wire g24161;
  wire expected_g24161;
  wire g24177;
  wire expected_g24177;
  wire g24171;
  wire expected_g24171;
  wire g24163;
  wire expected_g24163;
  wire g24170;
  wire expected_g24170;
  wire g24185;
  wire expected_g24185;
  wire g24164;
  wire expected_g24164;
  wire g24173;
  wire expected_g24173;
  wire g24162;
  wire expected_g24162;
  wire g24179;
  wire expected_g24179;
  wire g24180;
  wire expected_g24180;
  wire g24175;
  wire expected_g24175;
  wire g24183;
  wire expected_g24183;
  wire g24166;
  wire expected_g24166;
  wire g24176;
  wire expected_g24176;
  wire g24184;
  wire expected_g24184;
  wire g24169;
  wire expected_g24169;
  wire g24182;
  wire expected_g24182;
  wire g24165;
  wire expected_g24165;
  wire g24167;
  wire expected_g24167;
`ifdef DVBENCH_REPLAY_MODEL
  dvbench_model replay_unit(.GND(GND),.VDD(VDD),.CK(CK),.g35(g35),.g36(g36),.g6744(g6744),.g6745(g6745),.g6746(g6746),.g6747(g6747),.g6748(g6748),.g6749(g6749),.g6750(g6750),.g6751(g6751),.g6752(g6752),.g6753(g6753),.g84(g84),.g120(g120),.g5(g5),.g113(g113),.g126(g126),.g99(g99),.g53(g53),.g116(g116),.g92(g92),.g56(g56),.g91(g91),.g44(g44),.g57(g57),.g100(g100),.g54(g54),.g124(g124),.g125(g125),.g114(g114),.g134(g134),.g72(g72),.g115(g115),.g135(g135),.g90(g90),.g127(g127),.g64(g64),.g73(g73),.g7243(g7243),.g7245(g7245),.g7257(g7257),.g7260(g7260),.g7540(g7540),.g7916(g7916),.g7946(g7946),.g8132(g8132),.g8178(g8178),.g8215(g8215),.g8235(g8235),.g8277(g8277),.g8279(g8279),.g8283(g8283),.g8291(g8291),.g8342(g8342),.g8344(g8344),.g8353(g8353),.g8358(g8358),.g8398(g8398),.g8403(g8403),.g8416(g8416),.g8475(g8475),.g8719(g8719),.g8783(g8783),.g8784(g8784),.g8785(g8785),.g8786(g8786),.g8787(g8787),.g8788(g8788),.g8789(g8789),.g8839(g8839),.g8870(g8870),.g8915(g8915),.g8916(g8916),.g8917(g8917),.g8918(g8918),.g8919(g8919),.g8920(g8920),.g9019(g9019),.g9048(g9048),.g9251(g9251),.g9497(g9497),.g9553(g9553),.g9555(g9555),.g9615(g9615),.g9617(g9617),.g9680(g9680),.g9682(g9682),.g9741(g9741),.g9743(g9743),.g9817(g9817),.g10122(g10122),.g10306(g10306),.g10500(g10500),.g10527(g10527),.g11349(g11349),.g11388(g11388),.g11418(g11418),.g11447(g11447),.g11678(g11678),.g11770(g11770),.g12184(g12184),.g12238(g12238),.g12300(g12300),.g12350(g12350),.g12368(g12368),.g12422(g12422),.g12470(g12470),.g12832(g12832),.g12919(g12919),.g12923(g12923),.g13039(g13039),.g13049(g13049),.g13068(g13068),.g13085(g13085),.g13099(g13099),.g13259(g13259),.g13272(g13272),.g13865(g13865),.g13881(g13881),.g13895(g13895),.g13906(g13906),.g13926(g13926),.g13966(g13966),.g14096(g14096),.g14125(g14125),.g14147(g14147),.g14167(g14167),.g14189(g14189),.g14201(g14201),.g14217(g14217),.g14421(g14421),.g14451(g14451),.g14518(g14518),.g14597(g14597),.g14635(g14635),.g14662(g14662),.g14673(g14673),.g14694(g14694),.g14705(g14705),.g14738(g14738),.g14749(g14749),.g14779(g14779),.g14828(g14828),.g16603(g16603),.g16624(g16624),.g16627(g16627),.g16656(g16656),.g16659(g16659),.g16686(g16686),.g16693(g16693),.g16718(g16718),.g16722(g16722),.g16744(g16744),.g16748(g16748),.g16775(g16775),.g16874(g16874),.g16924(g16924),.g16955(g16955),.g17291(g17291),.g17316(g17316),.g17320(g17320),.g17400(g17400),.g17404(g17404),.g17423(g17423),.g17519(g17519),.g17577(g17577),.g17580(g17580),.g17604(g17604),.g17607(g17607),.g17639(g17639),.g17646(g17646),.g17649(g17649),.g17674(g17674),.g17678(g17678),.g17685(g17685),.g17688(g17688),.g17711(g17711),.g17715(g17715),.g17722(g17722),.g17739(g17739),.g17743(g17743),.g17760(g17760),.g17764(g17764),.g17778(g17778),.g17787(g17787),.g17813(g17813),.g17819(g17819),.g17845(g17845),.g17871(g17871),.g18092(g18092),.g18094(g18094),.g18095(g18095),.g18096(g18096),.g18097(g18097),.g18098(g18098),.g18099(g18099),.g18100(g18100),.g18101(g18101),.g18881(g18881),.g19334(g19334),.g19357(g19357),.g20049(g20049),.g20557(g20557),.g20652(g20652),.g20654(g20654),.g20763(g20763),.g20899(g20899),.g20901(g20901),.g21176(g21176),.g21245(g21245),.g21270(g21270),.g21292(g21292),.g21698(g21698),.g21727(g21727),.g23002(g23002),.g23190(g23190),.g23612(g23612),.g23652(g23652),.g23683(g23683),.g23759(g23759),.g24151(g24151),.g25114(g25114),.g25167(g25167),.g25219(g25219),.g25259(g25259),.g25582(g25582),.g25583(g25583),.g25584(g25584),.g25585(g25585),.g25586(g25586),.g25587(g25587),.g25588(g25588),.g25589(g25589),.g25590(g25590),.g26801(g26801),.g26875(g26875),.g26876(g26876),.g26877(g26877),.g27831(g27831),.g28030(g28030),.g28041(g28041),.g28042(g28042),.g28753(g28753),.g29210(g29210),.g29211(g29211),.g29212(g29212),.g29213(g29213),.g29214(g29214),.g29215(g29215),.g29216(g29216),.g29217(g29217),.g29218(g29218),.g29219(g29219),.g29220(g29220),.g29221(g29221),.g30327(g30327),.g30329(g30329),.g30330(g30330),.g30331(g30331),.g30332(g30332),.g31521(g31521),.g31656(g31656),.g31665(g31665),.g31793(g31793),.g31860(g31860),.g31861(g31861),.g31862(g31862),.g31863(g31863),.g32185(g32185),.g32429(g32429),.g32454(g32454),.g32975(g32975),.g33079(g33079),.g33435(g33435),.g33533(g33533),.g33636(g33636),.g33659(g33659),.g33874(g33874),.g33894(g33894),.g33935(g33935),.g33945(g33945),.g33946(g33946),.g33947(g33947),.g33948(g33948),.g33949(g33949),.g33950(g33950),.g33959(g33959),.g34201(g34201),.g34221(g34221),.g34232(g34232),.g34233(g34233),.g34234(g34234),.g34235(g34235),.g34236(g34236),.g34237(g34237),.g34238(g34238),.g34239(g34239),.g34240(g34240),.g34383(g34383),.g34425(g34425),.g34435(g34435),.g34436(g34436),.g34437(g34437),.g34597(g34597),.g34788(g34788),.g34839(g34839),.g34913(g34913),.g34915(g34915),.g34917(g34917),.g34919(g34919),.g34921(g34921),.g34923(g34923),.g34925(g34925),.g34927(g34927),.g34956(g34956),.g34972(g34972),.g24168(g24168),.g24178(g24178),.g12833(g12833),.g24174(g24174),.g24181(g24181),.g24172(g24172),.g24161(g24161),.g24177(g24177),.g24171(g24171),.g24163(g24163),.g24170(g24170),.g24185(g24185),.g24164(g24164),.g24173(g24173),.g24162(g24162),.g24179(g24179),.g24180(g24180),.g24175(g24175),.g24183(g24183),.g24166(g24166),.g24176(g24176),.g24184(g24184),.g24169(g24169),.g24182(g24182),.g24165(g24165),.g24167(g24167));
  assign bus.expected='0;
`else
  s38584 dut(.GND(GND),.VDD(VDD),.CK(CK),.g35(g35),.g36(g36),.g6744(g6744),.g6745(g6745),.g6746(g6746),.g6747(g6747),.g6748(g6748),.g6749(g6749),.g6750(g6750),.g6751(g6751),.g6752(g6752),.g6753(g6753),.g84(g84),.g120(g120),.g5(g5),.g113(g113),.g126(g126),.g99(g99),.g53(g53),.g116(g116),.g92(g92),.g56(g56),.g91(g91),.g44(g44),.g57(g57),.g100(g100),.g54(g54),.g124(g124),.g125(g125),.g114(g114),.g134(g134),.g72(g72),.g115(g115),.g135(g135),.g90(g90),.g127(g127),.g64(g64),.g73(g73),.g7243(g7243),.g7245(g7245),.g7257(g7257),.g7260(g7260),.g7540(g7540),.g7916(g7916),.g7946(g7946),.g8132(g8132),.g8178(g8178),.g8215(g8215),.g8235(g8235),.g8277(g8277),.g8279(g8279),.g8283(g8283),.g8291(g8291),.g8342(g8342),.g8344(g8344),.g8353(g8353),.g8358(g8358),.g8398(g8398),.g8403(g8403),.g8416(g8416),.g8475(g8475),.g8719(g8719),.g8783(g8783),.g8784(g8784),.g8785(g8785),.g8786(g8786),.g8787(g8787),.g8788(g8788),.g8789(g8789),.g8839(g8839),.g8870(g8870),.g8915(g8915),.g8916(g8916),.g8917(g8917),.g8918(g8918),.g8919(g8919),.g8920(g8920),.g9019(g9019),.g9048(g9048),.g9251(g9251),.g9497(g9497),.g9553(g9553),.g9555(g9555),.g9615(g9615),.g9617(g9617),.g9680(g9680),.g9682(g9682),.g9741(g9741),.g9743(g9743),.g9817(g9817),.g10122(g10122),.g10306(g10306),.g10500(g10500),.g10527(g10527),.g11349(g11349),.g11388(g11388),.g11418(g11418),.g11447(g11447),.g11678(g11678),.g11770(g11770),.g12184(g12184),.g12238(g12238),.g12300(g12300),.g12350(g12350),.g12368(g12368),.g12422(g12422),.g12470(g12470),.g12832(g12832),.g12919(g12919),.g12923(g12923),.g13039(g13039),.g13049(g13049),.g13068(g13068),.g13085(g13085),.g13099(g13099),.g13259(g13259),.g13272(g13272),.g13865(g13865),.g13881(g13881),.g13895(g13895),.g13906(g13906),.g13926(g13926),.g13966(g13966),.g14096(g14096),.g14125(g14125),.g14147(g14147),.g14167(g14167),.g14189(g14189),.g14201(g14201),.g14217(g14217),.g14421(g14421),.g14451(g14451),.g14518(g14518),.g14597(g14597),.g14635(g14635),.g14662(g14662),.g14673(g14673),.g14694(g14694),.g14705(g14705),.g14738(g14738),.g14749(g14749),.g14779(g14779),.g14828(g14828),.g16603(g16603),.g16624(g16624),.g16627(g16627),.g16656(g16656),.g16659(g16659),.g16686(g16686),.g16693(g16693),.g16718(g16718),.g16722(g16722),.g16744(g16744),.g16748(g16748),.g16775(g16775),.g16874(g16874),.g16924(g16924),.g16955(g16955),.g17291(g17291),.g17316(g17316),.g17320(g17320),.g17400(g17400),.g17404(g17404),.g17423(g17423),.g17519(g17519),.g17577(g17577),.g17580(g17580),.g17604(g17604),.g17607(g17607),.g17639(g17639),.g17646(g17646),.g17649(g17649),.g17674(g17674),.g17678(g17678),.g17685(g17685),.g17688(g17688),.g17711(g17711),.g17715(g17715),.g17722(g17722),.g17739(g17739),.g17743(g17743),.g17760(g17760),.g17764(g17764),.g17778(g17778),.g17787(g17787),.g17813(g17813),.g17819(g17819),.g17845(g17845),.g17871(g17871),.g18092(g18092),.g18094(g18094),.g18095(g18095),.g18096(g18096),.g18097(g18097),.g18098(g18098),.g18099(g18099),.g18100(g18100),.g18101(g18101),.g18881(g18881),.g19334(g19334),.g19357(g19357),.g20049(g20049),.g20557(g20557),.g20652(g20652),.g20654(g20654),.g20763(g20763),.g20899(g20899),.g20901(g20901),.g21176(g21176),.g21245(g21245),.g21270(g21270),.g21292(g21292),.g21698(g21698),.g21727(g21727),.g23002(g23002),.g23190(g23190),.g23612(g23612),.g23652(g23652),.g23683(g23683),.g23759(g23759),.g24151(g24151),.g25114(g25114),.g25167(g25167),.g25219(g25219),.g25259(g25259),.g25582(g25582),.g25583(g25583),.g25584(g25584),.g25585(g25585),.g25586(g25586),.g25587(g25587),.g25588(g25588),.g25589(g25589),.g25590(g25590),.g26801(g26801),.g26875(g26875),.g26876(g26876),.g26877(g26877),.g27831(g27831),.g28030(g28030),.g28041(g28041),.g28042(g28042),.g28753(g28753),.g29210(g29210),.g29211(g29211),.g29212(g29212),.g29213(g29213),.g29214(g29214),.g29215(g29215),.g29216(g29216),.g29217(g29217),.g29218(g29218),.g29219(g29219),.g29220(g29220),.g29221(g29221),.g30327(g30327),.g30329(g30329),.g30330(g30330),.g30331(g30331),.g30332(g30332),.g31521(g31521),.g31656(g31656),.g31665(g31665),.g31793(g31793),.g31860(g31860),.g31861(g31861),.g31862(g31862),.g31863(g31863),.g32185(g32185),.g32429(g32429),.g32454(g32454),.g32975(g32975),.g33079(g33079),.g33435(g33435),.g33533(g33533),.g33636(g33636),.g33659(g33659),.g33874(g33874),.g33894(g33894),.g33935(g33935),.g33945(g33945),.g33946(g33946),.g33947(g33947),.g33948(g33948),.g33949(g33949),.g33950(g33950),.g33959(g33959),.g34201(g34201),.g34221(g34221),.g34232(g34232),.g34233(g34233),.g34234(g34234),.g34235(g34235),.g34236(g34236),.g34237(g34237),.g34238(g34238),.g34239(g34239),.g34240(g34240),.g34383(g34383),.g34425(g34425),.g34435(g34435),.g34436(g34436),.g34437(g34437),.g34597(g34597),.g34788(g34788),.g34839(g34839),.g34913(g34913),.g34915(g34915),.g34917(g34917),.g34919(g34919),.g34921(g34921),.g34923(g34923),.g34925(g34925),.g34927(g34927),.g34956(g34956),.g34972(g34972),.g24168(g24168),.g24178(g24178),.g12833(g12833),.g24174(g24174),.g24181(g24181),.g24172(g24172),.g24161(g24161),.g24177(g24177),.g24171(g24171),.g24163(g24163),.g24170(g24170),.g24185(g24185),.g24164(g24164),.g24173(g24173),.g24162(g24162),.g24179(g24179),.g24180(g24180),.g24175(g24175),.g24183(g24183),.g24166(g24166),.g24176(g24176),.g24184(g24184),.g24169(g24169),.g24182(g24182),.g24165(g24165),.g24167(g24167));
`ifndef DVBENCH_REPLAY
  dvbench_model predictor(.GND(GND),.VDD(VDD),.CK(CK),.g35(g35),.g36(g36),.g6744(g6744),.g6745(g6745),.g6746(g6746),.g6747(g6747),.g6748(g6748),.g6749(g6749),.g6750(g6750),.g6751(g6751),.g6752(g6752),.g6753(g6753),.g84(g84),.g120(g120),.g5(g5),.g113(g113),.g126(g126),.g99(g99),.g53(g53),.g116(g116),.g92(g92),.g56(g56),.g91(g91),.g44(g44),.g57(g57),.g100(g100),.g54(g54),.g124(g124),.g125(g125),.g114(g114),.g134(g134),.g72(g72),.g115(g115),.g135(g135),.g90(g90),.g127(g127),.g64(g64),.g73(g73),.g7243(expected_g7243),.g7245(expected_g7245),.g7257(expected_g7257),.g7260(expected_g7260),.g7540(expected_g7540),.g7916(expected_g7916),.g7946(expected_g7946),.g8132(expected_g8132),.g8178(expected_g8178),.g8215(expected_g8215),.g8235(expected_g8235),.g8277(expected_g8277),.g8279(expected_g8279),.g8283(expected_g8283),.g8291(expected_g8291),.g8342(expected_g8342),.g8344(expected_g8344),.g8353(expected_g8353),.g8358(expected_g8358),.g8398(expected_g8398),.g8403(expected_g8403),.g8416(expected_g8416),.g8475(expected_g8475),.g8719(expected_g8719),.g8783(expected_g8783),.g8784(expected_g8784),.g8785(expected_g8785),.g8786(expected_g8786),.g8787(expected_g8787),.g8788(expected_g8788),.g8789(expected_g8789),.g8839(expected_g8839),.g8870(expected_g8870),.g8915(expected_g8915),.g8916(expected_g8916),.g8917(expected_g8917),.g8918(expected_g8918),.g8919(expected_g8919),.g8920(expected_g8920),.g9019(expected_g9019),.g9048(expected_g9048),.g9251(expected_g9251),.g9497(expected_g9497),.g9553(expected_g9553),.g9555(expected_g9555),.g9615(expected_g9615),.g9617(expected_g9617),.g9680(expected_g9680),.g9682(expected_g9682),.g9741(expected_g9741),.g9743(expected_g9743),.g9817(expected_g9817),.g10122(expected_g10122),.g10306(expected_g10306),.g10500(expected_g10500),.g10527(expected_g10527),.g11349(expected_g11349),.g11388(expected_g11388),.g11418(expected_g11418),.g11447(expected_g11447),.g11678(expected_g11678),.g11770(expected_g11770),.g12184(expected_g12184),.g12238(expected_g12238),.g12300(expected_g12300),.g12350(expected_g12350),.g12368(expected_g12368),.g12422(expected_g12422),.g12470(expected_g12470),.g12832(expected_g12832),.g12919(expected_g12919),.g12923(expected_g12923),.g13039(expected_g13039),.g13049(expected_g13049),.g13068(expected_g13068),.g13085(expected_g13085),.g13099(expected_g13099),.g13259(expected_g13259),.g13272(expected_g13272),.g13865(expected_g13865),.g13881(expected_g13881),.g13895(expected_g13895),.g13906(expected_g13906),.g13926(expected_g13926),.g13966(expected_g13966),.g14096(expected_g14096),.g14125(expected_g14125),.g14147(expected_g14147),.g14167(expected_g14167),.g14189(expected_g14189),.g14201(expected_g14201),.g14217(expected_g14217),.g14421(expected_g14421),.g14451(expected_g14451),.g14518(expected_g14518),.g14597(expected_g14597),.g14635(expected_g14635),.g14662(expected_g14662),.g14673(expected_g14673),.g14694(expected_g14694),.g14705(expected_g14705),.g14738(expected_g14738),.g14749(expected_g14749),.g14779(expected_g14779),.g14828(expected_g14828),.g16603(expected_g16603),.g16624(expected_g16624),.g16627(expected_g16627),.g16656(expected_g16656),.g16659(expected_g16659),.g16686(expected_g16686),.g16693(expected_g16693),.g16718(expected_g16718),.g16722(expected_g16722),.g16744(expected_g16744),.g16748(expected_g16748),.g16775(expected_g16775),.g16874(expected_g16874),.g16924(expected_g16924),.g16955(expected_g16955),.g17291(expected_g17291),.g17316(expected_g17316),.g17320(expected_g17320),.g17400(expected_g17400),.g17404(expected_g17404),.g17423(expected_g17423),.g17519(expected_g17519),.g17577(expected_g17577),.g17580(expected_g17580),.g17604(expected_g17604),.g17607(expected_g17607),.g17639(expected_g17639),.g17646(expected_g17646),.g17649(expected_g17649),.g17674(expected_g17674),.g17678(expected_g17678),.g17685(expected_g17685),.g17688(expected_g17688),.g17711(expected_g17711),.g17715(expected_g17715),.g17722(expected_g17722),.g17739(expected_g17739),.g17743(expected_g17743),.g17760(expected_g17760),.g17764(expected_g17764),.g17778(expected_g17778),.g17787(expected_g17787),.g17813(expected_g17813),.g17819(expected_g17819),.g17845(expected_g17845),.g17871(expected_g17871),.g18092(expected_g18092),.g18094(expected_g18094),.g18095(expected_g18095),.g18096(expected_g18096),.g18097(expected_g18097),.g18098(expected_g18098),.g18099(expected_g18099),.g18100(expected_g18100),.g18101(expected_g18101),.g18881(expected_g18881),.g19334(expected_g19334),.g19357(expected_g19357),.g20049(expected_g20049),.g20557(expected_g20557),.g20652(expected_g20652),.g20654(expected_g20654),.g20763(expected_g20763),.g20899(expected_g20899),.g20901(expected_g20901),.g21176(expected_g21176),.g21245(expected_g21245),.g21270(expected_g21270),.g21292(expected_g21292),.g21698(expected_g21698),.g21727(expected_g21727),.g23002(expected_g23002),.g23190(expected_g23190),.g23612(expected_g23612),.g23652(expected_g23652),.g23683(expected_g23683),.g23759(expected_g23759),.g24151(expected_g24151),.g25114(expected_g25114),.g25167(expected_g25167),.g25219(expected_g25219),.g25259(expected_g25259),.g25582(expected_g25582),.g25583(expected_g25583),.g25584(expected_g25584),.g25585(expected_g25585),.g25586(expected_g25586),.g25587(expected_g25587),.g25588(expected_g25588),.g25589(expected_g25589),.g25590(expected_g25590),.g26801(expected_g26801),.g26875(expected_g26875),.g26876(expected_g26876),.g26877(expected_g26877),.g27831(expected_g27831),.g28030(expected_g28030),.g28041(expected_g28041),.g28042(expected_g28042),.g28753(expected_g28753),.g29210(expected_g29210),.g29211(expected_g29211),.g29212(expected_g29212),.g29213(expected_g29213),.g29214(expected_g29214),.g29215(expected_g29215),.g29216(expected_g29216),.g29217(expected_g29217),.g29218(expected_g29218),.g29219(expected_g29219),.g29220(expected_g29220),.g29221(expected_g29221),.g30327(expected_g30327),.g30329(expected_g30329),.g30330(expected_g30330),.g30331(expected_g30331),.g30332(expected_g30332),.g31521(expected_g31521),.g31656(expected_g31656),.g31665(expected_g31665),.g31793(expected_g31793),.g31860(expected_g31860),.g31861(expected_g31861),.g31862(expected_g31862),.g31863(expected_g31863),.g32185(expected_g32185),.g32429(expected_g32429),.g32454(expected_g32454),.g32975(expected_g32975),.g33079(expected_g33079),.g33435(expected_g33435),.g33533(expected_g33533),.g33636(expected_g33636),.g33659(expected_g33659),.g33874(expected_g33874),.g33894(expected_g33894),.g33935(expected_g33935),.g33945(expected_g33945),.g33946(expected_g33946),.g33947(expected_g33947),.g33948(expected_g33948),.g33949(expected_g33949),.g33950(expected_g33950),.g33959(expected_g33959),.g34201(expected_g34201),.g34221(expected_g34221),.g34232(expected_g34232),.g34233(expected_g34233),.g34234(expected_g34234),.g34235(expected_g34235),.g34236(expected_g34236),.g34237(expected_g34237),.g34238(expected_g34238),.g34239(expected_g34239),.g34240(expected_g34240),.g34383(expected_g34383),.g34425(expected_g34425),.g34435(expected_g34435),.g34436(expected_g34436),.g34437(expected_g34437),.g34597(expected_g34597),.g34788(expected_g34788),.g34839(expected_g34839),.g34913(expected_g34913),.g34915(expected_g34915),.g34917(expected_g34917),.g34919(expected_g34919),.g34921(expected_g34921),.g34923(expected_g34923),.g34925(expected_g34925),.g34927(expected_g34927),.g34956(expected_g34956),.g34972(expected_g34972),.g24168(expected_g24168),.g24178(expected_g24178),.g12833(expected_g12833),.g24174(expected_g24174),.g24181(expected_g24181),.g24172(expected_g24172),.g24161(expected_g24161),.g24177(expected_g24177),.g24171(expected_g24171),.g24163(expected_g24163),.g24170(expected_g24170),.g24185(expected_g24185),.g24164(expected_g24164),.g24173(expected_g24173),.g24162(expected_g24162),.g24179(expected_g24179),.g24180(expected_g24180),.g24175(expected_g24175),.g24183(expected_g24183),.g24166(expected_g24166),.g24176(expected_g24176),.g24184(expected_g24184),.g24169(expected_g24169),.g24182(expected_g24182),.g24165(expected_g24165),.g24167(expected_g24167));
  assign bus.expected={expected_g24167,expected_g24165,expected_g24182,expected_g24169,expected_g24184,expected_g24176,expected_g24166,expected_g24183,expected_g24175,expected_g24180,expected_g24179,expected_g24162,expected_g24173,expected_g24164,expected_g24185,expected_g24170,expected_g24163,expected_g24171,expected_g24177,expected_g24161,expected_g24172,expected_g24181,expected_g24174,expected_g12833,expected_g24178,expected_g24168,expected_g34972,expected_g34956,expected_g34927,expected_g34925,expected_g34923,expected_g34921,expected_g34919,expected_g34917,expected_g34915,expected_g34913,expected_g34839,expected_g34788,expected_g34597,expected_g34437,expected_g34436,expected_g34435,expected_g34425,expected_g34383,expected_g34240,expected_g34239,expected_g34238,expected_g34237,expected_g34236,expected_g34235,expected_g34234,expected_g34233,expected_g34232,expected_g34221,expected_g34201,expected_g33959,expected_g33950,expected_g33949,expected_g33948,expected_g33947,expected_g33946,expected_g33945,expected_g33935,expected_g33894,expected_g33874,expected_g33659,expected_g33636,expected_g33533,expected_g33435,expected_g33079,expected_g32975,expected_g32454,expected_g32429,expected_g32185,expected_g31863,expected_g31862,expected_g31861,expected_g31860,expected_g31793,expected_g31665,expected_g31656,expected_g31521,expected_g30332,expected_g30331,expected_g30330,expected_g30329,expected_g30327,expected_g29221,expected_g29220,expected_g29219,expected_g29218,expected_g29217,expected_g29216,expected_g29215,expected_g29214,expected_g29213,expected_g29212,expected_g29211,expected_g29210,expected_g28753,expected_g28042,expected_g28041,expected_g28030,expected_g27831,expected_g26877,expected_g26876,expected_g26875,expected_g26801,expected_g25590,expected_g25589,expected_g25588,expected_g25587,expected_g25586,expected_g25585,expected_g25584,expected_g25583,expected_g25582,expected_g25259,expected_g25219,expected_g25167,expected_g25114,1'b0,expected_g23759,expected_g23683,expected_g23652,expected_g23612,1'b0,expected_g23002,expected_g21727,expected_g21698,expected_g21292,expected_g21270,expected_g21245,expected_g21176,expected_g20901,expected_g20899,expected_g20763,expected_g20654,expected_g20652,expected_g20557,expected_g20049,expected_g19357,expected_g19334,expected_g18881,expected_g18101,expected_g18100,expected_g18099,expected_g18098,expected_g18097,expected_g18096,expected_g18095,expected_g18094,expected_g18092,expected_g17871,expected_g17845,expected_g17819,expected_g17813,expected_g17787,expected_g17778,expected_g17764,expected_g17760,expected_g17743,expected_g17739,expected_g17722,expected_g17715,expected_g17711,expected_g17688,expected_g17685,expected_g17678,expected_g17674,expected_g17649,expected_g17646,expected_g17639,expected_g17607,expected_g17604,expected_g17580,expected_g17577,expected_g17519,expected_g17423,expected_g17404,expected_g17400,expected_g17320,expected_g17316,expected_g17291,expected_g16955,expected_g16924,expected_g16874,expected_g16775,expected_g16748,expected_g16744,expected_g16722,expected_g16718,expected_g16693,expected_g16686,expected_g16659,expected_g16656,expected_g16627,expected_g16624,expected_g16603,expected_g14828,expected_g14779,expected_g14749,expected_g14738,expected_g14705,expected_g14694,expected_g14673,expected_g14662,expected_g14635,expected_g14597,expected_g14518,expected_g14451,expected_g14421,expected_g14217,expected_g14201,expected_g14189,expected_g14167,expected_g14147,expected_g14125,expected_g14096,expected_g13966,expected_g13926,expected_g13906,expected_g13895,expected_g13881,expected_g13865,expected_g13272,expected_g13259,expected_g13099,expected_g13085,expected_g13068,expected_g13049,expected_g13039,expected_g12923,expected_g12919,expected_g12832,expected_g12470,expected_g12422,expected_g12368,expected_g12350,expected_g12300,expected_g12238,expected_g12184,expected_g11770,expected_g11678,expected_g11447,expected_g11418,expected_g11388,expected_g11349,expected_g10527,expected_g10500,expected_g10306,expected_g10122,expected_g9817,expected_g9743,expected_g9741,expected_g9682,expected_g9680,expected_g9617,expected_g9615,expected_g9555,expected_g9553,expected_g9497,expected_g9251,expected_g9048,expected_g9019,expected_g8920,expected_g8919,expected_g8918,expected_g8917,expected_g8916,expected_g8915,expected_g8870,expected_g8839,expected_g8789,expected_g8788,expected_g8787,expected_g8786,expected_g8785,expected_g8784,expected_g8783,expected_g8719,expected_g8475,expected_g8416,expected_g8403,expected_g8398,expected_g8358,expected_g8353,expected_g8344,expected_g8342,expected_g8291,expected_g8283,expected_g8279,expected_g8277,expected_g8235,expected_g8215,expected_g8178,expected_g8132,expected_g7946,expected_g7916,expected_g7540,expected_g7260,expected_g7257,expected_g7245,expected_g7243};
`else
  assign bus.expected='0;
`endif
`endif
  assign bus.actual={g24167,g24165,g24182,g24169,g24184,g24176,g24166,g24183,g24175,g24180,g24179,g24162,g24173,g24164,g24185,g24170,g24163,g24171,g24177,g24161,g24172,g24181,g24174,g12833,g24178,g24168,g34972,g34956,g34927,g34925,g34923,g34921,g34919,g34917,g34915,g34913,g34839,g34788,g34597,g34437,g34436,g34435,g34425,g34383,g34240,g34239,g34238,g34237,g34236,g34235,g34234,g34233,g34232,g34221,g34201,g33959,g33950,g33949,g33948,g33947,g33946,g33945,g33935,g33894,g33874,g33659,g33636,g33533,g33435,g33079,g32975,g32454,g32429,g32185,g31863,g31862,g31861,g31860,g31793,g31665,g31656,g31521,g30332,g30331,g30330,g30329,g30327,g29221,g29220,g29219,g29218,g29217,g29216,g29215,g29214,g29213,g29212,g29211,g29210,g28753,g28042,g28041,g28030,g27831,g26877,g26876,g26875,g26801,g25590,g25589,g25588,g25587,g25586,g25585,g25584,g25583,g25582,g25259,g25219,g25167,g25114,1'b0,g23759,g23683,g23652,g23612,1'b0,g23002,g21727,g21698,g21292,g21270,g21245,g21176,g20901,g20899,g20763,g20654,g20652,g20557,g20049,g19357,g19334,g18881,g18101,g18100,g18099,g18098,g18097,g18096,g18095,g18094,g18092,g17871,g17845,g17819,g17813,g17787,g17778,g17764,g17760,g17743,g17739,g17722,g17715,g17711,g17688,g17685,g17678,g17674,g17649,g17646,g17639,g17607,g17604,g17580,g17577,g17519,g17423,g17404,g17400,g17320,g17316,g17291,g16955,g16924,g16874,g16775,g16748,g16744,g16722,g16718,g16693,g16686,g16659,g16656,g16627,g16624,g16603,g14828,g14779,g14749,g14738,g14705,g14694,g14673,g14662,g14635,g14597,g14518,g14451,g14421,g14217,g14201,g14189,g14167,g14147,g14125,g14096,g13966,g13926,g13906,g13895,g13881,g13865,g13272,g13259,g13099,g13085,g13068,g13049,g13039,g12923,g12919,g12832,g12470,g12422,g12368,g12350,g12300,g12238,g12184,g11770,g11678,g11447,g11418,g11388,g11349,g10527,g10500,g10306,g10122,g9817,g9743,g9741,g9682,g9680,g9617,g9615,g9555,g9553,g9497,g9251,g9048,g9019,g8920,g8919,g8918,g8917,g8916,g8915,g8870,g8839,g8789,g8788,g8787,g8786,g8785,g8784,g8783,g8719,g8475,g8416,g8403,g8398,g8358,g8353,g8344,g8342,g8291,g8283,g8279,g8277,g8235,g8215,g8178,g8132,g7946,g7916,g7540,g7260,g7257,g7245,g7243};
`ifdef DVBENCH_REPLAY
  initial begin
    integer input_file,scan_count;
    logic [0:0] column_0;
    logic [0:0] column_1;
    logic [0:0] column_2;
    logic [0:0] column_3;
    logic [0:0] column_4;
    logic [0:0] column_5;
    logic [0:0] column_6;
    logic [0:0] column_7;
    logic [0:0] column_8;
    logic [0:0] column_9;
    logic [0:0] column_10;
    logic [0:0] column_11;
    logic [0:0] column_12;
    logic [0:0] column_13;
    logic [0:0] column_14;
    logic [0:0] column_15;
    logic [0:0] column_16;
    logic [0:0] column_17;
    logic [0:0] column_18;
    logic [0:0] column_19;
    logic [0:0] column_20;
    logic [0:0] column_21;
    logic [0:0] column_22;
    logic [0:0] column_23;
    logic [0:0] column_24;
    logic [0:0] column_25;
    logic [0:0] column_26;
    logic [0:0] column_27;
    logic [0:0] column_28;
    logic [0:0] column_29;
    logic [0:0] column_30;
    logic [0:0] column_31;
    logic [0:0] column_32;
    logic [0:0] column_33;
    logic [0:0] column_34;
    logic [0:0] column_35;
    logic [0:0] column_36;
    logic [0:0] column_37;
    logic [0:0] column_38;
    logic [0:0] column_39;
    string input_directory,output_directory;
    if (!$value$plusargs("INPUT_DIR=%s",input_directory)) input_directory=phase12_input_directory();
    if (!$value$plusargs("OUTPUT_DIR=%s",output_directory)) output_directory="/run";
    input_file=$fopen({input_directory,"/variant0.inputs"},"r");
    bus.output_file=$fopen({output_directory,"/variant0.outputs"},"w");
    if(!input_file || !bus.output_file) $fatal(1,"missing trace");
    while(!$feof(input_file)) begin
      scan_count=$fscanf(input_file,"%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h\n",column_0,column_1,column_2,column_3,column_4,column_5,column_6,column_7,column_8,column_9,column_10,column_11,column_12,column_13,column_14,column_15,column_16,column_17,column_18,column_19,column_20,column_21,column_22,column_23,column_24,column_25,column_26,column_27,column_28,column_29,column_30,column_31,column_32,column_33,column_34,column_35,column_36,column_37,column_38,column_39);
      if(scan_count==40) bus.step({column_39,column_38,column_37,column_36,column_35,column_34,column_33,column_32,column_31,column_30,column_29,column_28,column_27,column_26,column_25,column_24,column_23,column_22,column_21,column_20,column_19,column_18,column_17,column_16,column_15,column_14,column_13,column_12,column_11,column_10,column_9,column_8,column_7,column_6,column_5,column_4,column_3,column_2,column_1,column_0});
      else if(scan_count!=-1) $fatal(1,"invalid record");
    end
    $fclose(input_file);$fclose(bus.output_file);bus.finished=1;
  end
`endif
endmodule
module dvbench_top;
  wire finished;
  dvbench_scenario scenario0(.finished(finished));
`ifdef DVBENCH_REPLAY
  initial begin wait(finished);#2;$display("DVBENCH_REPLAY_COMPLETED");$finish;end
`else
  initial begin
    uvm_config_db#(int)::set(null,"uvm_test_top","variant_count",1);
    uvm_config_db#(virtual dvbench_interface)::set(null,"uvm_test_top","vif0",scenario0.bus);
    run_test("dvbench_test");
  end
`endif
endmodule
