# Feature List

## F-001

requirement_ids: R-ALU-001

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, instr_first_cycle_i, multdiv_operand_a_i, multdiv_operand_b_i, multdiv_sel_i, imd_val_q_i, imd_val_d_o, imd_val_we_o, adder_result_o, adder_result_ext_o, result_o, comparison_result_o, is_equal_result_o

definition: 顶层 ibex_alu_mut 是无时钟、无内部状态的组合接口。operator_i[6:0]、operand_a_i/operand_b_i[31:0]、instr_first_cycle_i、multdiv_operand_a_i/multdiv_operand_b_i[32:0]、multdiv_sel_i、imd_val_q_i[63:0] 为输入。输出 imd_val_d_o[63:0]、imd_val_we_o[1:0]、adder_result_o[31:0]、adder_result_ext_o[33:0]、result_o[31:0]、comparison_result_o、is_equal_result_o。分别验证 RV32B=0、1、2、3，默认值0；每个实例参数编译时固定。所有输入使用确定的二态值，任意 opcode 0..127 均允许；未知或禁用的功能其 result_o 为0，但其它输出仍遵循各自规则。instr_first_cycle_i 和 imd_val_q_i 是外部提供的组合输入，不代表模块内部寄存器，也不强制它们来自先前 DUT 输出。

timing: 驱动输入后等待组合传播稳定，逐次比较全部七个输出；没有复位、时钟沿或 ready/valid 握手。

boundary: 包含所有128种 opcode、RV32B四种取值、全零/全一/符号边界、任意IMD和33位旁路；不测试X/Z或delta传播中的暂态。

## F-002

requirement_ids: R-ALU-002

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, multdiv_operand_a_i, multdiv_operand_b_i, multdiv_sel_i, adder_result_o, adder_result_ext_o, result_o

definition: 构造33位加数A={operand_a_i,1}、B={operand_b_i,0}。opcode为1、25..34、43、44时逐位取反整个33位B。RV32B非0且opcode22/23/24时，A先将32位operand_a_i左移1/2/3位截断为32位，再追加低位1。multdiv_sel_i=1优先把两加数替换为相应33位multdiv输入。adder_result_ext_o是两个33位无符号数相加的34位全结果，adder_result_o取该结果[32:1]；opcode0、1、22、23、24的result_o等于adder_result_o。

timing: 上述加法侧输出对所有opcode持续有效，与result_o选择独立；旁路改变后在组合稳定时比较。

boundary: 覆盖进位、借位、移位截断、两个33位全一相加、旁路与减法/移位同时开启；RV32B=0的22..24按普通加法。

## F-003

requirement_ids: R-ALU-003

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, multdiv_operand_a_i, multdiv_operand_b_i, multdiv_sel_i, adder_result_o, comparison_result_o, is_equal_result_o, result_o

definition: is_equal_result_o始终表示adder_result_o为0，不在所有opcode下都表示两原始操作数相等。opcode25、27、31、33、43采用有符号比较控制。两操作数符号相同时，GE取adder_result_o最高位的反；符号不同时，GE取operand_a_i最高位异或有符号控制。opcode29比较标志为equal、30为非equal；27/28/33/34为GE；25/26/31/32/43/44为非GE，其它opcode比较标志为equal。opcode25..30及43/44的result_o为该标志零扩展至32位。旁路可以改变加法器和相等/同符号比较标志。

timing: 在同一个稳定窗口比较比较侧输出与result_o；即使opcode不是比较指令也核对两侧标志。

boundary: 包含相等、不等、正负异号、同号溢出和旁路；不能把所有opcode的equal替换为a==b。

## F-004

requirement_ids: R-ALU-004

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, instr_first_cycle_i, result_o

definition: opcode3/6执行OR，4/7执行AND，2/5执行XOR。RV32B非0时5/6/7先取反32位B；RV32B=0则不取反。对opcode2和5，operand_a_i恰为十六进制cafef00d时，正常XOR结果再翻转最低位；cafef00c不触发。此特例是本题固定的可观察行为，不推断其设计意图。

timing: 组合稳定后比较result_o，first对这六个逻辑opcode无影响。

boundary: 明确包含cafef00d、cafef00c、0、全一和交替位；区分OR与AND、取反与不取反。

## F-005

requirement_ids: R-ALU-005

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, instr_first_cycle_i, result_o

definition: 基本移位量在first=1时为B低5位，first=0时为(32-B低5位)模32；这条规则同样适用于RV32B=0。opcode10左移、9逻辑右移、8算术右移；opcode11/12在RV32B=2或3时分别为补一右移/补一左移。RV32B=0或1时11、12都退化为逻辑右移。移出位丢弃，算术右移按A符号位扩展。

timing: first是当前组合输入，翻转它后应重新计算移位量，没有隐含周期状态。

boundary: 移位低5位为0、1、15、16、31；低5位0的补量仍为0；包含负数和全一。

## F-006

requirement_ids: R-ALU-006

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, multdiv_operand_a_i, multdiv_operand_b_i, multdiv_sel_i, comparison_result_o, result_o

definition: RV32B非0时opcode31/32为有符号/无符号min，33/34为max，具体选择按comparison_result_o为1选A否则B。35输出{B低16,A低16}，36输出{B高16,A高16}，37输出{16位零,B低8,A低8}；38/39将A低8/16位符号扩展。40/41计算A的前导零/尾随零数，A=0时为32；42计算A置位数。RV32B=0时这些result_o均为0。

timing: 均为组合函数；最值选择仍受比较器旁路行为影响。

