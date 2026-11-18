# Native interface contract

Top level `xgmii_pcs_10g_tx`. Bit widths and indices come from the native declarations and default parameters; these parameters are fixed for this task, and interaction is only through public ports.

|Port|Direction|Bit width|Index or type|
|---|---|---:|---|
|clk|input|1|scalar|
|nreset|input|1|scalar|
|xgmii_txd_i|input|64|[63:0]|
|xgmii_txc_i|input|8|[7:0]|
|ready_o|output|1|scalar|
|data_o|output|64|[63:0]|

Parameter `XGMII_DATA_W=64` is fixed; localparam `XGMII_CTRL_W=8`.
