## F-106-001

requirement_ids: R-N106-001

module: DES_core

definition: Operates on the rising edge of clk; rst_n is asynchronous and active-low. Reset immediately sets desc_ready=1 and cancels unfinished operations. desc_result has no reset guarantee; interpret the result only after a complete operation finishes following the current reset and during the subsequent idle period; do not check the result between starting a new operation and completion. Inputs are definite 0/1 values, established before the edge; separate the reset response between edges from stable observations after the edge.

interface: clk, rst_n, desc_ready, desc_result

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-106-002

requirement_ids: R-N106-002

module: DES_core

definition: In the idle state with desc_ready=1, assert only one of des_encipher_en or des_decipher_en for one sampling edge, called cycle 1; afterward, both remain 0 until completion. Hold data and key from before the request until completion. On cycle 1 following the request, ready becomes 0; on cycle 18 for encryption or cycle 33 for decryption, ready returns to 1 and the final result is provided simultaneously. In idle, ready remains 1. Simultaneous requests, requests while busy, or holding a request for multiple cycles are prohibited and are outside the legal domain.

interface: clk, rst_n, des_encipher_en, des_decipher_en, des_data, des_key_in, desc_ready

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-106-003

requirement_ids: R-N106-003

module: DES_core

definition: des_data and des_key_in are both 64 bits, with the most significant bit corresponding to standard DES bit 1. Encryption uses standard DES (FIPS 46-3), with a 64-bit initial permutation, 16 Feistel rounds, and inverse permutation; key PC1 removes the parity bit of each byte, and circular left shifts by 1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1 generate 16 PC2 subkeys. The input to the final inverse permutation is R16 concatenated with L16. The standard vector 0123456789ABCDEF with key 133457799BBCDFF1 produces 85E813540F0AB405.

interface: des_data, des_key_in, des_encipher_en, desc_result, desc_ready

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-106-004

requirement_ids: R-N106-004

module: DES_core

definition: Decryption uses the same DES data transformation but uses the 16 subkeys in reverse order; the standard ciphertext 85E813540F0AB405 decrypts to 0123456789ABCDEF using 133457799BBCDFF1. The least significant bit of each byte is a key parity bit and does not contribute to the result; changing these bits does not change the result for the same direction; no parity checking or error reporting is performed.

interface: des_data, des_key_in, des_decipher_en, desc_result, desc_ready

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-106-005

requirement_ids: R-N106-005

module: DES_core

definition: After completion, if no new operation is started and no reset occurs, desc_result retains the final value; changing input data or the key while idle does not update this result. Each new legal request uses the data and key for that request; the direction, data, and key of previous transactions do not contaminate subsequent results.

interface: des_data, des_key_in, des_encipher_en, des_decipher_en, desc_ready, desc_result

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.
