## T-001

feature_ids: ["F-001"]

requirement_ids: ["R-BOARD-25B-001"]

stimulus: Asynchronously assert rst during operation, and compare leds and the segment code for zero at the currently scanned digit between edges; hold for 8 cycles before deasserting, and repeat resets at different phases.

expected: The complete fpgatop_taskB includes a CPU, ROM, data RAM, switch/LED peripherals, and a seven-segment display. The fixed parameters are CPU_HALF_PERIOD=4 (original default 100000000) and MEMFILE="temp_warning_test.mem"; only this accelerated configuration is evaluated. rst is active-high and asynchronous, resetting the PC/registers/board-level display data/three flags/leds and CPU clock-divider phase to zero. Reset does not clear data RAM, reload ROM, or restart seven-segment display scanning.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-1

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-002

feature_ids: ["F-002"]

requirement_ids: ["R-BOARD-25B-002"]

stimulus: Compare on every source cycle after deassertion, covering at least 131100 source cycles and the terminal self-loop; rerun the program with different reset phases, checking the first execution edge and the complete clock division.

expected: The source clock toggles the CPU clock every 4 rising edges. The first instruction executes on the 4th rising edge after reset deassertion, and one instruction executes every 8 source cycles thereafter. ROM is 256 bytes, with uncovered locations filled with zeros; the low address of an instruction holds its low byte. The public attachment temp_warning_test.mem is the fixed upstream program, whose file bytes are assembled into 32-bit words in little endian order. The CPU executes the attached program starting at PC=0; its complete definition is the iteration of the instruction semantics below, not a 96-step output table. The terminal BEQ x0,x0,0 self-loop can run indefinitely; prediction must not end at step 96.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-2

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-003

feature_ids: ["F-003"]

requirement_ids: ["R-BOARD-25B-003"]

stimulus: Independently interpret the public ROM and maintain the registers/PC instruction by instruction; check executed true/false signed branches, return addresses, JALR, and the self-loop, observing actual results through board-level leds/displays.

expected: The fixed program executes only LUI, ADDI, BEQ, BLT, BGE, JAL, and JALR. The 32-bit registers reset to zero, and x0 is always zero; arithmetic is modulo 2^32. LUI writes the upper 20 immediate bits shifted left by 12; ADDI adds rs1 to the sign-extended 12-bit immediate; BEQ compares for equality, while BLT/BGE use 32-bit signed comparisons. A taken conditional branch sets the PC to PC plus the sign-extended B-type offset; otherwise, it becomes PC+4. JAL writes PC+4 and sets the PC to PC plus the J-type offset; JALR writes PC+4 and sets the PC to (rs1+I-type immediate)&~1. Standard RISC-V B/J immediate bit assembly applies; only these instructions reached by this fixed program constitute the software domain of this task.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-3

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-004

feature_ids: ["F-004"]

requirement_ids: ["R-BOARD-25B-004"]

stimulus: Have the interpreter generate an independent writeback/rd display, checking LUI and normal writeback as well as holding without writeback across all four scan digits; there is no mutual feedback with the actual DUT display.

expected: At each CPU rising edge, writeback is calculated using the old register inputs of the instruction executed on that edge; the 16-bit display value is updated only when RegWrite is asserted and rd is nonzero. For LUI, the display shows the low 16 bits of writeback; otherwise, it shows, in order, the decimal tens digit of rd, its ones digit, and the high and low hexadecimal nibbles of the low byte of writeback. It holds its value when there is no writeback. All displays are observable once propagation has settled after the CPU edge triggered by the source rising edge; no additional wait for the next CPU edge is required.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-4

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-005

feature_ids: ["F-005"]

requirement_ids: ["R-BOARD-25B-005"]

stimulus: Using an independent instruction history, compare LEDs before and after each CPU edge and the rd10/11/12 flag latency, checking LUI priority and terminal-state retention.

expected: When LUI executes on a CPU edge, leds is the high 16 bits of writeback. For other instructions, leds[15:6]=0; bits 5/4/3 are the old fail/bge/blt flags, respectively, and bits 2/1/0 indicate the current JALR/JAL/branch instruction classes, respectively. The branch-class bit does not indicate whether the branch is taken. When rd10/11/12 is written, the corresponding flag is updated to writeback bit 0; leds still uses the pre-update flags on that same edge, and the new flags are not displayed until the next execution edge for a non-LUI instruction. The peripheral LED register is not the direct source of this board-level leds output.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-5

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-006

feature_ids: ["F-006"]

requirement_ids: ["R-BOARD-25B-006"]

stimulus: Run continuously for at least 262150 source cycles to cover all four digit selections and wraparound; reset the CPU at arbitrary scan positions and check an continuity and display clearing.

expected: Scanning is independently driven by the source clock. The 16-bit counter initially equals 0, and the 2-bit digit selector initially equals 0. On each source rising edge, first check whether the old count is 0; if so, increment the digit selector by 1, then increment the count by 1 modulo 65536. Thus, the digit selector changes from 0 to 1 on the first source edge and advances every 65536 cycles thereafter; rst does not change the scanning phase. Digit selections 0/1/2/3 correspond to the display-value nibbles from low to high, with an equal to 1110/1101/1011/0111, respectively, all active-low.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-6

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-007

feature_ids: ["F-007"]

requirement_ids: ["R-BOARD-25B-007"]

stimulus: Compare segment codes and an edge by edge using the current scan digit and an independent display word, covering actually reachable digits such as 0/1/2/3/4/5/6/7/8/A; do not falsely claim exhaustive coverage of the unreached F.

expected: seg[6:0] is active-low. The codes for hexadecimal 0..F are, in order, 40, 79, 24, 30, 19, 12, 02, 78, 00, 10, 08, 03, 46, 21, 06, and 0e (all hexadecimal, 7-bit). seg combinationally reflects the currently selected display nibble; neither an nor seg has additional clocked-register latency. Legal program displays constrain only digits actually reached; modifying the program to reach all decoder inputs is not required.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-7

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body

## T-008

feature_ids: ["F-008"]

requirement_ids: ["R-BOARD-25B-008"]

stimulus: Run the fixed program with different random sw sequences, with independent predictions unrelated to sw; retain the same source-clock history when comparing reset restarts and scanning of all four digits.

expected: sw[15:0] is an input. CPU address bits [9:8] select data RAM when 00, the LED peripheral when 01, and the switches when 10; a switch read returns zero-extended sw. The current fixed program executes no load/store instructions, so changes to sw do not affect the observable outputs of this task. RAM and peripheral write behavior are not ISA obligations testable through the ports in this task. X/Z inputs and replacing the program are outside the domain; this task does not claim that the full ISA or the original default long clock division has been tested.

checker: The self-contained dvbench_model reads only native inputs and history, with actual and expected wired separately; the monitor samples 1ns after source rising edges and at stable inter-edge reset points, and the scoreboard compares all public outputs using four-state !==. Report UVM_ERROR on mismatches and accumulate them. There must be a nonzero number of comparison points, and the completion marker is printed only after checking that there are no ERROR/FATAL messages in the report phase.

implementation_id: V-8

source: tb.sv:dvbench_scoreboard.write;tb.sv:dvbench_sequence.body
