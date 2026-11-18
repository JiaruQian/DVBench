## F-111-001

requirement_ids: R-N111-001

module: sha3_mmio

definition: clk上升沿工作，rst高异步复位清空所有消息存储、保留填充区、结果和DONE，LANE_COUNT=1、LAST_BYTECNT=8。只定义LANE_COUNT在1..17且LAST_BYTECNT在1..8的完整单块事务；操作从START写入到DONE期间保持数据与配置不写，允许读和重复START。输入在下降沿后改变，上升沿后稳定采样。

interface: clk, rst, addr, wdata, we, rd, rdata

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-111-002

requirement_ids: R-N111-002

module: sha3_mmio

definition: we=1在上升沿写入，仅addr低8位解码。00..87写17个64位lane，addr[7:3]选lane，bit2选高低32位，低2位忽略。88写LANE_COUNT低5位，8C写LAST_BYTECNT低4位；这些配置不可读。rd=0或未映射读返回0。rd=1时94返回DONE，A0/A4/…/BC分别返回digest低32位到高32位；精确读地址的低2位必须为0。无读副作用，读写可同时。

interface: clk, addr, wdata, we, rd, rdata

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-111-003

requirement_ids: R-N111-003

module: sha3_mmio

definition: 90写wdata.bit0=1生成一拍延迟的START；FSM在下一上升沿仅空闲或已完成时接受，清DONE而保留旧digest；忙时START被忽略，不排队。接受沿为t0，无中途复位时DONE及新digest恰在t0+LANE_COUNT+30个上升沿后更新；DONE保持至下一次接受或复位。连续写START若跨过完成沿则按当时状态接受。

interface: clk, rst, addr, wdata, we, rd, rdata

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-111-004

requirement_ids: R-N111-004

module: sha3_mmio

definition: 每lane输入字节按63:56、55:48直到7:0依次作为消息字节；映射Keccak lane低字节起。最后lane仅取LAST_BYTECNT个高位字节，少于8时紧随有效字节放06并清其余高字节；等于8时本实现不额外放06。lane16的最高bit总置1；若最后lane不是16则lane16直接为8000000000000000。未被本次消息覆盖的lane0..15保留上次填充内容；复位清除。该历史行为也适用于较短后继消息，不能默认每次清空。

interface: clk, rst, addr, wdata, we, rd, rdata

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-111-005

requirement_ids: R-N111-005

module: sha3_mmio

definition: 以17个填充lane置Keccak-f1600的低1088位，其余512位为0，lane(x,y)线性编号x+5*y。执行标准24轮theta/rho/pi/chi/iota，不吸收前次状态；输出前四个lane各自字节反转，按lane0至lane3排列为256位digest从高到低。Keccak采用标准FIPS202旋转偏移及轮常数。注意上述满lane填充与保留区是本实现合同，不能对所有历史直接套标准SHA3消息API。

interface: clk, rst, addr, wdata, we, rd, rdata

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。
