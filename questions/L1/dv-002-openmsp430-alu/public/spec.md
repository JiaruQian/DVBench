# omsp_alu Behavioral Specification

### R-dv-002-001 — Combinational Interface and Control Encoding

There is no clock, reset, or state storage; all two-state control combinations, including multi-hot combinations, are legal. Observe all outputs after the current inputs stabilize and combinational propagation completes. status supplies the old status as {V,N,Z,C}. inst_alu bits 0 through 11 are SRC_INV/INC/INC_C/ADD/AND/OR/XOR/DADD/STAT_7/STAT_F/SHIFT/EXEC_NO_WR; inst_so bits 0 through 7 are RRC/SWPB/RRA/SXT/PUSH/CALL/RETI/IRQ; inst_jmp bits 0 through 7 are JNE/JEQ/JNC/JC/JN/JGE/JL/JMP. Numerical outputs for inputs containing X/Z are unspecified; all outputs must be known for legal two-state inputs.

### R-dv-002-002 — Operand Shaping

Invert the source operand over 16 bits only when exec_cycle and SRC_INV are both 1; subsequently, clear the high 8 bits of the shaped source and destination only when exec_cycle and inst_bw are both 1. Preserve the high 8 bits otherwise. Denote the shaped nonnegative 17-bit numbers as S/D. exec_cycle=0 does not disable the entire ALU.

### R-dv-002-003 — Jumps and Binary Addition

If any asserted jump condition fails, the base addition ignores S: JNE fails at Z=1, JEQ at Z=0, JNC at C=1, JC at C=0, JN at N=0, JGE when V differs from N, and JL when V equals N. Any failure condition masks S, without exec_cycle gating; the JMP bit does not participate. The base 17-bit addition is D plus the masked S; alu_out_add always takes the low 16 bits and does not include the increment. The increment adds 1 only when exec_cycle is 1 and INC or (INC_C and old C) is true; concurrent assertions add only 1. Jumps do not mask other paths.

### R-dv-002-004 — Decimal Addition

DADD uses old C as the carry-in for the least significant group and adds S/D in 4-bit groups from low to high. Each group first forms a 5-bit sum; if it is less than 10, retain it, otherwise add 6 within 5 bits. Result bit4 propagates to the next group; concatenate the low 4 bits of each group, with bit4 of the final group becoming bit16. All nibbles, including a through f, are legal; 5-bit arithmetic overflow is truncated; in byte execution, the low-byte carry can still reach bit8. DADD is not further gated directly by jump or exec.

### R-dv-002-005 — Short Paths and Priority

AND/OR/XOR use S/D; SWPB swaps the two bytes of the original op_src, and SXT extends the low byte according to the original op_src[7]. SHIFT shifts the original source right by one bit, filling bit15 with RRC?old C:(inst_bw?original bit7:original bit15); in byte mode, bit7 is also filled with this value, bit14:8 comes from original bit15:9, and bit6:0 comes from original bit7:1. The selected AND/OR/XOR/SHIFT/SWPB/SXT results are bitwise ORed; S passes through only when none is selected. IRQ or halt or ADD takes priority in selecting the base addition plus increment, followed by DADD, and finally the short paths; data priority does not change status selection bits.

### R-dv-002-006 — Flags and Write Mask

N takes byte bit7 or word bit15 of the final alu_out; Z compares the low 8 bits for byte mode or all 16 bits for word mode. By default, C takes byte result bit8 or word internal result bit16; default V is 1 when the selected sign bits of S/D are the same and the final result sign differs. Flag priority is SHIFT>{STAT_7}>XOR>default: SHIFT gives {0,N,Z,S[0]}, STAT_7 gives {0,N,Z,!Z}, and XOR gives {S sign AND D sign,N,Z,!Z}. alu_stat_wr is 1111 only when STAT_F and exec_cycle are both 1, otherwise 0000; halt/IRQ do not provide additional gating. The RRA/PUSH/CALL/RETI/JMP/EXEC_NO_WR bits by themselves neither select an operation nor prohibit flag writes.
