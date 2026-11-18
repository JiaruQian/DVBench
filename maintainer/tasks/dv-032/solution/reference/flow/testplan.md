# testplan

## T1

test_id: T1

feature_ids: ["F1"]

requirement_ids: ["R-dv-032-jtag-apb-debug-001"]

stimulus: Drive all ports on the falling edges of the two domains, and continuously compare constant-0 outputs and responses during directed, concurrent, and random phases.

expected: The top-level adbg_jsp_apb_module has no parameters, and data_register_i is fixed at 64 bits. Only two-state inputs and legal APB two-phase accesses are defined. The PCLK period is 6ns and the tck_i period is 10ns; drive inputs on the falling edges of their respective domains and sample after stabilization; the two domains run independently and may have simultaneous rising edges, with state updates using pre-edge inputs. PSLVERR and top_inhibit_o are constantly 0.

checker: jsp_native_checker.check_apb compares PRDATA/PREADY/PSLVERR/int_o/top_inhibit_o at PCLK falling edge +0.2ns, skipping data for predicted empty RBR. check_tdo independently bounds valid bits using the predicted header and compares actual/expected, reporting UVM_ERROR on mismatches; check_phase requires at least 100 APB and 64 TDO checks to prevent vacuity. dvbench_model receives only native inputs and history; the source transaction-SB is only a diagnostic and coverage ledger.

implementation_id: jsp_native_checker.check_apb/check_tdo

source: tb/jsp_apb_pkg.sv

## T2

test_id: T2

feature_ids: ["F2"]

requirement_ids: ["R-dv-032-jtag-apb-debug-002"]

stimulus: After establishing nonempty queues in both directions, apply pulse_rst_jtag and pulse_presetn separately, and check clearing/retention, the first scan byte, and recovery.

expected: rst_i is asynchronous active-high and clears both FIFOs, JTAG scan state, serial output, and inter-domain event history, but does not clear IER/LCR/SCR. PRESETn is asynchronous active-low and clears IER/LCR/SCR, the THR interrupt armed state, APB operation scheduling, and the data holding byte for scanning, but does not clear the FIFOs or JTAG scan. After PRESETn is released, if APB-to-JTAG data existed previously, the first data byte of the first scan may be the post-reset 0; after it is consumed, subsequent queue-head data is restored. The registered PREADY response is defined only after the first PCLK rising edge; assert both resets first at power-up.

checker: jsp_native_checker.check_apb compares PRDATA/PREADY/PSLVERR/int_o/top_inhibit_o at PCLK falling edge +0.2ns, skipping data for predicted empty RBR. check_tdo independently bounds valid bits using the predicted header and compares actual/expected, reporting UVM_ERROR on mismatches; check_phase requires at least 100 APB and 64 TDO checks to prevent vacuity. dvbench_model receives only native inputs and history; the source transaction-SB is only a diagnostic and coverage ledger.

implementation_id: jsp_native_checker.check_apb/check_tdo

source: tb/jsp_apb_pkg.sv

## T3

test_id: T3

feature_ids: ["F3"]

requirement_ids: ["R-dv-032-jtag-apb-debug-003"]

stimulus: Access all addresses using APB two-phase accesses, interleaving FIFO and register operations; hold setup/access data, and check PREADY and pre-edge read values.

expected: The address is 3 bits and data is 8 bits. PSEL=1/PENABLE=0 is setup; in access on the next cycle, hold selection, address, direction, and write data until PREADY. FIFO actions at address 0 with LCR[7]=0 are initiated by setup: after setup is accepted on a PCLK rising edge, the response is visible after that edge; the actual push/pop executes on the immediately following PCLK rising edge (the access completion edge). Writes enter the APB-to-JTAG queue, and reads consume the JTAG-to-APB queue. Other addresses, or address 0 with LCR[7]=1, respond one cycle after setup. PRDATA combinationally follows PADDR and the current state and is not gated by PSEL/PENABLE; RBR reads the byte being consumed before the completion edge, and the read value of an empty FIFO is undefined.

checker: jsp_native_checker.check_apb compares PRDATA/PREADY/PSLVERR/int_o/top_inhibit_o at PCLK falling edge +0.2ns, skipping data for predicted empty RBR. check_tdo independently bounds valid bits using the predicted header and compares actual/expected, reporting UVM_ERROR on mismatches; check_phase requires at least 100 APB and 64 TDO checks to prevent vacuity. dvbench_model receives only native inputs and history; the source transaction-SB is only a diagnostic and coverage ledger.

implementation_id: jsp_native_checker.check_apb/check_tdo

source: tb/jsp_apb_pkg.sv

## T4

