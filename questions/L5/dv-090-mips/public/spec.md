# Controller Black-Box Behavioral Specification

This specification is based on the actual native-port behavior of the frozen fixed version; program attachments are fixed legal input data.

### R-MIPS-25B-001 — Interface and reset

The complete Controller retains the five-stage pipeline, ROM, and RAM containing 64 32-bit words. It advances on rising edges of Clk, and Reset is active high. Peripheral result_valid/result_data are asynchronously cleared on a rising edge of Reset; CPU pipeline/PC reset must be held for at least 8 Clk cycles. Inputs must be stable before reset release, driving occurs after falling edges, and results are observed after propagation has settled following rising edges. Reset does not reload ROM/RAM; do not assess capabilities using a history with no reset.

### R-MIPS-25B-002 — Firmware and memory

PROGRAM_FILE is fixed to "code.txt". The public attachment contains 32-bit hexadecimal instruction words. ROM is read using byte PC>>2, has a capacity of 1025 words, and unwritten locations are filled with NOP. test_data.txt contains the RAM power-up initial words; uncovered words are 0. The fixed firmware consists, in order, of 8 NOPs, then ADDI r8,r0,-8; thereafter, each non-NOP is followed by 8 NOPs, with the non-NOPs in this order: LW r9,0(r8), ADDI r10,r9,7, SW r10,0(r0), LW r11,0(r0), ADDI r11,r11,-3, SW r11,4(r8). All remaining instructions are NOPs. The original complete CPU is retained; ISA correctness for other programs or branches is not guaranteed.

### R-MIPS-25B-003 — Inputs and MMIO

Byte address fffffff8 is the 32-bit input peripheral, and fffffffc is the state-holding output peripheral. Peripheral reads select using the full address, without aliasing based on low bits; writes to the input are ignored, and peripheral writes do not reach RAM. The output accepts only SW width (BHW=2); SB/SH cannot produce output. This fixed program uses only word accesses, and the input read is latched on the 21st rising edge of Clk after reset release. Thus, input_data may change during other cycles as long as it is stable at that sampling edge; legal tests must not depend on unreached software branches.

### R-MIPS-25B-004 — Arithmetic and RAM round trip

The fixed program adds 7 to the sampled input using 32-bit modular arithmetic, writes it to RAM byte address 0, reads it back, and then adds the sign-extended immediate -3. The final value is the sampled input+4. r0 reads as zero, and NOP does not change functional registers. Addition does not trigger an overflow exception. RAM word accesses preserve all 32 bits, and the negative immediate must be sign-extended, not treated as 65533; this is the complete observable arithmetic contract for the fixed legal software domain.

### R-MIPS-25B-005 — Result transaction and retention

The 66th rising edge of Clk after release produces the sole cycle with result_valid=1, and result_data updates to the result above on that same edge. On the 67th edge, valid returns to 0, and data is retained until the next reset or legal output write. The fixed program has no subsequent output; valid is 0 from edges 1 through 65 and after the 67th edge. Reset takes priority over output, so even if asserted just before the scheduled output, no old transaction leaks through.

### R-MIPS-25B-006 — Timing and scope

Use only deterministic binary inputs and the fixed PROGRAM_FILE; hierarchical probes, backdoors, force, and ROM replacement are prohibited. Data comparison points include inter-edge reset windows, after settling following every rising edge, and after input changes between edges. Reference expectations depend only on input history and the public firmware. Pipeline BHW propagation and the writeback-address race have been fixed in this version; the old top level without outputs and the original branch path are not measurement targets for the new problem.
