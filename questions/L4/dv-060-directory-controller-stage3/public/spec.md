# Directory Controller Stage 3

The complete native scope of top-level directory_controller_stage3, including all protocol states, messages, metadata priorities, storage updates, instruction and coherence forwarding, responses, replacement, and WB. Fixed profile TILE_ID=0, TILE_MEMORY_ID=0 (module parameter defaults), 16 tiles, 512-bit cache line; do not substitute the same-named system macro's default value of 15 for the module parameter. All inputs are known 0/1; all native inputs may be combined independently. Input metadata is provided by the upstream stage each cycle; this module does not maintain a directory table itself; do not reduce the scope to only conventional MSI paths. 10ns clock, drive on falling edges, observe after 1ns of combinational settling and 1ns after rising edges; asynchronous reset may be applied between edges. See ports.md for complete native bit packing. The action names below describe behavior and do not imply access to internal implementation.

## R-DC3B00D-001 — Combinational Timing and WB Reset

All outputs except the three WB items change combinationally with current inputs. The clk rising edge updates dc3_wb_data and dc3_wb_addr, unconditionally sampling dc2_message_data/address respectively, even when reset=1 or message_valid=0; these two items are not reset. dc3_wb_enable clears to 0 immediately on the reset rising edge; it remains 0 on every rising edge while reset is high, and after deassertion takes the current processing condition on every rising edge: 1 when the selected state is MN_A, the message is PUTM, and source equals the selected owner, and 0 otherwise. This condition is not gated by dc2_message_valid.

Sample after 1ns of settling following a combinational input change; sample WB 1ns after the rising edge, and asynchronous reset 1ns after assertion between edges. At startup, reset first and pass through at least one clock edge; WB data/address are undefined before the first edge. A reset-high pulse shorter than one cycle that does not cross a rising edge also clears WB enable; reset does not force other outputs to zero.

## R-DC3B00D-002 — Metadata Selection, pending, and Bitmaps

The priority for selecting state/sharers/owner is TSHR hit, cache hit, replacement metadata when neither of the former applies and the message is REPLACEMENT, otherwise N/0/TILE_MEMORY_ID. TSHR valid and stored address do not participate in selection; use the entry's state[54:52], sharers[19:4], and owner[3:0]. All message addresses always come from dc2_message_address. The requestor bitmap q is 16 bits with the bit corresponding to source set to 1; the owner bitmap o and memory bitmap m are formed similarly, with bit0 corresponding to tile0. k is the number of set bits in the selected sharers modulo 16, so ffff counts as 0. dc3_pending is message_valid or instr_request_pending; pending_address takes the dc2 address when message_valid=1, otherwise unconditionally takes the instr address.

All outputs are combinational; selection and counting are not gated by valid, reset, or network available. Conflicting hits follow the priority above; all 8 states, 32 message types, and full-width metadata are allowed. owner/source range is 0..15; do not add system consistency assumptions.

## R-DC3B00D-003 — GETS/GETM State and Data Actions

State encodings are N=0,M=1,S=2,I=3,S_D=4,MN_A=5,NS_D=6,SN_A=7. GETS=0: N transitions to NS_D, adds q, allocates TSHR, and sends FWD_GETS to memory; M transitions to S_D, adds q and o, sets owner to TILE_ID, allocates TSHR and sets cache validity to 0, and sends FWD_GETS to the old owner; S or I transitions to S, adds q, updates cache, and sends a DATA response to q. GETM=1: N transitions to M, sets owner to source, updates cache, and sends FWD_GETM to memory; M remains M but sets owner to source, updates cache, and sends FWD_GETM to the old owner; S transitions to M, sets owner to source, clears sharers to 0, updates cache, and sends DATA to q and INV to the old sharers; I transitions to M, sets owner to source, updates cache and sends DATA to q. GETS/GETM in other states produce no protocol actions and preserve metadata.

Results are computed combinationally after selecting metadata; all destinations, counts, and message selections read state/sharers/owner from before the action. Even if source is already in sharers or equals owner, updates are still requested according to the actions above; see below for valid gating of whether actions take effect. There is no internal directory storage across cycles.

## R-DC3B00D-004 — PUTS/PUTM and DATA Returns

PUTS=2: N/M/I/NS_D only send PUTACK to q; S removes q, transitions to I when k=1 or otherwise remains S, and updates cache, sending PUTACK to q in either case; S_D/SN_A remove q and edit TSHR, sending PUTACK to q; otherwise no action. PUTM=3: N/I/NS_D only send PUTACK; M always sends PUTACK, and only when source equals owner does it transition to I, set owner to TILE_ID, save input message_data and update cache; S only when source is not owner removes q, updates cache and sends PUTACK; S_D always sends PUTACK, and only when source is not owner removes q and retires TSHR while updating cache; MN_A always sends PUTACK, and when sent by owner additionally generates the WB enable condition but does not change metadata; otherwise no action. DATA=9: S_D or NS_D transitions to S, saves message_data, retires TSHR and updates cache; otherwise no action.

All are combinational actions; the WB enable for PUTM is sampled separately at the clock edge. A single sharer is determined by k=1, with no additional constraint on whether q is actually in sharers. PUTM retires TSHR in the non-owner branch of S_D, even if the next state remains S_D; do not replace this behavior with conjectures about abstract state stability. An S-state PUTM whose source is owner has no PUTACK.

