## F-1

requirement_ids: R-dv-009-001

module: cva6_fifo_v3

definition: rst_ni low asynchronously clears the queue; it remains empty after deassertion. flush_i clears it on the rising edge of clk_i, taking priority over push/pop; flush does not take effect immediately between edges. After clearing, usage=0 and full=0; empty is still governed by the combinational fall-through rule for the current push.

interface: clk_i, rst_ni, flush_i, push_i, pop_i, usage_o, full_o, empty_o

timing: After reset assertion and before the next clock; before the flush edge and after NBA.

boundary: Fixed DEPTH=8, FALL_THROUGH=1, DATA_WIDTH=32, dtype=logic[31:0], FPGA_EN=0, FPGA_ALTERA=0; ADDR_DEPTH=3 is a derived value. Inputs are two-state, and non-reset inputs avoid rising edges. push_i=1 is prohibited when full_o=1, and pop_i=1 is prohibited when empty_o=1; simultaneous push/pop on an empty queue is legal due to fall-through. data_o is not scored when empty_o=1. testmode_i has no observable effect. The original source did not provide a spec; the following is the observable contract of the fixed RTL.

## F-2

requirement_ids: R-dv-009-002

module: cva6_fifo_v3

definition: The queue capacity is 8, and full_o is 1 when the stored entry count is 8; usage_o is the low 3 bits of the stored entry count and is 0 when full, so emptiness cannot be inferred from usage=0. A push when not full enqueues, a pop when not empty dequeues, and legal simultaneous push/pop preserves the stored entry count.

interface: clk_i, push_i, pop_i, full_o, empty_o, usage_o, data_i

timing: After combinational state changes and after the rising-edge NBA.

boundary: Fixed DEPTH=8, FALL_THROUGH=1, DATA_WIDTH=32, dtype=logic[31:0], FPGA_EN=0, FPGA_ALTERA=0; ADDR_DEPTH=3 is a derived value. Inputs are two-state, and non-reset inputs avoid rising edges. push_i=1 is prohibited when full_o=1, and pop_i=1 is prohibited when empty_o=1; simultaneous push/pop on an empty queue is legal due to fall-through. data_o is not scored when empty_o=1. testmode_i has no observable effect. The original source did not provide a spec; the following is the observable contract of the fixed RTL.

## F-3

requirement_ids: R-dv-009-003

module: cva6_fifo_v3

definition: When not empty, data_o combinationally presents the oldest data not yet dequeued; push accepts data_i on the rising edge of clk_i, and pop removes the queue head on the rising edge. Without pop, the queue head is retained; repeated wraparound and simultaneous push/pop do not change FIFO order. Arbitrary changes to testmode_i do not change these behaviors.

interface: clk_i, push_i, pop_i, data_i, data_o, empty_o, testmode_i

timing: Stable before and after the edge when not empty; data with empty=1 is not checked.

boundary: Fixed DEPTH=8, FALL_THROUGH=1, DATA_WIDTH=32, dtype=logic[31:0], FPGA_EN=0, FPGA_ALTERA=0; ADDR_DEPTH=3 is a derived value. Inputs are two-state, and non-reset inputs avoid rising edges. push_i=1 is prohibited when full_o=1, and pop_i=1 is prohibited when empty_o=1; simultaneous push/pop on an empty queue is legal due to fall-through. data_o is not scored when empty_o=1. testmode_i has no observable effect. The original source did not provide a spec; the following is the observable contract of the fixed RTL.

## F-4

requirement_ids: R-dv-009-004

module: cva6_fifo_v3

definition: When storage is empty and push_i=1, empty_o immediately becomes 0 without a clock, and data_o combinationally equals data_i. In this state, a rising edge with pop_i=0 retains the data as 1 entry; if pop_i=1, the entry is consumed through fall-through, and storage still contains 0 entries. Without push, an empty queue has empty_o=1.

interface: clk_i, data_i, push_i, pop_i, data_o, empty_o, usage_o

timing: When the combinational inputs are stable, do not wait for a clock; then check the stored entry count after the rising edge and the state after withdrawing push.

boundary: Fixed DEPTH=8, FALL_THROUGH=1, DATA_WIDTH=32, dtype=logic[31:0], FPGA_EN=0, FPGA_ALTERA=0; ADDR_DEPTH=3 is a derived value. Inputs are two-state, and non-reset inputs avoid rising edges. push_i=1 is prohibited when full_o=1, and pop_i=1 is prohibited when empty_o=1; simultaneous push/pop on an empty queue is legal due to fall-through. data_o is not scored when empty_o=1. testmode_i has no observable effect. The original source did not provide a spec; the following is the observable contract of the fixed RTL.
