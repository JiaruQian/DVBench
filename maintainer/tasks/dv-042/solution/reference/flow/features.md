# Feature analysis

## F-01

There are eight independent warp CSR banks and one registered result entry. rst_n is asynchronous active-low. Assertion immediately empties the result entry, zeros all result payloads, every CSR state and every dispatch/base state. A pulse wholly between clock edges still clears this state. While reset is low no attempted operation or dispatch survives. in_ready_o remains the combinational expression (entry empty or out_ready_i) and not CTA2csr_valid_i, even in reset. On every released rising edge each bank forces mstatus MPP bits12:11 to3 and vtype to0x10; these fields are zero during reset. The internal vector capacity is zero until the first released edge, then four. A request accepted on that first edge observes the old zero values. Release reset away from rising clk edges.

Interfaces: clk, rst_n, ctrl_inst_i, ctrl_csr_i, ctrl_custom_signal_0_i, ctrl_isvec_i, ctrl_reg_idxw_i, ctrl_wxd_i, ctrl_wid_i, in_valid_i, out_ready_i, in1_i, rm_wid_i, lsu_wid_i, simt_wid_i, CTA2csr_valid_i, dispatch2cu_wg_wf_count_i, dispatch2cu_wf_size_dispatch_i, dispatch2cu_sgpr_base_dispatch_i, dispatch2cu_vgpr_base_dispatch_i, dispatch2cu_wf_tag_dispatch_i, dispatch2cu_lds_base_dispatch_i, dispatch2cu_pds_base_dispatch_i, dispatch2cu_csr_knl_dispatch_i, dispatch2cu_wgid_x_dispatch_i, dispatch2cu_wgid_y_dispatch_i, dispatch2cu_wgid_z_dispatch_i, dispatch2cu_wg_id_i, wid_i, in_ready_o, out_valid_o, wb_wxd_rd_o, wxd_o, reg_idxw_o, warp_id_o, rm_o, sgpr_base_o, vgpr_base_o, lsu_tid_o, lsu_pds_o, lsu_numw_o, simt_rpc_o

Timing: Rising-edge state capture; pre-edge CSR reads; asynchronous reset and combinational indexed queries.

Domain: Fixed8warps/4threads,32-bit values, all binary native field values legal, no other macro configuration or X/Z control domain.

## F-02

The result entry is available when empty or out_ready_i is one. in_ready_o is availability AND NOT CTA2csr_valid_i. Acceptance is in_valid_i AND in_ready_o at a rising edge. Every accepted operation captures one result regardless of ctrl_csr_i and ctrl_wxd_i; ctrl_wxd_i is metadata only. Old valid data consumes when out_ready_i is one, independently of dispatch. A full entry can consume and replace on one edge; the new result appears after that edge. No empty-entry combinational bypass exists. Dispatch blocks acceptance globally, even when its wid_i differs from ctrl_wid_i, but does not prevent consuming an old result. Rejected attempts have no CSR or result side effects. Payloads retain the last captured snapshot after the entry empties.

Interfaces: clk, rst_n, ctrl_inst_i, ctrl_csr_i, ctrl_custom_signal_0_i, ctrl_isvec_i, ctrl_reg_idxw_i, ctrl_wxd_i, ctrl_wid_i, in_valid_i, out_ready_i, in1_i, CTA2csr_valid_i, in_ready_o, out_valid_o, wb_wxd_rd_o, wxd_o, reg_idxw_o, warp_id_o

Timing: Rising-edge state capture; pre-edge CSR reads; asynchronous reset and combinational indexed queries.

Domain: Fixed8warps/4threads,32-bit values, all binary native field values legal, no other macro configuration or X/Z control domain.

## F-03

