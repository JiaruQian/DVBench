# Native Interface

Top level: `Decryption`. This module has no parameters. All multi-bit ports are descending packed bit vectors; the table below gives their complete declared ranges. Scalar `clk` has no packed index. See spec.md for legal input values and complete behavior.

|Port|Direction|Declared range|Bit width|Purpose|
|---|---|---|---:|---|
|`in`|input|`[127:0]`|128|Ciphertext/first-round data input|
|`Key`|input|`[255:0]`|256|Key input|
|`counter`|input|`[5:0]`|6|External round number|
|`clk`|input|Scalar|1|State-update clock|
|`out`|output|`[127:0]`|128|Combinational output|
|`maxRound`|input|`[5:0]`|6|Round-count and key-length selection code|
