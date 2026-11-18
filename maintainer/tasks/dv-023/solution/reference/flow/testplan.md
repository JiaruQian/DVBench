## T-FIFO-001

**feature_ids**: ["F-FIFO-001"]

**requirement_ids**: ["R-dv-023-fifo-001"]

**stimulus**: First write 5 items to establish a nonempty history, asynchronously assert rst during a window when both clocks are low, and hold it for at least two write/read clock cycles; after reset deassertion, write different data again and read it out. During reset, we=re=0.

**expected**: After reset assertion, the two states are full=0 and empty=1; the first item after reset deassertion is independent of the pre-reset queue; undefined empty data is not compared.

**checker**: fifo_scoreboard::write samples actual from the native ports and uses dvbench_model in the same file to generate expected from the input history; compare flags using four-state case equality, compare data point by point when nonempty and expected is known, and issue uvm_error on a mismatch; check_phase requires at least 200 state points and 32 valid data points.

**implementation_id**: V-FIFO-001

**source**: fifo_pkg.sv: fifo_sequence::body; fifo_monitor::run_phase; fifo_scoreboard::write

## T-FIFO-002

**feature_ids**: ["F-FIFO-002"]

**requirement_ids**: ["R-dv-023-fifo-002"]

**stimulus**: Empty the logical queue, keep re=0, set we and data on w_clk negative edges, and pass through 16 accepting rising edges, with data covering 00, FF, 55, AA, and incrementing values; issue 4 more writes while full, then issue read requests; repeat filling and draining so that the positions wrap around multiple times.

**expected**: After accepting the 16th item, full=1; writes while full do not overwrite storage; subsequent nonempty valid data matches the memory prediction based on the independent input history.

**checker**: fifo_scoreboard::write samples actual from the native ports and uses dvbench_model in the same file to generate expected from the input history; compare flags using four-state case equality, compare data point by point when nonempty and expected is known, and issue uvm_error on a mismatch; check_phase requires at least 200 state points and 32 valid data points.

**implementation_id**: V-FIFO-002

**source**: fifo_pkg.sv: fifo_sequence::body; fifo_monitor::run_phase; fifo_scoreboard::write

## T-FIFO-003

**feature_ids**: ["F-FIFO-003"]

**requirement_ids**: ["R-dv-023-fifo-003"]

**stimulus**: First write every slot and keep re=0 to observe the combinational response of the first item, then apply read requests in the independent r_clk domain, including reads while empty; interleave with writes, changing we/wdata while the read position is held to observe the latest contents of the corresponding slot.

**expected**: rdata is the combinational value at the current read position; the read position moves only on an r_clk rising edge with re asserted and a nonempty pre-edge state; reads while empty do not move the position; data in nonempty, known slots equals the prediction.

**checker**: fifo_scoreboard::write samples actual from the native ports and uses dvbench_model in the same file to generate expected from the input history; compare flags using four-state case equality, compare data point by point when nonempty and expected is known, and issue uvm_error on a mismatch; check_phase requires at least 200 state points and 32 valid data points.

**implementation_id**: V-FIFO-003

**source**: fifo_pkg.sv: fifo_sequence::body; fifo_monitor::run_phase; fifo_scoreboard::write

## T-FIFO-004

**feature_ids**: ["F-FIFO-004"]

**requirement_ids**: ["R-dv-023-fifo-004"]

**stimulus**: Use a 10ns write period and a 14ns read period, drive 00, 10, and 01 requests, and include w_clk state updates without an r_clk edge; calculate both positions and pre-edge flags from the input history, processing edges in chronological order and handling coincident times.

**expected**: 1ns after every w_clk and r_clk rising edge, full/empty must match the independent model; an r_clk edge alone must not directly update flags, and the read-candidate comparison must not be mistaken for an ordinary occupancy count.

**checker**: fifo_scoreboard::write samples actual from the native ports and uses dvbench_model in the same file to generate expected from the input history; compare flags using four-state case equality, compare data point by point when nonempty and expected is known, and issue uvm_error on a mismatch; check_phase requires at least 200 state points and 32 valid data points.

**implementation_id**: V-FIFO-004

**source**: fifo_pkg.sv: fifo_sequence::body; fifo_monitor::run_phase; fifo_scoreboard::write

## T-FIFO-005

**feature_ids**: ["F-FIFO-005"]

**requirement_ids**: ["R-dv-023-fifo-005"]

**stimulus**: Apply we=re=1 after each of three types of history: filled first, drained first, and partially occupied, holding continuously for 1 to 4 write cycles; the two 10ns/14ns clocks include coincident rising edges, with data 55, AA, and random values.

**expected**: Reject writes when full and reads when empty; between these boundaries, each side accepts on its own clock, and the w_clk state updates according to boundary priority; coincident edges use the old state without dependence on simulation ordering.

**checker**: fifo_scoreboard::write samples actual from the native ports and uses dvbench_model in the same file to generate expected from the input history; compare flags using four-state case equality, compare data point by point when nonempty and expected is known, and issue uvm_error on a mismatch; check_phase requires at least 200 state points and 32 valid data points.

**implementation_id**: V-FIFO-005

**source**: fifo_pkg.sv: fifo_sequence::body; fifo_monitor::run_phase; fifo_scoreboard::write

## T-FIFO-006

**feature_ids**: ["F-FIFO-006"]

**requirement_ids**: ["R-dv-023-fifo-006"]

**stimulus**: Maintain independent 10ns and 14ns clocks throughout, drive controls on w_clk falling edges, and additionally insert asynchronous resets; randomize 400 sets of we/re/data and hold times of 1 to 4 write cycles, monitoring both types of clock edges and reset assertion each time.

**expected**: Compare model-predicted flags and known valid data 1ns after each relevant event; do not backfill the model with actual DUT outputs, do not check empty/unknown data, and do not substitute coverage hits for functional comparisons.

**checker**: fifo_scoreboard::write samples actual from the native ports and uses dvbench_model in the same file to generate expected from the input history; compare flags using four-state case equality, compare data point by point when nonempty and expected is known, and issue uvm_error on a mismatch; check_phase requires at least 200 state points and 32 valid data points.

**implementation_id**: V-FIFO-006

**source**: fifo_pkg.sv: fifo_sequence::body; fifo_monitor::run_phase; fifo_scoreboard::write
