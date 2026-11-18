# Test Plan

## T-timing

Function: F-timing; requirement: R-DC3B00D-001.

Stimulus: First hold reset high for 3 cycles, then release it; select cache_hit=1,state=MN_A,PUTM,source=owner=3 to establish WB enable=1, apply a 2ns high reset pulse at a falling edge and release it before the next rising edge; continuously change data/address separately with valid=0/1 and sample WB across reset. Change the message type between edges to verify that the other combinational outputs do not depend on the clock. Drive native ports on falling edges; do not read or write through the hierarchy.

Expected: All outputs except the three WB items change combinationally with the current inputs. On each rising edge of clk, dc3_wb_data and dc3_wb_addr are updated by unconditionally sampling dc2_message_data/address respectively, even when reset=1 or message_valid=0; these two items are not reset. dc3_wb_enable is immediately cleared to 0 on the rising edge of reset; it remains 0 at every rising edge while reset is high, and after release it takes the current processing condition at every rising edge: 1 when the selected state is MN_A, the message is PUTM, and source equals the selected owner; otherwise 0. This condition is not gated by dc2_message_valid. A high reset pulse shorter than one cycle that does not span a rising edge also clears the WB enable; reset does not force other outputs to zero.

Check: An independent input-history predictor reads only inputs and history, and performs bitwise four-state comparisons of all actual/expected values after combinational signals have settled for 1ns, 1ns after a rising edge, and 1ns after reset rises. Do not compare uninitialized WB data/address before the first valid clock edge. Report UVM_ERROR for any mismatch and identify the seed/sampling point; actual stimulus and boundary counts must be nonempty, otherwise report an error. Sample combinational inputs after they have settled for 1ns following a change; sample WB 1ns after a rising edge, and asynchronous reset 1ns after assertion between edges. Reset first at startup and allow at least one clock edge; WB data/address are undefined before the first edge.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-select

Function: F-select; requirement: R-DC3B00D-002.

Stimulus: Exhaustively cover overlaps of TSHR/cache hits and the replacement type, supply three different sets of state/sharers/owner, and toggle TSHR.valid/address; source/owner=0,3,7,15, sharers=0, walking-one, two bits, ffff; exercise all four pending combinations and two different sets of addresses. Drive native ports on falling edges; do not read or write through the hierarchy.

Expected: The priority for selecting state/sharers/owner is a TSHR hit, a cache hit, then replacement metadata when neither of the first two applies and the message is REPLACEMENT; otherwise N/0/TILE_MEMORY_ID. TSHR valid and stored address do not participate in selection; use the entry's state[54:52], sharers[19:4], and owner[3:0]. All message addresses always come from dc2_message_address. The requester bitmap q is 16 bits with the bit corresponding to source set to 1; the owner bitmap o and memory bitmap m are analogous, with bit0 corresponding to tile0. k is the number of set bits in the selected sharers modulo 16, so ffff counts as 0. dc3_pending is message_valid or instr_request_pending; pending_address takes the dc2 address when message_valid=1, otherwise it unconditionally takes the instr address. Conflicting hits follow the priority above; all 8 states, 32 message types, and full-width metadata are allowed. The owner/source range is 0..15; do not add system-consistency assumptions.

Check: An independent input-history predictor reads only inputs and history, and performs bitwise four-state comparisons of all actual/expected values after combinational signals have settled for 1ns, 1ns after a rising edge, and 1ns after reset rises. Do not compare uninitialized WB data/address before the first valid clock edge. Report UVM_ERROR for any mismatch and identify the seed/sampling point; actual stimulus and boundary counts must be nonempty, otherwise report an error. All outputs are combinational; selection and counting are not gated by valid, reset, or network available.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-gets

Function: F-gets; requirement: R-DC3B00D-003.

Stimulus: Exhaustively enumerate state=0..7, GETS/GETM, owner/source equal and different, q already present or absent, no/single/multiple sharers, and the priority relationship between cache_hit and TSHR_hit, with both valid and network_available taking 0/1; cross with instruction pending in the same cycle. Drive native ports on falling edges; do not read or write through hierarchy.

