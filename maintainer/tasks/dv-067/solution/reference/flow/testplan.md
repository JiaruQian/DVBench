# Reference testplan

{
  "test_id": "T1",
  "feature_ids": [
    "F1"
  ],
  "requirement_ids": [
    "R-p8-tage-001"
  ],
  "stimulus": "After a reset edge and completed128-row sweep, allocate every row with known tag3 and read every index. Vary all low2 history values, PC slice boundaries and tag aliases through2000 seeded randomized cycles, changing ignored upper PC/history bits independently. Use two initial distinct allocated writes before deterministic bypass-miss comparisons.",
  "expected": "There are128 rows and4 independent ways. Read index is {request_pc[10:6],request_pc[5:4] XOR request_ghist[1:0]}; read tag is {request_pc[17:13],request_pc[12:11] XOR request_ghist[1:0]}. Update index/tag use the identical functions of update_pc/update_hist. Only these PC slices and history bits1:0 affect addressing. Every field is unsigned; all other PC/history bits are ignored. There are no parameters, ready signals or external protocol restrictions.",
  "checker": "Self-contained independent dvbench_model maintains separate128x4 abstract valid/tag/counter/usefulness arrays, two bypass records and pre-edge read/reset/age history solely from native inputs. tage_scoreboard compares every native output to distinct expected outputs using four-state inequality two time units after falling and rising edges. Unknown disabled-read or uninitialized bits receive no deterministic correctness claim; known-bit mismatches emit UVM_ERROR. Count comparisons and reject fewer than1000 observations. Do not use actual DUT outputs as predicted state.",
  "implementation_id": "tage_scoreboard.compare",
  "source": "tage_pkg.sv:tage_sequence.body; tage_scoreboard.compare"
}

{
  "test_id": "T2",
  "feature_ids": [
    "F2"
  ],
  "requirement_ids": [
    "R-p8-tage-002"
  ],
  "stimulus": "Apply reset and wait the full sweep. Launch back-to-back valid reads to all128 rows, plus randomized valid gaps, misses and same-row read/write collisions. Track each input enable/index/tag at edge E and sample outputs after E+1. Include entry-invalid reads after sweep and tag misses after allocation; compare counter/usefulness regardless of hit, while treating disabled-read unknown bits as unspecified.",
  "expected": "At a rising edge E, latch read enable, index and tag unconditionally from current f1 inputs. At edge E+1 register each way response from the row selected by the latched index, using row state immediately before E+1 writes. Thus a row write at E is visible to that read, while a write at E+1 is not. With the latched read enable high, response valid is stored entry valid AND matching7-bit tag AND not sweeping at E+1; counter is the row3-bit counter and usefulness is {high,low}, even on a tag miss or invalid entry. With latched enable low, counter/usefulness are unknown and valid is unknown unless sweeping forces it low; do not assume zero or held response. Response registers and read pipeline are not synchronously cleared by reset itself. Every cycle can launch a new read.",
  "checker": "Self-contained independent dvbench_model maintains separate128x4 abstract valid/tag/counter/usefulness arrays, two bypass records and pre-edge read/reset/age history solely from native inputs. tage_scoreboard compares every native output to distinct expected outputs using four-state inequality two time units after falling and rising edges. Unknown disabled-read or uninitialized bits receive no deterministic correctness claim; known-bit mismatches emit UVM_ERROR. Count comparisons and reject fewer than1000 observations. Do not use actual DUT outputs as predicted state.",
  "implementation_id": "tage_scoreboard.compare",
  "source": "tage_pkg.sv:tage_sequence.body; tage_scoreboard.compare"
}

