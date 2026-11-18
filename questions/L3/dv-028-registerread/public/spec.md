# RegisterRead behavioral specification

The complete original native root and all listed dependencies are in scope.

### R-dv-028-001 — Native timing and pipeline scope

RegisterRead has two issue lanes and two synchronous pipeline stages, six external register-file read ports, no top parameters and no backpressure. All native input bits are legal two-state values. At each rising edge, a first stage captures current issue metadata and decoded controls. The second stage captures the previous first-stage contents. Numeric state before initialization is unspecified; establish known inputs over two rising edges before numerical state checks. Reset is synchronous active high and clears only the two execution valid outputs; it does not clear either metadata stage, operand data or register-file addresses. Combinational addresses and registered payload remain observable with valid low.

### R-dv-028-002 — Direct register-file addressing and sampled operand data

Read-port addresses 0/1/2 continuously equal lane 0 prs1/prs2/prs3; addresses 3/4/5 continuously equal lane 1 prs1/prs2/prs3, independently of valid, kill and reset. At each rising edge the execution operand data captures the current corresponding 65-bit external read data unless that operand's physical source index captured at the previous edge was zero, in which case it captures 65-bit zero. The zero-source flags depend solely on physical index equality to zero, not type, valid or lane. Kill/reset do not gate operand capture.

### R-dv-028-003 — First-stage issue capture and branch resolution

For each lane, the first-stage valid captures issue valid AND no overlap between the original current issue branch mask and current mispredict mask. It is updated even during reset and io_kill. The first-stage branch mask captures current issue mask with all current resolve-mask bits cleared; all other metadata is captured every edge regardless of valid. The two poison fields are generated as zero. Decoded control and immediate exceptions below replace their corresponding incoming fields.

### R-dv-028-004 — Second-stage cancellation and validity

For each lane independently, second-stage cancel is current io_kill OR an overlap of that lane's stored first-stage branch mask with the current mispredict mask. On the rising edge reset sets execution valid zero; otherwise execution valid captures previous first-stage valid AND no cancel. There is no cross-lane mask use. Misprediction is tested on the stored mask after the previous edge's resolution, so already resolved bits cannot later cancel through that stored bit.

### R-dv-028-005 — Cancelled metadata and branch-mask exception

At each rising edge, execution metadata takes the previous first-stage metadata when not cancelled. When cancelled every metadata field becomes zero except dst_rtype becomes numeric two and br_mask still equals the stored first-stage branch mask with current resolve bits cleared. This branch-mask update occurs even when cancelled, reset or invalid. Reset alone does not force metadata to the cancelled values. Poison fields remain zero once initialized. Operand data is independent of this metadata cancellation.

### R-dv-028-006 — Shared opcode decode and memory exceptions

The exact numeric shared decode table in the numeric decode table below defines br_type, op1_sel, op2_sel, imm_sel, op_fcn and fcn_dw for all 128 uopc values. csr_cmd is always zero. is_load is one only for uopc 1; is_sta only for uopc 2 or 67; is_std for uopc 3, or for uopc 2/67 with lrs2_rtype zero. The decoded immediate is zero for uopc 67 and for uopc 1 with mem_cmd six, otherwise it copies issue imm_packed. Other metadata fields pass to the first stage without opcode-dependent change. No architectural instruction legality restriction narrows the seven-bit opcode domain.

### R-dv-028-007 — Lane-specific function decode

Both lanes use the shared table except uopc 101,102,103,104: lane 0 op_fcn is 15 and lane 1 op_fcn is zero. All other decoded fields for those opcodes follow the shared default. This is an observable lane asymmetry, not an unsupported-domain omission. Both lanes accept the complete uopc 0..127 domain and can issue independently and simultaneously.

### R-dv-028-008 — Unconditional metadata preservation and lane independence

Every native metadata field not changed by the specified decode, immediate, branch-mask, poison or cancellation rules is forwarded exactly through both stages, including every declared high bit. Execution output metadata therefore corresponds to issue inputs sampled one edge earlier, while operand data uses current RF input data and one-edge-old zero-source flags. Changes in issue valid do not freeze metadata. One lane's issue contents, source indices or cancellation mask cannot alter the other lane's metadata or operands; shared global kill and branch updates apply by their stated per-lane rules.


# Numeric decode behavior

All uopc values are decimal. The table lists the shared values in the order br_type, op1_sel, op2_sel, imm_sel, op_fcn, fcn_dw. Fields are numeric values, not architecture names. Lane 1 differs only as explicitly stated.

