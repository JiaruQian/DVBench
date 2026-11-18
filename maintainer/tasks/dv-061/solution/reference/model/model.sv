`timescale 1ns/1ps
module dvbench_model(
input logic clock,
input logic reset,
output logic io_enq_ready,
input logic io_enq_valid,
input logic [39:0] io_enq_bits_pc,
input logic io_enq_bits_cfi_idx_valid,
input logic [2:0] io_enq_bits_cfi_idx_bits,
input logic [2:0] io_enq_bits_cfi_type,
input logic io_enq_bits_cfi_is_call,
input logic io_enq_bits_cfi_is_ret,
input logic [39:0] io_enq_bits_ras_top,
input logic [7:0] io_enq_bits_mask,
input logic [7:0] io_enq_bits_br_mask,
input logic [63:0] io_enq_bits_ghist_old_history,
input logic io_enq_bits_ghist_current_saw_branch_not_taken,
input logic io_enq_bits_ghist_new_saw_branch_not_taken,
input logic io_enq_bits_ghist_new_saw_branch_taken,
input logic [4:0] io_enq_bits_ghist_ras_idx,
input logic [119:0] io_enq_bits_bpd_meta_0,
input logic [119:0] io_enq_bits_bpd_meta_1,
output logic [5:0] io_enq_idx,
input logic io_deq_valid,
input logic [5:0] io_deq_bits,
input logic [5:0] io_get_ftq_pc_0_ftq_idx,
output logic io_get_ftq_pc_0_entry_cfi_idx_valid,
output logic [2:0] io_get_ftq_pc_0_entry_cfi_idx_bits,
output logic [4:0] io_get_ftq_pc_0_entry_ras_idx,
output logic io_get_ftq_pc_0_entry_start_bank,
output logic [39:0] io_get_ftq_pc_0_pc,
output logic [39:0] io_get_ftq_pc_0_com_pc,
output logic io_get_ftq_pc_0_next_val,
output logic [39:0] io_get_ftq_pc_0_next_pc,
input logic [5:0] io_get_ftq_pc_1_ftq_idx,
output logic [2:0] io_get_ftq_pc_1_entry_cfi_idx_bits,
output logic [7:0] io_get_ftq_pc_1_entry_br_mask,
output logic io_get_ftq_pc_1_entry_cfi_is_call,
output logic io_get_ftq_pc_1_entry_cfi_is_ret,
output logic io_get_ftq_pc_1_entry_start_bank,
output logic [63:0] io_get_ftq_pc_1_ghist_old_history,
output logic io_get_ftq_pc_1_ghist_current_saw_branch_not_taken,
output logic io_get_ftq_pc_1_ghist_new_saw_branch_not_taken,
output logic io_get_ftq_pc_1_ghist_new_saw_branch_taken,
output logic [4:0] io_get_ftq_pc_1_ghist_ras_idx,
output logic [39:0] io_get_ftq_pc_1_pc,
input logic io_redirect_valid,
input logic [5:0] io_redirect_bits,
input logic [5:0] io_brupdate_b2_uop_ftq_idx,
input logic [5:0] io_brupdate_b2_uop_pc_lob,
input logic io_brupdate_b2_mispredict,
input logic io_brupdate_b2_taken,
output logic io_bpdupdate_valid,
output logic io_bpdupdate_bits_is_mispredict_update,
output logic io_bpdupdate_bits_is_repair_update,
output logic [39:0] io_bpdupdate_bits_pc,
output logic [7:0] io_bpdupdate_bits_br_mask,
output logic io_bpdupdate_bits_cfi_idx_valid,
output logic [2:0] io_bpdupdate_bits_cfi_idx_bits,
output logic io_bpdupdate_bits_cfi_taken,
output logic io_bpdupdate_bits_cfi_mispredicted,
output logic io_bpdupdate_bits_cfi_is_br,
output logic io_bpdupdate_bits_cfi_is_jal,
output logic [63:0] io_bpdupdate_bits_ghist_old_history,
output logic io_bpdupdate_bits_ghist_new_saw_branch_not_taken,
output logic io_bpdupdate_bits_ghist_new_saw_branch_taken,
output logic [39:0] io_bpdupdate_bits_target,
output logic [119:0] io_bpdupdate_bits_meta_0,
output logic [119:0] io_bpdupdate_bits_meta_1,
output logic io_ras_update,
output logic [4:0] io_ras_update_idx,
output logic [39:0] io_ras_update_pc
);
typedef struct packed {
  logic cfi_valid;
  logic [2:0] cfi_index;
  logic taken,mispredicted;
  logic [2:0] cfi_type;
  logic [7:0] branches;
  logic call_value,return_value;
  logic [39:0] ras_top;
  logic [4:0] ras_index;
  logic start_bank;
} entry_t;
typedef struct packed {
  logic [4:0] ras_index;
  logic new_taken,new_not_taken,current_not_taken;
  logic [63:0] old_history;
} history_t;
logic [64:0] entries[0:39];
logic [39:0] pcs[0:39];
logic [71:0] histories[0:39];
logic [239:0] metadata[0:39];
logic [5:0] enqueue_position,dequeue_position,training_position;
logic [5:0] repair_position,repair_end,selected_position,next_query_position;
logic [5:0] history_read_position,query_history_position;
logic [39:0] repair_stop_pc,training_pc,training_target,previous_pc;
entry_t previous_entry,captured_redirect,new_redirect,new_enqueue;
entry_t training_entry,selected_entry,redirect_entry,query0_entry,query1_entry;
history_t previous_history,new_history,training_history,query_history;
logic previous_redirect,previous_branch_mispredict,previous_mispredict_mode;
logic [5:0] captured_mispredict_position,captured_end,captured_redirect_position;
logic mispredict_mode,repair_mode,first_empty,issued_update,previous_repair;
logic [63:0] history_base;
logic [7:0] preceding_branches;
logic first_not_taken,first_taken,ignore_second_bank;
logic commit_update,enqueue_fire;
logic [2:0] corrected_index;
function automatic logic [5:0] advance(input logic [5:0] position);
  advance=position==39?6'd0:position+6'd1;
endfunction
function automatic integer storage_index(input logic [5:0] position);
  if(position<40)storage_index=position;else storage_index=0;
endfunction
function automatic logic [7:0] prefix(input logic [2:0] slot);
  prefix=8'hff>>(7-slot);
endfunction
function automatic logic selected_branch(input logic [7:0] branches,input logic [2:0] slot);
  selected_branch=branches[slot];
endfunction
always_comb begin
  enqueue_fire=io_enq_ready && io_enq_valid;
  commit_update=!mispredict_mode && !repair_mode && training_position!=dequeue_position && enqueue_position!=advance(training_position) && !io_brupdate_b2_mispredict && !io_redirect_valid && !previous_redirect;
  selected_position=io_redirect_valid?io_redirect_bits:(mispredict_mode||repair_mode)?repair_position:training_position;
  selected_entry=entries[storage_index(selected_position)];
  redirect_entry=entries[storage_index(io_redirect_bits)];
  query0_entry=entries[storage_index(io_get_ftq_pc_0_ftq_idx)];
  query1_entry=entries[storage_index(io_get_ftq_pc_1_ftq_idx)];
  training_history=histories[history_read_position];
  query_history=histories[query_history_position];
  next_query_position=advance(io_get_ftq_pc_0_ftq_idx);
  new_enqueue.cfi_valid=io_enq_bits_cfi_idx_valid;
  new_enqueue.cfi_index=io_enq_bits_cfi_idx_bits;
  new_enqueue.taken=io_enq_bits_cfi_idx_valid;
  new_enqueue.mispredicted=0;
  new_enqueue.cfi_type=io_enq_bits_cfi_type;
  new_enqueue.branches=io_enq_bits_br_mask & io_enq_bits_mask;
  new_enqueue.call_value=io_enq_bits_cfi_is_call;
  new_enqueue.return_value=io_enq_bits_cfi_is_ret;
  new_enqueue.ras_top=io_enq_bits_ras_top;
  new_enqueue.ras_index=io_enq_bits_ghist_ras_idx;
  new_enqueue.start_bank=io_enq_bits_pc[3];
  corrected_index=io_brupdate_b2_uop_pc_lob[3:1]^{redirect_entry.start_bank,2'b0};
  new_redirect=redirect_entry;
  if(io_redirect_valid && io_brupdate_b2_mispredict)begin
    new_redirect.cfi_valid=1;
    new_redirect.cfi_index=corrected_index;
    new_redirect.taken=io_brupdate_b2_taken;
    new_redirect.mispredicted=1;
    new_redirect.call_value=(redirect_entry.cfi_index==corrected_index) && redirect_entry.call_value;
    new_redirect.return_value=(redirect_entry.cfi_index==corrected_index) && redirect_entry.return_value;
  end
  history_base=previous_history.new_taken?{previous_history.old_history[62:0],1'b1}:previous_history.new_not_taken?{previous_history.old_history[62:0],1'b0}:previous_history.old_history;
  preceding_branches=previous_entry.cfi_valid?prefix(previous_entry.cfi_index):8'hff;
  if(previous_entry.cfi_valid && selected_branch(previous_entry.branches,previous_entry.cfi_index) && previous_entry.taken)preceding_branches=preceding_branches & ~(8'b1<<previous_entry.cfi_index);
  first_not_taken=(|(previous_entry.branches[3:0]&preceding_branches[3:0])) || previous_history.current_not_taken;
  first_taken=selected_branch(previous_entry.branches,previous_entry.cfi_index) && previous_entry.cfi_valid && previous_entry.taken && !previous_entry.cfi_index[2];
  ignore_second_bank=(previous_entry.cfi_valid && previous_entry.taken && !previous_entry.cfi_index[2]) || previous_pc[5:3]==7;
  new_history.current_not_taken=io_enq_bits_ghist_current_saw_branch_not_taken;
  if(io_enq_bits_ghist_current_saw_branch_not_taken)begin
    new_history.old_history=io_enq_bits_ghist_old_history;
    new_history.new_not_taken=io_enq_bits_ghist_new_saw_branch_not_taken;
    new_history.new_taken=io_enq_bits_ghist_new_saw_branch_taken;
    new_history.ras_index=io_enq_bits_ghist_ras_idx;
  end
  else begin
    if(ignore_second_bank)begin
      new_history.old_history=history_base;
      new_history.new_not_taken=first_not_taken;
      new_history.new_taken=first_taken;
    end
    else begin
      new_history.old_history=first_taken?{history_base[62:0],1'b1}:first_not_taken?{history_base[62:0],1'b0}:history_base;
      new_history.new_not_taken=|(previous_entry.branches[7:4]&preceding_branches[7:4]);
      new_history.new_taken=previous_entry.cfi_valid && previous_entry.taken && selected_branch(previous_entry.branches,previous_entry.cfi_index) && previous_entry.cfi_index[2];
    end
    new_history.ras_index=previous_entry.cfi_valid && previous_entry.call_value?previous_history.ras_index+5'd1:previous_entry.cfi_valid && previous_entry.return_value?previous_history.ras_index-5'd1:previous_history.ras_index;
  end
end
always @(posedge clock)begin
  if(reset)begin
    enqueue_position<=1;dequeue_position<=0;training_position<=0;
    previous_history<='0;previous_entry<='0;previous_pc<=0;
    first_empty<=1;mispredict_mode<=0;repair_mode<=0;
  end
  else begin
    if(commit_update)training_position<=advance(training_position);
    if(io_deq_valid)dequeue_position<=io_deq_bits;
    if(io_redirect_valid)enqueue_position<=advance(io_redirect_bits);
    else if(enqueue_fire)enqueue_position<=advance(enqueue_position);
    if(previous_redirect && !io_redirect_valid)begin
      previous_history<=training_history;
      previous_entry<=captured_redirect;
      previous_pc<=training_pc;
    end
    else if(enqueue_fire)begin
      previous_history<=new_history;
      previous_entry<=new_enqueue;
      previous_pc<=io_enq_bits_pc;
    end
    first_empty<=first_empty && !issued_update;
    mispredict_mode<=!io_redirect_valid && previous_branch_mispredict;
    repair_mode<=!io_redirect_valid && (previous_branch_mispredict?repair_mode:(mispredict_mode || (repair_mode && (previous_mispredict_mode || !(advance(repair_position)==repair_end || training_pc==repair_stop_pc)))));
  end
  for(integer row=0;row<40;row=row+1)begin
    if(previous_redirect && !io_redirect_valid && captured_redirect_position==row)entries[row]<=captured_redirect;
    else if(enqueue_fire && enqueue_position==row)entries[row]<=new_enqueue;
    if(enqueue_fire && enqueue_position==row)begin
      pcs[row]<=io_enq_bits_pc;
      histories[row]<=new_history;
      metadata[row]<={io_enq_bits_bpd_meta_1,io_enq_bits_bpd_meta_0};
    end
  end
  io_ras_update<=io_redirect_valid;
  io_ras_update_pc<=io_redirect_valid?redirect_entry.ras_top:40'b0;
  io_ras_update_idx<=io_redirect_valid?redirect_entry.ras_index:5'b0;
  if(!io_redirect_valid)begin
    if(previous_branch_mispredict)begin repair_position<=captured_mispredict_position;repair_end<=captured_end;end
    else if(mispredict_mode || repair_mode)repair_position<=advance(repair_position);
    if(!previous_branch_mispredict && !mispredict_mode && repair_mode && previous_mispredict_mode)repair_stop_pc<=training_pc;
  end
  training_entry<=selected_entry;
  training_pc<=pcs[storage_index(selected_position)];
  training_target<=pcs[storage_index(advance(selected_position))];
  history_read_position<=selected_position;
  query_history_position<=io_get_ftq_pc_1_ftq_idx;
  previous_branch_mispredict<=io_brupdate_b2_mispredict;
  captured_mispredict_position<=io_brupdate_b2_uop_ftq_idx;
  captured_end<=enqueue_position;
  previous_mispredict_mode<=mispredict_mode;
  issued_update<=commit_update || repair_mode || mispredict_mode;
  previous_repair<=repair_mode;
  io_bpdupdate_bits_is_mispredict_update<=mispredict_mode;
  io_bpdupdate_bits_is_repair_update<=repair_mode;
  io_enq_ready<=!((advance(enqueue_position)==training_position)||(advance(advance(enqueue_position))==training_position)) || commit_update;
  previous_redirect<=io_redirect_valid;
  captured_redirect_position<=io_redirect_bits;
  captured_redirect<=new_redirect;
  io_get_ftq_pc_0_entry_cfi_idx_valid<=query0_entry.cfi_valid;
  io_get_ftq_pc_0_entry_cfi_idx_bits<=query0_entry.cfi_index;
  io_get_ftq_pc_0_entry_ras_idx<=query0_entry.ras_index;
  io_get_ftq_pc_0_entry_start_bank<=query0_entry.start_bank;
  io_get_ftq_pc_0_pc<=pcs[storage_index(io_get_ftq_pc_0_ftq_idx)];
  io_get_ftq_pc_0_com_pc<=pcs[storage_index(io_deq_valid?io_deq_bits:dequeue_position)];
  io_get_ftq_pc_0_next_pc<=(next_query_position==enqueue_position && enqueue_fire)?io_enq_bits_pc:pcs[storage_index(next_query_position)];
  io_get_ftq_pc_0_next_val<=next_query_position!=enqueue_position || enqueue_fire;
  io_get_ftq_pc_1_entry_cfi_idx_bits<=query1_entry.cfi_index;
  io_get_ftq_pc_1_entry_br_mask<=query1_entry.branches;
  io_get_ftq_pc_1_entry_cfi_is_call<=query1_entry.call_value;
  io_get_ftq_pc_1_entry_cfi_is_ret<=query1_entry.return_value;
  io_get_ftq_pc_1_entry_start_bank<=query1_entry.start_bank;
  io_get_ftq_pc_1_pc<=pcs[storage_index(io_get_ftq_pc_1_ftq_idx)];
end
assign io_enq_idx=enqueue_position;
assign io_get_ftq_pc_1_ghist_old_history=query_history.old_history;
assign io_get_ftq_pc_1_ghist_current_saw_branch_not_taken=query_history.current_not_taken;
assign io_get_ftq_pc_1_ghist_new_saw_branch_not_taken=query_history.new_not_taken;
assign io_get_ftq_pc_1_ghist_new_saw_branch_taken=query_history.new_taken;
assign io_get_ftq_pc_1_ghist_ras_idx=query_history.ras_index;
assign io_bpdupdate_valid=issued_update && !first_empty && (training_entry.cfi_valid || (|training_entry.branches)) && !(previous_repair && training_pc==repair_stop_pc);
assign io_bpdupdate_bits_pc=training_pc;
assign io_bpdupdate_bits_br_mask=training_entry.branches & (training_entry.cfi_valid?prefix(training_entry.cfi_index):8'hff);
assign io_bpdupdate_bits_cfi_idx_valid=training_entry.cfi_valid;
assign io_bpdupdate_bits_cfi_idx_bits=training_entry.cfi_index;
assign io_bpdupdate_bits_cfi_taken=training_entry.taken;
assign io_bpdupdate_bits_cfi_mispredicted=training_entry.mispredicted;
assign io_bpdupdate_bits_cfi_is_br=selected_branch(training_entry.branches,training_entry.cfi_index);
assign io_bpdupdate_bits_cfi_is_jal=training_entry.cfi_type==2 || training_entry.cfi_type==3;
assign io_bpdupdate_bits_ghist_old_history=training_history.old_history;
assign io_bpdupdate_bits_ghist_new_saw_branch_not_taken=training_history.new_not_taken;
assign io_bpdupdate_bits_ghist_new_saw_branch_taken=training_history.new_taken;
assign io_bpdupdate_bits_target=training_target;
assign io_bpdupdate_bits_meta_0=metadata[history_read_position][119:0];
assign io_bpdupdate_bits_meta_1=metadata[history_read_position][239:120];

endmodule
