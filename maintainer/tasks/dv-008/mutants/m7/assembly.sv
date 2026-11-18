module cdc_source_bundle(
input wire gray0_src_clk,
input wire [3:0] gray0_src_in_bin,
input wire gray0_dest_clk,
output wire [3:0] gray0_dest_out_bin,
input wire gray1_src_clk,
input wire [3:0] gray1_src_in_bin,
input wire gray1_dest_clk,
output wire [3:0] gray1_dest_out_bin,
input wire gray2_src_clk,
input wire [1:0] gray2_src_in_bin,
input wire gray2_dest_clk,
output wire [1:0] gray2_dest_out_bin,
input wire gray3_src_clk,
input wire gray3_src_in_bin,
input wire gray3_dest_clk,
output wire gray3_dest_out_bin,
input wire [3:0] b2g_A,
output wire [3:0] b2g_Z,
input wire [3:0] g2b_A,
output wire [3:0] g2b_Z,
input wire hclk,
input wire hrstn,
input wire sync_serial_i,
output wire sync_serial_o,
input wire spill_valid_i,
input wire [7:0] spill_data_i,
input wire spill_ready_i,
output wire spill_ready_o,
output wire spill_valid_o,
output wire [7:0] spill_data_o,
input wire flush_valid_i,
input wire [7:0] flush_data_i,
input wire flush_ready_i,
input wire flush_flush_i,
output wire flush_ready_o,
output wire flush_valid_o,
output wire [7:0] flush_data_o,
input wire bypass_valid_i,
input wire [7:0] bypass_data_i,
input wire bypass_ready_i,
output wire bypass_ready_o,
output wire bypass_valid_o,
output wire [7:0] bypass_data_o,
input wire hrst,
input wire [1:0] debug_mode,
input wire [31:0] debug_debug_wb_pc,
input wire [31:0] debug_debug_wb_instr,
input wire [31:0] debug_debug_wb_rf_wdata,
output wire [3:0] debug_data,
input wire single0_src_in,
input wire hclk2,
output wire single0_dest_out,
input wire single1_src_in,
output wire single1_dest_out,
input wire sync_reset_src_rst,
output wire sync_reset_dest_rst,
input wire [3:0] array0_src_in,
output wire [3:0] array0_dest_out,
input wire [1:0] array1_src_in,
output wire [1:0] array1_dest_out,
input wire pulse0_src_pulse,
input wire pulse0_src_rst,
input wire pulse0_dest_rst,
output wire pulse0_dest_pulse,
input wire pulse1_src_pulse,
output wire pulse1_dest_pulse,
input wire async_reset0_src_arst,
output wire async_reset0_dest_arst,
input wire async_reset1_src_arst,
output wire async_reset1_dest_arst
);
stolen_cdc_gray #(.WIDTH(4),.DEST_SYNC_FF(2),.REG_OUTPUT(1)) gray0(.src_clk(gray0_src_clk),.src_in_bin(gray0_src_in_bin),.dest_clk(gray0_dest_clk),.dest_out_bin(gray0_dest_out_bin));
stolen_cdc_gray #(.WIDTH(4),.DEST_SYNC_FF(4),.REG_OUTPUT(0)) gray1(.src_clk(gray1_src_clk),.src_in_bin(gray1_src_in_bin),.dest_clk(gray1_dest_clk),.dest_out_bin(gray1_dest_out_bin));
stolen_cdc_gray #(.WIDTH(2),.DEST_SYNC_FF(4),.REG_OUTPUT(0)) gray2(.src_clk(gray2_src_clk),.src_in_bin(gray2_src_in_bin),.dest_clk(gray2_dest_clk),.dest_out_bin(gray2_dest_out_bin));
stolen_cdc_gray #(.WIDTH(1),.DEST_SYNC_FF(2),.REG_OUTPUT(0)) gray3(.src_clk(gray3_src_clk),.src_in_bin(gray3_src_in_bin),.dest_clk(gray3_dest_clk),.dest_out_bin(gray3_dest_out_bin));
binary_to_gray #(.N(4)) b2g(.A(b2g_A),.Z(b2g_Z));
gray_to_binary #(.N(4)) g2b(.A(g2b_A),.Z(g2b_Z));
sync #(.STAGES(2),.ResetValue(1'b0)) sync(.clk_i(hclk),.rst_ni(hrstn),.serial_i(sync_serial_i),.serial_o(sync_serial_o));
spill_register #(.T(logic[7:0])) spill(.clk_i(hclk),.rst_ni(hrstn),.valid_i(spill_valid_i),.data_i(spill_data_i),.ready_i(spill_ready_i),.ready_o(spill_ready_o),.valid_o(spill_valid_o),.data_o(spill_data_o));
spill_register_flushable #(.T(logic[7:0])) flush(.clk_i(hclk),.rst_ni(hrstn),.valid_i(flush_valid_i),.data_i(flush_data_i),.ready_i(flush_ready_i),.flush_i(flush_flush_i),.ready_o(flush_ready_o),.valid_o(flush_valid_o),.data_o(flush_data_o));
spill_register_flushable #(.T(logic[7:0]),.Bypass(1'b1)) bypass(.clk_i(hclk),.rst_ni(hrstn),.valid_i(bypass_valid_i),.data_i(bypass_data_i),.ready_i(bypass_ready_i),.flush_i(1'b0),.ready_o(bypass_ready_o),.valid_o(bypass_valid_o),.data_o(bypass_data_o));
debug_output  debug(.clk(hclk),.rst(hrst),.mode(debug_mode),.debug_wb_pc(debug_debug_wb_pc),.debug_wb_instr(debug_debug_wb_instr),.debug_wb_rf_wdata(debug_debug_wb_rf_wdata),.data(debug_data));
stolen_cdc_single #(.DEST_SYNC_FF(4),.SRC_INPUT_REG(1)) single0(.src_clk(hclk),.src_in(single0_src_in),.dest_clk(hclk2),.dest_out(single0_dest_out));
stolen_cdc_single #(.DEST_SYNC_FF(2),.SRC_INPUT_REG(0)) single1(.src_clk(hclk),.src_in(single1_src_in),.dest_clk(hclk2),.dest_out(single1_dest_out));
stolen_cdc_sync_rst #(.DEST_SYNC_FF(4)) sync_reset(.src_rst(sync_reset_src_rst),.dest_clk(hclk2),.dest_rst(sync_reset_dest_rst));
stolen_cdc_array_single #(.WIDTH(4),.DEST_SYNC_FF(4),.SRC_INPUT_REG(1)) array0(.src_clk(hclk),.src_in(array0_src_in),.dest_clk(hclk2),.dest_out(array0_dest_out));
stolen_cdc_array_single #(.WIDTH(2),.DEST_SYNC_FF(2),.SRC_INPUT_REG(0)) array1(.src_clk(hclk),.src_in(array1_src_in),.dest_clk(hclk2),.dest_out(array1_dest_out));
stolen_cdc_pulse #(.DEST_SYNC_FF(4),.REG_OUTPUT(0),.RST_USED(1)) pulse0(.src_clk(hclk),.src_pulse(pulse0_src_pulse),.dest_clk(hclk2),.src_rst(pulse0_src_rst),.dest_rst(pulse0_dest_rst),.dest_pulse(pulse0_dest_pulse));
stolen_cdc_pulse #(.DEST_SYNC_FF(2),.REG_OUTPUT(1),.RST_USED(0)) pulse1(.src_clk(hclk),.src_pulse(pulse1_src_pulse),.dest_clk(hclk2),.src_rst(1'b0),.dest_rst(1'b0),.dest_pulse(pulse1_dest_pulse));
stolen_cdc_async_rst #(.DEST_SYNC_FF(4),.RST_ACTIVE_HIGH(1)) async_reset0(.src_arst(async_reset0_src_arst),.dest_clk(hclk2),.dest_arst(async_reset0_dest_arst));
stolen_cdc_async_rst #(.DEST_SYNC_FF(3),.RST_ACTIVE_HIGH(0)) async_reset1(.src_arst(async_reset1_src_arst),.dest_clk(hclk2),.dest_arst(async_reset1_dest_arst));
endmodule
