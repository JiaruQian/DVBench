## F1

requirement_ids: ["R-bba53466-001"]

module: ascon_top

definition: Rising edges of clock_i advance computation; resetb_i is active-low and asynchronously returns to idle and clears the logical round number and block count to zero. When computation is enabled, state clearing by reset is overwritten by the computation write in the same event; the state is guaranteed to be zero only when the enable is off during idle or waiting. Reset does not clear defined end_o, cipher_valid_o, or the external-state selection history. start_i=1 starts only when idle; start_i is ignored when busy; state_i, key_i, and data_i are not latched in their entirety at start, but use current port values in the computation windows described below.

interface: ["state_i", "key_i", "data_i", "resetb_i", "start_i", "clock_i", "data_valid_i", "end_o", "cipher_valid_o", "cipher_o", "tag_o"]

timing: Synchronous controls such as start/data_valid are sampled on rising edges of clock_i; state/key/data use current values according to the public computation windows, combinational outputs are observed after settling following the edge, and falling edges of resetb_i are observed separately.

boundary: Reset-related outputs are observed at the combinationally settled time after the corresponding event; initially undefined flags are not required to be cleared to zero. reset aborts control but must not forcibly clear all outputs to zero.

## F2

requirement_ids: ["R-bba53466-002"]

module: ascon_top

definition: The state consists of five 64-bit words, with state_i[0] as the most significant packed word. Initialization executes rounds 0 through 11; after the last round, the high 64 bits of key_i are XORed into word 3 and the low 64 bits into word 4. The first round uses state_i at the time of computation, and subsequent rounds use the previous mathematical state. Each round consists of constant injection, a 5-bit S-box, and per-word rotate-right XOR operations. All words are 64 bits, and bitwise XOR, AND, and NOT are all limited to 64 bits; ROTR denotes a 64-bit rotate right. For round numbers r=0..11, the 8-bit constant ((15-r)<<4)|r is zero-extended and XORed into word 2. The S-box is then applied in parallel to the 64 bit columns: the bits at the same position in the five words form a 5-bit integer with word 0 as the most significant bit. The outputs for inputs 0..31 are, in order, hexadecimal
04,0b,1f,14,1a,15,09,02,1b,05,08,12,1d,03,06,1c,1e,13,07,0e,00,0d,11,18,10,0c,01,19,16,0a,0f,17。
After the S-box output is split back into five words, each word x is updated to x xor ROTR(x,a) xor ROTR(x,b), where (a,b) for words 0..4 are respectively (19,28), (61,39), (1,6), (10,17), and (7,41). The data/key pre-XOR required by a phase occurs before the constant, and the last-round key/domain-separation XOR occurs after the linear layer. 12..15 are not legal mathematical round numbers; no definite value is guaranteed for temporary out-of-range results. In the normal flow from power-on reset with no intervening reset: denote acceptance of start as E0; E1 prepares; E2 commits initialization round 0; E13 commits round 11 and enters the associated-data wait state. Reentry after an abort is handled according to the disclosed history-retention rules.

interface: ["state_i", "key_i", "data_i", "resetb_i", "start_i", "clock_i", "data_valid_i", "end_o", "cipher_valid_o", "cipher_o", "tag_o"]

timing: Synchronous controls such as start/data_valid are sampled on rising edges of clock_i; state/key/data use current values according to the public computation windows, combinational outputs are observed after settling following the edge, and falling edges of resetb_i are observed separately.

boundary: Update the five words mathematically using an independent Boolean S-box and rotate-right operations; reading DUT outputs as chaining values is prohibited. Continue comparing all valid cipher/tag values after initialization to observe all rounds.

## F3

requirement_ids: ["R-bba53466-003"]

module: ascon_top

definition: After initialization, wait for data_valid_i=1, then enter the associated-data window. This window XORs the current data_i into word 0 and executes rounds 6 through 11; the last round only inverts the least significant bit of word 4 for domain separation and does not XOR the key. The mathematical state is held while waiting; data_valid_i outside a wait window does not start a new block.

interface: ["state_i", "key_i", "data_i", "resetb_i", "start_i", "clock_i", "data_valid_i", "end_o", "cipher_valid_o", "cipher_o", "tag_o"]

