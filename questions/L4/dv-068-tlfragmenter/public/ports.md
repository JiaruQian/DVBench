# Native interface

Instantiate every native TLFragmenter port below. No parameters. clock is the sole rising-edge clock. Packed indices descend to0. The self-contained dvbench_model has this identical signature.

| Port | Direction | Width | Packed indices |
|---|---|---:|---|
| `auto_in_a_bits_address` | In | 13 | [12:0] |
| `auto_in_a_bits_corrupt` | In | 1 | scalar |
| `auto_in_a_bits_data` | In | 64 | [63:0] |
| `auto_in_a_bits_mask` | In | 8 | [7:0] |
| `auto_in_a_bits_opcode` | In | 3 | [2:0] |
| `auto_in_a_bits_param` | In | 3 | [2:0] |
| `auto_in_a_bits_size` | In | 3 | [2:0] |
| `auto_in_a_bits_source` | In | 6 | [5:0] |
| `auto_in_a_ready` | Out | 1 | scalar |
| `auto_in_a_valid` | In | 1 | scalar |
| `auto_in_d_bits_data` | Out | 64 | [63:0] |
| `auto_in_d_bits_opcode` | Out | 3 | [2:0] |
| `auto_in_d_bits_size` | Out | 3 | [2:0] |
| `auto_in_d_bits_source` | Out | 6 | [5:0] |
| `auto_in_d_ready` | In | 1 | scalar |
| `auto_in_d_valid` | Out | 1 | scalar |
| `auto_out_a_bits_address` | Out | 13 | [12:0] |
| `auto_out_a_bits_corrupt` | Out | 1 | scalar |
| `auto_out_a_bits_data` | Out | 64 | [63:0] |
| `auto_out_a_bits_mask` | Out | 8 | [7:0] |
| `auto_out_a_bits_opcode` | Out | 3 | [2:0] |
| `auto_out_a_bits_param` | Out | 3 | [2:0] |
| `auto_out_a_bits_size` | Out | 2 | [1:0] |
| `auto_out_a_bits_source` | Out | 10 | [9:0] |
| `auto_out_a_ready` | In | 1 | scalar |
| `auto_out_a_valid` | Out | 1 | scalar |
| `auto_out_d_bits_data` | In | 64 | [63:0] |
| `auto_out_d_bits_opcode` | In | 3 | [2:0] |
| `auto_out_d_bits_size` | In | 2 | [1:0] |
| `auto_out_d_bits_source` | In | 10 | [9:0] |
| `auto_out_d_ready` | Out | 1 | scalar |
| `auto_out_d_valid` | In | 1 | scalar |
| `clock` | In | 1 | scalar |
| `reset` | In | 1 | scalar |

## Exact native index ranges

- `auto_in_a_bits_address`: packed `[12:0]`
- `auto_in_a_bits_data`: packed `[63:0]`
- `auto_in_a_bits_mask`: packed `[7:0]`
- `auto_in_a_bits_opcode`: packed `[2:0]`
- `auto_in_a_bits_param`: packed `[2:0]`
- `auto_in_a_bits_size`: packed `[2:0]`
- `auto_in_a_bits_source`: packed `[5:0]`
- `auto_in_d_bits_data`: packed `[63:0]`
- `auto_in_d_bits_opcode`: packed `[2:0]`
- `auto_in_d_bits_size`: packed `[2:0]`
- `auto_in_d_bits_source`: packed `[5:0]`
- `auto_out_a_bits_address`: packed `[12:0]`
- `auto_out_a_bits_data`: packed `[63:0]`
- `auto_out_a_bits_mask`: packed `[7:0]`
- `auto_out_a_bits_opcode`: packed `[2:0]`
- `auto_out_a_bits_param`: packed `[2:0]`
- `auto_out_a_bits_size`: packed `[1:0]`
- `auto_out_a_bits_source`: packed `[9:0]`
- `auto_out_d_bits_data`: packed `[63:0]`
- `auto_out_d_bits_opcode`: packed `[2:0]`
- `auto_out_d_bits_size`: packed `[1:0]`
- `auto_out_d_bits_source`: packed `[9:0]`
