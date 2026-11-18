# test_id

## T1

- feature_ids: F1
- requirement_ids: R-bb8eef11f6a971-001
- stimulus: Reset for the first three cycles before starting; reset again before transaction 8 to clear the sticky trigger; also interrupt decoding with reset after approximately 20 cycles and then resend. Drive on falling edges and observe outputs 1ns after assertion.
- expected: rst_n is an active-low asynchronous reset that clears dec_done, trigger_dec, total_bits_consumed, and all RGB outputs to zero; reset cancels in-flight transactions. dec_start is high for only one rising edge while idle; the three bitstreams, lengths, and block_num remain stable from acceptance to completion. Lengths are 0..1024, and all read indices must be within 1024 bits; each channel contains no more than 64 run/amplitude records (EOB also counts as one record), expanding to no more than 64 coefficients. Neither completion nor numerical values are guaranteed for over-capacity records, illegal codes, overlapping starts, or unstable streams. Reset may be asserted between clock edges; restart after deassertion. Complete tasks are serialized.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V1
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

## T2

- feature_ids: F2
- requirement_ids: R-bb8eef11f6a971-002
- stimulus: Independent encoders generate legal records for the three channels, including EOB, positive and negative categories, short and long codes, category1..10 (including native truncation of -128, 256, -511, 1023), different channel lengths, exhaustion exactly at a record boundary without EOB, and category10 records truncated to zero that are still followed by nonzero records; 16 serial tasks, with random coefficients in the range -127..127.
- expected: Each of the three channels reads bit by bit starting from bs_*[0], with the first bit read serving as the most significant bit of the codeword. Use the fixed code table below to match the first complete code. The high 4 bits of symbol are run, and the low 4 bits are category. 0x00 is EOB; 0xf0 is 16 zeros. For category>0, continue reading category bits to form an 8-bit shift buffer v (retain the last 8 bits if more than 8 bits are read), and mask is the low 8 bits of (2^category-1); for category1..8, take v&mask if bit category-1 of v is 1; otherwise take the low 8 bits of (v&mask)-mask and interpret them as signed. category9/10 takes the else branch because the index exceeds 8 bits. The code table defines the symbol facts; the input length is allowed to end at a code boundary, and unfilled coefficients are 0.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V2
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

## T3

- feature_ids: F3
- requirement_ids: R-bb8eef11f6a971-003
- stimulus: Empty blocks, nonzero DC, EOB after 63 nonzeros, and sparse coefficients (naturally producing ZRL), encoded across all 64 positions, with the independent model reconstructing the entire block.
- expected: run denotes the number of zeros inserted before the amplitude; decoding terminates when a decoded record has run=0 and a truncated 8-bit amplitude of 0 (including EOB, and also category9/10 that becomes exactly 0 after truncation), and the remaining coefficients are zero-filled; Huffman continues reading according to its own bitstream, and stopped RLE never resumes. 0xf0 inserts 15 zeros and then writes one zero; each channel is arranged into 8x8 row-major coefficients according to the zigzag-to-raster index table below, with the low byte corresponding to raster0. 8-bit coefficients use signed two's complement; both record capacity and expansion capacity follow the transaction domain.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V3
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

## T4

- feature_ids: F4
- requirement_ids: R-bb8eef11f6a971-004
- stimulus: Transaction 3 has a Y diagonal match with block_num=0, transaction 4 is the same with block_num=1, and reset clears it at transaction 8; nonmatching blocks and nonzero block numbers are interleaved.
- expected: When the Y block with block_num=0 has raster diagonal entries 0/9/18/27/36/45/54/63 equal to -127,84,94,35,30,10,13,10, respectively, trigger_dec is set to 1; before this, its previous value is retained when the block is not block 0 or does not match. Once set to 1, it remains set until reset. The trigger takes effect after Y inverse scanning ends and affects the current and subsequent transactions; Cb/Cr do not participate in triggering.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V4
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

## T5

- feature_ids: F5
- requirement_ids: R-bb8eef11f6a971-005
- stimulus: Identical blocks before and after triggering, Y values of 127 and negative values, with Cb/Cr remaining independent channels; random sparse blocks.
- expected: When trigger_dec is active, add 1 to each Y coefficient, except that an original value of 127 remains 127; add 1 to other values as 8-bit signed values. When trigger_dec is inactive, Y is unchanged. Cb/Cr are never modified. The current Y block that matches the trigger is also modified; the trigger is not inherited after reset.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V5
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

