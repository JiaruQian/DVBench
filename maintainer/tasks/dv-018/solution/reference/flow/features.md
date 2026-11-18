### F01

requirement_ids: ["dv-018/R01"]

module: width_convert

definition: The three parameter instances in this task are ISIZE/OSIZE=4/8, 8/4, and 8/8, all measured at the same width_convert native root. 4/8 and 8/4 use active-low asynchronous rst_n; upon assertion, the segment position, rd_data, rd_vld, and rd_last are cleared without waiting for clock; 8/4 also clears wr_ready. For 4/8, wr_ready remains combinationally equal to rd_ready. 8/8 is entirely combinational pass-through, and clock and rst_n do not affect any output.

interface: ["rst_n", "clock", "rd_data", "rd_vld", "rd_last"]

timing: For registered branches, compare after signals settle following the rising edge of clock; compare asynchronous reset between edges; compare the pass-through branch and the combinational relationship of wr_ready after inputs settle and before the edge.

boundary: The three parameter instances in this task are ISIZE/OSIZE=4/8, 8/4, and 8/8, all measured at the same width_convert native root. 4/8 and 8/4 use active-low asynchronous rst_n; upon assertion, the segment position, rd_data, rd_vld, and rd_last are cleared without waiting for clock; 8/4 also clears wr_ready. For 4/8, wr_ready remains combinationally equal to rd_ready. 8/8 is entirely combinational pass-through, and clock and rst_n do not affect any output.

parent_id: null

### F02

requirement_ids: ["dv-018/R02"]

module: width_convert

definition: For 4/8, wr_ready is combinationally equal to rd_ready, and the current 4-bit input is processed on each rising edge of clock only when wr_vld and rd_ready are both asserted. For 8/4, the segment advancement condition is likewise wr_vld and rd_ready, without gating by wr_ready: wr_ready is set to 1 on the edge that processes the high half-word, cleared to 0 on the next edge with both wr_ready and wr_vld asserted, and held otherwise, with setting to 1 taking priority. For 8/8, wr_ready=rd_ready, rd_vld=wr_vld. All inputs are stable before the edge; there is no need to interpret this interface as an additional internal FIFO.

interface: ["clock", "wr_vld", "wr_ready", "rd_ready"]

timing: For registered branches, compare after signals settle following the rising edge of clock; compare asynchronous reset between edges; compare the pass-through branch and the combinational relationship of wr_ready after inputs settle and before the edge.

boundary: For 4/8, wr_ready is combinationally equal to rd_ready, and the current 4-bit input is processed on each rising edge of clock only when wr_vld and rd_ready are both asserted. For 8/4, the segment advancement condition is likewise wr_vld and rd_ready, without gating by wr_ready: wr_ready is set to 1 on the edge that processes the high half-word, cleared to 0 on the next edge with both wr_ready and wr_vld asserted, and held otherwise, with setting to 1 taking priority. For 8/8, wr_ready=rd_ready, rd_vld=wr_vld. All inputs are stable before the edge; there is no need to interpret this interface as an additional internal FIFO.

parent_id: null

### F03

requirement_ids: ["dv-018/R03"]

module: width_convert

definition: 4/8 writes the two successively processed half-words into rd_data[7:4] and [3:0]; each updated segment remains defined when rd_vld=0. The second segment sets rd_vld, and a newly completed word takes priority over consumption on the same edge. 8/4 alternately takes the high half-word and low half-word from wr_data at that edge and registers the segment into rd_data; each processing edge sets rd_vld; otherwise, if the old rd_vld is asserted and ready is not asserted, it is held, and in all other cases it is cleared to 0. rd_data holds on edges without processing. For 8/8, rd_data is combinationally equal to wr_data, with no added latency.

interface: ["clock", "wr_data", "wr_vld", "rd_data", "rd_vld"]

timing: For registered branches, compare after signals settle following the rising edge of clock; compare asynchronous reset between edges; compare the pass-through branch and the combinational relationship of wr_ready after inputs settle and before the edge.

boundary: 4/8 writes the two successively processed half-words into rd_data[7:4] and [3:0]; each updated segment remains defined when rd_vld=0. The second segment sets rd_vld, and a newly completed word takes priority over consumption on the same edge. 8/4 alternately takes the high half-word and low half-word from wr_data at that edge and registers the segment into rd_data; each processing edge sets rd_vld; otherwise, if the old rd_vld is asserted and ready is not asserted, it is held, and in all other cases it is cleared to 0. rd_data holds on edges without processing. For 8/8, rd_data is combinationally equal to wr_data, with no added latency.

parent_id: null

### F04

requirement_ids: ["dv-018/R04"]

module: width_convert

definition: For 4/8, wr_last or wr_align_last returns the position to the first segment after processing the current segment, without undoing the write of this segment; wr_last is registered into rd_last only on a second-segment edge; otherwise, rd_last is cleared when the old valid output is consumed and held in all other cases. last on the first segment is allowed; an incomplete word does not produce valid as a result. 8/4 ignores wr_align_last; when processing the high half-word, rd_last=wr_last, and when processing the low half-word, rd_last=0; when there is no processing, it is held if the old rd_vld is asserted and ready is not asserted, and otherwise cleared to 0. For 8/8, rd_last is combinationally equal to wr_last, and wr_align_last does not affect the outputs.

interface: ["clock", "wr_last", "wr_align_last", "rd_last", "rd_vld"]

timing: For registered branches, compare after signals settle following the rising edge of clock; compare asynchronous reset between edges; compare the pass-through branch and the combinational relationship of wr_ready after inputs settle and before the edge.

boundary: For 4/8, wr_last or wr_align_last returns the position to the first segment after processing the current segment, without undoing the write of this segment; wr_last is registered into rd_last only on a second-segment edge; otherwise, rd_last is cleared when the old valid output is consumed and held in all other cases. last on the first segment is allowed; an incomplete word does not produce valid as a result. 8/4 ignores wr_align_last; when processing the high half-word, rd_last=wr_last, and when processing the low half-word, rd_last=0; when there is no processing, it is held if the old rd_vld is asserted and ready is not asserted, and otherwise cleared to 0. For 8/8, rd_last is combinationally equal to wr_last, and wr_align_last does not affect the outputs.

parent_id: null

### F05

requirement_ids: ["dv-018/R05"]

module: width_convert

definition: 4/8 and 8/4 do not process input when rd_ready=0, and rd_data, rd_vld, and rd_last hold; however, wr_ready for 8/4 still changes according to rule R02. After ready is restored, processing uses the input at the current edge; input acceptance must not be inferred backward from DUT outputs. Observe registered branches after the native edge and NBA settling, and observe asynchronous reset between edges; 8/8 can be observed once inputs settle, and even rd_ready=0 does not freeze pass-through data/valid/last.

interface: ["clock", "rd_ready", "wr_ready", "rd_data", "rd_last", "rd_vld"]

timing: For registered branches, compare after signals settle following the rising edge of clock; compare asynchronous reset between edges; compare the pass-through branch and the combinational relationship of wr_ready after inputs settle and before the edge.

boundary: 4/8 and 8/4 do not process input when rd_ready=0, and rd_data, rd_vld, and rd_last hold; however, wr_ready for 8/4 still changes according to rule R02. After ready is restored, processing uses the input at the current edge; input acceptance must not be inferred backward from DUT outputs. Observe registered branches after the native edge and NBA settling, and observe asynchronous reset between edges; 8/8 can be observed once inputs settle, and even rd_ready=0 does not freeze pass-through data/valid/last.

parent_id: null
