`timescale 1ns/1ps
package native_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class native_transaction extends uvm_sequence_item;
  `uvm_object_utils(native_transaction)
  logic [59-1:0] value;
  integer cycles;
  function new(string name="native_transaction");super.new(name);endfunction
endclass
class native_sequence extends uvm_sequence#(native_transaction);
  `uvm_object_utils(native_sequence)
  logic [59-1:0] drive=0;
  function new(string name="native_sequence");super.new(name);endfunction
  task apply(logic [59-1:0] value,integer cycles);
    native_transaction transaction;
    transaction=native_transaction::type_id::create("transaction");
    start_item(transaction);transaction.value=value;transaction.cycles=cycles;finish_item(transaction);
  endtask
  virtual native_if vif;
  `include "concurrent_witnesses.svh"
  task body();
    if(!uvm_config_db#(virtual native_if)::get(null,"*","vif",vif)) `uvm_fatal("VIF","sequence interface missing")
    `include "stimulus.svh"
  endtask
endclass
class native_driver extends uvm_driver#(native_transaction);
  `uvm_component_utils(native_driver)
  virtual native_if vif;
  logic [63:0] history_hash=64'hcbf29ce484222325;
  longint unsigned driven_cycles=0;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","driver interface missing")
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      @(negedge vif.s_axi_lite_clk);vif.driven=req.value;
      history_hash=(history_hash ^ req.value ^ req.cycles)*64'h100000001b3;
      driven_cycles+=req.cycles;
      #(10ns*req.cycles-5ns);
      seq_item_port.item_done();
    end
  endtask
  function void report_phase(uvm_phase phase);
    `uvm_info("INPUT_HISTORY",$sformatf("hash=%h cycles=%0d",history_hash,driven_cycles),UVM_LOW)
  endfunction
endclass
class native_observation extends uvm_sequence_item;
  `uvm_object_utils(native_observation)
  logic [47-1:0] actual;
  logic [47-1:0] predicted;
  function new(string name="native_observation");super.new(name);endfunction
endclass
class native_monitor extends uvm_monitor;
  `uvm_component_utils(native_monitor)
  virtual native_if vif;
  uvm_analysis_port#(native_observation) observations;
  function new(string name,uvm_component parent);super.new(name,parent);observations=new("observations",this);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","monitor interface missing")
  endfunction
  task run_phase(uvm_phase phase);
    native_observation sample;
    forever begin
      @(vif.init_done_o or vif.init_fail_o or vif.mdc_o or vif.mdio_io or vif.phy_link_change_o or vif.phy_link_o or vif.s_axi_arready or vif.s_axi_awready or vif.s_axi_bresp or vif.s_axi_bvalid or vif.s_axi_rdata or vif.s_axi_rresp or vif.s_axi_rvalid or vif.s_axi_wready or vif.pred_init_done_o or vif.pred_init_fail_o or vif.pred_mdc_o or vif.pred_mdio_io or vif.pred_phy_link_change_o or vif.pred_phy_link_o or vif.pred_s_axi_arready or vif.pred_s_axi_awready or vif.pred_s_axi_bresp or vif.pred_s_axi_bvalid or vif.pred_s_axi_rdata or vif.pred_s_axi_rresp or vif.pred_s_axi_rvalid or vif.pred_s_axi_wready or vif.driven);#1;
      sample=native_observation::type_id::create("sample");
      sample.actual={vif.init_done_o,vif.init_fail_o,vif.mdc_o,vif.mdio_io,vif.phy_link_change_o,vif.phy_link_o,vif.s_axi_arready,vif.s_axi_awready,vif.s_axi_bresp,vif.s_axi_bvalid,vif.s_axi_rdata,vif.s_axi_rresp,vif.s_axi_rvalid,vif.s_axi_wready};sample.predicted={vif.pred_init_done_o,vif.pred_init_fail_o,vif.pred_mdc_o,vif.pred_mdio_io,vif.pred_phy_link_change_o,vif.pred_phy_link_o,vif.pred_s_axi_arready,vif.pred_s_axi_awready,vif.pred_s_axi_bresp,vif.pred_s_axi_bvalid,vif.pred_s_axi_rdata,vif.pred_s_axi_rresp,vif.pred_s_axi_rvalid,vif.pred_s_axi_wready};
      observations.write(sample);
    end
  endtask
endclass
class native_predictor extends uvm_component;
  `uvm_component_utils(native_predictor)
  uvm_analysis_imp#(native_observation,native_predictor) observations;
  uvm_analysis_port#(native_observation) predictions;
  function new(string name,uvm_component parent);
    super.new(name,parent);observations=new("observations",this);predictions=new("predictions",this);
  endfunction
  function void write(native_observation sample);predictions.write(sample);endfunction
endclass
class native_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(native_scoreboard)
  virtual native_if vif;
  integer comparisons=0;
  integer mismatches=0;
  uvm_analysis_imp#(native_observation,native_scoreboard) predictions;
  function new(string name,uvm_component parent);super.new(name,parent);predictions=new("predictions",this);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","scoreboard interface missing")
  endfunction
  function void write(native_observation sample);
    if($time<30)return;
    comparisons++;
    if(1) begin
  if(vif.init_done_o !== vif.pred_init_done_o) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("init_done_o actual=%h expected=%h",vif.init_done_o,vif.pred_init_done_o))
  end
