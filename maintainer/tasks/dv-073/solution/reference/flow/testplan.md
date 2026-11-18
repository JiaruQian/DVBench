## T-111-001

feature_ids: F-111-001

requirement_ids: R-N111-001

stimulus: 在沿间断言复位并保持跨沿；释放后完成不同配置的事务，再在运算中复位取消它。

expected: clk上升沿工作，rst高异步复位清空所有消息存储、保留填充区、结果和DONE，LANE_COUNT=1、LAST_BYTECNT=8。只定义LANE_COUNT在1..17且LAST_BYTECNT在1..8的完整单块事务；操作从START写入到DONE期间保持数据与配置不写，允许读和重复START。输入在下降沿后改变，上升沿后稳定采样。

checker: 两上升沿之间断言rst，组合传播稳定后、下一上升沿前读取清零的DONE/全部结果；再比较跨沿保持、释放后事务及忙中取消。仅从合法输入与历史独立预测期望，monitor读取实际原生端口，逐位四态比较actual/expected，失配报告UVM_ERROR；累计比较次数和输出变化，缺少有效比较也报错，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-111-002

feature_ids: F-111-002

requirement_ids: R-N111-002

stimulus: 改变高地址位和数据写入低2位，写入互异高低半字；读全部8个结果字、94、未映射及rd=0；在读时保持we=0并比较。

expected: we=1在上升沿写入，仅addr低8位解码。00..87写17个64位lane，addr[7:3]选lane，bit2选高低32位，低2位忽略。88写LANE_COUNT低5位，8C写LAST_BYTECNT低4位；这些配置不可读。rd=0或未映射读返回0。rd=1时94返回DONE，A0/A4/…/BC分别返回digest低32位到高32位；精确读地址的低2位必须为0。无读副作用，读写可同时。

checker: 写输入在上升沿前稳定，写入在该沿后生效；每次改变addr/rd后等待组合传播稳定再读取rdata，分别检查rd=0、精确结果地址、别名和未映射读。仅从合法输入与历史独立预测期望，monitor读取实际原生端口，逐位四态比较actual/expected，失配报告UVM_ERROR；累计比较次数和输出变化，缺少有效比较也报错，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-111-003

feature_ids: F-111-003

requirement_ids: R-N111-003

stimulus: 完成初次运算后观察DONE保持和旧结果，写START=0不启动，写START=1启动并在忙时插入独立START，沿后持续读94至完成，核对精确延迟与复用。

expected: 90写wdata.bit0=1生成一拍延迟的START；FSM在下一上升沿仅空闲或已完成时接受，清DONE而保留旧digest；忙时START被忽略，不排队。接受沿为t0，无中途复位时DONE及新digest恰在t0+LANE_COUNT+30个上升沿后更新；DONE保持至下一次接受或复位。连续写START若跨过完成沿则按当时状态接受。

checker: 以沿前状态判定延迟START的接受沿t0；在接受、忙、完成和后续保持的每个上升沿NBA稳定后读取DONE，并在对应稳定读窗口比较旧/新结果。逐沿计数检验公开完成拍。仅从合法输入与历史独立预测期望，monitor读取实际原生端口，逐位四态比较actual/expected，失配报告UVM_ERROR；累计比较次数和输出变化，缺少有效比较也报错，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-111-004

feature_ids: F-111-004

requirement_ids: R-N111-004

stimulus: 覆盖最后有效字节数1..8、lane数1/16/17和中间值；先长后短不复位，再相同短消息先复位后运行；独立维护填充区预测差异。

expected: 每lane输入字节按63:56、55:48直到7:0依次作为消息字节；映射Keccak lane低字节起。最后lane仅取LAST_BYTECNT个高位字节，少于8时紧随有效字节放06并清其余高字节；等于8时本实现不额外放06。lane16的最高bit总置1；若最后lane不是16则lane16直接为8000000000000000。未被本次消息覆盖的lane0..15保留上次填充内容；复位清除。该历史行为也适用于较短后继消息，不能默认每次清空。

checker: 保持数据/配置不写直到DONE；长后短及复位对照各事务完成后，addr/rd稳定并等待组合传播后比较全部8个结果字与各自输入历史的填充期望。仅从合法输入与历史独立预测期望，monitor读取实际原生端口，逐位四态比较actual/expected，失配报告UVM_ERROR；累计比较次数和输出变化，缺少有效比较也报错，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv

## T-111-005

feature_ids: F-111-005

requirement_ids: R-N111-005

stimulus: 原生写入abc、全零、交替字节与随机消息；独立数学Keccak和公开填充历史形成预期，DONE后比较8个结果字；不读取DUT实际结果生成期望。

expected: 以17个填充lane置Keccak-f1600的低1088位，其余512位为0，lane(x,y)线性编号x+5*y。执行标准24轮theta/rho/pi/chi/iota，不吸收前次状态；输出前四个lane各自字节反转，按lane0至lane3排列为256位digest从高到低。Keccak采用标准FIPS202旋转偏移及轮常数。注意上述满lane填充与保留区是本实现合同，不能对所有历史直接套标准SHA3消息API。

checker: 完成前不把旧digest当新结果；DONE有效后，对8个精确结果字地址逐一等待组合传播稳定，比较完整256位数学期望及输出次序。仅从合法输入与历史独立预测期望，monitor读取实际原生端口，逐位四态比较actual/expected，失配报告UVM_ERROR；累计比较次数和输出变化，缺少有效比较也报错，禁止expected从actual回填。

implementation_id: native_sequence.body/native_monitor.run_phase/native_scoreboard.write

source: tb.sv:native_sequence.body; native_monitor.run_phase; native_scoreboard.write; model/model.sv
