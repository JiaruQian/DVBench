# Native Interface

The top level is pipelined_riscv_core, with WIDTH=32 and PROGRAM_FILE="program3.hex" fixed.

|Port|Direction|Width/Indices|
|---|---|---|
|i_clk|input|1|
|i_rstn|input|1|
|input_data|input|[31:0]|
|result_valid|output|1|
|result_data|output|[31:0]|

The model module is named dvbench_model and includes the same parameter defaults and the same native ports; input/output directions must not be swapped.
