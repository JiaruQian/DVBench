`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import bench_pkg::*;
bench_if vif();
kb_uart_source_bundle dut(.ascii(vif.ascii),.clk(vif.clk),.kb_fifo_empty(vif.kb_fifo_empty),.kb_ps2c(vif.kb_ps2c),.kb_ps2d(vif.kb_ps2d),.kb_rd_data(vif.kb_rd_data),.kb_rd_fifo(vif.kb_rd_fifo),.rst_n(vif.rst_n),.uart_rd_data(vif.uart_rd_data),.uart_rd_uart(vif.uart_rd_uart),.uart_rx(vif.uart_rx),.uart_rx_empty(vif.uart_rx_empty),.uart_tx(vif.uart_tx),.uart_tx_full(vif.uart_tx_full),.uart_wr_data(vif.uart_wr_data),.uart_wr_uart(vif.uart_wr_uart));
dvbench_model predictor(.ascii(vif.pred_ascii),.clk(vif.clk),.kb_fifo_empty(vif.pred_kb_fifo_empty),.kb_ps2c(vif.kb_ps2c),.kb_ps2d(vif.kb_ps2d),.kb_rd_data(vif.pred_kb_rd_data),.kb_rd_fifo(vif.kb_rd_fifo),.rst_n(vif.rst_n),.uart_rd_data(vif.pred_uart_rd_data),.uart_rd_uart(vif.uart_rd_uart),.uart_rx(vif.uart_rx),.uart_rx_empty(vif.pred_uart_rx_empty),.uart_tx(vif.pred_uart_tx),.uart_tx_full(vif.pred_uart_tx_full),.uart_wr_data(vif.uart_wr_data),.uart_wr_uart(vif.uart_wr_uart));
initial begin uvm_config_db#(virtual bench_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
