module dvbench_model #(
    parameter ISIZE = 4,
    parameter OSIZE = 8
) (
    input logic clock,
    input logic rst_n,
    input logic [ISIZE-1:0] wr_data,
    input logic wr_vld,
    output logic wr_ready,
    input logic wr_last,
    input logic wr_align_last,
    output logic [OSIZE-1:0] rd_data,
    output logic rd_vld,
    input logic rd_ready,
    output logic rd_last
);
    logic first_half_pending;

    always_comb begin
        wr_ready = rd_ready;
    end

    always_ff @(posedge clock or negedge rst_n) begin
        if (!rst_n) begin
            first_half_pending <= 1'b0;
            rd_data <= '0;
            rd_vld <= 1'b0;
            rd_last <= 1'b0;
        end else begin
            if (rd_vld && rd_ready) begin
                rd_vld <= 1'b0;
                rd_last <= 1'b0;
            end
            if (wr_vld && wr_ready) begin
                if (!first_half_pending) begin
                    rd_data[OSIZE-1 -: ISIZE] <= wr_data;
                    first_half_pending <= !(wr_last || wr_align_last);
                end else begin
                    rd_data[ISIZE-1:0] <= wr_data;
                    rd_vld <= 1'b1;
                    rd_last <= wr_last;
                    first_half_pending <= 1'b0;
                end
                if (wr_align_last)
                    first_half_pending <= 1'b0;
            end
        end
    end
endmodule