end
if(1) begin
  if(vif.init_fail_o !== vif.pred_init_fail_o) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("init_fail_o actual=%h expected=%h",vif.init_fail_o,vif.pred_init_fail_o))
  end
end
if(1) begin
  if(vif.mdc_o !== vif.pred_mdc_o) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("mdc_o actual=%h expected=%h",vif.mdc_o,vif.pred_mdc_o))
  end
end
if(1) begin
  if(vif.mdio_io !== vif.pred_mdio_io) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("mdio_io actual=%h expected=%h",vif.mdio_io,vif.pred_mdio_io))
  end
end
if(1) begin
  if(vif.phy_link_change_o !== vif.pred_phy_link_change_o) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("phy_link_change_o actual=%h expected=%h",vif.phy_link_change_o,vif.pred_phy_link_change_o))
  end
end
if(1) begin
  if(vif.phy_link_o !== vif.pred_phy_link_o) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("phy_link_o actual=%h expected=%h",vif.phy_link_o,vif.pred_phy_link_o))
  end
end
if(1) begin
  if(vif.s_axi_arready !== vif.pred_s_axi_arready) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_axi_arready actual=%h expected=%h",vif.s_axi_arready,vif.pred_s_axi_arready))
  end
end
if(1) begin
  if(vif.s_axi_awready !== vif.pred_s_axi_awready) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_axi_awready actual=%h expected=%h",vif.s_axi_awready,vif.pred_s_axi_awready))
  end
end
if(1) begin
  if(vif.s_axi_bresp !== vif.pred_s_axi_bresp) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_axi_bresp actual=%h expected=%h",vif.s_axi_bresp,vif.pred_s_axi_bresp))
  end
end
if(1) begin
  if(vif.s_axi_bvalid !== vif.pred_s_axi_bvalid) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_axi_bvalid actual=%h expected=%h",vif.s_axi_bvalid,vif.pred_s_axi_bvalid))
  end
end
if(1) begin
  if(vif.s_axi_rdata !== vif.pred_s_axi_rdata) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_axi_rdata actual=%h expected=%h",vif.s_axi_rdata,vif.pred_s_axi_rdata))
  end
end
if(1) begin
  if(vif.s_axi_rresp !== vif.pred_s_axi_rresp) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_axi_rresp actual=%h expected=%h",vif.s_axi_rresp,vif.pred_s_axi_rresp))
  end
end
if(1) begin
  if(vif.s_axi_rvalid !== vif.pred_s_axi_rvalid) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_axi_rvalid actual=%h expected=%h",vif.s_axi_rvalid,vif.pred_s_axi_rvalid))
  end
end
if(1) begin
  if(vif.s_axi_wready !== vif.pred_s_axi_wready) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_axi_wready actual=%h expected=%h",vif.s_axi_wready,vif.pred_s_axi_wready))
  end
