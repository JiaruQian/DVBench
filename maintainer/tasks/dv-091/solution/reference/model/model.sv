`timescale 1ns/1ps
module dvbench_model(
  input logic clk,
  input logic rst_n,
  input logic core_req_valid_i,
  output logic core_req_ready_o,
  input logic [2:0] core_req_instrid_i,
  input logic core_req_iswrite_i,
  input logic [23:0] core_req_tag_i,
  input logic [4:0] core_req_setidx_i,
  input logic [3:0] core_req_activemask_i,
  input logic [3:0] core_req_blockoffset_i,
  input logic [15:0] core_req_wordoffset1h_i,
  input logic [127:0] core_req_data_i,
  output logic core_rsp_valid_o,
  input logic core_rsp_ready_i,
  output logic core_rsp_iswrite_o,
  output logic [2:0] core_rsp_instrid_o,
  output logic [127:0] core_rsp_data_o,
  output logic [3:0] core_rsp_activemask_o
);
  typedef struct packed {
    logic [2:0] instruction;
    logic writing;
    logic [6:0] row;
    logic [3:0] lanes;
    logic [3:0] banks;
    logic [15:0] bytes;
    logic [127:0] words;
  } request_record;
  request_record accepted_request, executing_request;
  logic accepted_pulse, replaying;
  logic [3:0] remaining_lanes, remaining_banks;
  logic [15:0] remaining_bytes;
  logic first_read, first_write, second_read, second_write;
  logic response_writing;
  logic [2:0] response_instruction;
  logic [3:0] first_lanes, second_lanes;
  logic [3:0] first_routes, second_routes;
  logic [1:0] first_bank_enable;
  integer first_winner[0:1];
  logic [3:0] first_byte_mask[0:1];
  logic [31:0] memory_words[0:1][0:127];
  logic [31:0] memory_read[0:1], write_bypass[0:1], second_words[0:1];
  logic [1:0] bypass_active;
  logic [135:0] response_slots[0:3];
  logic [2:0] response_head, response_tail;
  logic [2:0] response_count;
  logic [3:0] selected_lanes, scheduling_lanes, scheduling_banks;
  logic [15:0] scheduling_bytes;
  logic next_replay;
  integer winners[0:1], lane_counts[0:1];
  logic [135:0] new_response;
  logic response_push, response_pop, read_now;
  logic [1:0] write_now;
  logic [31:0] write_words[0:1];

  always_comb begin
    scheduling_lanes = replaying ? remaining_lanes : accepted_request.lanes;
    scheduling_banks = replaying ? remaining_banks : accepted_request.banks;
    scheduling_bytes = replaying ? remaining_bytes : accepted_request.bytes;
    selected_lanes = 0;
    next_replay = 0;
    for (int bank_index = 0; bank_index < 2; bank_index++) begin
      winners[bank_index] = 0;
      lane_counts[bank_index] = 0;
      for (int lane_index = 0; lane_index < 4; lane_index++) begin
        if (scheduling_lanes[lane_index] && scheduling_banks[lane_index] == bank_index) begin
          if (lane_counts[bank_index] == 0) begin
            winners[bank_index] = lane_index;
            selected_lanes[lane_index] = 1;
          end
          lane_counts[bank_index]++;
        end
      end
      if ((lane_counts[bank_index] % 4) > 1) next_replay = 1;
      write_words[bank_index] = executing_request.words >> (32*first_winner[bank_index]);
      write_now[bank_index] = first_write && first_bank_enable[bank_index];
    end
    next_replay = next_replay && (accepted_pulse || replaying);
    response_count = response_tail - response_head;
    core_req_ready_o = !replaying && response_count != 1 && !first_write;
    core_rsp_valid_o = response_count != 0;
    {core_rsp_iswrite_o,core_rsp_instrid_o,core_rsp_activemask_o,core_rsp_data_o} = response_slots[response_head[1:0]];
    new_response = {response_writing,response_instruction,second_lanes,128'b0};
    for (int lane_index = 0; lane_index < 4; lane_index++) begin
      new_response[32*lane_index+:32] = second_words[second_routes[lane_index]];
    end
    response_push = (second_read || second_write) && (response_count != 4 || core_rsp_ready_i);
    response_pop = core_rsp_ready_i && response_count != 0;
    read_now = (accepted_pulse && !accepted_request.writing) || (first_read && replaying);
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      accepted_request <= '0;
      executing_request <= '0;
      accepted_pulse <= 0;
      replaying <= 0;
      remaining_lanes <= 0;
      remaining_banks <= 0;
      remaining_bytes <= 0;
      first_read <= 0;
      first_write <= 0;
      second_read <= 0;
      second_write <= 0;
      response_writing <= 0;
      response_instruction <= 0;
      first_lanes <= 0;
      second_lanes <= 0;
      first_routes <= 0;
      second_routes <= 0;
      first_bank_enable <= 0;
      bypass_active <= 0;
      response_head <= 0;
      response_tail <= 0;
      for (int bank_index = 0; bank_index < 2; bank_index++) begin
        first_winner[bank_index] <= 0;
        first_byte_mask[bank_index] <= 0;
        memory_read[bank_index] <= 0;
        write_bypass[bank_index] <= 0;
        second_words[bank_index] <= 0;
        for (int row_index = 0; row_index < 128; row_index++) memory_words[bank_index][row_index] <= 0;
      end
      for (int slot_index = 0; slot_index < 4; slot_index++) response_slots[slot_index] <= 0;
    end else begin
      accepted_pulse <= core_req_valid_i && core_req_ready_o;
      if (core_req_valid_i && core_req_ready_o) begin
        accepted_request.instruction <= core_req_instrid_i;
        accepted_request.writing <= core_req_iswrite_i;
        accepted_request.row <= {core_req_tag_i[1:0],core_req_setidx_i};
        accepted_request.lanes <= core_req_activemask_i;
        accepted_request.banks <= core_req_blockoffset_i;
        accepted_request.bytes <= core_req_wordoffset1h_i;
        accepted_request.words <= core_req_data_i;
      end
      if (accepted_pulse) executing_request <= accepted_request;
      first_read <= (accepted_pulse && !accepted_request.writing) || (first_read && replaying);
      first_write <= (accepted_pulse && accepted_request.writing) || (first_write && replaying);
      second_read <= first_read;
      second_write <= first_write;
      response_writing <= executing_request.writing;
      response_instruction <= executing_request.instruction;
      replaying <= next_replay;
      remaining_lanes <= scheduling_lanes & ~selected_lanes;
      remaining_banks <= scheduling_banks;
      remaining_bytes <= scheduling_bytes;
      first_lanes <= selected_lanes;
      second_lanes <= first_lanes;
      second_routes <= first_routes;
      for (int lane_index = 0; lane_index < 4; lane_index++) first_routes[lane_index] <= scheduling_lanes[lane_index] && scheduling_banks[lane_index];
      for (int bank_index = 0; bank_index < 2; bank_index++) begin
        first_winner[bank_index] <= winners[bank_index];
        first_bank_enable[bank_index] <= lane_counts[bank_index] != 0;
        first_byte_mask[bank_index] <= scheduling_bytes[4*winners[bank_index]+:4];
        write_bypass[bank_index] <= write_words[bank_index];
        bypass_active[bank_index] <= read_now && write_now[bank_index] && accepted_request.row == executing_request.row;
        if (read_now && !(write_now[bank_index] && accepted_request.row == executing_request.row)) memory_read[bank_index] <= memory_words[bank_index][accepted_request.row];
        if (write_now[bank_index]) begin
          for (int byte_index = 0; byte_index < 4; byte_index++) begin
            if (first_byte_mask[bank_index][byte_index]) memory_words[bank_index][executing_request.row][8*byte_index+:8] <= write_words[bank_index][8*byte_index+:8];
          end
        end
        second_words[bank_index] <= bypass_active[bank_index] ? write_bypass[bank_index] : memory_read[bank_index];
      end
      if (response_push) begin
        response_tail <= response_tail + 1;
        if (response_count != 4) response_slots[response_tail[1:0]] <= new_response;
      end
      if (response_pop) response_head <= response_head + 1;
    end
  end
endmodule
