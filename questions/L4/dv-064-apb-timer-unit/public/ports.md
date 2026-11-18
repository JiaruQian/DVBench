# Native ports and parameter

The DUT top is apb_timer_unit and the independent model is dvbench_model. Preserve parameter APB_ADDR_WIDTH=12 and every native port below. Other parameter values are outside this task.

| Port | Direction | Width |
| --- | --- | --- |
| HCLK | In | 1 |
| HRESETn | In | 1 |
| PADDR | In | 12 |
| PENABLE | In | 1 |
| PRDATA | Out | 32 |
| PREADY | Out | 1 |
| PSEL | In | 1 |
| PSLVERR | Out | 1 |
| PWDATA | In | 32 |
| PWRITE | In | 1 |
| busy_o | Out | 1 |
| dft_cg_enable_i | In | 1 |
| event_hi_i | In | 1 |
| event_lo_i | In | 1 |
| irq_hi_o | Out | 1 |
| irq_lo_o | Out | 1 |
| ref_clk_i | In | 1 |
| timer_val_lo_o | Out | 32 |

## Exact native index ranges

- `PADDR`: packed `[11:0]`
- `PRDATA`: packed `[31:0]`
- `PWDATA`: packed `[31:0]`
- `timer_val_lo_o`: packed `[31:0]`
