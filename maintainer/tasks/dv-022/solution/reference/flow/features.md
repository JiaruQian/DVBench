### F01

requirement_ids: ["dv-022/R01"]

module: reorder_queue

definition: On a rising edge of CLK, when INT_TAG_VALID and the pre-edge EXT_TAG_VALID are both 1, allocate the external slot indicated by the pre-edge EXT_TAG, mapping all 6 bits of INT_TAG; external slots cycle through 0..31. The first non-reset edge after synchronous reset restores the indication that an empty slot is available; occupied slots must not be allocated again. Up to 32 simultaneously in-flight allocations are allowed; subsequent reuse must wait for the slot to be cleared and for the availability indication.

interface: ["CLK", "RST", "INT_TAG", "INT_TAG_VALID", "EXT_TAG", "EXT_TAG_VALID"]

timing: Sample inputs on the rising edge of CLK and compare after a #1 delay/NBA settling; valid payload is delimited by route/count from independent input history, and the guard is not determined from DUT outputs; reset additionally covers synchronism between edges.

boundary: On a rising edge of CLK, when INT_TAG_VALID and the pre-edge EXT_TAG_VALID are both 1, allocate the external slot indicated by the pre-edge EXT_TAG, mapping all 6 bits of INT_TAG; external slots cycle through 0..31. The first non-reset edge after synchronous reset restores the indication that an empty slot is available; occupied slots must not be allocated again. Up to 32 simultaneously in-flight allocations are allowed; subsequent reuse must wait for the slot to be cleared and for the availability indication.

parent_id: null

### F02

requirement_ids: ["dv-022/R02"]

module: reorder_queue

definition: Input packets only for allocated TAGs. When VALID=1, DATA_EN must specify 1..4 contiguous low-order lanes, and DATA_EN_COUNT must be the same number of DWs, with 32 bits per lane; beats with the same tag are appended in order, and interleaving different tags is allowed. Each packet has a total length of 1..128 DW and terminates exactly once on its final valid beat with DONE or ERR or both set to 1; when VALID=0 or RST=1, DATA_EN, COUNT, and DONE/ERR must all be set to 0. Do not perform duplicate allocation and send a new slot's payload on the same edge, and do not reuse a slot before completion.

interface: ["CLK", "VALID", "DATA", "DATA_EN", "DATA_EN_COUNT", "DONE", "ERR", "TAG"]

timing: Sample inputs on the rising edge of CLK and compare after a #1 delay/NBA settling; valid payload is delimited by route/count from independent input history, and the guard is not determined from DUT outputs; reset additionally covers synchronism between edges.

boundary: Input packets only for allocated TAGs. When VALID=1, DATA_EN must specify 1..4 contiguous low-order lanes, and DATA_EN_COUNT must be the same number of DWs, with 32 bits per lane; beats with the same tag are appended in order, and interleaving different tags is allowed. Each packet has a total length of 1..128 DW and terminates exactly once on its final valid beat with DONE or ERR or both set to 1; when VALID=0 or RST=1, DATA_EN, COUNT, and DONE/ERR must all be set to 0. Do not perform duplicate allocation and send a new slot's payload on the same edge, and do not reuse a slot before completion.

parent_id: null

### F03

requirement_ids: ["dv-022/R03"]

module: reorder_queue

definition: Output completed packets in allocation order starting from external tag0; a later tag that completes first is still blocked by an incomplete head packet. The output has no backpressure, with low-order DWs output first, at most 4 DW per beat, and the remaining 1..4 DW on the final beat. The low 4 bits of the mapped route are the channel, and groups 0/1/2 correspond to MAIN/SG_RX/SG_TX respectively; only route0..11, 16..27, and 32..43 map to exposed count vectors; other 6-bit routes are legal but have no exposed routing activity. ENG_DATA is defined only in the low 32*count bits for the corresponding count. If the head packet's final input edge is n, an idle output engine outputs no earlier than edge n+10; the first beat of a subsequent completed packet is no earlier than its own n+10, and no earlier than 2 edges after the previous packet's final beat (if the previous packet is no more than 4 DW) or 1 edge after it (if the previous packet exceeds 4 DW); output is continuous on every edge within a packet.

interface: ["CLK", "TAG", "ENG_DATA", "MAIN_DATA_EN", "SG_RX_DATA_EN", "SG_TX_DATA_EN", "MAIN_DONE", "SG_RX_DONE", "SG_TX_DONE"]

timing: Sample inputs on the rising edge of CLK and compare after a #1 delay/NBA settling; valid payload is delimited by route/count from independent input history, and the guard is not determined from DUT outputs; reset additionally covers synchronism between edges.

