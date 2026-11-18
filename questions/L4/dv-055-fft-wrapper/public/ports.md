# Native Interface

Top level: `fft_wrapper`. This task uses a fixed default parameter configuration; interface directions and bit widths correspond to the selected RTL root.

|Port|Direction|Bit width|Purpose|
|---|---|---:|---|
|`clk`|input|1|External clock|
|`rst`|input|1|Asynchronous active-high reset|
|`m_addr`|input|5|Input RAM address|
|`m_data`|input|16|Q8.8 real input sample|
|`m_we`|input|1|Input RAM write enable|
|`s_addr`|input|5|Output RAM address|
|`s_re`|input|1|Output RAM read enable|
|`s_data`|output|32|{real part[31:16],imaginary part[15:0]} complex output|

Fixed parameters:
- `DIVISOR=5`
- `N=16`
- `Q=8`
- `ADDR_WIDTH=5`
- `DATA_WIDTH=16`
- `DEPTH=32`
