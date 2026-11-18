# Reference testplan

{
  "test_id": "T1",
  "feature_ids": [
    "F1"
  ],
  "requirement_ids": [
    "R-p8-simt-001"
  ],
  "stimulus": "After asynchronous reset,drive isolated branch/reconvergence offers and wait for registered occupancy. The deterministic operation routine accepts a control and reconvergence PC,then consumes with the IF mask and drains4 cycles. Add5000 seeded independent binary native-input cycles to cover full/empty offers,missing PCs,mismatched warps and backpressure. Compare retained payload and every ready/valid each half-cycle.",
  "expected": "The root has independent depth1 queues for branch-control,reconvergence-PC and fetch-control. Each has a full flag and saved payload,reset0. Input ready is NOT full,without a same-edge pop bypass. Push occurs on input valid AND NOT full; pop occurs on its consume condition AND full. Full next is (old full AND NOT pop) OR push. Only push replaces saved payload; it otherwise persists after pop and while invalid. A full queue cannot accept a replacement on the edge it pops. An empty pushed queue becomes visible after the edge. Branch ready is its queue ready; fetch valid and all fetch payload fields are continuously its queue full and saved payload. The reconvergence queue has no exported ready and silently ignores valid offers while full; its saved PC is still used even if its full flag0. complete_wid continuously equals the saved branch warp,including when branch invalid. The IF mask has no input queue.",
  "checker": "Independent self-contained dvbench_model uses per-warp abstract record arrays,pointers,active masks and three independent one-entry queues driven only by native inputs/history. It never instantiates DUT/dependency modules or reads internal hierarchy. ss_scoreboard compares every native output to separate expected outputs with four-state inequality two time units after falling/rising edges. A separate reset-event observer compares every native output0.1ns after every falling rst_n edge,after asynchronous state settles and before the next rising clk edge during the1ns between-edge pulse. This verifies the reset result without a clock transition. Unknown out-of-storage reads remain unknown. Emit UVM_ERROR on mismatch and require at least1000 observations.",
  "implementation_id": "ss_scoreboard.compare",
  "source": "ss_pkg.sv:ss_sequence.body; ss_scoreboard.compare"
}

{
  "test_id": "T2",
  "feature_ids": [
    "F2"
  ],
  "requirement_ids": [
    "R-p8-simt-002"
  ],
  "stimulus": "For all8 warps sweep every initial mask0..15 and every live IF mask0..15 after reset. Drive a branch with known execute/branch/reconvergence PCs,then its IF mask. Include zero masks,all-IF,all-ELSE,equal populations and asymmetric1-vs3/3-vs1 partitions. Compare take-path consequences,complete/fetch messages and every selected active mask independently.",
  "expected": "Use the retained branch initial mask M and current live4-bit IF mask I. Compute if_lanes=I AND M and else_lanes=M AND NOT if_lanes,all4 bits. if_only means else_lanes0; else_only means if_lanes0; divergent means neither is zero. Take IF when if_only OR (divergent AND population(if_lanes)<population(else_lanes)). A population tie takes ELSE. With M0 both only predicates are true and take IF is true. Chosen mask is if_lanes for take-IF,otherwise else_lanes; saved other-path mask is the opposite. Saved other-path PC is branch_pc for take-IF,otherwise execute_pc+4 modulo2^32. Mask partition uses retained branch fields even while branch invalid.",
  "checker": "Independent self-contained dvbench_model uses per-warp abstract record arrays,pointers,active masks and three independent one-entry queues driven only by native inputs/history. It never instantiates DUT/dependency modules or reads internal hierarchy. ss_scoreboard compares every native output to separate expected outputs with four-state inequality two time units after falling/rising edges. A separate reset-event observer compares every native output0.1ns after every falling rst_n edge,after asynchronous state settles and before the next rising clk edge during the1ns between-edge pulse. This verifies the reset result without a clock transition. Unknown out-of-storage reads remain unknown. Emit UVM_ERROR on mismatch and require at least1000 observations.",
  "implementation_id": "ss_scoreboard.compare",
  "source": "ss_pkg.sv:ss_sequence.body; ss_scoreboard.compare"
}

