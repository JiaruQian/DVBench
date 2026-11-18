# Native Interface

Module `montre_sdram`; only the fixed default configuration for this task.

|Port|Direction|Width|Index|
|---|---|---|---|
|az_addr|input|22|[21:0]|
|az_be_n|input|2|[1:0]|
|az_cs|input|1|scalar|
|az_data|input|16|[15:0]|
|az_rd_n|input|1|scalar|
|az_wr_n|input|1|scalar|
|clk|input|1|scalar|
|reset_n|input|1|scalar|
|za_data|output|16|[15:0]|
|za_valid|output|1|scalar|
|za_waitrequest|output|1|scalar|
|zs_addr|output|12|[11:0]|
|zs_ba|output|2|[1:0]|
|zs_cas_n|output|1|scalar|
|zs_cke|output|1|scalar|
|zs_cs_n|output|1|scalar|
|zs_dq|inout|16|[15:0]|
|zs_dqm|output|2|[1:0]|
|zs_ras_n|output|1|scalar|
|zs_we_n|output|1|scalar|

