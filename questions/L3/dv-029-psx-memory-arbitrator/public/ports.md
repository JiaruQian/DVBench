# Native Interface

Module `MemoryArbitrator`; only the fixed default configuration for this problem.

|Port|Direction|Width|Index|
|---|---|---|---|
|ClutCacheData|output|32|[31:0]|
|ClutCacheWrite|output|1|scalar|
|ClutWriteIndex|output|3|[2:0]|
|TexCacheData|output|64|[63:0]|
|TexCacheWrite|output|1|scalar|
|ack_i|input|1|scalar|
|adrClutCacheUpdate|input|15|[14:0]|
|adrTexCacheUpdateL|input|17|[16:0]|
|adrTexCacheUpdateR|input|17|[16:0]|
|adrTexCacheWrite|output|17|[16:0]|
|adr_o|output|20|[19:0]|
|cnt_o|output|3|[2:0]|
|dat_i|input|32|[31:0]|
|dat_o|output|32|[31:0]|
|exportedBGBlock|input|256|[255:0]|
|exportedMSKBGBlock|input|16|[15:0]|
|fifoComplete|output|1|scalar|
|fifoFull|output|1|scalar|
|gpuClk|input|1|scalar|
|i_nRst|input|1|scalar|
|importBGBlockSingleClock|output|1|scalar|
|importedBGBlock|output|256|[255:0]|
|isBlending|input|1|scalar|
|loadAdr|input|15|[14:0]|
|memoryWriteCommand|input|56|[55:0]|
|req_o|output|1|scalar|
|requClutCacheUpdate|input|1|scalar|
|requTexCacheUpdateL|input|1|scalar|
|requTexCacheUpdateR|input|1|scalar|
|resetMask|output|1|scalar|
|resetPipelinePixelStateSpike|output|1|scalar|
|saveAdr|input|15|[14:0]|
|saveBGBlock|input|2|[1:0]|
|saveLoadOnGoing|output|1|scalar|
|sel_o|output|4|[3:0]|
|updateClutCacheComplete|output|1|scalar|
|updateTexCacheCompleteL|output|1|scalar|
|updateTexCacheCompleteR|output|1|scalar|
|wrt_o|output|1|scalar|

Only fixed default parameters: {}