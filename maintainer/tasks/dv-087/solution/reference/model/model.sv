`timescale 1ns/1ps
module dvbench_model #(
  parameter [15:0] R_MAX_MM = 2000,
  parameter signed [15:0] TEMP_Q15_COLD = 4096,
  parameter signed [15:0] TEMP_Q15_HOT = 16384
)(
  input clk_100mhz, rst_sys,
  input [15:0] dist_mm,
  input dist_vld,
  input [15:0] theta_q15,
  input sweep_wrap,
  output reg pix_clk,
  output reg [9:0] hcount, vcount,
  output wire active_video, frame_tick,
  output reg [11:0] rgb_plot,
  output reg vga_hsync_n, vga_vsync_n,
  output reg [8:0] logo_x,
  output reg [7:0] logo_y,
  input [11:0] logo_rgb,
  input logo_buf_sel
);
  reg [1:0] source_reset;
  reg [1:0] pixel_reset = 3;
  integer half_count;
  reg [3:0] intensity [0:65535];
  integer clear_index;
  integer hit_phase;
  integer hit_address;
  integer queued_address;
  reg queued;
  integer decay_age;
  integer write_address;
  reg write_enable;
  reg [3:0] write_value;
  reg [3:0] system_read;
  integer decay_address;
  reg decay_write;
  reg [3:0] decay_value;
  integer port_address;
  integer next_address;
  integer scaled_distance;
  integer total;
  reg initializing;
  reg [1:0] ready_pipe;
  integer display_address;
  reg [3:0] display_read;
  integer screen_column;
  integer ring_index;
  reg plot_region;
  reg logo_region;
  reg [3:0] green;

  always @(posedge clk_100mhz or posedge rst_sys) begin
    if (rst_sys) source_reset <= 3;
    else source_reset <= {source_reset[0], 1'b0};
  end
  always @(posedge clk_100mhz) begin
    if (source_reset[1]) begin
      pix_clk <= 0;
      half_count <= 0;
    end else begin
      half_count <= 1 - half_count;
      if (half_count == 1) pix_clk <= ~pix_clk;
    end
  end
  always @(posedge pix_clk or posedge rst_sys) begin
    if (rst_sys) pixel_reset <= 3;
    else pixel_reset <= {pixel_reset[0], 1'b0};
  end

  always @(posedge clk_100mhz) begin
    port_address = initializing ? clear_index : (decay_age >= 0 ? decay_address : write_address);
    system_read <= intensity[port_address];
    if (initializing) intensity[port_address] <= 0;
    else if (decay_age >= 0) begin
      if (decay_write) intensity[port_address] <= decay_value;
    end else if (write_enable) intensity[port_address] <= write_value;
    if (rst_sys) begin
      initializing <= 1;
      clear_index <= 0;
    end else if (initializing) begin
      if (clear_index == 65535) initializing <= 0;
      else clear_index <= clear_index + 1;
    end
    if (rst_sys || initializing) begin
      hit_phase <= -1;
      hit_address <= 0;
      queued <= 0;
      queued_address <= 0;
      write_address <= 0;
      write_value <= 0;
      write_enable <= 0;
      decay_age <= -1;
      decay_address <= 0;
      decay_write <= 0;
      decay_value <= 0;
    end else begin
      scaled_distance = R_MAX_MM == 0 ? 0 : ((dist_mm > R_MAX_MM ? R_MAX_MM : dist_mm) * 255 + R_MAX_MM / 2) / R_MAX_MM;
      next_address = (255 - scaled_distance) * 256 + (theta_q15 >> 8);
      write_enable <= 0;
      if (dist_vld && (decay_age >= 0 || hit_phase >= 0)) begin
        queued <= 1;
        queued_address <= next_address;
      end
      if (hit_phase == -1) begin
        if (decay_age < 0 && (queued || dist_vld)) begin
          hit_address <= queued ? queued_address : next_address;
          write_address <= queued ? queued_address : next_address;
          hit_phase <= 0;
          if (queued) queued <= 0;
        end
      end else if (hit_phase == 0) begin
        write_address <= hit_address;
        hit_phase <= 1;
      end else begin
        write_address <= hit_address;
        total = system_read + 3;
        write_value <= total > 15 ? 15 : total;
        write_enable <= 1;
        hit_phase <= -1;
      end
      decay_write <= 0;
      if (decay_age < 0) begin
        if (sweep_wrap) begin
          decay_age <= 0;
          decay_address <= 0;
        end
      end else begin
        decay_address <= decay_age == 0 ? 0 : decay_age - 1;
        if (decay_age > 0) begin
          decay_write <= 1;
          decay_value <= system_read == 0 ? 0 : system_read - 1;
        end
        if (decay_age == 65536) decay_age <= -1;
        else decay_age <= decay_age + 1;
      end
    end
  end

  assign active_video = hcount < 640 && vcount < 480;
  assign frame_tick = hcount == 0 && vcount == 0 && active_video;
  always @(posedge pix_clk) begin
    display_read <= intensity[display_address];
    if (pixel_reset[1]) begin
      hcount <= 0;
      vcount <= 0;
      vga_hsync_n <= 1;
      vga_vsync_n <= 1;
      logo_x <= 0;
      logo_y <= 0;
      rgb_plot <= 0;
      display_address <= 0;
      ready_pipe <= 0;
    end else begin
      ready_pipe <= {ready_pipe[0], !initializing};
      hcount <= hcount == 799 ? 0 : hcount + 1;
      if (hcount == 799) vcount <= vcount == 524 ? 0 : vcount + 1;
      vga_hsync_n <= !(hcount >= 656 && hcount < 752);
      vga_vsync_n <= !(vcount >= 490 && vcount < 492);
      logo_region = active_video && hcount < 160 && vcount < 120;
      plot_region = hcount < 320 && vcount >= 120 && vcount <= 375;
      screen_column = (hcount * 4 / 5) & 255;
      logo_x <= logo_region ? hcount * 2 : 0;
      logo_y <= logo_region ? vcount * 2 : 0;
      display_address <= active_video && plot_region ? (vcount - 120) * 256 + screen_column : 0;
      green = ready_pipe[1] ? display_read : 0;
      rgb_plot <= 0;
      if (active_video) begin
        if (logo_region) rgb_plot <= logo_rgb;
        else if (plot_region) rgb_plot <= green == 0 ? 12'h333 : {4'h0, green, 4'h0};
        for (ring_index = 1; ring_index <= 3; ring_index = ring_index + 1)
          if (plot_region && vcount == 375 - (R_MAX_MM == 0 ? 0 : (R_MAX_MM / 4 * ring_index) * 255 / R_MAX_MM)) rgb_plot <= 12'h088;
        if (plot_region && (vcount == 375 || screen_column == 0)) rgb_plot <= 12'hfff;
        if (hcount >= 150 && hcount < 160 && vcount < 8) rgb_plot <= logo_buf_sel ? 12'h0f0 : 12'hf00;
      end
    end
  end
endmodule
