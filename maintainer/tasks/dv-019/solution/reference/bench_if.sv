`timescale 1ns/1ps
interface bench_if;
event sampled;
bit stop_requested=0;
bit keyboard_transition=0;
integer diagnostics=0;
logic [7:0] ascii;
logic [7:0] pred_ascii;
logic clk=0;
logic kb_fifo_empty;
logic pred_kb_fifo_empty;
logic kb_ps2c=0;
logic kb_ps2d=0;
logic [8:0] kb_rd_data;
logic [8:0] pred_kb_rd_data;
logic kb_rd_fifo=0;
logic rst_n=0;
logic [7:0] uart_rd_data;
logic [7:0] pred_uart_rd_data;
logic uart_rd_uart=0;
logic uart_rx=0;
logic uart_rx_empty;
logic pred_uart_rx_empty;
logic uart_tx;
logic pred_uart_tx;
logic uart_tx_full;
logic pred_uart_tx_full;
logic [7:0] uart_wr_data=0;
logic uart_wr_uart=0;
logic [28:0] actual,predicted;
task sample();
actual={ascii,kb_fifo_empty,kb_rd_data,uart_rd_data,uart_rx_empty,uart_tx,uart_tx_full};
predicted={pred_ascii,pred_kb_fifo_empty,pred_kb_rd_data,pred_uart_rd_data,pred_uart_rx_empty,pred_uart_tx,pred_uart_tx_full};
if((pred_kb_fifo_empty && kb_fifo_empty) || keyboard_transition) begin actual[21+:8]=0;predicted[21+:8]=0;end
if(keyboard_transition) begin actual[20]=0;predicted[20]=0;end
if((pred_kb_fifo_empty && kb_fifo_empty) || keyboard_transition) begin actual[11+:9]=0;predicted[11+:9]=0;end
if((pred_uart_rx_empty && uart_rx_empty)) begin actual[3+:8]=0;predicted[3+:8]=0;end
if(actual!==predicted && diagnostics<20) begin
diagnostics++;
$display("INPUT_STATE %h",{clk,kb_ps2c,kb_ps2d,kb_rd_fifo,rst_n,uart_rd_uart,uart_rx,uart_wr_data,uart_wr_uart});
if(ascii!==pred_ascii) $display("PORT_DIFF ascii actual=%h expected=%h",ascii,pred_ascii);
if(kb_fifo_empty!==pred_kb_fifo_empty) $display("PORT_DIFF kb_fifo_empty actual=%h expected=%h",kb_fifo_empty,pred_kb_fifo_empty);
if(kb_rd_data!==pred_kb_rd_data) $display("PORT_DIFF kb_rd_data actual=%h expected=%h",kb_rd_data,pred_kb_rd_data);
if(uart_rd_data!==pred_uart_rd_data) $display("PORT_DIFF uart_rd_data actual=%h expected=%h",uart_rd_data,pred_uart_rd_data);
if(uart_rx_empty!==pred_uart_rx_empty) $display("PORT_DIFF uart_rx_empty actual=%h expected=%h",uart_rx_empty,pred_uart_rx_empty);
if(uart_tx!==pred_uart_tx) $display("PORT_DIFF uart_tx actual=%h expected=%h",uart_tx,pred_uart_tx);
if(uart_tx_full!==pred_uart_tx_full) $display("PORT_DIFF uart_tx_full actual=%h expected=%h",uart_tx_full,pred_uart_tx_full);
end
->sampled;
endtask
task cycles(input integer count);repeat(count) begin #10;clk=1;#2;sample();#6;sample();#2;clk=0;end endtask
task serial_frame(input logic[7:0] value,input bit stop_value=1);uart_rx=0;cycles(64);for(integer bit_index=0;bit_index<8;bit_index++) begin uart_rx=value[bit_index];cycles(64);end uart_rx=stop_value;cycles(64);uart_rx=1;cycles(32);endtask
task keyboard_frame(input logic[7:0] value,input bit bad_parity=0,input bit bad_start=0,input bit bad_stop=0);logic [10:0] frame;frame={!bad_stop,(~^value)^bad_parity,value,bad_start};for(integer bit_index=0;bit_index<11;bit_index++) begin kb_ps2d=frame[bit_index];kb_ps2c=1;cycles(16);kb_ps2c=0;if(bit_index==10) keyboard_transition=1;cycles(16);keyboard_transition=0;end kb_ps2c=1;cycles(20);endtask
task read_uart();uart_rd_uart=1;cycles(1);uart_rd_uart=0;cycles(1);endtask
task read_keyboard();kb_rd_fifo=1;cycles(1);kb_rd_fifo=0;cycles(1);endtask
`include "timing_witnesses.svh"
task stimulate();
integer selected_seed;
selected_seed=1;void'($value$plusargs("ntb_random_seed=%d",selected_seed));
void'($urandom(selected_seed));
uart_rx=1;kb_ps2d=1;kb_ps2c=1;rst_n=0;cycles(3);rst_n=1;cycles(20);
for(integer value=0;value<256;value++) begin
uart_wr_data=value;uart_wr_uart=1;cycles(1);uart_wr_uart=0;
serial_frame(value);read_uart();cycles(16);
if(stop_requested && value>1) break;
end
for(integer index=0;index<8;index++) begin uart_wr_data=$urandom;uart_wr_uart=1;cycles(1);uart_wr_uart=0;cycles(1);end
cycles(3000);
for(integer index=0;index<6;index++) serial_frame(8'h80+index);
repeat(7) read_uart();
for(integer value=0;value<256;value++) begin
keyboard_frame(value);read_keyboard();
if(stop_requested && value>1) break;
end
keyboard_frame(8'h12);keyboard_frame(8'h1c);read_keyboard();keyboard_frame(8'h59);keyboard_frame(8'h32);read_keyboard();keyboard_frame(8'hf0);keyboard_frame(8'h12);keyboard_frame(8'h21);read_keyboard();
keyboard_frame(8'hf0);keyboard_frame(8'h59);keyboard_frame(8'h23);read_keyboard();
for(integer index=0;index<6;index++) keyboard_frame(8'h30+index);repeat(7) read_keyboard();
keyboard_frame(8'h1c,1,1,1);read_keyboard();
kb_ps2c=0;cycles(3);kb_ps2c=1;cycles(20);
uart_rx=0;cycles(100);rst_n=0;cycles(3);uart_rx=1;rst_n=1;cycles(32);serial_frame(8'ha5);read_uart();
uart_rd_uart=1;uart_wr_uart=1;cycles(1);uart_rd_uart=0;uart_wr_uart=0;cycles(1000);
timing_witnesses();
endtask
endinterface
