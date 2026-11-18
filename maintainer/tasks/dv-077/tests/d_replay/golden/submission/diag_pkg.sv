package diag_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
bit diagnostic_done=0;
class dvbench_test extends uvm_test;
 `uvm_component_utils(dvbench_test)
 function new(string name="dvbench_test",uvm_component parent=null);super.new(name,parent);endfunction
 task run_phase(uvm_phase phase);
  phase.raise_objection(this);wait(diagnostic_done);phase.drop_objection(this);
 endtask
 function void report_phase(uvm_phase phase);
  `uvm_info("NATIVE_DIAGNOSTIC","Native-port characterization only; no qualification claim.",UVM_LOW)
  $display("DVBench_COMPLETED");
 endfunction
endclass
endpackage
