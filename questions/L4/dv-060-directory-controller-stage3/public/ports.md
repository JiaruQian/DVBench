# Native Ports and Fixed Parameters

The DUT is directory_controller_stage3 and the model is dvbench_model; both declare parameters TILE_ID=0, TILE_MEMORY_ID=0; this task tests only this profile. There are no inout ports, all ports are unsigned, and multi-bit port logic vectors are [width-1:0]. Custom packed typedefs of equal width may be defined in the submission, without depending on hidden header files. All outputs are compared within the specified windows; rules for invalid payloads are still given in the spec.

| Name | Direction | Width |
|---|---|---|
| clk | In | 1 |
| reset | In | 1 |
| ni_forwarded_request_network_available | In | 1 |
| instr_request_pending | In | 1 |
| instr_request_address | In | 32 |
| dc2_message_valid | In | 1 |
| dc2_message_type | In | 5 |
| dc2_message_address | In | 32 |
| dc2_message_data | In | 512 |
| dc2_message_source | In | 4 |
| dc2_replacement_state | In | 3 |
| dc2_replacement_sharers_list | In | 16 |
| dc2_replacement_owner | In | 4 |
| dc2_message_tshr_hit | In | 1 |
| dc2_message_tshr_index | In | 4 |
| dc2_message_tshr_entry_info | In | 56 |
| dc2_message_cache_hit | In | 1 |
| dc2_message_cache_valid | In | 1 |
| dc2_message_cache_state | In | 3 |
| dc2_message_cache_sharers_list | In | 16 |
| dc2_message_cache_owner | In | 4 |
| dc2_message_cache_tag | In | 19 |
| dc2_message_cache_data | In | 512 |
| dc2_message_cache_way | In | 3 |
| tshr_empty_index | In | 4 |
| dc3_instr_request_dequeue | Out | 1 |
| dc3_pending | Out | 1 |
| dc3_pending_address | Out | 32 |
| dc3_update_cache_enable | Out | 1 |
| dc3_update_cache_validity_bit | Out | 1 |
| dc3_update_cache_set | Out | 7 |
| dc3_update_cache_way | Out | 3 |
| dc3_update_cache_tag | Out | 19 |
| dc3_update_cache_state | Out | 3 |
| dc3_update_cache_sharers_list | Out | 16 |
| dc3_update_cache_owner | Out | 4 |
| dc3_update_cache_data | Out | 512 |
| dc3_update_plru_en | Out | 1 |
| dc3_update_plru_set | Out | 7 |
| dc3_update_plru_way | Out | 3 |
| dc3_update_tshr_enable | Out | 1 |
| dc3_update_tshr_index | Out | 4 |
| dc3_update_tshr_entry_info | Out | 56 |
| dc3_replacement_enqueue | Out | 1 |
| dc3_replacement_request | Out | 571 |
| dc3_wb_enable | Out | 1 |
| dc3_wb_data | Out | 512 |
| dc3_wb_addr | Out | 32 |
| dc3_forwarded_request | Out | 43 |
| dc3_forwarded_request_valid | Out | 1 |
| dc3_forwarded_request_destinations | Out | 16 |
| dc3_response | Out | 624 |
| dc3_response_valid | Out | 1 |
| dc3_response_has_data | Out | 1 |
| dc3_response_destinations | Out | 16 |

32-bit address: tag[31:13], index[12:6], offset[5:0]. TSHR entry[55]valid, [54:52]state, [51:20]address, [19:4]sharers, [3:0]owner.
571-bit replacement: data[570:59], source[58:55], address[54:23], state[22:20], sharers[19:4], owner[3:0].
43-bit forward: source[42:39], packet_type[38:35], address[34:3], uncoherent[2], requestor[1:0].
624-bit response: data[623:112], dirty_mask[111:48], source[47:44], packet_type[43:40], address[39:8], sharers_count[7:4], from_directory[3], uncoherent[2], requestor[1:0].
Clock: clk rising edge; reset is active-high asynchronous and clears only WB enable; WB data/address sample unconditionally on the edge.
