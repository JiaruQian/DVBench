# Native Interface

Module cpu_core, with no parameters. All bit indices are descending; scalars have no indices.

|Port|Direction|Bit width|
|---|---|---|
|clk_i|In|1|
|rst_i|In|1|
|i_req_valid_o|Out|1|
|i_req_ready_i|In|1|
|i_req_addr_o|Out|32|
|i_rsp_valid_i|In|1|
|i_rsp_ready_o|Out|1|
|i_rsp_rdata_i|In|32|
|i_rsp_error_i|In|1|
|d_req_valid_o|Out|1|
|d_req_ready_i|In|1|
|d_req_addr_o|Out|32|
|d_req_write_o|Out|1|
|d_req_wdata_o|Out|32|
|d_req_wstrb_o|Out|4|
|d_rsp_valid_i|In|1|
|d_rsp_ready_o|Out|1|
|d_rsp_rdata_i|In|32|
|d_rsp_error_i|In|1|
|timer_irq_i|In|1|
|external_irq_i|In|1|
|halted_o|Out|1|
|trap_o|Out|1|
|trap_cause_o|Out|8|
|trap_badaddr_o|Out|32|
|retire_valid_o|Out|1|
|retire_pc_o|Out|32|
|retire_instruction_o|Out|32|
