# Fixed Native Interface

DUT top level `rv32i_single_cycle_core`; model top level `dvbench_model`. See the table for all vector directions; each port is [width-1:0].

Fixed parameters (SV elaboration values):

No top-level parameters.

|Port|Direction|Bit width|
|---|---|---:|
|`clk`|In|1|
|`dmem_addr_o`|Out|32|
|`dmem_be_o`|Out|4|
|`dmem_rdata_i`|In|32|
|`dmem_re_o`|Out|1|
|`dmem_wdata_o`|Out|32|
|`dmem_we_o`|Out|1|
|`imem_addr_o`|Out|32|
|`imem_rdata_i`|In|32|
|`rst_n`|In|1|
