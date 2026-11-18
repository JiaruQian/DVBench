# Native interface

Instantiate `TLFIFOFixer` with every listed port. There are no parameters. The self-contained `dvbench_model` uses exactly the same ports and predicts every output. `clock` is the rising-edge clock for legal-history checking, and `reset` is synchronous active high. All packed vectors descend to index zero.

| Port | Direction | Width | Packed indices |
|---|---|---:|---|
| `auto_in_0_a_bits_address` | In | 33 | [32:0] |
| `auto_in_0_a_bits_corrupt` | In | 1 | scalar |
| `auto_in_0_a_bits_data` | In | 64 | [63:0] |
| `auto_in_0_a_bits_mask` | In | 8 | [7:0] |
| `auto_in_0_a_bits_opcode` | In | 3 | [2:0] |
| `auto_in_0_a_bits_param` | In | 3 | [2:0] |
| `auto_in_0_a_bits_size` | In | 4 | [3:0] |
| `auto_in_0_a_bits_source` | In | 4 | [3:0] |
| `auto_in_0_a_ready` | Out | 1 | scalar |
| `auto_in_0_a_valid` | In | 1 | scalar |
| `auto_in_0_d_bits_corrupt` | Out | 1 | scalar |
| `auto_in_0_d_bits_data` | Out | 64 | [63:0] |
| `auto_in_0_d_bits_denied` | Out | 1 | scalar |
| `auto_in_0_d_bits_opcode` | Out | 3 | [2:0] |
| `auto_in_0_d_bits_param` | Out | 2 | [1:0] |
| `auto_in_0_d_bits_sink` | Out | 2 | [1:0] |
| `auto_in_0_d_bits_size` | Out | 4 | [3:0] |
| `auto_in_0_d_bits_source` | Out | 4 | [3:0] |
| `auto_in_0_d_ready` | In | 1 | scalar |
| `auto_in_0_d_valid` | Out | 1 | scalar |
| `auto_in_1_a_bits_address` | In | 33 | [32:0] |
| `auto_in_1_a_bits_corrupt` | In | 1 | scalar |
| `auto_in_1_a_bits_data` | In | 64 | [63:0] |
| `auto_in_1_a_bits_mask` | In | 8 | [7:0] |
| `auto_in_1_a_bits_opcode` | In | 3 | [2:0] |
| `auto_in_1_a_bits_param` | In | 3 | [2:0] |
| `auto_in_1_a_bits_size` | In | 4 | [3:0] |
| `auto_in_1_a_bits_source` | In | 5 | [4:0] |
| `auto_in_1_a_ready` | Out | 1 | scalar |
| `auto_in_1_a_valid` | In | 1 | scalar |
| `auto_in_1_b_bits_address` | Out | 33 | [32:0] |
| `auto_in_1_b_bits_param` | Out | 2 | [1:0] |
| `auto_in_1_b_ready` | In | 1 | scalar |
| `auto_in_1_b_valid` | Out | 1 | scalar |
| `auto_in_1_c_bits_address` | In | 33 | [32:0] |
| `auto_in_1_c_bits_corrupt` | In | 1 | scalar |
| `auto_in_1_c_bits_data` | In | 64 | [63:0] |
| `auto_in_1_c_bits_opcode` | In | 3 | [2:0] |
| `auto_in_1_c_bits_param` | In | 3 | [2:0] |
| `auto_in_1_c_bits_size` | In | 4 | [3:0] |
| `auto_in_1_c_bits_source` | In | 5 | [4:0] |
| `auto_in_1_c_ready` | Out | 1 | scalar |
| `auto_in_1_c_valid` | In | 1 | scalar |
| `auto_in_1_d_bits_corrupt` | Out | 1 | scalar |
| `auto_in_1_d_bits_data` | Out | 64 | [63:0] |
| `auto_in_1_d_bits_denied` | Out | 1 | scalar |
| `auto_in_1_d_bits_opcode` | Out | 3 | [2:0] |
| `auto_in_1_d_bits_param` | Out | 2 | [1:0] |
| `auto_in_1_d_bits_sink` | Out | 2 | [1:0] |
| `auto_in_1_d_bits_size` | Out | 4 | [3:0] |
| `auto_in_1_d_bits_source` | Out | 5 | [4:0] |
| `auto_in_1_d_ready` | In | 1 | scalar |
| `auto_in_1_d_valid` | Out | 1 | scalar |
| `auto_in_1_e_bits_sink` | In | 2 | [1:0] |
| `auto_in_1_e_valid` | In | 1 | scalar |
| `auto_out_0_a_bits_address` | Out | 33 | [32:0] |
| `auto_out_0_a_bits_corrupt` | Out | 1 | scalar |
| `auto_out_0_a_bits_data` | Out | 64 | [63:0] |
| `auto_out_0_a_bits_mask` | Out | 8 | [7:0] |
| `auto_out_0_a_bits_opcode` | Out | 3 | [2:0] |
| `auto_out_0_a_bits_param` | Out | 3 | [2:0] |
| `auto_out_0_a_bits_size` | Out | 4 | [3:0] |
| `auto_out_0_a_bits_source` | Out | 4 | [3:0] |
| `auto_out_0_a_ready` | In | 1 | scalar |
| `auto_out_0_a_valid` | Out | 1 | scalar |
| `auto_out_0_d_bits_corrupt` | In | 1 | scalar |
| `auto_out_0_d_bits_data` | In | 64 | [63:0] |
| `auto_out_0_d_bits_denied` | In | 1 | scalar |
| `auto_out_0_d_bits_opcode` | In | 3 | [2:0] |
| `auto_out_0_d_bits_param` | In | 2 | [1:0] |
| `auto_out_0_d_bits_sink` | In | 2 | [1:0] |
| `auto_out_0_d_bits_size` | In | 4 | [3:0] |
| `auto_out_0_d_bits_source` | In | 4 | [3:0] |
| `auto_out_0_d_ready` | Out | 1 | scalar |
| `auto_out_0_d_valid` | In | 1 | scalar |
| `auto_out_1_a_bits_address` | Out | 33 | [32:0] |
| `auto_out_1_a_bits_corrupt` | Out | 1 | scalar |
| `auto_out_1_a_bits_data` | Out | 64 | [63:0] |
| `auto_out_1_a_bits_mask` | Out | 8 | [7:0] |
| `auto_out_1_a_bits_opcode` | Out | 3 | [2:0] |
| `auto_out_1_a_bits_param` | Out | 3 | [2:0] |
| `auto_out_1_a_bits_size` | Out | 4 | [3:0] |
| `auto_out_1_a_bits_source` | Out | 5 | [4:0] |
| `auto_out_1_a_ready` | In | 1 | scalar |
| `auto_out_1_a_valid` | Out | 1 | scalar |
| `auto_out_1_b_bits_address` | In | 33 | [32:0] |
| `auto_out_1_b_bits_param` | In | 2 | [1:0] |
| `auto_out_1_b_ready` | Out | 1 | scalar |
| `auto_out_1_b_valid` | In | 1 | scalar |
| `auto_out_1_c_bits_address` | Out | 33 | [32:0] |
| `auto_out_1_c_bits_corrupt` | Out | 1 | scalar |
| `auto_out_1_c_bits_data` | Out | 64 | [63:0] |
| `auto_out_1_c_bits_opcode` | Out | 3 | [2:0] |
| `auto_out_1_c_bits_param` | Out | 3 | [2:0] |
| `auto_out_1_c_bits_size` | Out | 4 | [3:0] |
| `auto_out_1_c_bits_source` | Out | 5 | [4:0] |
| `auto_out_1_c_ready` | In | 1 | scalar |
| `auto_out_1_c_valid` | Out | 1 | scalar |
| `auto_out_1_d_bits_corrupt` | In | 1 | scalar |
| `auto_out_1_d_bits_data` | In | 64 | [63:0] |
| `auto_out_1_d_bits_denied` | In | 1 | scalar |
| `auto_out_1_d_bits_opcode` | In | 3 | [2:0] |
| `auto_out_1_d_bits_param` | In | 2 | [1:0] |
| `auto_out_1_d_bits_sink` | In | 2 | [1:0] |
| `auto_out_1_d_bits_size` | In | 4 | [3:0] |
| `auto_out_1_d_bits_source` | In | 5 | [4:0] |
| `auto_out_1_d_ready` | Out | 1 | scalar |
| `auto_out_1_d_valid` | In | 1 | scalar |
| `auto_out_1_e_bits_sink` | Out | 2 | [1:0] |
| `auto_out_1_e_valid` | Out | 1 | scalar |
| `clock` | In | 1 | scalar |
| `reset` | In | 1 | scalar |

