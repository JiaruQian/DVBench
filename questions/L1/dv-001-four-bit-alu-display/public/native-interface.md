# Native Port and Parameter Contract

Top-level module: `top`. All multibit ports are in descending order `[width-1:0]`; there are no unlisted inout ports. The fixed assembly boundary does not hide connection choices.

| Port | Direction | Range |
| --- | --- | --- |
| A | input | [3:0] |
| B | input | [3:0] |
| bcd | output | [11:0] |
| carry_in | input | [0:0] |
| carry_out | output | [0:0] |
| error | output | [0:0] |
| opcode | input | [2:0] |
| overflow | output | [0:0] |
| screen | input | [1:0] |

See [ports.md](ports.md) for additional fixed context parameters and connections.
