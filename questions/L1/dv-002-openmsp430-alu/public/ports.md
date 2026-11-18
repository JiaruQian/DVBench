# Native Interface

Module name: `omsp_alu`. No parameters.

|Port|Direction|Width/Indices|
|---|---|---|
|dbg_halt_st|input|1|
|exec_cycle|input|1|
|inst_alu|input|[11:0]|
|inst_bw|input|1|
|inst_jmp|input|[7:0]|
|inst_so|input|[7:0]|
|op_dst|input|[15:0]|
|op_src|input|[15:0]|
|status|input|[3:0]|
|alu_out|output|[15:0]|
|alu_out_add|output|[15:0]|
|alu_stat|output|[3:0]|
|alu_stat_wr|output|[3:0]|
