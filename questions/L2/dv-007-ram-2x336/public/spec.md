# ram_2x336 Behavioral Contract

All addresses are 0 or 1; controls, data, and masks are two-state and stable before and after the write edge. There is no reset. Values of storage bits that have never been written are unspecified; do not compare these bits. The all-X value when R0_en=0 is an explicitly defined four-state output and must be checked bit by bit.

### R-dv-007-001 — Bitwise Masked Write

On the rising edge of W0_clk, when W0_en=1 and bit i of W0_mask is 1, bit i at address W0_addr is overwritten by the corresponding bit of W0_data, with i ranging from 0 to 335; unselected bits retain their values.

### R-dv-007-002 — Write Disable and Address Isolation

When W0_en=0 or W0_mask is all zeros, storage is not modified; writing one word does not change the other word.

### R-dv-007-003 — Asynchronous Read and Ineffective Read Clock

When R0_en=1, R0_data combinationally equals the word at the current R0_addr; after the read address changes or a write to the same address completes, it updates without requiring an R0_clk edge. Any change in R0_clk does not alter storage or read semantics.

### R-dv-007-004 — Four-State Output When Reading Is Disabled

When R0_en=0, all 336 bits of R0_data are X; it neither retains the previous data nor becomes all zeros. After re-enabling, it reads back storage.

