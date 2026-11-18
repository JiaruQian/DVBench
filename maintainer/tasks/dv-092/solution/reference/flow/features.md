# Feature analysis

## F-01

The fixed configuration is eight warp banks,eight workgroup sets and two fetched instructions. There are no top parameters. All native binary values and simultaneous input combinations are legal. rst_n is asynchronous active-low and clears running warp bits,barrier-wait bits,all workgroup membership,all eight32-bit fetch addresses and two-bit lane masks. A pulse wholly between clock edges clears these histories. Combinational outputs remain functions of current inputs and cleared state during reset: branch/control responses and flushes are not reset-gated. Every native output payload is defined even when its valid is zero. Release reset away from rising edges.

Interfaces: clk, rst_n, warpReq_valid_i, warpReq_dispatch2cu_wf_tag_dispatch_i, warpReq_wid_i, warpReq_dispatch2cu_start_pc_dispatch_i, warpRsp_ready_i, wg_id_tag_i, pc_rsp_valid_i, pc_rsp_addr_i, pc_rsp_mask_i, pc_rsp_wid_i, pc_rsp_status_i, branch_valid_i, branch_wid_i, branch_jump_i, branch_new_pc_i, warp_control_valid_i, warp_control_simt_stack_op_i, warp_control_wid_i, scoreboard_busy_i, ibuffer_ready_i, warpRsp_valid_o, warpRsp_wid_o, wg_id_lookup_o, pc_req_valid_o, pc_req_addr_o, pc_req_mask_o, pc_req_wid_o, branch_ready_o, warp_control_ready_o, warp_ready_o, flush_valid_o, flush_wid_o, flushCache_valid_o, flushCache_wid_o

Timing: Rising-edge set/address updates,asynchronous active-low reset,current-pin combinational control priority.

Domain: Fixed8warp/8group/2fetch and7-bit tags; all binary simultaneous native combinations legal,no X/Z control domain.

## F-02

flushCache_valid_o is pc_rsp_valid_i AND pc_rsp_status_i; flushCache_wid_o always equals pc_rsp_wid_i. branch_ready_o is NOT flushCache_valid_o and branch acceptance is branch_valid_i AND branch_ready_o. warp_control_ready_o is NOT branch acceptance AND NOT flushCache_valid_o; warp control accepts when it is valid and ready. Any accepted branch,including jump0,blocks warp control. A warp-end event is accepted warp control with simt_stack_op1. warpRsp_valid_o is this event and warpRsp_wid_o always equals warp_control_wid_i; response ready does not hold or defer its valid. flush_valid_o is accepted jumping branch OR warp-end, with flush_wid_o choosing branch_wid_i for an accepted jump and otherwise warp_control_wid_i. wg_id_lookup_o always equals warp_control_wid_i.

Interfaces: clk, rst_n, warpReq_valid_i, warpReq_dispatch2cu_wf_tag_dispatch_i, warpReq_wid_i, warpReq_dispatch2cu_start_pc_dispatch_i, warpRsp_ready_i, wg_id_tag_i, pc_rsp_valid_i, pc_rsp_addr_i, pc_rsp_mask_i, pc_rsp_wid_i, pc_rsp_status_i, branch_valid_i, branch_wid_i, branch_jump_i, branch_new_pc_i, warp_control_valid_i, warp_control_simt_stack_op_i, warp_control_wid_i, scoreboard_busy_i, ibuffer_ready_i, warpRsp_valid_o, warpRsp_wid_o, wg_id_lookup_o, pc_req_valid_o, pc_req_addr_o, pc_req_mask_o, pc_req_wid_o, branch_ready_o, warp_control_ready_o, warp_ready_o, flush_valid_o, flush_wid_o, flushCache_valid_o, flushCache_wid_o

Timing: Rising-edge set/address updates,asynchronous active-low reset,current-pin combinational control priority.

Domain: Fixed8warp/8group/2fetch and7-bit tags; all binary simultaneous native combinations legal,no X/Z control domain.

## F-03

