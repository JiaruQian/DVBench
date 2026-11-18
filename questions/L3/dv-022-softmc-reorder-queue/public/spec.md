# reorder_queue behavioral specification

See ports.md for the native interface and parameters. Inputs should be stable before the native sampling edge.

### dv-022/R01

On a rising edge of CLK, when INT_TAG_VALID and the pre-edge EXT_TAG_VALID are both 1, allocate the external slot indicated by the pre-edge EXT_TAG, mapping all 6 bits of INT_TAG; external slots cycle through 0..31. The first non-reset edge after synchronous reset restores the indication that an empty slot is available; occupied slots must not be allocated again. Up to 32 simultaneously in-flight allocations are allowed; subsequent reuse must wait for the slot to be cleared and for the availability indication.

### dv-022/R02

Input packets only for allocated TAGs. When VALID=1, DATA_EN must consist of 1..4 contiguous low-order lanes, and DATA_EN_COUNT must be the same number of DWs, with 32 bits per lane; beats with the same tag are appended in order, and different tags may be interleaved. Each packet has a total length of 1..128 DWs and terminates exactly once, on the final valid beat with DONE or ERR or both set to 1; when VALID=0 or RST=1, DATA_EN, COUNT, and DONE/ERR must all be set to 0. Do not allocate a new slot and send its payload on the same edge, and do not reuse a slot before completion.

### dv-022/R03

Output completed packets in allocation order starting from external tag0; a later tag that completes first is still blocked by an incomplete head packet. There is no output backpressure; low-order DWs are output first, with at most 4 DWs per cycle and the remaining 1..4 DWs on the final cycle. The low 4 bits of the mapped route are the channel, and groups 0/1/2 correspond to MAIN/SG_RX/SG_TX respectively; only route0..11, 16..27, and 32..43 map to public count vectors; other 6-bit routes are legal but have no public routing activity. Only the low 32*count bits of ENG_DATA for the corresponding count are defined. If the head packet's final input edge is n, an idle output unit can output no earlier than edge n+10; the first beat of a subsequent completed packet must be no earlier than its own n+10, and no earlier than 2 edges after the preceding packet's final beat (if the preceding packet is no more than 4 DWs) or 1 edge after it (if the preceding packet exceeds 4 DWs); output is continuous on every edge within a packet.

### dv-022/R04

On the final beat, DONE for the corresponding route equals the final input DONE or ERR, and ERR equals the final ERR; controls are 0 on non-final beats and inactive cycles. A packet is cleared after ordered output, and a cleared slot can be reallocated when EXT_TAG_VALID permits; all 32 slots can wrap around for multiple rounds. Invisible routes likewise consume and clear their packets and must not block subsequent visible routes.

### dv-022/R05

RST is active-high and synchronous; only when it spans a rising edge of CLK does it clear the allocator, occupancy, and finished state, set EXT_TAG and EXT_TAG_VALID to 0, and set output route count/DONE/ERR to 0; RAM data is not cleared. An RST pulse between edges that does not span a rising edge does not immediately clear state. Reset discards previous packets; new payload must be written after reallocation, without relying on old RAM values.

### dv-022/R06

Post-edge controls after reset are 0, but non-reset idle route count and ENG_DATA before the first output-capable packet may be uninitialized and must not be required to be 0. After the first packet establishes routing, count/DONE/ERR return to 0 on every inactive output edge; on active edges, the public route/count, DONE/ERR, and valid DWs must be checked, and X/Z must not be masked during active windows.
