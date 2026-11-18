# Native interface

Top `CLINT`, no top parameters. All packed indices descend to zero.

|Port|Direction|Width|
|---|---|---:|
|`clock`|In|1|
|`reset`|In|1|
|`auto_int_out_0`|Out|1|
|`auto_int_out_1`|Out|1|
|`auto_in_a_ready`|Out|1|
|`auto_in_a_valid`|In|1|
|`auto_in_a_bits_opcode`|In|3|
|`auto_in_a_bits_param`|In|3|
|`auto_in_a_bits_size`|In|2|
|`auto_in_a_bits_source`|In|10|
|`auto_in_a_bits_address`|In|26|
|`auto_in_a_bits_mask`|In|8|
|`auto_in_a_bits_data`|In|64|
|`auto_in_a_bits_corrupt`|In|1|
|`auto_in_d_ready`|In|1|
|`auto_in_d_valid`|Out|1|
|`auto_in_d_bits_opcode`|Out|3|
|`auto_in_d_bits_size`|Out|2|
|`auto_in_d_bits_source`|Out|10|
|`auto_in_d_bits_data`|Out|64|
|`io_rtcTick`|In|1|

## Exact native index ranges

- `auto_in_a_bits_address`: packed `[25:0]`
- `auto_in_a_bits_data`: packed `[63:0]`
- `auto_in_a_bits_mask`: packed `[7:0]`
- `auto_in_a_bits_opcode`: packed `[2:0]`
- `auto_in_a_bits_param`: packed `[2:0]`
- `auto_in_a_bits_size`: packed `[1:0]`
- `auto_in_a_bits_source`: packed `[9:0]`
- `auto_in_d_bits_data`: packed `[63:0]`
- `auto_in_d_bits_opcode`: packed `[2:0]`
- `auto_in_d_bits_size`: packed `[1:0]`
- `auto_in_d_bits_source`: packed `[9:0]`
