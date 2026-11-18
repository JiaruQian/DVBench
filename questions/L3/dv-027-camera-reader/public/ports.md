# Native Interface

Fixed top: `sf_camera_reader`. Parameters: {"BUFFER_SIZE": "12"}. This parameter version only.

|Port|Direction|Index|Bit width|
|---|---|---|---:|
|clk|In||1|
|debug|Out|[31:0]|32|
|i_camera_reset|In||1|
|i_clk_locked|In||1|
|i_enable|In||1|
|i_hsync|In||1|
|i_image_debug_en|In||1|
|i_memory_ready|In||1|
|i_pix_clk|In||1|
|i_pix_data|In|[7:0]|8|
|i_reset_counts|In||1|
|i_rfifo_activate|In||1|
|i_rfifo_strobe|In||1|
|i_vsync|In||1|
|o_busy|Out||1|
|o_captured|Out||1|
|o_inactive|Out||1|
|o_pixel_count|Out|[31:0]|32|
|o_rfifo_data|Out|[31:0]|32|
|o_rfifo_ready|Out||1|
|o_rfifo_size|Out|[23:0]|24|
|o_row_count|Out|[31:0]|32|
|rst|In||1|
