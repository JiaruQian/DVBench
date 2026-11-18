module dvbench_top;
 import uvm_pkg::*;import cache_native_pkg::*;
 cache_native_if pins0();
 lm32_dcache #(.sets(512)) dut0(.clk_i(pins0.clk),.rst_i(pins0.rst),.stall_a(pins0.sa),.stall_x(pins0.sx),.stall_m(pins0.sm),.address_x(pins0.ax),.address_m(pins0.am),.load_q_m(pins0.lq),.store_q_m(pins0.sq),.store_data(pins0.sd),.store_byte_select(pins0.be),.refill_ready(pins0.rr),.refill_data(pins0.rd),.dflush(pins0.flush),.stall_request(pins0.stall),.restart_request(pins0.restart),.refill_request(pins0.req),.refill_address(pins0.addr),.refilling(pins0.refilling),.load_data(pins0.data));
 dvbench_model #(.sets(512)) predictor0(.clk_i(pins0.clk),.rst_i(pins0.rst),.stall_a(pins0.sa),.stall_x(pins0.sx),.stall_m(pins0.sm),.address_x(pins0.ax),.address_m(pins0.am),.load_q_m(pins0.lq),.store_q_m(pins0.sq),.store_data(pins0.sd),.store_byte_select(pins0.be),.refill_ready(pins0.rr),.refill_data(pins0.rd),.dflush(pins0.flush),.stall_request(pins0.estall),.restart_request(pins0.erestart),.refill_request(pins0.ereq),.refill_address(pins0.eaddr),.refilling(pins0.erefilling),.load_data(pins0.edata));
 always @(posedge pins0.rst)begin #2;if(pins0.stall!==1 || pins0.restart!==0 || pins0.req!==0 || pins0.refilling!==0)`uvm_error("ASYNC_RESET","control reset failed") end
 initial uvm_config_db#(virtual cache_native_if)::set(null,"uvm_test_top.agent0.*","vif",pins0);
 cache_native_if pins1();
 lm32_dcache #(.sets(64)) dut1(.clk_i(pins1.clk),.rst_i(pins1.rst),.stall_a(pins1.sa),.stall_x(pins1.sx),.stall_m(pins1.sm),.address_x(pins1.ax),.address_m(pins1.am),.load_q_m(pins1.lq),.store_q_m(pins1.sq),.store_data(pins1.sd),.store_byte_select(pins1.be),.refill_ready(pins1.rr),.refill_data(pins1.rd),.dflush(pins1.flush),.stall_request(pins1.stall),.restart_request(pins1.restart),.refill_request(pins1.req),.refill_address(pins1.addr),.refilling(pins1.refilling),.load_data(pins1.data));
 dvbench_model #(.sets(64)) predictor1(.clk_i(pins1.clk),.rst_i(pins1.rst),.stall_a(pins1.sa),.stall_x(pins1.sx),.stall_m(pins1.sm),.address_x(pins1.ax),.address_m(pins1.am),.load_q_m(pins1.lq),.store_q_m(pins1.sq),.store_data(pins1.sd),.store_byte_select(pins1.be),.refill_ready(pins1.rr),.refill_data(pins1.rd),.dflush(pins1.flush),.stall_request(pins1.estall),.restart_request(pins1.erestart),.refill_request(pins1.ereq),.refill_address(pins1.eaddr),.refilling(pins1.erefilling),.load_data(pins1.edata));
 always @(posedge pins1.rst)begin #2;if(pins1.stall!==1 || pins1.restart!==0 || pins1.req!==0 || pins1.refilling!==0)`uvm_error("ASYNC_RESET","control reset failed") end
 initial uvm_config_db#(virtual cache_native_if)::set(null,"uvm_test_top.agent1.*","vif",pins1);
 initial run_test("dvbench_test");
endmodule