Every warpReq_valid_i dispatch is accepted at its rising edge without a ready handshake. It sets the running bit of warpReq_wid_i. An accepted warp end clears its selected running bit regardless of warpRsp_ready_i; if dispatch and end select the same bank on one edge,end wins that running bit. Each seven-bit tag selects a workgroup using bits6:4; bits3:0 do not affect group membership. Dispatch adds its warp to the selected group. Otherwise an accepted end with warpRsp_ready_i1 removes its warp from the group selected by wg_id_tag_i bits6:4. Dispatch has global priority over this membership removal even for different groups. Dispatch does not implicitly remove the warp from previous groups. All updates use old state.

Interfaces: clk, rst_n, warpReq_valid_i, warpReq_dispatch2cu_wf_tag_dispatch_i, warpReq_wid_i, warpReq_dispatch2cu_start_pc_dispatch_i, warpRsp_ready_i, wg_id_tag_i, pc_rsp_valid_i, pc_rsp_addr_i, pc_rsp_mask_i, pc_rsp_wid_i, pc_rsp_status_i, branch_valid_i, branch_wid_i, branch_jump_i, branch_new_pc_i, warp_control_valid_i, warp_control_simt_stack_op_i, warp_control_wid_i, scoreboard_busy_i, ibuffer_ready_i, warpRsp_valid_o, warpRsp_wid_o, wg_id_lookup_o, pc_req_valid_o, pc_req_addr_o, pc_req_mask_o, pc_req_wid_o, branch_ready_o, warp_control_ready_o, warp_ready_o, flush_valid_o, flush_wid_o, flushCache_valid_o, flushCache_wid_o

Timing: Rising-edge set/address updates,asynchronous active-low reset,current-pin combinational control priority.

Domain: Fixed8warp/8group/2fetch and7-bit tags; all binary simultaneous native combinations legal,no X/Z control domain.

## F-04

Accepted warp control with simt_stack_op0 is a barrier arrival. Form candidate_wait=old global eight-bit barrier-wait set OR the arrival warp bit. Compare that entire eight-bit candidate to the old member set selected by wg_id_tag_i bits6:4. If equal,clear those group-member bits from the old wait set; otherwise store candidate_wait. This is exact set equality,not subset containment. Other groups waiting bits may prevent equality; there is one global wait set. Ordinary branches and warp ends do not directly clear wait bits. A simultaneous dispatch/end membership update does not change the old membership used by that edge barrier decision.

Interfaces: clk, rst_n, warpReq_valid_i, warpReq_dispatch2cu_wf_tag_dispatch_i, warpReq_wid_i, warpReq_dispatch2cu_start_pc_dispatch_i, warpRsp_ready_i, wg_id_tag_i, pc_rsp_valid_i, pc_rsp_addr_i, pc_rsp_mask_i, pc_rsp_wid_i, pc_rsp_status_i, branch_valid_i, branch_wid_i, branch_jump_i, branch_new_pc_i, warp_control_valid_i, warp_control_simt_stack_op_i, warp_control_wid_i, scoreboard_busy_i, ibuffer_ready_i, warpRsp_valid_o, warpRsp_wid_o, wg_id_lookup_o, pc_req_valid_o, pc_req_addr_o, pc_req_mask_o, pc_req_wid_o, branch_ready_o, warp_control_ready_o, warp_ready_o, flush_valid_o, flush_wid_o, flushCache_valid_o, flushCache_wid_o

Timing: Rising-edge set/address updates,asynchronous active-low reset,current-pin combinational control priority.

Domain: Fixed8warp/8group/2fetch and7-bit tags; all binary simultaneous native combinations legal,no X/Z control domain.

## F-05

warp_ready_o is running AND NOT barrier-wait AND NOT scoreboard_busy_i. Fetch eligibility is independently running AND ibuffer_ready_i; barrier waiting and scoreboard busy do not gate fetch selection. Select the lowest eligible warp index,or index0 when no warp is eligible. pc_req_wid_o is always this index; address and mask are its stored values. pc_req_valid_o equals that selected eligibility bit except an accepted jumping branch to the selected warp suppresses it. A branch to another warp does not suppress selected fetch. No fetch ready input exists and no round-robin history is maintained.

