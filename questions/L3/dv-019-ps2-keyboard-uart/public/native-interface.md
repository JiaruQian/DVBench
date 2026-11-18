# Native Port and Parameter Contract

Top-level module: `kb_uart_source_bundle`. All multi-bit ports are in descending order `[width-1:0]`; there are no unlisted inout ports. The fixed assembly boundary does not hide connection choices.

| Port | Direction | Range |
| --- | --- | --- |
| ascii | output | [7:0] |
| clk | input | [0:0] |
| kb_fifo_empty | output | [0:0] |
| kb_ps2c | input | [0:0] |
| kb_ps2d | input | [0:0] |
| kb_rd_data | output | [8:0] |
| kb_rd_fifo | input | [0:0] |
| rst_n | input | [0:0] |
| uart_rd_data | output | [7:0] |
| uart_rd_uart | input | [0:0] |
| uart_rx | input | [0:0] |
| uart_rx_empty | output | [0:0] |
| uart_tx | output | [0:0] |
| uart_tx_full | output | [0:0] |
| uart_wr_data | input | [7:0] |
| uart_wr_uart | input | [0:0] |

See [ports.md](ports.md) for additional fixed context parameters and connections.
