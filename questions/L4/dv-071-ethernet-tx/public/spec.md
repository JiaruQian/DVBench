> Derived from the implementation; the original design intent has not been proven.

# IEEE802TX (Ethernet MAC Transmitter) Module Specification (Derived from the Implementation)

> This specification is reverse-derived from the RTL implementation and describes only the behavior of the current implementation; it does not establish the original design intent. For unresolved matters, see Section 8, “Issues and Revision Locations.”

### R-ETH-001 — Role and Boundaries

IEEE802TX is an Ethernet frame transmitter located between the client MAC and PHY/GMII. It reads frame payload byte by byte from an external FIFO, sequentially generates the preamble (Preamble), start frame delimiter (SFD), 12-byte destination/source MAC header, payload data, and 32-bit frame check sequence (FCS) according to the IEEE 802.3 frame format, and outputs them through the GMII transmit interface.

The module internally maintains a 7-state transmit state machine, outputs the current state through `diagnostic`, and indicates transmit idle through `complete`. FCS calculation is delegated to submodule `CRC_gen` (instance `CRC_gen_inst`).

The module is **not responsible for**: FIFO storage and full/empty management (`iEmpty`/`i8Data` are provided externally); PHY encoding beyond GMII; collision/carrier detection (`gmii_tx_er` is always 0, and no transmit error indication is generated); MAC header configuration (destination/source addresses are hard-coded constants). The input does not provide an MTU/maximum frame length convention; see I4.



### R-ETH-002 — Interface Contract

The top level has a total of 12 ports:

| Port | Direction | Bit Width | Purpose |
|------|------|------|------|
| Reset | input | 1 | Synchronous active-high reset |
| Clk | input | 1 | Main clock |
| clk_en | input | 1 | Clock enable |
| iEmpty | input | 1 | External FIFO empty flag |
| i8Data | input | 16 | External FIFO data word |
| oRead | output | 1 | FIFO read request |
| Addres | output | 9 | FIFO read address |
| gmii_txd | output | 8 | GMII transmit data |
| gmii_tx_en | output | 1 | GMII transmit enable |
| gmii_tx_er | output | 1 | GMII transmit error |
| complete | output | 1 | Transmit idle indication |
| diagnostic | output | 3 | State indication |

(Clock/reset) The rising edge of `Clk` is the main clock edge for all sequential logic; `Reset` is a **synchronous active-high** reset, sampled on the rising edge of `Clk`, and clears the sequential registers during reset. `clk_en` is an active-high clock enable that gates almost all `posedge Clk` logic except `clkDiv`; when `clk_en=0`, the state machine and data registers hold their values.

(FIFO side) `iEmpty` indicates that the external FIFO is empty and is active-high; `i8Data[15:0]` is the 16-bit data word output by the FIFO; `oRead` is the read request; `Addres[8:0]` is the read address.

Key fact: `oRead` is implemented as `~clkDiv[0]`, while `clkDiv` increments on the falling edge of `Clk`, so `oRead` is a **free-running half-rate clock** (toggling once per `Clk` cycle), not gated by `state` or `iEmpty`. This differs from the port comment “read request” and from the read enable `wReadFifo = rReadFifo & ~iEmpty` actually used internally by the module to check for empty; see I1.

`Addres = r11DataCounter[9:1]`, that is, the data counter shifted right by one bit; the read address changes with the counter once every two cycles.

(GMII side) `gmii_txd[7:0]`, `gmii_tx_en`, and `gmii_tx_er` are GMII transmit data, transmit enable, and transmit error. `gmii_txd`/`gmii_tx_en` are **one-cycle-delayed** versions of internal `FCS_data`/`tx_en`; `gmii_tx_er` is always 0.

(State indication) `diagnostic[2:0] = diag`, and `diag` takes values 0..6 according to the state; `complete` is a combinational signal and is 1 only when `StateIdle`.

### R-ETH-003 — Normal Operation (State Machine and Transmission Flow)

State encodings (4 bits): `StateIdle=0`, `StatePreamble=1`, `StateSFD=2`, `StateHeader=3`, `StateData=4`, `StateFCS=5`, `StateIFG=6`. `state` is updated to the combinationally calculated `next_state` when `posedge Clk` and `clk_en`; `next_state`, `diag`, and `complete` are generated combinationally in `always @(*)` according to the current `state`.

- **Idle**: `complete=1`, `diag=0`. When `~iEmpty` (FIFO nonempty), the next state is Preamble; otherwise, remain in this state.
- **Preamble**: `diag=1`, `complete=0`. Transmit 7 bytes of 0x55. Counter `r4CntrPreamble` increments from 0; when `wFinishPreamble=(r4CntrPreamble==6)`, it is cleared to zero and the state transitions to SFD.
- **SFD**: `diag=2`. Transmit 1 byte of 0xd5, and unconditionally transition to Header; within the same state, `FCS_init=1` resets the CRC register.
- **Header**: `diag=3`. Transmit a 12-byte MAC header. Counter `r4CntrHeader` increments from 0 to 11; when `wFinishHeader=(r4CntrHeader==11)`, it is cleared to zero and the state transitions to Data. The bytes actually transmitted are determined by the `case(r4CntrHeader)` of `FCS_data` (see I2).
- **Data**: `diag=4`. Transmit the FIFO payload byte by byte; counter `r11DataCounter` increments every cycle. When `~wReadFifo | wFinishData`, transition to FCS, where `wReadFifo=rReadFifo&~iEmpty`, `wFinishData=iEmpty | (r11DataCounter==1023)`.
- **FCS**: `diag=5`. In the first cycle upon entering FCS, `FCS_read` has not yet taken effect (`CRC_rd=0`); in cycles 2–5, `FCS_read=1` causes the CRC submodule to output a 4-byte checksum over 4 cycles; `FCS_end` (`Counter==3`) is asserted in cycle 5 and the state transitions to IFG, so the FCS state lasts a total of 5 cycles (see Section 5 for details).
- **IFG**: `diag=6`. `r6IFG_counter` increments during IFG; when the count reaches 12, transition to Idle (a total interval of 13 cycles).

Transmit-byte generation and the CRC input share `FCS_data`: Preamble selects 0x55, SFD selects 0xd5, Header selects the constant table, and Data selects the high/low byte of `i8Data`; `FCS_data_en` is asserted in Header/Data to feed bytes to the CRC; `FCS_init` is asserted in SFD. `tx_en` is 1 in Preamble/SFD/Header/Data, and 0 otherwise.

Header field constant table (`case(r4CntrHeader)`): 6→0x12, 7→0x34, 8→0x56, 9→0x78, 10→0x9A, 11→0xBC, 0→0xC8, 1→0x60, 2→0x00, 3→0x98, 4→0xCC, 5→0xBE. Since the counter starts at 0 and transmits sequentially, the 12-byte sequence actually transmitted is `C8 60 00 98 CC BE 12 34 56 78 9A BC`; see I2.

### R-ETH-004 — Datapath and Address

(16→8 serialization) In `StateData`, `FCS_data = (r11DataCounter[0]==1'b1) ? i8Data[7:0] : i8Data[15:8]`, that is, select the high byte when the counter is even and the low byte when it is odd, splitting the 16-bit word into two bytes in big-endian order.

`Addres = r11DataCounter[9:1]`, with the address equal to the counter divided by 2 using integer division. The counter is 11 bits wide, and the termination check uses 1023, so the address range is 0..511. `r11DataCounter` increases by 1 every cycle in Data and is cleared to zero when `wFinishData`; it is cleared to zero on reset. In addition, in states other than `StateData`, this counter is cleared to zero by default every cycle, so outside Data, `r11DataCounter` is always 0 and `Addres` is always 0.

The expressions for `wFinishData` and `wFinishDataFifo` are exactly the same (`iEmpty | (r11DataCounter==11'd1023)`); the latter is a redundant condition; see I3.

(Internal read enable) Assignment priority for `rReadFifo`: default `~iEmpty & (r4CntrHeader==10)`; if `wFinishData` (or `wFinishDataFifo`), clear 0; otherwise, when `state==StateHeader & r4CntrHeader==11`, set `~iEmpty`; otherwise, when `state==StateData`, set `~iEmpty`. The actual read enable `wReadFifo=rReadFifo & ~iEmpty` is used only in the StateData→FCS transition decision and does **not** drive the `oRead` output.

(Output registers) `delayed_FCS_data`/`delayed_tx_en` register `FCS_data`/`tx_en` under `clk_en`; when `dstate==StateFCS & state==StateFCS`, they instead register `FCS_out` and `delayed_tx_en=1`. Thus, the GMII output lags the internal byte by one cycle. `dstate` is `state` delayed by one cycle (also updated under `clk_en`).

### R-ETH-005 — FCS/CRC Submodule (CRC_gen)

`CRC_gen` is a 32-bit CRC updated byte by byte (Ethernet FCS):

