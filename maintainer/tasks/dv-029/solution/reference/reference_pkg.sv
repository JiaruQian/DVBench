`timescale 1ns/1ps
package reference_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class reference_item extends uvm_sequence_item;
  `uvm_object_utils(reference_item)
  logic [1023:0] inputs, actual, predicted, valid_mask;
  int tag; int delay_ns = 4; int clock_cycles=0; int probe_stride=1000;
  function new(string name="reference_item"); super.new(name); endfunction
endclass
class reference_driver extends uvm_driver #(reference_item);
  `uvm_component_utils(reference_driver)
  virtual reference_if vif;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual reference_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      #(req.delay_ns);
      vif.ack_i = req.inputs[0 +: 1]; vif.adrClutCacheUpdate = req.inputs[1 +: 15]; vif.adrTexCacheUpdateL = req.inputs[16 +: 17]; vif.adrTexCacheUpdateR = req.inputs[33 +: 17]; vif.dat_i = req.inputs[50 +: 32]; vif.exportedBGBlock = req.inputs[82 +: 256]; vif.exportedMSKBGBlock = req.inputs[338 +: 16]; vif.gpuClk = req.inputs[354 +: 1]; vif.i_nRst = req.inputs[355 +: 1]; vif.isBlending = req.inputs[356 +: 1]; vif.loadAdr = req.inputs[357 +: 15]; vif.memoryWriteCommand = req.inputs[372 +: 56]; vif.requClutCacheUpdate = req.inputs[428 +: 1]; vif.requTexCacheUpdateL = req.inputs[429 +: 1]; vif.requTexCacheUpdateR = req.inputs[430 +: 1]; vif.saveAdr = req.inputs[431 +: 15]; vif.saveBGBlock = req.inputs[446 +: 2];
      vif.valid_mask=req.valid_mask; vif.tag=req.tag;
      
      #1; ->vif.observe;
      #1; seq_item_port.item_done();
    end
  endtask
endclass
class reference_monitor extends uvm_monitor;
  `uvm_component_utils(reference_monitor)
  virtual reference_if vif;
  uvm_analysis_port #(reference_item) ap;
  function new(string name,uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual reference_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  task run_phase(uvm_phase phase);
    reference_item item;
    forever begin
      @vif.observe; item=reference_item::type_id::create("observed");
      item.actual='0; item.actual[0 +: 32] = vif.ClutCacheData; item.actual[32 +: 1] = vif.ClutCacheWrite; item.actual[33 +: 3] = vif.ClutWriteIndex; item.actual[36 +: 64] = vif.TexCacheData; item.actual[100 +: 1] = vif.TexCacheWrite; item.actual[101 +: 17] = vif.adrTexCacheWrite; item.actual[118 +: 20] = vif.adr_o; item.actual[138 +: 3] = vif.cnt_o; item.actual[141 +: 32] = vif.dat_o; item.actual[173 +: 1] = vif.fifoComplete; item.actual[174 +: 1] = vif.fifoFull; item.actual[175 +: 1] = vif.importBGBlockSingleClock; item.actual[176 +: 256] = vif.importedBGBlock; item.actual[432 +: 1] = vif.req_o; item.actual[433 +: 1] = vif.resetMask; item.actual[434 +: 1] = vif.resetPipelinePixelStateSpike; item.actual[435 +: 1] = vif.saveLoadOnGoing; item.actual[436 +: 4] = vif.sel_o; item.actual[440 +: 1] = vif.updateClutCacheComplete; item.actual[441 +: 1] = vif.updateTexCacheCompleteL; item.actual[442 +: 1] = vif.updateTexCacheCompleteR; item.actual[443 +: 1] = vif.wrt_o;
      item.valid_mask=vif.valid_mask; item.tag=vif.tag; ap.write(item);
    end
  endtask
endclass
class reference_predictor extends uvm_component;
  `uvm_component_utils(reference_predictor)
  virtual reference_if vif;
  uvm_analysis_imp #(reference_item,reference_predictor) imp;
  uvm_analysis_port #(reference_item) ap;
  function new(string name,uvm_component parent); super.new(name,parent); imp=new("imp",this); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual reference_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
  endfunction
  function void write(reference_item item);
    item.predicted='0; item.predicted[0 +: 32] = vif.predicted_ClutCacheData; item.predicted[32 +: 1] = vif.predicted_ClutCacheWrite; item.predicted[33 +: 3] = vif.predicted_ClutWriteIndex; item.predicted[36 +: 64] = vif.predicted_TexCacheData; item.predicted[100 +: 1] = vif.predicted_TexCacheWrite; item.predicted[101 +: 17] = vif.predicted_adrTexCacheWrite; item.predicted[118 +: 20] = vif.predicted_adr_o; item.predicted[138 +: 3] = vif.predicted_cnt_o; item.predicted[141 +: 32] = vif.predicted_dat_o; item.predicted[173 +: 1] = vif.predicted_fifoComplete; item.predicted[174 +: 1] = vif.predicted_fifoFull; item.predicted[175 +: 1] = vif.predicted_importBGBlockSingleClock; item.predicted[176 +: 256] = vif.predicted_importedBGBlock; item.predicted[432 +: 1] = vif.predicted_req_o; item.predicted[433 +: 1] = vif.predicted_resetMask; item.predicted[434 +: 1] = vif.predicted_resetPipelinePixelStateSpike; item.predicted[435 +: 1] = vif.predicted_saveLoadOnGoing; item.predicted[436 +: 4] = vif.predicted_sel_o; item.predicted[440 +: 1] = vif.predicted_updateClutCacheComplete; item.predicted[441 +: 1] = vif.predicted_updateTexCacheCompleteL; item.predicted[442 +: 1] = vif.predicted_updateTexCacheCompleteR; item.predicted[443 +: 1] = vif.predicted_wrt_o;
    ap.write(item);
  endfunction
endclass
class reference_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(reference_scoreboard)
  uvm_analysis_imp #(reference_item,reference_scoreboard) imp;
  int comparisons=0, mismatches=0;
  function new(string name,uvm_component parent); super.new(name,parent); imp=new("imp",this); endfunction
  function void write(reference_item item);
    bit mismatch;
    mismatch=0;
    for(int signal_bit=0;signal_bit<444;signal_bit++)
      if(item.valid_mask[signal_bit] && item.actual[signal_bit] !== item.predicted[signal_bit]) mismatch=1;
    if(item.valid_mask!='0) begin
      comparisons++;
      if(mismatch) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE",$sformatf("tag=%0d actual=%h expected=%h mask=%h",item.tag,item.actual,item.predicted,item.valid_mask))
      end
    end
  endfunction
  function void check_phase(uvm_phase phase);
    if(comparisons==0) `uvm_error("VACUOUS","no comparisons")
    if(mismatches>12) `uvm_error("TOTAL",$sformatf("total mismatches=%0d",mismatches))
  endfunction
  function void report_phase(uvm_phase phase);
    `uvm_info("COUNTS",$sformatf("points=%0d mismatches=%0d",comparisons,mismatches),UVM_NONE)
  endfunction
endclass
class reference_checker extends uvm_subscriber #(reference_item);
  `uvm_component_utils(reference_checker)
  int observed=0;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void write(reference_item item);
    if(item.valid_mask!='0) begin
      observed++;
      if($isunknown(item.actual & item.valid_mask & ~1024'd35917864239044270117773758448835371491064198176178176)) `uvm_error("FOUR_STATE","unknown valid output")
    end
  endfunction
endclass
class reference_coverage extends uvm_subscriber #(reference_item);
  `uvm_component_utils(reference_coverage)
  int tag;
  covergroup behavior; option.per_instance=1; cp_tag: coverpoint tag { bins exercised[]={[0:31]}; } endgroup
  function new(string name,uvm_component parent); super.new(name,parent); behavior=new(); endfunction
  function void write(reference_item item); tag=item.tag; behavior.sample(); endfunction
endclass
class reference_sequence extends uvm_sequence #(reference_item);
  `uvm_object_utils(reference_sequence)
  logic [1023:0] pins='0;
  int serial=0;
  function new(string name="reference_sequence"); super.new(name); endfunction
  task send(logic [1023:0] mask, int tag=0, int delay_ns=4);
    reference_item item;
    item=reference_item::type_id::create("stimulus"); start_item(item);
    item.inputs=pins; item.valid_mask=mask; item.tag=tag; item.delay_ns=delay_ns;
    serial++; finish_item(item);
  endtask
  
  virtual reference_if stimulus_if;
  bit background_ready=0,texture_ready=0,reset_established=0;
  task observation(int tag=0);
    logic [1023:0] mask;
    mask=1024'd42754566683342965134699146719486350706989859702295091589128795133077460566362747191084755235668273241824430077013073972225057220460543;
    if(stimulus_if.predicted_req_o) mask|=1024'd348448811420042040357527372058365578444800;
    if(stimulus_if.predicted_req_o&&stimulus_if.predicted_wrt_o) mask|=1024'd2661762906355982265195277616777360355298979592360783912163660397390036455493400610090996840087137551081753819442773141896169395322880;
    if(stimulus_if.predicted_TexCacheWrite&&texture_ready) mask|=1024'd332305731295628739996550199647404032;
    if(stimulus_if.predicted_importBGBlockSingleClock&&background_ready) mask|=1024'd11090678776483259438313656736572334813745748301503266300681918322458485231222406711188593506362910915700367949521638116120760156160;
    send(reset_established ? mask : 0,tag);
  endtask
  task cycle_native(int tag=0);
    pins[354 +: 1]=0;send(0,tag);observation(tag);
    pins[354 +: 1]=1;send(0,tag);reset_established=1;observation(tag);
    pins[354 +: 1]=0;send(0,tag);
  endtask
  task beats(int count,int tag=0,bit background_read=0);
    pins[0 +: 1]=1;
    for(int beat=0;beat<count;beat++) begin pins[50 +: 32]=$urandom;cycle_native(tag);end
    if(background_read&&count>=8) background_ready=1;
    if(tag==5&&count>=1) texture_ready=1;
    pins[0 +: 1]=0;pins[50 +: 32]=$urandom;cycle_native(tag);
    pins[429 +: 1]=0;pins[430 +: 1]=0;pins[428 +: 1]=0;
    cycle_native(tag);
  endtask
  task command_port(int kind,int bank,int rotation=0,int force_value=0,int check_value=0,int clear_value=0,int mask=65535,int tag=1);
    pins[372 +: 56]=(56'(mask)<<40)|(56'($urandom_range(0,32767))<<7)|kind|(bank<<3);
    if(kind==4) pins[372 +: 56]|=(56'(rotation)<<24)|(force_value<<4)|(check_value<<5)|(clear_value<<22);
    if(kind==1) pins[372 +: 56]|=(56'($urandom_range(0,65535))<<24)|(56'($urandom_range(0,3))<<22)|($urandom_range(0,7)<<4);
    cycle_native(tag);pins[372 +: 56]=0;
    beats(kind==1 ? 1 : 8,tag);
  endtask
  task extended_ack_and_partial_clear();
    pins[446+:2]=0;pins[428+:3]=0;pins[372+:56]=0;pins[0]=0;
    repeat(3)cycle_native(10);
    for(int length_case=0;length_case<4;length_case++)begin
      pins[372+:56]=(56'h1357<<40)|(56'h4567<<7)|56'd2;
      cycle_native(4);pins[372+:56]=0;
      beats(17+length_case*8,4);
      pins[428]=1;pins[1+:15]=15'h7fed;
      cycle_native(6);beats(17+length_case*8,6);
    end
    for(int length_value=1;length_value<8;length_value++)begin
      for(int clear_value=1;clear_value<4;clear_value++)begin
        command_port(3,0,0,0,0,0,65535,7);
        command_port(3,1,0,0,0,0,65535,7);
        pins[372+:56]=(56'(clear_value)<<22)|(56'h2468<<7)|56'd4;
        cycle_native(8);pins[372+:56]=0;
        beats(length_value,8);
        command_port(4,0,0,0,0,0,0,8);
        command_port(4,1,0,0,0,0,0,8);
      end
    end
  endtask
  task body();
    if(!uvm_config_db#(virtual reference_if)::get(null,"","vif",stimulus_if)) `uvm_fatal("VIF","missing")
    pins[355 +: 1]=0;repeat(3) cycle_native(0);pins[355 +: 1]=1;cycle_native(0);
    command_port(3,0,0,0,0,0,65535,7);command_port(3,1,0,0,0,0,65535,7);
    for(int trial=0;trial<8;trial++) command_port(1,0,0,0,0,0,$urandom_range(0,65535),3);
    command_port(2,0,0,0,0,0,0,4);command_port(2,0,0,0,0,0,65535,4);
    for(int bank=0;bank<2;bank++) for(int rotation=0;rotation<16;rotation++) begin
      command_port(4,bank,rotation,rotation%2,(rotation/2)%2,0,16'ha55a,8);
    end
    for(int side=0;side<3;side++) begin
      pins[429 +: 1]=side!=1;pins[430 +: 1]=side!=0;
      pins[16 +: 17]=17'h12345;pins[33 +: 17]=17'h5432;
      cycle_native(5);beats(2,5);pins[429 +: 1]=0;pins[430 +: 1]=0;cycle_native(5);
    end
    pins[428 +: 1]=1;pins[1 +: 15]=15'h7fed;
    cycle_native(6);beats(8,6);pins[428 +: 1]=0;cycle_native(6);
    for(int blend=0;blend<2;blend++) for(int block_value=1;block_value<4;block_value++) begin
      pins[446 +: 2]=0;cycle_native(9);
      pins[446 +: 2]=block_value;pins[356 +: 1]=blend;pins[431 +: 15]=15'h123;pins[357 +: 15]=15'h456;
      pins[338 +: 16]=16'ha55a;
      for(int word_index=0;word_index<8;word_index++) pins[82+word_index*32 +:32]=$urandom;
      cycle_native(9);
      if(block_value!=1 || blend) begin beats(8,9,blend&&block_value==1);if(blend&&block_value==2) beats(8,9,1);end
      repeat(3) cycle_native(9);
    end
    pins[446 +: 2]=0;pins[355 +: 1]=0;repeat(2) cycle_native(0);
    pins[355 +: 1]=1;repeat(3) cycle_native(0);
    extended_ack_and_partial_clear();
    for(int pattern=0;pattern<64;pattern++) begin
      pins='0;pins[355]=0;repeat(2)cycle_native(20);
      pins[355]=1;cycle_native(20);
      pins[372+:56]=(56'(16'h1357)<<40)|(56'(pattern)<<7)|56'd2;
      cycle_native(20);pins[372+:56]=0;pins[0]=1;
      send(0,20);observation(20);
      pins[355]=0;send(0,20);observation(20);
      if(stimulus_if.predicted_req_o!==1'b1 || stimulus_if.predicted_wrt_o!==1'b1)
        `uvm_error("NONVACUITY","A reset pulse without a source rising edge must preserve active fill")
      pins[355]=1;send(0,20);observation(20);
      cycle_native(20);pins[0]=0;cycle_native(20);cycle_native(20);
      pins='0;pins[355]=0;repeat(2)cycle_native(21);
      pins[355]=1;cycle_native(21);
      pins[429]=1;pins[16+:17]=17'(pattern*17);
      cycle_native(21);pins[429]=0;pins[0]=1;
      pins[50+:32]=pattern<32 ? (32'b1<<pattern) : ~(32'b1<<(pattern-32));
      pins[354]=0;send(0,21);observation(21);
      pins[354]=1;send(0,21);observation(21);
      pins[50+:32]=~pins[50+:32];send(0,21);observation(21);
      pins[354]=0;send(0,21);
      pins[50+:32]=32'h76543210^32'(pattern);cycle_native(21);
      texture_ready=1;pins[0]=0;send(0,21);observation(21);
      if(stimulus_if.predicted_TexCacheWrite!==1'b1 || stimulus_if.predicted_TexCacheData[31:0] !== (pattern<32 ? (32'b1<<pattern) : ~(32'b1<<(pattern-32))))
        `uvm_error("NONVACUITY","TEX termination must expose the original rising-edge first word")
      cycle_native(21);cycle_native(21);
    end
  endtask

endclass
class reference_env extends uvm_env;
  `uvm_component_utils(reference_env)
  uvm_sequencer #(reference_item) sequencer;
  reference_driver driver; reference_monitor monitor; reference_predictor predictor;
  reference_scoreboard scoreboard; reference_checker checker; reference_coverage coverage;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    sequencer=uvm_sequencer#(reference_item)::type_id::create("sequencer",this);
    driver=reference_driver::type_id::create("driver",this); monitor=reference_monitor::type_id::create("monitor",this);
    predictor=reference_predictor::type_id::create("predictor",this); scoreboard=reference_scoreboard::type_id::create("scoreboard",this);
    checker=reference_checker::type_id::create("checker",this); coverage=reference_coverage::type_id::create("coverage",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.ap.connect(predictor.imp); predictor.ap.connect(scoreboard.imp);
    monitor.ap.connect(checker.analysis_export); monitor.ap.connect(coverage.analysis_export);
  endfunction
endclass
class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  reference_env env;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); env=reference_env::type_id::create("env",this); endfunction
  task run_phase(uvm_phase phase);
    reference_sequence sequence_instance;
    phase.raise_objection(this); sequence_instance=reference_sequence::type_id::create("sequence_instance");
    sequence_instance.start(env.sequencer); #20; phase.drop_objection(this);
  endtask
  function void report_phase(uvm_phase phase);
    uvm_report_server server; server=uvm_report_server::get_server();
    if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
  endfunction
endclass
endpackage
