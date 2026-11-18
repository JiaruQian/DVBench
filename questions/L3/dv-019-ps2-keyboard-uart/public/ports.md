# Source Assembly Interface

Assembly module: `kb_uart_source_bundle`. The name is only an explicit test boundary and does not claim that an original system top level with the same name exists. All connections come from actual instances in the original TB.

|Port|Direction|Bit width|
|---|---|---|
|clk|input|1|
|rst_n|input|1|
|uart_rd_uart|input|1|
|uart_wr_uart|input|1|
|uart_wr_data|input|8|
|uart_rx|input|1|
|uart_tx|output|1|
|uart_rd_data|output|8|
|uart_rx_empty|output|1|
|uart_tx_full|output|1|
|kb_ps2d|input|1|
|kb_ps2c|input|1|
|kb_rd_fifo|input|1|
|kb_rd_data|output|9|
|kb_fifo_empty|output|1|
|ascii|output|8|

## Fixed Parameter Context

UART: DBIT=8, SB_TICK=16, DVSR=4, DVSR_WIDTH=2, FIFO_W=2; TX/RX each have depth 4. The keyboard queue has width 9 and depth 4. clk/rst_n connect to both the UART and keyboard; the ascii input connects directly to kb_rd_data. All remaining prefixed ports connect one-to-one to the corresponding functions with the same names; there is no automatic forwarding from the keyboard to the UART.
