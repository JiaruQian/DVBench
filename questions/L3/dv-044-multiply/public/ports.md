# Native ports

|Port|Direction|Width|
|---|---|---|
|clk|input|1|
|reset|input|1|
|a_tdata|input|WIDTH_A|
|a_tlast|input|1|
|a_tvalid|input|1|
|a_tready|output|1|
|b_tdata|input|WIDTH_B|
|b_tlast|input|1|
|b_tvalid|input|1|
|b_tready|output|1|
|p_tdata|output|WIDTH_P|
|p_tlast|output|1|
|p_tvalid|output|1|
|p_tready|input|1|

## Parameters

```json
[
  {
    "WIDTH_A": 16,
    "WIDTH_B": 16,
    "WIDTH_P": 31,
    "DROP_TOP_P": 1,
    "LATENCY": 3,
    "EN_SATURATE": 0,
    "EN_ROUND": 0,
    "SIGNED": 1
  },
  {
    "WIDTH_A": 16,
    "WIDTH_B": 16,
    "WIDTH_P": 31,
    "DROP_TOP_P": 1,
    "LATENCY": 0,
    "EN_SATURATE": 0,
    "EN_ROUND": 0,
    "SIGNED": 1
  },
  {
    "WIDTH_A": 16,
    "WIDTH_B": 16,
    "WIDTH_P": 31,
    "DROP_TOP_P": 1,
    "LATENCY": 4,
    "EN_SATURATE": 0,
    "EN_ROUND": 0,
    "SIGNED": 1
  },
  {
    "WIDTH_A": 16,
    "WIDTH_B": 16,
    "WIDTH_P": 16,
    "DROP_TOP_P": 1,
    "LATENCY": 3,
    "EN_SATURATE": 0,
    "EN_ROUND": 1,
    "SIGNED": 1
  },
  {
    "WIDTH_A": 16,
    "WIDTH_B": 16,
    "WIDTH_P": 16,
    "DROP_TOP_P": 1,
    "LATENCY": 3,
    "EN_SATURATE": 1,
    "EN_ROUND": 0,
    "SIGNED": 1
  },
  {
    "WIDTH_A": 16,
    "WIDTH_B": 16,
    "WIDTH_P": 16,
    "DROP_TOP_P": 1,
    "LATENCY": 1,
    "EN_SATURATE": 1,
    "EN_ROUND": 1,
    "SIGNED": 1
  },
  {
    "WIDTH_A": 16,
    "WIDTH_B": 16,
    "WIDTH_P": 32,
    "DROP_TOP_P": 0,
    "LATENCY": 2,
    "EN_SATURATE": 0,
    "EN_ROUND": 0,
    "SIGNED": 0
  },
  {
    "WIDTH_A": 8,
    "WIDTH_B": 12,
    "WIDTH_P": 20,
    "DROP_TOP_P": 0,
    "LATENCY": 1,
    "EN_SATURATE": 0,
    "EN_ROUND": 0,
    "SIGNED": 1
  },
  {
    "WIDTH_A": 16,
    "WIDTH_B": 16,
    "WIDTH_P": 31,
    "DROP_TOP_P": 1,
    "LATENCY": 3,
    "EN_SATURATE": 0,
    "EN_ROUND": 1,
    "SIGNED": 1
  },
  {
    "WIDTH_A": 16,
    "WIDTH_B": 16,
    "WIDTH_P": 31,
    "DROP_TOP_P": 1,
    "LATENCY": 3,
    "EN_SATURATE": 1,
    "EN_ROUND": 1,
    "SIGNED": 1
  }
]
```
