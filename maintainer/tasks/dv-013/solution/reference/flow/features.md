# Feature List

## F-001

requirement_ids: R-32C4343634EF-001

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_dat_i, sa_addr_i, sa_dat_o, sa_ack_o, sa_err_o, sa_rty_o, irq

definition: reset高有效且异步。复位将counter=0、compare=2^CNTw-1、prescaler=0、控制配置=0、ISR=0、read=0、ack=0。sa_err_o和sa_rty_o始终为0。

timing: 不需要clk上升沿；释放reset本身不更新状态。

boundary: 复位优先于同拍读写、计数和IRQ事件；默认32位及CNTw=8配置分别截断。

## F-002

requirement_ids: R-32C4343634EF-002

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_cyc_i, sa_sel_i, sa_tag_i, sa_dat_i, sa_addr_i, sa_ack_o, sa_dat_o

definition: 每个非复位上升沿ack_next=sa_stb_i AND NOT old_ack。读写仅以sa_stb_i及sa_we_i使能；sa_cyc_i、sa_sel_i、sa_tag_i均不影响操作。

timing: ack是寄存输出；stb连续为1时每拍交替1/0，ack=0的拍仍执行读写。

boundary: stb=0令下一ack=0；cyc=0、sel=0仍可以写完整寄存器。

## F-003

requirement_ids: R-32C4343634EF-003

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_addr_i, sa_dat_i, sa_dat_o, irq

definition: 地址0是控制/ISR，1是counter，2是compare。stb=1且we=1时写；地址1/2取数据低CNTw位。其它地址写无效果。

timing: 写在上升沿执行，counter load优先于同拍正常计数。

boundary: Aw=3的非法地址3..7不改变配置、counter load或compare；counter仍可按原配置正常计数。

## F-004

requirement_ids: R-32C4343634EF-004

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_addr_i, sa_dat_i, sa_dat_o

definition: stb=1且we=0的上升沿：地址0采样旧{ISR,configuration}、1采样旧counter、2采样旧compare；其它地址保持旧read。sa_dat_o是CNTw位read零扩展至Dw。

timing: 读出是寄存的，读与同拍计数更新并行，读旧状态；无读操作时保持。

boundary: 不是组合地址mux；CNTw=8时输出高24位必须0。

## F-005

requirement_ids: R-32C4343634EF-005

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_addr_i, sa_dat_i, sa_dat_o, irq

definition: 令D=ceil(log2(PRESCALER_WIDTH))，configuration低D+3位按从低到高为enable、int_enable、reset_on_compare、D位divider选择s；紧接的bit D+3为ISR。地址0写替换低配置位。

timing: 当前沿计数和事件使用旧配置；新配置从随后状态转换生效。

boundary: PRESCALER_WIDTH=8时D=3、ISR位6；宽度4时D=2、ISR位5。其它写高位忽略。

## F-006

requirement_ids: R-32C4343634EF-006

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_addr_i, sa_dat_i, sa_dat_o

definition: 选择s=0时终值T=0，s>0时T=2^(s-1)。tick是旧prescaler低PRESCALER_WIDTH-1位等于T。enable=1时tick则prescaler清0，否则prescaler加1；enable=0保持prescaler。

timing: 所有判定使用沿前状态；最高prescaler位不参与tick。

boundary: divider不是简单2^s周期；s=0时使能后的每拍均tick，s>0从相位0开始每T+1拍tick。

## F-007

requirement_ids: R-32C4343634EF-007

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_addr_i, sa_dat_i, sa_dat_o

definition: enable=1且tick时，若reset_on_compare=1且旧counter==旧compare则counter_next=0，否则counter_next=(counter+1) mod 2^CNTw；未tick或disable时保持。

timing: 比较的是增加前counter，不是在增加后立即清0。

boundary: load覆盖正常counter更新；compare写只更新compare，当前拍仍按旧compare作判断。

## F-008

requirement_ids: R-32C4343634EF-008

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_addr_i, sa_dat_i, irq

definition: 没有控制写时ISR_next=old_int_enable AND (old_ISR OR (tick AND reset_on_compare AND old_counter==old_compare))；irq=ISR。

timing: IRQ寄存更新，使用旧配置和旧计数；事件本身不要求enable=1。

boundary: int_enable=0会在普通下一沿清ISR；reset_on_compare=0时即使匹配也不产生该事件。

## F-009

requirement_ids: R-32C4343634EF-009

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_addr_i, sa_dat_i, sa_dat_o, irq

definition: 地址0控制写时ISR_next=old_ISR AND NOT sa_dat_i[D+3]，该写覆盖普通中断事件；写0保留旧ISR，写1清除。配置低位同时更新。

timing: 控制写当前沿即使发生新事件也不置位ISR；不能使用新int_enable生成同拍事件。

boundary: 同拍ISR写0保持一个已存在ISR，即使新int_enable=0；随后无控制写的普通沿才依普通规则清除。

## F-010

requirement_ids: R-32C4343634EF-010

module: timer

interface: clk, reset, sa_stb_i, sa_we_i, sa_cyc_i, sa_sel_i, sa_tag_i, sa_addr_i, sa_dat_i, sa_dat_o, sa_ack_o, sa_err_o, sa_rty_o, irq

definition: 固定测试矩阵是PRESCALER_WIDTH=8,CNTw=32及PRESCALER_WIDTH=4,CNTw=8；两者Dw=32,Aw=3,SELw=4,TAGw=3。sa_err_o=sa_rty_o=0在全部状态成立。

timing: 常量输出不随时钟、reset、总线访问、匹配或IRQ改变。

boundary: 不要求支持未公开参数组合；32位配置必须真实保留并通过近溢出load测试，不能只测缩小配置。
