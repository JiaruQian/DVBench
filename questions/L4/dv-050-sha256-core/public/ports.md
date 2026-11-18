# Native interface contract

The top level is `sha256_core`. Bit widths and indices come from the native declarations and default parameters; this task fixes these parameters and interacts only through public ports.

|Port|Direction|Bit width|Index or type|
|---|---|---:|---|
|clk|input|1|scalar|
|reset_n|input|1|scalar|
|init|input|1|scalar|
|next|input|1|scalar|
|mode|input|1|scalar|
|block|input|512|[511:0]|
|ready|output|1|scalar|
|digest|output|256|[255:0]|
|digest_valid|output|1|scalar|
