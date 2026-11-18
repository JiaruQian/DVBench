`timescale 1ns/1ps
module native_replay;
wire [31:0] debug;
wire  o_busy;
wire  o_captured;
wire  o_inactive;
wire [31:0] o_pixel_count;
wire [31:0] o_rfifo_data;
wire  o_rfifo_ready;
wire [23:0] o_rfifo_size;
wire [31:0] o_row_count;
integer system_halfperiod=5,pixel_halfperiod=7;
integer time_index=0, scenario=0, seed=1, pixel_count;
logic  clk;
logic  i_camera_reset;
logic  i_clk_locked;
logic  i_enable;
logic  i_hsync;
logic  i_image_debug_en;
logic  i_memory_ready;
logic  i_pix_clk;
logic [7:0] i_pix_data;
logic  i_reset_counts;
logic  i_rfifo_activate;
logic  i_rfifo_strobe;
logic  i_vsync;
logic  rst;
task advance(integer duration);
  repeat(duration) begin
    time_index++;
    if (time_index%system_halfperiod==0) clk=~clk; if (time_index%pixel_halfperiod==0) i_pix_clk=~i_pix_clk;
    send_event();
  end
endtask
`ifdef REPLAY_MODEL
dvbench_model
`else
sf_camera_reader
`endif
 unit(.clk(clk),.debug(debug),.i_camera_reset(i_camera_reset),.i_clk_locked(i_clk_locked),.i_enable(i_enable),.i_hsync(i_hsync),.i_image_debug_en(i_image_debug_en),.i_memory_ready(i_memory_ready),.i_pix_clk(i_pix_clk),.i_pix_data(i_pix_data),.i_reset_counts(i_reset_counts),.i_rfifo_activate(i_rfifo_activate),.i_rfifo_strobe(i_rfifo_strobe),.i_vsync(i_vsync),.o_busy(o_busy),.o_captured(o_captured),.o_inactive(o_inactive),.o_pixel_count(o_pixel_count),.o_rfifo_data(o_rfifo_data),.o_rfifo_ready(o_rfifo_ready),.o_rfifo_size(o_rfifo_size),.o_row_count(o_row_count),.rst(rst));
