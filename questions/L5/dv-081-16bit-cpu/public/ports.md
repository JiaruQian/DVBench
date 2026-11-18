# Native Interface

Top level `Top`; independent model top level `dvbench_model`.

|Port|Direction|Bit Width|Packed Indices|
|---|---|---:|---|
|clk|In|1||
|input_data|In|32|[31:0]|
|result_data|Out|32|[31:0]|
|result_valid|Out|1||
|rst|In|1||

Parameter defaults: {"PROGRAM_FILE": "88'h70726f6772616d2e6d656d"}. See spec.md for the legal parameter domain and semantics; port widths or directions must not be changed.
