`timescale 1ns/1ps
interface reference_if;
logic  clka = 0;
logic  rsta = 0;
logic [0:0] wea = 0;
logic [7:0] addra = 0;
logic [23:0] dina = 0;
logic [23:0] douta;
logic [23:0] predicted_douta;
logic  clkb = 0;
logic  rstb = 0;
logic [0:0] web = 0;
logic [7:0] addrb = 0;
logic [23:0] dinb = 0;
logic [23:0] doutb;
logic [23:0] predicted_doutb;
logic  rsta_busy;
logic  predicted_rsta_busy;
logic  rstb_busy;
logic  predicted_rstb_busy;
event observe; logic [1023:0] valid_mask = 0; int tag = 0; endinterface
