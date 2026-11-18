## T-1

feature_ids: F-1

requirement_ids: R-dv-007-001

stimulus: First write both addresses separately with a full mask to establish independent known mirror values for all bits. Apply all-zero, all-one, alternating, single-bit 0/335, and walking masks for every bit to each of the two addresses; use random data and masks; change data between write edges to confirm that no write is committed.

expected: On the rising edge of W0_clk, when W0_en=1 and bit i of W0_mask is 1, bit i at address W0_addr is overwritten by the corresponding bit of W0_data, with i ranging from 0 through 335; unselected bits retain their values.

checker: Predict using an independent input-history model, without reading the DUT's actual output. Check after combinational settling following the write edge; for a same-address read, check the new value after the update. Use bitwise four-state comparison of actual and expected; report UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-1

source: reference_pkg.sv:native_scoreboard.write

## T-2

feature_ids: F-2

requirement_ids: R-dv-007-002

stimulus: With a full mask, write 0 to address 0 and all ones to address 1. Interleave disabled writes and zero-mask writes across the two addresses, invert the data, and then read back both words; then update only one address.

expected: When W0_en=0 or W0_mask is all zeros, storage is not modified; writing one word does not change the other word.

checker: Predict using an independent input-history model, without reading the DUT's actual output. After each write edge, read both addresses separately using combinational reads. Use bitwise four-state comparison of actual and expected; report UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-2

source: reference_pkg.sv:native_scoreboard.write

## T-3

feature_ids: F-3

requirement_ids: R-dv-007-003

stimulus: Initialize the two addresses with different patterns; R0_clk may be stopped at 0 or 1. With R0_clk stopped, change the read address and enable; read after writes with the two clocks out of phase and with coincident edges; repeat the checks while toggling only R0_clk.

expected: When R0_en=1, R0_data combinationally equals the word at the current R0_addr; after the read address changes or a same-address write completes, it updates without requiring an R0_clk edge. Any change in R0_clk does not alter storage or read semantics.

checker: Predict using an independent input-history model, without reading the DUT's actual output. Sample after combinational settling following read-input changes and completion of the write NBA, without waiting for the read clock. Use bitwise four-state comparison of actual and expected; report UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-3

source: reference_pkg.sv:native_scoreboard.write

## T-4

feature_ids: F-4

requirement_ids: R-dv-007-004

stimulus: Initialize two words, first reading zero and nonzero patterns, respectively. For both addresses, transition the read enable 1→0→1; while reads are disabled, change the address, write known patterns, and toggle R0_clk.

expected: When R0_en=0, all 336 bits of R0_data are X, neither retaining the previous data nor being all zeros; after re-enabling, read back the stored contents.

checker: Predict using an independent input-history model, without reading the DUT's actual output. After combinational settling following each enable change, use bitwise case equality to check for all X while reads are disabled. Use bitwise four-state comparison of actual and expected; report UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-4

source: reference_pkg.sv:native_scoreboard.write