{
  "test_id": "T3",
  "feature_ids": [
    "F3"
  ],
  "requirement_ids": [
    "R-p8-simt-003"
  ],
  "stimulus": "Use the full8x16x16 deterministic branch matrix and5000 seeded random binary cycles with independent branch valid,IF valid,IF warp,PC valid and fetch ready. Track retained header and all queue full bits to derive exact consume/completion predicates,including completion on IF warp mismatch and JOIN consumption without IF/PC valid.",
  "expected": "Let fetch_capacity be NOT fetch queue full. if_mask_ready equals fetch_capacity and IF_fire=if_mask_valid AND fetch_capacity. A retained valid JOIN (opcode1) consumes branch and reconvergence queues when fetch_capacity,independently of IF valid/warp. A retained valid BRANCH (opcode0) consumes those queues only when fetch_capacity AND IF valid AND live IF warp equals retained branch warp. Reconvergence full/valid is not a consumption prerequisite. branch_fire denotes a consumed valid branch-control record. complete_valid is IF_fire AND retained branch valid AND opcode0 AND take-IF; it does NOT require the IF warp to match,so completion can pulse while a mismatched-warp branch remains queued. complete_wid is the retained branch warp. There is no output ready for completion.",
  "checker": "Independent self-contained dvbench_model uses per-warp abstract record arrays,pointers,active masks and three independent one-entry queues driven only by native inputs/history. It never instantiates DUT/dependency modules or reads internal hierarchy. ss_scoreboard compares every native output to separate expected outputs with four-state inequality two time units after falling/rising edges. A separate reset-event observer compares every native output0.1ns after every falling rst_n edge,after asynchronous state settles and before the next rising clk edge during the1ns between-edge pulse. This verifies the reset result without a clock transition. Unknown out-of-storage reads remain unknown. Emit UVM_ERROR on mismatch and require at least1000 observations.",
  "implementation_id": "ss_scoreboard.compare",
  "source": "ss_pkg.sv:ss_sequence.body; ss_scoreboard.compare"
}

{
  "test_id": "T4",
  "feature_ids": [
    "F4"
  ],
  "requirement_ids": [
    "R-p8-simt-004"
  ],
  "stimulus": "Exercise take-IF,ELSE-only,tie and zero-initial-mask branches. Randomly hold fetch ready0 while offering branch/IF traffic,then release. In random histories retain mismatched-warp branch headers and live IF valid across multiple fetch-empty opportunities; compare every accepted fetch candidate,zero-jump JOIN message and payload retention during invalid cycles.",
  "expected": "A retained valid JOIN offers a fetch-control candidate every cycle,even without a successful stack pop: candidate warp is retained warp,jump is that warp successful JOIN jump,PC is its pre-pop top jump-PC if jump1 and otherwise0. A retained valid BRANCH offers a candidate when live IF valid AND (NOT take-IF OR else_only),without an IF-warp match or branch_fire prerequisite; candidate jump1,PC=retained branch_pc,warp=retained branch warp. Otherwise no candidate. The fetch queue accepts the candidate exactly when currently empty and may later pop when fetch_ctl_ready1. A queued branch can therefore offer repeated fetch messages across empty/pop cycles when its IF warp mismatches. M0 can produce both completion and a fetch offer. While fetch queue full it blocks all IF readiness and branch consumption,even when external fetch ready1 will pop on that edge. Fetch payload persists while invalid.",
  "checker": "Independent self-contained dvbench_model uses per-warp abstract record arrays,pointers,active masks and three independent one-entry queues driven only by native inputs/history. It never instantiates DUT/dependency modules or reads internal hierarchy. ss_scoreboard compares every native output to separate expected outputs with four-state inequality two time units after falling/rising edges. A separate reset-event observer compares every native output0.1ns after every falling rst_n edge,after asynchronous state settles and before the next rising clk edge during the1ns between-edge pulse. This verifies the reset result without a clock transition. Unknown out-of-storage reads remain unknown. Emit UVM_ERROR on mismatch and require at least1000 observations.",
  "implementation_id": "ss_scoreboard.compare",
  "source": "ss_pkg.sv:ss_sequence.body; ss_scoreboard.compare"
}

