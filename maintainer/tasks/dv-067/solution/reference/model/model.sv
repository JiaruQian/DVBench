`timescale 1ns/1ps
module dvbench_model(
  input logic clock,
  input logic [63:0] io_f1_req_ghist,
  input logic [39:0] io_f1_req_pc,
  input logic io_f1_req_valid,
  output logic [2:0] io_f3_resp_0_bits_ctr,
  output logic [1:0] io_f3_resp_0_bits_u,
  output logic io_f3_resp_0_valid,
  output logic [2:0] io_f3_resp_1_bits_ctr,
  output logic [1:0] io_f3_resp_1_bits_u,
  output logic io_f3_resp_1_valid,
  output logic [2:0] io_f3_resp_2_bits_ctr,
  output logic [1:0] io_f3_resp_2_bits_u,
  output logic io_f3_resp_2_valid,
  output logic [2:0] io_f3_resp_3_bits_ctr,
  output logic [1:0] io_f3_resp_3_bits_u,
  output logic io_f3_resp_3_valid,
  input logic io_update_alloc_0,
  input logic io_update_alloc_1,
  input logic io_update_alloc_2,
  input logic io_update_alloc_3,
  input logic [63:0] io_update_hist,
  input logic io_update_mask_0,
  input logic io_update_mask_1,
  input logic io_update_mask_2,
  input logic io_update_mask_3,
  input logic [2:0] io_update_old_ctr_0,
  input logic [2:0] io_update_old_ctr_1,
  input logic [2:0] io_update_old_ctr_2,
  input logic [2:0] io_update_old_ctr_3,
  input logic [39:0] io_update_pc,
  input logic io_update_taken_0,
  input logic io_update_taken_1,
  input logic io_update_taken_2,
  input logic io_update_taken_3,
  input logic [1:0] io_update_u_0,
  input logic [1:0] io_update_u_1,
  input logic [1:0] io_update_u_2,
  input logic [1:0] io_update_u_3,
  input logic io_update_u_mask_0,
  input logic io_update_u_mask_1,
  input logic io_update_u_mask_2,
  input logic io_update_u_mask_3,
  input logic reset
);
  logic entry_valid[128][4];
  logic [6:0] entry_tag[128][4];
  logic [2:0] counter[128][4];
  logic useful_hi[128][4];
  logic useful_lo[128][4];
  logic sweeping;
  logic [6:0] sweep_index;
  logic [18:0] age;
  logic read_enabled;
  logic [6:0] read_index,read_tag;
  logic [6:0] bypass_index[2],bypass_tag[2];
  logic [2:0] bypass_counter[2][4];
  logic replacement;
  logic [6:0] update_index,update_tag;
  logic [3:0] masks,taken,alloc,u_masks;
  logic [2:0] old_counter[4],next_counter[4];
  logic [1:0] useful_value[4];
  logic hit0,hit1,hit,any_update;
  logic [2:0] base_counter[4];
  function automatic logic [2:0] step_counter(input logic [2:0] value,input logic direction);
    if(direction) step_counter=value==7 ? 7 : value+1;
    else step_counter=value==0 ? 0 : value-1;
  endfunction
  always_comb begin
    update_index=((io_update_pc>>4)&127) ^ (io_update_hist&3);
    update_tag=((io_update_pc>>11)&127) ^ (io_update_hist&3);
    masks={io_update_mask_3,io_update_mask_2,io_update_mask_1,io_update_mask_0};
    taken={io_update_taken_3,io_update_taken_2,io_update_taken_1,io_update_taken_0};
    alloc={io_update_alloc_3,io_update_alloc_2,io_update_alloc_1,io_update_alloc_0};
    u_masks={io_update_u_mask_3,io_update_u_mask_2,io_update_u_mask_1,io_update_u_mask_0};
    old_counter[0]=io_update_old_ctr_0; useful_value[0]=io_update_u_0;
    old_counter[1]=io_update_old_ctr_1; useful_value[1]=io_update_u_1;
    old_counter[2]=io_update_old_ctr_2; useful_value[2]=io_update_u_2;
    old_counter[3]=io_update_old_ctr_3; useful_value[3]=io_update_u_3;
    hit0=!sweeping && bypass_index[0]==update_index && bypass_tag[0]==update_tag;
    hit1=!sweeping && bypass_index[1]==update_index && bypass_tag[1]==update_tag;
    hit=hit0 || hit1; any_update=|masks;
    for(int bank=0;bank<4;bank++) begin
      base_counter[bank]=hit0 ? bypass_counter[0][bank] : bypass_counter[1][bank];
      next_counter[bank]=alloc[bank] ? (taken[bank] ? 4 : 3) : hit ? step_counter(base_counter[bank],taken[bank]) : step_counter(old_counter[bank],taken[bank]);
    end
  end
  always @(posedge clock) begin
    io_f3_resp_0_valid <= (read_enabled ? entry_valid[read_index][0] && entry_tag[read_index][0]==read_tag : 1'bx) && !sweeping;
    io_f3_resp_0_bits_ctr <= read_enabled ? counter[read_index][0] : 3'bx;
    io_f3_resp_0_bits_u <= read_enabled ? {useful_hi[read_index][0],useful_lo[read_index][0]} : 2'bx;
    io_f3_resp_1_valid <= (read_enabled ? entry_valid[read_index][1] && entry_tag[read_index][1]==read_tag : 1'bx) && !sweeping;
    io_f3_resp_1_bits_ctr <= read_enabled ? counter[read_index][1] : 3'bx;
    io_f3_resp_1_bits_u <= read_enabled ? {useful_hi[read_index][1],useful_lo[read_index][1]} : 2'bx;
    io_f3_resp_2_valid <= (read_enabled ? entry_valid[read_index][2] && entry_tag[read_index][2]==read_tag : 1'bx) && !sweeping;
    io_f3_resp_2_bits_ctr <= read_enabled ? counter[read_index][2] : 3'bx;
    io_f3_resp_2_bits_u <= read_enabled ? {useful_hi[read_index][2],useful_lo[read_index][2]} : 2'bx;
    io_f3_resp_3_valid <= (read_enabled ? entry_valid[read_index][3] && entry_tag[read_index][3]==read_tag : 1'bx) && !sweeping;
    io_f3_resp_3_bits_ctr <= read_enabled ? counter[read_index][3] : 3'bx;
    io_f3_resp_3_bits_u <= read_enabled ? {useful_hi[read_index][3],useful_lo[read_index][3]} : 2'bx;
    read_enabled<=io_f1_req_valid;
    read_index<=((io_f1_req_pc>>4)&127) ^ (io_f1_req_ghist&3);
    read_tag<=((io_f1_req_pc>>11)&127) ^ (io_f1_req_ghist&3);
    for(int bank=0;bank<4;bank++) begin
      if(sweeping) begin entry_valid[sweep_index][bank]<=0; entry_tag[sweep_index][bank]<=0; counter[sweep_index][bank]<=0; end
      else if(masks[bank]) begin entry_valid[update_index][bank]<=1; entry_tag[update_index][bank]<=update_tag; counter[update_index][bank]<=next_counter[bank]; end
      if(sweeping) begin useful_hi[sweep_index][bank]<=0; useful_lo[sweep_index][bank]<=0; end
      else begin
        if(age[10:0]==0 && age[18]) useful_hi[age[17:11]][bank]<=0;
        else if(u_masks[bank]) useful_hi[update_index][bank]<=useful_value[bank][1];
        if(age[10:0]==0 && !age[18]) useful_lo[age[17:11]][bank]<=0;
        else if(u_masks[bank]) useful_lo[update_index][bank]<=useful_value[bank][0];
      end
    end
    if(any_update) begin
      if(hit) begin
        if(hit0) begin for(int bank=0;bank<4;bank++) bypass_counter[0][bank]<=next_counter[bank]; end
        else begin for(int bank=0;bank<4;bank++) bypass_counter[1][bank]<=next_counter[bank]; end
      end
      else if(replacement) begin
        bypass_index[1]<=update_index; bypass_tag[1]<=update_tag;
        for(int bank=0;bank<4;bank++) bypass_counter[1][bank]<=next_counter[bank];
      end
      else begin
        bypass_index[0]<=update_index; bypass_tag[0]<=update_tag;
        for(int bank=0;bank<4;bank++) bypass_counter[0][bank]<=next_counter[bank];
      end
    end
    if(reset) begin sweeping<=1; sweep_index<=0; age<=0; replacement<=0; end
    else begin
      if(sweeping) begin
        sweeping<=sweep_index!=127; sweep_index<=sweep_index+1; age<=1;
      end
      else age<=age+1;
      if(!any_update || hit) begin end else replacement<=!replacement;
    end
  end
endmodule