Expected: State encodings N=0,M=1,S=2,I=3,S_D=4,MN_A=5,NS_D=6,SN_A=7. GETS=0: N transitions to NS_D, adds q, allocates TSHR, and sends FWD_GETS to memory; M transitions to S_D, adds q and o, sets owner to TILE_ID, allocates TSHR and sets cache validity to 0, and sends FWD_GETS to the old owner; S or I transitions to S, adds q, updates cache, and sends a DATA response to q. GETM=1: N transitions to M, sets owner to source, updates cache, and sends FWD_GETM to memory; M remains M but sets owner to source, updates cache, and sends FWD_GETM to the old owner; S transitions to M, sets owner to source, clears sharers to 0, updates cache, sends DATA to q and INV to the old sharers; I transitions to M, sets owner to source, updates cache and sends DATA to q. GETS/GETM in other states produces no protocol action and preserves metadata. Even if source is already in sharers or equals owner, updates are still requested according to the actions above; see below for valid gating of whether actions take effect. There is no internal directory storage across cycles.

Checks: An independent input-history predictor reads only inputs and history, and performs bitwise four-state comparisons of all actual/expected values after 1ns of combinational settling, 1ns after a rising edge, and 1ns after reset rises. Do not compare uninitialized WB data/address before the first valid clock. Report UVM_ERROR for any mismatch and identify the seed/sample point; actual stimulus and boundary counts must be nonempty, otherwise report an error. Compute results combinationally after selecting metadata; all destinations, counts, and message selections read state/sharers/owner from before the action.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-put

Function: F-put; Requirement: R-DC3B00D-004.

Stimulus: For PUTS, PUTM, and DATA, exhaustively enumerate state0..7 and owner relationships; sharers=0, q only, non-q only, multiple including q, and ffff; set input message_data and cache_data to different walking-patterns, specifically testing S_D non-owner PUTM, M owner PUTM, and MN_A owner PUTM; valid0/1. Drive native ports on falling edges; do not read or write through hierarchy.

Expected: PUTS=2: N/M/I/NS_D only sends PUTACK to q; S removes q, transitions to I when k=1, otherwise remains S and updates cache, and sends PUTACK to q in both cases; S_D/SN_A removes q and edits TSHR, and sends PUTACK to q; otherwise no action. PUTM=3: N/I/NS_D only sends PUTACK; M always sends PUTACK, and only when source equals owner does it transition to I, set owner to TILE_ID, save input message_data and update cache; S removes q, updates cache and sends PUTACK only for a non-owner; S_D always sends PUTACK, and only for a non-owner does it remove q and retire TSHR while updating cache; MN_A always sends PUTACK, and when sent by the owner additionally generates the WB enable condition but does not change metadata; otherwise no action. DATA=9: S_D or NS_D transitions to S, saves message_data, retires TSHR and updates cache; otherwise no action. The non-owner branch of PUTM in S_D retires TSHR even if the next state remains S_D; do not replace this behavior with speculation about abstract state stability. PUTM in S with the owner as source has no PUTACK.

Checks: An independent input-history predictor reads only inputs and history, and performs bitwise four-state comparisons of all actual/expected values after 1ns of combinational settling, 1ns after a rising edge, and 1ns after reset rises. Do not compare uninitialized WB data/address before the first valid clock. Report UVM_ERROR for any mismatch and identify the seed/sample point; actual stimulus and boundary counts must be nonempty, otherwise report an error. All are combinational actions; the WB enable for PUTM is sampled separately at the clock edge. A single sharer is determined by k=1, with no additional constraint on whether q is actually in sharers.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-management

Function: F-management; Requirement: R-DC3B00D-005.

Stimulus: Exhaustively enumerate state0..7 and all 32 types, crossing TSHR/cache/replacement selection, focusing on REPLACEMENT, DIR_FLUSH, MC_ACK, WB_GEN, and unlisted encodings 4..8,10,11,15,17..31; use valid0/1 for each, observing all commands and default payloads separately. Drive native ports on falling edges; do not read or write through hierarchy.

