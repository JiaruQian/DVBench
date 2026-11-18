`timescale 1ns/1ps
package tlff_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class tlff_item extends uvm_sequence_item;
    `uvm_object_utils(tlff_item)
    rand logic [32:0] auto_in_0_a_bits_address;
    rand logic auto_in_0_a_bits_corrupt;
    rand logic [63:0] auto_in_0_a_bits_data;
    rand logic [7:0] auto_in_0_a_bits_mask;
    rand logic [2:0] auto_in_0_a_bits_opcode;
    rand logic [2:0] auto_in_0_a_bits_param;
    rand logic [3:0] auto_in_0_a_bits_size;
    rand logic [3:0] auto_in_0_a_bits_source;
    rand logic auto_in_0_a_valid;
    rand logic auto_in_0_d_ready;
    rand logic [32:0] auto_in_1_a_bits_address;
    rand logic auto_in_1_a_bits_corrupt;
    rand logic [63:0] auto_in_1_a_bits_data;
    rand logic [7:0] auto_in_1_a_bits_mask;
    rand logic [2:0] auto_in_1_a_bits_opcode;
    rand logic [2:0] auto_in_1_a_bits_param;
    rand logic [3:0] auto_in_1_a_bits_size;
    rand logic [4:0] auto_in_1_a_bits_source;
    rand logic auto_in_1_a_valid;
    rand logic auto_in_1_b_ready;
    rand logic [32:0] auto_in_1_c_bits_address;
    rand logic auto_in_1_c_bits_corrupt;
    rand logic [63:0] auto_in_1_c_bits_data;
    rand logic [2:0] auto_in_1_c_bits_opcode;
    rand logic [2:0] auto_in_1_c_bits_param;
    rand logic [3:0] auto_in_1_c_bits_size;
    rand logic [4:0] auto_in_1_c_bits_source;
    rand logic auto_in_1_c_valid;
    rand logic auto_in_1_d_ready;
    rand logic [1:0] auto_in_1_e_bits_sink;
    rand logic auto_in_1_e_valid;
    rand logic auto_out_0_a_ready;
    rand logic auto_out_0_d_bits_corrupt;
    rand logic [63:0] auto_out_0_d_bits_data;
    rand logic auto_out_0_d_bits_denied;
    rand logic [2:0] auto_out_0_d_bits_opcode;
    rand logic [1:0] auto_out_0_d_bits_param;
    rand logic [1:0] auto_out_0_d_bits_sink;
    rand logic [3:0] auto_out_0_d_bits_size;
    rand logic [3:0] auto_out_0_d_bits_source;
    rand logic auto_out_0_d_valid;
    rand logic auto_out_1_a_ready;
    rand logic [32:0] auto_out_1_b_bits_address;
    rand logic [1:0] auto_out_1_b_bits_param;
    rand logic auto_out_1_b_valid;
    rand logic auto_out_1_c_ready;
    rand logic auto_out_1_d_bits_corrupt;
    rand logic [63:0] auto_out_1_d_bits_data;
    rand logic auto_out_1_d_bits_denied;
    rand logic [2:0] auto_out_1_d_bits_opcode;
    rand logic [1:0] auto_out_1_d_bits_param;
    rand logic [1:0] auto_out_1_d_bits_sink;
    rand logic [3:0] auto_out_1_d_bits_size;
    rand logic [4:0] auto_out_1_d_bits_source;
    rand logic auto_out_1_d_valid;
    rand logic reset;
    function new(string name="tlff_item"); super.new(name); endfunction
  endclass
  class tlff_driver extends uvm_driver #(tlff_item);
    `uvm_component_utils(tlff_driver)
    virtual tlff_if vif;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual tlff_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task run_phase(uvm_phase phase);
      tlff_item item;
      forever begin
        seq_item_port.get_next_item(item); @(negedge vif.clock);
        vif.auto_in_0_a_bits_address=item.auto_in_0_a_bits_address;
        vif.auto_in_0_a_bits_corrupt=item.auto_in_0_a_bits_corrupt;
        vif.auto_in_0_a_bits_data=item.auto_in_0_a_bits_data;
        vif.auto_in_0_a_bits_mask=item.auto_in_0_a_bits_mask;
        vif.auto_in_0_a_bits_opcode=item.auto_in_0_a_bits_opcode;
        vif.auto_in_0_a_bits_param=item.auto_in_0_a_bits_param;
        vif.auto_in_0_a_bits_size=item.auto_in_0_a_bits_size;
        vif.auto_in_0_a_bits_source=item.auto_in_0_a_bits_source;
        vif.auto_in_0_a_valid=item.auto_in_0_a_valid;
        vif.auto_in_0_d_ready=item.auto_in_0_d_ready;
        vif.auto_in_1_a_bits_address=item.auto_in_1_a_bits_address;
        vif.auto_in_1_a_bits_corrupt=item.auto_in_1_a_bits_corrupt;
        vif.auto_in_1_a_bits_data=item.auto_in_1_a_bits_data;
        vif.auto_in_1_a_bits_mask=item.auto_in_1_a_bits_mask;
        vif.auto_in_1_a_bits_opcode=item.auto_in_1_a_bits_opcode;
        vif.auto_in_1_a_bits_param=item.auto_in_1_a_bits_param;
        vif.auto_in_1_a_bits_size=item.auto_in_1_a_bits_size;
        vif.auto_in_1_a_bits_source=item.auto_in_1_a_bits_source;
        vif.auto_in_1_a_valid=item.auto_in_1_a_valid;
        vif.auto_in_1_b_ready=item.auto_in_1_b_ready;
        vif.auto_in_1_c_bits_address=item.auto_in_1_c_bits_address;
        vif.auto_in_1_c_bits_corrupt=item.auto_in_1_c_bits_corrupt;
        vif.auto_in_1_c_bits_data=item.auto_in_1_c_bits_data;
        vif.auto_in_1_c_bits_opcode=item.auto_in_1_c_bits_opcode;
        vif.auto_in_1_c_bits_param=item.auto_in_1_c_bits_param;
        vif.auto_in_1_c_bits_size=item.auto_in_1_c_bits_size;
        vif.auto_in_1_c_bits_source=item.auto_in_1_c_bits_source;
        vif.auto_in_1_c_valid=item.auto_in_1_c_valid;
        vif.auto_in_1_d_ready=item.auto_in_1_d_ready;
        vif.auto_in_1_e_bits_sink=item.auto_in_1_e_bits_sink;
        vif.auto_in_1_e_valid=item.auto_in_1_e_valid;
        vif.auto_out_0_a_ready=item.auto_out_0_a_ready;
        vif.auto_out_0_d_bits_corrupt=item.auto_out_0_d_bits_corrupt;
        vif.auto_out_0_d_bits_data=item.auto_out_0_d_bits_data;
        vif.auto_out_0_d_bits_denied=item.auto_out_0_d_bits_denied;
        vif.auto_out_0_d_bits_opcode=item.auto_out_0_d_bits_opcode;
        vif.auto_out_0_d_bits_param=item.auto_out_0_d_bits_param;
        vif.auto_out_0_d_bits_sink=item.auto_out_0_d_bits_sink;
        vif.auto_out_0_d_bits_size=item.auto_out_0_d_bits_size;
        vif.auto_out_0_d_bits_source=item.auto_out_0_d_bits_source;
        vif.auto_out_0_d_valid=item.auto_out_0_d_valid;
        vif.auto_out_1_a_ready=item.auto_out_1_a_ready;
        vif.auto_out_1_b_bits_address=item.auto_out_1_b_bits_address;
        vif.auto_out_1_b_bits_param=item.auto_out_1_b_bits_param;
        vif.auto_out_1_b_valid=item.auto_out_1_b_valid;
        vif.auto_out_1_c_ready=item.auto_out_1_c_ready;
        vif.auto_out_1_d_bits_corrupt=item.auto_out_1_d_bits_corrupt;
        vif.auto_out_1_d_bits_data=item.auto_out_1_d_bits_data;
        vif.auto_out_1_d_bits_denied=item.auto_out_1_d_bits_denied;
        vif.auto_out_1_d_bits_opcode=item.auto_out_1_d_bits_opcode;
        vif.auto_out_1_d_bits_param=item.auto_out_1_d_bits_param;
        vif.auto_out_1_d_bits_sink=item.auto_out_1_d_bits_sink;
        vif.auto_out_1_d_bits_size=item.auto_out_1_d_bits_size;
        vif.auto_out_1_d_bits_source=item.auto_out_1_d_bits_source;
        vif.auto_out_1_d_valid=item.auto_out_1_d_valid;
        vif.reset=item.reset;
        @(posedge vif.clock); #3; seq_item_port.item_done();
      end
    endtask
  endclass
  class tlff_scoreboard extends uvm_component;
    `uvm_component_utils(tlff_scoreboard)
    virtual tlff_if vif;
    int observations;
    int mismatches;
    covergroup channel_activity with function sample(bit reset,bit a0,bit a1,bit b1,bit c1,bit d0,bit d1,bit e1);
      reset_cp: coverpoint reset;
      a0_cp: coverpoint a0;
      a1_cp: coverpoint a1;
      b1_cp: coverpoint b1;
      c1_cp: coverpoint c1;
      d0_cp: coverpoint d0;
      d1_cp: coverpoint d1;
      e1_cp: coverpoint e1;
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent); channel_activity=new(); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual tlff_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task compare();
      observations++;
      channel_activity.sample(vif.reset,vif.auto_in_0_a_valid,vif.auto_in_1_a_valid,vif.auto_out_1_b_valid,vif.auto_in_1_c_valid,vif.auto_out_0_d_valid,vif.auto_out_1_d_valid,vif.auto_in_1_e_valid);
      if(vif.auto_in_0_a_ready !== vif.expected_auto_in_0_a_ready) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_a_ready differs from independent native predictor")
      end
      if(vif.auto_in_0_d_bits_corrupt !== vif.expected_auto_in_0_d_bits_corrupt) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_d_bits_corrupt differs from independent native predictor")
      end
      if(vif.auto_in_0_d_bits_data !== vif.expected_auto_in_0_d_bits_data) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_d_bits_data differs from independent native predictor")
      end
      if(vif.auto_in_0_d_bits_denied !== vif.expected_auto_in_0_d_bits_denied) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_d_bits_denied differs from independent native predictor")
      end
      if(vif.auto_in_0_d_bits_opcode !== vif.expected_auto_in_0_d_bits_opcode) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_d_bits_opcode differs from independent native predictor")
      end
      if(vif.auto_in_0_d_bits_param !== vif.expected_auto_in_0_d_bits_param) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_d_bits_param differs from independent native predictor")
      end
      if(vif.auto_in_0_d_bits_sink !== vif.expected_auto_in_0_d_bits_sink) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_d_bits_sink differs from independent native predictor")
      end
      if(vif.auto_in_0_d_bits_size !== vif.expected_auto_in_0_d_bits_size) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_d_bits_size differs from independent native predictor")
      end
      if(vif.auto_in_0_d_bits_source !== vif.expected_auto_in_0_d_bits_source) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_d_bits_source differs from independent native predictor")
      end
      if(vif.auto_in_0_d_valid !== vif.expected_auto_in_0_d_valid) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_0_d_valid differs from independent native predictor")
      end
      if(vif.auto_in_1_a_ready !== vif.expected_auto_in_1_a_ready) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_a_ready differs from independent native predictor")
      end
      if(vif.auto_in_1_b_bits_address !== vif.expected_auto_in_1_b_bits_address) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_b_bits_address differs from independent native predictor")
      end
      if(vif.auto_in_1_b_bits_param !== vif.expected_auto_in_1_b_bits_param) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_b_bits_param differs from independent native predictor")
      end
      if(vif.auto_in_1_b_valid !== vif.expected_auto_in_1_b_valid) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_b_valid differs from independent native predictor")
      end
      if(vif.auto_in_1_c_ready !== vif.expected_auto_in_1_c_ready) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_c_ready differs from independent native predictor")
      end
      if(vif.auto_in_1_d_bits_corrupt !== vif.expected_auto_in_1_d_bits_corrupt) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_d_bits_corrupt differs from independent native predictor")
      end
      if(vif.auto_in_1_d_bits_data !== vif.expected_auto_in_1_d_bits_data) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_d_bits_data differs from independent native predictor")
      end
      if(vif.auto_in_1_d_bits_denied !== vif.expected_auto_in_1_d_bits_denied) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_d_bits_denied differs from independent native predictor")
      end
      if(vif.auto_in_1_d_bits_opcode !== vif.expected_auto_in_1_d_bits_opcode) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_d_bits_opcode differs from independent native predictor")
      end
      if(vif.auto_in_1_d_bits_param !== vif.expected_auto_in_1_d_bits_param) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_d_bits_param differs from independent native predictor")
      end
      if(vif.auto_in_1_d_bits_sink !== vif.expected_auto_in_1_d_bits_sink) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_d_bits_sink differs from independent native predictor")
      end
      if(vif.auto_in_1_d_bits_size !== vif.expected_auto_in_1_d_bits_size) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_d_bits_size differs from independent native predictor")
      end
      if(vif.auto_in_1_d_bits_source !== vif.expected_auto_in_1_d_bits_source) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_d_bits_source differs from independent native predictor")
      end
      if(vif.auto_in_1_d_valid !== vif.expected_auto_in_1_d_valid) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_in_1_d_valid differs from independent native predictor")
      end
      if(vif.auto_out_0_a_bits_address !== vif.expected_auto_out_0_a_bits_address) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_a_bits_address differs from independent native predictor")
      end
      if(vif.auto_out_0_a_bits_corrupt !== vif.expected_auto_out_0_a_bits_corrupt) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_a_bits_corrupt differs from independent native predictor")
      end
      if(vif.auto_out_0_a_bits_data !== vif.expected_auto_out_0_a_bits_data) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_a_bits_data differs from independent native predictor")
      end
      if(vif.auto_out_0_a_bits_mask !== vif.expected_auto_out_0_a_bits_mask) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_a_bits_mask differs from independent native predictor")
      end
      if(vif.auto_out_0_a_bits_opcode !== vif.expected_auto_out_0_a_bits_opcode) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_a_bits_opcode differs from independent native predictor")
      end
      if(vif.auto_out_0_a_bits_param !== vif.expected_auto_out_0_a_bits_param) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_a_bits_param differs from independent native predictor")
      end
      if(vif.auto_out_0_a_bits_size !== vif.expected_auto_out_0_a_bits_size) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_a_bits_size differs from independent native predictor")
      end
      if(vif.auto_out_0_a_bits_source !== vif.expected_auto_out_0_a_bits_source) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_a_bits_source differs from independent native predictor")
      end
      if(vif.auto_out_0_a_valid !== vif.expected_auto_out_0_a_valid) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_a_valid differs from independent native predictor")
      end
      if(vif.auto_out_0_d_ready !== vif.expected_auto_out_0_d_ready) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_0_d_ready differs from independent native predictor")
      end
      if(vif.auto_out_1_a_bits_address !== vif.expected_auto_out_1_a_bits_address) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_a_bits_address differs from independent native predictor")
      end
      if(vif.auto_out_1_a_bits_corrupt !== vif.expected_auto_out_1_a_bits_corrupt) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_a_bits_corrupt differs from independent native predictor")
      end
      if(vif.auto_out_1_a_bits_data !== vif.expected_auto_out_1_a_bits_data) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_a_bits_data differs from independent native predictor")
      end
      if(vif.auto_out_1_a_bits_mask !== vif.expected_auto_out_1_a_bits_mask) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_a_bits_mask differs from independent native predictor")
      end
      if(vif.auto_out_1_a_bits_opcode !== vif.expected_auto_out_1_a_bits_opcode) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_a_bits_opcode differs from independent native predictor")
      end
      if(vif.auto_out_1_a_bits_param !== vif.expected_auto_out_1_a_bits_param) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_a_bits_param differs from independent native predictor")
      end
      if(vif.auto_out_1_a_bits_size !== vif.expected_auto_out_1_a_bits_size) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_a_bits_size differs from independent native predictor")
      end
      if(vif.auto_out_1_a_bits_source !== vif.expected_auto_out_1_a_bits_source) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_a_bits_source differs from independent native predictor")
      end
      if(vif.auto_out_1_a_valid !== vif.expected_auto_out_1_a_valid) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_a_valid differs from independent native predictor")
      end
      if(vif.auto_out_1_b_ready !== vif.expected_auto_out_1_b_ready) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_b_ready differs from independent native predictor")
      end
      if(vif.auto_out_1_c_bits_address !== vif.expected_auto_out_1_c_bits_address) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_c_bits_address differs from independent native predictor")
      end
      if(vif.auto_out_1_c_bits_corrupt !== vif.expected_auto_out_1_c_bits_corrupt) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_c_bits_corrupt differs from independent native predictor")
      end
      if(vif.auto_out_1_c_bits_data !== vif.expected_auto_out_1_c_bits_data) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_c_bits_data differs from independent native predictor")
      end
      if(vif.auto_out_1_c_bits_opcode !== vif.expected_auto_out_1_c_bits_opcode) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_c_bits_opcode differs from independent native predictor")
      end
      if(vif.auto_out_1_c_bits_param !== vif.expected_auto_out_1_c_bits_param) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_c_bits_param differs from independent native predictor")
      end
      if(vif.auto_out_1_c_bits_size !== vif.expected_auto_out_1_c_bits_size) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_c_bits_size differs from independent native predictor")
      end
      if(vif.auto_out_1_c_bits_source !== vif.expected_auto_out_1_c_bits_source) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_c_bits_source differs from independent native predictor")
      end
      if(vif.auto_out_1_c_valid !== vif.expected_auto_out_1_c_valid) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_c_valid differs from independent native predictor")
      end
      if(vif.auto_out_1_d_ready !== vif.expected_auto_out_1_d_ready) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_d_ready differs from independent native predictor")
      end
      if(vif.auto_out_1_e_bits_sink !== vif.expected_auto_out_1_e_bits_sink) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_e_bits_sink differs from independent native predictor")
      end
      if(vif.auto_out_1_e_valid !== vif.expected_auto_out_1_e_valid) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","auto_out_1_e_valid differs from independent native predictor")
      end
    endtask
    task run_phase(uvm_phase phase); forever begin @(negedge vif.clock); #2; compare(); @(posedge vif.clock); #2; compare(); end endtask
    function void check_phase(uvm_phase phase); if(observations<100) `uvm_error("VACUITY","too few observations") if(mismatches>0) `uvm_error("TOTAL",$sformatf("%0d mismatches",mismatches)) endfunction
  endclass
  class tlff_sequence extends uvm_sequence #(tlff_item);
    `uvm_object_utils(tlff_sequence)
    int reset_beats;
    function new(string name="tlff_sequence"); super.new(name); endfunction
    task beat(int mode,int lane=0,int opcode=4,int size=3,int source_id=0,int param=0,int sink=0,bit stalled=0);
      tlff_item item=tlff_item::type_id::create("drive");
      start_item(item); if(!item.randomize()) `uvm_fatal("RANDOM","randomization failed")
      item.reset=(mode==0);
      item.auto_in_0_a_valid=0;
      item.auto_in_1_a_valid=0;
      item.auto_in_1_c_valid=0;
      item.auto_in_1_e_valid=0;
      item.auto_out_0_d_valid=0;
      item.auto_out_1_b_valid=0;
      item.auto_out_1_d_valid=0;
      item.auto_in_0_d_ready=1;
      item.auto_in_1_b_ready=1;
      item.auto_in_1_d_ready=1;
      item.auto_out_0_a_ready=1;
      item.auto_out_1_a_ready=1;
      item.auto_out_1_c_ready=1;
      if(mode==0) begin
        if(reset_beats%3==0) item.auto_in_0_a_bits_address='0; else if(reset_beats%3==1) item.auto_in_0_a_bits_address='1;
        if(reset_beats%3==0) item.auto_in_0_a_bits_corrupt='0; else if(reset_beats%3==1) item.auto_in_0_a_bits_corrupt='1;
        if(reset_beats%3==0) item.auto_in_0_a_bits_data='0; else if(reset_beats%3==1) item.auto_in_0_a_bits_data='1;
        if(reset_beats%3==0) item.auto_in_0_a_bits_mask='0; else if(reset_beats%3==1) item.auto_in_0_a_bits_mask='1;
        if(reset_beats%3==0) item.auto_in_0_a_bits_opcode='0; else if(reset_beats%3==1) item.auto_in_0_a_bits_opcode='1;
        if(reset_beats%3==0) item.auto_in_0_a_bits_param='0; else if(reset_beats%3==1) item.auto_in_0_a_bits_param='1;
        if(reset_beats%3==0) item.auto_in_0_a_bits_size='0; else if(reset_beats%3==1) item.auto_in_0_a_bits_size='1;
        if(reset_beats%3==0) item.auto_in_0_a_bits_source='0; else if(reset_beats%3==1) item.auto_in_0_a_bits_source='1;
        if(reset_beats%3==0) item.auto_in_1_a_bits_address='0; else if(reset_beats%3==1) item.auto_in_1_a_bits_address='1;
        if(reset_beats%3==0) item.auto_in_1_a_bits_corrupt='0; else if(reset_beats%3==1) item.auto_in_1_a_bits_corrupt='1;
        if(reset_beats%3==0) item.auto_in_1_a_bits_data='0; else if(reset_beats%3==1) item.auto_in_1_a_bits_data='1;
        if(reset_beats%3==0) item.auto_in_1_a_bits_mask='0; else if(reset_beats%3==1) item.auto_in_1_a_bits_mask='1;
        if(reset_beats%3==0) item.auto_in_1_a_bits_opcode='0; else if(reset_beats%3==1) item.auto_in_1_a_bits_opcode='1;
        if(reset_beats%3==0) item.auto_in_1_a_bits_param='0; else if(reset_beats%3==1) item.auto_in_1_a_bits_param='1;
        if(reset_beats%3==0) item.auto_in_1_a_bits_size='0; else if(reset_beats%3==1) item.auto_in_1_a_bits_size='1;
        if(reset_beats%3==0) item.auto_in_1_a_bits_source='0; else if(reset_beats%3==1) item.auto_in_1_a_bits_source='1;
        if(reset_beats%3==0) item.auto_in_1_c_bits_address='0; else if(reset_beats%3==1) item.auto_in_1_c_bits_address='1;
        if(reset_beats%3==0) item.auto_in_1_c_bits_corrupt='0; else if(reset_beats%3==1) item.auto_in_1_c_bits_corrupt='1;
        if(reset_beats%3==0) item.auto_in_1_c_bits_data='0; else if(reset_beats%3==1) item.auto_in_1_c_bits_data='1;
        if(reset_beats%3==0) item.auto_in_1_c_bits_opcode='0; else if(reset_beats%3==1) item.auto_in_1_c_bits_opcode='1;
        if(reset_beats%3==0) item.auto_in_1_c_bits_param='0; else if(reset_beats%3==1) item.auto_in_1_c_bits_param='1;
        if(reset_beats%3==0) item.auto_in_1_c_bits_size='0; else if(reset_beats%3==1) item.auto_in_1_c_bits_size='1;
        if(reset_beats%3==0) item.auto_in_1_c_bits_source='0; else if(reset_beats%3==1) item.auto_in_1_c_bits_source='1;
        if(reset_beats%3==0) item.auto_in_1_e_bits_sink='0; else if(reset_beats%3==1) item.auto_in_1_e_bits_sink='1;
        if(reset_beats%3==0) item.auto_out_0_d_bits_corrupt='0; else if(reset_beats%3==1) item.auto_out_0_d_bits_corrupt='1;
        if(reset_beats%3==0) item.auto_out_0_d_bits_data='0; else if(reset_beats%3==1) item.auto_out_0_d_bits_data='1;
        if(reset_beats%3==0) item.auto_out_0_d_bits_denied='0; else if(reset_beats%3==1) item.auto_out_0_d_bits_denied='1;
        if(reset_beats%3==0) item.auto_out_0_d_bits_opcode='0; else if(reset_beats%3==1) item.auto_out_0_d_bits_opcode='1;
        if(reset_beats%3==0) item.auto_out_0_d_bits_param='0; else if(reset_beats%3==1) item.auto_out_0_d_bits_param='1;
        if(reset_beats%3==0) item.auto_out_0_d_bits_sink='0; else if(reset_beats%3==1) item.auto_out_0_d_bits_sink='1;
        if(reset_beats%3==0) item.auto_out_0_d_bits_size='0; else if(reset_beats%3==1) item.auto_out_0_d_bits_size='1;
        if(reset_beats%3==0) item.auto_out_0_d_bits_source='0; else if(reset_beats%3==1) item.auto_out_0_d_bits_source='1;
        if(reset_beats%3==0) item.auto_out_1_b_bits_address='0; else if(reset_beats%3==1) item.auto_out_1_b_bits_address='1;
        if(reset_beats%3==0) item.auto_out_1_b_bits_param='0; else if(reset_beats%3==1) item.auto_out_1_b_bits_param='1;
        if(reset_beats%3==0) item.auto_out_1_d_bits_corrupt='0; else if(reset_beats%3==1) item.auto_out_1_d_bits_corrupt='1;
        if(reset_beats%3==0) item.auto_out_1_d_bits_data='0; else if(reset_beats%3==1) item.auto_out_1_d_bits_data='1;
        if(reset_beats%3==0) item.auto_out_1_d_bits_denied='0; else if(reset_beats%3==1) item.auto_out_1_d_bits_denied='1;
        if(reset_beats%3==0) item.auto_out_1_d_bits_opcode='0; else if(reset_beats%3==1) item.auto_out_1_d_bits_opcode='1;
        if(reset_beats%3==0) item.auto_out_1_d_bits_param='0; else if(reset_beats%3==1) item.auto_out_1_d_bits_param='1;
        if(reset_beats%3==0) item.auto_out_1_d_bits_sink='0; else if(reset_beats%3==1) item.auto_out_1_d_bits_sink='1;
        if(reset_beats%3==0) item.auto_out_1_d_bits_size='0; else if(reset_beats%3==1) item.auto_out_1_d_bits_size='1;
        if(reset_beats%3==0) item.auto_out_1_d_bits_source='0; else if(reset_beats%3==1) item.auto_out_1_d_bits_source='1;
        reset_beats++;
        item.auto_in_0_a_valid=$urandom_range(1,0);
        item.auto_in_0_d_ready=$urandom_range(1,0);
        item.auto_in_1_a_valid=$urandom_range(1,0);
        item.auto_in_1_b_ready=$urandom_range(1,0);
        item.auto_in_1_c_valid=$urandom_range(1,0);
        item.auto_in_1_d_ready=$urandom_range(1,0);
        item.auto_in_1_e_valid=$urandom_range(1,0);
        item.auto_out_0_a_ready=$urandom_range(1,0);
        item.auto_out_0_d_valid=$urandom_range(1,0);
        item.auto_out_1_a_ready=$urandom_range(1,0);
        item.auto_out_1_b_valid=$urandom_range(1,0);
        item.auto_out_1_c_ready=$urandom_range(1,0);
        item.auto_out_1_d_valid=$urandom_range(1,0);
      end
      if(mode==1) begin
        if(lane==0) begin
          item.auto_in_0_a_valid=1;
          item.auto_in_0_a_bits_opcode=opcode;
          item.auto_in_0_a_bits_size=size;
          item.auto_in_0_a_bits_source=source_id;
          item.auto_in_0_a_bits_param=param;
          item.auto_in_0_a_bits_address=(opcode>=6 ? 33'h80000000 : 33'h3000);
          item.auto_in_0_a_bits_mask=(size>=3 ? 8'hff : ((1<<(1<<size))-1));
          item.auto_in_0_a_bits_corrupt=0;
        end
        if(lane==1) begin
          item.auto_in_1_a_valid=1;
          item.auto_in_1_a_bits_opcode=opcode;
          item.auto_in_1_a_bits_size=size;
          item.auto_in_1_a_bits_source=source_id;
          item.auto_in_1_a_bits_param=param;
          item.auto_in_1_a_bits_address=(opcode>=6 ? 33'h80000000 : 33'h3000);
          item.auto_in_1_a_bits_mask=(size>=3 ? 8'hff : ((1<<(1<<size))-1));
          item.auto_in_1_a_bits_corrupt=0;
        end
      end
      if(mode==2) begin
        if(lane==0) begin
          item.auto_out_0_d_valid=1;
          item.auto_out_0_d_bits_opcode=opcode;
          item.auto_out_0_d_bits_size=size;
          item.auto_out_0_d_bits_source=source_id;
          item.auto_out_0_d_bits_param=param;
          item.auto_out_0_d_bits_sink=sink;
          item.auto_out_0_d_bits_denied=0;
          item.auto_out_0_d_bits_corrupt=0;
        end
        if(lane==1) begin
          item.auto_out_1_d_valid=1;
          item.auto_out_1_d_bits_opcode=opcode;
          item.auto_out_1_d_bits_size=size;
          item.auto_out_1_d_bits_source=source_id;
          item.auto_out_1_d_bits_param=param;
          item.auto_out_1_d_bits_sink=sink;
          item.auto_out_1_d_bits_denied=0;
          item.auto_out_1_d_bits_corrupt=0;
        end
      end
      if(mode==3) begin
        item.auto_out_1_b_valid=1; item.auto_out_1_b_bits_param=param; item.auto_out_1_b_bits_address=0;
      end
      if(mode==4) begin
        item.auto_in_1_c_valid=1; item.auto_in_1_c_bits_opcode=opcode; item.auto_in_1_c_bits_size=size;
        item.auto_in_1_c_bits_source=source_id; item.auto_in_1_c_bits_param=param;
        item.auto_in_1_c_bits_address=(opcode>=6 ? 33'h80000000 : 0); item.auto_in_1_c_bits_corrupt=0;
      end
      if(mode==5) begin item.auto_in_1_e_valid=1; item.auto_in_1_e_bits_sink=sink; end
      if(stalled) begin
        item.auto_out_0_a_ready=0;
        item.auto_out_1_a_ready=0;
        item.auto_in_0_d_ready=0;
        item.auto_in_1_d_ready=0;
        item.auto_out_1_c_ready=0;
        item.auto_in_1_b_ready=0;
      end
      finish_item(item);
    endtask
    task body();
      for(int index=0;index<300;index++) beat(0);
      for(int lane=0;lane<2;lane++) begin
        for(int opcode=0;opcode<6;opcode++) begin
          for(int size=0;size<6;size++) begin
            if((opcode==2 || opcode==3) && size>3) continue;
            beat(0);
            repeat(opcode<4 && size>3 ? (1<<(size-3)) : 1) beat(1,lane,opcode,size,0,0);
            beat(6);
            repeat((opcode>=2 && opcode<=4) && size>3 ? (1<<(size-3)) : 1) beat(2,lane,opcode<2 ? 0 : opcode==5 ? 2 : 1,size,0,0);
            beat(6);
          end
        end
      end
      for(int source_id=0;source_id<16;source_id++) begin beat(0); beat(1,0,4,3,source_id); beat(6); beat(2,0,1,3,source_id); end
      for(int source_id=0;source_id<17;source_id++) begin if(source_id>9 && source_id!=16) continue; beat(0); beat(1,1,4,3,source_id); beat(6); beat(2,1,1,3,source_id); end
      for(int param=0;param<3;param++) begin beat(0); beat(3,1,0,3,0,param); end
      for(int opcode=4;opcode<8;opcode++) begin
        beat(0); repeat((opcode[0] && opcode>=6) ? 8 : 1) beat(4,1,opcode,opcode>=6 ? 6 : 3,0,0);
        if(opcode>=6) begin beat(6); beat(2,1,6,6,0,0); end
      end
      for(int sink=0;sink<4;sink++) begin
        beat(0); beat(1,1,6,6,0,0); beat(6); beat(2,1,4,6,0,0,sink); beat(5,1,0,0,0,0,sink);
      end
      for(int lane=0;lane<2;lane++) begin
        for(int source_id=0;source_id<(lane==0 ? 16 : 17);source_id++) begin
          if(lane==1 && source_id>9 && source_id!=16) continue;
          for(int opcode=0;opcode<6;opcode++) begin
            for(int size=0;size<=12;size++) begin
              if((opcode==2 || opcode==3) && size>3) continue;
              beat(0);
              beat(1,lane,opcode,size,source_id,0,0,1);
              repeat(opcode<4 && size>3 ? (1<<(size-3)) : 1) beat(1,lane,opcode,size,source_id);
              beat(6);
              beat(2,lane,opcode<2 ? 0 : opcode==5 ? 2 : 1,size,source_id,0,0,1);
              repeat((opcode>=2 && opcode<=4) && size>3 ? (1<<(size-3)) : 1) beat(2,lane,opcode<2 ? 0 : opcode==5 ? 2 : 1,size,source_id);
              beat(6);
            end
          end
        end
      end
      for(int source_id=0;source_id<=8;source_id++) begin
        for(int opcode=6;opcode<=7;opcode++) begin
          for(int param=1;param<=2;param++) begin
            for(int sink=0;sink<4;sink++) begin
              beat(0); beat(1,1,opcode,6,source_id,param); beat(6);
              repeat(opcode==6 ? 8 : 1) beat(2,1,opcode==6 ? 5 : 4,6,source_id,1,sink);
              beat(5,1,0,0,0,0,sink);
            end
          end
        end
        for(int opcode=6;opcode<=7;opcode++) begin
          for(int param=0;param<=5;param++) begin
            beat(0);
            repeat(opcode==7 ? 8 : 1) beat(4,1,opcode,6,source_id,param);
            beat(6); beat(2,1,6,6,source_id); beat(6);
          end
        end
      end
      for(int size=3;size<=15;size++) begin
        beat(0);
        repeat(size>=12 ? 512 : (1<<(size-3))) beat(4,1,3,size,31,7);
        beat(6);
      end
      beat(0); beat(6);
    endtask
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    uvm_sequencer #(tlff_item) sequencer;
    tlff_driver driver;
    tlff_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); sequencer=new("sequencer",this); driver=tlff_driver::type_id::create("driver",this); scoreboard=tlff_scoreboard::type_id::create("scoreboard",this); endfunction
    function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
    task run_phase(uvm_phase phase); tlff_sequence sequence_handle=tlff_sequence::type_id::create("sequence_handle"); phase.raise_objection(this); sequence_handle.start(sequencer); repeat(3) @(posedge driver.vif.clock); phase.drop_objection(this); endtask
    function void report_phase(uvm_phase phase); uvm_report_server reports=uvm_report_server::get_server(); if(reports.get_severity_count(UVM_ERROR)==0 && reports.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED"); endfunction
  endclass
endpackage