## T6

- feature_ids: F6
- requirement_ids: R-bb8eef11f6a971-006
- stimulus: DC, sparse nonzero positions, densely populated 63 positions, positive and negative coefficients, and all Q indices; random signs and magnitudes with different seeds.
- expected: Each raster entry in all three channels is multiplied by the unsigned 8-bit constant at the same index in the Q table below; coefficients are interpreted as signed 8-bit values, and products as signed 16-bit values. The Q table is identical for Y/Cb/Cr, and all 64 coefficients participate.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V6
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

## T7

- feature_ids: F7
- requirement_ids: R-bb8eef11f6a971-007
- stimulus: Nonzero columns/rows, DC, sparse and dense blocks; including diagonal trigger vectors and random positions, with positive and negative intermediate values.
- expected: First apply the one-dimensional T(w=16) below to each column, retaining each result as a 25-bit signed value; then apply T(w=25) to each row, also retaining each result as 25 bits. Arithmetically shift the second-pass results right by 6 and take 9-bit signed values, then add 128 and clamp to 0..255. wrap_w means retaining the low w bits and interpreting them as signed; right shifts are arithmetic shifts, and no floating-point IDCT substitution is made.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V7
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

## T8

- feature_ids: F8
- requirement_ids: R-bb8eef11f6a971-008
- stimulus: Independent random signs and values for Y/Cb/Cr, positive and negative chroma, centered empty blocks, and larger coefficients that trigger RGB clamping.
- expected: For each pixel, R=clip((256*Y+359*(Cr-128))>>>8), G=clip((256*Y-88*(Cb-128)-183*(Cr-128))>>>8), B=clip((256*Y+454*(Cb-128))>>>8), where clip clamps to 0..255. The low output byte corresponds to raster0. All multiply-add operations are within the signed 20-bit range; whole-block RGB values are guaranteed only during the dec_done=1 window, and partial outputs during conversion need not be compared.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V8
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

## T9

- feature_ids: F9
- requirement_ids: R-bb8eef11f6a971-009
- stimulus: Different bitstream lengths, especially short Y with dense Cb, and dense Y; compare completion pulses, consumed bit counts, and final RGB.
- expected: dec_done is a completion pulse lasting one rising-edge update cycle. total_bits_consumed is the number of bits actually read by the Y channel, including Huffman codes and amplitudes, and including the EOB code; after updating, it remains unchanged until the next Y decoding ends or reset occurs. Cb/Cr lengths may differ; completion must wait until all three channels have reconstructed their pixels, and completion must not be lost because Y finishes first.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V9
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

## T10

- feature_ids: F10
- requirement_ids: R-bb8eef11f6a971-010
- stimulus: After driving each transaction, wait up to a limit of 4000 cycles; the sequence independently parses the expected timing according to the model and checks done at the same time; on timeout, report UVM_ERROR and continue normally.
- expected: The acceptance edge is age0. For each channel, h is 2 times the total number of Huffman code bits read, plus category+2 for each record with category>0, plus 1 for EOB; add another 2 if the length is exhausted without EOB. r is the sum of run+1 for the records other than the zero-termination record before RLE stops, plus 2; if no record with run=0 and 8-bit amplitude=0 occurs, likewise add 2 when the records are exhausted. Let i=h+r+2; then completion occurs at age=max(iY+225,iCb+160,iCr+160)+66, the Y bit count updates at age=hY+1, and the trigger match updates at age=iY+1. This timing is guaranteed only for legal complete bitstreams within the transaction domain; asynchronous reset need not wait for completion.
- checker: The same model/model.sv independently performs bitstream parsing, integer transforms, and timing prediction solely from input history. native_monitor retains four-state actual/expected 2ns after the edge; native_scoreboard compares done, trigger, and bits, and compares RGB when done; errors are reported as UVM_ERROR. Activity and completion-count checks rule out vacuity.
- implementation_id: V10
- source: tb/jpeg_pkg.sv: stimulus::body, native_driver::run_phase, native_monitor::run_phase, native_scoreboard::write/check_phase; tb/jpeg_top.sv: asynchronous reset check; model/model.sv: dvbench_model

