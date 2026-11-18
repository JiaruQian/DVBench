# Native interface and parameters

The DUT module is prim_sram_arbiter. The candidate model defines dvbench_model, using the same native port names, directions, packed/unpacked indices, and parameter names. Array [N] has unpacked indices 0 through N-1, and all vectors have descending packed indices.

| Parameter | Default | Values for this task |
|---|---|---|
| N | 4 | 4 or 2, limited to the following three configurations |
| SramDw | 32 | 32 |
| SramAw | 12 | 12 |
| ArbiterImpl | "PPC" | "PPC" or "BINTREE" |
| EnMask | 0 | 0 or 1 |

The fixed configuration tuples, in the parameter order of the table above, are (4,32,12,"PPC",0), (4,32,12,"PPC",1), and (2,32,12,"BINTREE",1). The three configurations belong to the same complete A task, and the submission should support all three.

| Port | Direction | packed dimensions | unpacked dimensions |
|---|---|---|---|
| clk_i | in | scalar | none |
| rst_ni | in | scalar | none |
| req_i | in | [N-1:0] | none |
| req_addr_i | in | [SramAw-1:0] | [0:N-1] |
| req_write_i | in | [N-1:0] | none |
| req_wdata_i | in | [SramDw-1:0] | [0:N-1] |
| req_wmask_i | in | [SramDw-1:0] | [0:N-1] |
| gnt_o | out | [N-1:0] | none |
| rsp_rvalid_o | out | [N-1:0] | none |
| rsp_rdata_o | out | [SramDw-1:0] | [0:N-1] |
| rsp_error_o | out | [1:0] | [0:N-1] |
| sram_req_o | out | scalar | none |
| sram_addr_o | out | [SramAw-1:0] | none |
| sram_write_o | out | scalar | none |
| sram_wdata_o | out | [SramDw-1:0] | none |
| sram_wmask_o | out | [SramDw-1:0] | none |
| sram_rvalid_i | in | scalar | none |
| sram_rdata_i | in | [SramDw-1:0] | none |
| sram_rerror_i | in | [1:0] | none |

clk_i is the only clock; commands are accepted and history is updated on rising edges. rst_ni is asynchronous and active low. Reset does not mask combinational grant/request either. The command payload is valid only when sram_req_o is high; the data/error broadcasts are always valid. There are no inout, ready, or other ports.
