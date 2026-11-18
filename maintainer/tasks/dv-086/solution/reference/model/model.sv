`timescale 1ns/1ps
module dvbench_model(
input logic clk,
input logic rst_n,
input logic invalid_i,
input logic core_req_valid_i,
input logic [31:0] core_req_addr_i,
input logic [1:0] core_req_mask_i,
input logic [2:0] core_req_wid_i,
input logic flush_pipe_valid_i,
input logic [2:0] flush_pipe_wid_i,
output logic core_rsp_valid_o,
output logic [31:0] core_rsp_addr_o,
output logic [63:0] core_rsp_data_o,
output logic [1:0] core_rsp_mask_o,
output logic [2:0] core_rsp_wid_o,
output logic core_rsp_status_o,
output logic mem_rsp_ready_o,
input logic mem_rsp_valid_i,
input logic [2:0] mem_rsp_d_source_i,
input logic [31:0] mem_rsp_d_addr_i,
input logic [63:0] mem_rsp_d_data_i,
input logic mem_req_ready_i,
output logic mem_req_valid_o,
output logic [2:0] mem_req_a_source_o,
output logic [31:0] mem_req_a_addr_o
);

logic [23:0] tags[0:31][0:1];
logic [63:0] lines[0:31][0:1];
logic [1:0] valid_ways[0:31];
logic [31:0] victim;
logic [47:0] tag_read;
logic [127:0] line_read;
logic same_row_bypass;
logic [23:0] bypass_tag;
logic [63:0] bypass_line;
logic request_seen,stage_one_valid;
logic [4:0] captured_set;
logic [31:0] stage_one_addr;
logic [2:0] stage_one_warp;
logic [1:0] stage_one_mask;
logic old_flush_zero,old_flush_one,miss_status;
logic [28:0] blocks[0:3];
logic [1:0] occupied[0:3];
logic [3:0] sent;
logic [23:0] target_bits;
logic [98:0] response_slots[0:1];
logic [1:0] response_write,response_read;
logic [98:0] response_head;
logic response_pending,read_request,flush_zero,flush_one;
logic [1:0] hit_vector;
logic hit_any,selected_way,cache_miss;
logic [47:0] lookup_tags;
logic [127:0] lookup_lines;
logic [3:0] live_entries,request_matches,response_matches,waiting;
logic [28:0] request_block,response_block,fill_block;
logic request_secondary,admit_request,response_fire;
integer request_entry,response_entry,free_entry,free_subentry,send_entry,selected_entry,selected_subentry;
integer fill_set,fill_way,allocation_row;
logic request_fire,send_fire;

function automatic integer first_clear(input logic [3:0] bits,input integer count);
  integer result;
  begin
    result=0;
    for(integer position=count-1;position>=0;position--) if(!bits[position]) result=position;
    first_clear=result;
  end
endfunction

always @* begin
  response_head=response_slots[response_read[0]];
  response_pending=(response_write!=response_read);
  response_fire=response_pending;
  response_block=response_head[34:3]>>3;
  flush_zero=flush_pipe_valid_i && core_req_wid_i==flush_pipe_wid_i;
  flush_one=flush_pipe_valid_i && stage_one_warp==flush_pipe_wid_i;
  read_request=core_req_valid_i && !flush_zero;
  lookup_tags=same_row_bypass ? {bypass_tag,bypass_tag} : tag_read;
  lookup_lines=same_row_bypass ? {bypass_line,bypass_line} : line_read;
  for(integer way=0;way<2;way++) hit_vector[way]=request_seen && valid_ways[captured_set][way] && lookup_tags[way*24+:24]==stage_one_addr[31:8];
  hit_any=|hit_vector;
  selected_way=hit_vector[1];
  cache_miss=stage_one_valid && !hit_any;
  request_block=stage_one_addr[31:3];
  request_entry=0;
  response_entry=0;
  for(integer entry=0;entry<4;entry++) begin
    live_entries[entry]=|occupied[entry];
    request_matches[entry]=live_entries[entry] && blocks[entry]==request_block;
    response_matches[entry]=live_entries[entry] && blocks[entry]==response_block;
    waiting[entry]=live_entries[entry] && !sent[entry];
    if(request_matches[entry]) request_entry=request_entry|entry;
    if(response_matches[entry]) response_entry=response_entry|entry;
  end
  request_secondary=|request_matches;
  free_entry=first_clear(live_entries,4);
  free_subentry=first_clear({2'b00,occupied[request_entry]},2);
  send_entry=first_clear(~waiting,4);
  selected_entry=request_secondary ? request_entry : free_entry;
  selected_subentry=request_secondary ? free_subentry : 0;
  admit_request=!(request_secondary ? &occupied[request_entry] : &live_entries) && !(cache_miss && response_fire && response_block==request_block);
  request_fire=cache_miss && admit_request;
  mem_req_valid_o=waiting[send_entry];
  mem_req_a_addr_o={blocks[send_entry],3'b000};
  mem_req_a_source_o=target_bits[send_entry*3+:3];
  send_fire=mem_req_ready_i && mem_req_valid_o;
  fill_block=blocks[response_entry];
  fill_set=fill_block[4:0];
  fill_way=victim[fill_set];
  allocation_row=free_entry;
  if(response_fire && response_block!=request_block && free_entry>response_entry) allocation_row=response_entry;
  core_rsp_status_o=old_flush_one ? 1'b0 : miss_status;
  mem_rsp_ready_o=1'b1;
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    victim<=0;
    tag_read<=0;
    line_read<=0;
    same_row_bypass<=0;
    bypass_tag<=0;
    bypass_line<=0;
    request_seen<=0;
    captured_set<=0;
    stage_one_valid<=0;
    stage_one_addr<=0;
    stage_one_warp<=0;
    stage_one_mask<=0;
    old_flush_zero<=0;
    old_flush_one<=0;
    miss_status<=0;
    core_rsp_valid_o<=0;
    core_rsp_addr_o<=0;
    core_rsp_data_o<=0;
    core_rsp_mask_o<=0;
    core_rsp_wid_o<=0;
    sent<=0;
    target_bits<=0;
    response_write<=0;
    response_read<=0;
    for(integer slot=0;slot<2;slot++) response_slots[slot]<=0;
    for(integer entry=0;entry<4;entry++) begin blocks[entry]<=0;occupied[entry]<=0;end
    for(integer row=0;row<32;row++) begin
      valid_ways[row]<=0;
      for(integer way=0;way<2;way++) begin tags[row][way]<=0;lines[row][way]<=0;end
    end
  end else begin
    core_rsp_valid_o<=stage_one_valid && !flush_one;
    core_rsp_addr_o<=stage_one_addr;
    core_rsp_wid_o<=stage_one_warp;
    core_rsp_mask_o<=stage_one_mask;
    core_rsp_data_o<=lookup_lines[selected_way*64+:64];
    stage_one_addr<=core_req_addr_i;
    stage_one_warp<=core_req_wid_i;
    stage_one_mask<=core_req_mask_i;
    stage_one_valid<=read_request;
    request_seen<=read_request;
    captured_set<=core_req_addr_i[7:3];
    old_flush_zero<=flush_zero;
    old_flush_one<=flush_one;
    miss_status<=old_flush_zero ? 1'b0 : cache_miss;
    same_row_bypass<=read_request && response_fire && core_req_addr_i[7:3]==fill_set;
    bypass_tag<=fill_block[28:5];
    bypass_line<=response_head[98:35];
    if(read_request && !(response_fire && core_req_addr_i[7:3]==fill_set)) begin
      tag_read<={tags[core_req_addr_i[7:3]][1],tags[core_req_addr_i[7:3]][0]};
      line_read<={lines[core_req_addr_i[7:3]][1],lines[core_req_addr_i[7:3]][0]};
    end
    if(response_fire) begin
      tags[fill_set][fill_way]<=fill_block[28:5];
      lines[fill_set][fill_way]<=response_head[98:35];
      valid_ways[fill_set][fill_way]<=1;
    end else if(invalid_i) begin
      for(integer row=0;row<32;row++) valid_ways[row]<=0;
    end
    for(integer row=0;row<32;row++) begin
      if(hit_any && captured_set==row) victim[row]<=!selected_way;
      else if(response_fire && fill_set==row) victim[row]<=!fill_way;
    end
    for(integer entry=0;entry<4;entry++) begin
      if(send_fire && send_entry==entry) sent[entry]<=1;
      else if(response_fire && response_entry==entry) sent[entry]<=0;
      if(response_fire && (!request_fire || response_block!=request_block) && response_entry==entry) occupied[entry]<=0;
    end
    if(request_fire) begin
      if(!request_secondary) begin
        blocks[free_entry]<=request_block;
        occupied[allocation_row][0]<=1;
      end else occupied[request_entry][free_subentry]<=1;
      target_bits[3*((selected_entry+1)*(selected_subentry+1)-1)+:3]<=stage_one_addr[2:0];
    end
    if(response_pending) response_read<=response_read+1'b1;
    if(mem_rsp_valid_i) begin
      response_slots[response_write[0]]<={mem_rsp_d_data_i,mem_rsp_d_addr_i,mem_rsp_d_source_i};
      response_write<=response_write+1'b1;
    end
  end
end

endmodule
