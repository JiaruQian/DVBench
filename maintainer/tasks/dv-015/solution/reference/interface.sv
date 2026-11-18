`timescale 1ns/1ps
interface native_if;
tri1 scl;
wire [15:0] o_data;
wire s_busy;
wire s_done;
wire sda_en;
tri1 sda;
logic clk;
logic rst_n;
logic [6:0] addr;
logic [7:0] cmd;
logic [7:0] data;
logic rd_wr;
logic init;
logic wr;
logic slave_low;
assign sda = slave_low ? 1'b0 : 1'bz;

tri1 exp_scl;
wire [15:0] exp_o_data;
wire exp_s_busy;
wire exp_s_done;
wire exp_sda_en;
tri1 exp_sda;
logic [28:0] drive;
wire [20:0] actual = {scl,o_data,s_busy,s_done,sda_en,sda};
wire [20:0] predicted = {exp_scl,exp_o_data,exp_s_busy,exp_s_done,exp_sda_en,exp_sda};
assign {clk,rst_n,addr,cmd,data,rd_wr,init,wr,slave_low} = drive;
assign exp_sda = slave_low ? 1'b0 : 1'bz;
event sample_event;
int unsigned tag, pending;
endinterface
