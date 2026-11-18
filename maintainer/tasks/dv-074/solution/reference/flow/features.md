## F-113-001

requirement_ids: R-N113-001

module: fpu_sqrt

definition: 本模块是平方根的前规格化有效数数据通路，不是完整IEEE754平方根：没有符号、NaN/Inf处理或最终舍入；固定无参数。仅sqrt_done=1的稳定窗口要求检查sig/exp/uf，sqrt_done每拍均检查。

interface: sqrt_done, sqrt_proNorm_sig, sqrt_proNorm_exp, uf

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-113-002

requirement_ids: R-N113-002

module: fpu_sqrt

definition: reset下降立即取消运算并使sqrt_done=0；复位保持期间不接受start，释放后可重新发起。结果数据只在done有效窗口有检查义务。

interface: clk, reset, start, sqrt_done

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-113-003

requirement_ids: R-N113-003

module: fpu_sqrt

definition: 空闲上升沿采到start=1后进入装载阶段；下一上升沿才采in_sig以及由is_subnormal、in_exp0决定的缩放。忙时start不排队；回到空闲后持续高start会在下一沿重新启动。

interface: clk, reset, start, in_sig, is_subnormal, in_exp0, sqrt_done

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-113-004

requirement_ids: R-N113-004

module: fpu_sqrt

definition: 接受start的沿为第0沿，第1沿装载，随后44沿迭代，第46沿sqrt_done=1且完整结果有效；done为单拍，下一沿清零，start持续高可在该下一沿接受。

interface: clk, start, sqrt_done

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-113-005

requirement_ids: R-N113-005

module: fpu_sqrt

definition: 装载时A为88位无符号数：is_subnormal=0且in_exp0=0时A=in_sig乘2^64，其余A=in_sig乘2^63。完成的44位R=floor(sqrt(A))；不得用实际DUT输出反推。

interface: is_subnormal, in_exp0, in_sig, sqrt_done, sqrt_proNorm_sig

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-113-006

requirement_ids: R-N113-006

module: fpu_sqrt

definition: 完成窗口且当前is_subnormal=0时，sqrt_proNorm_sig={R[43:18],OR(R[17:0])}，exp=当前exp_half，uf=0。这里包括所有in_sig取值，不假定隐含位一定为1。

interface: is_subnormal, exp_half, sqrt_proNorm_sig, sqrt_proNorm_exp, uf

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-113-007

requirement_ids: R-N113-007

module: fpu_sqrt

definition: 当前is_subnormal=1时，L为R的44位前导零数（R=0时L=44），N=(R<<L)截为44位，exp=(当前exp_half-L)模256，uf=!N[43]。rounding_mode!=3时sig={N[43:18],OR(N[17:0])}。

interface: is_subnormal, exp_half, rounding_mode, sqrt_proNorm_sig, sqrt_proNorm_exp, uf

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。

## F-113-008

requirement_ids: R-N113-008

module: fpu_sqrt

definition: 当前次正规且rounding_mode=3时sig={N[43:20],R[19:18],OR(R[17:0])}，低三位取未规格化R；模式编码只在此选择投影，不执行加一舍入。输出分类、指数和模式为当前输入的组合值，需在done窗口稳定后采样。

interface: is_subnormal, rounding_mode, exp_half, sqrt_proNorm_sig, sqrt_proNorm_exp

timing: 按该行为明确的沿间、采样沿和组合稳定窗口观察。

boundary: 仅固定默认参数和该行为明确的合法输入历史；未定义输出不扩张为检查义务。
