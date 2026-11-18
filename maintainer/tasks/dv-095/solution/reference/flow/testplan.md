## T-115-001

feature_ids: F-115-001

requirement_ids: R-N115-001

stimulus: 沿间断言rst验证同步特性；接收、计算和输出stall中软取消，检查CSR保留并能重启。

expected: 固定8x8、INT8输入和INT32结果，无可覆写参数。rst高仅在上升沿复位CSR和controller/array：清start、done、irq_en、tilecount及AXIL pending/valid，core空闲；A/B/C缓冲内容无复位保证。CTRL bit1写1产生一拍soft_reset，下一沿只取消controller/array且清start，CSR累计/IRQ配置保留。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-115-002

feature_ids: F-115-002

requirement_ids: R-N115-002

stimulus: AW先、W先、同拍、长分离、B背压中捕获下一对、wstrb0和未对齐地址；沿前握手后检查提交延迟。

expected: AW/W各有单项缓冲，可任意先后接受：awready=!aw_pending、wready=!w_pending。两项都已存在且bvalid=0的下一沿提交，bresp恒OKAY=0；bvalid保持到bready，响应期间仍可捕获下一对地址/数据但未清响应前不提交。wstrb完全忽略，包括0；地址精确匹配无对齐别名。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-115-003

feature_ids: F-115-003

requirement_ids: R-N115-003

stimulus: 逐CSR读、未映射读和长R背压，验证AR接受到下一沿取值、保持及恢复。

expected: arready=!ar_pending&&!rvalid；AR接受后下一沿采寄存器值并置rvalid，rresp恒0，rdata/rvalid保持到rready。响应未接受前不接下一个AR。未知/非对齐地址读0，写忽略但正常响应。只在rvalid时检查rdata。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-115-004

feature_ids: F-115-004

requirement_ids: R-N115-004

stimulus: 全部CSR/只读/未知地址，IRQ开关、W1C、忙时start写拒绝、同沿done和W1C或CTRL写。

expected: 0x00 CTRL bit0=start电平，仅core空闲允许写bit0；bit1软复位优先且清start。0x04 STATUS busy[0],sticky_done[1],overflow[2]=0，写bit1为1清done。0x08只读tilecount每完成加1模2^32；0x0c IRQ_EN bit0；0x10 VERSION=0x10000。done事件同沿优先于bus写：清start、置sticky、tilecount++。irq=IRQ_EN&&sticky_done，未受忙状态门控。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-115-005

feature_ids: F-115-005

requirement_ids: R-N115-005

stimulus: A/B并发、B延迟到LOAD之后、两流空泡、valid保持、早/迟tlast、满8行关闭ready和无start数据。

expected: start电平在空闲沿被接受，随后busy=1并打开接收。A仅RECV阶段且少于8行时ready；B可在RECV/八拍LOAD/WAIT_B阶段接收，少于8行时ready。只按valid&&ready收一行，两个流独立，可有空泡。tlast只诊断预期第8行，不改变数学结果或FSM。完成整A后下一沿才进入8拍LOAD；B不足8则等待，绝不计算半tile。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-115-006

feature_ids: F-115-006

requirement_ids: R-N115-006

stimulus: 单位矩阵、全零、-128/127极值、非对称随机矩阵；独立三循环signed乘加，逐行逐列比对完整结果。

expected: A/B每个64位beat为一行，小端byte：第j项在[8j+:8]，均二补码有符号INT8。C[r][c]=sum(k=0..7,A[r][k]*B[k][c])，32位二补码无饱和；不转置、不激活、不加偏置。每个256位输出为C一行，第j项[32j+:32]，行0到7顺序。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-115-007

feature_ids: F-115-007

requirement_ids: R-N115-007

stimulus: 沿级计数覆盖最后A/B同拍、最后LOAD沿才接受B、延迟B和最终C消费到done/CSR的延迟。

expected: 完整A接收后多一拍进入LOAD，LOAD恰8拍；最后LOAD沿若B已完整即开始COMPUTE，否则WAIT_B观察旧计数直到完整。COMPUTE固定23拍（0..22），下一周期进入OUTPUT。busy包括所有非空闲阶段和一拍DONE。第8个C握手后的周期DONE，下一沿回空闲并使CSR完成事件生效；start此时自动清零。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-115-008

feature_ids: F-115-008

requirement_ids: R-N115-008

stimulus: 首/中/末行背压、连续ready和交错stall、连续不同tile及软复位取消输出；计数8个真实握手且检查无重复/丢行。

expected: 输出valid保持到8行全部被valid&&ready接受，tlast仅第8行，stall期间data/last稳定，只有握手才递增行。输出期间不接受A/B，不提前完成。C data在valid=0时无检查义务；下一tile必须重新收满A/B，历史tile不混入。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv
