`timescale 1ns/1ps
module dvbench_model(
input logic [3:0] branch_ctl_mask_init_i,
input logic branch_ctl_opcode_i,
input logic [31:0] branch_ctl_pc_branch_i,
input logic [31:0] branch_ctl_pc_execute_i,
output logic branch_ctl_ready_o,
input logic branch_ctl_valid_i,
input logic [2:0] branch_ctl_wid_i,
input logic clk,
output logic complete_valid_o,
output logic [2:0] complete_wid_o,
output logic fetch_ctl_jump_o,
output logic [31:0] fetch_ctl_new_pc_o,
input logic fetch_ctl_ready_i,
output logic fetch_ctl_valid_o,
output logic [2:0] fetch_ctl_wid_o,
input logic [3:0] if_mask_mask_i,
output logic if_mask_ready_o,
input logic if_mask_valid_i,
input logic [2:0] if_mask_wid_i,
input logic [2:0] input_wid_i,
output logic [3:0] out_mask_o,
input logic [31:0] pc_reconv_i,
input logic pc_reconv_valid_i,
input logic rst_n
);

  typedef struct packed {logic opcode;logic[2:0] warp;logic[31:0] branch_pc,execute_pc;logic[3:0] initial_mask;} branch_record;
  typedef struct packed {logic[31:0] pc;logic jump;logic[2:0] warp;} fetch_record;
  branch_record pending;
  fetch_record fetch_saved,fetch_candidate;
  logic branch_full,recon_full,fetch_full;
  logic[31:0] recon_saved;
  logic[3:0] active_mask[8];
  logic[31:0] recon_record[8][24],jump_record[8][24];
  logic[3:0] mask_record[8][24];
  logic[20:0] read_position[8],write_position[8],write_successor[8];
  logic[3:0] if_lanes,else_lanes,other_mask,chosen_mask;
  logic if_only,else_only,divergent,take_if,fetch_capacity,if_fire,consume_branch,branch_fire;
  logic[31:0] other_pc,top_rpc[8],top_jpc[8];
  logic[3:0] top_mask[8];
  logic empty_stack[8],join_jump[8],stack_push[8];
  function automatic integer population(input logic[3:0] value);
    population=int'(value[0])+int'(value[1])+int'(value[2])+int'(value[3]);
  endfunction
  always_comb begin
    fetch_capacity=!fetch_full;
    branch_ctl_ready_o=!branch_full;
    if_mask_ready_o=fetch_capacity;
    if_fire=if_mask_valid_i && fetch_capacity;
    if_lanes=if_mask_mask_i & pending.initial_mask;
    else_lanes=pending.initial_mask & ~if_lanes;
    if_only=else_lanes==0;else_only=if_lanes==0;
    divergent=!(if_only || else_only);
    take_if=if_only || (divergent && population(if_lanes)<population(else_lanes));
    chosen_mask=take_if ? if_lanes:else_lanes;
    other_mask=take_if ? else_lanes:if_lanes;
    other_pc=take_if ? pending.branch_pc:pending.execute_pc+32'd4;
    consume_branch=fetch_capacity && branch_full && (pending.opcode || (pending.warp==if_mask_wid_i && if_mask_valid_i));
    branch_fire=consume_branch && branch_full;
    for(int warp=0;warp<8;warp++) begin
      empty_stack[warp]=write_position[warp]==0;
      write_successor[warp]=write_position[warp]+1'b1;
      top_rpc[warp]=read_position[warp]<24 ? recon_record[warp][read_position[warp]]:32'bx;
      top_jpc[warp]=empty_stack[warp] ? 0:read_position[warp]<24 ? jump_record[warp][read_position[warp]]:32'bx;
      top_mask[warp]=empty_stack[warp] ? 0:read_position[warp]<24 ? mask_record[warp][read_position[warp]]:4'bx;
      join_jump[warp]=!empty_stack[warp] && top_rpc[warp]==pending.execute_pc && pending.opcode && branch_fire && pending.warp==warp;
      stack_push[warp]=branch_fire && !pending.opcode && divergent && pending.warp==warp;
    end
    fetch_candidate.warp=pending.warp;fetch_candidate.pc=0;fetch_candidate.jump=0;
    if(pending.opcode && branch_full) begin
      fetch_candidate.pc=join_jump[pending.warp] ? top_jpc[pending.warp]:32'b0;
      fetch_candidate.jump=join_jump[pending.warp] ? 1'b1:1'b0;
    end
    else if(!pending.opcode && branch_full && if_mask_valid_i && (!take_if || else_only)) begin
      fetch_candidate.pc=pending.branch_pc;fetch_candidate.jump=1;
    end
    complete_valid_o=if_fire && !pending.opcode && branch_full && take_if;
    complete_wid_o=pending.warp;
    out_mask_o=active_mask[input_wid_i];
    fetch_ctl_valid_o=fetch_full;fetch_ctl_wid_o=fetch_saved.warp;fetch_ctl_jump_o=fetch_saved.jump;fetch_ctl_new_pc_o=fetch_saved.pc;
  end
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      pending<='0;fetch_saved<='0;recon_saved<=0;branch_full<=0;recon_full<=0;fetch_full<=0;
      for(int warp=0;warp<8;warp++) begin
        active_mask[warp]<=15;read_position[warp]<=0;write_position[warp]<=0;
        for(int slot=0;slot<24;slot++)begin recon_record[warp][slot]<=0;jump_record[warp][slot]<=0;mask_record[warp][slot]<=0;end
      end
    end
    else begin
      if(branch_ctl_valid_i && !branch_full)begin
        pending.opcode<=branch_ctl_opcode_i;pending.warp<=branch_ctl_wid_i;pending.branch_pc<=branch_ctl_pc_branch_i;pending.execute_pc<=branch_ctl_pc_execute_i;pending.initial_mask<=branch_ctl_mask_init_i;
      end
      branch_full<=(branch_full && !consume_branch) || (branch_ctl_valid_i && !branch_full);
      if(pc_reconv_valid_i && !recon_full)recon_saved<=pc_reconv_i;
      recon_full<=(recon_full && !consume_branch) || (pc_reconv_valid_i && !recon_full);
      if(fetch_capacity && ((pending.opcode && branch_full) || (!pending.opcode && branch_full && if_mask_valid_i && (!take_if || else_only))))fetch_saved<=fetch_candidate;
      fetch_full<=(fetch_full && !fetch_ctl_ready_i) || (fetch_capacity && ((pending.opcode && branch_full) || (!pending.opcode && branch_full && if_mask_valid_i && (!take_if || else_only))));
      if(if_fire && divergent)active_mask[pending.warp]<=chosen_mask;
      else if(pending.opcode && branch_full && join_jump[pending.warp])active_mask[pending.warp]<=top_mask[pending.warp];
      else if(empty_stack[pending.warp])active_mask[pending.warp]<=15;
      for(int warp=0;warp<8;warp++)begin
        if(stack_push[warp])begin
          read_position[warp]<=write_position[warp]+1'b1;write_position[warp]<=write_position[warp]+2'd2;
          for(int slot=0;slot<24;slot++)begin
            if(slot==int'(write_successor[warp])-1)begin recon_record[warp][slot]<=recon_saved;jump_record[warp][slot]<=recon_saved;mask_record[warp][slot]<=active_mask[warp];end
            if(slot==int'(write_successor[warp]))begin recon_record[warp][slot]<=recon_saved;jump_record[warp][slot]<=other_pc;mask_record[warp][slot]<=other_mask;end
          end
        end
        else if(join_jump[warp])begin read_position[warp]<=read_position[warp]-1'b1;write_position[warp]<=write_position[warp]-1'b1;end
      end
    end
  end

endmodule
