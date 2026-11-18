# ibex_alu_mut black-box verification specification

The following natural-language contract defines behavior using native ports only. Parameter configurations are independent; transactions are not paired across configurations.

### R-ALU-001 — Interface, parameters, and valid observations

ibex_alu_mut is combinational, with no clock or internal state. Inputs are operator_i[6:0], operand_a_i/operand_b_i[31:0], instr_first_cycle_i, multdiv_operand_a_i/multdiv_operand_b_i[32:0], multdiv_sel_i, and imd_val_q_i[63:0]. Outputs are imd_val_d_o[63:0], imd_val_we_o[1:0], adder_result_o[31:0], adder_result_ext_o[33:0], result_o[31:0], comparison_result_o, and is_equal_result_o. Verify RV32B=0,1,2,3 separately; its default is 0 and each instance fixes its parameter at compilation. Inputs are deterministic two-state values. Every opcode 0..127 is legal. Unknown or disabled operations produce result_o=0, while other outputs follow their own rules. instr_first_cycle_i and imd_val_q_i are externally supplied combinational inputs, not internal registers, and need not come from earlier DUT outputs.

After driving inputs, allow combinational settling and compare all seven outputs. There is no reset, clock edge, or ready/valid handshake. The domain includes all 128 opcodes, all four RV32B values, zero/all-one/sign boundaries, arbitrary IMD, and 33-bit bypass values. X/Z and transient delta-cycle behavior are outside scope.

### R-ALU-002 — Extended addition, subtraction, shift-add, and bypass

Construct 33-bit addends A={operand_a_i,1} and B={operand_b_i,0}. For opcodes 1,25..34,43,44, invert all 33 bits of B. When RV32B is nonzero, opcodes 22/23/24 first shift the 32-bit operand_a_i left by 1/2/3, truncate to 32 bits, and append the low bit 1 to form A. multdiv_sel_i=1 takes priority and replaces both addends with the corresponding 33-bit multdiv inputs. adder_result_ext_o is the complete 34-bit unsigned sum; adder_result_o is its [32:1] slice. For opcodes 0,1,22,23,24, result_o equals adder_result_o.

These adder outputs remain valid for all opcodes independently of result_o selection. Compare after bypass changes settle. The domain includes carry, borrow, shift truncation, two all-one 33-bit addends, and bypass combined with subtraction/shift-add controls. With RV32B=0, opcodes 22..24 use ordinary addition.

### R-ALU-003 — Comparison flags and results

is_equal_result_o always means adder_result_o is zero; it does not mean the original operands are equal for every opcode. Opcodes 25,27,31,33,43 select signed comparison control. If the original operands have the same sign, GE is the inverse of the top bit of adder_result_o. If their signs differ, GE is operand_a_i's top bit XOR signed comparison control. comparison_result_o is equal for opcode 29, not-equal for 30, GE for 27/28/33/34, not-GE for 25/26/31/32/43/44, and equal for other opcodes. For opcodes 25..30 and 43/44, result_o is this flag zero-extended to 32 bits. Bypass may alter the adder, equality flag, and same-sign comparison flag.

Compare both flags and result_o in the same settled window, including flags on non-comparison opcodes. Cover equal/unequal operands, opposite signs, same-sign overflow, and bypass. Replacing equal with a==b for all opcodes is incorrect.

### R-ALU-004 — Logic and fixed XOR special case

Opcodes 3/6 perform OR, 4/7 perform AND, and 2/5 perform XOR. With nonzero RV32B, opcodes 5/6/7 first invert the 32-bit B operand; with RV32B=0 they do not. For opcodes 2 and 5, if operand_a_i is exactly hexadecimal cafef00d, flip the low bit of the normal XOR result. cafef00c does not trigger it. This is fixed observable behavior of this task; no design intent is implied.

Compare result_o after settling. first does not affect these six logic opcodes. Include cafef00d, cafef00c, zero, all ones, and alternating patterns, distinguishing OR/AND and inverted/non-inverted B.

### R-ALU-005 — Basic and one-filling shifts

The effective shift amount is B[4:0] when first=1 and (32-B[4:0]) mod 32 when first=0, including RV32B=0. Opcode 10 shifts left, 9 shifts right logically, and 8 shifts right arithmetically. At RV32B=2 or 3, opcodes 11/12 shift right/left filling with ones. At RV32B=0 or 1, both 11 and 12 instead perform logical right shift. Shifted-out bits are discarded; arithmetic right shift extends A's sign bit.

first is the current combinational input: changing it recalculates the amount without implicit cycle state. Include low-five-bit amounts 0,1,15,16,31; the complemented amount for zero remains zero. Negative and all-one operands are legal.

### R-ALU-006 — Min/max, packing, sign extension, and counts

With nonzero RV32B, opcodes 31/32 are signed/unsigned min and 33/34 are signed/unsigned max. Each selects A when comparison_result_o=1, otherwise B. Opcode 35 produces {B low16,A low16}, 36 produces {B high16,A high16}, and 37 produces {16 zero bits,B low8,A low8}. Opcodes 38/39 sign-extend A's low 8/16 bits. Opcodes 40/41 count A's leading/trailing zeros, returning 32 for A=0; 42 counts set bits. With RV32B=0 these result_o values are all zero.

All are combinational, and min/max selection still follows comparator bypass behavior. Include zero counts of 32, all-one population count 32, each one-hot position, sign-extension boundaries, and equal/opposite-sign extrema.

### R-ALU-007 — Generalized reversal, shuffle, and element permutation