|uopc|br_type|op1_sel|op2_sel|imm_sel|op_fcn lane 0|fcn_dw|op_fcn lane 1|
|---:|---:|---:|---:|---:|---:|---:|---:|
|0|0|0|1|0|0|1|0|
|1|0|0|1|0|0|1|0|
|2|0|0|1|0|0|1|0|
|3|0|0|1|0|0|1|0|
|4|0|1|1|3|0|1|0|
|5|0|0|1|0|0|1|0|
|6|0|0|1|0|7|1|7|
|7|0|0|1|0|6|1|6|
|8|0|0|1|0|4|1|4|
|9|0|0|1|0|12|1|12|
|10|0|0|1|0|14|1|14|
|11|0|0|1|0|1|1|1|
|12|0|0|1|0|11|1|11|
|13|0|0|1|0|5|1|5|
|14|0|0|0|0|1|1|1|
|15|0|0|0|0|0|1|0|
|16|0|0|0|2|10|1|10|
|17|0|0|0|2|12|1|12|
|18|0|0|0|2|14|1|14|
|19|0|0|0|2|7|1|7|
|20|0|0|0|2|6|1|6|
|21|0|0|0|2|4|1|4|
|22|0|0|0|2|11|1|11|
|23|0|0|0|2|5|1|5|
|24|2|0|0|2|10|1|10|
|25|1|0|0|2|10|1|10|
|26|3|0|0|2|12|1|12|
|27|4|0|0|2|14|1|14|
|28|5|0|0|2|12|1|12|
|29|6|0|0|2|14|1|14|
|30|0|0|0|2|0|1|0|
|31|0|0|0|2|0|1|0|
|32|0|0|0|0|0|1|0|
|33|0|0|0|0|0|1|0|
|34|0|0|0|0|0|1|0|
|35|0|0|0|0|0|1|0|
|36|0|0|0|0|0|1|0|
|37|0|0|0|0|0|1|0|
|38|0|0|0|0|0|1|0|
|39|0|0|0|0|0|1|0|
|40|0|0|0|0|0|1|0|
|41|0|0|1|0|0|1|0|
|42|0|0|0|0|0|1|0|
|43|0|0|1|0|0|0|0|
|44|0|0|0|0|0|0|0|
|45|0|0|0|0|10|0|10|
|46|0|0|1|0|1|0|1|
|47|0|0|0|0|1|0|1|
|48|0|0|1|0|11|0|11|
|49|0|0|0|0|11|0|11|
|50|0|0|1|0|5|0|5|
|51|0|0|0|0|5|0|5|
|52|0|0|0|0|0|1|0|
|53|0|0|0|0|0|1|0|
|54|0|0|0|0|0|1|0|
|55|0|0|0|0|0|1|0|
|56|0|0|0|0|0|1|0|
|57|0|0|0|0|0|1|0|
|58|0|0|0|0|0|1|0|
|59|0|0|0|0|0|1|0|
|60|0|0|0|0|0|1|0|
|61|0|0|0|0|0|1|0|
|62|0|0|0|0|0|1|0|
|63|0|0|0|0|0|1|0|
|64|0|0|0|0|0|1|0|
|65|0|0|0|0|0|1|0|
|66|0|0|0|0|0|1|0|
|67|0|0|0|0|0|1|0|
|68|0|0|0|0|0|1|0|
|69|0|0|0|0|0|1|0|
|70|0|0|0|0|15|1|15|
|71|0|0|0|0|15|1|15|
|72|0|0|0|0|15|1|15|
|73|0|0|0|0|15|1|15|
|74|0|0|0|0|15|1|15|
|75|0|0|0|0|15|1|15|
|76|0|0|0|0|15|1|15|
|77|0|0|0|0|15|1|15|
|78|0|0|0|0|15|1|15|
|79|0|0|0|0|15|1|15|
|80|0|0|0|0|15|1|15|
|81|0|0|0|0|15|1|15|
|82|0|0|0|0|15|1|15|
|83|0|0|0|0|15|1|15|
|84|0|0|0|0|15|1|15|
|85|0|0|0|0|15|1|15|
|86|0|0|0|0|0|1|0|
|87|0|0|0|0|15|1|15|
|88|0|0|0|0|15|1|15|
|89|0|0|0|0|15|1|15|
|90|0|0|0|0|15|1|15|
|91|0|0|0|0|15|1|15|
|92|0|0|0|0|15|1|15|
|93|0|0|0|0|15|1|15|
|94|0|0|0|0|15|1|15|
|95|0|0|0|0|15|1|15|
|96|0|0|0|0|15|1|15|
|97|0|0|0|0|15|1|15|
|98|0|0|0|0|15|1|15|
|99|0|0|0|0|15|1|15|
|100|0|0|0|0|15|1|15|
|101|0|0|0|0|15|1|0|
|102|0|0|0|0|15|1|0|
|103|0|0|0|0|15|1|0|
|104|0|0|0|0|15|1|0|
|105|0|0|0|0|0|1|0|
|106|0|0|0|0|0|1|0|
|107|0|0|0|0|0|1|0|
|108|0|0|0|0|0|1|0|
|109|0|0|0|0|0|1|0|
|110|0|0|0|0|0|1|0|
|111|0|0|0|0|0|1|0|
|112|0|0|0|0|0|1|0|
|113|0|0|0|0|0|1|0|
|114|0|0|0|0|0|1|0|
|115|0|0|0|0|0|1|0|
|116|0|0|0|0|0|1|0|
|117|0|0|0|0|0|1|0|
|118|0|0|0|0|0|1|0|
|119|0|0|0|0|0|1|0|
|120|0|0|0|0|0|1|0|
|121|0|0|0|0|0|1|0|
|122|0|0|0|0|0|1|0|
|123|0|0|0|0|0|1|0|
|124|0|0|0|0|0|1|0|
|125|0|0|0|0|0|1|0|
|126|0|0|0|0|0|1|0|
|127|0|0|0|0|0|1|0|
