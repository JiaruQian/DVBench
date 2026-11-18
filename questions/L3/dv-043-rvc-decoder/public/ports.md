# Native Interface and Fixed Configuration

Top-level module: `cv32e40p_compressed_decoder`. Use only default parameter values; overrides are not allowed.

|Parameter|Fixed value|
|---|---|
|FPU|0|
|ZFINX|0|

|Port|Direction|Width/Indices|
|---|---|---|
|illegal_instr_o|output|1 scalar|
|instr_i|input|32 [31:0]|
|instr_o|output|32 [31:0]|
|is_compressed_o|output|1 scalar|
