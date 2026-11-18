# Native interface

Top `BIMBranchPredictorBank`, no top parameters. All packed indices descend to zero.

|Port|Direction|Width|
|---|---|---:|
|`clock`|In|1|
|`reset`|In|1|
|`io_f0_valid`|In|1|
|`io_f0_pc`|In|40|
|`io_resp_in_0_f1_0_taken`|In|1|
|`io_resp_in_0_f1_0_is_br`|In|1|
|`io_resp_in_0_f1_0_is_jal`|In|1|
|`io_resp_in_0_f1_0_predicted_pc_valid`|In|1|
|`io_resp_in_0_f1_0_predicted_pc_bits`|In|40|
|`io_resp_in_0_f1_1_taken`|In|1|
|`io_resp_in_0_f1_1_is_br`|In|1|
|`io_resp_in_0_f1_1_is_jal`|In|1|
|`io_resp_in_0_f1_1_predicted_pc_valid`|In|1|
|`io_resp_in_0_f1_1_predicted_pc_bits`|In|40|
|`io_resp_in_0_f1_2_taken`|In|1|
|`io_resp_in_0_f1_2_is_br`|In|1|
|`io_resp_in_0_f1_2_is_jal`|In|1|
|`io_resp_in_0_f1_2_predicted_pc_valid`|In|1|
|`io_resp_in_0_f1_2_predicted_pc_bits`|In|40|
|`io_resp_in_0_f1_3_taken`|In|1|
|`io_resp_in_0_f1_3_is_br`|In|1|
|`io_resp_in_0_f1_3_is_jal`|In|1|
|`io_resp_in_0_f1_3_predicted_pc_valid`|In|1|
|`io_resp_in_0_f1_3_predicted_pc_bits`|In|40|
|`io_resp_in_0_f2_0_is_br`|In|1|
|`io_resp_in_0_f2_0_is_jal`|In|1|
|`io_resp_in_0_f2_0_predicted_pc_valid`|In|1|
|`io_resp_in_0_f2_0_predicted_pc_bits`|In|40|
|`io_resp_in_0_f2_1_is_br`|In|1|
|`io_resp_in_0_f2_1_is_jal`|In|1|
|`io_resp_in_0_f2_1_predicted_pc_valid`|In|1|
|`io_resp_in_0_f2_1_predicted_pc_bits`|In|40|
|`io_resp_in_0_f2_2_is_br`|In|1|
|`io_resp_in_0_f2_2_is_jal`|In|1|
|`io_resp_in_0_f2_2_predicted_pc_valid`|In|1|
|`io_resp_in_0_f2_2_predicted_pc_bits`|In|40|
|`io_resp_in_0_f2_3_is_br`|In|1|
|`io_resp_in_0_f2_3_is_jal`|In|1|
|`io_resp_in_0_f2_3_predicted_pc_valid`|In|1|
|`io_resp_in_0_f2_3_predicted_pc_bits`|In|40|
|`io_resp_in_0_f3_0_is_br`|In|1|
|`io_resp_in_0_f3_0_is_jal`|In|1|
|`io_resp_in_0_f3_0_predicted_pc_valid`|In|1|
|`io_resp_in_0_f3_0_predicted_pc_bits`|In|40|
|`io_resp_in_0_f3_1_is_br`|In|1|
|`io_resp_in_0_f3_1_is_jal`|In|1|
|`io_resp_in_0_f3_1_predicted_pc_valid`|In|1|
|`io_resp_in_0_f3_1_predicted_pc_bits`|In|40|
|`io_resp_in_0_f3_2_is_br`|In|1|
|`io_resp_in_0_f3_2_is_jal`|In|1|
|`io_resp_in_0_f3_2_predicted_pc_valid`|In|1|
|`io_resp_in_0_f3_2_predicted_pc_bits`|In|40|
|`io_resp_in_0_f3_3_is_br`|In|1|
|`io_resp_in_0_f3_3_is_jal`|In|1|
|`io_resp_in_0_f3_3_predicted_pc_valid`|In|1|
|`io_resp_in_0_f3_3_predicted_pc_bits`|In|40|
|`io_resp_f1_0_taken`|Out|1|
|`io_resp_f1_0_is_br`|Out|1|
|`io_resp_f1_0_is_jal`|Out|1|
|`io_resp_f1_0_predicted_pc_valid`|Out|1|
|`io_resp_f1_0_predicted_pc_bits`|Out|40|
|`io_resp_f1_1_taken`|Out|1|
|`io_resp_f1_1_is_br`|Out|1|
|`io_resp_f1_1_is_jal`|Out|1|
|`io_resp_f1_1_predicted_pc_valid`|Out|1|
|`io_resp_f1_1_predicted_pc_bits`|Out|40|
|`io_resp_f1_2_taken`|Out|1|
|`io_resp_f1_2_is_br`|Out|1|
|`io_resp_f1_2_is_jal`|Out|1|
|`io_resp_f1_2_predicted_pc_valid`|Out|1|
|`io_resp_f1_2_predicted_pc_bits`|Out|40|
|`io_resp_f1_3_taken`|Out|1|
|`io_resp_f1_3_is_br`|Out|1|
|`io_resp_f1_3_is_jal`|Out|1|
|`io_resp_f1_3_predicted_pc_valid`|Out|1|
|`io_resp_f1_3_predicted_pc_bits`|Out|40|
|`io_resp_f2_0_taken`|Out|1|
|`io_resp_f2_0_is_br`|Out|1|
|`io_resp_f2_0_is_jal`|Out|1|
|`io_resp_f2_0_predicted_pc_valid`|Out|1|
|`io_resp_f2_0_predicted_pc_bits`|Out|40|
|`io_resp_f2_1_taken`|Out|1|
|`io_resp_f2_1_is_br`|Out|1|
|`io_resp_f2_1_is_jal`|Out|1|
|`io_resp_f2_1_predicted_pc_valid`|Out|1|
|`io_resp_f2_1_predicted_pc_bits`|Out|40|
|`io_resp_f2_2_taken`|Out|1|
|`io_resp_f2_2_is_br`|Out|1|
|`io_resp_f2_2_is_jal`|Out|1|
|`io_resp_f2_2_predicted_pc_valid`|Out|1|
|`io_resp_f2_2_predicted_pc_bits`|Out|40|
|`io_resp_f2_3_taken`|Out|1|
|`io_resp_f2_3_is_br`|Out|1|
|`io_resp_f2_3_is_jal`|Out|1|
|`io_resp_f2_3_predicted_pc_valid`|Out|1|
|`io_resp_f2_3_predicted_pc_bits`|Out|40|
|`io_resp_f3_0_taken`|Out|1|
|`io_resp_f3_0_is_br`|Out|1|
|`io_resp_f3_0_is_jal`|Out|1|
|`io_resp_f3_0_predicted_pc_valid`|Out|1|
|`io_resp_f3_0_predicted_pc_bits`|Out|40|
|`io_resp_f3_1_taken`|Out|1|
|`io_resp_f3_1_is_br`|Out|1|
|`io_resp_f3_1_is_jal`|Out|1|
|`io_resp_f3_1_predicted_pc_valid`|Out|1|
|`io_resp_f3_1_predicted_pc_bits`|Out|40|
|`io_resp_f3_2_taken`|Out|1|
|`io_resp_f3_2_is_br`|Out|1|
|`io_resp_f3_2_is_jal`|Out|1|
|`io_resp_f3_2_predicted_pc_valid`|Out|1|
|`io_resp_f3_2_predicted_pc_bits`|Out|40|
|`io_resp_f3_3_taken`|Out|1|
|`io_resp_f3_3_is_br`|Out|1|
|`io_resp_f3_3_is_jal`|Out|1|
|`io_resp_f3_3_predicted_pc_valid`|Out|1|
|`io_resp_f3_3_predicted_pc_bits`|Out|40|
|`io_f3_meta`|Out|120|
|`io_update_valid`|In|1|
|`io_update_bits_is_mispredict_update`|In|1|
|`io_update_bits_is_repair_update`|In|1|
|`io_update_bits_btb_mispredicts`|In|4|
|`io_update_bits_pc`|In|40|
|`io_update_bits_br_mask`|In|4|
|`io_update_bits_cfi_idx_valid`|In|1|
|`io_update_bits_cfi_idx_bits`|In|2|
|`io_update_bits_cfi_taken`|In|1|
|`io_update_bits_cfi_is_br`|In|1|
|`io_update_bits_cfi_is_jal`|In|1|
|`io_update_bits_meta`|In|120|

## Exact native index ranges

- `io_f0_pc`: packed `[39:0]`
- `io_f3_meta`: packed `[119:0]`
- `io_resp_f1_0_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f1_1_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f1_2_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f1_3_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f2_0_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f2_1_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f2_2_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f2_3_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f3_0_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f3_1_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f3_2_predicted_pc_bits`: packed `[39:0]`
- `io_resp_f3_3_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f1_0_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f1_1_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f1_2_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f1_3_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f2_0_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f2_1_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f2_2_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f2_3_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f3_0_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f3_1_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f3_2_predicted_pc_bits`: packed `[39:0]`
- `io_resp_in_0_f3_3_predicted_pc_bits`: packed `[39:0]`
- `io_update_bits_br_mask`: packed `[3:0]`
- `io_update_bits_btb_mispredicts`: packed `[3:0]`
- `io_update_bits_cfi_idx_bits`: packed `[1:0]`
- `io_update_bits_meta`: packed `[119:0]`
- `io_update_bits_pc`: packed `[39:0]`
