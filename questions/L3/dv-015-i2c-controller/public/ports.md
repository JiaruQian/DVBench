# Native Interface

The fixed top is `i2c`. Parameters support only the fixed values for this version: {}.

|Port|Direction|Width/Indices|
|---|---|---|
|scl|output|scalar|
|o_data|output|[15:0]|
|s_busy|output|scalar|
|s_done|output|scalar|
|sda_en|output|scalar|
|sda|inout|scalar|
|clk|input|scalar|
|rst_n|input|scalar|
|addr|input|[6:0]|
|cmd|input|[7:0]|
|data|input|[7:0]|
|rd_wr|input|scalar|
|init|input|scalar|
|wr|input|scalar|

No parameters; fixed macro DVSR=16 (from backfill/package.svh), with 16 clk cycles per SCL bit period. Two-state host inputs avoid clk rising edges; init is pulsed for one clk cycle only when idle after STOP completes, and addr/cmd/data/rd_wr/wr are held throughout from initiation to STOP. The external slave may only pull sda low or release it, must not drive it high, and must not drive scl; during DUT read termination when sda_en=1, the slave releases the line to avoid strong-drive contention. An external pull-up makes a released line 1. No guarantees for multi-master arbitration, clock stretching, or analog metastability.
