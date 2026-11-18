# Native ports

The DUT is NV_NVDLA_CDMA_cvt and independent model is dvbench_model with identical native ports. The fixed configuration and clock/reset domain are stated in the behavioral contract.

| Port | Direction | Bits |
| --- | --- | --- |
| cdma2buf_dat_wr_addr | Out | 17 |
| cdma2buf_dat_wr_data | Out | 64 |
| cdma2buf_dat_wr_en | Out | 1 |
| dc2cvt_dat_wr_addr | In | 17 |
| dc2cvt_dat_wr_data | In | 64 |
| dc2cvt_dat_wr_en | In | 1 |
| dc2cvt_dat_wr_info_pd | In | 12 |
| dp2reg_dat_flush_done | Out | 1 |
| dp2reg_done | In | 1 |
| dp2reg_inf_data_num | Out | 32 |
| dp2reg_nan_data_num | Out | 32 |
| img2cvt_dat_wr_addr | In | 17 |
| img2cvt_dat_wr_data | In | 64 |
| img2cvt_dat_wr_en | In | 1 |
| img2cvt_dat_wr_info_pd | In | 12 |
| img2cvt_dat_wr_pad_mask | In | 8 |
| img2cvt_mn_wr_data | In | 128 |
| nvdla_core_clk | In | 1 |
| nvdla_core_ng_clk | In | 1 |
| nvdla_core_rstn | In | 1 |
| nvdla_hls_clk | In | 1 |
| reg2dp_cvt_en | In | 1 |
| reg2dp_cvt_offset | In | 16 |
| reg2dp_cvt_scale | In | 16 |
| reg2dp_cvt_truncate | In | 6 |
| reg2dp_in_precision | In | 2 |
| reg2dp_nan_to_zero | In | 1 |
| reg2dp_op_en | In | 1 |
| reg2dp_pad_value | In | 16 |
| reg2dp_proc_precision | In | 2 |
| slcg_hls_en | Out | 1 |

## Exact native index ranges

- `cdma2buf_dat_wr_addr`: packed `[16:0]`
- `cdma2buf_dat_wr_data`: packed `[63:0]`
- `dc2cvt_dat_wr_addr`: packed `[16:0]`
- `dc2cvt_dat_wr_data`: packed `[63:0]`
- `dc2cvt_dat_wr_info_pd`: packed `[11:0]`
- `dp2reg_inf_data_num`: packed `[31:0]`
- `dp2reg_nan_data_num`: packed `[31:0]`
- `img2cvt_dat_wr_addr`: packed `[16:0]`
- `img2cvt_dat_wr_data`: packed `[63:0]`
- `img2cvt_dat_wr_info_pd`: packed `[11:0]`
- `img2cvt_dat_wr_pad_mask`: packed `[7:0]`
- `img2cvt_mn_wr_data`: packed `[127:0]`
- `reg2dp_cvt_offset`: packed `[15:0]`
- `reg2dp_cvt_scale`: packed `[15:0]`
- `reg2dp_cvt_truncate`: packed `[5:0]`
- `reg2dp_in_precision`: packed `[1:0]`
- `reg2dp_pad_value`: packed `[15:0]`
- `reg2dp_proc_precision`: packed `[1:0]`
