`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*; import reference_pkg::*;
reference_if vif();
BRAM_TDP_24w_256d dut(.clka(vif.clka),.rsta(vif.rsta),.wea(vif.wea),.addra(vif.addra),.dina(vif.dina),.douta(vif.douta),.clkb(vif.clkb),.rstb(vif.rstb),.web(vif.web),.addrb(vif.addrb),.dinb(vif.dinb),.doutb(vif.doutb),.rsta_busy(vif.rsta_busy),.rstb_busy(vif.rstb_busy));
dvbench_model predictor_model(.clka(vif.clka),.rsta(vif.rsta),.wea(vif.wea),.addra(vif.addra),.dina(vif.dina),.douta(vif.predicted_douta),.clkb(vif.clkb),.rstb(vif.rstb),.web(vif.web),.addrb(vif.addrb),.dinb(vif.dinb),.doutb(vif.predicted_doutb),.rsta_busy(vif.predicted_rsta_busy),.rstb_busy(vif.predicted_rstb_busy));
initial begin uvm_config_db#(virtual reference_if)::set(null,"*","vif",vif); run_test("dvbench_test"); end
endmodule