Interfaces: clk, rst_n, warpReq_valid_i, warpReq_dispatch2cu_wf_tag_dispatch_i, warpReq_wid_i, warpReq_dispatch2cu_start_pc_dispatch_i, warpRsp_ready_i, wg_id_tag_i, pc_rsp_valid_i, pc_rsp_addr_i, pc_rsp_mask_i, pc_rsp_wid_i, pc_rsp_status_i, branch_valid_i, branch_wid_i, branch_jump_i, branch_new_pc_i, warp_control_valid_i, warp_control_simt_stack_op_i, warp_control_wid_i, scoreboard_busy_i, ibuffer_ready_i, warpRsp_valid_o, warpRsp_wid_o, wg_id_lookup_o, pc_req_valid_o, pc_req_addr_o, pc_req_mask_o, pc_req_wid_o, branch_ready_o, warp_control_ready_o, warp_ready_o, flush_valid_o, flush_wid_o, flushCache_valid_o, flushCache_wid_o

Timing: Rising-edge set/address updates,asynchronous active-low reset,current-pin combinational control priority.

Domain: Fixed8warp/8group/2fetch and7-bit tags; all binary simultaneous native combinations legal,no X/Z control domain.

## F-06

For a bank with dispatch or accepted jumping branch,update its fetch address to target AND0xfffffff8. Target priority is dispatch start address first,then failed-response address for that bank,then accepted branch address,then zero. With ordinary legal combinations a failed response blocks branch acceptance,while dispatch remains accepted. The aligned update lane mask bitj is one exactly when unsigned(aligned_target+4*j) is greater than or equal to the original32-bit target,for j0,1. Thus offsets0,1..4,5..7 within an eight-byte line yield masks3,2,0 respectively. No instruction-alignment constraint excludes other byte addresses; addresses wrap at32bits.

Interfaces: clk, rst_n, warpReq_valid_i, warpReq_dispatch2cu_wf_tag_dispatch_i, warpReq_wid_i, warpReq_dispatch2cu_start_pc_dispatch_i, warpRsp_ready_i, wg_id_tag_i, pc_rsp_valid_i, pc_rsp_addr_i, pc_rsp_mask_i, pc_rsp_wid_i, pc_rsp_status_i, branch_valid_i, branch_wid_i, branch_jump_i, branch_new_pc_i, warp_control_valid_i, warp_control_simt_stack_op_i, warp_control_wid_i, scoreboard_busy_i, ibuffer_ready_i, warpRsp_valid_o, warpRsp_wid_o, wg_id_lookup_o, pc_req_valid_o, pc_req_addr_o, pc_req_mask_o, pc_req_wid_o, branch_ready_o, warp_control_ready_o, warp_ready_o, flush_valid_o, flush_wid_o, flushCache_valid_o, flushCache_wid_o

Timing: Rising-edge set/address updates,asynchronous active-low reset,current-pin combinational control priority.

Domain: Fixed8warp/8group/2fetch and7-bit tags; all binary simultaneous native combinations legal,no X/Z control domain.

## F-07

At every rising edge each bank uses this priority: dispatch or accepted jumping branch performs the aligned update; otherwise a valid failed response for that bank copies pc_rsp_addr_i and pc_rsp_mask_i exactly without alignment; otherwise the currently selected bank performs the selected-bank rule; all other banks hold. The ordinary selected-bank rule adds8 modulo2^32 and sets mask3 even if pc_req_valid_o is zero. It does not require active/eligible/request acceptance. Thus idle no-active histories still advance bank0. A successful response,status0,does not itself write any address. Different-bank dispatch,branch,response and selected-bank operations may occur together.

Interfaces: clk, rst_n, warpReq_valid_i, warpReq_dispatch2cu_wf_tag_dispatch_i, warpReq_wid_i, warpReq_dispatch2cu_start_pc_dispatch_i, warpRsp_ready_i, wg_id_tag_i, pc_rsp_valid_i, pc_rsp_addr_i, pc_rsp_mask_i, pc_rsp_wid_i, pc_rsp_status_i, branch_valid_i, branch_wid_i, branch_jump_i, branch_new_pc_i, warp_control_valid_i, warp_control_simt_stack_op_i, warp_control_wid_i, scoreboard_busy_i, ibuffer_ready_i, warpRsp_valid_o, warpRsp_wid_o, wg_id_lookup_o, pc_req_valid_o, pc_req_addr_o, pc_req_mask_o, pc_req_wid_o, branch_ready_o, warp_control_ready_o, warp_ready_o, flush_valid_o, flush_wid_o, flushCache_valid_o, flushCache_wid_o