boundary: Output completed packets in allocation order starting from external tag0; a later tag that completes first is still blocked by an incomplete head packet. The output has no backpressure, with low-order DWs output first, at most 4 DW per beat, and the remaining 1..4 DW on the final beat. The low 4 bits of the mapped route are the channel, and groups 0/1/2 correspond to MAIN/SG_RX/SG_TX respectively; only route0..11, 16..27, and 32..43 map to exposed count vectors; other 6-bit routes are legal but have no exposed routing activity. ENG_DATA is defined only in the low 32*count bits for the corresponding count. If the head packet's final input edge is n, an idle output engine outputs no earlier than edge n+10; the first beat of a subsequent completed packet is no earlier than its own n+10, and no earlier than 2 edges after the previous packet's final beat (if the previous packet is no more than 4 DW) or 1 edge after it (if the previous packet exceeds 4 DW); output is continuous on every edge within a packet.

parent_id: null

### F04

requirement_ids: ["dv-022/R04"]

module: reorder_queue

definition: On the final beat, DONE for the corresponding route equals the final input DONE OR ERR, and ERR equals the final ERR; controls are 0 on non-final beats and inactive beats. Packets are cleared after ordered output, and cleared slots may be reallocated when EXT_TAG_VALID permits; all 32 slots may wrap around for multiple rounds. Invisible routes likewise consume and clear their packets and must not block subsequent visible routes.

interface: ["CLK", "DONE", "ERR", "TAG", "MAIN_DONE", "MAIN_ERR", "SG_RX_DONE", "SG_RX_ERR", "SG_TX_DONE", "SG_TX_ERR"]

timing: Sample inputs on the rising edge of CLK and compare after a #1 delay/NBA settling; valid payload is delimited by route/count from independent input history, and the guard is not determined from DUT outputs; reset additionally covers synchronism between edges.

boundary: On the final beat, DONE for the corresponding route equals the final input DONE OR ERR, and ERR equals the final ERR; controls are 0 on non-final beats and inactive beats. Packets are cleared after ordered output, and cleared slots may be reallocated when EXT_TAG_VALID permits; all 32 slots may wrap around for multiple rounds. Invisible routes likewise consume and clear their packets and must not block subsequent visible routes.

parent_id: null

### F05

requirement_ids: ["dv-022/R05"]

module: reorder_queue

definition: RST is active-high and synchronous; only when asserted across a CLK rising edge does it clear the allocator, occupancy, and finished state, set EXT_TAG and EXT_TAG_VALID to 0, and set output route count/DONE/ERR to 0; RAM data is not cleared. An RST pulse between edges that does not span a rising edge does not immediately clear state. Reset discards previous packets; new payload must be written after reallocation, without relying on old RAM values.

interface: ["CLK", "RST", "EXT_TAG", "EXT_TAG_VALID", "MAIN_DATA_EN", "SG_RX_DATA_EN", "SG_TX_DATA_EN"]

timing: Sample inputs on the rising edge of CLK and compare after a #1 delay/NBA settling; valid payload is delimited by route/count from independent input history, and the guard is not determined from DUT outputs; reset additionally covers synchronism between edges.

boundary: RST is active-high and synchronous; only when asserted across a CLK rising edge does it clear the allocator, occupancy, and finished state, set EXT_TAG and EXT_TAG_VALID to 0, and set output route count/DONE/ERR to 0; RAM data is not cleared. An RST pulse between edges that does not span a rising edge does not immediately clear state. Reset discards previous packets; new payload must be written after reallocation, without relying on old RAM values.

parent_id: null

### F06

requirement_ids: ["dv-022/R06"]

module: reorder_queue

definition: Post-edge controls are 0 after reset, but non-reset idle route count and ENG_DATA before the first output-ready packet may be uninitialized and must not be required to be 0. After the first packet establishes the route, count/DONE/ERR return to 0 on every inactive output edge; on active edges, exposed route/count, DONE/ERR, and valid DWs must be checked, and X/Z must not be masked during the active window.

interface: ["CLK", "ENG_DATA", "MAIN_DATA_EN", "MAIN_DONE", "MAIN_ERR", "SG_RX_DATA_EN", "SG_RX_DONE", "SG_RX_ERR", "SG_TX_DATA_EN", "SG_TX_DONE", "SG_TX_ERR"]

timing: Sample inputs on the rising edge of CLK and compare after a #1 delay/NBA settling; valid payload is delimited by route/count from independent input history, and the guard is not determined from DUT outputs; reset additionally covers synchronism between edges.

boundary: Post-edge controls are 0 after reset, but non-reset idle route count and ENG_DATA before the first output-ready packet may be uninitialized and must not be required to be 0. After the first packet establishes the route, count/DONE/ERR return to 0 on every inactive output edge; on active edges, exposed route/count, DONE/ERR, and valid DWs must be checked, and X/Z must not be masked during the active window.

parent_id: null
