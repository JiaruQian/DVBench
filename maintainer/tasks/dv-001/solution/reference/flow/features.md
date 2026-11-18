# Reference Features

## F-1: Combinational interface and defined input domain

The module top is a stateless combinational four-bit unsigned ALU with a decimal display selector. Inputs screen[1:0], opcode[2:0], A[3:0], B[3:0], and carry_in affect the outputs as specified below. There is no clock, reset or handshake. Compare outputs only after input changes have settled. All specified behavior applies to inputs containing only 0 and 1; behavior with X or Z inputs is unspecified.

Interface: screen, opcode, A, B, carry_in, carry_out, overflow, bcd, error. Observe after the input has stabilized and propagated combinationally; there is no request or clock acceptance event.

## F-2: Display selection and decimal encoding

screen=0 displays the unsigned opcode (0 through 7); screen=1 displays unsigned A; screen=2 displays unsigned B; screen=3 displays the selected ALU result. The displayed value is encoded as three packed BCD digits: bcd[11:8] is hundreds, bcd[7:4] tens, and bcd[3:0] ones. Each digit is 0 through 9 and leading zeros are retained. Operand displays cover 0 through 15; multiplication results can reach 225. Display selection does not change the error rule in R-dv-001-006.

Interface: screen, opcode, A, B, carry_in, carry_out, overflow, bcd, error. Observe after the input has stabilized and propagated combinationally; there is no request or clock acceptance event.

## F-3: Addition, carry and unsigned overflow

When screen=3 and opcode=0, let S=A+B+carry_in using unsigned arithmetic. Display S modulo 16; carry_out=1 exactly when S is at least 16, otherwise carry_out=0. overflow equals carry_out in this mode: it denotes unsigned four-bit addition overflow, not signed two's-complement overflow. Both carry_in values are supported, including 15+15+1=31 (display 15, carry_out=1, overflow=1).

Interface: screen, opcode, A, B, carry_in, carry_out, overflow, bcd, error. Observe after the input has stabilized and propagated combinationally; there is no request or clock acceptance event.

## F-4: Subtraction and borrow

When screen=3 and opcode=1, let D=A-B-carry_in using unsigned operands and treating carry_in as borrow-in. Display the nonnegative residue D modulo 16. carry_out is the borrow-out: it is 1 exactly when A is less than B+carry_in, otherwise 0. overflow=0. For example, 0-0-1 displays 15 with borrow-out 1, while 15-0-0 displays 15 with borrow-out 0.

Interface: screen, opcode, A, B, carry_in, carry_out, overflow, bcd, error. Observe after the input has stabilized and propagated combinationally; there is no request or clock acceptance event.

## F-5: Multiplication and bitwise operations

When screen=3, opcode=2 displays the full unsigned product A*B (0 through 225); opcode=3 displays A AND B; opcode=4 displays A OR B; opcode=5 displays A XOR B. The bitwise results are four-bit unsigned values displayed in decimal. carry_in has no effect in these four modes. carry_out=0 and overflow=0 in all four modes.

Interface: screen, opcode, A, B, carry_in, carry_out, overflow, bcd, error. Observe after the input has stabilized and propagated combinationally; there is no request or clock acceptance event.

## F-6: Invalid opcodes and inactive arithmetic flags

error=1 exactly when opcode is 6 or 7, for every screen value; error=0 for opcodes 0 through 5. When screen=3 and opcode is invalid, display zero and set carry_out=0 and overflow=0. When screen is 0, 1 or 2, carry_out=0 and overflow=0 regardless of opcode, operands and carry_in; display the opcode or operand selected by screen even if error=1. In particular, opcode=7 with screen=0 displays BCD 007 and error=1.

Interface: screen, opcode, A, B, carry_in, carry_out, overflow, bcd, error. Observe after the input has stabilized and propagated combinationally; there is no request or clock acceptance event.
