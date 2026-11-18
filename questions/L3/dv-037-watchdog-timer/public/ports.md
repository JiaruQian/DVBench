# Native Interface

The top is fixed as `watchdog_timer`. Parameters support only the fixed values for this version: {"ADDR_WIDTH": 8, "DATA_WIDTH": 32, "XLEN": 32}.

|Port|Direction|Width/Indices|
|---|---|---|
|pclk|input|scalar|
|presetn|input|scalar|
|psel|input|scalar|
|penable|input|scalar|
|pwrite|input|scalar|
|paddr|input|[7:0]|
|pwdata|input|[31:0]|
|prdata|output|[31:0]|
|pready|output|scalar|
|pslverr|output|scalar|
|wdt_clk|input|scalar|
|wdt_rstn|input|scalar|
|cpu_dbg_halt|input|scalar|
|cpu_commit_pc|input|[31:0]|
|cpu_commit_valid|input|scalar|
|wdt_reset|output|scalar|
|reset_scope|output|[1:0]|
|trace_event_id|output|[7:0]|
|trace_data|output|[31:0]|

Parameters are fixed at ADDR_WIDTH=8, DATA_WIDTH=32, XLEN=32. All non-clock inputs are two-state and avoid sampling edges; the two clocks may run independently, pause, and have different phases. APB writes must have setup followed by access and commit only on the pclk rising edge of access. Adjacent toggle requests for configuration, control, refresh, and status clearing must be separated by at least 4 wdt_clk rising edges, and cross-domain data must be held until the request is consumed; excessively fast toggles are not guaranteed to be lossless. All public outputs are checked according to the digital simulation contract; real analog CDC reliability is not required.
