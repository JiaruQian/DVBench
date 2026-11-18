# testplan

## T1

test_id: T1

feature_ids: ["F1"]

requirement_ids: ["R-dv-086-001"]

stimulus: Drive every input and establish a10 ns clock. Assert asynchronous reset initially and midstream, including away from a rising edge, with in-flight core, memory and buffered response work. Check every cleared state/output consequence and first post-reset miss. Cover all32 sets, both ways, full32-bit address extremes, all8 warps, masks0..3 and offsets0..7.

expected: The complete instruction_cache and supplied dependencies are in scope, with no top parameters. Fixed macros select 32-bit addresses, eight warps, two fetch mask bits, 32 sets, two ways, 64-bit lines, four MSHR entries and two subentries per entry. Address bits31:8 are tag,7:3 set and2:0 byte offset. Every native input pattern is legal. Active-low rst_n asynchronously clears all pipeline registers, both SRAM arrays and read/bypass registers, all validity and replacement state, MSHR address/target/valid/sent state and both response FIFO slots/pointers. Initial replacement way is zero. There is no core request or response ready port.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates at rising edges or an asserted asynchronous reset. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T2

test_id: T2

feature_ids: ["F2"]

requirement_ids: ["R-dv-086-002"]

stimulus: Use isolated and back-to-back requests with differing address/warp/mask and valid gaps. Maintain two input-history stages and independent selected-line storage. Check all native payload outputs every cycle after propagation, including invalid/miss cycles, mask0, byte offsets and status alignment around hits and misses.

expected: On each rising edge stage1 captures current request address, warp and mask unconditionally, and valid captures core_req_valid_i with same-cycle matching flush removed. Stage2 captures prior stage1 address/warp/mask unconditionally; its valid is prior stage1 valid with current stage1 matching flush removed. Data captures the pre-edge 64-bit lookup data from the hit way, with way0 on no hit and way1 if both ways hit. Return the complete line without selecting by byte offset; mask is echoed without gating lookup or data. All payload outputs remain observable while valid is zero. Miss status is stage1 valid AND no tag hit, first suppressed by the previous stage0 flush and captured one edge, then suppressed by the registered stage1 flush; status is not an earlier-stage combinational result. Misses respond immediately with status1 and stale selected-way data; there is no internal core replay.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates at rising edges or an asserted asynchronous reset. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T3

test_id: T3

feature_ids: ["F3"]

requirement_ids: ["R-dv-086-003"]

stimulus: Cross flush with matching/nonmatching current and previous warp in each stage, including simultaneous two-stage traffic and a stage1 miss. Independently retain MSHR/memory work after stage1 response cancellation. Compare response valid/status and every unaffected warp and retained storage consequence.

expected: A stage0 flush matches current core_req_wid_i and flush_pipe_wid_i when flush valid: it suppresses both array read enables and the captured request valid. Stage1 matching uses the stored request warp; it suppresses next core response valid and the corresponding registered status. A current stage1 flush does not suppress that stage1 miss entering MSHR. Flush affects neither cache storage/replacement nor existing MSHR entries, memory requests or refills. Other warps continue independently.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates at rising edges or an asserted asynchronous reset. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T4

test_id: T4

feature_ids: ["F4"]

requirement_ids: ["R-dv-086-004"]

stimulus: Fill two distinct tags per set, hit each way and fill a third tag to expose the exact two-way victim. Cross same/different-set hit and refill, invalid-only and invalid+refill. Revisit after invalid and verify stored stale data and replacement retention as well as current validity changes.

expected: Tag hit requires the captured read-request valid, a matching captured tag for the stored request address and the current validity bit of its captured set. In both-way hits the binary way is one. A miss selects way0 for data. Each set independently replaces way0 after reset and thereafter replaces the opposite of its most recently touched way. A lookup hit touches its hit way; a refill touches its pre-edge replacement way. A hit and refill in one set give the lookup touch priority; different sets both update. A refill sets only the selected way valid and has priority over global invalidation. When no refill occurs, invalid_i clears all way validity bits but preserves SRAM contents, replacement state, MSHR, FIFO and pipeline. An invalidation coinciding with a refill is discarded, with no pending invalidate.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates at rising edges or an asserted asynchronous reset. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T5

test_id: T5

feature_ids: ["F5"]

requirement_ids: ["R-dv-086-005"]

stimulus: Perform reads with and without enable; capture both ways before a later write. Refill and read the same set on one edge, including a tag matching an already valid other way, and expect complete replicated tag/data bypass rather than a masked merge. Include a different-set simultaneous read/write and subsequent held read outputs.

