# Native Interface and Fixed Configuration

Top-level module: `fpu_sqrt`. Use only default parameter values; overrides are not allowed.

|Parameter|Fixed value|
|---|---|
|None|None|

|Port|Direction|Width/Indices|
|---|---|---|
|clk|input|1 scalar|
|exp_half|input|8 [7:0]|
|in_exp0|input|1 scalar|
|in_sig|input|24 [23:0]|
|is_subnormal|input|1 scalar|
|reset|input|1 scalar|
|rounding_mode|input|3 [2:0]|
|sqrt_done|output|1 scalar|
|sqrt_proNorm_exp|output|8 [7:0]|
|sqrt_proNorm_sig|output|27 [26:0]|
|start|input|1 scalar|
|uf|output|1 scalar|
