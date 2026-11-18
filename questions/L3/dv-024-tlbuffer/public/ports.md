# Native interface

Top `TLBuffer`, no top parameters. All packed indices descend to zero.

|Port|Direction|Width|
|---|---|---:|
|`clock`|In|1|
|`reset`|In|1|
|`auto_in_a_ready`|Out|1|
|`auto_in_a_valid`|In|1|
|`auto_in_a_bits_opcode`|In|3|
|`auto_in_a_bits_param`|In|3|
|`auto_in_a_bits_size`|In|3|
|`auto_in_a_bits_source`|In|6|
|`auto_in_a_bits_address`|In|13|
|`auto_in_a_bits_mask`|In|8|
|`auto_in_a_bits_data`|In|64|
|`auto_in_a_bits_corrupt`|In|1|
|`auto_in_d_ready`|In|1|
|`auto_in_d_valid`|Out|1|
|`auto_in_d_bits_opcode`|Out|3|
|`auto_in_d_bits_param`|Out|2|
|`auto_in_d_bits_size`|Out|3|
|`auto_in_d_bits_source`|Out|6|
|`auto_in_d_bits_sink`|Out|1|
|`auto_in_d_bits_denied`|Out|1|
|`auto_in_d_bits_data`|Out|64|
|`auto_in_d_bits_corrupt`|Out|1|
|`auto_out_a_ready`|In|1|
|`auto_out_a_valid`|Out|1|
|`auto_out_a_bits_opcode`|Out|3|
|`auto_out_a_bits_param`|Out|3|
|`auto_out_a_bits_size`|Out|3|
|`auto_out_a_bits_source`|Out|6|
|`auto_out_a_bits_address`|Out|13|
|`auto_out_a_bits_mask`|Out|8|
|`auto_out_a_bits_data`|Out|64|
|`auto_out_a_bits_corrupt`|Out|1|
|`auto_out_d_ready`|Out|1|
|`auto_out_d_valid`|In|1|
|`auto_out_d_bits_opcode`|In|3|
|`auto_out_d_bits_size`|In|3|
|`auto_out_d_bits_source`|In|6|
|`auto_out_d_bits_data`|In|64|

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
- `auto_in_d_bits_param`: packed `[1:0]`
- `auto_in_d_bits_size`: packed `[2:0]`
- `auto_in_d_bits_source`: packed `[5:0]`
- `auto_out_a_bits_address`: packed `[12:0]`
- `auto_out_a_bits_data`: packed `[63:0]`
- `auto_out_a_bits_mask`: packed `[7:0]`
- `auto_out_a_bits_opcode`: packed `[2:0]`
- `auto_out_a_bits_param`: packed `[2:0]`
- `auto_out_a_bits_size`: packed `[2:0]`
- `auto_out_a_bits_source`: packed `[5:0]`
- `auto_out_d_bits_data`: packed `[63:0]`
- `auto_out_d_bits_opcode`: packed `[2:0]`
- `auto_out_d_bits_size`: packed `[2:0]`
- `auto_out_d_bits_source`: packed `[5:0]`