With nonzero RV32B, 15 is GREV and 16 is GORC. Starting from A, swap bit pairs at distances 1/2/4/8/16 under the corresponding effective-shift control bits. GORC ORs the swapped result with the pre-swap value. At RV32B=1, the low three control bits each copy amount bit0 and the high two each copy bit3; GORC's distance-8/16 stages swap without OR. Only RV32B=2/3 support shuffle/unshuffle 17/18 and 4/8/16-bit element permutations 19/20/21; other RV32B values return zero for them. Shuffle processes distances 8/4/2/1 in that order. In each 4d-bit block it exchanges the middle two d-bit groups, controlled by amount bits 3/2/1/0 respectively. Unshuffle first reverses the five-bit index of every bit, applies the same four stages controlled by bits 0/1/2/3, and reverses indices again. Element permutation treats each 4/8/16-bit B element as an index selecting the same-width A element; out-of-range indices produce zero.

Shift controls follow the first-dependent complement rule. Element permutations use complete B elements, not the shift amount. Include every control combination, the largest valid and out-of-range indices, asymmetric/random patterns, and parameter capability differences.

### R-ALU-008 — Single-bit operations and bit-field insertion

With nonzero RV32B, 49/50/51 set/clear/toggle the A bit indexed by the effective shift amount; 52 extracts that bit into bit0 and clears all others. Opcode 55 inserts a field. Length is B[27:24], with zero encoding 16; offset is B[20:16] independently of first. Clear that length-bit window of A, then OR B's low length bits shifted to the offset. Bits beyond bit31 are discarded. At RV32B=0 these result_o values are zero.

Single-bit operations use the first-dependent amount; field offset does not. Include offsets 0/31, lengths 1/15/16, windows extending beyond the word, and original target bits of both values.

### R-ALU-009 — Carryless multiplication

At RV32B=2/3, interpret A and B as GF(2) polynomials. Form the 64-bit product using bitwise AND and XOR addition, with no integer carry. Opcode 56 selects product[31:0], 57 selects [62:31], and 58 selects [63:32]. RV32B=0/1 return zero. Compare settled result_o independently of first. Include 0,1, the top bit, dense all-one, sparse/random polynomials, and distinguish all three slices.

### R-ALU-010 — External IMD combinational protocol and CRC

Here A and B denote the original 32-bit operands. With nonzero RV32B, the usual imd_val_d_o={A,32 zero bits} and we=0. Opcode 45 returns A when B=0 and otherwise IMD's high 32 bits; its write data is {A,0}. For 46, part=A AND (B if first, otherwise NOT B); result=IMD high32 OR part and write data={part,0}. Opcodes 13/14 form two-step right/left rotate fragments; 47/48 form two-step left/right funnel fragments. The low shift amount depends on first and B bit5: for funnel with bit5=1, first uses the complemented amount and non-first uses the original low five bits; otherwise the reverse applies. Opcode 13 shifts right on first and left otherwise; 14 does the opposite. For 47, first shifts left when B bit5=0 and right when bit5=1; 48 does the opposite. If the low amount is zero, result is A for funnel with B bit5=1, otherwise IMD high32. For nonzero amounts, result=IMD high32 OR shifted fragment; write data={fragment,0}. These operations set we=01 only when first=1.

At RV32B=2/3, opcodes 59..64 form two-step CRC fragments. For 59/60, the input is A low8 shifted left24; for 61/62, A low16 shifted left16; for 63/64, complete A. first selects this input; otherwise select IMD high32. Odd opcodes use polynomial 04c11db7 and reciprocal constant f7011641; even opcodes use 1edc6f41 and dea713f1. Carrylessly multiply by the reciprocal on first and by the polynomial otherwise, take the low32 bits, and reverse their bit order to obtain part. For 59/60, result additionally XORs A shifted right8; for 61/62, right16; 63/64 return part. Write data={part,0}; we=01 on first and zero otherwise. With RV32B=0, all IMD outputs and these result values are zero. RV32B=1 does not support CRC: CRC result=0 and IMD retains its usual value.

IMD may be any deterministic external value; the module stores no fragment. Check after each first/B/IMD change settles. we bit numbering follows the port, without assuming external bank names. Include B zero/nonzero, shift amounts 0/31, funnel bit5, both first values, arbitrary IMD halves, both polynomials, and 8/16/32-bit CRC inputs.

### R-ALU-011 — Full bit expansion/compression network and IMD encoding

Only RV32B=3 supports opcodes 53/54. Let C[i] be the population count of B[0..i]. Bit i of the IMD write-data high half stores C[i] bit0. In the low half, bits 0..15 store C[2j+1] bit1, bits 16..23 store C[4j+3] bit2, bits 24..27 store C[8j+7] bit3, bits 28..29 store C[16j+15] bit4, bit30 stores C[31] bit5, and bit31 is zero. we=11 on first, otherwise zero. Decode result-control counts from the current input IMD using that layout, treating bits not stored at an index as zero. For half-block widths d=16,8,4,2,1 and each 2d-bit block, take the low log2(d)+1 bits c of the decoded count at the low half's end. Shift a word of d ones left by c in 2d bits, invert its high d bits to form an exchange mask, and exchange bit pairs distance d apart according to that mask. Opcode 54 starts with A, exchanges in descending d order, then ANDs B. Opcode 53 starts with A AND B and exchanges in ascending d order. At other RV32B values, 53/54 return zero and use usual IMD data with we=0.

first controls only write enable. The result always uses current input IMD counts, not newly generated write data. Include zero/all-one/sparse/random B, arbitrary IMD, and both first values. Distinguish opcode order and input IMD from current-B counts.
