## T-cpu-01

feature_ids: ["F-cpu-01"]

requirement_ids: ["R-dv-082-001"]

stimulus: First use LUI/ADDI to write distinct nonzero values to all of x1 through x31 and execute several sequential instructions; assert rst_n on the falling edge and hold it across 3 rising edges, then read out all registers individually using SW after deassertion. Hold load and store instructions separately during reset, checking that memory-access decoding is not gated by reset; PC must not be asynchronously cleared between edges, and PC is 0 after the reset edge. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: One instruction executes on each rising edge of clk. A rising edge with rst_n at 0 clears PC and all general-purpose registers to zero; reset is synchronous. During reset, instruction-decoded dmem_re_o and dmem_we_o are still generated combinationally according to the current instruction and are not gated by rst_n. External memory does not commit writes on reset edges. Reset deassertion and input updates occur on the falling edge and remain stable across the next rising edge.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-02

feature_ids: ["F-cpu-02"]

requirement_ids: ["R-dv-082-002"]

stimulus: Use a no-wait external instruction source, replacing the stable instruction and corresponding aligned word data on every falling edge; read and write various addresses and byte offsets, including wraparound across the 32-bit address boundary. Driving does not depend on DUT internal state; external writes commit only on non-reset rising edges, and read data is stable before the execution edge; do not artificially insert a nonexistent ready. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: Neither the instruction nor the data interface has ready, stall, or response latency. imem_addr_o is the current 32-bit PC, and the environment provides a stable 32-bit instruction before the next execution rising edge; dmem_rdata_i is the read value of the aligned 32-bit word containing the current address. The model and DUT receive the same external input history. All arithmetic is 32-bit modular arithmetic. The legal input domain is known 0/1; exceptions, interrupts, or caches are not required.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-03

feature_ids: ["F-cpu-03"]

requirement_ids: ["R-dv-082-003"]

stimulus: Use LUI/ADDI to establish 31 distinct register values, and execute SW for each to provide observable readback; for each instruction that writes rd0, confirm that a subsequent SW of x0 still yields 0; construct rd=rs1, rd=rs2, and an immediately following instruction dependent on the previous result, comparing the new values calculated from old source values and subsequent stores. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: There are 32 32-bit general-purpose registers; x0 always reads as 0 and ignores all destination writes. Source registers are selected by instruction rs1/rs2 and read combinationally; the destination register is written on the execution rising edge, using the pre-write source values on that same edge. Sequential instructions can immediately read the preceding result, and rd may be the same as rs1/rs2. Register values can be observed through subsequent stores and instruction address transfers; no internal access port is provided.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-04

feature_ids: ["F-cpu-04"]

requirement_ids: ["R-dv-082-004"]

stimulus: Supply consecutive non-jump instructions, an all-zero unknown opcode, and random unsupported opcodes, with source registers preset to distinct values; compare cycle by cycle that PC increments by 4 and there are no memory accesses, and use subsequent SW instructions to confirm that there were no destination writes, while also checking that the default address is the sum of the two sources and wraps around at 32 bits. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: The default next PC is the current PC+4. An opcode that does not decode to any of the following categories performs no register write, memory access, or jump, and still advances sequentially. Its combinational dmem_addr_o value is rs1+rs2. There is no trap output.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-05

feature_ids: ["F-cpu-05"]

requirement_ids: ["R-dv-082-005"]

stimulus: Initialize sources to 0, 1, 0x7fffffff, 0x80000000, and 0xffffffff; execute all eight funct3 values, each with funct7=0/0x20/other aliases, using shift amounts 0/1/31/32/63, and read out the destinations through SW. Use cases that distinguish signed/unsigned behavior and overflow cases to check all operations, shifting using the low 5 bits, and 0/1 comparison results. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: For opcode 0x33, funct3 values from 0 through 7 correspond, in order, to ADD/SUB, SLL, SLT, SLTU, XOR, SRL/SRA, OR, and AND. For funct3=0, only funct7=0x20 selects SUB; otherwise ADD is selected. For funct3=5, only funct7=0x20 selects arithmetic right shift; otherwise logical right shift is selected. The shift amount is taken from the low 5 bits of rs2; SLT performs a signed comparison and SLTU performs an unsigned comparison, with a result of 0 or 1. Other funct7 values do not cause exceptions.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-06

feature_ids: ["F-cpu-06"]

requirement_ids: ["R-dv-082-006"]

stimulus: Initialize sources to the positive and negative boundary values above, enumerate all eight immediate-arithmetic funct3 values, with immediates 0/1/-1/-2048/2047, shifts 0/1/31, and right-shift funct7=0/0x20/other; then observe the results through SW, checking that SLTIU performs an unsigned comparison after sign extension. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: For opcode 0x13, sign-extend bits31:20 as a 12-bit immediate. The funct3 values correspond, in order, to ADDI, SLLI, SLTI, SLTIU, XORI, SRLI/SRAI, ORI, and ANDI. The shift amount uses only the low 5 bits of the immediate; in the right-shift category, only funct7=0x20 is arithmetic, otherwise it is logical. SLTIU compares the sign-extended 32-bit immediate and the unsigned value of rs1.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-07

feature_ids: ["F-cpu-07"]

requirement_ids: ["R-dv-082-007"]

stimulus: Execute LUI/AUIPC from a nonzero PC with high bits set, using 0/1/0x80000/0xfffff for the high 20 bits of the immediate; include rd0 and self-dependencies, then read out through SW and compare against independent old-PC addition and the upper immediate. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: LUI opcode0x37 writes bits31:12 shifted left by 12 bits; AUIPC opcode0x17 writes the current PC plus the same upper immediate. Both may write any rd and obey the x0 rule.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-08

