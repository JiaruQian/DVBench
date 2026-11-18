# Native ports and parameters

Complete module fpnew_fma; clock clk_i, active-low asynchronous register reset rst_ni. default_logic/original_comb have no registers; original_pipe2 has two stages, with reset behavior specified in the spec.

Native parameters: FpFormat is a 3-bit enum, 0 FP32, 1 FP64, 2 FP16, 3 FP8, 4 FP16ALT; NumPipeRegs is unsigned int; PipeConfig is an enum with BEFORE=0, AFTER=1, INSIDE=2, DISTRIBUTED=3; TagType/AuxType are type parameters. The three configurations in this task are default_logic=FP32/0/BEFORE/logic/logic, original_comb=FP32/0/BEFORE/logic[3:0]/logic[1:0], and original_pipe2=FP32/2/DISTRIBUTED/logic[3:0]/logic[1:0]; each instance is compiled with its fixed configuration. Derived localparam WIDTH=32; ExtRegEnaWidth=max(NumPipeRegs,1), which cannot be overridden. Native enums are provided by the maintained compilation side; the model may use logic vector ports of equal width.

|Port|Direction|Width and packed indices|
|---|---|---|
|clk_i|input|1 |
|rst_ni|input|1 |
|operands_i|input|96 [2:0][31:0]|
|is_boxed_i|input|3 [2:0]|
|rnd_mode_i|input|3 [2:0]|
|op_i|input|4 [3:0]|
|op_mod_i|input|1 |
|tag_i|input|1 |
|mask_i|input|1 |
|aux_i|input|1 |
|in_valid_i|input|1 |
|flush_i|input|1 |
|out_ready_i|input|1 |
|reg_ena_i|input|1 [0:0]|
|result_o|output|32 [31:0]|
|status_o|output|5 [4:0]|
|extension_bit_o|output|1 |
|tag_o|output|1 |
|mask_o|output|1 |
|aux_o|output|1 |
|out_valid_o|output|1 |
|in_ready_o|output|1 |
|busy_o|output|1 |

The rightmost 32 bits of operands_i are [0], followed in order by [1] and [2]. status_o[4:0]={NV,DZ,OF,UF,NX}. The model name is dvbench_model, using native ports with the same names and fixed parameters; the DUT must not be instantiated as the model.

## Two wide-sideband configurations from the source

For original_comb and original_pipe2, tag_i/tag_o are 4 bits [3:0], and aux_i/aux_o are 2 bits [1:0]; reg_ena_i for original_pipe2 is 2 bits [1:0], while original_comb remains [0:0]. Other port widths are the same as in the table. Declarations for other formats/register counts in the DUT's native parameters are retained; the current answer must implement the three profiles above, and unlisted combinations are not in this version's dynamic scoring domain.