task send_event(); #0.1; $display("TRACE %h %h",{clk,i_camera_reset,i_clk_locked,i_enable,i_hsync,i_image_debug_en,i_memory_ready,i_pix_clk,i_pix_data,i_reset_counts,i_rfifo_activate,i_rfifo_strobe,i_vsync,rst},{debug,o_busy,o_captured,o_inactive,o_pixel_count,o_rfifo_data,o_rfifo_ready,o_rfifo_size,o_row_count}); #0.9; endtask
initial begin
clk='0;
i_camera_reset='0;
i_clk_locked='0;
i_enable='0;
i_hsync='0;
i_image_debug_en='0;
i_memory_ready='0;
i_pix_clk='0;
i_pix_data='0;
i_reset_counts='0;
i_rfifo_activate='0;
i_rfifo_strobe='0;
i_vsync='0;
rst='0;
if($value$plusargs("ntb_random_seed=%d",seed)) begin end
      rst=1; i_camera_reset=0; i_clk_locked=0;
      advance(280);
      rst=0; i_camera_reset=1; i_clk_locked=1;
      i_enable=0; i_memory_ready=0; i_vsync=1; i_hsync=1;
      scenario=19;
      advance(14*65537);
      i_hsync=0; advance(28);
      rst=1; i_camera_reset=0; i_clk_locked=0;
      i_vsync=0; i_hsync=0; advance(280);
      rst=0; i_camera_reset=1; i_clk_locked=1; i_enable=1; i_memory_ready=1;
      advance(700);
      for (integer run_index=0; run_index<12; run_index++) begin
        scenario=run_index;
        i_image_debug_en=(run_index%3 == 1);
        if (run_index%4 == 0) begin
          i_memory_ready=0; advance(14*(run_index+1)); i_memory_ready=1; advance(280);
        end
        i_vsync=1;
        for (integer line_index=0; line_index<4; line_index++) begin
          pixel_count = run_index == 8 ? 16384 : run_index == 9 ? 16404 : ((run_index*7+line_index*3)%31)+1;
          for (integer pixel_index=0; pixel_index<pixel_count; pixel_index++) begin
            while (i_pix_clk !== 0) advance(1);
            i_hsync=1;
            i_pix_data=(pixel_index*29+seed*17+line_index*53+run_index)%256;
            advance(14);
          end
          i_hsync=0; advance(280);
          if (line_index%2 == 1 || run_index%2 == 0) begin
            i_rfifo_activate=1; advance(100);
            for (integer read_index=0; read_index<(pixel_count/4)+8; read_index++) begin
              i_rfifo_strobe=1; advance(10);
              if (read_index%3 != 1) begin i_rfifo_strobe=0; advance(20); end
            end
            i_rfifo_strobe=0; advance(50); i_rfifo_activate=0; advance(700);
          end
        end
        i_vsync=0; i_hsync=0;
        advance(700);
        i_rfifo_activate=1; i_rfifo_strobe=1; advance(100); i_rfifo_strobe=0; advance(30); i_rfifo_activate=0; advance(700);
        i_reset_counts=1; advance(28); i_reset_counts=0;
        if (run_index == 3) begin rst=1; advance(140); rst=0; advance(700); end
        if (run_index == 5) begin i_camera_reset=0; advance(140); i_camera_reset=1; advance(700); end
        if (run_index == 7) begin i_clk_locked=0; advance(280); i_clk_locked=1; advance(700); end
        i_enable=0; i_vsync=1; i_hsync=1; advance(70); i_hsync=0; i_vsync=0; advance(280); i_enable=1;
      end


      for(integer boundary_index=0;boundary_index<7;boundary_index++) begin
        scenario=12+boundary_index;
        system_halfperiod=4+boundary_index%3;pixel_halfperiod=6+boundary_index%4;
        rst=1; i_camera_reset=0; i_clk_locked=0; i_rfifo_activate=0; i_rfifo_strobe=0;
        i_hsync=0; i_vsync=0; advance(280);
        rst=0; i_camera_reset=1; i_clk_locked=1; i_memory_ready=1; i_enable=1; advance(700);
        i_vsync=1;
        for(integer line_index=0;line_index<3;line_index++) begin
          pixel_count=boundary_index==0 ? line_index+1 : boundary_index==1 ? 4 : boundary_index==2 ? 5 : boundary_index==3 ? 7 : boundary_index==4 ? 16380 : boundary_index==5 ? 16384 : 16388;
          for(integer pixel_index=0;pixel_index<pixel_count;pixel_index++) begin
            while(i_pix_clk!==0) advance(1);
            i_hsync=1; i_pix_data=(pixel_index*37+seed*11+line_index*79)%256; advance(2*pixel_halfperiod);
            if(pixel_index==2 && boundary_index==2) begin i_enable=0;advance(70);i_enable=1;end
          end
          i_hsync=0;advance(280);
        end
        i_vsync=0;advance(700);
        for(integer bank_index=0;bank_index<2;bank_index++) begin
          i_rfifo_activate=1;advance(100);
          for(integer read_index=0;read_index<4104;read_index++) begin
            i_rfifo_strobe=1;advance(2*system_halfperiod);
            if(read_index%7==0) begin i_rfifo_strobe=0;advance(30);end
          end
          i_rfifo_strobe=0;advance(50);i_rfifo_activate=0;advance(700);
        end
        i_vsync=1;i_hsync=1;advance(112);i_hsync=0;advance(280);i_vsync=0;advance(700);
        i_reset_counts=1;i_hsync=1;advance(28);i_hsync=0;advance(14);i_reset_counts=0;advance(280);
      end
$display("NATIVE_PROBE_COMPLETED"); $finish; end
endmodule