feature_ids: ["F-cpu-08"]

requirement_ids: ["R-dv-082-008"]

stimulus: Establish pre-branch states using equal and unequal register values and positive and negative register values whose signed and unsigned orderings are opposite; produce both taken and not-taken outcomes for each funct3=0/1/4/5/6/7, with 2/3 not branching, positive and negative offsets, near-extreme values, and PC wraparound; observe the next PC, the absence of destination writes/memory accesses, and the combinational subtraction address. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: For opcode0x63, the B immediate is sign-extended from {bit31,bit7,bits30:25,bits11:8,0}. funct3=0/1/4/5/6/7 correspond, in order, to BEQ, BNE, BLT, BGE, BLTU, and BGEU; if the relation is satisfied, next PC=current PC+offset, otherwise +4. funct3=2/3 do not branch. Branches do not write registers or access memory; combinational dmem_addr_o still provides rs1-rs2.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-09

feature_ids: ["F-cpu-09"]

requirement_ids: ["R-dv-082-009"]

stimulus: Execute JAL from a nonzero PC with positive and negative near and far offsets, and observe the link register through SW; execute JALR with odd and even sources and bit1=1, positive and negative immediates, all funct3 values, rd0, and rd equal to the source; compare the target with only bit0 cleared, the old PC+4 link, and the pre-edge address before bit clearing. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: The J immediate for JAL opcode0x6f is sign-extended from {bit31,bits19:12,bit20,bits30:21,0}, and next PC=current PC+offset; for JALR opcode0x67, next PC=(rs1+sign-extended I immediate)&0xfffffffe, with all funct3 values interpreted this way. Both write old PC+4 to rd, allowing rd to equal the source register; bit1 is not forcibly cleared. dmem_addr_o is the JAL target addition result and the JALR addition result before clearing bit0, respectively.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-10

feature_ids: ["F-cpu-10"]

requirement_ids: ["R-dv-082-010"]

stimulus: Preset x1 to an address base value; exercise all 8 load funct3 values individually with offset0/1/2/3 and positive and negative offsets, using input words 0x800080ff/0xff7f0080/0x8001ffff; immediately follow each load with SW of the load destination register, comparing LB/LH sign extension, LBU/LHU zero extension, halfword behavior that ignores bit0, and full-word behavior for reserved funct3 values, including rd0 and base-value self-dependencies. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: opcode0x03 asserts dmem_re_o high, with dmem_we_o at 0 and address=rs1+sign-extended I immediate. funct3=0/4 are LB/LBU, selecting a byte within the word according to the low 2 address bits and sign-/zero-extending it; 1/5 are LH/LHU, selecting the low/high halfword using only address bit1, ignoring bit0, and sign-/zero-extending it; 2 and other reserved funct3 values are full-word LW. The result is written to rd on the execution rising edge.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-11

feature_ids: ["F-cpu-11"]

requirement_ids: ["R-dv-082-011"]

stimulus: Preset sources to 0x89abcdef and different base addresses; drive all store funct3 values and offset0/1/2/3, and positive and negative S immediates, individually; compare the native address, SB/SH zero-filled shifted wdata and be, and full-word behavior for SW and reserved funct3 values; on non-store edges, check wdata=rs2 and be1111. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: opcode0x23 asserts dmem_we_o high, with dmem_re_o at 0; the S immediate is formed by concatenating bits31:25 and 11:7 and sign-extending. Address=rs1+immediate. funct3=0 is SB: the low 8 bits of rs2 are shifted to the byte selected by the low 2 address bits, other wdata bits are 0, and be is the corresponding single bit; funct3=1 is SH: only address bit1 selects the low/high halfword, the low 16 bits of rs2 are shifted to that halfword, other bits are 0, and be is 0011 or 1100; 2 and other reserved funct3 values are SW, with wdata=rs2 and be=1111.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.

## T-cpu-12

feature_ids: ["F-cpu-12"]

requirement_ids: ["R-dv-082-012"]

stimulus: Alternate driving all instruction categories and change the source instruction/external data on the falling edge; compare all outputs separately in the pre-edge stable window and 1ns after every rising edge, covering combinational recomputation after state changes as well as non-memory-access addresses and non-store data/be. Do not compare unknown states before the initial synchronous reset; report errors for any X/Z in valid windows. Drive known inputs on the falling edge and hold them across the execution rising edge; sample stable combinational values before the edge, and wait 1ns after the rising edge for NBA and combinational propagation to complete before sampling again. Check synchronous reset across a rising edge; do not compare unknown states before the initial reset.

expected: dmem_addr_o is always the arithmetic result of the current operation: the arithmetic result for R/I, the upper immediate for LUI, PC plus the upper immediate for AUIPC, rs1-rs2 for branches, as described above for jumps, and rs1+rs2 for others. For non-store operations, dmem_wdata_o=rs2, dmem_be_o=1111. All native outputs are observable before the edge with stable inputs and in the post-edge combinationally stable window; states are unknown before the initial synchronous reset and are not compared. Inputs update on the falling edge; wait at least 1ns after the edge before sampling.

checker: An independent ISA interpreter based on input history maintains 32 registers and PC, calculating expected values from inputs and old state; the monitor reads native outputs, and the scoreboard performs per-signal four-state comparisons, reporting UVM_ERROR for X/Z or mismatches. Expected values must not be filled in from actual outputs, and internal registers must not be read; count comparisons and report missing comparisons as errors as well.

implementation_id: cpu_reference_sequence

source: tb.sv; independent model/model.sv. The semantic plan includes the full domain; see the maintained execution records separately for whether the current HDL covers every scenario.