test_id: T4

feature_ids: ["F4"]

requirement_ids: ["R-dv-032-jtag-apb-debug-004"]

stimulus: Write IER/LCR/SCR with 00/ff/a5, access IER/THR/RBR respectively with DLAB0/1; read/write MCR/MSR to verify constants and ignored writes.

expected: Address 1 is the low 4 bits of IER, with the upper 4 bits reading as 0; IER writes are accepted only when LCR[7]=0; address 3 is the 8-bit LCR; address 7 is the 8-bit SCR; all are written on the access rising edge. Address 4 MCR is constantly 0 and address 6 MSR is constantly 0b; writes are ignored. Address 2 reads IIR and writes FCR. LCR[7] only disables FIFO operations and IER writes and does not provide DLL/DLM divisor registers; IER reads still return IER, and address 0 reads still combinationally display RBR.

checker: jsp_native_checker.check_apb compares PRDATA/PREADY/PSLVERR/int_o/top_inhibit_o at PCLK falling edge +0.2ns, skipping data for predicted empty RBR. check_tdo independently bounds valid bits using the predicted header and compares actual/expected, reporting UVM_ERROR on mismatches; check_phase requires at least 100 APB and 64 TDO checks to prevent vacuity. dvbench_model receives only native inputs and history; the source transaction-SB is only a diagnostic and coverage ledger.

implementation_id: jsp_native_checker.check_apb/check_tdo

source: tb/jsp_apb_pkg.sv

## T5

test_id: T5

feature_ids: ["F5"]

requirement_ids: ["R-dv-032-jtag-apb-debug-005"]

stimulus: Fill both directions to 8, then push and drain, covering empty/near-full; use FCR bit1/bit2 separately and clear both to check the remaining direction.

expected: Each of the two FIFOs holds 8 8-bit bytes, first in, first out. JTAG writes supply APB RBR reads, and APB THR writes supply JTAG shifting out; when full, a new push is discarded and old bytes are retained; an empty pop causes no change. An access write to FCR address 2 with bit1=1 asynchronously clears the JTAG-to-APB queue, and bit2=1 asynchronously clears the APB-to-JTAG queue; both may be set simultaneously; other registers, armed, and the scan count are not cleared. FCR is not stored, and its read value is defined by IIR.

checker: jsp_native_checker.check_apb compares PRDATA/PREADY/PSLVERR/int_o/top_inhibit_o at PCLK falling edge +0.2ns, skipping data for predicted empty RBR. check_tdo independently bounds valid bits using the predicted header and compares actual/expected, reporting UVM_ERROR on mismatches; check_phase requires at least 100 APB and 64 TDO checks to prevent vacuity. dvbench_model receives only native inputs and history; the source transaction-SB is only a diagnostic and coverage ledger.

implementation_id: jsp_native_checker.check_apb/check_tdo

source: tb/jsp_apb_pkg.sv

## T6

test_id: T6

feature_ids: ["F6"]

requirement_ids: ["R-dv-032-jtag-apb-debug-006"]

stimulus: selected0/1 with capture, count0/1/7/15, full 64bit and aborts at 4/8/12bit; shift different bytes LSB first, pause and then resume.

expected: A scan starts on a tck_i rising edge when module_select_i and capture_dr_i are both 1; only one of them being asserted does not start a scan. The first output byte is {number of bytes available to shift out,number of free slots available to receive}, with the high and low nibbles each ranging from 0 to 8, and each byte is output LSB first. The high nibble of the first input byte is the number the user wishes to send; subsequent input bytes are formed at complete-byte boundaries from {tdi_i,data_register_i[63:57]}; externally, each shift rising edge shifts data_register_i right and places tdi_i in bit63. The bit count advances only when shift_dr_i=1; update_dr_i terminates the scan, and fully input bytes are retained. At most the smaller of the free-slot count at capture and the user-declared count is received; excess complete bytes are ignored. The number of valid output bytes is bounded by the high nibble of the header, and excess TDO has no valid-data obligation; TDO within the header and valid payload is stable before the corresponding shift rising edge.

checker: jsp_native_checker.check_apb compares PRDATA/PREADY/PSLVERR/int_o/top_inhibit_o at PCLK falling edge +0.2ns, skipping data for predicted empty RBR. check_tdo independently bounds valid bits using the predicted header and compares actual/expected, reporting UVM_ERROR on mismatches; check_phase requires at least 100 APB and 64 TDO checks to prevent vacuity. dvbench_model receives only native inputs and history; the source transaction-SB is only a diagnostic and coverage ledger.

implementation_id: jsp_native_checker.check_apb/check_tdo

