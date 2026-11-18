# Native Interface

The sole top level is `yapp_router`, with no top-level parameters; neither `INT_SUPPORT` nor `INJECT_ERROR` is defined. One complete instance contains all three channels, the host registers, and both memories.

|Port|Direction|Bit width/direction|
|---|---|---|
|clock|In|1 scalar|
|data_0|Out|8 [7:0]|
|data_1|Out|8 [7:0]|
|data_2|Out|8 [7:0]|
|data_vld_0|Out|1 scalar|
|data_vld_1|Out|1 scalar|
|data_vld_2|Out|1 scalar|
|error|Out|1 scalar|
|haddr|In|16 [15:0]|
|hdata|InOut|8 [7:0]|
|hen|In|1 scalar|
|hwr_rd|In|1 scalar|
|in_data|In|8 [7:0]|
|in_data_vld|In|1 scalar|
|in_suspend|Out|1 scalar|
|reset|In|1 scalar|
|suspend_0|In|1 scalar|
|suspend_1|In|1 scalar|
|suspend_2|In|1 scalar|

clock is the only clock; inputs/host accesses/dequeues are accepted on falling edges, and outputs are produced on rising edges. reset is active-high and asynchronous. hwr_rd=1 writes, 0 reads, and hdata is a bidirectional resolved net. The source holds the stalled byte, and the host leaves an idle falling edge before each access. See the spec for valid windows.