Only ctrl_inst_i bits31:20 select the twelve-bit CSR address. Read addresses are 0x300 mstatus,0x304 mie,0x305 mtvec,0x340 mscratch,0x341 mepc,0x342 mcause,0x343 mtval,0x344 mip,0x001 fflags,0x002 frm,0x003 fcsr,0xc21 vtype, and0x800..0x80c respectively threadid,wg_wf_count,wf_size,knl_base,wg_id,wf_tag,lds_base,pds_base,wg_id_x,wg_id_y,wg_id_z,print,rpc. Every other address reads zero and ignores ordinary writes, including other vector or machine CSRs. On an accepted operation, ctrl_csr_i0 reads without writing;1 writes in1_i;2 writes old CSR OR in1_i;3 writes old CSR AND NOT in1_i. Only the selected ctrl_wid_i bank changes. The normal returned result is the pre-edge read value even on a write. Read-only addresses and ignored writes still return their pre-edge read and generate a result.

Interfaces: clk, rst_n, ctrl_inst_i, ctrl_csr_i, ctrl_custom_signal_0_i, ctrl_isvec_i, ctrl_reg_idxw_i, ctrl_wxd_i, ctrl_wid_i, in_valid_i, out_ready_i, in1_i, CTA2csr_valid_i, in_ready_o, out_valid_o, wb_wxd_rd_o, wxd_o, reg_idxw_o, warp_id_o

Timing: Rising-edge state capture; pre-edge CSR reads; asynchronous reset and combinational indexed queries.

Domain: Fixed8warps/4threads,32-bit values, all binary native field values legal, no other macro configuration or X/Z control domain.

## F-04

mstatus stores only writable bits3 and7; after released edges bits12:11 are forced3 and all other bits remain zero. mie and mip store only bits3,7,11, all others zero. mscratch,mepc,mcause,mtval store all32bits. mtvec always reads zero and ignores writes. frm stores low3bits and fflags low5bits; fcsr reads (frm<<5)|fflags but fcsr writes are ignored. Ordinary write/set/clear use the old complete read value before applying these masks. print stores all32bits on ordinary writes except when the same accepted operation is custom; rpc ordinary writes are ignored. Dispatch metadata and vtype are read-only through the ordinary CSR path.

Interfaces: clk, rst_n, ctrl_inst_i, ctrl_csr_i, ctrl_custom_signal_0_i, ctrl_isvec_i, ctrl_reg_idxw_i, ctrl_wxd_i, ctrl_wid_i, in_valid_i, out_ready_i, in1_i, CTA2csr_valid_i, in_ready_o, out_valid_o, wb_wxd_rd_o, wxd_o, reg_idxw_o, warp_id_o, rm_wid_i, rm_o, simt_wid_i, simt_rpc_o

Timing: Rising-edge state capture; pre-edge CSR reads; asynchronous reset and combinational indexed queries.

Domain: Fixed8warps/4threads,32-bit values, all binary native field values legal, no other macro configuration or X/Z control domain.

## F-05

A side-effect-enabled operation means an accepted operation with ctrl_csr_i nonzero. For such an operation custom signal one has highest return priority: return in1_i and replace the selected bank RPC with the full in1_i, regardless of address and CSR op. The addressed ordinary writable CSR update still occurs using its own old-value write/set/clear rule, except custom suppresses print writes. Otherwise if ctrl_isvec_i is one, return unsigned min(in1_i,capacity), with capacity0 before the first released edge and4 afterwards. Vector mode does not suppress an addressed ordinary CSR update. With ctrl_csr_i zero, custom and vector flags neither change RPC nor select a special result: return the normal CSR read. With both custom and vector one, custom wins.

Interfaces: clk, rst_n, ctrl_inst_i, ctrl_csr_i, ctrl_custom_signal_0_i, ctrl_isvec_i, ctrl_reg_idxw_i, ctrl_wxd_i, ctrl_wid_i, in_valid_i, out_ready_i, in1_i, CTA2csr_valid_i, in_ready_o, out_valid_o, wb_wxd_rd_o, wxd_o, reg_idxw_o, warp_id_o, simt_wid_i, simt_rpc_o

Timing: Rising-edge state capture; pre-edge CSR reads; asynchronous reset and combinational indexed queries.

Domain: Fixed8warps/4threads,32-bit values, all binary native field values legal, no other macro configuration or X/Z control domain.

## F-06