{
  "test_id": "T3",
  "feature_ids": [
    "F3"
  ],
  "requirement_ids": [
    "R-p8-tage-003"
  ],
  "stimulus": "After reset/sweep and two distinct allocated writes, exercise every external old_ctr0..7 with taken0/1 and allocation overrides. Sweep all16 independent table masks and differing useful masks. Alternate row/tag pairs to exercise bypass misses and hits, then repeat updates enough times to reach both saturations. Read affected and untouched ways with full expected contents.",
  "expected": "Each normal clock independently writes every way whose update_mask is high at the hashed update row; it sets entry valid1, shared new tag and computed3-bit counter. Unmasked ways preserve entry fields. For each way allocation overrides the old counter and initializes4 if taken,3 if not taken. Otherwise saturating increment/decrement uses a matching bypass counter if available, or that way external update_old_ctr if no match. Taken increments up to7; not-taken decrements down to0. Current table storage is not an implicit substitute for external old_ctr on a bypass miss. Normal writes occur every masked edge without a global update-valid signal.",
  "checker": "Self-contained independent dvbench_model maintains separate128x4 abstract valid/tag/counter/usefulness arrays, two bypass records and pre-edge read/reset/age history solely from native inputs. tage_scoreboard compares every native output to distinct expected outputs using four-state inequality two time units after falling and rising edges. Unknown disabled-read or uninitialized bits receive no deterministic correctness claim; known-bit mismatches emit UVM_ERROR. Count comparisons and reject fewer than1000 observations. Do not use actual DUT outputs as predicted state.",
  "implementation_id": "tage_scoreboard.compare",
  "source": "tage_pkg.sv:tage_sequence.body; tage_scoreboard.compare"
}

{
  "test_id": "T4",
  "feature_ids": [
    "F4"
  ],
  "requirement_ids": [
    "R-p8-tage-004"
  ],
  "stimulus": "After reset/sweep fill all128 rows with allocated writes, establishing both bypass slots. Alternate distinct row/tag pairs then revisit earlier keys, including different tags at related rows. Use all16 table masks and repeat10 updates at a recent key with deliberately stale external old counters. Vary all4 taken/allocation bits so masked and unmasked bypass-counter updates diverge. Complete another reset sweep after active history and inspect cleared table contents.",
  "expected": "Maintain two recency slots with row index, tag and4 counters. A slot matches only outside the reset sweep, by both index and tag; slot0 wins if both match. Any nonzero update_mask updates all4 computed bypass counters in the chosen slot, including ways whose table mask is zero. On a hit update its counters without changing replacement selection. On a miss put index/tag and all4 computed counters into the replacement slot, then alternate replacement for the next miss. Replacement initializes to slot0 on reset. Slot indices,tags and counters are not cleared by reset. Sweep disables matches but masked updates may still modify bypass data; the reset branch independently controls replacement. Before slots have known records, uninitialized comparisons/data are unspecified; initialize with allocated writes to two distinct index/tag pairs when relying on deterministic nonallocation behavior.",
  "checker": "Self-contained independent dvbench_model maintains separate128x4 abstract valid/tag/counter/usefulness arrays, two bypass records and pre-edge read/reset/age history solely from native inputs. tage_scoreboard compares every native output to distinct expected outputs using four-state inequality two time units after falling and rising edges. Unknown disabled-read or uninitialized bits receive no deterministic correctness claim; known-bit mismatches emit UVM_ERROR. Count comparisons and reject fewer than1000 observations. Do not use actual DUT outputs as predicted state.",
  "implementation_id": "tage_scoreboard.compare",
  "source": "tage_pkg.sv:tage_sequence.body; tage_scoreboard.compare"
}

{
  "test_id": "T5",
  "feature_ids": [
    "F5"
  ],
  "requirement_ids": [
    "R-p8-tage-005"
  ],
  "stimulus": "After reset/sweep, independently vary all16 table masks and all16 useful masks, useful values0..3 and distinct way values through seeded randomized traffic. Read written and preserved ways. Refill all128 rows with useful3, then continuously read across the long aging phase to compare the separate arrays, including cycles when one array clear overrides ordinary updates in the random prefix.",
  "expected": "Each way has two useful bits in independent high/low arrays. A normal update_u_mask writes both bits from update_u at the hashed update row, independently of table update_mask, allocation and entry validity. Table writes alone do not alter usefulness. If a periodic clear affects one array on that edge, it overrides that entire array write address, all4 way masks and data with its aging clear; the other array still accepts its ordinary masked update. Sweep has priority over both arrays and clears all4 ways at its current row.",
  "checker": "Self-contained independent dvbench_model maintains separate128x4 abstract valid/tag/counter/usefulness arrays, two bypass records and pre-edge read/reset/age history solely from native inputs. tage_scoreboard compares every native output to distinct expected outputs using four-state inequality two time units after falling and rising edges. Unknown disabled-read or uninitialized bits receive no deterministic correctness claim; known-bit mismatches emit UVM_ERROR. Count comparisons and reject fewer than1000 observations. Do not use actual DUT outputs as predicted state.",
  "implementation_id": "tage_scoreboard.compare",
  "source": "tage_pkg.sv:tage_sequence.body; tage_scoreboard.compare"
}

