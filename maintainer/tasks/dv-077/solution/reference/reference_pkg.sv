package reference_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
bit reference_done=0;
int compared=0,mismatches=0,actual_count=0,expected_count=0;
class dvbench_test extends uvm_test;
 `uvm_component_utils(dvbench_test)
 function new(string n="dvbench_test",uvm_component p=null);super.new(n,p);endfunction
 task run_phase(uvm_phase phase);
  phase.raise_objection(this);wait(reference_done);#5;
  if(mismatches>0) `uvm_error("LH_COMPARE","Behavioral comparison mismatches; see LH_COMPARE diagnostics")
  if(compared<100) `uvm_error("VACUOUS","Fewer than one hundred actual comparisons")
  phase.drop_objection(this);
 endtask
 function void report_phase(uvm_phase phase);
  uvm_report_server server=uvm_report_server::get_server();
  $display("LH_COUNTS compared=%0d mismatches=%0d actual=%0d expected=%0d",compared,mismatches,actual_count,expected_count);
  if(mismatches==0&&compared>=100&&server.get_severity_count(UVM_ERROR)==0&&server.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");
 endfunction
endclass
endpackage
