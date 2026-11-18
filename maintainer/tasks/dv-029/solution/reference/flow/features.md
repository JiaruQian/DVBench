### F-001
feature_id: F-001
requirement_ids: R-dv-029-001
module: MemoryArbitrator
definition: i_nRst is synchronous and active-low; it clears active state, beat counts, busy flags, bank/index, write stencil, etc. only on source rising edges. Colors, addresses, read caches, and masks that are not reset must be established through legal transactions before use. fifoFull/fifoComplete are undriven and remain Z in functional simulation; they do not indicate the existence of a command FIFO.
interface: gpuClk, i_nRst, fifoFull, fifoComplete, req_o, cnt_o, adr_o, dat_o, sel_o, wrt_o, saveLoadOnGoing, importedBGBlock
timing: Bus outputs are combinational functions of the current state/inputs and may be sampled before the edge after the inputs have been stable for 1ns; sequential state updates on the gpuClk edge.
boundary: Fix all parameters at their defaults only; memory commands, TEX, CLUT, and background transactions are all in scope. Addresses/data have transaction meaning only in the corresponding req/write/completion windows.

### F-002
feature_id: F-002
requirement_ids: R-dv-029-002
module: MemoryArbitrator
definition: When idle, a request is initiated only when ack_i=0. Priority is a nonzero memoryWriteCommand, then a saveBGBlock transition from 0 to nonzero with a value of 2/3 or a value of 1 with blending, then CLUT, and finally TEX. On the first beat, req=1. The command address is command21:7 shifted left by 5, the CLUT address is shifted left by 5, and TEX selects the L address, otherwise R, shifted left by 3; the background first-beat address is 0. On the first beat, wrt_o=0. cnt is 0 for command 1, 7 for the other legal commands and BG/CLUT, and 1 for TEX.
interface: gpuClk, i_nRst, memoryWriteCommand, ack_i, saveBGBlock, isBlending, requClutCacheUpdate, requTexCacheUpdateL, requTexCacheUpdateR, adr_o, cnt_o, req_o, wrt_o
timing: Request selection is a pre-edge combinational value, and the active transaction is latched on the rising edge; subsequent cnt defaults to 0.
boundary: No request is issued while idle with ack high; simultaneous L/R selects the L address, but the completion side is latched separately according to the R request; holding a command nonzero causes it to be initiated again when subsequently idle.

### F-003
feature_id: F-003
requirement_ids: R-dv-029-003
module: MemoryArbitrator
definition: After entering the active state, each edge with ack_i=1 advances the beat index, and req remains 1; when ack_i=0, req is low in that cycle and a return to idle or a subsequent BG phase is scheduled for the next edge. Low ack ends the transaction rather than waiting indefinitely. The low active-address bits follow beat×4, and the low 3 bits of beat wrap modulo 8, with no automatic length-based stop.
interface: gpuClk, ack_i, req_o, cnt_o, adr_o, wrt_o, memoryWriteCommand
timing: First stabilize ack during the low phase, check the current beat address before the edge, and check the advanced outputs after the edge; cnt has length meaning only on the first beat.
boundary: ack going low early at any beat, standard 1/2/8 beats, and wraparound beyond 8 beats; do not count an external timeout as error detection.

### F-004
feature_id: F-004
requirement_ids: R-dv-029-004
module: MemoryArbitrator
definition: A command whose low 3 bits are 1 writes a pixel pair. Field 55:40 is the low 16-bit color, 39:24 is the high 16-bit color, 23:22 is the validity of the two halfwords, and 6:4 is the pair index; the active write address is the latched block address plus pair×4, and the data is {high color,low color}. Command 2 fills 8 words, replicating color 55:40 into both halfwords, with the mask all valid and the active address advancing by beat×4. Each halfword mask expands into two sel bits.
interface: memoryWriteCommand, gpuClk, ack_i, adr_o, dat_o, sel_o, wrt_o, req_o
timing: Colors and masks are latched on the initiation edge, and wrt=1 when active with ack high; the first beat still uses the default read direction.
boundary: Colors all zeros/all ones/distinct, mask00/01/10/11, pair0/7, and the first/last block; changes to command inputs during activity do not replace the latched colors.