## Exact native index ranges

- `auto_in_0_a_bits_address`: packed `[32:0]`
- `auto_in_0_a_bits_data`: packed `[63:0]`
- `auto_in_0_a_bits_mask`: packed `[7:0]`
- `auto_in_0_a_bits_opcode`: packed `[2:0]`
- `auto_in_0_a_bits_param`: packed `[2:0]`
- `auto_in_0_a_bits_size`: packed `[3:0]`
- `auto_in_0_a_bits_source`: packed `[3:0]`
- `auto_in_0_d_bits_data`: packed `[63:0]`
- `auto_in_0_d_bits_opcode`: packed `[2:0]`
- `auto_in_0_d_bits_param`: packed `[1:0]`
- `auto_in_0_d_bits_sink`: packed `[1:0]`
- `auto_in_0_d_bits_size`: packed `[3:0]`
- `auto_in_0_d_bits_source`: packed `[3:0]`
- `auto_in_1_a_bits_address`: packed `[32:0]`
- `auto_in_1_a_bits_data`: packed `[63:0]`
- `auto_in_1_a_bits_mask`: packed `[7:0]`
- `auto_in_1_a_bits_opcode`: packed `[2:0]`
- `auto_in_1_a_bits_param`: packed `[2:0]`
- `auto_in_1_a_bits_size`: packed `[3:0]`
- `auto_in_1_a_bits_source`: packed `[4:0]`
- `auto_in_1_b_bits_address`: packed `[32:0]`
- `auto_in_1_b_bits_param`: packed `[1:0]`
- `auto_in_1_c_bits_address`: packed `[32:0]`
- `auto_in_1_c_bits_data`: packed `[63:0]`
- `auto_in_1_c_bits_opcode`: packed `[2:0]`
- `auto_in_1_c_bits_param`: packed `[2:0]`
- `auto_in_1_c_bits_size`: packed `[3:0]`
- `auto_in_1_c_bits_source`: packed `[4:0]`
- `auto_in_1_d_bits_data`: packed `[63:0]`
- `auto_in_1_d_bits_opcode`: packed `[2:0]`
- `auto_in_1_d_bits_param`: packed `[1:0]`
- `auto_in_1_d_bits_sink`: packed `[1:0]`
- `auto_in_1_d_bits_size`: packed `[3:0]`
- `auto_in_1_d_bits_source`: packed `[4:0]`
- `auto_in_1_e_bits_sink`: packed `[1:0]`
- `auto_out_0_a_bits_address`: packed `[32:0]`
- `auto_out_0_a_bits_data`: packed `[63:0]`
- `auto_out_0_a_bits_mask`: packed `[7:0]`
- `auto_out_0_a_bits_opcode`: packed `[2:0]`
- `auto_out_0_a_bits_param`: packed `[2:0]`
- `auto_out_0_a_bits_size`: packed `[3:0]`
- `auto_out_0_a_bits_source`: packed `[3:0]`
- `auto_out_0_d_bits_data`: packed `[63:0]`
- `auto_out_0_d_bits_opcode`: packed `[2:0]`
- `auto_out_0_d_bits_param`: packed `[1:0]`
- `auto_out_0_d_bits_sink`: packed `[1:0]`
- `auto_out_0_d_bits_size`: packed `[3:0]`
- `auto_out_0_d_bits_source`: packed `[3:0]`
- `auto_out_1_a_bits_address`: packed `[32:0]`
- `auto_out_1_a_bits_data`: packed `[63:0]`
- `auto_out_1_a_bits_mask`: packed `[7:0]`
- `auto_out_1_a_bits_opcode`: packed `[2:0]`
- `auto_out_1_a_bits_param`: packed `[2:0]`
- `auto_out_1_a_bits_size`: packed `[3:0]`
- `auto_out_1_a_bits_source`: packed `[4:0]`
- `auto_out_1_b_bits_address`: packed `[32:0]`
- `auto_out_1_b_bits_param`: packed `[1:0]`
- `auto_out_1_c_bits_address`: packed `[32:0]`
- `auto_out_1_c_bits_data`: packed `[63:0]`
- `auto_out_1_c_bits_opcode`: packed `[2:0]`
- `auto_out_1_c_bits_param`: packed `[2:0]`
- `auto_out_1_c_bits_size`: packed `[3:0]`
- `auto_out_1_c_bits_source`: packed `[4:0]`
- `auto_out_1_d_bits_data`: packed `[63:0]`
- `auto_out_1_d_bits_opcode`: packed `[2:0]`
- `auto_out_1_d_bits_param`: packed `[1:0]`
- `auto_out_1_d_bits_sink`: packed `[1:0]`
- `auto_out_1_d_bits_size`: packed `[3:0]`
- `auto_out_1_d_bits_source`: packed `[4:0]`
- `auto_out_1_e_bits_sink`: packed `[1:0]`
