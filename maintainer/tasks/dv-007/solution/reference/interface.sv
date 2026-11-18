`timescale 1ns/1ps
interface native_if;
logic R0_addr;
logic R0_en;
logic R0_clk;
wire [335:0] R0_data;
logic W0_addr;
logic W0_en;
logic W0_clk;
logic [335:0] W0_data;
logic [335:0] W0_mask;

wire [335:0] exp_R0_data;
logic [677:0] drive;
wire [335:0] actual = {R0_data};
wire [335:0] predicted = {exp_R0_data};
assign {R0_addr,R0_en,R0_clk,W0_addr,W0_en,W0_clk,W0_data,W0_mask} = drive;

event sample_event;
int unsigned tag, pending;
endinterface
