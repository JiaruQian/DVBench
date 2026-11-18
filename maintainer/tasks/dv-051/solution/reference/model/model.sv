`timescale 1ns/1ps
module dvbench_model(
input logic clock,
input logic reset,
input logic io_f0_valid,
input logic [39:0] io_f0_pc,
input logic io_resp_in_0_f1_0_taken,
input logic io_resp_in_0_f1_0_is_br,
input logic io_resp_in_0_f1_0_is_jal,
input logic io_resp_in_0_f1_0_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f1_0_predicted_pc_bits,
input logic io_resp_in_0_f1_1_taken,
input logic io_resp_in_0_f1_1_is_br,
input logic io_resp_in_0_f1_1_is_jal,
input logic io_resp_in_0_f1_1_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f1_1_predicted_pc_bits,
input logic io_resp_in_0_f1_2_taken,
input logic io_resp_in_0_f1_2_is_br,
input logic io_resp_in_0_f1_2_is_jal,
input logic io_resp_in_0_f1_2_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f1_2_predicted_pc_bits,
input logic io_resp_in_0_f1_3_taken,
input logic io_resp_in_0_f1_3_is_br,
input logic io_resp_in_0_f1_3_is_jal,
input logic io_resp_in_0_f1_3_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f1_3_predicted_pc_bits,
input logic io_resp_in_0_f2_0_is_br,
input logic io_resp_in_0_f2_0_is_jal,
input logic io_resp_in_0_f2_0_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f2_0_predicted_pc_bits,
input logic io_resp_in_0_f2_1_is_br,
input logic io_resp_in_0_f2_1_is_jal,
input logic io_resp_in_0_f2_1_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f2_1_predicted_pc_bits,
input logic io_resp_in_0_f2_2_is_br,
input logic io_resp_in_0_f2_2_is_jal,
input logic io_resp_in_0_f2_2_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f2_2_predicted_pc_bits,
input logic io_resp_in_0_f2_3_is_br,
input logic io_resp_in_0_f2_3_is_jal,
input logic io_resp_in_0_f2_3_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f2_3_predicted_pc_bits,
input logic io_resp_in_0_f3_0_is_br,
input logic io_resp_in_0_f3_0_is_jal,
input logic io_resp_in_0_f3_0_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f3_0_predicted_pc_bits,
input logic io_resp_in_0_f3_1_is_br,
input logic io_resp_in_0_f3_1_is_jal,
input logic io_resp_in_0_f3_1_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f3_1_predicted_pc_bits,
input logic io_resp_in_0_f3_2_is_br,
input logic io_resp_in_0_f3_2_is_jal,
input logic io_resp_in_0_f3_2_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f3_2_predicted_pc_bits,
input logic io_resp_in_0_f3_3_is_br,
input logic io_resp_in_0_f3_3_is_jal,
input logic io_resp_in_0_f3_3_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f3_3_predicted_pc_bits,
output logic io_resp_f1_0_taken,
output logic io_resp_f1_0_is_br,
output logic io_resp_f1_0_is_jal,
output logic io_resp_f1_0_predicted_pc_valid,
output logic [39:0] io_resp_f1_0_predicted_pc_bits,
output logic io_resp_f1_1_taken,
output logic io_resp_f1_1_is_br,
output logic io_resp_f1_1_is_jal,
output logic io_resp_f1_1_predicted_pc_valid,
output logic [39:0] io_resp_f1_1_predicted_pc_bits,
output logic io_resp_f1_2_taken,
output logic io_resp_f1_2_is_br,
output logic io_resp_f1_2_is_jal,
output logic io_resp_f1_2_predicted_pc_valid,
output logic [39:0] io_resp_f1_2_predicted_pc_bits,
output logic io_resp_f1_3_taken,
output logic io_resp_f1_3_is_br,
output logic io_resp_f1_3_is_jal,
output logic io_resp_f1_3_predicted_pc_valid,
output logic [39:0] io_resp_f1_3_predicted_pc_bits,
output logic io_resp_f2_0_taken,
output logic io_resp_f2_0_is_br,
output logic io_resp_f2_0_is_jal,
output logic io_resp_f2_0_predicted_pc_valid,
output logic [39:0] io_resp_f2_0_predicted_pc_bits,
output logic io_resp_f2_1_taken,
output logic io_resp_f2_1_is_br,
output logic io_resp_f2_1_is_jal,
output logic io_resp_f2_1_predicted_pc_valid,
output logic [39:0] io_resp_f2_1_predicted_pc_bits,
output logic io_resp_f2_2_taken,
output logic io_resp_f2_2_is_br,
output logic io_resp_f2_2_is_jal,
output logic io_resp_f2_2_predicted_pc_valid,
output logic [39:0] io_resp_f2_2_predicted_pc_bits,
output logic io_resp_f2_3_taken,
output logic io_resp_f2_3_is_br,
output logic io_resp_f2_3_is_jal,
output logic io_resp_f2_3_predicted_pc_valid,
output logic [39:0] io_resp_f2_3_predicted_pc_bits,
output logic io_resp_f3_0_taken,
output logic io_resp_f3_0_is_br,
output logic io_resp_f3_0_is_jal,
output logic io_resp_f3_0_predicted_pc_valid,
output logic [39:0] io_resp_f3_0_predicted_pc_bits,
output logic io_resp_f3_1_taken,
output logic io_resp_f3_1_is_br,
output logic io_resp_f3_1_is_jal,
output logic io_resp_f3_1_predicted_pc_valid,
output logic [39:0] io_resp_f3_1_predicted_pc_bits,
output logic io_resp_f3_2_taken,
output logic io_resp_f3_2_is_br,
output logic io_resp_f3_2_is_jal,
output logic io_resp_f3_2_predicted_pc_valid,
output logic [39:0] io_resp_f3_2_predicted_pc_bits,
output logic io_resp_f3_3_taken,
output logic io_resp_f3_3_is_br,
output logic io_resp_f3_3_is_jal,
output logic io_resp_f3_3_predicted_pc_valid,
output logic [39:0] io_resp_f3_3_predicted_pc_bits,
output logic [119:0] io_f3_meta,
input logic io_update_valid,
input logic io_update_bits_is_mispredict_update,
input logic io_update_bits_is_repair_update,
input logic [3:0] io_update_bits_btb_mispredicts,
input logic [39:0] io_update_bits_pc,
input logic [3:0] io_update_bits_br_mask,
input logic io_update_bits_cfi_idx_valid,
input logic [1:0] io_update_bits_cfi_idx_bits,
input logic io_update_bits_cfi_taken,
input logic io_update_bits_cfi_is_br,
input logic io_update_bits_cfi_is_jal,
input logic [119:0] io_update_bits_meta
);
logic [7:0] cells[0:3];
logic memory_read_enable;
logic [1:0] memory_read_slot,memory_write_slot;
logic [1:0] request_valid;
logic sweeping;
logic [10:0] sweep_index;
logic update_valid,update_suppressed;
logic [10:0] update_index;
logic [3:0] branch_slots;
logic selected_valid,selected_taken,selected_branch,selected_jump;
logic [1:0] selected_slot;
logic [7:0] supplied_counters,response_counters,trained_counters;
logic [10:0] recent_index[0:1];
logic [7:0] recent_counters[0:1];
logic next_recent;
logic [1:0] recent_match;
logic [3:0] write_slots;
logic [7:0] training_base;
logic training_enabled;
function automatic logic [1:0] fold_address(input logic [10:0] address);
  fold_address=address[1:0]^address[5:4]^address[9:8];
endfunction
function automatic logic [1:0] adjusted(input logic [1:0] previous,input logic direction);
  if(direction) adjusted=(previous==3)?2'd3:previous+2'd1;
  else adjusted=(previous==0)?2'd0:previous-2'd1;
endfunction
always_comb begin
  recent_match[0]=!sweeping && recent_index[0]==update_index;
  recent_match[1]=!sweeping && recent_index[1]==update_index;
  training_base=(|recent_match)?(recent_match[0]?recent_counters[0]:recent_counters[1]):supplied_counters;
  for(integer slot=0;slot<4;slot=slot+1) begin
    write_slots[slot]=branch_slots[slot] || (selected_valid && selected_slot==slot);
    trained_counters[2*slot+:2]=adjusted(training_base[2*slot+:2],selected_valid && selected_slot==slot && ((selected_branch && branch_slots[slot] && selected_taken)||selected_jump));
  end
  training_enabled=update_valid && !update_suppressed && (|write_slots);
end
always @(posedge clock) begin
  memory_read_enable<=io_f0_valid;
  memory_read_slot<=fold_address(io_f0_pc[14:4]);
  memory_write_slot<=fold_address(sweeping?sweep_index:update_index);
  for(integer slot=0;slot<4;slot=slot+1)
    if(sweeping || (update_valid && !update_suppressed && write_slots[slot]))
      cells[memory_write_slot][2*slot+:2]<=sweeping?2'd2:trained_counters[2*slot+:2];
  response_counters<=memory_read_enable?cells[memory_read_slot]:8'bx;
  request_valid<={request_valid[0],io_f0_valid};
  io_f3_meta<={112'b0,response_counters};
  for(integer slot=0;slot<2;slot=slot+1) begin
    if(!training_enabled || (|recent_match) || next_recent!=slot) begin end
    else recent_index[slot]<=update_index;
  end
  if(training_enabled) begin
    if(|recent_match) begin
      if(recent_match[0])recent_counters[0]<=trained_counters;
      else recent_counters[1]<=trained_counters;
    end
    else recent_counters[next_recent]<=trained_counters;
  end
  if(reset)begin sweeping<=1;sweep_index<=0;next_recent<=0;end
  else begin
    if(sweeping && sweep_index==2047)sweeping<=0;
    sweep_index<=sweep_index+sweeping;
    if(training_enabled && !(|recent_match))next_recent<=!next_recent;
  end
  update_valid<=io_update_valid;
  update_suppressed<=io_update_bits_is_mispredict_update || io_update_bits_is_repair_update || (|io_update_bits_btb_mispredicts);
  update_index<=io_update_bits_pc[14:4];
  branch_slots<=io_update_bits_br_mask;
  selected_valid<=io_update_bits_cfi_idx_valid;
  selected_slot<=io_update_bits_cfi_idx_bits;
  selected_taken<=io_update_bits_cfi_taken;
  selected_branch<=io_update_bits_cfi_is_br;
  selected_jump<=io_update_bits_cfi_is_jal;
  supplied_counters<=io_update_bits_meta[7:0];
  io_resp_f3_0_taken<=request_valid[1] && response_counters[1] && !sweeping;
  io_resp_f3_1_taken<=request_valid[1] && response_counters[3] && !sweeping;
  io_resp_f3_2_taken<=request_valid[1] && response_counters[5] && !sweeping;
  io_resp_f3_3_taken<=request_valid[1] && response_counters[7] && !sweeping;
end
assign io_resp_f1_0_taken=io_resp_in_0_f1_0_taken;
assign io_resp_f1_0_is_br=io_resp_in_0_f1_0_is_br;
assign io_resp_f1_0_is_jal=io_resp_in_0_f1_0_is_jal;
assign io_resp_f1_0_predicted_pc_valid=io_resp_in_0_f1_0_predicted_pc_valid;
assign io_resp_f1_0_predicted_pc_bits=io_resp_in_0_f1_0_predicted_pc_bits;
assign io_resp_f1_1_taken=io_resp_in_0_f1_1_taken;
assign io_resp_f1_1_is_br=io_resp_in_0_f1_1_is_br;
assign io_resp_f1_1_is_jal=io_resp_in_0_f1_1_is_jal;
assign io_resp_f1_1_predicted_pc_valid=io_resp_in_0_f1_1_predicted_pc_valid;
assign io_resp_f1_1_predicted_pc_bits=io_resp_in_0_f1_1_predicted_pc_bits;
assign io_resp_f1_2_taken=io_resp_in_0_f1_2_taken;
assign io_resp_f1_2_is_br=io_resp_in_0_f1_2_is_br;
assign io_resp_f1_2_is_jal=io_resp_in_0_f1_2_is_jal;
assign io_resp_f1_2_predicted_pc_valid=io_resp_in_0_f1_2_predicted_pc_valid;
assign io_resp_f1_2_predicted_pc_bits=io_resp_in_0_f1_2_predicted_pc_bits;
assign io_resp_f1_3_taken=io_resp_in_0_f1_3_taken;
assign io_resp_f1_3_is_br=io_resp_in_0_f1_3_is_br;
assign io_resp_f1_3_is_jal=io_resp_in_0_f1_3_is_jal;
assign io_resp_f1_3_predicted_pc_valid=io_resp_in_0_f1_3_predicted_pc_valid;
assign io_resp_f1_3_predicted_pc_bits=io_resp_in_0_f1_3_predicted_pc_bits;
assign io_resp_f2_0_taken=request_valid[1] && response_counters[1] && !sweeping;
assign io_resp_f2_0_is_br=io_resp_in_0_f2_0_is_br;
assign io_resp_f2_0_is_jal=io_resp_in_0_f2_0_is_jal;
assign io_resp_f2_0_predicted_pc_valid=io_resp_in_0_f2_0_predicted_pc_valid;
assign io_resp_f2_0_predicted_pc_bits=io_resp_in_0_f2_0_predicted_pc_bits;
assign io_resp_f2_1_taken=request_valid[1] && response_counters[3] && !sweeping;
assign io_resp_f2_1_is_br=io_resp_in_0_f2_1_is_br;
assign io_resp_f2_1_is_jal=io_resp_in_0_f2_1_is_jal;
assign io_resp_f2_1_predicted_pc_valid=io_resp_in_0_f2_1_predicted_pc_valid;
assign io_resp_f2_1_predicted_pc_bits=io_resp_in_0_f2_1_predicted_pc_bits;
assign io_resp_f2_2_taken=request_valid[1] && response_counters[5] && !sweeping;
assign io_resp_f2_2_is_br=io_resp_in_0_f2_2_is_br;
assign io_resp_f2_2_is_jal=io_resp_in_0_f2_2_is_jal;
assign io_resp_f2_2_predicted_pc_valid=io_resp_in_0_f2_2_predicted_pc_valid;
assign io_resp_f2_2_predicted_pc_bits=io_resp_in_0_f2_2_predicted_pc_bits;
assign io_resp_f2_3_taken=request_valid[1] && response_counters[7] && !sweeping;
assign io_resp_f2_3_is_br=io_resp_in_0_f2_3_is_br;
assign io_resp_f2_3_is_jal=io_resp_in_0_f2_3_is_jal;
assign io_resp_f2_3_predicted_pc_valid=io_resp_in_0_f2_3_predicted_pc_valid;
assign io_resp_f2_3_predicted_pc_bits=io_resp_in_0_f2_3_predicted_pc_bits;
assign io_resp_f3_0_is_br=io_resp_in_0_f3_0_is_br;
assign io_resp_f3_0_is_jal=io_resp_in_0_f3_0_is_jal;
assign io_resp_f3_0_predicted_pc_valid=io_resp_in_0_f3_0_predicted_pc_valid;
assign io_resp_f3_0_predicted_pc_bits=io_resp_in_0_f3_0_predicted_pc_bits;
assign io_resp_f3_1_is_br=io_resp_in_0_f3_1_is_br;
assign io_resp_f3_1_is_jal=io_resp_in_0_f3_1_is_jal;
assign io_resp_f3_1_predicted_pc_valid=io_resp_in_0_f3_1_predicted_pc_valid;
assign io_resp_f3_1_predicted_pc_bits=io_resp_in_0_f3_1_predicted_pc_bits;
assign io_resp_f3_2_is_br=io_resp_in_0_f3_2_is_br;
assign io_resp_f3_2_is_jal=io_resp_in_0_f3_2_is_jal;
assign io_resp_f3_2_predicted_pc_valid=io_resp_in_0_f3_2_predicted_pc_valid;
assign io_resp_f3_2_predicted_pc_bits=io_resp_in_0_f3_2_predicted_pc_bits;
assign io_resp_f3_3_is_br=io_resp_in_0_f3_3_is_br;
assign io_resp_f3_3_is_jal=io_resp_in_0_f3_3_is_jal;
assign io_resp_f3_3_predicted_pc_valid=io_resp_in_0_f3_3_predicted_pc_valid;
assign io_resp_f3_3_predicted_pc_bits=io_resp_in_0_f3_3_predicted_pc_bits;

endmodule
