# width_convert Behavioral Specification

See ports.md for the native interface and parameters. Inputs should be stable before the native sampling edge.

### dv-018/R01

The three parameter instances in this task are ISIZE/OSIZE=4/8, 8/4, and 8/8, all measured at the same width_convert native root. 4/8 and 8/4 use active-low asynchronous rst_n, which clears the segment position, rd_data, rd_vld, and rd_last after assertion without waiting for clock; 8/4 also clears wr_ready. For 4/8, wr_ready still combinationally equals rd_ready. 8/8 is entirely combinational pass-through; clock and rst_n do not affect any output.

### dv-018/R02

For 4/8, wr_ready combinationally equals rd_ready, and each clock rising edge processes the current 4-bit input only when wr_vld and rd_ready are asserted. For 8/4, the segment advancement condition is likewise wr_vld and rd_ready, not gated by wr_ready: wr_ready is set to 1 on the edge that processes the high half-word, cleared to 0 on the next edge with wr_ready and wr_vld asserted, and otherwise holds, with setting to 1 taking priority. For 8/8, wr_ready=rd_ready, rd_vld=wr_vld. All inputs are stable before the edge; there is no need to interpret this interface as an additional internal FIFO.

### dv-018/R03

4/8 writes two successively processed half-words into rd_data[7:4] and [3:0]; each updated segment remains defined when rd_vld=0. The second segment sets rd_vld, and a newly completed word takes priority over consumption on the same edge. 8/4 alternately takes the high half-word and low half-word from wr_data at that edge and registers the segment into rd_data; each processing edge sets rd_vld, otherwise it holds if the old rd_vld is asserted and ready is not asserted, and clears to 0 in all other cases. rd_data holds on an edge with no processing. For 8/8, rd_data combinationally equals wr_data, adding no latency.

### dv-018/R04

For 4/8, wr_last or wr_align_last returns the position to the first segment after processing this segment, without undoing this segment's write; only a second-segment edge registers wr_last into rd_last, otherwise consuming the old valid value clears rd_last, and it holds in all other cases. A first-segment last is allowed; an incomplete word does not generate valid as a result. 8/4 ignores wr_align_last; when processing the high half-word, rd_last=wr_last, and when processing the low half-word, rd_last=0; when not processing, it holds if the old rd_vld is asserted and ready is not asserted, otherwise it clears to 0. For 8/8, rd_last combinationally equals wr_last, and wr_align_last does not affect outputs.

### dv-018/R05

4/8 and 8/4 do not process input when rd_ready=0, and rd_data, rd_vld, and rd_last hold; however, wr_ready for 8/4 still changes according to rule R02. After ready recovers, processing uses the current edge's inputs; input acceptance must not be inferred from DUT outputs. Observe registered branches after the native edge and NBA settling, and asynchronous reset between edges; 8/8 can be observed once inputs are stable, and even rd_ready=0 does not freeze pass-through data/valid/last.