## R-DC3B00D-005 — Replacement, flush, ACK, and Default Behavior

REPLACEMENT=12: I transitions to MN_A, allocates TSHR, and sends a WB response to memory; S transitions to SN_A, allocates TSHR, sends a WB response to memory and RECALL to the old sharers; M transitions to MN_A, allocates TSHR, and sends RECALL to the old owner; otherwise no action. DIR_FLUSH=13: I only sends a WB response to memory; S transitions to I, updates cache and sends a WB response to memory; M only sends FWD_FLUSH to the old owner; otherwise no action. MC_ACK=14: MN_A or SN_A transitions to N, retires and sets TSHR entry.valid=0 and cache validity=0, without updating cache; otherwise no action. WB_GEN=16 sends a WB response to memory in every state, leaving metadata unchanged. All other message encodings and unlisted state/request combinations produce no protocol actions, preserving selected metadata and cache data, with cache validity defaulting to 1.

The protocol is a combinational function. Unlisted combinations still execute the pending, PLRU, payload, and unconditional WB sampling rules; not all outputs are zero. There are no SIMULATION, COHERENCE_INJECTION, or DISPLAY_COHERENCE macros; undisclosed internal diagnostics are not required. Replacement suppresses cache updates even on a cache hit.

## R-DC3B00D-006 — TSHR and Cache Command Composition

The protocol actions above are classified as cache update, TSHR allocation, TSHR edit, TSHR retirement, ACK TSHR discard, and no action. For cache update or TSHR retirement, message_valid and non-REPLACEMENT set cache_enable=1; during retirement, TSHR_enable also takes message_valid. During TSHR allocation, TSHR_enable=message_valid and index takes tshr_empty_index; cache_enable is asserted only when message_valid and non-REPLACEMENT and cache_hit. Edit/ACK discard only set TSHR_enable=message_valid, cache_enable=0. Other enables are 0. Except during allocation, TSHR index always takes dc2_message_tshr_index. The TSHR payload, from high to low, is valid, next_state, dc2 address, next_sharers, next_owner; valid is 1 only for allocation or edit actions, even when message_valid=0. Cache state/sharers/owner/data take the post-action metadata; data defaults to cache_data and takes message_data only when saving is specified; validity defaults to 1 and is 0 only for GETS/M and MC_ACK/MN_A or SN_A.

Enables and payloads are both combinational; payloads are not forced to 0 when enables are 0. Actions are determined only by current metadata and message type. cache set=dc2 address[12:6], tag=dc2 address[31:13], way=cache_way; the TSHR stored address always uses the dc2 address, ignoring input entry.address.

## R-DC3B00D-007 — PLRU and Replacement Queue

dc3_update_plru_en always equals dc2_message_valid; PLRU set takes dc2 address[12:6], and way takes cache_way. dc3_replacement_enqueue is 1 only when cache_enable=1, cache_hit=0, and cache_valid=1. The replacement payload is always formed from cache metadata, independently of enqueue: from high to low, cache_data, dc2_message_source, cache_tag, dc2 address index, 6-bit zero offset, cache_state, cache_sharers, cache_owner.

All outputs are combinational; invalid messages have PLRU enable 0, while payload remains defined. REPLACEMENT messages always have cache_enable 0 and therefore do not enqueue into the replacement queue again; a TSHR hit does not mask cache metadata as the replacement payload.

## R-DC3B00D-008 — Forwarding Arbitration and Payload

When message_valid and the protocol has a forward, coherence forwarding takes priority: valid=1, and the 43-bit payload from high to low is dc2 source, 4-bit type, dc2 address, uncoherent=0, requestor=0; types are FWD_GETS=4/FWD_GETM=5/INV=6/RECALL=8/FWD_FLUSH=15, and destinations are determined by the preceding actions. Otherwise, when instr_request_pending and network_available, send an instruction request: valid=1, source=TILE_ID, type=4, address=instr address, uncoherent=1, requestor=1, destination is the memory bitmap, and instr_dequeue=1. In all other cases, forward valid, payload, destinations, and dequeue are all 0. In the coherence branch, dequeue=0.

Combinational arbitration; coherence forwarding is not gated by network_available. When a valid message does not require forwarding, instruction forwarding may still be sent in the same cycle. There is no ready-based hold protocol; arbitration is reevaluated immediately when inputs change. Priority blocks instruction dequeue only when coherence forwarding actually occurs.

## R-DC3B00D-009 — Response Payload and Invalid Windows

dc3_response_valid is only message_valid and a protocol-generated response. The 624-bit response from high to low: 512-bit data, 64-bit all-ones dirty_mask, 4-bit dc2 source, 4-bit packet_type, 32-bit dc2 address, 4-bit k, from_directory=1, uncoherent=0, requestor=0. data takes cache_data when cache_hit and non-REPLACEMENT, otherwise message_data; this selection differs from the protocol's selection of data to save to cache. packet_type is PUTACK=7, DATA=9, or WB=11, and is 0 when there is no response action; has_data is 1 only for DATA/WB actions and is not gated by message_valid. Response destinations are q or memory as described above, defaulting to old sharers when there is no response action.

Response payload, has_data, and destinations remain defined by the combinational rules above when response_valid=0; they must not all be cleared to zero or omitted from comparison. With 16 sharers, k=0; DIR_FLUSH uses cache_data even on a cache hit, while REPLACEMENT uses message_data even on a cache hit. There is no response backpressure or holding across cycles.