end

  endfunction
  function void check_phase(uvm_phase phase);
    if(comparisons==0) `uvm_error("VACUOUS","no comparison performed")
    `uvm_info("COUNTS",$sformatf("compared=%0d mismatched=%0d",comparisons,mismatches),UVM_LOW)
  endfunction
endclass
class native_checker extends uvm_subscriber#(native_observation);
  `uvm_component_utils(native_checker)
  integer observed=0;
  integer checked=0;
  virtual native_if vif;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","checker interface missing")
  endfunction
  function void write(native_observation sample);
    observed++;
    if($time<30)return;
    if(vif.s_axi_bvalid && vif.s_axi_bresp !== 2'b00)
                    `uvm_error("BRESP","write response must be OKAY")
                  if(vif.s_axi_rvalid && vif.s_axi_rresp !== 2'b00)
                    `uvm_error("RRESP","read response must be OKAY")
    checked++;
  endfunction
  function void check_phase(uvm_phase phase);
    if(checked==0) `uvm_error("CHECKER","no protocol observation")
  endfunction
endclass
class native_coverage extends uvm_subscriber#(native_observation);
  `uvm_component_utils(native_coverage)
  logic [7:0] observed;
  virtual native_if vif;
  covergroup output_events;
    option.per_instance=1;
    reset:coverpoint vif.s_axi_lite_resetn;
 write_response:coverpoint {vif.s_axi_bvalid,vif.s_axi_bready};
 read_response:coverpoint {vif.s_axi_rvalid,vif.s_axi_rready};
 init_complete:coverpoint vif.init_done_o;
 init_failed:coverpoint vif.init_fail_o;
 link:coverpoint vif.phy_link_o;
 link_change:coverpoint vif.phy_link_change_o;
 direction:coverpoint vif.s_axi_wdata[16] iff(vif.s_axi_wvalid && vif.s_axi_awaddr==0);
 strobes:coverpoint vif.s_axi_wstrb iff(vif.s_axi_wvalid) {bins zero={0};bins low={1};bins high={2};bins direction={4};bins both={3};bins all={15};}
  endgroup
  function new(string name,uvm_component parent);super.new(name,parent);output_events=new;endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual native_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","coverage interface missing")
  endfunction
  function void write(native_observation sample);observed=sample.actual;output_events.sample();endfunction
endclass
class native_env extends uvm_env;
  `uvm_component_utils(native_env)
  uvm_sequencer#(native_transaction) sequencer;
  native_driver driver;
  native_monitor monitor;
  native_predictor predictor;
  native_scoreboard scoreboard;
  native_checker checker;
  native_coverage coverage;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer=uvm_sequencer#(native_transaction)::type_id::create("sequencer",this);
    driver=native_driver::type_id::create("driver",this);
    monitor=native_monitor::type_id::create("monitor",this);
    predictor=native_predictor::type_id::create("predictor",this);
    scoreboard=native_scoreboard::type_id::create("scoreboard",this);
    checker=native_checker::type_id::create("checker",this);
    coverage=native_coverage::type_id::create("coverage",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.observations.connect(predictor.observations);
    predictor.predictions.connect(scoreboard.predictions);
    monitor.observations.connect(checker.analysis_export);
    monitor.observations.connect(coverage.analysis_export);
  endfunction
endclass
class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  native_env environment;
  function new(string name,uvm_component parent);super.new(name,parent);endfunction
  function void build_phase(uvm_phase phase);environment=native_env::type_id::create("environment",this);endfunction
  task run_phase(uvm_phase phase);
    native_sequence active_sequence;
    phase.raise_objection(this);active_sequence=native_sequence::type_id::create("active_sequence");
    active_sequence.start(environment.sequencer);#30;phase.drop_objection(this);
  endtask
  function void report_phase(uvm_phase phase);
    uvm_report_server server;
    server=uvm_report_server::get_server();
    if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)
      $display("DVBench_COMPLETED");
    $display("DVBench_END_OF_RUN");
  endfunction
endclass
endpackage
