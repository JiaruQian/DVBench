module kb_uart_source_bundle(
input wire clk,
input wire rst_n,
input wire uart_rd_uart,
input wire uart_wr_uart,
input wire [7:0] uart_wr_data,
input wire uart_rx,
output wire uart_tx,
output wire [7:0] uart_rd_data,
output wire uart_rx_empty,
output wire uart_tx_full,
input wire kb_ps2d,
input wire kb_ps2c,
input wire kb_rd_fifo,
output wire [8:0] kb_rd_data,
output wire kb_fifo_empty,
output wire [7:0] ascii
);
uart #(.DBIT(8),.SB_TICK(16),.DVSR(4),.DVSR_WIDTH(2),.FIFO_W(2)) uart(.clk(clk),.rst_n(rst_n),.rd_uart(uart_rd_uart),.wr_uart(uart_wr_uart),.wr_data(uart_wr_data),.rx(uart_rx),.tx(uart_tx),.rd_data(uart_rd_data),.rx_empty(uart_rx_empty),.tx_full(uart_tx_full));
kb  kb(.clk(clk),.rst_n(rst_n),.ps2d(kb_ps2d),.ps2c(kb_ps2c),.rd_fifo(kb_rd_fifo),.rd_data(kb_rd_data),.fifo_empty(kb_fifo_empty));
ascii_conv  ascii_decoder(.rd_data(kb_rd_data),.ascii(ascii));
endmodule