Expected: REPLACEMENT=12: I transitions to MN_A, allocates TSHR, and sends a WB response to memory; S transitions to SN_A, allocates TSHR, sends a WB response to memory and RECALL to the old sharers; M transitions to MN_A, allocates TSHR, and sends RECALL to the old owner; otherwise no action. DIR_FLUSH=13: I only sends a WB response to memory; S transitions to I, updates cache and sends a WB response to memory; M only sends FWD_FLUSH to the old owner; otherwise no action. MC_ACK=14: MN_A or SN_A transitions to N, retires TSHR and sets TSHR entry.valid=0 and cache validity=0, without updating cache; otherwise no action. WB_GEN=16 sends a WB response to memory in every state, with metadata unchanged. All other message encodings and unlisted state/request combinations produce no protocol action, preserve selected metadata and cache data, and default cache validity to 1. No SIMULATION, COHERENCE_INJECTION, or DISPLAY_COHERENCE macros; unexposed internal diagnostics are not required. Replacement suppresses cache updates, even on a cache hit.

Checks: An independent input-history predictor reads only inputs and history, and performs bitwise four-state comparisons of all actual/expected values after 1ns of combinational settling, 1ns after a rising edge, and 1ns after reset rises. Do not compare uninitialized WB data/address before the first valid clock. Report UVM_ERROR for any mismatch and identify the seed/sample point; actual stimulus and boundary counts must be nonempty, otherwise report an error. The protocol is a combinational function. Unlisted combinations still execute the pending, PLRU, payload, and unconditional WB sampling rules; not all outputs are zero.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-storage

Function: F-storage; Requirement: R-DC3B00D-006.

Stimulus: Cross each action above with valid, cache_hit, and cache_valid; use index 0/15 with the original TSHR index different from empty_index; use 0, all ones, and walking bits for address tag/index/offset respectively, and set data sources to opposite patterns; confirm that payloads are still compared when all enables are 0. Drive native ports on falling edges; do not read or write through hierarchy.

Expected: The protocol actions above are divided into cache update, TSHR allocation, TSHR edit, TSHR retirement, ACK discard of TSHR, and no action. For cache update or TSHR retirement, message_valid and non-REPLACEMENT make cache_enable=1; on retirement, TSHR_enable also takes message_valid. For TSHR allocation, TSHR_enable=message_valid and index takes tshr_empty_index; cache_enable is asserted only when message_valid and non-REPLACEMENT and cache_hit. Edit/ACK discard only sets TSHR_enable=message_valid, cache_enable=0. All other enables are 0. Except for allocation, TSHR index always takes dc2_message_tshr_index. The TSHR payload from high to low is valid, next_state, dc2 address, next_sharers, next_owner; valid is 1 only for allocation or edit actions, even when message_valid=0. Cache state/sharers/owner/data take the post-action metadata; data defaults to cache_data and takes message_data only when saving is specified; validity defaults to 1 and is 0 only for GETS/M and MC_ACK/MN_A or SN_A. cache set=dc2 address[12:6], tag=dc2 address[31:13], way=cache_way; the TSHR stored address always uses the dc2 address, ignoring input entry.address.

Checks: An independent input-history predictor reads only inputs and history, and performs bitwise four-state comparisons of all actual/expected values after 1ns of combinational settling, 1ns after a rising edge, and 1ns after reset rises. Do not compare uninitialized WB data/address before the first valid clock. Report UVM_ERROR for any mismatch and identify the seed/sample point; actual stimulus and boundary counts must be nonempty, otherwise report an error. Enables and payloads are all combinational; do not force payloads to 0 when enables are 0. Actions are determined only by current metadata and message type.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-replacement

Function: F-replacement; Requirement: R-DC3B00D-007.

Stimulus: Cross all actions that can produce cache_enable with hit/valid and REPLACEMENT suppression; drive walking patterns on each of cache_data, source, tag, state, sharers, and owner, use a nonzero dc2 address offset, and confirm the replacement offset is still 0; test PLRU for all valid/type combinations. Drive native ports on falling edges; do not read or write through hierarchy.

Expected: dc3_update_plru_en always equals dc2_message_valid; PLRU set takes dc2 address[12:6], and way takes cache_way. dc3_replacement_enqueue is 1 only when cache_enable=1, cache_hit=0, and cache_valid=1. The replacement payload is always constructed from cache metadata, independently of enqueue: from high to low, cache_data, dc2_message_source, cache_tag, dc2 address index, 6-bit zero offset, cache_state, cache_sharers, cache_owner. A REPLACEMENT message always has cache_enable=0 and therefore does not enqueue into the replacement queue again; a TSHR hit does not mask cache metadata as the replacement payload.

