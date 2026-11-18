# Native Interface

Top level `cv32e40p_icache`; top-level parameters are fixed at TAG_WIDTH=20, INDEX_WIDTH=6, OFFSET_WIDTH=6; other parameter configurations are outside the scope of this problem. Clock `clk_i`, reset `rst_ni`, active value 0. All multibit indices are [width−1:0].

|Port|Direction|Bit width|
|---|---|---|
|clk_i|In|1|
|rst_ni|In|1|
|instr_req_i|In|1|
|instr_gnt_o|Out|1|
|instr_addr_i|In|32|
|instr_rvalid_o|Out|1|
|instr_rdata_o|Out|32|
|flush_i|In|1|
|flush_ack_o|Out|1|
|mem_req_valid_o|Out|1|
|mem_req_addr_o|Out|32|
|mem_req_len_o|Out|8|
|mem_req_size_o|Out|3|
|mem_req_ack_i|In|1|
|mem_rsp_valid_i|In|1|
|mem_rsp_data_i|In|256|
|mem_rsp_last_i|In|1|
|miss_o|Out|1|
|miss_event_o|Out|1|