timing: Synchronous controls such as start/data_valid are sampled on rising edges of clock_i; state/key/data use current values according to the public computation windows, combinational outputs are observed after settling following the edge, and falling edges of resetb_i are observed separately.

boundary: Only the first associated-data round absorbs the current data_i, and the last round performs domain separation. Do not latch data early at the valid acceptance edge, and do not generate an associated-data cipher_valid pulse.

## F4

requirement_ids: ["R-bba53466-004"]

module: ascon_top

definition: After associated data, enter the plaintext wait state with the block count at 0. Every rising edge in the plaintext wait state increments the 2-bit block count by one with modulo-4 wraparound, including the edge accepting data_valid_i. During the one cycle after acceptance in which cipher_valid_o is 1, cipher_o is the current mathematical state word 0 xor the current data_i; rounds 6 through 11 are then executed, and cipher_valid_o returns to 0. At completion of the last round, enter the finalization wait state only if the block count equals 3; otherwise, return to the plaintext wait state. The number of wait cycles affects exit; it must not be assumed that there are always 3 plaintext blocks.

interface: ["state_i", "key_i", "data_i", "resetb_i", "start_i", "clock_i", "data_valid_i", "end_o", "cipher_valid_o", "cipher_o", "tag_o"]

timing: Synchronous controls such as start/data_valid are sampled on rising edges of clock_i; state/key/data use current values according to the public computation windows, combinational outputs are observed after settling following the edge, and falling edges of resetb_i are observed separately.

boundary: Compare the 64-bit cipher and valid bit by bit in every valid window. Determine whether to enter finalization by accumulating wait cycles from the input history; do not derive expectations from actual end/cipher_valid or treat valid=0 as a reason to stop checking.

## F5

requirement_ids: ["R-bba53466-005"]

module: ascon_top

definition: The finalization wait state enters the first finalization round only after data_valid_i=1. The first round XORs data_i into word 0 and the high and low halves of key_i into words 1 and 2, respectively; at the same time, cipher_valid_o is 1 and cipher_o is word 0 xor data_i. Rounds 0 through 11 are then executed, with valid at 0 from the second round onward; the last round XORs the high and low halves of the current key_i into words 3 and 4, respectively. Upon completion, end_o is set to 1 and tag_o is {mathematical state word 3,mathematical state word 4}; return to idle in the next cycle.

interface: ["state_i", "key_i", "data_i", "resetb_i", "start_i", "clock_i", "data_valid_i", "end_o", "cipher_valid_o", "cipher_o", "tag_o"]

timing: Synchronous controls such as start/data_valid are sampled on rising edges of clock_i; state/key/data use current values according to the public computation windows, combinational outputs are observed after settling following the edge, and falling edges of resetb_i are observed separately.

boundary: Check cipher validity in the first finalization round and its deassertion in the next cycle, the word order of the full 128-bit tag, and the time when end first goes high; continue observing after end is defined as 1.

## F6

requirement_ids: ["R-bba53466-006"]

module: ascon_top

definition: end_o is undefined before the first completion and remains 1 after completion; neither subsequent starts nor resets clear it. cipher_valid_o is undefined before the first plaintext window; afterward, it is set to 1 only in the first round of plaintext or finalization and cleared to 0 in the next round, and is held in all other phases. After end_o=1, tag_o continuously reflects the current mathematical state words 3 and 4, so it can change in a new session; it does not permanently latch the first tag. A numerical value is required for cipher_o only when the predicted cipher_valid_o=1, and for tag_o only when the predicted end_o=1 and the mathematical bits are defined. The idle round number may reach 12 through 15; out-of-range constants and the mathematical bits affected by them that have not yet been overwritten by a new initialization are undefined. No specific X pattern is required, and actual values must not be used to determine the mask.

interface: ["state_i", "key_i", "data_i", "resetb_i", "start_i", "clock_i", "data_valid_i", "end_o", "cipher_valid_o", "cipher_o", "tag_o"]

timing: Synchronous controls such as start/data_valid are sampled on rising edges of clock_i; state/key/data use current values according to the public computation windows, combinational outputs are observed after settling following the edge, and falling edges of resetb_i are observed separately.

boundary: Validity and the per-bit domain of definedness come only from the input history and the independent model; an X produced by the DUT in a window that should be defined must also cause a mismatch. Do not fabricate zeros for undefined values, and do not check invalid cipher values.
