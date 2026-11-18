# Native Interface and Fixed Configuration

Top-level module: `DES_core`. Use only default parameter values; overrides are not allowed.

|Parameter|Fixed value|
|---|---|
|None|None|

|Port|Direction|Width/Indices|
|---|---|---|
|clk|input|1 scalar|
|des_data|input|64 [63:0]|
|des_decipher_en|input|1 scalar|
|des_encipher_en|input|1 scalar|
|des_key_in|input|64 [63:0]|
|desc_ready|output|1 scalar|
|desc_result|output|64 [63:0]|
|rst_n|input|1 scalar|
