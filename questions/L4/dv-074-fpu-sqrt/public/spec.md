# fpu_sqrt Behavioral Contract

Version 1.0.0; only the fixed native default configuration. Both inputs and outputs interact through public ports.

### R-N113-001 — Operational boundaries

This module is a pre-normalization significand datapath for square root, not a complete IEEE754 square root: it has no sign handling, NaN/Inf handling, or final rounding; it is fixed and has no parameters. sig/exp/uf are required to be checked only in stable windows where sqrt_done=1; sqrt_done is checked every cycle.

### R-N113-002 — Active-low asynchronous reset

A falling edge of reset immediately cancels the operation and sets sqrt_done=0; start is not accepted while reset is held, and a new operation can be initiated after release. Result data is required to be checked only in the window where done is asserted.

### R-N113-003 — Start and capture timing

After start=1 is sampled on an idle rising edge, the module enters the load phase; in_sig and the scaling determined by is_subnormal and in_exp0 are sampled only on the next rising edge. start is not queued while busy; if start remains high after returning to idle, it restarts on the next edge.

### R-N113-004 — Fixed completion latency

The edge that accepts start is edge 0, edge 1 loads, and 44 iteration edges follow. At edge 46, sqrt_done=1 and the complete result is valid; done lasts one cycle and is cleared on the next edge, at which a continuously high start can be accepted.

### R-N113-005 — Integer square root and scaling

At load time, A is an 88-bit unsigned number: when is_subnormal=0 and in_exp0=0, A=in_sig multiplied by 2^64; otherwise, A=in_sig multiplied by 2^63. The completed 44-bit R=floor(sqrt(A)); it must not be inferred from actual DUT outputs.

### R-N113-006 — Normal-number projection

In the completion window, when the current is_subnormal=0, sqrt_proNorm_sig={R[43:18],OR(R[17:0])}, exp=current exp_half, and uf=0. This includes all in_sig values; the implicit bit is not assumed to be 1.

### R-N113-007 — Subnormal normalization

When the current is_subnormal=1, L is the 44-bit leading-zero count of R (L=44 when R=0), N=(R<<L) truncated to 44 bits, exp=(current exp_half-L) modulo 256, and uf=!N[43]. When rounding_mode!=3, sig={N[43:18],OR(N[17:0])}.

### R-N113-008 — Original-value low bits in mode 3

When currently subnormal and rounding_mode=3, sig={N[43:20],R[19:18],OR(R[17:0])}; the low three bits are taken from unnormalized R. The mode encoding only selects the projection here and does not perform increment rounding. Output classification, exponent, and mode are combinational values of the current inputs and must be sampled after stabilization in the done window.
