# Native Interface

The top level is decoder_top, with no parameters; all vectors use descending indices. clk uses the rising edge, and rst_n is an active-low asynchronous reset. Each bs_len specifies the number of valid bits in its corresponding bs; block_num is a 13-bit unsigned block number.

|Port|Direction|Bit width|
|---|---|---|
|B_out|Out|512|
|G_out|Out|512|
|R_out|Out|512|
|block_num|In|13|
|bs_Cb|In|1024|
|bs_Cr|In|1024|
|bs_Y|In|1024|
|bs_len_Cb|In|11|
|bs_len_Cr|In|11|
|bs_len_Y|In|11|
|clk|In|1|
|dec_done|Out|1|
|dec_start|In|1|
|rst_n|In|1|
|total_bits_consumed|Out|11|
|trigger_dec|Out|1|
