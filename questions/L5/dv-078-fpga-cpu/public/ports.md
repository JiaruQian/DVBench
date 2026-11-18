# Native Interface

Top level: `fpgatop_taskB`. Only the following ports are present; all index directions are descending, and single-bit ports have no index.

|Name|Direction|Bit width|
|---|---|---|
|clk|In|1|
|rst|In|1|
|sw|In|16|
|seg|Out|7|
|an|Out|4|
|leds|Out|16|

Fixed parameters: {"CPU_HALF_PERIOD": 4, "MEMFILE": "temp_warning_test.mem"}.
The clock period is 10ns, and inputs are established after the falling edge; asynchronous reset may change between edges. Port stability windows and boundaries are governed by spec.
