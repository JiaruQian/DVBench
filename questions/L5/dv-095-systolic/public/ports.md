# Native Interface and Fixed Configuration

Top-level module: `systolic_top`. Use only default parameter values; overrides are not allowed.

|Parameter|Fixed value|
|---|---|
|None|None|

|Port|Direction|Width/Indices|
|---|---|---|
|clk|input|1 scalar|
|irq|output|1 scalar|
|m_axis_c_tdata|output|256 [255:0]|
|m_axis_c_tlast|output|1 scalar|
|m_axis_c_tready|input|1 scalar|
|m_axis_c_tvalid|output|1 scalar|
|rst|input|1 scalar|
|s_axil_araddr|input|8 [7:0]|
|s_axil_arready|output|1 scalar|
|s_axil_arvalid|input|1 scalar|
|s_axil_awaddr|input|8 [7:0]|
|s_axil_awready|output|1 scalar|
|s_axil_awvalid|input|1 scalar|
|s_axil_bready|input|1 scalar|
|s_axil_bresp|output|2 [1:0]|
|s_axil_bvalid|output|1 scalar|
|s_axil_rdata|output|32 [31:0]|
|s_axil_rready|input|1 scalar|
|s_axil_rresp|output|2 [1:0]|
|s_axil_rvalid|output|1 scalar|
|s_axil_wdata|input|32 [31:0]|
|s_axil_wready|output|1 scalar|
|s_axil_wstrb|input|4 [3:0]|
|s_axil_wvalid|input|1 scalar|
|s_axis_a_tdata|input|64 [63:0]|
|s_axis_a_tlast|input|1 scalar|
|s_axis_a_tready|output|1 scalar|
|s_axis_a_tvalid|input|1 scalar|
|s_axis_b_tdata|input|64 [63:0]|
|s_axis_b_tlast|input|1 scalar|
|s_axis_b_tready|output|1 scalar|
|s_axis_b_tvalid|input|1 scalar|
