`timescale 1ns/1ps
interface cq_if(input logic clk);
    logic rstn = 1;
    logic write_valid = 0;
    logic [6:0] write_data = 0;
    logic read_ready = 0;
    logic [31:0] power_pattern = 0;
    logic write_ready;
    logic read_valid;
    logic [6:0] read_data;
    logic expected_ready;
    logic expected_valid;
    logic [6:0] expected_data;
    logic checking = 0;
    logic stop_requested = 0;
endinterface
