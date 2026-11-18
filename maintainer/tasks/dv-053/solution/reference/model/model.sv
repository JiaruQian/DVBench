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
input logic io_resp_in_0_f2_0_taken,
input logic io_resp_in_0_f2_0_is_br,
input logic io_resp_in_0_f2_0_is_jal,
input logic io_resp_in_0_f2_0_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f2_0_predicted_pc_bits,
input logic io_resp_in_0_f2_1_taken,
input logic io_resp_in_0_f2_1_is_br,
input logic io_resp_in_0_f2_1_is_jal,
input logic io_resp_in_0_f2_1_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f2_1_predicted_pc_bits,
input logic io_resp_in_0_f2_2_taken,
input logic io_resp_in_0_f2_2_is_br,
input logic io_resp_in_0_f2_2_is_jal,
input logic io_resp_in_0_f2_2_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f2_2_predicted_pc_bits,
input logic io_resp_in_0_f2_3_taken,
input logic io_resp_in_0_f2_3_is_br,
input logic io_resp_in_0_f2_3_is_jal,
input logic io_resp_in_0_f2_3_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f2_3_predicted_pc_bits,
input logic io_resp_in_0_f3_0_taken,
input logic io_resp_in_0_f3_0_is_br,
input logic io_resp_in_0_f3_0_is_jal,
input logic io_resp_in_0_f3_0_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f3_0_predicted_pc_bits,
input logic io_resp_in_0_f3_1_taken,
input logic io_resp_in_0_f3_1_is_br,
input logic io_resp_in_0_f3_1_is_jal,
input logic io_resp_in_0_f3_1_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f3_1_predicted_pc_bits,
input logic io_resp_in_0_f3_2_taken,
input logic io_resp_in_0_f3_2_is_br,
input logic io_resp_in_0_f3_2_is_jal,
input logic io_resp_in_0_f3_2_predicted_pc_valid,
input logic [39:0] io_resp_in_0_f3_2_predicted_pc_bits,
input logic io_resp_in_0_f3_3_taken,
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
input logic [39:0] io_update_bits_target,
input logic [119:0] io_update_bits_meta
);
logic [55:0] target_rows[0:1][0:127];
logic [119:0] tag_rows[0:1][0:127];
logic [39:0] extended_rows[0:15];
logic [6:0] read_row;
logic [3:0] extended_write_row;
logic read_enabled;
logic [39:0] request_pc;
logic sweeping;
logic [6:0] sweep_index;
logic update_valid,update_mispredict,update_repair,update_selected_valid,update_taken,update_way;
logic [3:0] update_bad_slots,update_branches;
logic [1:0] update_selected;
logic [39:0] update_pc,update_target;
logic [39:0] distance;
logic extended_distance,normal_update;
logic [3:0] target_mask,tag_mask;
logic [55:0] lookup_targets[0:1];
logic [119:0] lookup_tags[0:1];
logic [39:0] lookup_extended;
logic [3:0] first_way_hit,any_hit;
logic [3:0] override_f2,override_f3,jump_f2,jump_f3;
logic [3:0] prediction_valid_f2,prediction_branch_f2,prediction_jump_f2;
logic [39:0] prediction_pc_f2[0:3];
logic [3:0] prediction_valid_f3,prediction_branch_f3,prediction_jump_f3;
logic [39:0] prediction_pc_f3[0:3];
logic [13:0] selected_target[0:3];
logic [29:0] selected_tag[0:3];
logic allocation_way,replacement_f2,replacement_f3;
logic [6:0] write_row;
function automatic logic [3:0] extended_hash(input logic [6:0] row);
  extended_hash=row[3:0]^{1'b0,row[6:4]};
endfunction
always_comb begin
  distance=update_target-(update_pc+{37'b0,update_selected,1'b0});
  extended_distance=($signed(distance)>40'sd4095)||($signed(distance)<-40'sd4096);
  normal_update=update_valid && !update_mispredict && !update_repair && !(|update_bad_slots);
  target_mask=normal_update && update_selected_valid && update_taken ? (4'b1<<update_selected):0;
  write_row=sweeping?sweep_index:update_pc[10:4];
  for(integer slot=0;slot<4;slot=slot+1)
    tag_mask[slot]=(target_mask[slot]||update_branches[slot])&&(normal_update||(update_valid&&update_bad_slots[slot]));
  for(integer way=0;way<2;way=way+1)begin
    lookup_targets[way]=read_enabled?target_rows[way][read_row]:'x;
    lookup_tags[way]=read_enabled?tag_rows[way][read_row]:'x;
  end
  lookup_extended=read_enabled?extended_rows[extended_hash(read_row)]:'x;
  allocation_way=^request_pc[39:11];
  for(integer slot=0;slot<4;slot=slot+1)begin
    first_way_hit[slot]=lookup_tags[0][30*slot+:29]==request_pc[39:11];
    any_hit[slot]=first_way_hit[slot] || lookup_tags[1][30*slot+:29]==request_pc[39:11];
    selected_target[slot]=first_way_hit[slot]?lookup_targets[0][14*slot+:14]:lookup_targets[1][14*slot+:14];
    selected_tag[slot]=first_way_hit[slot]?lookup_tags[0][30*slot+:30]:lookup_tags[1][30*slot+:30];
    allocation_way=allocation_way^(^lookup_tags[0][30*slot+:29])^(^lookup_tags[1][30*slot+:29]);
  end
end
always @(posedge clock)begin
  for(integer way=0;way<2;way=way+1)begin
    for(integer slot=0;slot<4;slot=slot+1)begin
      if(sweeping || (update_way==way && target_mask[slot]))
        target_rows[way][write_row][14*slot+:14]<=sweeping?14'b0:{distance[12:0],extended_distance};
      if(sweeping || (update_way==way && tag_mask[slot]))
        tag_rows[way][write_row][30*slot+:30]<=sweeping?30'b0:{update_branches[slot],update_bad_slots[slot]?29'b0:update_pc[39:11]};
    end
  end
  extended_write_row<=extended_hash(update_pc[10:4]);
  if((|target_mask)&&extended_distance)extended_rows[extended_write_row]<=update_target;
  read_enabled<=io_f0_valid;
  read_row<=io_f0_pc[10:4];
  request_pc<=io_f0_pc;
  override_f2<=any_hit;
  override_f3<=override_f2;
  replacement_f2<=(|any_hit)?!(|first_way_hit):allocation_way;
  replacement_f3<=replacement_f2;
  for(integer slot=0;slot<4;slot=slot+1)begin
    prediction_valid_f2[slot]<=!sweeping && read_enabled && any_hit[slot];
    prediction_branch_f2[slot]<=!sweeping && read_enabled && any_hit[slot] && selected_tag[slot][29];
    prediction_jump_f2[slot]<=!sweeping && read_enabled && any_hit[slot] && !selected_tag[slot][29];
    jump_f2[slot]<=!sweeping && read_enabled && any_hit[slot] && !selected_tag[slot][29];
    jump_f3[slot]<=jump_f2[slot];
    prediction_pc_f2[slot]<=selected_target[slot][0]?lookup_extended:request_pc+{{27{selected_target[slot][13]}},selected_target[slot][13:1]}+40'(slot*2);
  end
  prediction_valid_f3[0]<=override_f2[0]?prediction_valid_f2[0]:io_resp_in_0_f2_0_predicted_pc_valid;
  prediction_branch_f3[0]<=override_f2[0]?prediction_branch_f2[0]:io_resp_in_0_f2_0_is_br;
  prediction_jump_f3[0]<=override_f2[0]?prediction_jump_f2[0]:io_resp_in_0_f2_0_is_jal;
  prediction_pc_f3[0]<=override_f2[0]?prediction_pc_f2[0]:io_resp_in_0_f2_0_predicted_pc_bits;
  prediction_valid_f3[1]<=override_f2[1]?prediction_valid_f2[1]:io_resp_in_0_f2_1_predicted_pc_valid;
  prediction_branch_f3[1]<=override_f2[1]?prediction_branch_f2[1]:io_resp_in_0_f2_1_is_br;
  prediction_jump_f3[1]<=override_f2[1]?prediction_jump_f2[1]:io_resp_in_0_f2_1_is_jal;
  prediction_pc_f3[1]<=override_f2[1]?prediction_pc_f2[1]:io_resp_in_0_f2_1_predicted_pc_bits;
  prediction_valid_f3[2]<=override_f2[2]?prediction_valid_f2[2]:io_resp_in_0_f2_2_predicted_pc_valid;
  prediction_branch_f3[2]<=override_f2[2]?prediction_branch_f2[2]:io_resp_in_0_f2_2_is_br;
  prediction_jump_f3[2]<=override_f2[2]?prediction_jump_f2[2]:io_resp_in_0_f2_2_is_jal;
  prediction_pc_f3[2]<=override_f2[2]?prediction_pc_f2[2]:io_resp_in_0_f2_2_predicted_pc_bits;
  prediction_valid_f3[3]<=override_f2[3]?prediction_valid_f2[3]:io_resp_in_0_f2_3_predicted_pc_valid;
  prediction_branch_f3[3]<=override_f2[3]?prediction_branch_f2[3]:io_resp_in_0_f2_3_is_br;
  prediction_jump_f3[3]<=override_f2[3]?prediction_jump_f2[3]:io_resp_in_0_f2_3_is_jal;
  prediction_pc_f3[3]<=override_f2[3]?prediction_pc_f2[3]:io_resp_in_0_f2_3_predicted_pc_bits;
  update_valid<=io_update_valid;
  update_mispredict<=io_update_bits_is_mispredict_update;
  update_repair<=io_update_bits_is_repair_update;
  update_bad_slots<=io_update_bits_btb_mispredicts;
  update_branches<=io_update_bits_br_mask;
  update_selected_valid<=io_update_bits_cfi_idx_valid;
  update_selected<=io_update_bits_cfi_idx_bits;
  update_taken<=io_update_bits_cfi_taken;
  update_pc<=io_update_bits_pc;
  update_target<=io_update_bits_target;
  update_way<=io_update_bits_meta[0];
  if(reset)begin sweeping<=1;sweep_index<=0;end
  else begin sweeping<=sweeping && sweep_index!=127;sweep_index<=sweep_index+sweeping;end
end
assign io_f3_meta={119'b0,replacement_f3};
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
assign io_resp_f2_0_taken=(override_f2[0] && jump_f2[0]) || io_resp_in_0_f2_0_taken;
assign io_resp_f2_0_is_br=override_f2[0]?prediction_branch_f2[0]:io_resp_in_0_f2_0_is_br;
assign io_resp_f2_0_is_jal=override_f2[0]?prediction_jump_f2[0]:io_resp_in_0_f2_0_is_jal;
assign io_resp_f2_0_predicted_pc_valid=override_f2[0]?prediction_valid_f2[0]:io_resp_in_0_f2_0_predicted_pc_valid;
assign io_resp_f2_0_predicted_pc_bits=override_f2[0]?prediction_pc_f2[0]:io_resp_in_0_f2_0_predicted_pc_bits;
assign io_resp_f2_1_taken=(override_f2[1] && jump_f2[1]) || io_resp_in_0_f2_1_taken;
assign io_resp_f2_1_is_br=override_f2[1]?prediction_branch_f2[1]:io_resp_in_0_f2_1_is_br;
assign io_resp_f2_1_is_jal=override_f2[1]?prediction_jump_f2[1]:io_resp_in_0_f2_1_is_jal;
assign io_resp_f2_1_predicted_pc_valid=override_f2[1]?prediction_valid_f2[1]:io_resp_in_0_f2_1_predicted_pc_valid;
assign io_resp_f2_1_predicted_pc_bits=override_f2[1]?prediction_pc_f2[1]:io_resp_in_0_f2_1_predicted_pc_bits;
assign io_resp_f2_2_taken=(override_f2[2] && jump_f2[2]) || io_resp_in_0_f2_2_taken;
assign io_resp_f2_2_is_br=override_f2[2]?prediction_branch_f2[2]:io_resp_in_0_f2_2_is_br;
assign io_resp_f2_2_is_jal=override_f2[2]?prediction_jump_f2[2]:io_resp_in_0_f2_2_is_jal;
assign io_resp_f2_2_predicted_pc_valid=override_f2[2]?prediction_valid_f2[2]:io_resp_in_0_f2_2_predicted_pc_valid;
assign io_resp_f2_2_predicted_pc_bits=override_f2[2]?prediction_pc_f2[2]:io_resp_in_0_f2_2_predicted_pc_bits;
assign io_resp_f2_3_taken=(override_f2[3] && jump_f2[3]) || io_resp_in_0_f2_3_taken;
assign io_resp_f2_3_is_br=override_f2[3]?prediction_branch_f2[3]:io_resp_in_0_f2_3_is_br;
assign io_resp_f2_3_is_jal=override_f2[3]?prediction_jump_f2[3]:io_resp_in_0_f2_3_is_jal;
assign io_resp_f2_3_predicted_pc_valid=override_f2[3]?prediction_valid_f2[3]:io_resp_in_0_f2_3_predicted_pc_valid;
assign io_resp_f2_3_predicted_pc_bits=override_f2[3]?prediction_pc_f2[3]:io_resp_in_0_f2_3_predicted_pc_bits;
assign io_resp_f3_0_taken=(override_f3[0] && jump_f3[0]) || io_resp_in_0_f3_0_taken;
assign io_resp_f3_0_is_br=override_f3[0]?prediction_branch_f3[0]:io_resp_in_0_f3_0_is_br;
assign io_resp_f3_0_is_jal=override_f3[0]?prediction_jump_f3[0]:io_resp_in_0_f3_0_is_jal;
assign io_resp_f3_0_predicted_pc_valid=override_f3[0]?prediction_valid_f3[0]:io_resp_in_0_f3_0_predicted_pc_valid;
assign io_resp_f3_0_predicted_pc_bits=override_f3[0]?prediction_pc_f3[0]:io_resp_in_0_f3_0_predicted_pc_bits;
assign io_resp_f3_1_taken=(override_f3[1] && jump_f3[1]) || io_resp_in_0_f3_1_taken;
assign io_resp_f3_1_is_br=override_f3[1]?prediction_branch_f3[1]:io_resp_in_0_f3_1_is_br;
assign io_resp_f3_1_is_jal=override_f3[1]?prediction_jump_f3[1]:io_resp_in_0_f3_1_is_jal;
assign io_resp_f3_1_predicted_pc_valid=override_f3[1]?prediction_valid_f3[1]:io_resp_in_0_f3_1_predicted_pc_valid;
assign io_resp_f3_1_predicted_pc_bits=override_f3[1]?prediction_pc_f3[1]:io_resp_in_0_f3_1_predicted_pc_bits;
assign io_resp_f3_2_taken=(override_f3[2] && jump_f3[2]) || io_resp_in_0_f3_2_taken;
assign io_resp_f3_2_is_br=override_f3[2]?prediction_branch_f3[2]:io_resp_in_0_f3_2_is_br;
assign io_resp_f3_2_is_jal=override_f3[2]?prediction_jump_f3[2]:io_resp_in_0_f3_2_is_jal;
assign io_resp_f3_2_predicted_pc_valid=override_f3[2]?prediction_valid_f3[2]:io_resp_in_0_f3_2_predicted_pc_valid;
assign io_resp_f3_2_predicted_pc_bits=override_f3[2]?prediction_pc_f3[2]:io_resp_in_0_f3_2_predicted_pc_bits;
assign io_resp_f3_3_taken=(override_f3[3] && jump_f3[3]) || io_resp_in_0_f3_3_taken;
assign io_resp_f3_3_is_br=override_f3[3]?prediction_branch_f3[3]:io_resp_in_0_f3_3_is_br;
assign io_resp_f3_3_is_jal=override_f3[3]?prediction_jump_f3[3]:io_resp_in_0_f3_3_is_jal;
assign io_resp_f3_3_predicted_pc_valid=override_f3[3]?prediction_valid_f3[3]:io_resp_in_0_f3_3_predicted_pc_valid;
assign io_resp_f3_3_predicted_pc_bits=override_f3[3]?prediction_pc_f3[3]:io_resp_in_0_f3_3_predicted_pc_bits;

endmodule
