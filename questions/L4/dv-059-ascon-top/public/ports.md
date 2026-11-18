# Native Interface

The DUT module is ascon_top, with no parameters or macro configuration; the model module is dvbench_model, with exactly the same port names, directions, and packed indices. In the model, state_i is declared directly as logic [0:4][63:0], without depending on a hidden type package. clock_i is the only clock.

| Name | Direction | Bit width and indices |
|---|---|---|
| state_i | input | logic [0:4][63:0] (five packed words, with index 0 being the most significant 64 bits) |
| key_i | input | [127:0] |
| data_i | input | [63:0] |
| resetb_i | input | 1 bits |
| start_i | input | 1 bits |
| clock_i | input | 1 bits |
| data_valid_i | input | 1 bits |
| end_o | output | 1 bits |
| cipher_valid_o | output | 1 bits |
| cipher_o | output | [63:0] |
| tag_o | output | [127:0] |
