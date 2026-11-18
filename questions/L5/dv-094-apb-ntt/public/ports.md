# Native Interface and Fixed Configuration

Top-level module: `apb_ntt_wrapper`. Use only default parameter values; overrides are not allowed.

|Parameter|Fixed value|
|---|---|
|C_APB_DATA_WIDTH|32|
|C_APB_ADDR_WIDTH|8|
|N|256|
|Q|3329|
|ROOT|17|
|COEFF_WIDTH|16|
|ADDR_WIDTH|8|

|Port|Direction|Width/Indices|
|---|---|---|
|i_ntt_paddr|input|8 [7:0]|
|i_ntt_pclk|input|1 scalar|
|i_ntt_penable|input|1 scalar|
|i_ntt_presetn|input|1 scalar|
|i_ntt_psel|input|1 scalar|
|i_ntt_pstrb|input|4 [3:0]|
|i_ntt_pwdata|input|32 [31:0]|
|i_ntt_pwrite|input|1 scalar|
|o_ntt_irq|output|1 scalar|
|o_ntt_prdata|output|32 [31:0]|
|o_ntt_pready|output|1 scalar|
|o_ntt_pslverr|output|1 scalar|