{
  "test_id": "T5",
  "feature_ids": [
    "F5"
  ],
  "requirement_ids": [
    "R-p8-simt-005"
  ],
  "stimulus": "For each warp,after reset push8 nested divergent branches with distinct execute,reconvergence and other-path PCs; maintain independent per-warp records. Then use matching JOINs twice per depth in reverse nesting order and check PC/mask restoration. Scan input_wid0..7 after every deterministic mask-matrix branch so untouched warps are compared too.",
  "expected": "There are8 independent warp stacks,each with24 records containing32-bit reconvergence PC,32-bit jump PC and4-bit mask. A divergent consumed BRANCH pushes exactly two records only into its retained warp. The lower record stores reconvergence PC from the reconvergence queue,that same PC as jump-PC,and the selected warp PRE-edge active mask. The upper record stores the same reconvergence PC,the other-path PC and other-path mask from R002. New top points to the upper record; write position advances by2. This push uses the retained reconvergence PC even when that queue empty. Simultaneous active-mask updates do not change the original mask being saved. Different warps preserve separate contents and positions.",
  "checker": "Independent self-contained dvbench_model uses per-warp abstract record arrays,pointers,active masks and three independent one-entry queues driven only by native inputs/history. It never instantiates DUT/dependency modules or reads internal hierarchy. ss_scoreboard compares every native output to separate expected outputs with four-state inequality two time units after falling/rising edges. A separate reset-event observer compares every native output0.1ns after every falling rst_n edge,after asynchronous state settles and before the next rising clk edge during the1ns between-edge pulse. This verifies the reset result without a clock transition. Unknown out-of-storage reads remain unknown. Emit UVM_ERROR on mismatch and require at least1000 observations.",
  "implementation_id": "ss_scoreboard.compare",
  "source": "ss_pkg.sv:ss_sequence.body; ss_scoreboard.compare"
}

{
  "test_id": "T6",
  "feature_ids": [
    "F6"
  ],
  "requirement_ids": [
    "R-p8-simt-006"
  ],
  "stimulus": "For each8-warp nested history issue a mismatching JOIN PC first,then two correct JOINs per depth,then an empty JOIN. Separately push14 divergent branches on each warp so records exceed24; compare exact unknown top reads and ignored out-of-storage writes,then reset. Use execute_pc fffffffc in these pushes to cover wraparound of the saved execute+4 PC.",
  "expected": "Each warp has unsigned21-bit read and write positions,reset0. Empty means write position0. A successful JOIN jump requires nonempty selected stack,top record reconvergence PC equal retained execute_pc,and a consumed valid JOIN for that warp. It presents the PRE-pop top jump-PC/mask and decrements both positions by1 modulo2^21. A mismatching or empty JOIN consumes its control but leaves stack positions unchanged and offers fetch jump0/PC0. Push has priority over a pop in the underlying stack. On push,let n=(old write position+1) modulo2^21; new read=n,new write=(old write+2) modulo2^21. The two physical write record indices are integer(n)-1 and integer(n),with lower/upper payloads from R005. Only indices0..23 exist; out-of-storage writes are ignored,including a negative lower index after wrap. Reading a top outside0..23 yields unknown record fields; there is no full check or saturation. Do not assume an unlimited stack,automatic overflow trap,clamping or deterministic zeros for out-of-storage reads. Reset is the way to restore a known empty state.",
  "checker": "Independent self-contained dvbench_model uses per-warp abstract record arrays,pointers,active masks and three independent one-entry queues driven only by native inputs/history. It never instantiates DUT/dependency modules or reads internal hierarchy. ss_scoreboard compares every native output to separate expected outputs with four-state inequality two time units after falling/rising edges. A separate reset-event observer compares every native output0.1ns after every falling rst_n edge,after asynchronous state settles and before the next rising clk edge during the1ns between-edge pulse. This verifies the reset result without a clock transition. Unknown out-of-storage reads remain unknown. Emit UVM_ERROR on mismatch and require at least1000 observations.",
  "implementation_id": "ss_scoreboard.compare",
  "source": "ss_pkg.sv:ss_sequence.body; ss_scoreboard.compare"
}