boundary: 0的零计数为32，全一置位数32，单个置位逐位遍历，符号扩展最高有效符号位，最值相等和异号。

## F-007

requirement_ids: R-ALU-007

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, instr_first_cycle_i, result_o

definition: RV32B非0时15为GREv、16为GORC：从A开始，对距离1/2/4/8/16的位对按有效移位量对应控制位交换；GORC在交换结果上按位OR交换前值。RV32B=1时控制低3位均复制移位量bit0，高2位均复制bit3；GORC的距离8/16只交换不OR。RV32B=2/3才支持17/18的shuffle/unshuffle及19/20/21的4/8/16位元素置换，其余参数这些结果为0。shuffle按距离8/4/2/1的顺序，在每个4d位块内交换中间两组d位，分别受移位量bit3/2/1/0控制。unshuffle先把每一位的五位索引反序，再以控制位0/1/2/3做同样四阶段，最后再次反序索引。元素置换把B每个4/8/16位元素看作索引，选A中相同宽度的对应元素；超出元素数的索引输出0。

timing: 移位量遵循first补量规则；元素置换使用完整B元素而非该移位量。

boundary: 全部控制组合、元素索引最大合法值与越界值、非对称及随机位模式、RV32B能力差异。

## F-008

requirement_ids: R-ALU-008

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, instr_first_cycle_i, result_o

definition: RV32B非0时49/50/51在A上置位/清位/翻转有效移位量指定的bit，52提取该bit至bit0并将其余位清零。55为位域插入：长度取B[27:24]，该4位全0表示16；偏移为B[20:16]，不随first变化。将A对应的长度位窗口清零，再把B低length位移到偏移处OR入；超出bit31部分丢弃。RV32B=0时这些result_o为0。

timing: 单比特使用first补量规则，位域偏移独立于first。

boundary: 偏移0/31、长度1/15/16、超过字长的窗口截断、置位前bit原为0/1。

## F-009

requirement_ids: R-ALU-009

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, result_o

definition: RV32B=2/3时，将A、B视为GF(2)多项式，按按位AND和异或相加得到64位乘积，不产生普通整数进位。opcode56输出乘积[31:0]，57输出[62:31]，58输出[63:32]。RV32B=0/1输出0。

timing: 组合稳定后核对result_o，与first无关。

boundary: 0、1、最高位、稠密全一、稀疏及随机多项式，区分三个切片。

## F-010

requirement_ids: R-ALU-010

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, instr_first_cycle_i, imd_val_q_i, imd_val_d_o, imd_val_we_o, result_o

definition: RV32B非0时，通常imd_val_d_o={A,32位零}且we=0。45的result在B为0时选A，否则选IMD高32位，写数据为{A,0}；46以A AND (first时B、非first时非B)得到part，result=IMD高半OR part，写数据={part,0}。13/14分别为双步右/左旋转组成片段，47/48为双步funnel左/右片段；低移位量按first及Bbit5决定：funnel且Bbit5为1时，first用补量、非first用原低5位，否则相反。13的first右移/非first左移，14相反；47的Bbit5=0时first左移，bit5=1时first右移，48相反。低移位量为0时result取funnel且Bbit5为1时的A，否则IMD高半；非0时result=IMD高半OR移位片段，写数据={片段,0}。这些操作we仅在first=1时为01。RV32B=2/3的59..64为两步CRC片段：59/60输入低8位左移24，61/62低16位左移16，63/64完整A；first选该输入，否则选IMD高半。奇数opcode多项式为04c11db7、倒数常量f7011641，偶数为1edc6f41和dea713f1。first与倒数常量、否则与多项式做无进位乘法，取低32位后逐位反序为part；result在59/60额外异或A右移8、61/62额外异或A右移16，63/64直接part。写数据={part,0}，first时we=01否则0。RV32B=0所有IMD输出和上述result为0；RV32B=1不支持CRC，CRC result=0且IMD保持通常值。

timing: IMD由外部输入任意确定值，模块不保存片段；每次改变first/B/IMD都在组合稳定后检查。we位编号按端口比特给出，不推测外部存储银行命名。

boundary: B等于0或非0、移位量0/31、funnel bit5、first两值、IMD任意高低半、两种CRC多项式及8/16/32输入模式。

## F-011

requirement_ids: R-ALU-011

module: ibex_alu_mut

interface: operator_i, operand_a_i, operand_b_i, instr_first_cycle_i, imd_val_q_i, imd_val_d_o, imd_val_we_o, result_o

definition: 仅RV32B=3支持53/54。令C[i]为B[0..i]的置位数。IMD写数据高半第i位保存C[i]bit0；低半bit0..15保存C[2j+1]bit1，bit16..23保存C[4j+3]bit2，bit24..27保存C[8j+7]bit3，bit28..29保存C[16j+15]bit4，bit30保存C[31]bit5，bit31为0。first时we=11，否则0。结果的控制计数从输入IMD按上述布局解码，未在某索引保存的位视为0。对半块宽d=16、8、4、2、1及每个2d位块，取块内低半结束位置的解码计数低log2(d)+1位c；把d个1左移c形成2d位字，取其高d位逐位取反作为交换掩码，按掩码交换块内相距d位的位对。54从A开始按d降序交换，最终AND B；53先A AND B，再按d升序交换。其它RV32B的53/54 result=0，IMD为通常值且we=0。

timing: first仅控制写使能；结果始终使用当前输入IMD控制计数，而不是本次生成的写数据。

boundary: B全零/全一/稀疏/随机、任意IMD、first两值；区分53和54顺序、区分输入IMD与当前B计数。
