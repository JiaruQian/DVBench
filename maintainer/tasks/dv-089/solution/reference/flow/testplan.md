# testplan

## T-1

feature_ids: ["F-1"]

requirement_ids: ["R-dv-089-001"]

stimulus: First set rst_i=1 between edges, hold it across 3 rising edges, then release it on a falling edge; also insert short pulses that do not span a rising edge and resets that span an edge during operation. Apply edge-spanning resets separately at power-up, during fetch waits, during data waits, and while halted; short pulses occur only between two rising edges.

expected: The input-history model accepts reset only on rising edges, expecting the next fetch address to be 0, no pending responses, and halt/trace cleared; short pulses do not clear existing state.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-1

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-2

feature_ids: ["F-2"]

requirement_ids: ["R-dv-089-002"]

stimulus: Start from reset address 0 and use an external program image to maintain the address of each accepted request. Alternate ready between 0 and 1, delay responses by 1 to 6 cycles, hold responses until ready, and continuously execute ordinary instructions with different encodings.

expected: An independent transaction scheduler calculates request addresses, waiting/buffering, and advancement times; compare valid/ready cycle by cycle, compare addresses at handshakes, and check for duplicate acceptance or lost instructions.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-2

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-3

feature_ids: ["F-3"]

requirement_ids: ["R-dv-089-003"]

stimulus: Use legal immediates and LUI to establish zero, positive, negative, most-significant-bit, and all-ones patterns; subsequent STORE instructions output arithmetic results onto the native data bus. Execute all 15 R-type instructions, 7 I-type instructions, and LUI, covering shifts by 0/15/16/31, 32-bit overflow, equality/inequality, signed and unsigned ordering, writes to r0, and reads from r0.

expected: An independent integer arithmetic interpreter calculates the register image and subsequent STORE data, checking the PC and original instruction for each retire; it does not read internal registers.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-3

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-4

feature_ids: ["F-4"]

requirement_ids: ["R-dv-089-004"]

stimulus: Initialize the external data memory image with patterns such as 80FF807F and FEDCBA98, with base address 4096 established by the program. Cover five load types, three store widths, byte offsets 0..3, legal halfword offsets 0/2, negative offsets, overwriting and readback, and immediate use after a load.

expected: An independent byte array calculates addresses, strobes, write data, and extended values; observe load results externally through STORE instructions following loads, and compare all valid data requests.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-4

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-5

feature_ids: ["F-5"]

requirement_ids: ["R-dv-089-005"]

stimulus: The program executes LOAD followed by immediately dependent ALU and STORE instructions, and also executes dependent instructions after CSR instructions; externally delay data responses. Cover request backpressure of 1 to 5 cycles, response delays of 1 to 10 cycles, dependencies on rs1 and rs2, nondependent instructions, and same-cycle response/subsequent advancement.

expected: The independent interpreter updates the architectural image on completion events, then schedules dependent execution; compare complete request payloads and retire times, without substituting coverage hits for checking.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-5

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-6

feature_ids: ["F-6"]

requirement_ids: ["R-dv-089-006"]

stimulus: Establish equal, positive/negative, and reverse-ordered unsigned operands, place identifiable side effects at skipped locations, and output link values through STORE. Cover all six branch types taken/not taken, positive and negative offsets, J/JAL/JR/JALR, link rd boundaries, and aligned and unaligned jump targets.

expected: An independent ISA interpreter calculates the next PC, link values, and exceptions; compare fetch addresses, retirement sequences, and valid STORE operations, confirming that flushed instructions have no side effects.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-6

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-7

feature_ids: ["F-7"]

requirement_ids: ["R-dv-089-007"]

stimulus: Keep a delayed fetch response pending before a branch, HALT, or exception so that it spans a redirect. Redirect both before the response arrives and in the same cycle as its arrival, while the external peer still returns the old response normally; place a different program at the target.

expected: Request generation tags from input history determine response validity and independently predict the commit sequence; confirm cycle by cycle that no stale instruction produces retire/STORE.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-7

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-8

feature_ids: ["F-8"]

requirement_ids: ["R-dv-089-008"]

stimulus: First set tvec, then use a legal peer to return illegal encodings, fetch errors, and unaligned operations separately. Cover individual errors and combinations of fetch error with legal unaligned/trap encodings; cover different low address bits for byte/halfword/word accesses.

expected: The interpreter calculates priority and cause/badaddr/EPC from input encodings/error bits, compares trap cycle by cycle, and confirms that the instruction produces no retire/data side effects.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-8

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-9

feature_ids: ["F-9"]

requirement_ids: ["R-dv-089-009"]

stimulus: Issue LOAD or STORE at a legal aligned address, with handshakes recorded externally. Return error for reads and writes separately, covering delayed errors after backpressure and alternating normal/error responses.

expected: At the actual response acceptance edge, compare cause5/7, the original address, absence of retire, and redirection; the subsequent program confirms through STORE that no erroneous load writeback occurred.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-9

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-10

feature_ids: ["F-10"]

requirement_ids: ["R-dv-089-010"]

stimulus: Establish a known CSR/counter image from reset, configure through CSRW, and read out using CSRR+STORE. Cover all 11 read addresses, 4 write addresses, illegal reads and writes, unaligned EPC/tvec inputs, differences between cycle and instret, and r0 as the destination register.

expected: The independent image accumulates on each cycle and on successful completion; compare externally exposed STORE data and illegal-access exceptions, without reading internal CSRs.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-10

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-11

feature_ids: ["F-11"]

requirement_ids: ["R-dv-089-011"]

stimulus: Set tvec; the handler reads EPC/cause/status through CSRR and performs STORE, then modifies EPC and uses MRET to reach the specified continuation address. Cover EBREAK, TRAP with different immediates, combinations of software traps and IE, MRET round trips, EI/DI, and CSR writes.

expected: An independent state stack calculates EPC/IE/MPIE, targets, and counters; check that traps do not retire, that MRET retires, and that the restored address is correct.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-11

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

## T-12

feature_ids: ["F-12"]

requirement_ids: ["R-dv-089-012"]

stimulus: Configure tvec and the handler, execute HALT with IE=0/1 respectively, and also inject IRQ during ordinary/system instructions and data waits. Cover timer, external, both simultaneously, wakeup from halt, remaining halted without enable, interrupts in the same cycle as retire, and synchronous trap/MRET/HALT priority.

expected: Independent transaction history determines the oldest unexecuted PC and the state stack; compare trap/cause, whether halted, the fetch target, and concurrency with retire; the handler reads back EPC through CSR.

checker: Record inputs and acceptance conditions before the rising edge, sample all valid native outputs using four-state logic 1ns after the edge, and compare them against an independent model generated solely from input history; report UVM_ERROR on any mismatch. The asynchronous inter-edge short-pulse test also observes state retention during the pulse and before the next edge; activity counts prevent vacuity.

implementation_id: V-12

source: cpu_reference_pkg.sv:native_monitor/native_scoreboard; model/model.sv:dvbench_model

