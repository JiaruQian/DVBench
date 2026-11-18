# Source Assembly Interface

Assembled module: `cdc_source_bundle`. The name is only an explicit test boundary and does not claim that an original system top level of the same name exists. All connections come from actual instances in the original TB.

|Port|Direction|Bit width|
|---|---|---|
|gray0_src_clk|input|1|
|gray0_src_in_bin|input|4|
|gray0_dest_clk|input|1|
|gray0_dest_out_bin|output|4|
|gray1_src_clk|input|1|
|gray1_src_in_bin|input|4|
|gray1_dest_clk|input|1|
|gray1_dest_out_bin|output|4|
|gray2_src_clk|input|1|
|gray2_src_in_bin|input|2|
|gray2_dest_clk|input|1|
|gray2_dest_out_bin|output|2|
|gray3_src_clk|input|1|
|gray3_src_in_bin|input|1|
|gray3_dest_clk|input|1|
|gray3_dest_out_bin|output|1|
|b2g_A|input|4|
|b2g_Z|output|4|
|g2b_A|input|4|
|g2b_Z|output|4|
|hclk|input|1|
|hrstn|input|1|
|sync_serial_i|input|1|
|sync_serial_o|output|1|
|spill_valid_i|input|1|
|spill_data_i|input|8|
|spill_ready_i|input|1|
|spill_ready_o|output|1|
|spill_valid_o|output|1|
|spill_data_o|output|8|
|flush_valid_i|input|1|
|flush_data_i|input|8|
|flush_ready_i|input|1|
|flush_flush_i|input|1|
|flush_ready_o|output|1|
|flush_valid_o|output|1|
|flush_data_o|output|8|
|bypass_valid_i|input|1|
|bypass_data_i|input|8|
|bypass_ready_i|input|1|
|bypass_ready_o|output|1|
|bypass_valid_o|output|1|
|bypass_data_o|output|8|
|hrst|input|1|
|debug_mode|input|2|
|debug_debug_wb_pc|input|32|
|debug_debug_wb_instr|input|32|
|debug_debug_wb_rf_wdata|input|32|
|debug_data|output|4|
|single0_src_in|input|1|
|hclk2|input|1|
|single0_dest_out|output|1|
|single1_src_in|input|1|
|single1_dest_out|output|1|
|sync_reset_src_rst|input|1|
|sync_reset_dest_rst|output|1|
|array0_src_in|input|4|
|array0_dest_out|output|4|
|array1_src_in|input|2|
|array1_dest_out|output|2|
|pulse0_src_pulse|input|1|
|pulse0_src_rst|input|1|
|pulse0_dest_rst|input|1|
|pulse0_dest_pulse|output|1|
|pulse1_src_pulse|input|1|
|pulse1_dest_pulse|output|1|
|async_reset0_src_arst|input|1|
|async_reset0_dest_arst|output|1|
|async_reset1_src_arst|input|1|
|async_reset1_dest_arst|output|1|


## Fixed Parameter Context

| Port prefix | Fixed parameters | Clock/reset |
| --- | --- | --- |
| gray0 | WIDTH=4, DEST_SYNC_FF=2, REG_OUTPUT=1 | gray0_src_clk/gray0_dest_clk, no reset |
| gray1 | WIDTH=4, DEST_SYNC_FF=4, REG_OUTPUT=0 | gray1_src_clk/gray1_dest_clk, no reset |
| gray2 | WIDTH=2, DEST_SYNC_FF=4, REG_OUTPUT=0 | gray2_src_clk/gray2_dest_clk, no reset |
| gray3 | WIDTH=1, DEST_SYNC_FF=2, REG_OUTPUT=0 | gray3_src_clk/gray3_dest_clk, no reset |
| b2g/g2b | N=4 | Purely combinational |
| sync | STAGES=2, ResetValue=0 | hclk, hrstn active-low asynchronous |
| spill/flush | T=8bit, Bypass=0 | hclk, hrstn active-low asynchronous |
| bypass | T=8bit, Bypass=1, flush fixed at 0 | Combinationally transparent |
| debug | No variable parameters | hclk, hrst active-high synchronous |
| single0/array0 | DEST_SYNC_FF=4, SRC_INPUT_REG=1, array0 WIDTH=4 | hclk source, hclk2 destination, no reset |
| single1/array1 | DEST_SYNC_FF=2, SRC_INPUT_REG=0, array1 WIDTH=2 | hclk source, hclk2 destination, no reset |
| sync_reset | DEST_SYNC_FF=4 | hclk2 destination |
| pulse0 | DEST_SYNC_FF=4, REG_OUTPUT=0, RST_USED=1 | hclk source, hclk2 destination, each with an independent active-high synchronous reset |
| pulse1 | DEST_SYNC_FF=2, REG_OUTPUT=1, RST_USED=0 | hclk source, hclk2 destination, both resets fixed at 0 |
| async_reset0 | DEST_SYNC_FF=4, RST_ACTIVE_HIGH=1 | hclk2 destination, src_arst active-high |
| async_reset1 | DEST_SYNC_FF=3, RST_ACTIVE_HIGH=0 | hclk2 destination, src_arst active-low |

The WIDTH=1 Gray context transfers each source-captured bit after two destination rising edges, with no output register; coincident edges use pre-edge capture history.