{
  "test_id": "T7",
  "feature_ids": [
    "F7"
  ],
  "requirement_ids": [
    "R-p8-simt-007"
  ],
  "stimulus": "For all8 warps and all256 initial/IF mask pairs compare the chosen active mask and scan every input_wid. In nested histories check the pre-update original mask saved into each lower record and restoration on two JOINs. Random5000-cycle independent IF-valid/warp/opcode traffic covers priority writes with invalid/mismatched retained headers and empty-stack fallback.",
  "expected": "There is a4-bit active mask per warp,whose reset value in this4-lane configuration is binary1111 (hex f). At every outside-reset edge update only the warp named by the retained branch header with this priority: first,IF_fire AND divergent writes the chosen mask,without testing branch valid,opcode or IF-warp match; second,retained valid JOIN AND successful JOIN jump writes its pre-pop top mask; third,if that retained warp stack is empty restore1111; otherwise hold. Other warps hold. Consequently live IF input can change a mask using an invalid retained header,and the empty-stack restoration occurs on later edges only when neither higher-priority condition applies. out_mask continuously selects the active mask at current input_wid,independent of branch/IF warp and validity.",
  "checker": "Independent self-contained dvbench_model uses per-warp abstract record arrays,pointers,active masks and three independent one-entry queues driven only by native inputs/history. It never instantiates DUT/dependency modules or reads internal hierarchy. ss_scoreboard compares every native output to separate expected outputs with four-state inequality two time units after falling/rising edges. A separate reset-event observer compares every native output0.1ns after every falling rst_n edge,after asynchronous state settles and before the next rising clk edge during the1ns between-edge pulse. This verifies the reset result without a clock transition. Unknown out-of-storage reads remain unknown. Emit UVM_ERROR on mismatch and require at least1000 observations.",
  "implementation_id": "ss_scoreboard.compare",
  "source": "ss_pkg.sv:ss_sequence.body; ss_scoreboard.compare"
}

{
  "test_id": "T8",
  "feature_ids": [
    "F8"
  ],
  "requirement_ids": [
    "R-p8-simt-008"
  ],
  "stimulus": "Begin with two reset-low edges,reset before each complete mask-matrix case and between per-warp nested/overflow histories. After5000 random cycles apply a1ns reset-low pulse entirely between rising edges,then drain10 cycles and check all queues,stack-derived behavior and selected masks reset independently. Finish with reset and10 drains.",
  "expected": "rst_n falling asynchronously clears all3 queue full flags and saved payloads,all8 stack read/write positions and all24 records per stack to0,and sets all8 active masks1111. A short low pulse wholly between rising edges flushes pending histories and stack contents. Holding reset low keeps state cleared at each edge. Native combinational outputs still follow reset state and current live inputs; reset does not separately gate ready/completion/mask outputs. There are no top parameters or external protocol assertions. Every known binary native input combination is admitted,including IF without a valid branch,mismatched IF warp,missing reconvergence PC,offers while queues full,zero masks,JOIN on empty stack and pushes past physical storage. These cases obey the exact retained-state and unknown-read rules above; no external SIMT algorithm convention narrows the contract.",
  "checker": "Independent self-contained dvbench_model uses per-warp abstract record arrays,pointers,active masks and three independent one-entry queues driven only by native inputs/history. It never instantiates DUT/dependency modules or reads internal hierarchy. ss_scoreboard compares every native output to separate expected outputs with four-state inequality two time units after falling/rising edges. A separate reset-event observer compares every native output0.1ns after every falling rst_n edge,after asynchronous state settles and before the next rising clk edge during the1ns between-edge pulse. This verifies the reset result without a clock transition. Unknown out-of-storage reads remain unknown. Emit UVM_ERROR on mismatch and require at least1000 observations.",
  "implementation_id": "ss_scoreboard.compare",
  "source": "ss_pkg.sv:ss_sequence.body; ss_scoreboard.compare"
}
