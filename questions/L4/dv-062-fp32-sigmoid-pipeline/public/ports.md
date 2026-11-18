# Native interface and fixed parameters

The top level is fp32_sigmoid_pipeline; the model entry point is dvbench_model; preserve port names, directions, bit widths, and index directions.

|Port|Direction|Width|Index|
|---|---|---|---|
|clear_i|In|1|Scalar|
|clk_i|In|1|Scalar|
|data_i|In|32|[31:0]|
|invalid_i|In|1|Scalar|
|invalid_o|Out|1|Scalar|
|result_o|Out|32|[31:0]|
|rst_i|In|1|Scalar|
|valid_i|In|1|Scalar|
|valid_o|Out|1|Scalar|

## Native parameter defaults

- FTZ = 1'b0


## Fixed configuration for this task

FTZ=0 and FTZ=1 must both be covered; the two configurations may be instantiated within one dvbench_top, each connected to a parameterized model from the same model/model.sv and compared. The root sources.f contains the complete test.
