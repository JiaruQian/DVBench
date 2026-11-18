## F-001

requirement_ids: ["R-BOARD-25B-001"]

module: fpgatop_taskB

definition: The complete fpgatop_taskB includes a CPU, ROM, data RAM, switch/LED peripherals, and a seven-segment display. The fixed parameters are CPU_HALF_PERIOD=4 (original default 100000000) and MEMFILE="temp_warning_test.mem"; only this accelerated configuration is evaluated. rst is active-high and asynchronous, resetting the PC/registers/board-level display data/three flags/leds and CPU clock-divider phase to zero. Reset does not clear data RAM, reload ROM, or restart seven-segment display scanning.

interface: ["clk", "rst", "sw", "seg", "an", "leds"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-002

requirement_ids: ["R-BOARD-25B-002"]

module: fpgatop_taskB

definition: The source clock toggles the CPU clock every 4 rising edges. The first instruction executes on the 4th rising edge after reset deassertion, and one instruction executes every 8 source cycles thereafter. ROM is 256 bytes, with uncovered locations filled with zeros; the low address of an instruction holds its low byte. The public attachment temp_warning_test.mem is the fixed upstream program, whose file bytes are assembled into 32-bit words in little endian order. The CPU executes the attached program starting at PC=0; its complete definition is the iteration of the instruction semantics below, not a 96-step output table. The terminal BEQ x0,x0,0 self-loop can run indefinitely; prediction must not end at step 96.

interface: ["clk", "rst", "sw", "seg", "an", "leds"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-003

requirement_ids: ["R-BOARD-25B-003"]

module: fpgatop_taskB

definition: The fixed program executes only LUI, ADDI, BEQ, BLT, BGE, JAL, and JALR. The 32-bit registers reset to zero, and x0 is always zero; arithmetic is modulo 2^32. LUI writes the upper 20 immediate bits shifted left by 12; ADDI adds rs1 to the sign-extended 12-bit immediate; BEQ compares for equality, while BLT/BGE use 32-bit signed comparisons. A taken conditional branch sets the PC to PC plus the sign-extended B-type offset; otherwise, it becomes PC+4. JAL writes PC+4 and sets the PC to PC plus the J-type offset; JALR writes PC+4 and sets the PC to (rs1+I-type immediate)&~1. Standard RISC-V B/J immediate bit assembly applies; only these instructions reached by this fixed program constitute the software domain of this task.

interface: ["clk", "rst", "sw", "seg", "an", "leds"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-004

requirement_ids: ["R-BOARD-25B-004"]

module: fpgatop_taskB

definition: At each CPU rising edge, writeback is calculated using the old register inputs of the instruction executed on that edge; the 16-bit display value is updated only when RegWrite is asserted and rd is nonzero. For LUI, the display shows the low 16 bits of writeback; otherwise, it shows, in order, the decimal tens digit of rd, its ones digit, and the high and low hexadecimal nibbles of the low byte of writeback. It holds its value when there is no writeback. All displays are observable once propagation has settled after the CPU edge triggered by the source rising edge; no additional wait for the next CPU edge is required.

interface: ["clk", "rst", "sw", "seg", "an", "leds"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-005

requirement_ids: ["R-BOARD-25B-005"]

module: fpgatop_taskB

definition: When LUI executes on a CPU edge, leds is the high 16 bits of writeback. For other instructions, leds[15:6]=0; bits 5/4/3 are the old fail/bge/blt flags, respectively, and bits 2/1/0 indicate the current JALR/JAL/branch instruction classes, respectively. The branch-class bit does not indicate whether the branch is taken. When rd10/11/12 is written, the corresponding flag is updated to writeback bit 0; leds still uses the pre-update flags on that same edge, and the new flags are not displayed until the next execution edge for a non-LUI instruction. The peripheral LED register is not the direct source of this board-level leds output.

interface: ["clk", "rst", "sw", "seg", "an", "leds"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-006

requirement_ids: ["R-BOARD-25B-006"]

module: fpgatop_taskB

definition: Scanning is independently driven by the source clock. The 16-bit counter initially equals 0, and the 2-bit digit selector initially equals 0. On each source rising edge, first check whether the old count is 0; if so, increment the digit selector by 1, then increment the count by 1 modulo 65536. Thus, the digit selector changes from 0 to 1 on the first source edge and advances every 65536 cycles thereafter; rst does not change the scanning phase. Digit selections 0/1/2/3 correspond to the display-value nibbles from low to high, with an equal to 1110/1101/1011/0111, respectively, all active-low.

interface: ["clk", "rst", "sw", "seg", "an", "leds"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-007

requirement_ids: ["R-BOARD-25B-007"]

module: fpgatop_taskB

definition: seg[6:0] is active-low. The codes for hexadecimal 0..F are, in order, 40, 79, 24, 30, 19, 12, 02, 78, 00, 10, 08, 03, 46, 21, 06, and 0e (all hexadecimal, 7-bit). seg combinationally reflects the currently selected display nibble; neither an nor seg has additional clocked-register latency. Legal program displays constrain only digits actually reached; modifying the program to reach all decoder inputs is not required.

interface: ["clk", "rst", "sw", "seg", "an", "leds"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.

## F-008

requirement_ids: ["R-BOARD-25B-008"]

module: fpgatop_taskB

definition: sw[15:0] is an input. CPU address bits [9:8] select data RAM when 00, the LED peripheral when 01, and the switches when 10; a switch read returns zero-extended sw. The current fixed program executes no load/store instructions, so changes to sw do not affect the observable outputs of this task. RAM and peripheral write behavior are not ISA obligations testable through the ports in this task. X/Z inputs and replacing the program are outside the domain; this task does not claim that the full ISA or the original default long clock division has been tested.

interface: ["clk", "rst", "sw", "seg", "an", "leds"]

timing: Observe according to the source clock/derived clock or inter-edge reset window explicitly specified in this item; sample values after output propagation has settled.

boundary: Only fixed parameters, firmware, and reachable native input histories are public; do not extrapolate to undisclosed ports or undefined X/Z domains.
