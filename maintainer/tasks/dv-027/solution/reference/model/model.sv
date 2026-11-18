`timescale 1ns/1ps
module dvbench_model #(parameter BUFFER_SIZE=12)(
input logic  clk,
output logic [31:0] debug,
input logic  i_camera_reset,
input logic  i_clk_locked,
input logic  i_enable,
input logic  i_hsync,
input logic  i_image_debug_en,
input logic  i_memory_ready,
input logic  i_pix_clk,
input logic [7:0] i_pix_data,
input logic  i_reset_counts,
input logic  i_rfifo_activate,
input logic  i_rfifo_strobe,
input logic  i_vsync,
output logic  o_busy,
output logic  o_captured,
output logic  o_inactive,
output logic [31:0] o_pixel_count,
output logic [31:0] o_rfifo_data,
output logic  o_rfifo_ready,
output logic [23:0] o_rfifo_size,
output logic [31:0] o_row_count,
input logic  rst
);
  localparam integer DEPTH = 1 << BUFFER_SIZE;
  logic [31:0] words [0:2*DEPTH];
  logic [1:0] writable = 0, writer_bank;
  logic [23:0] bank_length [0:1];
  logic [1:0] published = 0, release_seen, published_seen, released = 0;
  logic [2:0] publish_history [0:1], release_history [0:1];
  logic [2:0] order_history;
  logic published_order, order_seen;
  logic write_wait = 1, read_wait = 1;
  integer write_warmup = 0, read_warmup = 0;
  wire fifo_reset = rst || !i_clk_locked;
  wire fifo_online = !write_wait && !read_wait;
  logic [BUFFER_SIZE-1:0] write_offset = 0, read_offset = 0;
  logic [1:0] collecting, prepared = 0, pending = 3, available = 0, consuming = 0;
  logic selected = 0, preferred = 0, prefetch_wait = 0;
  logic [23:0] lengths [0:1];
  logic delayed_read_strobe;
  logic [31:0] ram_output, retained_output = 0;
  logic [31:0] assembled, previous_bytes;
  logic [1:0] byte_position;
  logic pending_word, write_word;
  logic [23:0] line_words;
  logic capturing, pattern_phase, completion;
  logic completion_toggle;
  logic [2:0] completion_history, empty_history;
  logic empty_visible;
  logic [31:0] current_pixels, current_rows;
  wire empty_banks = bank_length[0] == 0 && bank_length[1] == 0 && writable == 3 && !write_word;
  assign published_order = published == 2;
  assign o_rfifo_data = delayed_read_strobe ? ram_output : retained_output;
  assign o_inactive = empty_visible;
  assign o_captured = completion_history[2] ^ completion_history[1];
  assign debug = {15'bz, o_busy, i_hsync, i_vsync, i_pix_data, write_word, collecting, writable, i_enable};
  initial begin
    lengths[0] = 0;
    lengths[1] = 0;
    o_rfifo_ready = 0;
  end
  always @(posedge i_pix_clk) begin
    if (collecting != 0 && write_word)
      words[{collecting == 2, write_offset}] <= assembled;
    if (fifo_reset) begin
      write_wait <= 1;
      write_warmup <= 0;
      writable <= 0;
      published <= 0;
      write_offset <= 0;
      bank_length[0] <= 0;
      bank_length[1] <= 0;
      release_seen <= 0;
      for (integer bank=0; bank<2; bank++) release_history[bank] <= 0;
      completion_toggle <= 0;
    end else begin
      if (write_wait && write_warmup < 4) write_warmup <= write_warmup + 1;
      else write_wait <= 0;
      for (integer bank=0; bank<2; bank++) begin
        release_history[bank] <= {release_history[bank][1:0], released[bank]};
        case (release_history[bank][2:1])
          0: release_seen[bank] <= 0;
          3: release_seen[bank] <= 1;
        endcase
        if (fifo_online) begin
          if (collecting[bank] && write_word) writable[bank] <= 0;
          if (!collecting[bank] && bank_length[bank] == 0 && release_seen[bank]) writable[bank] <= 1;
        end
        if (collecting[bank] && write_word) bank_length[bank] <= bank_length[bank] + 1;
        if (collecting == 0 && bank_length[bank] > 0) published[bank] <= 1;
        if (!release_seen[bank]) begin bank_length[bank] <= 0; published[bank] <= 0; end
      end
      if (collecting != 0 && write_word) write_offset <= write_offset + 1;
      if (collecting == 0) write_offset <= 0;
      if (completion) completion_toggle <= ~completion_toggle;
    end
    if (!i_camera_reset || !i_clk_locked) begin
      collecting <= 0;
      write_word <= 0;
      pending_word <= 0;
      assembled <= 0;
      previous_bytes <= 0;
      byte_position <= 0;
      line_words <= 0;
      capturing <= 0;
      pattern_phase <= 0;
      completion <= 0;
      o_busy <= 0;
    end else begin
      write_word <= pending_word;
      pending_word <= 0;
      completion <= 0;
      if (i_enable && !capturing && !i_vsync && collecting != 0 && i_memory_ready) begin
        capturing <= 1;
        pattern_phase <= ~pattern_phase;
      end else if (!i_vsync && !i_memory_ready) begin
        capturing <= 0;
        pattern_phase <= ~pattern_phase;
      end
      if (i_vsync) o_busy <= 1;
      else if (o_busy && empty_banks && capturing) begin
        o_busy <= 0;
        completion <= 1;
        capturing <= 0;
      end
      if (writable != 0 && collecting == 0) begin
        collecting <= writable[0] ? 1 : 2;
        byte_position <= 0;
        previous_bytes <= 0;
        line_words <= 0;
      end
      if (i_enable && collecting != 0 && capturing) begin
        if (i_hsync && i_vsync) begin
          case (byte_position)
            0: previous_bytes[23:16] <= i_pix_data;
            1: previous_bytes[15:8] <= i_pix_data;
            2: previous_bytes[7:0] <= i_pix_data;
          endcase
          byte_position <= byte_position + 1;
          if (byte_position == 3) begin
            assembled <= i_image_debug_en ? (pattern_phase ? (line_words == 0 ? 32'h001f001f : 32'h07d007d0) : (line_words == 0 ? 32'hffffffff : 32'hf800f800)) : {previous_bytes[23:0], i_pix_data};
            pending_word <= 1;
            line_words <= line_words + 1;
          end
        end else if (!pending_word && !write_word && line_words > 0) begin
          collecting <= 0;
          byte_position <= 0;
          line_words <= 0;
        end
      end
    end
    if (!i_camera_reset || !i_clk_locked) begin
      current_pixels <= 0;
      current_rows <= 0;
      o_pixel_count <= 0;
      o_row_count <= 0;
    end else begin
      if (i_reset_counts) begin o_pixel_count <= 0; o_row_count <= 0; end
      if (!i_vsync) begin
        if (current_rows > 0 && current_rows > o_row_count) o_row_count <= current_rows;
        current_rows <= 0;
      end
      if (!i_hsync) begin
        if (current_pixels > 0) begin o_pixel_count <= current_pixels; current_rows <= current_rows + 1; end
        current_pixels <= 0;
      end else current_pixels <= current_pixels + 1;
    end
  end
  always @(posedge clk) begin
    ram_output <= words[{selected, read_offset}];
    if (fifo_reset) begin
      read_wait <= 1;
      read_warmup <= 0;
      published_seen <= 0;
      order_seen <= 0;
      order_history <= 0;
      completion_history <= 0;
      empty_history <= 0;
      empty_visible <= 0;
      for (integer bank=0; bank<2; bank++) publish_history[bank] <= 0;
      selected <= 0;
      read_offset <= 0;
      released <= 3;
      o_rfifo_size <= 0;
      prepared <= 0;
      consuming <= 0;
      prefetch_wait <= 0;
      lengths[0] <= 0;
      lengths[1] <= 0;
      pending <= 3;
      available <= 0;
      preferred <= 0;
      retained_output <= 0;
      o_rfifo_ready <= 0;
    end else begin
      if (read_wait && read_warmup < 4) read_warmup <= read_warmup + 1;
      else read_wait <= 0;
      completion_history <= {completion_history[1:0], completion_toggle};
      empty_history <= {empty_history[1:0], empty_banks};
      case (empty_history[2:1])
        0: empty_visible <= 0;
        3: empty_visible <= 1;
      endcase
      order_history <= {order_history[1:0], published_order};
      case (order_history[2:1])
        0: order_seen <= 0;
        3: order_seen <= 1;
      endcase
      for (integer bank=0; bank<2; bank++) begin
        publish_history[bank] <= {publish_history[bank][1:0], published[bank]};
        case (publish_history[bank][2:1])
          0: published_seen[bank] <= 0;
          3: published_seen[bank] <= 1;
        endcase
      end
      delayed_read_strobe <= i_rfifo_strobe;
      if (!i_rfifo_activate && prepared == 0) begin
        if (consuming == 0) begin
          o_rfifo_size <= 0;
          read_offset <= 0;
          prefetch_wait <= 0;
          if (available != 0) begin
            if (available == 3) begin
              selected <= preferred;
              prepared <= preferred ? 2 : 1;
              preferred <= ~preferred;
              o_rfifo_size <= lengths[preferred];
            end else begin
              selected <= available[1];
              prepared <= available;
              preferred <= !available[1];
              o_rfifo_size <= lengths[available[1]];
            end
          end
        end else if (consuming[selected] && !available[selected]) begin
          consuming[selected] <= 0;
          released[selected] <= 1;
        end
      end else begin
        if (prepared != 0 && prefetch_wait) o_rfifo_ready <= 1;
        if (consuming != 0) begin o_rfifo_ready <= 0; available[selected] <= 0; end
        if (consuming == 0 && prefetch_wait) begin
          retained_output <= ram_output;
          read_offset <= read_offset + 1;
          consuming <= prepared;
          prepared <= 0;
        end else if (!prefetch_wait) prefetch_wait <= 1;
        if (i_rfifo_strobe && read_offset < lengths[selected] + 1) begin retained_output <= ram_output; read_offset <= read_offset + 1; end
        if (delayed_read_strobe && !i_rfifo_strobe) retained_output <= ram_output;
      end
      for (integer bank=0; bank<2; bank++) begin
        if (!published_seen[bank] && !available[bank] && !consuming[bank]) pending[bank] <= 1;
        if (published_seen != 0) begin
          if (pending == 3 && published_seen == 3 && bank_length[0] > 0 && bank_length[1] > 0) preferred <= order_seen;
          if (pending[bank] && published_seen[bank] && bank_length[bank] > 0) begin
            if (consuming == 0 && !published_seen[1-bank]) preferred <= bank;
            lengths[bank] <= bank_length[bank];
            available[bank] <= 1;
            pending[bank] <= 0;
            released[bank] <= 0;
          end
        end
      end
    end
  end

endmodule
