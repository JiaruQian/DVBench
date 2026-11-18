# lm32_dcache Behavioral Specification

Sampling occurs on rising edges of the single clock clk_i. Fixed macros enable the data cache and active-high asynchronous reset. Both complete configurations must be retained: sets=512 and 64; all other native parameters use their default values. Legal inputs are stable before the sampling edge; refill_ready is valid only within the refill window of an initiated miss. Unknown values before initialization and in unwritten data must not be inferred to be zero.

### R-bb5eabcd72c0cd-001 — Asynchronous Reset and Invalidation Scan

rst_i is an active-high asynchronous reset; control enters the invalidation scan 1ns after assertion: stall_request=1, restart_request=0, refill_request=0, refilling=0, and refill_address is unknown. After deassertion, all tags are invalidated one cycle at a time from set=sets-1 down to 0, entering the query-ready phase after exactly sets rising edges.

All registered control outputs update 1ns after an active rising edge or reset event; RAM updates only on rising edges. The scan cursor is continuously reloaded during reset. Neither reset nor dflush clears the data RAM; previously written contents are retained. No definite numerical value is guaranteed for initially uninitialized data.

### R-bb5eabcd72c0cd-002 — Read Address and Data

A rising edge with stall_x=0 latches the word index and set index of address_x; after 1ns, load_data continuously reflects the selected stored word. With stall_x=1, the previous read index is retained.

load_data is not masked by load_q_m or a tag hit; no output is guaranteed before the first reset. The lowest 2 bits of the 32-bit address do not participate in the word index, and the highest 4 bits do not participate in the tag; see the two profiles in the port documentation.

### R-bb5eabcd72c0cd-003 — Hits and Misses

In the query-ready phase, the valid tag of the latched read set is compared with the current address_m[27:tag_lsb]. When load_q_m=1 and stall_m=0 and there is no hit, refill is entered after the edge, refill_request=1, and the full 32-bit address_m is saved to refill_address.

Miss detection uses the inputs stable before the edge and the latched tag; address_x usually leads by one cycle, and the two addresses are allowed to differ, with behavior defined by this clause. load_q_m=0, stall_m=1, or a hit does not initiate a miss; a miss takes priority over dflush on the same edge.

### R-bb5eabcd72c0cd-004 — Four-Word refill

During the refill phase, 4 32-bit refill_data words are accepted in sequence on rising edges with refill_ready=1 and written to word0, 1, 2, 3 of the line containing the saved address; the starting point is independent of the input address's word offset; ready=0 does not advance progress. When the last word is written, the tag is marked valid and the query-ready phase is reentered.

refill_request is 1 only for the cycle after entering refill and is deasserted on the first rising edge of refill; refill_address is retained until the next miss or reset. A legal environment provides refill_ready only within the refill window and deasserts it after the fourth word; the tag of an incomplete refill is invalid.

### R-bb5eabcd72c0cd-005 — Stall and Restart

stall_request is 1 during the invalidation scan or refill phase and 0 during the query-ready phase. After each rising edge, refilling reflects whether the phase before the edge was refill, lagging phase transitions by one cycle. restart_request is set to 1 when the last word is accepted; it is cleared on a rising edge in the query-ready phase with stall_a=0, and otherwise retained.

The final refill on the same edge takes priority in setting restart; clearing according to stall_a occurs only on the next query-ready edge. Progress is retained through arbitrary gaps while waiting for refill_ready, and stall_a can extend restart.

### R-bb5eabcd72c0cd-006 — Store Hits and Byte Selection

In the query-ready phase, when store_q_m=1 and the tag of the latched read set hits the current address_m and stall_m=0, the word corresponding to address_m is written. Bit j of store_byte_select selects store_data[8*j+:8]. No write occurs on a miss or with stall_m=1.

Writes take effect 1ns after the rising edge; load_q_m and store_q_m can be independent. In the 512-set configuration, unselected bytes retain the original values of the target write word; in the 64-set configuration, unselected bytes are taken from load_data before the edge, so unselected bytes can differ when the two addresses select different words.

### R-bb5eabcd72c0cd-007 — Software flush and Priority

When query-ready and there is no acceptable load miss, dflush=1 makes the next phase the invalidation scan, which then invalidates all tags in sequence over sets rising edges. dflush and load requests are ignored during the scan.

The scan cursor decrements from sets-1 to 0 and wraps around; completion of the scan returns to query-ready. When a miss and dflush both occur on the same edge, the miss is handled first; dflush is not queued during refill. Data is not zeroed.

### R-bb5eabcd72c0cd-008 — Indexing and Conflict Replacement

Fixed single-way direct mapping: a line is 16 bytes; for 512 sets, set=address[12:4], word=address[12:2], tag=address[27:13]; for 64 sets, set=address[9:4], word=address[9:2], tag=address[27:10]. When different tags map to the same set, a new refill replaces the old tag and all 4 words.

The read index comes from the latched address_x; the write word index comes from address_m or the refill sequence. The native parameters base_address and limit do not determine the range in the fixed implementation; the fixed macros CFG_DCACHE_BASE_ADDRESS=0, CFG_DCACHE_LIMIT=0x0fffffff determine that the highest tag bit is 27. associativity=1, bytes_per_line=16.

