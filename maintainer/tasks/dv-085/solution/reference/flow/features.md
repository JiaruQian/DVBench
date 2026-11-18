## F-001

requirement_ids: ["R-940d3642f8d2-001"]

module: cv32e40p_icache

definition: This problem fixes TAG_WIDTH=20, INDEX_WIDTH=6, OFFSET_WIDTH=6; 4 ways and 64 sets, with address tag[31:12], set[11:6], and offset[5:0]. rst_ni is active-low and asynchronous; it clears all valid/tag/data, the historical address, the global replacement tree, and flush progress, and returns to idle. In idle, instr_gnt_o=1, including during reset; all other responses/requests/events are 0, mem_req_len_o is always 3, and mem_req_size_o is always 3.

interface: ["clk_i", "rst_ni", "instr_req_i", "instr_gnt_o", "instr_addr_i", "instr_rvalid_o", "instr_rdata_o", "flush_i", "flush_ack_o", "mem_req_valid_o", "mem_req_addr_o", "mem_req_len_o", "mem_req_size_o", "mem_req_ack_i", "mem_rsp_valid_i", "mem_rsp_data_i", "mem_rsp_last_i", "miss_o", "miss_event_o"]

timing: The edges and stable windows specified in this clause.

boundary: Deterministic binary inputs, native fixed port ranges; no additional guarantees are made for domains undefined by this clause.

## F-002

requirement_ids: ["R-940d3642f8d2-002"]

module: cv32e40p_icache

definition: In idle, a rising edge with instr_req_i=1 captures the address tag and enters lookup; in the next cycle, the set index of the current instr_addr_i is used combinationally to read all ways, and valid entries are matched against the captured tag. If multiple ways match, the highest-numbered way is selected. During a hit, instr_rvalid_o=1 and instr_rdata_o is the low 32 bits of the selected line, ignoring offset; the next rising edge returns to idle. Changing the input address between edges changes the current lookup set and output; this is not a registered response.

interface: ["clk_i", "rst_ni", "instr_req_i", "instr_gnt_o", "instr_addr_i", "instr_rvalid_o", "instr_rdata_o", "flush_i", "flush_ack_o", "mem_req_valid_o", "mem_req_addr_o", "mem_req_len_o", "mem_req_size_o", "mem_req_ack_i", "mem_rsp_valid_i", "mem_rsp_data_i", "mem_rsp_last_i", "miss_o", "miss_event_o"]

timing: The edges and stable windows specified in this clause.

boundary: Deterministic binary inputs, native fixed port ranges; no additional guarantees are made for domains undefined by this clause.

## F-003

requirement_ids: ["R-940d3642f8d2-003"]

module: cv32e40p_icache

definition: On a lookup miss, the combinational outputs are mem_req_valid_o=1, mem_req_addr_o=live instr_addr_i, and miss_o=miss_event_o=1; each rising edge in this state saves the live address without waiting for ACK. After an edge with mem_req_ack_i=1, it enters the refill wait state, and requests/events are cleared to 0. While waiting, mem_rsp_valid_i=1 immediately returns the low 32 bits combinationally, and at the next rising edge the entire line and the saved address tag are written into the selected way and valid is set, followed by a return to idle; it does not wait for mem_rsp_last_i or use it to determine whether to write. When mem_rsp_valid_i=0, it remains waiting; ACK/response outside the applicable domain does not trigger a new request.

interface: ["clk_i", "rst_ni", "instr_req_i", "instr_gnt_o", "instr_addr_i", "instr_rvalid_o", "instr_rdata_o", "flush_i", "flush_ack_o", "mem_req_valid_o", "mem_req_addr_o", "mem_req_len_o", "mem_req_size_o", "mem_req_ack_i", "mem_rsp_valid_i", "mem_rsp_data_i", "mem_rsp_last_i", "miss_o", "miss_event_o"]

timing: The edges and stable windows specified in this clause.

boundary: Deterministic binary inputs, native fixed port ranges; no additional guarantees are made for domains undefined by this clause.

## F-004

requirement_ids: ["R-940d3642f8d2-004"]

module: cv32e40p_icache

definition: refill way selection uses the valid bits of the set addressed by the current live address, preferring the lowest-numbered invalid way; when all ways are valid, it uses a global 4-way tree-PLRU. Reset sets each selection bit of the tree to 0, so the initial victim=0; after accessing a way, the root and the corresponding half-tree are pointed to the other side, and following the selection path yields the victim. In any cycle, whenever the current combinational tag comparison hits or a refill occurs, this global tree is updated, not only during lookup cycles; the refill update has priority and uses its selected way. flush does not reset the tree.

interface: ["clk_i", "rst_ni", "instr_req_i", "instr_gnt_o", "instr_addr_i", "instr_rvalid_o", "instr_rdata_o", "flush_i", "flush_ack_o", "mem_req_valid_o", "mem_req_addr_o", "mem_req_len_o", "mem_req_size_o", "mem_req_ack_i", "mem_rsp_valid_i", "mem_rsp_data_i", "mem_rsp_last_i", "miss_o", "miss_event_o"]

timing: The edges and stable windows specified in this clause.

boundary: Deterministic binary inputs, native fixed port ranges; no additional guarantees are made for domains undefined by this clause.

## F-005

requirement_ids: ["R-940d3642f8d2-005"]

module: cv32e40p_icache

definition: In a non-flush phase, flush_i causes a transition to flush at the next edge, taking priority over normal phase transitions, but the current combinational response and any refill write that would otherwise execute at that edge still occur. flush clears the valid bits of the current set at each rising edge; starting from reset progress 0, it alternates only between set 0 and set 1 and cannot reach 63, so flush_ack_o is always 0 and it does not automatically return to idle. Sustained or repeated flush_i does not change this state; only assertion of rst_ni can recover it. During flush, other requests/responses are ignored, and data and tag are not cleared; only valid is cleared. reset sets progress back to 0.

interface: ["clk_i", "rst_ni", "instr_req_i", "instr_gnt_o", "instr_addr_i", "instr_rvalid_o", "instr_rdata_o", "flush_i", "flush_ack_o", "mem_req_valid_o", "mem_req_addr_o", "mem_req_len_o", "mem_req_size_o", "mem_req_ack_i", "mem_rsp_valid_i", "mem_rsp_data_i", "mem_rsp_last_i", "miss_o", "miss_event_o"]

timing: The edges and stable windows specified in this clause.

boundary: Deterministic binary inputs, native fixed port ranges; no additional guarantees are made for domains undefined by this clause.
