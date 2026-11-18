# Feature List

## F-001

requirement_ids: R-D82FE92CBEE6-001

module: s1196

interface: blif_clk_net, blif_reset_net, G0, G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, G546, G539, G550, G551, G552, G547, G548, G549, G530, G45, G542, G532, G535, G537

definition: 抽象状态q0..q17在blif_reset_net=1时全部为0；复位高有效且异步，优先于时钟更新。

timing: 沿间reset高脉冲立即清状态；释放本身不产生状态更新。

boundary: 复位并不保证所有输出0，复位期间组合输出仍按函数表以q=0和当前输入计算。

## F-002

requirement_ids: R-D82FE92CBEE6-002

module: s1196

interface: blif_clk_net, blif_reset_net, G0, G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, G546, G539, G550, G551, G552, G547, G548, G549, G530, G45, G542, G532, G535, G537

definition: 非复位的blif_clk_net上升沿，q0..q17各自同时更新为函数表“下一状态”根函数，所有函数使用沿前同一份q和G0..G13。

timing: 仅上升沿更新；下降沿与无沿输入变化保持状态。

boundary: 18位并行更新，不允许按q编号级联使用同拍新值；不存在事务valid或busy。

## F-003

requirement_ids: R-D82FE92CBEE6-003

module: s1196

interface: blif_clk_net, blif_reset_net, G0, G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, G45, G546

definition: G45=q16，G546=NOT q12，均依当前抽象状态。

timing: 这两个输出在状态更新或异步复位后组合稳定时有效。

boundary: 复位后G45=0而G546=1；不能把反相状态输出也清0。

## F-004

requirement_ids: R-D82FE92CBEE6-004

module: s1196

interface: G0, G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, blif_clk_net, blif_reset_net, G539, G550, G551, G552

definition: G539、G550、G551、G552分别等于完整布尔函数合同“输出”表中同名根函数；F0=0、F1=1，非终端F由对应v取低或高分支递归求值。

timing: v0..v13为当前G0..G13，v14..v31为当前q0..q17；输入稳定后组合输出立即有效，不等待时钟。

boundary: 二态输入域，所有表行语义均有效，不能只检查reset输入或少数常量。

## F-005

requirement_ids: R-D82FE92CBEE6-005

module: s1196

interface: G0, G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, blif_clk_net, blif_reset_net, G547, G548, G549

definition: G547、G548、G549分别等于完整布尔函数合同“输出”表同名根函数，条件节点v=0走低分支、v=1走高分支。

timing: 使用当前输入与当前状态，组合稳定后有效。

boundary: 不能把它们当作每拍寄存一遍的输出。

## F-006

requirement_ids: R-D82FE92CBEE6-006

module: s1196

interface: G0, G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, blif_clk_net, blif_reset_net, G530, G542, G532

definition: G530、G542、G532分别等于完整布尔函数合同“输出”表同名根函数，函数解释使用本拍当前状态及输入。

timing: 输出连续组合，沿间也有效。

boundary: 共享布尔条件可能影响多个输出，仍应逐个核对。

## F-007

requirement_ids: R-D82FE92CBEE6-007

module: s1196

interface: G0, G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, blif_clk_net, blif_reset_net, G535, G537

definition: G535、G537分别等于完整布尔函数合同“输出”表同名根函数。F条件选择语义与其它根函数一致，不引入额外模式。

timing: 组合稳定后有效，复位高时仍使用当前输入和q=0。

boundary: 输入全0、全1、单比特、单比特取反以及随机序列均在合同范围。

## F-008

requirement_ids: R-D82FE92CBEE6-008

module: s1196

interface: blif_clk_net, blif_reset_net, G0, G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, G546, G539, G550, G551, G552, G547, G548, G549, G530, G45, G542, G532, G535, G537

definition: 本设计只接收时钟、复位及14个二态数据输入；没有参数、ready、valid、enable或隐含交易门控。14个输出在全部稳定观察窗口都必须按当前输入历史预测。

timing: 每次输入改变后、上升沿NBA更新稳定后、下降沿后和沿间复位脉冲期间均可比较；首个复位前未知状态不评分。

boundary: 无需观测DUT内部状态；参考状态完全由初始复位和已驱动输入推导。