Checks: An independent input-history predictor reads only inputs and history, and performs bitwise four-state comparisons of all actual/expected values after 1ns of combinational settling, 1ns after a rising edge, and 1ns after reset rises. Do not compare uninitialized WB data/address before the first valid clock. Report UVM_ERROR for any mismatch and identify the seed/sample point; actual stimulus and boundary counts must be nonempty, otherwise report an error. All outputs are combinational; an invalid message has PLRU enable 0, while the payload remains well-defined.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-forward

Function: F-forward; Requirement: R-DC3B00D-008.

Stimulus: Cross forwardable GETS/GETM/INV/RECALL/FLUSH actions with message_valid, instruction_pending, and network_available; issue instructions when coherence has no forwarding and when invalid; use different sources/addresses and cover every destination tile; generate response and instruction forwarding simultaneously. Drive native ports on falling edges; do not read or write through hierarchy.

Expected: When message_valid and the protocol has forwarding, coherence forwarding takes priority: valid=1, and the 43-bit payload from high to low is dc2 source, 4-bit type, dc2 address, uncoherent=0, requestor=0; types are FWD_GETS=4/FWD_GETM=5/INV=6/RECALL=8/FWD_FLUSH=15, and the destination is determined by the actions above. Otherwise, when instr_request_pending and network_available, issue an instruction request: valid=1, source=TILE_ID, type=4, address=instr address, uncoherent=1, requestor=1, destination=memory bitmap, and instr_dequeue=1 simultaneously. In all other cases forwarding valid, payload, destination, and dequeue are all 0. In the coherence branch, dequeue=0. There is no ready-based holding protocol; input changes immediately trigger re-arbitration. Priority blocks instruction dequeue only when actual coherence forwarding occurs.

Checks: An independent input-history predictor reads only inputs and history, and performs bitwise four-state comparisons of all actual/expected values after 1ns of combinational settling, 1ns after a rising edge, and 1ns after reset rises. Do not compare uninitialized WB data/address before the first valid clock. Report UVM_ERROR for any mismatch and identify the seed/sample point; actual stimulus and boundary counts must be nonempty, otherwise report an error. Arbitration is combinational; coherence forwarding is not gated by network_available. When a valid message does not require forwarding, instruction forwarding can still be issued in the same cycle.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-response

Function: F-response; Requirement: R-DC3B00D-009.

Stimulus: For PUTACK, DATA, WB, and actions with no response, cross valid, cache_hit, and REPLACEMENT, with data opposite to cache_data and random in every 32-bit group; use sharers with 0..16 bits set, including ffff wraparound, and compare all 624 bits and has_data/destination, including when invalid. Drive native ports on falling edges; do not read or write through hierarchy.

Expected: dc3_response_valid is only message_valid AND the protocol producing a response. The 624-bit response from high to low: 512-bit data, 64-bit all-ones dirty_mask, 4-bit dc2 source, 4-bit packet_type, 32-bit dc2 address, 4-bit k, from_directory=1, uncoherent=0, requestor=0. data takes cache_data when cache_hit and non-REPLACEMENT, otherwise message_data; this selection differs from the selection of data saved to cache by the protocol. packet_type is PUTACK=7, DATA=9, or WB=11, and is 0 when there is no response action; has_data is 1 only for DATA/WB actions and is not gated by message_valid. The response destination is q or memory as described above, defaulting to the old sharers when there is no response action. With 16 sharers, k=0; DIR_FLUSH still uses cache_data even on a cache hit, and REPLACEMENT still uses message_data even on a cache hit. There is no response backpressure or holding across cycles.

Checks: An independent input-history predictor reads only inputs and history, and performs bitwise four-state comparisons of all actual/expected values after 1ns of combinational settling, 1ns after a rising edge, and 1ns after reset rises. Do not compare uninitialized WB data/address before the first valid clock. Report UVM_ERROR for any mismatch and identify the seed/sample point; actual stimulus and boundary counts must be nonempty, otherwise report an error. The response payload, has_data, and destinations are still defined by the combinational rules above when response_valid=0; they must not all be cleared to zero or left uncompared.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories
