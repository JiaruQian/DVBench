# Native Interface

Module name: `top`. No parameters.

|Port|Direction|Width/Indices|
|---|---|---|
|screen|input|[1:0]|
|opcode|input|[2:0]|
|A|input|[3:0]|
|B|input|[3:0]|
|carry_in|input|1|
|carry_out|output|1|
|overflow|output|1|
|bcd|output|[11:0]|
|error|output|1|