Timing: Rising-edge set/address updates,asynchronous active-low reset,current-pin combinational control priority.

Domain: Fixed8warp/8group/2fetch and7-bit tags; all binary simultaneous native combinations legal,no X/Z control domain.

## F-08

The selected-bank ordinary increment is replaced by a replay/hold when no bank is fetch-eligible and either the population count of running bits is greater than1,or pc_rsp_valid_i is zero and the complete running bit vector equals8'h01. The latter condition means only warp0 running,not an arbitrary single running warp. Selection defaults to0 here,so replay copies that bank0 address/mask and preserves them. With exactly one running higher-index warp and no eligibility,bank0 still increments. With only warp0 running,a valid successful response disables the second hold condition. Higher-priority dispatch,branch or failed-response updates still win. All population and equality conditions use pre-edge state.

Interfaces: clk, rst_n, warpReq_valid_i, warpReq_dispatch2cu_wf_tag_dispatch_i, warpReq_wid_i, warpReq_dispatch2cu_start_pc_dispatch_i, warpRsp_ready_i, wg_id_tag_i, pc_rsp_valid_i, pc_rsp_addr_i, pc_rsp_mask_i, pc_rsp_wid_i, pc_rsp_status_i, branch_valid_i, branch_wid_i, branch_jump_i, branch_new_pc_i, warp_control_valid_i, warp_control_simt_stack_op_i, warp_control_wid_i, scoreboard_busy_i, ibuffer_ready_i, warpRsp_valid_o, warpRsp_wid_o, wg_id_lookup_o, pc_req_valid_o, pc_req_addr_o, pc_req_mask_o, pc_req_wid_o, branch_ready_o, warp_control_ready_o, warp_ready_o, flush_valid_o, flush_wid_o, flushCache_valid_o, flushCache_wid_o

Timing: Rising-edge set/address updates,asynchronous active-low reset,current-pin combinational control priority.

Domain: Fixed8warp/8group/2fetch and7-bit tags; all binary simultaneous native combinations legal,no X/Z control domain.

## F-09

Each bank retains independent address/mask histories and each group independent member bits; running and wait sets are indexed by native three-bit warp IDs. Current request address/mask follow selected-bank changes combinationally,including while request valid is zero. Response/flush/lookup IDs remain direct current-pin functions without state capture. Scoreboard busy,warpRsp_ready and tag low bits affect only their explicitly stated readiness/member-removal domains. pc_rsp_addr/mask/wid/status without valid cannot directly trigger a replay write,though current response-valid has the stated selected-hold effect.

Interfaces: clk, rst_n, warpReq_valid_i, warpReq_dispatch2cu_wf_tag_dispatch_i, warpReq_wid_i, warpReq_dispatch2cu_start_pc_dispatch_i, warpRsp_ready_i, wg_id_tag_i, pc_rsp_valid_i, pc_rsp_addr_i, pc_rsp_mask_i, pc_rsp_wid_i, pc_rsp_status_i, branch_valid_i, branch_wid_i, branch_jump_i, branch_new_pc_i, warp_control_valid_i, warp_control_simt_stack_op_i, warp_control_wid_i, scoreboard_busy_i, ibuffer_ready_i, warpRsp_valid_o, warpRsp_wid_o, wg_id_lookup_o, pc_req_valid_o, pc_req_addr_o, pc_req_mask_o, pc_req_wid_o, branch_ready_o, warp_control_ready_o, warp_ready_o, flush_valid_o, flush_wid_o, flushCache_valid_o, flushCache_wid_o

Timing: Rising-edge set/address updates,asynchronous active-low reset,current-pin combinational control priority.

Domain: Fixed8warp/8group/2fetch and7-bit tags; all binary simultaneous native combinations legal,no X/Z control domain.
