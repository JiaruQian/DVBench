# Native Interface

Top level `AesCTR`; no top-level parameters. Clock `clk`, reset `rst`, active value 1. All multibit indices are [width−1:0].

|Port|Direction|Bit width|
|---|---|---|
|clk|In|1|
|rst|In|1|
|load|In|1|
|start|In|1|
|key|In|128|
|iv|In|128|
|iBlock|In|128|
|oBlock|Out|128|
|idle|Out|1|
