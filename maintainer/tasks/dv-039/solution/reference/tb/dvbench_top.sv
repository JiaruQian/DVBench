`timescale 1ns/1ps
module dvbench_top;
    import uvm_pkg::*;
    import cq_pkg::*;
    logic nvdla_core_clk=0;
    always #5 nvdla_core_clk=~nvdla_core_clk;
    cq_if vif(nvdla_core_clk);
    NV_NVDLA_CDP_RDMA_cq dut(.nvdla_core_clk(nvdla_core_clk),.nvdla_core_rstn(vif.rstn),.cq_wr_pvld(vif.write_valid),.cq_wr_pd(vif.write_data),.cq_rd_prdy(vif.read_ready),.pwrbus_ram_pd(vif.power_pattern),.cq_wr_prdy(vif.write_ready),.cq_rd_pvld(vif.read_valid),.cq_rd_pd(vif.read_data));
    dvbench_model predictor(.nvdla_core_clk(nvdla_core_clk),.nvdla_core_rstn(vif.rstn),.cq_wr_pvld(vif.write_valid),.cq_wr_pd(vif.write_data),.cq_rd_prdy(vif.read_ready),.pwrbus_ram_pd(vif.power_pattern),.cq_wr_prdy(vif.expected_ready),.cq_rd_pvld(vif.expected_valid),.cq_rd_pd(vif.expected_data));
    initial begin
        uvm_config_db#(virtual cq_if)::set(null,"*","vif",vif);
        run_test("dvbench_test");
    end
endmodule
