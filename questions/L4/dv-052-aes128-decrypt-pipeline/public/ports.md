# Interface Contract

Module `TOPpipelined`; the parameters for this problem are fixed, with no adjustable parameters.

|Port|Direction|Width|Index|
|---|---|---|---|
|ciphertext|input|128|[127:0]|
|key10|input|128|[127:0]|
|rst|input|1|Scalar|
|clk|input|1|Scalar|
|plaintext|output|128|[127:0]|
