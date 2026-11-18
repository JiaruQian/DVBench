`timescale 1ns/1ps
interface native_if;
logic  CLOCK_50Mhz;
logic [6:0] HEX0;
logic [6:0] pred_HEX0;
logic  KEY_0;
logic  LCD_BLON;
logic  pred_LCD_BLON;
logic [7:0] LCD_DATA;
logic [7:0] pred_LCD_DATA;
logic  LCD_EN;
logic  pred_LCD_EN;
logic  LCD_ON;
logic  pred_LCD_ON;
logic  LCD_RS;
logic  pred_LCD_RS;
logic  LCD_RW;
logic  pred_LCD_RW;
logic  key_valid;
logic [3:0] keypad_input;
logic  lock;
logic  pred_lock;
logic  lock_c;
logic  pred_lock_c;
initial CLOCK_50Mhz=0;
always #5 CLOCK_50Mhz=~CLOCK_50Mhz;
logic [5:0] driven=0;
assign {KEY_0,key_valid,keypad_input}=driven;
endinterface
