# Native Interface

Top level `pong_top`. Only the following ports, with all indices in descending order and no indices for single-bit ports.

|Name|Direction|Bit width|
|---|---|---|
|clk|In|1|
|reset_n|In|1|
|btn|In|2|
|rx|In|1|
|vga_hsync|Out|1|
|vga_vsync|Out|1|
|vga_rgb|Out|3|

Fixed parameters: {}.
The clock period is 10ns, and inputs are established after the falling edge; asynchronous reset may change between edges. Port stability windows and boundaries are governed by spec.
