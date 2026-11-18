# Native ports

|Port|Direction|Width|
|---|---|---|
|operator_i|input|7|
|operand_a_i|input|32|
|operand_b_i|input|32|
|instr_first_cycle_i|input|1|
|multdiv_operand_a_i|input|33|
|multdiv_operand_b_i|input|33|
|multdiv_sel_i|input|1|
|imd_val_q_i|input|64|
|imd_val_d_o|output|64|
|imd_val_we_o|output|2|
|adder_result_o|output|32|
|adder_result_ext_o|output|34|
|result_o|output|32|
|comparison_result_o|output|1|
|is_equal_result_o|output|1|

## Parameters

```json
[
  {
    "RV32B": 0
  },
  {
    "RV32B": 1
  },
  {
    "RV32B": 2
  },
  {
    "RV32B": 3
  }
]
```
