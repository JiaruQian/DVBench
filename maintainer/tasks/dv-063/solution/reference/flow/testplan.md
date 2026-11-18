## T-001

feature_ids: ["F-001"]

requirement_ids: ["R-e1a3b2bbb3ae-001"]

stimulus: Reset for the initial 4 cycles and apply mid-run reset between edges every 350 cycles; after reset, load before starting; check clearing and cancellation between edges.

expected: rst is an active-high asynchronous reset; after assertion, idle=1 and oBlock=0, the counter and captured plaintext are cleared, and current work is canceled. The generated round-key table is not cleared; encryption data is undefined when starting before a load has completed after power-up, and one load must complete before data is evaluated.

checker: Prediction uses only input history; drive on falling edges, and have the monitor compare native outputs against an independent model 2ns after falling edges and 2ns after rising edges, reporting UVM_ERROR for four-state mismatches; the comparison count must be nonzero, and judgment is based on the unique UVM summary and normal termination.

implementation_id: V-001

source: tb.sv:dvbench_monitor.run_phase;tb.sv:dvbench_scoreboard.write;stimulus.sv:sample_pins

## T-002

feature_ids: ["F-002"]

requirement_ids: ["R-e1a3b2bbb3ae-002"]

stimulus: Load on the 5th cycle of every 350-cycle interval, then change key/iv; also apply busy-state load and same-cycle load/start, observing edge by edge.

expected: A load is accepted on a rising edge with idle=1 and load=1, sampling iv as the 128-bit counter and key as the AES-128 key; load takes priority over simultaneous start, and iBlock is not captured on this edge. Following a normal single-cycle load, idle returns to 1 on the 12th rising edge after acceptance; sustained load can restart expansion. While busy, the top level no longer loads iv, but load is passed directly to the key generator: this generator can accept load when it is not expanding, affecting keys used later; busy-state load cannot be treated as universally having no effect.

checker: Prediction uses only input history; drive on falling edges, and have the monitor compare native outputs against an independent model 2ns after falling edges and 2ns after rising edges, reporting UVM_ERROR for four-state mismatches; the comparison count must be nonzero, and judgment is based on the unique UVM summary and normal termination.

implementation_id: V-002

source: tb.sv:dvbench_monitor.run_phase;tb.sv:dvbench_scoreboard.write;stimulus.sv:sample_pins

## T-003

feature_ids: ["F-003"]

requirement_ids: ["R-e1a3b2bbb3ae-003"]

stimulus: Run consecutive blocks to completion, with iv covering the highest bit and all-ones wraparound; independently calculate key expansion, per-round data, and completion times from input history.

expected: A normal start pulse is accepted on a rising edge with idle=1 and captures iBlock, performing standard AES-128 encryption using the counter value before that edge; ultimately oBlock=captured plaintext XOR AES(key,counter). The AES final-round result is formed on the 11th edge after acceptance; on the 13th edge, idle returns to 1 and the entire 128-bit counter is incremented by 1, with overflow wrapping modulo 2^128. The completed result is retained until a new operation or reset. Bytes are arranged in AES column-major order starting from [127:120]; the standard AES S-box, GF(2^8) modulo 0x11b, ShiftRows and MixColumns, and the standard 11 round keys are used.

checker: Prediction uses only input history; drive on falling edges, and have the monitor compare native outputs against an independent model 2ns after falling edges and 2ns after rising edges, reporting UVM_ERROR for four-state mismatches; the comparison count must be nonzero, and judgment is based on the unique UVM summary and normal termination.

implementation_id: V-003

source: tb.sv:dvbench_monitor.run_phase;tb.sv:dvbench_scoreboard.write;stimulus.sv:sample_pins

## T-004

feature_ids: ["F-004"]

requirement_ids: ["R-e1a3b2bbb3ae-004"]

stimulus: After the first key becomes valid, insert busy start, continuous start, busy load, and overlapping load/start; change input plaintext to check the differences between the two acceptance windows and the intermediate outputs.

expected: oBlock is always the current AES intermediate block XOR the plaintext captured by the top level, not just at the completion edge; the acceptance edge that starts AES first exposes the counter block, the 1st edge performs the initial key XOR, the 2nd through 10th edges perform 9 full rounds, and the 11th edge performs the final round omitting MixColumns. When the AES engine is idle, start starts it directly, independently of top-level idle, so busy-state/long start can restart AES before the top level returns to idle; the top level captures plaintext only when it is itself idle and load=0. During key expansion, the keys used for AES rounds are all 0; otherwise, written table entries are selected according to the current round number; when expansion is canceled by reset, unwritten table entries retain their old values.

checker: Prediction uses only input history; drive on falling edges, and have the monitor compare native outputs against an independent model 2ns after falling edges and 2ns after rising edges, reporting UVM_ERROR for four-state mismatches; the comparison count must be nonzero, and judgment is based on the unique UVM summary and normal termination.

implementation_id: V-004

source: tb.sv:dvbench_monitor.run_phase;tb.sv:dvbench_scoreboard.write;stimulus.sv:sample_pins
