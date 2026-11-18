`timescale 1ns/1ps
interface native_if;
logic  alarm_button;
logic  alarm_sound;
logic  pred_alarm_sound;
logic  clock;
logic  fastwatch;
logic [3:0] key;
logic [7:0] ls_hour;
logic [7:0] pred_ls_hour;
logic [7:0] ls_minute;
logic [7:0] pred_ls_minute;
logic [7:0] ms_hour;
logic [7:0] pred_ms_hour;
logic [7:0] ms_minute;
logic [7:0] pred_ms_minute;
logic  reset;
logic  time_button;
initial clock=0;
always #5 clock=~clock;
logic [7:0] driven=0;
assign {alarm_button,fastwatch,key,reset,time_button}=driven;
endinterface
