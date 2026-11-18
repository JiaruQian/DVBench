# Native interface

|Port|Direction|Width|
|---|---|---|
|clk|input|1|
|reset|input|1|
|sa_dat_i|input|Dw|
|sa_sel_i|input|SELw|
|sa_addr_i|input|Aw|
|sa_tag_i|input|TAGw|
|sa_stb_i|input|1|
|sa_cyc_i|input|1|
|sa_we_i|input|1|
|sa_dat_o|output|Dw|
|sa_ack_o|output|1|
|sa_err_o|output|1|
|sa_rty_o|output|1|
|irq|output|1|

Fixed parameter matrix (an empty object means no parameters):
```json
[
  {
    "PRESCALER_WIDTH": 8,
    "Dw": 32,
    "Aw": 3,
    "SELw": 4,
    "TAGw": 3,
    "CNTw": 32
  },
  {
    "PRESCALER_WIDTH": 4,
    "Dw": 32,
    "Aw": 3,
    "SELw": 4,
    "TAGw": 3,
    "CNTw": 8
  }
]
```
