module dvbench_model(
    input logic nvdla_core_clk,
    input logic nvdla_core_rstn,
    output logic cq_wr_prdy,
    input logic cq_wr_pvld,
    input logic [6:0] cq_wr_pd,
    input logic cq_rd_prdy,
    output logic cq_rd_pvld,
    output logic [6:0] cq_rd_pd,
    input logic [31:0] pwrbus_ram_pd
);
    logic [6:0] waiting_data[$];
    logic previous_load;
    logic accepted_write;
    logic load_output;
    logic [6:0] oldest_data;
    integer waiting_before;
    always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
        if (!nvdla_core_rstn) begin
            waiting_data.delete();
            previous_load <= 0;
            cq_wr_prdy <= 1;
            cq_rd_pvld <= 0;
        end else begin
            waiting_before = waiting_data.size();
            accepted_write = cq_wr_pvld && cq_wr_prdy;
            load_output = waiting_before > 0 && (!cq_rd_pvld || cq_rd_prdy);
            cq_wr_prdy <= previous_load || (waiting_before + accepted_write != 256);
            cq_rd_pvld <= waiting_before > 0 || (cq_rd_pvld && !cq_rd_prdy);
            if (load_output) begin
                oldest_data = waiting_data.pop_front();
                cq_rd_pd <= oldest_data;
            end
            if (accepted_write)
                waiting_data.push_back(cq_wr_pd);
            previous_load <= load_output;
        end
    end
endmodule
