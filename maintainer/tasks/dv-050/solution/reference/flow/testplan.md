## T01
test_id: T01
feature_ids: ['F01']
requirement_ids: ['R-3b4ee4883dca-001']
stimulus: First complete a nonzero digest and start another block, assert reset at a point more than 2ns away from adjacent clock edges, compare between edges and after subsequent clock edges, then release reset and start a new block.
expected: reset_n is an active-low asynchronous reset. Upon assertion, without waiting for a clk edge, ready=1, digest=0, and digest_valid=0, and the block being processed is canceled. Releasing reset does not start computation.
checker: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sample 1ns after rising-edge NBA updates and combinational propagation have completed. For asynchronous reset and combinational reads, also sample between edges after 1ns of stability. The input-history predictor is driven only by reset, stimulus, and previous inputs, and does not read DUT outputs. An independent whole-block SHA-2 model and a command/register history model compute expected; the monitor samples actual from the native ports and compares all valid outputs using four-state inequality, reporting UVM_ERROR for any mismatch; record the comparison count and also report an error for missing comparisons, end after a fixed number of cycles, and do not wait for DUT outputs to determine stimulus.
implementation_id: dv-050-reset
source: tests/native_if.sv:exercise; tests/verify_pkg.sv:scoreboard.write
implementation_status: Semantic plan; existing HDL has measured baseline/mutants but not every directed scenario separately witnessed

## T02
test_id: T02
feature_ids: ['F02']
requirement_ids: ['R-3b4ee4883dca-002']
stimulus: Issue one-cycle commands for init, next, and both asserted simultaneously, respectively, drive different 512-bit blocks, and change block immediately after acceptance; check acceptance and completion cycle by cycle.
expected: Accept init or next only on a rising edge of clk with ready=1. Denote the acceptance edge as n; capture the entire block at that time, after which ready=0 and digest_valid=0. When init and next are both 1, handle the command as init.
checker: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sample 1ns after rising-edge NBA updates and combinational propagation have completed. For asynchronous reset and combinational reads, also sample between edges after 1ns of stability. The input-history predictor is driven only by reset, stimulus, and previous inputs, and does not read DUT outputs. An independent whole-block SHA-2 model and a command/register history model compute expected; the monitor samples actual from the native ports and compares all valid outputs using four-state inequality, reporting UVM_ERROR for any mismatch; record the comparison count and also report an error for missing comparisons, end after a fixed number of cycles, and do not wait for DUT outputs to determine stimulus.
implementation_id: dv-050-launch
source: tests/native_if.sv:exercise; tests/verify_pkg.sv:scoreboard.write
implementation_status: Semantic plan; existing HDL has measured baseline/mutants but not every directed scenario separately witnessed

## T03
test_id: T03
feature_ids: ['F03']
requirement_ids: ['R-3b4ee4883dca-003']
stimulus: Starting from reset, compute the padded abc block, all-0, all-1, distinct-word, and random blocks in sequence. For both modes, use an independent 64-round whole-block mathematical algorithm to compute the full 256-bit result; also check the standard SHA-256 and the first 224 bits of SHA-224 for abc.
expected: All operations are performed as 32-bit unsigned operations modulo 2^32. Divide each 512-bit input block into W[0..15], most significant word first. For t=16..63, W[t]=W[t-16]+σ0(W[t-15])+W[t-7]+σ1(W[t-2]), where σ0(x)=ROTR7(x) XOR ROTR18(x) XOR SHR3(x), and σ1(x)=ROTR17(x) XOR ROTR19(x) XOR SHR10(x). Initialize a..h from the current eight-word chaining value. In each of the 64 rounds, use T1=h+Σ1(e)+Ch(e,f,g)+K[t]+W[t] and T2=Σ0(a)+Maj(a,b,c), and update (a,b,c,d,e,f,g,h)=(T1+T2,a,b,c,d+T1,e,f,g). Σ0 is ROTR2 XOR ROTR13 XOR ROTR22, Σ1 is ROTR6 XOR ROTR11 XOR ROTR25, Ch=(e AND f) XOR ((NOT e) AND g), and Maj=(a AND b) XOR (a AND c) XOR (b AND c). K[t] consists of the 64 constants in the SHA-256 standard, namely the fractional parts of the cube roots of the first 64 primes multiplied by 2^32 and rounded down. The result is the eight input chaining words individually added to a..h after 64 rounds, with H0 occupying the most significant 32 bits. The initial eight words for SHA-256 are 6a09e667 bb67ae85 3c6ef372 a54ff53a 510e527f 9b05688c 1f83d9ab 5be0cd19; the initial eight words for SHA-224 are c1059ed8 367cd507 3070dd17 f70e5939 ffc00b31 68581511 64f98fa7 befa4fa4. The full 256-bit chaining value is output here, and SHA-224 also retains the eighth word; the module does not generate padding, length encoding, or external byte-order conversion.
checker: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sample 1ns after rising-edge NBA updates and combinational propagation have completed. For asynchronous reset and combinational reads, also sample between edges after 1ns of stability. The input-history predictor is driven only by reset, stimulus, and previous inputs, and does not read DUT outputs. An independent whole-block SHA-2 model and a command/register history model compute expected; the monitor samples actual from the native ports and compares all valid outputs using four-state inequality, reporting UVM_ERROR for any mismatch; record the comparison count and also report an error for missing comparisons, end after a fixed number of cycles, and do not wait for DUT outputs to determine stimulus.
implementation_id: dv-050-algorithm
source: tests/native_if.sv:exercise; tests/verify_pkg.sv:scoreboard.write
implementation_status: Semantic plan; existing HDL has measured baseline/mutants but not every directed scenario separately witnessed

## T04
test_id: T04
feature_ids: ['F04']
requirement_ids: ['R-3b4ee4883dca-004']
stimulus: After completing init, use next for three consecutive different blocks, alternating mode during the sequence; insert a new init to verify restarting. After a separate reset, issue next directly and compare against independent compression with an all-0 chaining value.
expected: When init is accepted, select the initial chaining value for SHA-256 (mode=1) or SHA-224 (mode=0) according to mode, and immediately display that eight-word initial value on digest. next uses the previous full 256-bit digest as the input chaining value for the new block without reinitialization; changes in mode do not change the chaining input for next. A next issued directly after reset starts from an all-0 chaining value.
checker: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sample 1ns after rising-edge NBA updates and combinational propagation have completed. For asynchronous reset and combinational reads, also sample between edges after 1ns of stability. The input-history predictor is driven only by reset, stimulus, and previous inputs, and does not read DUT outputs. An independent whole-block SHA-2 model and a command/register history model compute expected; the monitor samples actual from the native ports and compares all valid outputs using four-state inequality, reporting UVM_ERROR for any mismatch; record the comparison count and also report an error for missing comparisons, end after a fixed number of cycles, and do not wait for DUT outputs to determine stimulus.
implementation_id: dv-050-chain
source: tests/native_if.sv:exercise; tests/verify_pkg.sv:scoreboard.write
implementation_status: Semantic plan; existing HDL has measured baseline/mutants but not every directed scenario separately witnessed

## T05
test_id: T05
feature_ids: ['F05']
requirement_ids: ['R-3b4ee4883dca-005']
stimulus: For a single block and a continuation block, sample every cycle from n through n+67, then remain idle for 80 cycles and check that the digest and valid hold. Check that it is still busy at n+64 and completes at n+65.
expected: The 65th rising edge after acceptance edge n (n+65) updates digest to the final compression value, with ready=1 and digest_valid=1 simultaneously. Remain busy from n+1 through n+64 without completing early; during computation, digest holds the chaining value at acceptance. digest_valid remains 1 until the next valid command or reset; digest holds while idle.
checker: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sample 1ns after rising-edge NBA updates and combinational propagation have completed. For asynchronous reset and combinational reads, also sample between edges after 1ns of stability. The input-history predictor is driven only by reset, stimulus, and previous inputs, and does not read DUT outputs. An independent whole-block SHA-2 model and a command/register history model compute expected; the monitor samples actual from the native ports and compares all valid outputs using four-state inequality, reporting UVM_ERROR for any mismatch; record the comparison count and also report an error for missing comparisons, end after a fixed number of cycles, and do not wait for DUT outputs to determine stimulus.
implementation_id: dv-050-retire
source: tests/native_if.sv:exercise; tests/verify_pkg.sv:scoreboard.write
implementation_status: Semantic plan; existing HDL has measured baseline/mutants but not every directed scenario separately witnessed

## T06
test_id: T06
feature_ids: ['F06']
requirement_ids: ['R-3b4ee4883dca-006']
stimulus: Apply different commands and blocks at the 1st, 10th, 64th, and 65th rising edges after acceptance, and compare against the original result of the first block; then resubmit at an idle edge and confirm the new block.
expected: init/next and changes to mode/block while ready=0 do not change the result of the accepted block and are not queued. It is still busy before completion edge n+65, and commands at that edge are not accepted; if a command is still asserted at the next rising edge, it is accepted.
checker: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sample 1ns after rising-edge NBA updates and combinational propagation have completed. For asynchronous reset and combinational reads, also sample between edges after 1ns of stability. The input-history predictor is driven only by reset, stimulus, and previous inputs, and does not read DUT outputs. An independent whole-block SHA-2 model and a command/register history model compute expected; the monitor samples actual from the native ports and compares all valid outputs using four-state inequality, reporting UVM_ERROR for any mismatch; record the comparison count and also report an error for missing comparisons, end after a fixed number of cycles, and do not wait for DUT outputs to determine stimulus.
implementation_id: dv-050-busy
source: tests/native_if.sv:exercise; tests/verify_pkg.sv:scoreboard.write
implementation_status: Semantic plan; existing HDL has measured baseline/mutants but not every directed scenario separately witnessed

## T07
test_id: T07
feature_ids: ['F07']
requirement_ids: ['R-3b4ee4883dca-007']
stimulus: Establish two independent histories separately: in the first, set init=1 and hold next=1, maintaining the init-priority path for more than 140 cycles; in the second, separately hold next=1 and init=0 for more than 140 cycles. Both histories start from definite, legal chaining values. Observe cycle by cycle at least two completions and reacceptance and clearing of valid at the next idle edge; change the full block and mode while busy, and predict the full 256-bit digest using the values captured at each acceptance edge.
expected: When init or next remains 1, computation restarts on every rising edge at which the module is idle; there is no additional pulse deduplication or queue. All 512 bits of block participate in computation, and mode selects the initial vector only when init is accepted. All port inputs use known 0/1 values, with a fixed native interface and no externally overridable parameters.
checker: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sample 1ns after rising-edge NBA updates and combinational propagation have completed. For asynchronous reset and combinational reads, also sample between edges after 1ns of stability. The input-history predictor is driven only by reset, stimulus, and previous inputs, and does not read DUT outputs. An independent whole-block SHA-2 model and a command/register history model compute expected; the monitor samples actual from the native ports and compares all valid outputs using four-state inequality, reporting UVM_ERROR for any mismatch; record the comparison count and also report an error for missing comparisons, end after a fixed number of cycles, and do not wait for DUT outputs to determine stimulus.
implementation_id: dv-050-held
source: tests/native_if.sv:exercise; tests/verify_pkg.sv:scoreboard.write
implementation_status: Semantic plan; existing HDL has measured baseline/mutants but not every directed scenario separately witnessed
