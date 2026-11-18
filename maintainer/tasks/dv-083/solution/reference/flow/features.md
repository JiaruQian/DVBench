# feature_id

## F1

- requirement_ids: R-bb5eabcd72c0cd-001
- module: lm32_dcache
- definition: rst_i is an active-high asynchronous reset; control enters the invalidation scan 1ns after assertion: stall_request=1, restart_request=0, refill_request=0, refilling=0, and refill_address is unknown. After deassertion, all tags are invalidated one cycle at a time from set=sets-1 down to 0, entering the query-ready phase after exactly sets rising edges.
- interface: rst_i, clk_i, stall_request, restart_request, refill_request, refill_address, refilling, load_data
- timing: All registered control outputs update 1ns after an active rising edge or reset event; RAM updates only on rising edges. The scan cursor is continuously reloaded during reset.
- boundary: Neither reset nor dflush clears the data RAM; previously written contents are retained. No definite numerical value is guaranteed for initially uninitialized data.

## F2

- requirement_ids: R-bb5eabcd72c0cd-002
- module: lm32_dcache
- definition: A rising edge with stall_x=0 latches the word index and set index of address_x; after 1ns, load_data continuously reflects the selected stored word. With stall_x=1, the previous read index is retained.
- interface: clk_i, stall_x, address_x, load_data
- timing: load_data is not masked by load_q_m or a tag hit; no output is guaranteed before the first reset.
- boundary: The lowest 2 bits of the 32-bit address do not participate in the word index, and the highest 4 bits do not participate in the tag; see the two profiles in the port documentation.

## F3

- requirement_ids: R-bb5eabcd72c0cd-003
- module: lm32_dcache
- definition: In the query-ready phase, the valid tag of the latched read set is compared with the current address_m[27:tag_lsb]. When load_q_m=1 and stall_m=0 and there is no hit, refill is entered after the edge, refill_request=1, and the full 32-bit address_m is saved to refill_address.
- interface: clk_i, address_x, address_m, load_q_m, stall_m, refill_request, refill_address, stall_request
- timing: Miss detection uses the inputs stable before the edge and the latched tag; address_x usually leads by one cycle, and the two addresses are allowed to differ, with behavior defined by this clause.
- boundary: load_q_m=0, stall_m=1, or a hit does not initiate a miss; a miss takes priority over dflush on the same edge.

## F4

- requirement_ids: R-bb5eabcd72c0cd-004
- module: lm32_dcache
- definition: During the refill phase, 4 32-bit refill_data words are accepted in sequence on rising edges with refill_ready=1 and written to word0, 1, 2, 3 of the line containing the saved address; the starting point is independent of the input address's word offset; ready=0 does not advance progress. When the last word is written, the tag is marked valid and the query-ready phase is reentered.
- interface: clk_i, refill_ready, refill_data, refill_address, refill_request, stall_request
- timing: refill_request is 1 only for the cycle after entering refill and is deasserted on the first rising edge of refill; refill_address is retained until the next miss or reset.
- boundary: A legal environment provides refill_ready only within the refill window and deasserts it after the fourth word; the tag of an incomplete refill is invalid.

## F5

- requirement_ids: R-bb5eabcd72c0cd-005
- module: lm32_dcache
- definition: stall_request is 1 during the invalidation scan or refill phase and 0 during the query-ready phase. After each rising edge, refilling reflects whether the phase before the edge was refill, lagging phase transitions by one cycle. restart_request is set to 1 when the last word is accepted; it is cleared on a rising edge in the query-ready phase with stall_a=0, and otherwise retained.
- interface: clk_i, stall_a, stall_request, restart_request, refilling, refill_ready
- timing: The final refill on the same edge takes priority in setting restart; clearing according to stall_a occurs only on the next query-ready edge.
- boundary: Progress is retained through arbitrary gaps while waiting for refill_ready, and stall_a can extend restart.

## F6

- requirement_ids: R-bb5eabcd72c0cd-006
- module: lm32_dcache
- definition: In the queryable phase, when store_q_m=1, the tag of the latched read set hits the current address_m, and stall_m=0, write the word corresponding to address_m. Bit j of store_byte_select selects store_data[8*j+:8]. Do not write on a miss or when stall_m=1.
- interface: clk_i, store_q_m, stall_m, address_m, store_data, store_byte_select, load_data, address_x
- timing: The write takes effect 1ns after the rising edge; load_q_m and store_q_m can be independent.
- boundary: In the 512-set configuration, unselected bytes retain the original values in the target write word; in the 64-set configuration, unselected bytes come from load_data before the edge, so unselected bytes may differ when the two addresses select different words.

## F7

- requirement_ids: R-bb5eabcd72c0cd-007
- module: lm32_dcache
- definition: When queryable and there is no acceptable load miss, dflush=1 causes the next phase to enter the invalidation scan, which then invalidates all tags sequentially over sets rising edges. Ignore dflush and load requests during the scan.
- interface: clk_i, dflush, load_q_m, stall_m, stall_request, refill_request, load_data
- timing: The scan cursor decrements from sets-1 to 0 and wraps around; return to the queryable phase when the scan ends.
- boundary: When a miss and dflush both occur on the same edge, handle the miss first; dflush is not queued during refill. Data is not cleared to zero.

## F8

- requirement_ids: R-bb5eabcd72c0cd-008
- module: lm32_dcache
- definition: Fixed single-way direct mapping: a line is 16 bytes; for 512 sets, use set=address[12:4], word=address[12:2], and tag=address[27:13]; for 64 sets, use set=address[9:4], word=address[9:2], and tag=address[27:10]. When different tags map to the same set, a new refill replaces the old tag and all 4 words.
- interface: address_x, address_m, refill_address, load_data
- timing: The read index comes from the latched address_x; the write word index comes from address_m or the refill sequence.
- boundary: The native parameters base_address and limit do not determine the range in the fixed implementation; the fixed macros CFG_DCACHE_BASE_ADDRESS=0 and CFG_DCACHE_LIMIT=0x0fffffff determine that the highest tag bit is 27. associativity=1, bytes_per_line=16.

