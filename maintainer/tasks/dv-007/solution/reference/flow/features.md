## F-1

requirement_ids: R-dv-007-001

module: ram_2x336

definition: On the rising edge of W0_clk, when W0_en=1 and bit i of W0_mask is 1, bit i at address W0_addr is overwritten by the corresponding bit of W0_data, with i ranging from 0 to 335; unselected bits retain their values.

interface: W0_clk, W0_en, W0_addr, W0_data, W0_mask, R0_addr, R0_en, R0_data

timing: When combinational logic is stable after the write edge; for a read of the same address, check the new value after the update.

boundary: All addresses are 0 or 1; controls, data, and masks are two-state and stable before and after the write edge. There is no reset. Values of storage bits that have never been written are unspecified; do not compare these bits. The all-X value when R0_en=0 is an explicitly defined four-state output and must be checked bit by bit.

## F-2

requirement_ids: R-dv-007-002

module: ram_2x336

definition: When W0_en=0 or W0_mask is all zeros, storage is not modified; writing one word does not change the other word.

interface: W0_clk, W0_en, W0_addr, W0_mask, R0_addr, R0_en, R0_data

timing: After each write edge, read both addresses separately through combinational reads.

boundary: All addresses are 0 or 1; controls, data, and masks are two-state and stable before and after the write edge. There is no reset. Values of storage bits that have never been written are unspecified; do not compare these bits. The all-X value when R0_en=0 is an explicitly defined four-state output and must be checked bit by bit.

## F-3

requirement_ids: R-dv-007-003

module: ram_2x336

definition: When R0_en=1, R0_data combinationally equals the word at the current R0_addr; after the read address changes or a write to the same address completes, it updates without requiring an R0_clk edge. Any change in R0_clk does not alter storage or read semantics.

interface: R0_addr, R0_en, R0_clk, R0_data, W0_clk, W0_addr, W0_en, W0_data, W0_mask

timing: Sample when combinational logic is stable after read input changes and after the write NBA completes, without waiting for the read clock.

boundary: All addresses are 0 or 1; controls, data, and masks are two-state and stable before and after the write edge. There is no reset. Values of storage bits that have never been written are unspecified; do not compare these bits. The all-X value when R0_en=0 is an explicitly defined four-state output and must be checked bit by bit.

## F-4

requirement_ids: R-dv-007-004

module: ram_2x336

definition: When R0_en=0, all 336 bits of R0_data are X; it neither retains the previous data nor becomes all zeros. After re-enabling, it reads back storage.

interface: R0_en, R0_addr, R0_data

timing: After combinational logic stabilizes following each enable change, check for all X bit by bit using case equality when reading is disabled.

boundary: All addresses are 0 or 1; controls, data, and masks are two-state and stable before and after the write edge. There is no reset. Values of storage bits that have never been written are unspecified; do not compare these bits. The all-X value when R0_en=0 is an explicitly defined four-state output and must be checked bit by bit.
