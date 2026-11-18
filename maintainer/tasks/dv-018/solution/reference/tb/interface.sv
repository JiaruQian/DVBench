`timescale 1ns/1ps
interface dvbench_if;
    logic [9:0] input_state;
    logic [10:0] actual_state;
    logic [10:0] expected_state;
    logic [10:0] compare_mask;
    event sample_ready;
endinterface
