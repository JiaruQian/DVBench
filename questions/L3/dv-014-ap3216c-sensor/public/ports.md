# Native ports and fixed parameters

Top level `ap3216c_top`. SLAVE_ADDR=7'h1e, BIT_CTRL=1'b0, CLK_FREQ=50000000, I2C_FREQ=250000, all using default values.

| Name | Direction | Width/indices | Description |
|---|---|---|---|
| sys_clk | input | 1 | 50MHz system rising-edge clock |
| sys_rst_n | input | 1 | Asynchronous active-low reset |
| ap_scl | output | 1 | I2C master serial clock |
| ap_sda | inout | 1 | resolved bidirectional serial data; an external pull-up is provided, and the slave only pulls down to 0 or releases |
| led | output | [3:0] | PS range indicator LEDs |
| sel | output | [5:0] | Six-digit active-low scan digit select |
| seg_led | output | [7:0] | Active-low seven-segment and decimal-point code |

There are no other native ports. The model must have identically named ports and the same parameters, directions, and widths; both input and drive on native inout ports must be handled correctly, and DUT drive must not be copied onto the prediction bus.