### F-005
feature_id: F-005
requirement_ids: R-dv-029-005
module: MemoryArbitrator
definition: The TEX address gives priority to L, while the completion side latches the R request bit at initiation: when both requests are high, the address may be L while completion is R. Active beat 0 with ack high latches dat_i as the low 32 bits; beat 1 and later beats with nonzero low 3 index bits assert the selected completion side. TexCacheWrite is generated in the termination cycle when ack goes low; the high half of the 64-bit value is the current dat_i, and the low half is the value latched on the first beat. adrTexCacheWrite is the initiating byte address shifted right by 3.
interface: requTexCacheUpdateL, requTexCacheUpdateR, adrTexCacheUpdateL, adrTexCacheUpdateR, gpuClk, ack_i, dat_i, TexCacheData, TexCacheWrite, adrTexCacheWrite, updateTexCacheCompleteL, updateTexCacheCompleteR
timing: The completion side and TexCacheWrite have different windows; the high half of the data follows dat_i directly and is sampled after 1ns in the termination cycle.
boundary: L only, R only, both requests, different addresses/data, and early low ack; check the 64-bit value only in a valid writeback window.

### F-006
feature_id: F-006
requirement_ids: R-dv-029-006
module: MemoryArbitrator
definition: CLUT has cnt7 on the first beat, and the active address uses the current adrClutCacheUpdate and the low 3 bits of beat×4. When ack is high, an internal cache-write intent is issued. ClutCacheWrite and ClutWriteIndex are registered on the source edge, while ClutCacheData always passes dat_i through directly; the completion output is 1 on beat7.
interface: requClutCacheUpdate, adrClutCacheUpdate, gpuClk, ack_i, dat_i, ClutCacheWrite, ClutWriteIndex, ClutCacheData, updateClutCacheComplete
timing: Check pre-edge address/completion separately from post-edge write flag/index; the data itself has no corresponding register.
boundary: beat0/7, 8 consecutive beats and early termination, and address changes during activity; do not treat ClutCacheData as data delayed by one beat.

### F-007
feature_id: F-007
requirement_ids: R-dv-029-007
module: MemoryArbitrator
definition: saveBGBlock triggers only on a transition from 0 to nonzero. 1 reads the background only with blending; 2/3 first write 8 words, taking data and masks directly from the corresponding beat of the current exported block. Write termination generates resetMask; if blending and not 3, another read first beat is issued and loadAdr is read, otherwise the operation terminates and generates a pipeline reset pulse. Read termination issues an import pulse and a pipeline reset, with the imported block arranged as eight 32-bit dat_i values.
interface: saveBGBlock, isBlending, saveAdr, loadAdr, exportedBGBlock, exportedMSKBGBlock, gpuClk, ack_i, adr_o, dat_o, sel_o, wrt_o, resetMask, resetPipelinePixelStateSpike, importBGBlockSingleClock, importedBGBlock, saveLoadOnGoing
timing: The first beat sets busy, and the final termination edge clears busy; the background cache is valid only after a legal read history, and source-side save/load/export remain stable until completion.
boundary: saveBlock0/1/2/3×blending, holding the value repeatedly does not retrigger, retriggering after 0, read after write, and flush3 does not read again.

### F-008
feature_id: F-008
requirement_ids: R-dv-029-008
module: MemoryArbitrator
definition: Command 3 reads 8 words into one of two banks, each containing eight 32-bit words, with the bank selected by command3. The corresponding 16-bit pixel mask comes from 55:40; when command22 is 1, the other bank's mask is cleared. The cache and masks are not fully reset, so both banks must first be legally loaded separately before use.
interface: memoryWriteCommand, gpuClk, ack_i, dat_i, adr_o, req_o, saveLoadOnGoing
timing: The read-bank cache is written through a pipeline of active beats and their indices; use the writeback command only after termination.
boundary: bank0/1, masks all zeros/all ones/alternating, clearing the other bank versus retaining it; do not check data in an uninitialized bank.

### F-009
feature_id: F-009
requirement_ids: R-dv-029-009
module: MemoryArbitrator
definition: Command 4 writes back 8 words. bank=command3, VVIndex=27:24; the pixel source starting point rotates forward by bank×16+VVIndex 16-bit pixels modulo 32, then advances by 2 pixels per beat; the two halfwords come from this cyclic pixel sequence. command4 forces the most significant bit of each halfword to 1. When command5 is 1, only pixels whose corresponding stencil bit is 0 are written, and the source pixel mask must still be valid. stencil comes from 55:40, with two bits selected according to the current beat. After termination, command23:22 selects clearing the bank0/1 mask.
interface: memoryWriteCommand, gpuClk, ack_i, dat_o, sel_o, adr_o, wrt_o
timing: bank, rotation, stencil, force/check, and bank-clear controls are latched on the first beat; observe each active beat with ack high.
boundary: VVIndex0..15, including odd-halfword rotations, the cross-bank modulo-32 boundary, all four stencil pairs, force/check combinations, and another writeback after clearing a bank.