- On reset or when `Init & Ce`, `CRC_reg <= 32'hffffffff`.
- When `Data_en & Ce`, `CRC_reg <= NextCRC(Frame_data, CRC_reg)`, where `NextCRC` is a bitwise combinational polynomial.
- When `CRC_rd & Ce`, `CRC_reg <= {CRC_reg[23:0], 8'hff}`, shifting left by 8 bits and filling with 0xff every cycle.
- `CRC_out` is combinational logic: when `CRC_rd & Ce`, it outputs `~{CRC_reg[24],…,CRC_reg[31]}` (the high 8 bits bitwise inverted), and otherwise 0; only the high 8 bits are taken, with a left shift each cycle, outputting 4 bytes over the 4 cycles during which `CRC_rd` is high.
- `Counter` is cleared to zero when `!CRC_rd` and increments when `CRC_rd & Ce`, `CRC_end=(Counter==3)`. In the first cycle upon entering FCS, `FCS_read` is still 0 (this register is set to 1 on the next rising edge when `state==StateFCS`, ), so `CRC_rd` is high for 4 consecutive cycles starting at cycle 2, `Counter` takes the values 0/1/2/3 in sequence, and `CRC_end` is set in cycle 5 and the state transitions to IFG: **the FCS state lasts 5 cycles**. “4 cycles” in the comment for `CRC_gen` refers only to the number of cycles during which `CRC_rd` is high, not the number of cycles in the FCS state.

Top-level instance connections: `.Ce(clk_en)`, `.Init(FCS_init)`, `.Frame_data(FCS_data)`, `.Data_en(FCS_data_en)`, `.CRC_rd(FCS_read)`, `.CRC_end(FCS_end)`, `.CRC_out(FCS_out)`. `delayed_FCS_data` latches `CRC_out` in sequence on the rising edges of the 4 cycles of `dstate==StateFCS & state==StateFCS` (FCS cycles 2–5), so the 4 checksum bytes appear in sequence on `gmii_txd` in FCS cycles 3–5 and the immediately following IFG cycle 1.

### R-ETH-006 — State and Resource Boundaries

This module has no internal storage array; its “resources” consist of counters and pipeline registers: preamble counter `r4CntrPreamble` (4 bits), header counter `r4CntrHeader` (4 bits), data counter `r11DataCounter` (11 bits), IFG counter `r6IFG_counter` (6 bits), 32-bit CRC register `CRC_reg`, and output delay registers `delayed_FCS_data`/`delayed_tx_en`/`dstate`. All counters and registers are cleared to zero at `Reset`; `r11DataCounter` is cleared to zero when `wFinishData` and is cleared to zero by default every cycle in states other than `StateData` (, so between frames `Addres` is always 0); `r6IFG_counter` is cleared to zero when leaving IFG.

The upper limit on data length is determined by `r11DataCounter==1023` (counting up to 1023, addresses 0..511). The input provides no MTU or maximum frame length requirement; the actual boundary is defined by this constant; see I4.

No queue/arbitration: single-port sequential transmission, with no read/write conflicts or concurrent accesses.

### R-ETH-007 — Reset and Clock

`Reset` is a synchronous active-high reset that takes effect only on the rising edge of `Clk`; as an exception, `clkDiv` samples reset on the falling edge of `Clk`. `clk_en` is the global clock enable. `complete`, `diag`, and `next_state` are combinational signals, and reset does not act on them directly (their values are determined by `state`; after reset, `state=StateIdle`). `oRead` is derived from `clkDiv` in the falling-edge domain and has a cross-edge relationship with the remaining rising-edge logic.

### R-ETH-008 — Issues and Revision Locations

- **I1**: `oRead` is free-running and inconsistent with the “read request” semantics and internal `wReadFifo` (see Section 2).
- **I2**: The header field byte order is determined by `case` of `FCS_data` offset by 6 relative to `r8HeaderData`, and `r8HeaderData` is unused (see Section 3).
- **I3**: There are unused registers and redundant conditions (`addrCnt`, `r8PreambleData`, `r8HeaderData`, `r8SFD`, `rFIFOData`, `wFinishDataFifo`) (see Section 4).
- **I4**: The maximum frame length/MTU is not specified in the input; the boundary is defined by the `1023` constant (see Section 6).


## Supplementary CRC Representation and Parameters

The byte-wise CRC of R-ETH-005 can equivalently use the reflected form: initialize the 32-bit state to ffffffff; first XOR each Header/Data byte with the low 8 bits of the state, then shift right bit by bit 8 times, starting with the least significant bit; at each step, XOR with edb88320 if the shifted-out bit is 1. The FCS runs from the low byte to the high byte of the inverted final state; this is equivalent to the state representation in the main text that outputs the high bits in reversed bit order, and the valid output window for the bytes still follows the register delay in the main text. All operations are truncated to 32 bits. The CRC includes only the 12-byte fixed header and the actual Data bytes, and does not include Preamble/SFD/FCS/IFG.

The top-level state parameters default to StateIdle=0, StatePreamble=1, StateSFD=2, StateHeader=3, StateData=4, StateFCS=5, StateIFG=6, all 4 bits wide; this task fixes the default values and prohibits parameter overrides.
