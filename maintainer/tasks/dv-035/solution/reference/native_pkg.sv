`timescale 1ns/1ps
package native_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class native_transaction extends uvm_sequence_item;
  `uvm_object_utils(native_transaction)
  logic [351-1:0] value;
  integer cycles;
  function new(string name="native_transaction");super.new(name);endfunction
endclass
class native_sequence extends uvm_sequence#(native_transaction);
  `uvm_object_utils(native_sequence)
  logic [351-1:0] drive=0;
  longint source_cycles=1;
  function new(string name="native_sequence");super.new(name);endfunction
  task apply(logic [351-1:0] value,integer cycles);
    native_transaction transaction;
    transaction=native_transaction::type_id::create("transaction");
    start_item(transaction);transaction.value=value;transaction.cycles=cycles;finish_item(transaction);
    source_cycles+=cycles;
  endtask
  task slow_tick(logic [351-1:0] value);
    longint next_tick;
    if(source_cycles<25000000)next_tick=25000000;
    else next_tick=25000000+((source_cycles-25000000)/50000000+1)*50000000;
    apply(value,next_tick-source_cycles);
  endtask
  task body();
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
      @(negedge vif.clk);vif.driven=req.value;
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
  logic [351-1:0] actual;
  logic [351-1:0] predicted;
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
      @(posedge vif.clk or vif.busy or vif.m_eth_dest_mac or vif.m_eth_src_mac or vif.m_eth_type or vif.m_ip_dest_ip or vif.m_ip_dscp or vif.m_ip_ecn or vif.m_ip_flags or vif.m_ip_fragment_offset or vif.m_ip_hdr_valid or vif.m_ip_header_checksum or vif.m_ip_identification or vif.m_ip_ihl or vif.m_ip_length or vif.m_ip_payload_axis_tdata or vif.m_ip_payload_axis_tkeep or vif.m_ip_payload_axis_tlast or vif.m_ip_payload_axis_tuser or vif.m_ip_payload_axis_tvalid or vif.m_ip_protocol or vif.m_ip_source_ip or vif.m_ip_ttl or vif.m_ip_version or vif.s_ip_hdr_ready or vif.s_ip_payload_axis_tready or vif.pred_busy or vif.pred_m_eth_dest_mac or vif.pred_m_eth_src_mac or vif.pred_m_eth_type or vif.pred_m_ip_dest_ip or vif.pred_m_ip_dscp or vif.pred_m_ip_ecn or vif.pred_m_ip_flags or vif.pred_m_ip_fragment_offset or vif.pred_m_ip_hdr_valid or vif.pred_m_ip_header_checksum or vif.pred_m_ip_identification or vif.pred_m_ip_ihl or vif.pred_m_ip_length or vif.pred_m_ip_payload_axis_tdata or vif.pred_m_ip_payload_axis_tkeep or vif.pred_m_ip_payload_axis_tlast or vif.pred_m_ip_payload_axis_tuser or vif.pred_m_ip_payload_axis_tvalid or vif.pred_m_ip_protocol or vif.pred_m_ip_source_ip or vif.pred_m_ip_ttl or vif.pred_m_ip_version or vif.pred_s_ip_hdr_ready or vif.pred_s_ip_payload_axis_tready or vif.driven);#1;
      sample=native_observation::type_id::create("sample");
      sample.actual={vif.busy,vif.m_eth_dest_mac,vif.m_eth_src_mac,vif.m_eth_type,vif.m_ip_dest_ip,vif.m_ip_dscp,vif.m_ip_ecn,vif.m_ip_flags,vif.m_ip_fragment_offset,vif.m_ip_hdr_valid,vif.m_ip_header_checksum,vif.m_ip_identification,vif.m_ip_ihl,vif.m_ip_length,vif.m_ip_payload_axis_tdata,vif.m_ip_payload_axis_tkeep,vif.m_ip_payload_axis_tlast,vif.m_ip_payload_axis_tuser,vif.m_ip_payload_axis_tvalid,vif.m_ip_protocol,vif.m_ip_source_ip,vif.m_ip_ttl,vif.m_ip_version,vif.s_ip_hdr_ready,vif.s_ip_payload_axis_tready};sample.predicted={vif.pred_busy,vif.pred_m_eth_dest_mac,vif.pred_m_eth_src_mac,vif.pred_m_eth_type,vif.pred_m_ip_dest_ip,vif.pred_m_ip_dscp,vif.pred_m_ip_ecn,vif.pred_m_ip_flags,vif.pred_m_ip_fragment_offset,vif.pred_m_ip_hdr_valid,vif.pred_m_ip_header_checksum,vif.pred_m_ip_identification,vif.pred_m_ip_ihl,vif.pred_m_ip_length,vif.pred_m_ip_payload_axis_tdata,vif.pred_m_ip_payload_axis_tkeep,vif.pred_m_ip_payload_axis_tlast,vif.pred_m_ip_payload_axis_tuser,vif.pred_m_ip_payload_axis_tvalid,vif.pred_m_ip_protocol,vif.pred_m_ip_source_ip,vif.pred_m_ip_ttl,vif.pred_m_ip_version,vif.pred_s_ip_hdr_ready,vif.pred_s_ip_payload_axis_tready};
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
  if(vif.busy !== vif.pred_busy) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("busy actual=%h expected=%h",vif.busy,vif.pred_busy))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_eth_dest_mac !== vif.pred_m_eth_dest_mac) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_eth_dest_mac actual=%h expected=%h",vif.m_eth_dest_mac,vif.pred_m_eth_dest_mac))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_eth_src_mac !== vif.pred_m_eth_src_mac) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_eth_src_mac actual=%h expected=%h",vif.m_eth_src_mac,vif.pred_m_eth_src_mac))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_eth_type !== vif.pred_m_eth_type) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_eth_type actual=%h expected=%h",vif.m_eth_type,vif.pred_m_eth_type))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_dest_ip !== vif.pred_m_ip_dest_ip) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_dest_ip actual=%h expected=%h",vif.m_ip_dest_ip,vif.pred_m_ip_dest_ip))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_dscp !== vif.pred_m_ip_dscp) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_dscp actual=%h expected=%h",vif.m_ip_dscp,vif.pred_m_ip_dscp))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_ecn !== vif.pred_m_ip_ecn) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_ecn actual=%h expected=%h",vif.m_ip_ecn,vif.pred_m_ip_ecn))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_flags !== vif.pred_m_ip_flags) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_flags actual=%h expected=%h",vif.m_ip_flags,vif.pred_m_ip_flags))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_fragment_offset !== vif.pred_m_ip_fragment_offset) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_fragment_offset actual=%h expected=%h",vif.m_ip_fragment_offset,vif.pred_m_ip_fragment_offset))
  end
end
if(1) begin
  if(vif.m_ip_hdr_valid !== vif.pred_m_ip_hdr_valid) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_hdr_valid actual=%h expected=%h",vif.m_ip_hdr_valid,vif.pred_m_ip_hdr_valid))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_header_checksum !== vif.pred_m_ip_header_checksum) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_header_checksum actual=%h expected=%h",vif.m_ip_header_checksum,vif.pred_m_ip_header_checksum))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_identification !== vif.pred_m_ip_identification) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_identification actual=%h expected=%h",vif.m_ip_identification,vif.pred_m_ip_identification))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_ihl !== vif.pred_m_ip_ihl) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_ihl actual=%h expected=%h",vif.m_ip_ihl,vif.pred_m_ip_ihl))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_length !== vif.pred_m_ip_length) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_length actual=%h expected=%h",vif.m_ip_length,vif.pred_m_ip_length))
  end
end
if(vif.pred_m_ip_payload_axis_tvalid) begin
  if(vif.m_ip_payload_axis_tdata !== vif.pred_m_ip_payload_axis_tdata) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_payload_axis_tdata actual=%h expected=%h",vif.m_ip_payload_axis_tdata,vif.pred_m_ip_payload_axis_tdata))
  end
end
if(vif.pred_m_ip_payload_axis_tvalid) begin
  if(vif.m_ip_payload_axis_tkeep !== vif.pred_m_ip_payload_axis_tkeep) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_payload_axis_tkeep actual=%h expected=%h",vif.m_ip_payload_axis_tkeep,vif.pred_m_ip_payload_axis_tkeep))
  end
end
if(vif.pred_m_ip_payload_axis_tvalid) begin
  if(vif.m_ip_payload_axis_tlast !== vif.pred_m_ip_payload_axis_tlast) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_payload_axis_tlast actual=%h expected=%h",vif.m_ip_payload_axis_tlast,vif.pred_m_ip_payload_axis_tlast))
  end
end
if(vif.pred_m_ip_payload_axis_tvalid) begin
  if(vif.m_ip_payload_axis_tuser !== vif.pred_m_ip_payload_axis_tuser) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_payload_axis_tuser actual=%h expected=%h",vif.m_ip_payload_axis_tuser,vif.pred_m_ip_payload_axis_tuser))
  end
end
if(1) begin
  if(vif.m_ip_payload_axis_tvalid !== vif.pred_m_ip_payload_axis_tvalid) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_payload_axis_tvalid actual=%h expected=%h",vif.m_ip_payload_axis_tvalid,vif.pred_m_ip_payload_axis_tvalid))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_protocol !== vif.pred_m_ip_protocol) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_protocol actual=%h expected=%h",vif.m_ip_protocol,vif.pred_m_ip_protocol))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_source_ip !== vif.pred_m_ip_source_ip) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_source_ip actual=%h expected=%h",vif.m_ip_source_ip,vif.pred_m_ip_source_ip))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_ttl !== vif.pred_m_ip_ttl) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_ttl actual=%h expected=%h",vif.m_ip_ttl,vif.pred_m_ip_ttl))
  end
end
if(vif.pred_m_ip_hdr_valid) begin
  if(vif.m_ip_version !== vif.pred_m_ip_version) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("m_ip_version actual=%h expected=%h",vif.m_ip_version,vif.pred_m_ip_version))
  end
end
if(1) begin
  if(vif.s_ip_hdr_ready !== vif.pred_s_ip_hdr_ready) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_ip_hdr_ready actual=%h expected=%h",vif.s_ip_hdr_ready,vif.pred_s_ip_hdr_ready))
  end
end
if(1) begin
  if(vif.s_ip_payload_axis_tready !== vif.pred_s_ip_payload_axis_tready) begin
    mismatches++; if(mismatches<25) `uvm_error("COMPARE",$sformatf("s_ip_payload_axis_tready actual=%h expected=%h",vif.s_ip_payload_axis_tready,vif.pred_s_ip_payload_axis_tready))
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
    if($isunknown({vif.s_ip_hdr_ready,vif.s_ip_payload_axis_tready,vif.m_ip_hdr_valid,vif.m_ip_payload_axis_tvalid,vif.busy}))
                    `uvm_error("CONTROL_XZ","FIFO handshake output contains X/Z")
                  if(vif.busy !== 1'b0) `uvm_error("BUSY","fixed design busy must be zero")
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
    reset:coverpoint vif.rst;
 payload_input:coverpoint {vif.s_ip_payload_axis_tvalid,vif.s_ip_payload_axis_tready};
 payload_output:coverpoint {vif.m_ip_payload_axis_tvalid,vif.m_ip_payload_axis_tready};
 header_input:coverpoint {vif.s_ip_hdr_valid,vif.s_ip_hdr_ready};
 header_output:coverpoint {vif.m_ip_hdr_valid,vif.m_ip_hdr_ready};
 last:coverpoint vif.m_ip_payload_axis_tlast iff(vif.m_ip_payload_axis_tvalid);
 user:coverpoint vif.m_ip_payload_axis_tuser iff(vif.m_ip_payload_axis_tvalid);
 keep:coverpoint vif.m_ip_payload_axis_tkeep iff(vif.m_ip_payload_axis_tvalid) {bins zero={0};bins full={255};bins sparse={[1:254]};}
 version:coverpoint vif.m_ip_version iff(vif.m_ip_hdr_valid);
 ihl:coverpoint vif.m_ip_ihl iff(vif.m_ip_hdr_valid);
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
