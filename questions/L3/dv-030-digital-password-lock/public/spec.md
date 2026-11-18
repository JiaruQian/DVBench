# Digital_lock_top

Complete native Digital_lock_top, fixed with no parameters. Counts on every rising edge of CLOCK_50Mhz; the internal FSM first updates on source cycle 25000000, and then updates every 50000000 cycles. KEY_0 does not reset this divider phase. All keypad inputs are two-state; digits are 0 through 9, command C is 10, and other values are not accepted as password digits.

### R-dv-030-001 — Reset and static outputs

Low KEY_0 asynchronously locks and restores password 1122, with lock=0, lock_c=0, and HEX0 all ones; LCD_ON and LCD_BLON are always 1, and LCD_RW is always 0. LCD reset outputs are RS=0, EN=0, DATA=0x38. After KEY_0 is released, the original divider phase is retained.

### R-dv-030-002 — Combinational seven-segment display

After reset is released, when key_valid=1 and not in blocked, HEX0 combinationally displays the current keypad_input: 0 through 9 use standard active-low seven-segment patterns, and 10 displays C (1000110); other values and key_valid=0 display all ones; during blocked, it is all ones. There is no need to wait for an FSM cycle.

### R-dv-030-003 — Password and unlocking

One valid digit is accepted on each FSM rising edge, even when key_valid remains continuously high; 1122 enters unlock after the fourth digit, and lock is not set to 1 until the next FSM edge. An incorrect password enters wrong, and lock=0 on the next edge; both the first three digits and the fourth digit must match.

### R-dv-030-004 — Timeout and error count

While digit entry is incomplete, four consecutive FSM cycles without a valid digit bring the idle count to 4, and one more cycle without a valid digit returns to idle; a valid digit takes priority over timeout. The error state returns to idle after remaining for five FSM cycles; three accumulated errors enter blocked, and blocked returns to idle after 101 FSM cycles and clears the error count. A successful password clears the error count.

### R-dv-030-005 — Unlock duration

Without a C command, the unlock state returns to idle and locks after running for 11 FSM edges. C is valid only in unlock and enters the password-change wait; lock remains unlocked until the corresponding password-change completion, failure, or timeout path.

### R-dv-030-006 — Password change

After unlock accepts C, enter the four digits of the old password, then use one additional FSM cycle to check it; if correct, lock_c is set to 1 and new-password collection begins. After four new digits are received, the password is replaced atomically and lock and lock_c are cleared to 0. If the old password is incorrect, the error count is incremented and wrong is entered; a timeout in any digit-entry stage of password change locks and clears lock_c to 0. Reset restores 1122.

### R-dv-030-007 — LCD protocol

The LCD source divider first produces an internal rising edge on source cycle 1, then on cycle 25002, and then every 50001 cycles. After reset, alternating between high-EN action and low-EN hold, it sends eight initialization commands 38/38/38/38/08/01/06/0C, followed by HOME=80, 16 first-line characters, LINE2=C0, and 16 second-line characters, and repeats. RS is 0 for commands and 1 for characters. Each line is padded with spaces to 16 ASCII bytes: idle has ENTER PASSWORD on the first line and a blank second line; unlock has DOOR UNLOCKED on the first line and AUTO Lock Soon.. on the second line; wrong has WRONG PASSWORD! on the first line and Try Again on the second line; timeout has TIMEOUT ERROR on the first line and Start Again on the second line; all password-change stages have CHANGE PASSWORD on the first line and Enter New Code on the second line; blocked has four spaces followed by BLOCKED on the first line and a blank second line. idle displays timeout when the idle count reaches 4, as do incomplete ordinary password-entry stages. Each character uses the state at the time it is sent; whole-frame atomicity is not guaranteed.

