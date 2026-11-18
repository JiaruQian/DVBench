# Native Interface

Module `top_stopwatch_watch`; only the fixed default configuration for this task.

|Port|Direction|Width|Index|
|---|---|---|---|
|btnL|input|1|scalar|
|btnR|input|1|scalar|
|btnU|input|1|scalar|
|btuD|input|1|scalar|
|clk|input|1|scalar|
|fnd_com|output|4|[3:0]|
|fnd_data|output|8|[7:0]|
|led|output|8|[7:0]|
|rst|input|1|scalar|
|sw|input|3|[2:0]|

Fixed default parameters MSEC_WIDTH=7, SEC_WIDTH=6, MIN_WIDTH=6, HOUR_WIDTH=5; submodule clock division must not be overridden.