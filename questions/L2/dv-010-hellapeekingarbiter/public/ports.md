# Native interface

Instantiate the hidden module `HellaPeekingArbiter` with every port below. There are no parameters. The independent `dvbench_model` must declare exactly these native ports and widths, including outputs as model predictions. `clock` is the sole rising-edge clock, and `reset` is synchronous active high. All vectors use descending packed indices.

| Port | Direction | Width | Packed indices |
|---|---|---:|---|
| `clock` | In | 1 | scalar |
| `reset` | In | 1 | scalar |
| `io_in_1_ready` | Out | 1 | scalar |
| `io_in_1_valid` | In | 1 | scalar |
| `io_in_1_bits_opcode` | In | 3 | [2:0] |
| `io_in_1_bits_param` | In | 3 | [2:0] |
| `io_in_1_bits_size` | In | 8 | [7:0] |
| `io_in_1_bits_source` | In | 8 | [7:0] |
| `io_in_1_bits_data` | In | 64 | [63:0] |
| `io_in_1_bits_corrupt` | In | 1 | scalar |
| `io_in_1_bits_union` | In | 9 | [8:0] |
| `io_in_1_bits_last` | In | 1 | scalar |
| `io_in_4_ready` | Out | 1 | scalar |
| `io_in_4_valid` | In | 1 | scalar |
| `io_in_4_bits_opcode` | In | 3 | [2:0] |
| `io_in_4_bits_param` | In | 3 | [2:0] |
| `io_in_4_bits_size` | In | 8 | [7:0] |
| `io_in_4_bits_source` | In | 8 | [7:0] |
| `io_in_4_bits_address` | In | 64 | [63:0] |
| `io_in_4_bits_data` | In | 64 | [63:0] |
| `io_in_4_bits_corrupt` | In | 1 | scalar |
| `io_in_4_bits_union` | In | 9 | [8:0] |
| `io_in_4_bits_last` | In | 1 | scalar |
| `io_out_ready` | In | 1 | scalar |
| `io_out_valid` | Out | 1 | scalar |
| `io_out_bits_chanId` | Out | 3 | [2:0] |
| `io_out_bits_opcode` | Out | 3 | [2:0] |
| `io_out_bits_param` | Out | 3 | [2:0] |
| `io_out_bits_size` | Out | 8 | [7:0] |
| `io_out_bits_source` | Out | 8 | [7:0] |
| `io_out_bits_address` | Out | 64 | [63:0] |
| `io_out_bits_data` | Out | 64 | [63:0] |
| `io_out_bits_corrupt` | Out | 1 | scalar |
| `io_out_bits_union` | Out | 9 | [8:0] |
| `io_out_bits_last` | Out | 1 | scalar |

## Exact native index ranges

- `io_in_1_bits_data`: packed `[63:0]`
- `io_in_1_bits_opcode`: packed `[2:0]`
- `io_in_1_bits_param`: packed `[2:0]`
- `io_in_1_bits_size`: packed `[7:0]`
- `io_in_1_bits_source`: packed `[7:0]`
- `io_in_1_bits_union`: packed `[8:0]`
- `io_in_4_bits_address`: packed `[63:0]`
- `io_in_4_bits_data`: packed `[63:0]`
- `io_in_4_bits_opcode`: packed `[2:0]`
- `io_in_4_bits_param`: packed `[2:0]`
- `io_in_4_bits_size`: packed `[7:0]`
- `io_in_4_bits_source`: packed `[7:0]`
- `io_in_4_bits_union`: packed `[8:0]`
- `io_out_bits_address`: packed `[63:0]`
- `io_out_bits_chanId`: packed `[2:0]`
- `io_out_bits_data`: packed `[63:0]`
- `io_out_bits_opcode`: packed `[2:0]`
- `io_out_bits_param`: packed `[2:0]`
- `io_out_bits_size`: packed `[7:0]`
- `io_out_bits_source`: packed `[7:0]`
- `io_out_bits_union`: packed `[8:0]`
