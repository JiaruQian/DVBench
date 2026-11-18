# Native Interface

The fixed top is `ram_2x336`. Parameters support only the fixed values for this version: {}.

|Port|Direction|Width/Indices|
|---|---|---|
|R0_addr|input|scalar|
|R0_en|input|scalar|
|R0_clk|input|scalar|
|R0_data|output|[335:0]|
|W0_addr|input|scalar|
|W0_en|input|scalar|
|W0_clk|input|scalar|
|W0_data|input|[335:0]|
|W0_mask|input|[335:0]|

All addresses are 0 or 1; controls, data, and masks are two-state and stable before and after the write edge. There is no reset. Values of storage bits that have never been written are unspecified; do not compare these bits. The all-X value when R0_en=0 is an explicitly defined four-state output and must be checked bit by bit.
