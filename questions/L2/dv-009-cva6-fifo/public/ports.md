# Native Interface

The top is fixed as `cva6_fifo_v3`. Parameters support only the fixed values for this version: {"FALL_THROUGH": 1, "FPGA_ALTERA": 0, "DATA_WIDTH": 32, "DEPTH": 8, "FPGA_EN": 0}.

|Port|Direction|Width/Indices|
|---|---|---|
|clk_i|input|scalar|
|rst_ni|input|scalar|
|flush_i|input|scalar|
|testmode_i|input|scalar|
|full_o|output|scalar|
|empty_o|output|scalar|
|usage_o|output|[2:0]|
|data_i|input|[31:0]|
|push_i|input|scalar|
|data_o|output|[31:0]|
|pop_i|input|scalar|

Fixed DEPTH=8, FALL_THROUGH=1, DATA_WIDTH=32, dtype=logic[31:0], FPGA_EN=0, FPGA_ALTERA=0; ADDR_DEPTH=3 is a derived value. Inputs are two-state, and non-reset inputs avoid rising edges. push_i=1 is prohibited when full_o=1, and pop_i=1 is prohibited when empty_o=1; simultaneous push/pop on an empty queue is legal due to fall-through. data_o is not scored when empty_o=1. testmode_i has no observable effect. The original source did not provide a spec; the following is the observable contract of the fixed RTL.
