### T01

feature_ids: ["F01"]

requirement_ids: ["dv-022/R01"]

stimulus: Apply synchronous reset and wait for pre-edge EXT_TAG_VALID; allocate 32 slots consecutively, check the full condition and that no further allocation occurs, then complete all packets and wait for slots to become available; repeat for two rounds to map all 64 routes.

expected: When INT_TAG_VALID and pre-edge EXT_TAG_VALID are both 1 at a CLK rising edge, allocate the external slot indicated by pre-edge EXT_TAG, mapping all 6 bits of INT_TAG; external slots cycle through 0..31. The first non-reset edge after synchronous reset restores the empty-slot availability indication, and occupied slots must not be allocated again. At most 32 simultaneous in-flight allocations are allowed; subsequent reuse must wait for that slot to be cleared and for its availability indication.

checker: Independently compute the allocation/packet sequence or segmented arithmetic from input history, without reading actual DUT outputs to generate expected; sample inputs at CLK rising edges and compare after a #1 delay/NBA settling; valid payload is qualified by route/count from independent input history, not by guards determined from DUT outputs; separately cover reset synchrony between edges. Compare every valid port using four-state !==, and report UVM_ERROR for X/Z or mismatches; drain after legal stimulus ends, and report an error if the comparison count is 0.

implementation_id: CHK01

source: tb/package.sv:dvbench_scoreboard.write

### T02

feature_ids: ["F02"]

requirement_ids: ["dv-022/R02"]

stimulus: First allocate legally; input consecutive same-tag beats and interleaved different-tag beats using low-lane count1..4, lengths 1..16 and 128 DW, with known, distinct random values for each DW; cover DONE-only, ERR-only, and simultaneous termination by both, with all idle inputs disabled.

expected: Input packets only for allocated TAGs. When VALID=1, DATA_EN must specify 1..4 contiguous low-order lanes, and DATA_EN_COUNT must be the same number of DWs, with 32 bits per lane; beats with the same tag are appended in order, and interleaving different tags is allowed. Each packet has a total length of 1..128 DW and terminates exactly once on its final valid beat with DONE or ERR or both set to 1; when VALID=0 or RST=1, DATA_EN, COUNT, and DONE/ERR must all be set to 0. Do not perform duplicate allocation and send a new slot's payload on the same edge, and do not reuse a slot before completion.

checker: Independently compute the allocation/packet sequence or segmented arithmetic from input history, without reading actual DUT outputs to generate expected; sample inputs at CLK rising edges and compare after a #1 delay/NBA settling; valid payload is qualified by route/count from independent input history, not by guards determined from DUT outputs; separately cover reset synchrony between edges. Compare every valid port using four-state !==, and report UVM_ERROR for X/Z or mismatches; drain after legal stimulus ends, and report an error if the comparison count is 0.

implementation_id: CHK02

source: tb/package.sv:dvbench_scoreboard.write

### T03

feature_ids: ["F03"]

requirement_ids: ["dv-022/R03"]

stimulus: After consecutively allocating 32 tags, complete them in reverse order 31..0, initially leaving head incomplete to confirm that no out-of-order output occurs; map 0..63 over two rounds, cover packet lengths 1..16 and 128 DW, record every final input edge and packet order, and wait at least 2000 edges to drain.

expected: Output completed packets in allocation order starting from external tag0; a later tag that completes first is still blocked by an incomplete head packet. The output has no backpressure, with low-order DWs output first, at most 4 DW per beat, and the remaining 1..4 DW on the final beat. The low 4 bits of the mapped route are the channel, and groups 0/1/2 correspond to MAIN/SG_RX/SG_TX respectively; only route0..11, 16..27, and 32..43 map to exposed count vectors; other 6-bit routes are legal but have no exposed routing activity. ENG_DATA is defined only in the low 32*count bits for the corresponding count. If the head packet's final input edge is n, an idle output engine outputs no earlier than edge n+10; the first beat of a subsequent completed packet is no earlier than its own n+10, and no earlier than 2 edges after the previous packet's final beat (if the previous packet is no more than 4 DW) or 1 edge after it (if the previous packet exceeds 4 DW); output is continuous on every edge within a packet.

