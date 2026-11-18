`timescale 1ns/1ps
interface native_if;
logic pclk;
logic presetn;
logic psel;
logic penable;
logic pwrite;
logic [7:0] paddr;
logic [31:0] pwdata;
wire [31:0] prdata;
wire pready;
wire pslverr;
logic wdt_clk;
logic wdt_rstn;
logic cpu_dbg_halt;
logic [31:0] cpu_commit_pc;
logic cpu_commit_valid;
wire wdt_reset;
wire [1:0] reset_scope;
wire [7:0] trace_event_id;
wire [31:0] trace_data;

wire [31:0] exp_prdata;
wire exp_pready;
wire exp_pslverr;
wire exp_wdt_reset;
wire [1:0] exp_reset_scope;
wire [7:0] exp_trace_event_id;
wire [31:0] exp_trace_data;
logic [80:0] drive;
wire [76:0] actual = {prdata,pready,pslverr,wdt_reset,reset_scope,trace_event_id,trace_data};
wire [76:0] predicted = {exp_prdata,exp_pready,exp_pslverr,exp_wdt_reset,exp_reset_scope,exp_trace_event_id,exp_trace_data};
assign {pclk,presetn,psel,penable,pwrite,paddr,pwdata,wdt_clk,wdt_rstn,cpu_dbg_halt,cpu_commit_pc,cpu_commit_valid} = drive;

event sample_event;
int unsigned tag, pending;
endinterface
