# Four-lane shared memory

Verify the complete native shared_mem module under the following public behavior contract.

### R-p8-smem-001 — Reset and fixed domain

The fixed instance has four 32-bit lanes, two banks of 128 words, and no overridable top parameters. All binary input histories after reset are in scope, including overlapping requests, zero or multiple byte enables, zero active mask and full response queues. Active-low reset is asynchronous: it clears both bank memories, request history, replay state, read holdings, response pipeline, all four response slots and queue pointers. After settling during reset, request ready is one and all response outputs are zero. Clocked state changes occur on rising edges; observe outputs after settling and also after a reset falling edge without waiting for a clock.

### R-p8-smem-002 — Addressing and byte writes

A lane selects bank core_req_blockoffset_i[lane]. Its word row is the seven-bit concatenation of core_req_tag_i[1:0] and core_req_setidx_i[4:0]; the upper 22 tag bits alias. Lane k occupies data bits 32*k through 32*k+31 and byte-enable bits 4*k through 4*k+3. Each enabled byte independently replaces the corresponding byte of the selected bank word; disabled bytes retain their previous values and a zero enable changes no memory byte. Each bank uses the lowest-numbered selected active lane for its write word and byte enables. Both banks retain all other rows.

### R-p8-smem-003 — Lane arbitration and replay

For each arbitration step select the lowest-numbered remaining active lane in each bank; the response active mask marks just these winners. Count active lanes per bank modulo four. A count of two or three requests another replay step; four lanes in one bank wrap to zero and do not request replay. Remove the selected winners before the next replay step. On the first step use the latest accepted snapshot lane mask, banks and byte enables; while replay is active use the saved remaining selection. A replay indication is retained for the next cycle only when this step has a count of two or three and either the previous-cycle acceptance pulse or current replay indication is set. Selection and routing continue to update even in cycles without a valid operation.

### R-p8-smem-004 — Acceptance, overlap and pipeline timing

A request is accepted exactly when valid and ready are both one before a rising edge. Let C be the most recently accepted complete request snapshot, E the execution snapshot, h the acceptance pulse from the previous edge, and r the registered replay indication. At each edge capture C on a new acceptance; copy the pre-edge C into E when h is one. Independently update first-read validity to (h and C is a read) or (old first-read validity and r), and first-write validity analogously for writes. The second read and write validities copy the old first validities. First-step winner masks and lane routes are delayed one further edge into the response selection; response write flag and all three instruction bits are delayed from the pre-edge E each edge. Without contention a request accepted at e0 supplies arbitration at e1, its memory operation at e2 and a response queue push at e3. Replay does not freeze C or E: reads use the current C row and writes the current E row and word. An additional acceptance immediately following a conflicting request can therefore replace the row, payload and identity used by continuation while the saved remaining lane selection belongs to the earlier request.

### R-p8-smem-005 — Exact request readiness

Let n be response tail minus head modulo eight, r the registered replay indication and w the first write validity. Request ready is exactly (not r) and (n is not one) and (not w). The response-occupancy test is equality to one: occupancies two, three and four do not by themselves deassert request ready. Newly discovered contention affects ready only after its indication is registered, allowing the overlapping acceptance described above. Input valid alone never modifies acceptance snapshots when ready is zero.

### R-p8-smem-006 — Read holdings, routing and bypass

Every first read pulse reads both banks at the current C row, regardless of which lanes are active. The first route for lane k is bank one only when that lane is active and its bank bit is one; otherwise it is bank zero. Routes are delayed another edge for response assembly. An inactive lane therefore carries defined bank-zero data rather than forced zero. Each bank read holding retains its value when there is no read. A simultaneous read and selected write to the same bank row suppresses that bank memory read and saves a bypass word equal to the complete selected 32-bit write payload, even for a partial or zero byte-enable mask. The array itself still performs only enabled-byte updates. At each edge the second bank-data holdings take the old bypass word when its old bypass flag is one, otherwise the old bank-read holding. Write responses also carry these defined retained/routed bank data; no response-data bit is unspecified merely because the response is a write or the lane is inactive.

### R-p8-smem-007 — Response queue and overflow behavior

The response queue has four 136-bit slots containing write flag, three-bit instruction, four-bit winner mask and 128-bit routed data. Head and tail are three-bit modulo-eight pointers; slot index uses their low two bits and n is tail minus head modulo eight. Empty means n equals zero and full means n equals four. Each edge requests a single push when either second-read or second-write validity is one, including when both are one. A push advances tail if not full or response ready is one. A pop advances head only if response ready is one and the pre-edge queue is nonempty. There is no empty bypass. Store the assembled response into the old tail slot only when a push advances tail and pre-edge n is not four. Thus full plus ready advances both pointers but suppresses storage of the incoming response, retaining the old slot content; full without ready drops the incoming response and holds pointers. All decisions use pre-edge state.

### R-p8-smem-008 — Always-defined response observations

Response valid is exactly n not equal to zero. All response payload outputs continuously expose the current head slot even when valid is zero. Slots start at zero and retain their bytes until a permitted nonfull push writes them. Reset overrides all pending history. During response backpressure, the head stays fixed but its slot may still be affected by the specified queue write and wrap rules; predict behavior from pointer and slot history rather than assuming an unspecified payload or an unconditional stable-ready/valid protocol. Compare every output bit on every settled observation, without valid or active-mask gating.