checker: Independently compute the allocation/packet sequence or segmented arithmetic from input history, without reading actual DUT outputs to generate expected; sample inputs at CLK rising edges and compare after a #1 delay/NBA settling; valid payload is qualified by route/count from independent input history, not by guards determined from DUT outputs; separately cover reset synchrony between edges. Compare every valid port using four-state !==, and report UVM_ERROR for X/Z or mismatches; drain after legal stimulus ends, and report an error if the comparison count is 0.

implementation_id: CHK03

source: tb/package.sv:dvbench_scoreboard.write

### T04

feature_ids: ["F04"]

requirement_ids: ["dv-022/R04"]

stimulus: Allocate, fill, and terminate 32 slots, and check each packet's final beat using a mix of visible/invisible routes and the three termination combinations; after output and clearing make slots available, allocate all 32 slots again to confirm wraparound and isolation from old data.

expected: On the final beat, DONE for the corresponding route equals the final input DONE OR ERR, and ERR equals the final ERR; controls are 0 on non-final beats and inactive beats. Packets are cleared after ordered output, and cleared slots may be reallocated when EXT_TAG_VALID permits; all 32 slots may wrap around for multiple rounds. Invisible routes likewise consume and clear their packets and must not block subsequent visible routes.

checker: Independently compute the allocation/packet sequence or segmented arithmetic from input history, without reading actual DUT outputs to generate expected; sample inputs at CLK rising edges and compare after a #1 delay/NBA settling; valid payload is qualified by route/count from independent input history, not by guards determined from DUT outputs; separately cover reset synchrony between edges. Compare every valid port using four-state !==, and report UVM_ERROR for X/Z or mismatches; drain after legal stimulus ends, and report an error if the comparison count is 0.

implementation_id: CHK04

source: tb/package.sv:dvbench_scoreboard.write

### T05

feature_ids: ["F05"]

requirement_ids: ["dv-022/R05"]

stimulus: First establish in-flight allocations/partial payload/completed packets, keep all inputs disabled, then assert RST across a CLK edge and reallocate new packets; also apply an RST pulse that does not span an edge to check synchrony.

expected: RST is active-high and synchronous; only when asserted across a CLK rising edge does it clear the allocator, occupancy, and finished state, set EXT_TAG and EXT_TAG_VALID to 0, and set output route count/DONE/ERR to 0; RAM data is not cleared. An RST pulse between edges that does not span a rising edge does not immediately clear state. Reset discards previous packets; new payload must be written after reallocation, without relying on old RAM values.

checker: Independently compute the allocation/packet sequence or segmented arithmetic from input history, without reading actual DUT outputs to generate expected; sample inputs at CLK rising edges and compare after a #1 delay/NBA settling; valid payload is qualified by route/count from independent input history, not by guards determined from DUT outputs; separately cover reset synchrony between edges. Compare every valid port using four-state !==, and report UVM_ERROR for X/Z or mismatches; drain after legal stimulus ends, and report an error if the comparison count is 0.

implementation_id: CHK05

source: tb/package.sv:dvbench_scoreboard.write

### T06

feature_ids: ["F06"]

requirement_ids: ["dv-022/R06"]

stimulus: After synchronous reset, observe the undefined idle fields before the first activity; complete a legal visible-route packet, then observe activity and at least eight idle edges, checking valid fields and subsequent idle controls.

expected: Post-edge controls are 0 after reset, but non-reset idle route count and ENG_DATA before the first output-ready packet may be uninitialized and must not be required to be 0. After the first packet establishes the route, count/DONE/ERR return to 0 on every inactive output edge; on active edges, exposed route/count, DONE/ERR, and valid DWs must be checked, and X/Z must not be masked during the active window.

checker: Independently compute the allocation/packet sequence or segmented arithmetic from input history, without reading actual DUT outputs to generate expected; sample inputs at CLK rising edges and compare after a #1 delay/NBA settling; valid payload is qualified by route/count from independent input history, not by guards determined from DUT outputs; separately cover reset synchrony between edges. Compare every valid port using four-state !==, and report UVM_ERROR for X/Z or mismatches; drain after legal stimulus ends, and report an error if the comparison count is 0.

implementation_id: CHK06

source: tb/package.sv:dvbench_scoreboard.write