At each rising edge with CTA2csr_valid_i one, the bank indexed by wid_i captures dispatch fields, independently of result ready/valid. threadid=low3 dispatch tag bits times4; stored wf_tag also retains only those low3bits despite the seven-bit input. wg_wf_count retains4bits, wf_size and each wgid coordinate retain10bits, knl_base,wg_id,pds_base retain32bits. lds_base is0x70000000 OR the eighteen-bit LDS input. SGPR and VGPR bases each retain11bits. Other banks remain unchanged; no ordinary CSR write can modify these dispatch fields. The complete eight scalar/vector base arrays are always visible, bank0 in the least significant11bits, bank7 in the most significant11bits.

Interfaces: clk, rst_n, CTA2csr_valid_i, wid_i, dispatch2cu_wg_wf_count_i, dispatch2cu_wf_size_dispatch_i, dispatch2cu_sgpr_base_dispatch_i, dispatch2cu_vgpr_base_dispatch_i, dispatch2cu_wf_tag_dispatch_i, dispatch2cu_lds_base_dispatch_i, dispatch2cu_pds_base_dispatch_i, dispatch2cu_csr_knl_dispatch_i, dispatch2cu_wgid_x_dispatch_i, dispatch2cu_wgid_y_dispatch_i, dispatch2cu_wgid_z_dispatch_i, dispatch2cu_wg_id_i, in_ready_o, out_valid_o, wb_wxd_rd_o, wxd_o, reg_idxw_o, warp_id_o, rm_o, sgpr_base_o, vgpr_base_o, lsu_tid_o, lsu_pds_o, lsu_numw_o, simt_rpc_o

Timing: Rising-edge state capture; pre-edge CSR reads; asynchronous reset and combinational indexed queries.

Domain: Fixed8warps/4threads,32-bit values, all binary native field values legal, no other macro configuration or X/Z control domain.

## F-07

rm_wid_i contains three independent three-bit bank selectors; rm_o slice[3*j+:3] is that bank's frm for j0,1,2. lsu_wid_i selects lsu_tid_o=stored wf_tag times4, lsu_pds_o=stored pds_base and lsu_numw_o=stored wg_wf_count. simt_wid_i independently selects the stored RPC. These query outputs and the complete SGPR/VGPR base arrays are combinational views of bank state and do not wait for result acceptance, ctrl_wid_i, out_ready_i or dispatch selection. Changing query selectors between clock edges immediately changes their views after combinational settling and does not mutate state.

Interfaces: clk, rst_n, rm_wid_i, lsu_wid_i, simt_wid_i, rm_o, sgpr_base_o, vgpr_base_o, lsu_tid_o, lsu_pds_o, lsu_numw_o, simt_rpc_o, ctrl_wid_i, out_ready_i, CTA2csr_valid_i

Timing: Rising-edge state capture; pre-edge CSR reads; asynchronous reset and combinational indexed queries.

Domain: Fixed8warps/4threads,32-bit values, all binary native field values legal, no other macro configuration or X/Z control domain.

## F-08

Every accepted operation captures ctrl_reg_idxw_i as eight-bit reg_idxw_o, ctrl_wxd_i as wxd_o and ctrl_wid_i as three-bit warp_id_o together with that operation's returned word. All metadata values are legal. ctrl_wxd_i never gates result creation or CSR side effects. ctrl_inst_i bits19:0 are ignored, including instruction opcode/register/immediate encodings: only its twelve high address bits matter. After capture, changing any input cannot alter a stalled or retained result; asynchronous query outputs remain independently responsive. No unaccepted attempt can replace the result snapshot.

Interfaces: clk, rst_n, ctrl_inst_i, ctrl_csr_i, ctrl_custom_signal_0_i, ctrl_isvec_i, ctrl_reg_idxw_i, ctrl_wxd_i, ctrl_wid_i, in_valid_i, out_ready_i, in1_i, CTA2csr_valid_i, in_ready_o, out_valid_o, wb_wxd_rd_o, wxd_o, reg_idxw_o, warp_id_o

Timing: Rising-edge state capture; pre-edge CSR reads; asynchronous reset and combinational indexed queries.

Domain: Fixed8warps/4threads,32-bit values, all binary native field values legal, no other macro configuration or X/Z control domain.
