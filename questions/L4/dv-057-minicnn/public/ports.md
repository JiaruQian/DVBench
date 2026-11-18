# Native Interface

Top level `CNN`; independent model top level `dvbench_model`.

|Port|Direction|Bit Width|Packed Indices|
|---|---|---:|---|
|clk|In|1||
|en|In|1||
|float_out0|Out|32|[31:0]|
|float_out1|Out|32|[31:0]|
|mem|In|2400|[0:2399]|
|rst_b|In|1||
|valid|Out|1||

Parameter defaults: {}. See spec.md for the legal parameter domain and semantics; port widths or directions must not be changed.
