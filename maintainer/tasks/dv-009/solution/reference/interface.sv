`timescale 1ns/1ps
interface native_if;
logic clk_i;
logic rst_ni;
logic flush_i;
logic testmode_i;
wire full_o;
wire empty_o;
wire [2:0] usage_o;
logic [31:0] data_i;
logic push_i;
wire [31:0] data_o;
logic pop_i;

wire exp_full_o;
wire exp_empty_o;
wire [2:0] exp_usage_o;
wire [31:0] exp_data_o;
logic [37:0] drive;
int unsigned tag, pending;
wire [36:0] actual = {full_o,empty_o,usage_o,((tag & 256) ? 32'b0 : data_o)};
wire [36:0] predicted = {exp_full_o,exp_empty_o,exp_usage_o,((tag & 256) ? 32'b0 : exp_data_o)};
assign {clk_i,rst_ni,flush_i,testmode_i,data_i,push_i,pop_i} = drive;

event sample_event;
endinterface
