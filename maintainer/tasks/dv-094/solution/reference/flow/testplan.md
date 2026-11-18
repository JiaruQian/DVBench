## T-114-001

feature_ids: F-114-001

requirement_ids: R-N114-001

stimulus: 覆盖setup/idle/access、读写、四个合法及未对齐/未知地址、忙时受限访问和零strobe启动。

expected: 固定参数N=256,Q=3329,ROOT=17,16位系数、8位地址、32位总线。pready恒1；仅psel&&penable为access，写还需pwrite。合法字节地址为0/4/8/12，不做对齐别名。access访问非法地址报pslverr；忙时任意COEFF_DATA访问或写CTRL且pwdata[0]=1也报错，与pstrb无关；错误写无副作用。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-114-002

feature_ids: F-114-002

requirement_ids: R-N114-002

stimulus: 每寄存器在setup与access及未选中/写时采样，观察沿前与沿后稳定结果；仅读取已初始化系数。

expected: psel=1且pwrite=0即组合读，不依赖penable；其余prdata=0。CTRL0只读mode[2:1]，STATUS4返回busy[0]/sticky_done[1]/sticky_error[2]，ADDR8返回host_addr低8位，DATA12空闲返回该地址16位系数零扩展、忙时0，未知地址读0。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-114-003

feature_ids: F-114-003

requirement_ids: R-N114-003

stimulus: 空闲和计算中异步复位，检查状态清零与先前已写系数保留，复位后可再次运行。

expected: presetn低有效异步复位：控制回空闲，mode=1、host_addr=0、start/host_write脉冲和sticky标志清0，irq=0；系数数组不清零，复位取消算法但保留已提交写入。读取未初始化地址无数据检查义务。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-114-004

feature_ids: F-114-004

requirement_ids: R-N114-004

stimulus: 四模式启动、零/其它byte strobe、忙启动拒绝、无启动修改mode和连续命令。

expected: 合法CTRL写且pstrb[0]=1、当前不忙时，锁存mode=pwdata[2:1]，start=pwdata[0]形成下一周期单拍命令。mode1启动前向NTT；mode0无动作；mode2/3产生错误事件，不修改系数。忙时不更新mode；start为0的合法CTRL写可清标志。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-114-005

feature_ids: F-114-005

requirement_ids: R-N114-005

stimulus: 完成/错误后跨多拍读状态，启动不清、显式clear、clear与事件相撞和错误后再启动。

expected: done/error事件在其下一采样沿进入独立sticky状态；irq=sticky_done||sticky_error，无中断使能。CTRL合法写pstrb[0]且bit3=1同时清两标志，清除优先于同沿事件。启动本身不自动清旧标志。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-114-006

feature_ids: F-114-006

requirement_ids: R-N114-006

stimulus: 初始化全256地址，低/高字节写、零及高byte strobe、写后立即改ADDR和同沿连续写；分别观察锁存沿和提交沿。

expected: ADDR写仅pstrb[0]有效，地址取pwdata低8位；DATA写按pstrb[1:0]逐字节合并当前系数，较高两byte无影响，低两bit全0无写。合法DATA访问沿锁存合并值/写脉冲，下一沿才写到该下一沿之前的host_addr；无自动增址。原生同时core写优先。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-114-007

feature_ids: F-114-007

requirement_ids: R-N114-007

stimulus: 用零、单位脉冲、超过Q、最大16位和随机完整256系数；独立循环模运算预期，完成后逐地址读取比较。

expected: 原地8级、每级128蝶形，stage s=0..7；h=2^s，k=0..127，offset=k mod h，a=floor(k/h)*2h+offset，b=a+h，w=17^(offset*2^(7-s)) mod3329。先取A=mem[a] mod3329,B=mem[b] mod3329,T=B*w mod3329，再同时写(a,b)=((A+T)mod3329,(A-T+3329)mod3329)。按s再k递增；无额外bit-reverse或逆变换。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-114-008

feature_ids: F-114-008

requirement_ids: R-N114-008

stimulus: 逐拍观察启动/完成边界，忙期间状态读、DATA/START错误、ADDR更改，完成后读全结果。

expected: 接受CTRL START的沿记T0，T1开始busy；T2起第一个两拍读阶段，随后计算/写/推进；每蝶形占5拍，最后一次busy在T5122下降，T5123起sticky_done/irq置位。算法期间允许STATUS/CTRL/ADDR读和ADDR写，DATA读返回0且access报错。忙时非法START不排队。

checker: 输入历史独立预测器维护本条行为，monitor读取实际原生端口；在所述稳定窗口逐位四态比较actual/expected并以UVM_ERROR报告失配；统计比较次数和输出变化，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv
