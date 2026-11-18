`timescale 1ns/1ps
package reference_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class reference_item extends uvm_sequence_item;
  `uvm_object_utils(reference_item)
  logic [1023:0] inputs, actual, predicted, valid_mask;
  int tag; int delay_ns = 4;
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
      vif.clka = req.inputs[0 +: 1]; vif.rsta = req.inputs[1 +: 1]; vif.wea = req.inputs[2 +: 1]; vif.addra = req.inputs[3 +: 8]; vif.dina = req.inputs[11 +: 24]; vif.clkb = req.inputs[35 +: 1]; vif.rstb = req.inputs[36 +: 1]; vif.web = req.inputs[37 +: 1]; vif.addrb = req.inputs[38 +: 8]; vif.dinb = req.inputs[46 +: 24];
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
      item.actual='0; item.actual[0 +: 24] = vif.douta; item.actual[24 +: 24] = vif.doutb; item.actual[48 +: 1] = vif.rsta_busy; item.actual[49 +: 1] = vif.rstb_busy;
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
    item.predicted='0; item.predicted[0 +: 24] = vif.predicted_douta; item.predicted[24 +: 24] = vif.predicted_doutb; item.predicted[48 +: 1] = vif.predicted_rsta_busy; item.predicted[49 +: 1] = vif.predicted_rstb_busy;
    ap.write(item);
  endfunction