{
  "test_id": "T6",
  "feature_ids": [
    "F6"
  ],
  "requirement_ids": [
    "R-p8-tage-006"
  ],
  "stimulus": "Drive reset across two rising edges with writes disabled, then132 deasserted clocks to cover all128 clears and pipeline drain. Allocate and update before another reset; repeat the complete reset/sweep and read all rows. Compare registered responses both before and after edges from reset onward; no immediate reset gating is expected. Maintain an independent pre-edge sweep-index/history model rather than reading DUT internals.",
  "expected": "Reset is synchronous active high. At a reset edge set sweeping1, sweep_index0,19-bit age0 and replacement slot0. It does not immediately clear memory, read pipeline, response registers or bypass data. Every edge with pre-edge sweeping1 clears all4 table entries and both useful arrays at sweep_index, overriding normal table/useful writes. With reset low advance sweep_index modulo128, keep sweeping until the row127 write, then stop; while sweeping set age1 each edge. Holding reset high repeatedly writes row0 once sweeping is active and holds its index0. A full reset followed by128 deasserted edges completes all row clears. Response-valid suppression uses pre-edge sweeping, so the row127-clearing edge remains suppressed. Bypass updates and pipeline sampling remain governed by their separate input conditions, including reset edges. Memory and other unreset registers start unspecified. At a reset edge, memory writes still use pre-edge sweeping/age and native masks, so an ordinary or aging write may occur before the newly reset sweep state takes effect.",
  "checker": "Self-contained independent dvbench_model maintains separate128x4 abstract valid/tag/counter/usefulness arrays, two bypass records and pre-edge read/reset/age history solely from native inputs. tage_scoreboard compares every native output to distinct expected outputs using four-state inequality two time units after falling and rising edges. Unknown disabled-read or uninitialized bits receive no deterministic correctness claim; known-bit mismatches emit UVM_ERROR. Count comparisons and reject fewer than1000 observations. Do not use actual DUT outputs as predicted state.",
  "implementation_id": "tage_scoreboard.compare",
  "source": "tage_pkg.sv:tage_sequence.body; tage_scoreboard.compare"
}

{
  "test_id": "T7",
  "feature_ids": [
    "F7"
  ],
  "requirement_ids": [
    "R-p8-tage-007"
  ],
  "stimulus": "After completed sweep and arbitrary masked updates, refill all128 rows and all4 ways with useful3. Run270000 further normal clocks without updates, continuously read successive rows, and independently count age from the reset/sweep history. This crosses2048-clock low clears and the2^18 low-to-high transition. Compare exact array/row/way values before and after each clearing edge, with all table tags/counters preserved.",
  "expected": "After sweep, increment the unsigned19-bit age each clock modulo2^19. When pre-edge age bits10:0 are zero, clear all4 ways of one usefulness array at row age[17:11]. Clear low when age[18]=0 and high when age[18]=1. This happens once per2048 normal clocks, alternates arrays every2^18 age increments, and wraps after2^19. Aging never alters table valid/tag/counter. Sweep has higher priority; normal masked usefulness writes to the array being cleared lose that edge, while the other array may still update.",
  "checker": "Self-contained independent dvbench_model maintains separate128x4 abstract valid/tag/counter/usefulness arrays, two bypass records and pre-edge read/reset/age history solely from native inputs. tage_scoreboard compares every native output to distinct expected outputs using four-state inequality two time units after falling and rising edges. Unknown disabled-read or uninitialized bits receive no deterministic correctness claim; known-bit mismatches emit UVM_ERROR. Count comparisons and reject fewer than1000 observations. Do not use actual DUT outputs as predicted state.",
  "implementation_id": "tage_scoreboard.compare",
  "source": "tage_pkg.sv:tage_sequence.body; tage_scoreboard.compare"
}