source: tb/jsp_apb_pkg.sv

## T7

test_id: T7

feature_ids: ["F7"]

requirement_ids: ["R-dv-032-jtag-apb-debug-007"]

stimulus: Run back-to-back scans and concurrent APB operations, recording history without artificially waiting for convergence; predict stale headers and event delays, and check the final state after settling.

expected: JTAG complete-byte commits and output-byte consumption are sent as events to the PCLK domain; events appear after two PCLK synchronization rising edges, then pass through one scheduling edge and one execution edge in sequence to change the queues; the JTAG boundary and the FIFO change must not be treated as occurring at the same instant. Byte events are separated by at least 8 tck_i cycles. FIFO counts are updated toward JTAG through request/ack snapshot round trips: when counts change and the previous snapshot has been acknowledged, latch and issue a request; after two tck_i synchronization edges, the request is loaded on the next edge; only after the acknowledgment returns through two PCLK synchronization edges may the next snapshot be latched. Multiple intermediate changes may be merged. capture uses the already-visible snapshot, and the header may be stale during concurrency. After rst_i is released, a tck_i edge must occur first, followed by two PCLK synchronization edges before the link is ready; before that, LSR[6:5]=0.

checker: jsp_native_checker.check_apb compares PRDATA/PREADY/PSLVERR/int_o/top_inhibit_o at PCLK falling edge +0.2ns, skipping data for predicted empty RBR. check_tdo independently bounds valid bits using the predicted header and compares actual/expected, reporting UVM_ERROR on mismatches; check_phase requires at least 100 APB and 64 TDO checks to prevent vacuity. dvbench_model receives only native inputs and history; the source transaction-SB is only a diagnostic and coverage ledger.

implementation_id: jsp_native_checker.check_apb/check_tdo

source: tb/jsp_apb_pkg.sv

## T8

test_id: T8

feature_ids: ["F8"]

requirement_ids: ["R-dv-032-jtag-apb-debug-008"]

stimulus: Generate IIR01/02/04 and priorities, toggle IER, clear armed on IIR reads, and set armed on THR writes and the last pop.

expected: LSR address 5 bit0 indicates that the JTAG-to-APB FIFO is nonempty; bit5/6 both indicate that the link is ready and APB-to-JTAG is not full; other bits are 0, and they do not indicate UART transmit busy. IIR gives priority to 04 (JTAG-to-APB nonempty), otherwise 02 when armed and APB-to-JTAG is not full and ready, otherwise 01; IIR is not masked by IER. A THR setup write or consumption of the last APB-to-JTAG byte sets armed; an access read of IIR when JTAG-to-APB is empty clears armed, with setting taking priority.

checker: jsp_native_checker.check_apb compares PRDATA/PREADY/PSLVERR/int_o/top_inhibit_o at PCLK falling edge +0.2ns, skipping data for predicted empty RBR. check_tdo independently bounds valid bits using the predicted header and compares actual/expected, reporting UVM_ERROR on mismatches; check_phase requires at least 100 APB and 64 TDO checks to prevent vacuity. dvbench_model receives only native inputs and history; the source transaction-SB is only a diagnostic and coverage ledger.

implementation_id: jsp_native_checker.check_apb/check_tdo

source: tb/jsp_apb_pkg.sv

## T9

test_id: T9

feature_ids: ["F9"]

requirement_ids: ["R-dv-032-jtag-apb-debug-009"]

stimulus: Compare against an independent model after PCLK/TCK falling edges throughout; only predicted empty RBR and TDO beyond the header count have no data obligation; continuously compare everything else.

expected: int_o is (IER[1] and armed and APB-to-JTAG not full and link ready) or (IER[0] and JTAG-to-APB nonempty), combinationally reflecting the state. PRDATA at register addresses can be compared after combinational stabilization; address 0 has a data obligation only when the queue is nonempty. TDO has a data obligation only for the selected scan header and payload within its declared count; pausing holds the shift position, and residual values after update are not treated as new data. PREADY, int_o, and the two constant-0 outputs can always be compared within their defined windows.

checker: jsp_native_checker.check_apb compares PRDATA/PREADY/PSLVERR/int_o/top_inhibit_o at PCLK falling edge +0.2ns, skipping data for predicted empty RBR. check_tdo independently bounds valid bits using the predicted header and compares actual/expected, reporting UVM_ERROR on mismatches; check_phase requires at least 100 APB and 64 TDO checks to prevent vacuity. dvbench_model receives only native inputs and history; the source transaction-SB is only a diagnostic and coverage ledger.

implementation_id: jsp_native_checker.check_apb/check_tdo

source: tb/jsp_apb_pkg.sv