endclass
class reference_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(reference_scoreboard)
  uvm_analysis_imp #(reference_item,reference_scoreboard) imp;
  int comparisons=0, mismatches=0;
  function new(string name,uvm_component parent); super.new(name,parent); imp=new("imp",this); endfunction
  function void write(reference_item item);
    if(item.valid_mask!='0) begin
      comparisons++;
      if((item.actual & item.valid_mask) !== (item.predicted & item.valid_mask)) begin
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
      if($isunknown(item.actual & item.valid_mask)) `uvm_error("FOUR_STATE","unknown valid output")
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
  
  task edge_port(int side, int address, logic [23:0] data, bit write_enable, bit reset_value=0, int tag=0, bit check=1);
    if(side==0) begin
      pins[0 +: 1]=0; pins[3 +: 8]=address; pins[11 +: 24]=data; pins[2 +: 1]=write_enable; pins[1 +: 1]=reset_value;
      send(check ? 1024'd1125899906842623 : 0,tag);
      pins[0 +: 1]=1; send(check ? 1024'd1125899906842623 : 0,tag);
      pins[0 +: 1]=0; send(check ? 1024'd1125899906842623 : 0,tag);
    end else begin
      pins[35 +: 1]=0; pins[38 +: 8]=address; pins[46 +: 24]=data; pins[37 +: 1]=write_enable; pins[36 +: 1]=reset_value;
      send(check ? 1024'd1125899906842623 : 0,tag);
      pins[35 +: 1]=1; send(check ? 1024'd1125899906842623 : 0,tag);
      pins[35 +: 1]=0; send(check ? 1024'd1125899906842623 : 0,tag);
    end
  endtask
  virtual reference_if witness_vif;
  task pc3_storage_witnesses();
    logic [23:0] first_data, second_data;
    if(!uvm_config_db#(virtual reference_if)::get(null,"*","vif",witness_vif))
      `uvm_fatal("WITNESS_VIF","Missing independent reference interface")
    for(int location=0;location<256;location++) begin
      first_data=24'ha55a0f ^ (location*24'h010101);
      second_data=~first_data;
      pins[0]=0;pins[35]=0;pins[1]=0;pins[36]=0;pins[2]=0;pins[37]=0;
      edge_port(1,location,first_data,1,0,11);
      edge_port(0,location,0,0,0,11);
      edge_port(1,location,second_data,1,0,11);
      edge_port(0,location,0,0,0,11);
      if(witness_vif.predicted_douta!==second_data)
        `uvm_error("READ_CACHE_NONVACUITY","Independent repeated-address read must see other-port update")
      edge_port(0,location,first_data,1,0,12);
      pins[0]=1;send(1024'd1125899906842623,12);
      pins[11 +: 24]=second_data;send(1024'd1125899906842623,12);
      if(witness_vif.predicted_douta!==first_data)
        `uvm_error("WRITE_EDGE_NONVACUITY","Independent output must hold during high-clock data change")
      pins[0]=0;send(1024'd1125899906842623,12);
      pins[2]=0;
      edge_port(1,location,0,0,0,12);
      if(witness_vif.predicted_doutb!==first_data)
        `uvm_error("WRITE_STORAGE_NONVACUITY","No extra edge means no second write")
      edge_port(1,location,first_data,1,0,13);
      edge_port(1,location^1,second_data,1,0,13);
      pins[37]=0;
      edge_port(0,location,0,0,0,13);
      pins[0]=1;send(1024'd1125899906842623,13);
      pins[3 +: 8]=location^1;send(1024'd1125899906842623,13);
      if(witness_vif.predicted_douta!==first_data)
        `uvm_error("READ_EDGE_NONVACUITY","Independent read output must hold during high-clock address change")
      pins[0]=0;send(1024'd1125899906842623,13);
      edge_port(0,location^1,0,0,0,13);
      if(witness_vif.predicted_douta!==second_data)
        `uvm_error("READ_NEXT_EDGE_NONVACUITY","Next true read edge must select the other initialized word")
    end
  endtask
  task body();
    int address, side, random_address;
    logic [23:0] data;
    send(0,0,120);
    for(int startup=0;startup<12;startup++) begin edge_port(0,0,0,0,0,0,0); edge_port(1,1,0,0,0,0,0); end
    for(int owner=0;owner<2;owner++) begin
      for(int position=0;position<4;position++) begin
        case(position)
          0: address=0;
          1: address=127;
          2: address=128;
          3: address=255;
        endcase
        for(int pattern=0;pattern<4;pattern++) begin
          case(pattern)
            0: data=24'h000000;
            1: data=24'hffffff;
            2: data=24'haaaaaa;
            3: data=24'h555555;
          endcase
          edge_port(owner,address,data,1,0,10);
          edge_port(1-owner,address,~data,1,0,10);
          edge_port(owner,address,data,1,0,10);
          edge_port(1-owner,address,0,0,0,10);
        end
        edge_port(owner,address,0,1,0,10);
      end
    end
    for(address=0;address<256;address++) begin edge_port(0,address,0,0,0,1); edge_port(1,address,0,0,0,2); end
    pc3_storage_witnesses();
    for(address=0;address<256;address++) begin
      data=(address%2) ? '1 : '0;
      edge_port(0,address,data,1,0,3); edge_port(0,address,~data,0,0,1); edge_port(1,address,0,0,0,7);
      edge_port(1,address,~data,1,0,4); edge_port(1,address,data,0,0,2); edge_port(0,address,0,0,0,7);
    end
    for(int data_bit=0;data_bit<24;data_bit++) begin
      edge_port(0,255,1<<data_bit,1,0,3); edge_port(1,255,0,0,0,7);
      edge_port(1,0,~(24'd1<<data_bit),1,0,4); edge_port(0,0,0,0,0,7);
    end
    for(side=0;side<2;side++) begin
      edge_port(side,5,'1,1,0,3+side);
      edge_port(side,5,0,0,1,5+side);
      edge_port(1-side,6,'1,1,0,7);
      edge_port(side,5,0,0,0,5+side); edge_port(side,5,0,0,0,5+side); edge_port(side,5,0,0,0,5+side);
      edge_port(side,6,'1,1,1,5+side);
      edge_port(side,6,0,0,0,5+side); edge_port(side,6,'1,1,1,5+side);
      repeat(5) edge_port(side,6,0,0,0,5+side);
      edge_port(1-side,6,0,0,0,7);
      repeat(3) edge_port(side,0,0,0,1,5+side);
      repeat(5) edge_port(side,0,0,0,0,5+side);
    end
    for(int random_event=0;random_event<800;random_event++) begin
      side=$urandom_range(0,1); random_address=$urandom_range(0,255); data=$urandom;
      edge_port(side,random_address,data,$urandom_range(0,1),0,8);
      if(random_event%5==0) edge_port(side,random_address,0,0,0,8);
      if(random_event%7==0) edge_port(1-side,random_address,0,0,0,7);
    end
    pins[2 +: 1]=0; pins[37 +: 1]=0; send(1024'd1125899906842623,9);
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
