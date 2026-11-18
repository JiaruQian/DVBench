# Native Interface

The top level adbg_jsp_apb_module has no parameters. The PCLK period is 6ns and the tck_i period is 10ns; they run independently and continuously. data_register_i is a 64-bit external shared shift register. All vectors are descending, with no inout. See spec for reset polarities and valid windows.

|Port|Direction|Index|
|---|---|---|
|rst_i|input|scalar|
|tck_i|input|scalar|
|tdi_i|input|scalar|
|capture_dr_i|input|scalar|
|shift_dr_i|input|scalar|
|update_dr_i|input|scalar|
|data_register_i|input|[63:0]|
|module_select_i|input|scalar|
|PRESETn|input|scalar|
|PCLK|input|scalar|
|PSEL|input|scalar|
|PENABLE|input|scalar|
|PWRITE|input|scalar|
|PADDR|input|[2:0]|
|PWDATA|input|[7:0]|
|module_tdo_o|output|scalar|
|top_inhibit_o|output|scalar|
|PRDATA|output|[7:0]|
|PREADY|output|scalar|
|PSLVERR|output|scalar|
|int_o|output|scalar|
