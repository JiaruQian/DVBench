# Native Interface

Top level `vga_range_plot_top`; independent model top level `dvbench_model`.

|Port|Direction|Bit Width|Packed Indices|
|---|---|---:|---|
|active_video|Out|1||
|clk_100mhz|In|1||
|dist_mm|In|16|[15:0]|
|dist_vld|In|1||
|frame_tick|Out|1||
|hcount|Out|10|[9:0]|
|logo_buf_sel|In|1||
|logo_rgb|In|12|[11:0]|
|logo_x|Out|9|[8:0]|
|logo_y|Out|8|[7:0]|
|pix_clk|Out|1||
|rgb_plot|Out|12|[11:0]|
|rst_sys|In|1||
|sweep_wrap|In|1||
|theta_q15|In|16|[15:0]|
|vcount|Out|10|[9:0]|
|vga_hsync_n|Out|1||
|vga_vsync_n|Out|1||

Parameter defaults: {"R_MAX_MM": "16'd2000", "TEMP_Q15_COLD": "16'sd4096", "TEMP_Q15_HOT": "16'sd16384"}. See spec.md for legal parameter domains and semantics; do not change port widths or directions.
