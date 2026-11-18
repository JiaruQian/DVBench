# Native interface

Top `FetchTargetQueue`, no top parameters. All packed indices descend to zero.

|Port|Direction|Width|
|---|---|---:|
|`clock`|In|1|
|`reset`|In|1|
|`io_enq_ready`|Out|1|
|`io_enq_valid`|In|1|
|`io_enq_bits_pc`|In|40|
|`io_enq_bits_cfi_idx_valid`|In|1|
|`io_enq_bits_cfi_idx_bits`|In|3|
|`io_enq_bits_cfi_type`|In|3|
|`io_enq_bits_cfi_is_call`|In|1|
|`io_enq_bits_cfi_is_ret`|In|1|
|`io_enq_bits_ras_top`|In|40|
|`io_enq_bits_mask`|In|8|
|`io_enq_bits_br_mask`|In|8|
|`io_enq_bits_ghist_old_history`|In|64|
|`io_enq_bits_ghist_current_saw_branch_not_taken`|In|1|
|`io_enq_bits_ghist_new_saw_branch_not_taken`|In|1|
|`io_enq_bits_ghist_new_saw_branch_taken`|In|1|
|`io_enq_bits_ghist_ras_idx`|In|5|
|`io_enq_bits_bpd_meta_0`|In|120|
|`io_enq_bits_bpd_meta_1`|In|120|
|`io_enq_idx`|Out|6|
|`io_deq_valid`|In|1|
|`io_deq_bits`|In|6|
|`io_get_ftq_pc_0_ftq_idx`|In|6|
|`io_get_ftq_pc_0_entry_cfi_idx_valid`|Out|1|
|`io_get_ftq_pc_0_entry_cfi_idx_bits`|Out|3|
|`io_get_ftq_pc_0_entry_ras_idx`|Out|5|
|`io_get_ftq_pc_0_entry_start_bank`|Out|1|
|`io_get_ftq_pc_0_pc`|Out|40|
|`io_get_ftq_pc_0_com_pc`|Out|40|
|`io_get_ftq_pc_0_next_val`|Out|1|
|`io_get_ftq_pc_0_next_pc`|Out|40|
|`io_get_ftq_pc_1_ftq_idx`|In|6|
|`io_get_ftq_pc_1_entry_cfi_idx_bits`|Out|3|
|`io_get_ftq_pc_1_entry_br_mask`|Out|8|
|`io_get_ftq_pc_1_entry_cfi_is_call`|Out|1|
|`io_get_ftq_pc_1_entry_cfi_is_ret`|Out|1|
|`io_get_ftq_pc_1_entry_start_bank`|Out|1|
|`io_get_ftq_pc_1_ghist_old_history`|Out|64|
|`io_get_ftq_pc_1_ghist_current_saw_branch_not_taken`|Out|1|
|`io_get_ftq_pc_1_ghist_new_saw_branch_not_taken`|Out|1|
|`io_get_ftq_pc_1_ghist_new_saw_branch_taken`|Out|1|
|`io_get_ftq_pc_1_ghist_ras_idx`|Out|5|
|`io_get_ftq_pc_1_pc`|Out|40|
|`io_redirect_valid`|In|1|
|`io_redirect_bits`|In|6|
|`io_brupdate_b2_uop_ftq_idx`|In|6|
|`io_brupdate_b2_uop_pc_lob`|In|6|
|`io_brupdate_b2_mispredict`|In|1|
|`io_brupdate_b2_taken`|In|1|
|`io_bpdupdate_valid`|Out|1|
|`io_bpdupdate_bits_is_mispredict_update`|Out|1|
|`io_bpdupdate_bits_is_repair_update`|Out|1|
|`io_bpdupdate_bits_pc`|Out|40|
|`io_bpdupdate_bits_br_mask`|Out|8|
|`io_bpdupdate_bits_cfi_idx_valid`|Out|1|
|`io_bpdupdate_bits_cfi_idx_bits`|Out|3|
|`io_bpdupdate_bits_cfi_taken`|Out|1|
|`io_bpdupdate_bits_cfi_mispredicted`|Out|1|
|`io_bpdupdate_bits_cfi_is_br`|Out|1|
|`io_bpdupdate_bits_cfi_is_jal`|Out|1|
|`io_bpdupdate_bits_ghist_old_history`|Out|64|
|`io_bpdupdate_bits_ghist_new_saw_branch_not_taken`|Out|1|
|`io_bpdupdate_bits_ghist_new_saw_branch_taken`|Out|1|
|`io_bpdupdate_bits_target`|Out|40|
|`io_bpdupdate_bits_meta_0`|Out|120|
|`io_bpdupdate_bits_meta_1`|Out|120|
|`io_ras_update`|Out|1|
|`io_ras_update_idx`|Out|5|
|`io_ras_update_pc`|Out|40|

## Exact native index ranges

- `io_bpdupdate_bits_br_mask`: packed `[7:0]`
- `io_bpdupdate_bits_cfi_idx_bits`: packed `[2:0]`
- `io_bpdupdate_bits_ghist_old_history`: packed `[63:0]`
- `io_bpdupdate_bits_meta_0`: packed `[119:0]`
- `io_bpdupdate_bits_meta_1`: packed `[119:0]`
- `io_bpdupdate_bits_pc`: packed `[39:0]`
- `io_bpdupdate_bits_target`: packed `[39:0]`
- `io_brupdate_b2_uop_ftq_idx`: packed `[5:0]`
- `io_brupdate_b2_uop_pc_lob`: packed `[5:0]`
- `io_deq_bits`: packed `[5:0]`
- `io_enq_bits_bpd_meta_0`: packed `[119:0]`
- `io_enq_bits_bpd_meta_1`: packed `[119:0]`
- `io_enq_bits_br_mask`: packed `[7:0]`
- `io_enq_bits_cfi_idx_bits`: packed `[2:0]`
- `io_enq_bits_cfi_type`: packed `[2:0]`
- `io_enq_bits_ghist_old_history`: packed `[63:0]`
- `io_enq_bits_ghist_ras_idx`: packed `[4:0]`
- `io_enq_bits_mask`: packed `[7:0]`
- `io_enq_bits_pc`: packed `[39:0]`
- `io_enq_bits_ras_top`: packed `[39:0]`
- `io_enq_idx`: packed `[5:0]`
- `io_get_ftq_pc_0_com_pc`: packed `[39:0]`
- `io_get_ftq_pc_0_entry_cfi_idx_bits`: packed `[2:0]`
- `io_get_ftq_pc_0_entry_ras_idx`: packed `[4:0]`
- `io_get_ftq_pc_0_ftq_idx`: packed `[5:0]`
- `io_get_ftq_pc_0_next_pc`: packed `[39:0]`
- `io_get_ftq_pc_0_pc`: packed `[39:0]`
- `io_get_ftq_pc_1_entry_br_mask`: packed `[7:0]`
- `io_get_ftq_pc_1_entry_cfi_idx_bits`: packed `[2:0]`
- `io_get_ftq_pc_1_ftq_idx`: packed `[5:0]`
- `io_get_ftq_pc_1_ghist_old_history`: packed `[63:0]`
- `io_get_ftq_pc_1_ghist_ras_idx`: packed `[4:0]`
- `io_get_ftq_pc_1_pc`: packed `[39:0]`
- `io_ras_update_idx`: packed `[4:0]`
- `io_ras_update_pc`: packed `[39:0]`
- `io_redirect_bits`: packed `[5:0]`
