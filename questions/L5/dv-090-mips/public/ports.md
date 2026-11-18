# Native Interface

Top level `Controller`. Only the following ports are present; all index directions are descending, and single-bit ports have no index.

|Name|Direction|Bit width|
|---|---|---|
|Clk|In|1|
|Reset|In|1|
|input_data|In|32|
|result_valid|Out|1|
|result_data|Out|32|

Fixed parameters: {"PROGRAM_FILE": "code.txt"}.
The clock period is 10ns, and inputs are established after the falling edge; asynchronous reset may change between edges. Port stability windows and boundaries are governed by spec.
