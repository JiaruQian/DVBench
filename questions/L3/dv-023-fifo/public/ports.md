# Native ports and fixed parameters

Top level `fifo`. Fixed parameters `ADDR=16` and `BIT_WIDTH=8`; other parameter profiles are outside the scope of this task.

| Name | Direction | Width/Index | Meaning |
|---|---|---|---|
| w_clk | input | 1 | Rising-edge clock for write requests and status updates |
| r_clk | input | 1 | Rising-edge clock for read-position updates |
| rst | input | 1 | Asynchronous active-high reset |
| we | input | 1 | Write request level |
| re | input | 1 | Read request level |
| wdata | input | [7:0] | Unsigned write byte |
| rdata | output | [7:0] | Combinational data at the current read position |
| full | output | 1 | Full status in the write clock domain |
| empty | output | 1 | Empty status in the write clock domain |

There are no other native ports and no external SRAM model. Inputs follow the stability conditions around the relevant clock edges in the spec. The model must use the same ports, parameters, and directions, with its outputs and the actual DUT outputs connected separately.