expected: A nonflushed core request captures both ways' pre-edge tag and data values for its current set. With no read, the array read registers retain their prior values. If the same edge also refills that set, the SRAM read is suppressed and a one-edge bypass flag instead selects two copies of the refill tag and two copies of its complete64-bit line, including the way not written. Otherwise the read registers are selected. This full-way bypass is intentional observable behavior and does not use the refill way mask. Bypass data/tag captures every edge from the currently selected response head and refill address; reset clears it. Underlying SRAM writes still modify only the pre-edge replacement way.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates at rising edges or an asserted asynchronous reset. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T6

test_id: T6

feature_ids: ["F6"]

requirement_ids: ["R-dv-086-006"]

stimulus: Fill all4 entries with memory requests blocked, issue secondary misses up to/over2 slots, and issue a fifth primary. Cross response/miss same block rejection, different block reuse on either index ordering and secondary slot clear/write priority. Predict block/valid state from input history and check later visible memory requests/refill placement.

expected: A stage1 miss offers block address addr[31:3] for one edge. Each of four entries is live when either of its two subentries is valid; a matching live address is secondary. Match encoders bitwise-OR all matching entry indices, returning0 on no match. Allocation uses the lowest free entry or subentry, returning0 when none exists. Reject a primary when all entries are live, a secondary when its two slots are full, or any miss concurrent with a response for the same block. Rejected misses are dropped without core backpressure/retry. An admitted primary writes its block address at the pre-edge lowest free entry. Normally it sets that entry's subentry0; concurrent response for a different block clears the matched response entry and places this new valid bit at the smaller of the free-entry and response-entry indices, while the block write remains at the original free entry. Thus reuse can revive the old response address. An admitted secondary sets its chosen slot, with new valid bits taking priority over concurrent clearing. Without an admitted request, a response clears all subentries of its selected entry.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates at rising edges or an asserted asynchronous reset. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T7

test_id: T7

feature_ids: ["F7"]

requirement_ids: ["R-dv-086-007"]

stimulus: Vary memory request ready and each eligible entry priority, exercise simultaneous sent-set/response-clear and all byte offsets with independent warp values. Hold entry1/entry3 unsent while entry0/entry1 secondary writes alias their source slots, and compare address/source even while valid is zero.

expected: For each entry keep a sent flag. The lowest-index live unsent entry drives mem_req_valid_o; with none eligible select index0 for observable address/source payload and deassert valid. Request address is that entry's29-bit block concatenated with three zeros. A valid/ready handshake sets its sent flag; a response clears the selected response entry's sent flag, with a same-entry request send taking priority. The target-information input truncates the nominal concatenation {warp,addr[2:0]} to only addr[2:0]. Keep a24-bit target vector reset to zero. An admitted request for entry e and subentry s writes three offset bits starting at bit3*((e+1)*(s+1)-1). mem_req_a_source_o reads bits3*send_entry+:3, including the resulting aliasing between entry0 secondary and entry1 primary, and entry1 secondary and entry3 primary. No warp bits survive this source path. Payload remains observable while memory request valid is zero.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates at rising edges or an asserted asynchronous reset. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T8

test_id: T8

feature_ids: ["F8"]

requirement_ids: ["R-dv-086-008"]

stimulus: Inject isolated, consecutive, duplicate and unmatched responses with complete high-bit data patterns, source variations and mixed request traffic. Track the two physical FIFO slots and pre-edge head. Compare one-edge refill latency, selected entry's stored address fallback, concurrent request/response reuse and source independence. Require nonempty independent checking and directed plus randomized histories for each criterion.

expected: mem_rsp_ready_o is always one. A two-slot FIFO captures every valid memory response and consumes each nonempty head at the following rising edge; it has no empty bypass, may simultaneously enqueue/dequeue and preserves stale slot payload while empty. Its99-bit payload is {data64,address32,source3}; response source is otherwise ignored. The head address bits31:3 match all live MSHR blocks and bitwise-OR matching entry indices; no match selects entry0. Every consumed head refills the stored block address of that selected entry, not the raw external response address, using its current replacement way, stored block tag/set and the head's full64-bit data. Unsolicited or duplicate responses therefore use entry0's stale block and clear its MSHR validity. Response acceptance/consumption is independent of core valid, flush, invalid and memory request readiness. Complete native high bits and all documented concurrent reset/read/write/admission priorities remain in scope.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates at rising edges or an asserted asynchronous reset. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv
