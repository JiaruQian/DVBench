# Testplan

## T-001

feature_ids: F-001

requirement_ids: R-32C4343634EF-001

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。每个参数配置先复位，经过使能/读写产生非零状态，再施加沿间reset高脉冲和跨沿复位，同时stb/write=1；在脉冲期间、释放后和下一个沿后比较。

expected: reset高有效且异步。复位将counter=0、compare=2^CNTw-1、prescaler=0、控制配置=0、ISR=0、read=0、ack=0。sa_err_o和sa_rty_o始终为0。 不需要clk上升沿；释放reset本身不更新状态。 复位优先于同拍读写、计数和IRQ事件；默认32位及CNTw=8配置分别截断。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测sa_dat_o, sa_ack_o, sa_err_o, sa_rty_o, irq；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。

## T-002

feature_ids: F-002

requirement_ids: R-32C4343634EF-002

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。持续stb至少六拍并每拍改变写数据，交替cyc、遍历sel/tag，读回证明ack低拍也写入；再插入stb=0拍。

expected: 每个非复位上升沿ack_next=sa_stb_i AND NOT old_ack。读写仅以sa_stb_i及sa_we_i使能；sa_cyc_i、sa_sel_i、sa_tag_i均不影响操作。 ack是寄存输出；stb连续为1时每拍交替1/0，ack=0的拍仍执行读写。 stb=0令下一ack=0；cyc=0、sel=0仍可以写完整寄存器。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测sa_ack_o, sa_dat_o；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。

## T-003

feature_ids: F-003

requirement_ids: R-32C4343634EF-003

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。依次写读地址0/1/2，使用高低位不同数据和counter近最大值，遍历非法地址3..7；在运行计数期间同拍load并随后读回。

expected: 地址0是控制/ISR，1是counter，2是compare。stb=1且we=1时写；地址1/2取数据低CNTw位。其它地址写无效果。 写在上升沿执行，counter load优先于同拍正常计数。 Aw=3的非法地址3..7不改变配置、counter load或compare；counter仍可按原配置正常计数。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测sa_dat_o, irq；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。

## T-004

feature_ids: F-004

requirement_ids: R-32C4343634EF-004

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。先设置可辨识的配置/counter/compare，再交替读三个地址及非法地址、插入无stb或写拍；使counter在读同沿增加，核对返回沿前值并验证读寄存器保持。

expected: stb=1且we=0的上升沿：地址0采样旧{ISR,configuration}、1采样旧counter、2采样旧compare；其它地址保持旧read。sa_dat_o是CNTw位read零扩展至Dw。 读出是寄存的，读与同拍计数更新并行，读旧状态；无读操作时保持。 不是组合地址mux；CNTw=8时输出高24位必须0。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测sa_dat_o；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。

## T-005

feature_ids: F-005

requirement_ids: R-32C4343634EF-005

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。两个配置逐位写控制位、遍历全部divider选择与八种低控制组合，控制写同沿安排原配置应计数或不计数，并读回配置。

expected: 令D=ceil(log2(PRESCALER_WIDTH))，configuration低D+3位按从低到高为enable、int_enable、reset_on_compare、D位divider选择s；紧接的bit D+3为ISR。地址0写替换低配置位。 当前沿计数和事件使用旧配置；新配置从随后状态转换生效。 PRESCALER_WIDTH=8时D=3、ISR位6；宽度4时D=2、ISR位5。其它写高位忽略。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测sa_dat_o, irq；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。

## T-006

feature_ids: F-006

requirement_ids: R-32C4343634EF-006

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。遍历两个参数配置的全部s；从复位开始使能并持续足够多拍，读取counter核对每个tick的间距；插入disable后再enable证明相位保持。

expected: 选择s=0时终值T=0，s>0时T=2^(s-1)。tick是旧prescaler低PRESCALER_WIDTH-1位等于T。enable=1时tick则prescaler清0，否则prescaler加1；enable=0保持prescaler。 所有判定使用沿前状态；最高prescaler位不参与tick。 divider不是简单2^s周期；s=0时使能后的每拍均tick，s>0从相位0开始每T+1拍tick。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测sa_dat_o；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。

## T-007

feature_ids: F-007

requirement_ids: R-32C4343634EF-007

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。compare取0/1/3/全1，遍历enable、reset_on_compare和divider；load counter为compare-1/compare/compare+1及最大值，观察匹配后清零、非reset_on_compare时越过比较和自然溢出。

expected: enable=1且tick时，若reset_on_compare=1且旧counter==旧compare则counter_next=0，否则counter_next=(counter+1) mod 2^CNTw；未tick或disable时保持。 比较的是增加前counter，不是在增加后立即清0。 load覆盖正常counter更新；compare写只更新compare，当前拍仍按旧compare作判断。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测sa_dat_o；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。

## T-008

feature_ids: F-008

requirement_ids: R-32C4343634EF-008

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。分别设置int_enable/reset_on_compare/enable的组合，准备counter==compare、divider终值或非终值，比较irq；禁用timer但允许中断时仍制造匹配事件，随后撤int_enable并核对清除。

expected: 没有控制写时ISR_next=old_int_enable AND (old_ISR OR (tick AND reset_on_compare AND old_counter==old_compare))；irq=ISR。 IRQ寄存更新，使用旧配置和旧计数；事件本身不要求enable=1。 int_enable=0会在普通下一沿清ISR；reset_on_compare=0时即使匹配也不产生该事件。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测irq；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。

## T-009

feature_ids: F-009

requirement_ids: R-32C4343634EF-009

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。先通过合法输入产生ISR=1，再写ISR位0与1并读回；安排匹配事件与控制写同沿，分别写新int_enable=0/1并比较irq。

expected: 地址0控制写时ISR_next=old_ISR AND NOT sa_dat_i[D+3]，该写覆盖普通中断事件；写0保留旧ISR，写1清除。配置低位同时更新。 控制写当前沿即使发生新事件也不置位ISR；不能使用新int_enable生成同拍事件。 同拍ISR写0保持一个已存在ISR，即使新int_enable=0；随后无控制写的普通沿才依普通规则清除。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测sa_dat_o, irq；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。

## T-010

feature_ids: F-010

requirement_ids: R-32C4343634EF-010

stimulus: 每个公开参数配置先施加高有效异步reset并释放，所有驱动输入为确定二态。两配置执行完整寄存器/分频/中断流程，包含reset、非法地址、cyc=0、sel=0和最大计数；每次采样均比较err/rty恒0。

expected: 固定测试矩阵是PRESCALER_WIDTH=8,CNTw=32及PRESCALER_WIDTH=4,CNTw=8；两者Dw=32,Aw=3,SELw=4,TAGw=3。sa_err_o=sa_rty_o=0在全部状态成立。 常量输出不随时钟、reset、总线访问、匹配或IRQ改变。 不要求支持未公开参数组合；32位配置必须真实保留并通过近溢出load测试，不能只测缩小配置。

checker: 使用仅由已驱动输入及其历史计算的独立SystemVerilog模型预测sa_dat_o, sa_ack_o, sa_err_o, sa_rty_o, irq；每次输入稳定后、上升沿NBA稳定后、下降沿后和沿间复位脉冲期间比较所有相关输出，未知期望或任一失配用UVM_ERROR报告。绝不读取DUT内部状态或以实际输出回灌期望。
