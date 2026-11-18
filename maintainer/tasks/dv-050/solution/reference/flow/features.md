# features

## F01
feature_id: F01
requirement_ids: ['R-3b4ee4883dca-001']
module: sha256_core
definition: reset_n is an active-low asynchronous reset. Upon assertion, without waiting for a clk edge, ready=1, digest=0, and digest_valid=0, and the block being processed is canceled. Deasserting reset does not start computation.
interface: ['clk', 'reset_n', 'ready', 'digest', 'digest_valid']
timing: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sampling occurs 1ns after rising-edge NBA and combinational propagation have completed. Asynchronous reset and combinational reads are additionally sampled between edges after being stable for 1ns. The input-history predictor is driven only by reset, stimulus, and prior inputs, and does not read DUT outputs.
boundary: Fixed native interface, known 0/1 inputs; the digest is handled as a full 256-bit value.

## F02
feature_id: F02
requirement_ids: ['R-3b4ee4883dca-002']
module: sha256_core
definition: init or next is accepted only on a rising edge of clk when ready=1. Denote the acceptance edge by n; the entire block at that time is captured, after which ready=0 and digest_valid=0. When init and next are both 1, it is handled as init.
interface: ['clk', 'reset_n', 'init', 'next', 'mode', 'block', 'ready', 'digest_valid']
timing: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sampling occurs 1ns after rising-edge NBA and combinational propagation have completed. Asynchronous reset and combinational reads are additionally sampled between edges after being stable for 1ns. The input-history predictor is driven only by reset, stimulus, and prior inputs, and does not read DUT outputs.
boundary: Fixed native interface, known 0/1 inputs; the digest is handled as a full 256-bit value.

## F03
feature_id: F03
requirement_ids: ['R-3b4ee4883dca-003']
module: sha256_core
definition: All operations use 32-bit unsigned arithmetic modulo 2^32. Each 512-bit input block is divided into W[0..15], most significant word first. For t=16..63, W[t]=W[t-16]+σ0(W[t-15])+W[t-7]+σ1(W[t-2]), where σ0(x)=ROTR7(x) XOR ROTR18(x) XOR SHR3(x) and σ1(x)=ROTR17(x) XOR ROTR19(x) XOR SHR10(x). Initialize a..h from the current eight-word chaining value; in each of 64 rounds, use T1=h+Σ1(e)+Ch(e,f,g)+K[t]+W[t] and T2=Σ0(a)+Maj(a,b,c), and update (a,b,c,d,e,f,g,h)=(T1+T2,a,b,c,d+T1,e,f,g). Σ0 is ROTR2 XOR ROTR13 XOR ROTR22, Σ1 is ROTR6 XOR ROTR11 XOR ROTR25, Ch=(e AND f) XOR ((NOT e) AND g), and Maj=(a AND b) XOR (a AND c) XOR (b AND c). K[t] consists of the 64 constants from the SHA-256 standard, namely the fractional parts of the cube roots of the first 64 primes multiplied by 2^32 and rounded down. The result is the eight input chaining words respectively added to a..h after 64 rounds, with H0 occupying the most significant 32 bits. The initial eight words for SHA-256 are 6a09e667 bb67ae85 3c6ef372 a54ff53a 510e527f 9b05688c 1f83d9ab 5be0cd19; the initial eight words for SHA-224 are c1059ed8 367cd507 3070dd17 f70e5939 ffc00b31 68581511 64f98fa7 befa4fa4. The full 256-bit chaining value is output here, and SHA-224 also retains the eighth word; the module does not generate padding, length encoding, or external byte-order conversion.
interface: ['clk', 'block', 'mode', 'init', 'next', 'digest']
timing: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sampling occurs 1ns after rising-edge NBA and combinational propagation have completed. Asynchronous reset and combinational reads are additionally sampled between edges after being stable for 1ns. The input-history predictor is driven only by reset, stimulus, and prior inputs, and does not read DUT outputs.
boundary: Fixed native interface, known 0/1 inputs; the digest is handled as a full 256-bit value.

## F04
feature_id: F04
requirement_ids: ['R-3b4ee4883dca-004']
module: sha256_core
definition: When init is accepted, mode selects the initial chaining value for SHA-256(mode=1) or SHA-224(mode=0), and this eight-word initial value is immediately displayed on digest. next uses the previous full 256-bit digest as the input chaining value for the new block, without reinitialization; changes to mode do not change the chaining input for next. A next directly after reset starts from an all-0 chaining value.
interface: ['clk', 'reset_n', 'init', 'next', 'mode', 'block', 'digest']
timing: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sampling occurs 1ns after rising-edge NBA and combinational propagation have completed. Asynchronous reset and combinational reads are additionally sampled between edges after being stable for 1ns. The input-history predictor is driven only by reset, stimulus, and prior inputs, and does not read DUT outputs.
boundary: Fixed native interface, known 0/1 inputs; the digest is handled as a full 256-bit value.

## F05
feature_id: F05
requirement_ids: ['R-3b4ee4883dca-005']
module: sha256_core
definition: The 65th rising edge after acceptance edge n (n+65) updates digest to the final compression value, with ready=1 and digest_valid=1 at the same time. It remains busy from n+1 through n+64, without early completion; during computation, digest retains the chaining value at acceptance. digest_valid remains 1 until the next valid command or reset; digest is retained while idle.
interface: ['clk', 'init', 'next', 'ready', 'digest', 'digest_valid']
timing: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sampling occurs 1ns after rising-edge NBA and combinational propagation have completed. Asynchronous reset and combinational reads are additionally sampled between edges after being stable for 1ns. The input-history predictor is driven only by reset, stimulus, and prior inputs, and does not read DUT outputs.
boundary: Fixed native interface, known 0/1 inputs; the digest is handled as a full 256-bit value.

## F06
feature_id: F06
requirement_ids: ['R-3b4ee4883dca-006']
module: sha256_core
definition: init/next and changes to mode/block while ready=0 do not change the result of the accepted block and are not queued. It is still busy before completion edge n+65, and commands on that edge are not accepted; if a command is still valid on the next rising edge, it is accepted.
interface: ['clk', 'init', 'next', 'mode', 'block', 'ready', 'digest', 'digest_valid']
timing: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sampling occurs 1ns after rising-edge NBA and combinational propagation have completed. Asynchronous reset and combinational reads are additionally sampled between edges after being stable for 1ns. The input-history predictor is driven only by reset, stimulus, and prior inputs, and does not read DUT outputs.
boundary: Fixed native interface, known 0/1 inputs; the digest is handled as a full 256-bit value.

## F07
feature_id: F07
requirement_ids: ['R-3b4ee4883dca-007']
module: sha256_core
definition: When init or next remains 1, an operation is restarted on every rising edge at which it is idle; there is no additional pulse deduplication or queue. All 512 bits of block participate in the computation, and mode selects the initial vector only when init is accepted. All port inputs use known 0/1 values, with a fixed native interface and no externally overridable parameters.
interface: ['clk', 'reset_n', 'init', 'next', 'mode', 'block', 'ready', 'digest', 'digest_valid']
timing: Stimulus is stable after the falling edge of clk, and writes/commands are stable before the rising edge; sampling occurs 1ns after rising-edge NBA and combinational propagation have completed. Asynchronous reset and combinational reads are additionally sampled between edges after being stable for 1ns. The input-history predictor is driven only by reset, stimulus, and prior inputs, and does not read DUT outputs.
boundary: Fixed native interface, known 0/1 inputs; the digest is handled as a full 256-bit value.
