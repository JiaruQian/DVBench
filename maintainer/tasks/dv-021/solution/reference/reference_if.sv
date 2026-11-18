`timescale 1ns/1ps
interface reference_if;
logic  btnL = 0;
logic  btnR = 0;
logic  btnU = 0;
logic  btuD = 0;
logic  clk = 0;
logic [3:0] fnd_com;
logic [3:0] predicted_fnd_com;
logic [7:0] fnd_data;
logic [7:0] predicted_fnd_data;
logic [7:0] led;
logic [7:0] predicted_led;
logic  rst = 0;
logic [2:0] sw = 0;
event observe; logic [1023:0] valid_mask = 0; int tag = 0; endinterface
