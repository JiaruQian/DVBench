# Native Port and Parameter Contract

Top-level module: `omsp_alu`. All multibit ports are in descending order `[width-1:0]`; there are no unlisted inout ports. The fixed assembly boundary does not hide connection choices.

| Port | Direction | Range |
| --- | --- | --- |
| alu_out | output | [15:0] |
| alu_out_add | output | [15:0] |
| alu_stat | output | [3:0] |
| alu_stat_wr | output | [3:0] |
| dbg_halt_st | input | [0:0] |
| exec_cycle | input | [0:0] |
| inst_alu | input | [11:0] |
| inst_bw | input | [0:0] |
| inst_jmp | input | [7:0] |
| inst_so | input | [7:0] |
| op_dst | input | [15:0] |
| op_src | input | [15:0] |
| status | input | [3:0] |

See [ports.md](ports.md) for additional fixed context parameters and connections.
