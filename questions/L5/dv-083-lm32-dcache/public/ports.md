# Native interface and configuration

The top level is lm32_dcache; all vectors use descending indices. Parameters are associativity=1, sets=512 (64 must also be tested), bytes_per_line=16, base_address=0, and limit=0. Fixed macros are CFG_DCACHE_ENABLED, CFG_DCACHE_BASE_ADDRESS=0, and CFG_DCACHE_LIMIT=0x0fffffff, with asynchronous active-high reset. A single TB may instantiate one 512 configuration and one 64 configuration, each with its own independent input history; the same parameterized dvbench_model is used for both and for D.

|Port|Direction|Width and indices|
|---|---|---|
|address_m|In|32 [31:0]|
|address_x|In|32 [31:0]|
|clk_i|In|1 scalar|
|dflush|In|1 scalar|
|load_data|Out|32 [31:0]|
|load_q_m|In|1 scalar|
|refill_address|Out|32 [31:0]|
|refill_data|In|32 [31:0]|
|refill_ready|In|1 scalar|
|refill_request|Out|1 scalar|
|refilling|Out|1 scalar|
|restart_request|Out|1 scalar|
|rst_i|In|1 scalar|
|stall_a|In|1 scalar|
|stall_m|In|1 scalar|
|stall_request|Out|1 scalar|
|stall_x|In|1 scalar|
|store_byte_select|In|4 [3:0]|
|store_data|In|32 [31:0]|
|store_q_m|In|1 scalar|
