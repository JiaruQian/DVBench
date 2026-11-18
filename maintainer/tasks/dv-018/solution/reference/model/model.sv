module dvbench_model #(parameter ISIZE=4, parameter OSIZE=8)(
input logic clock, rst_n,
input logic [ISIZE-1:0] wr_data,
input logic wr_vld,
output logic wr_ready,
input logic wr_last, wr_align_last,
output logic [OSIZE-1:0] rd_data,
output logic rd_vld,
input logic rd_ready,
output logic rd_last
);
generate
if(ISIZE==OSIZE) begin
    always_comb begin
        wr_ready=rd_ready; rd_data=wr_data; rd_vld=wr_vld; rd_last=wr_last;
    end
end else if(ISIZE<OSIZE) begin
    integer stored_pieces;
    always_comb wr_ready=rd_ready;
    always_ff @(posedge clock or negedge rst_n) begin
        if(!rst_n) begin
            stored_pieces<=0; rd_data<='0; rd_vld<=0; rd_last<=0;
        end else begin
            if(rd_ready && rd_vld) begin rd_vld<=0; rd_last<=0; end
            if(wr_vld && rd_ready) begin
                rd_data[OSIZE-1-stored_pieces*ISIZE -:ISIZE]<=wr_data;
                if(stored_pieces==(OSIZE/ISIZE)-1) begin rd_vld<=1; rd_last<=wr_last; end
                if(wr_last || wr_align_last || stored_pieces==(OSIZE/ISIZE)-1) stored_pieces<=0;
                else stored_pieces<=stored_pieces+1;
            end
        end
    end
end else begin
    integer emitted_pieces;
    always_ff @(posedge clock or negedge rst_n) begin
        if(!rst_n) begin
            emitted_pieces<=0; wr_ready<=0; rd_data<='0; rd_vld<=0; rd_last<=0;
        end else begin
            if(wr_vld && rd_ready) begin
                rd_data<=wr_data[ISIZE-1-emitted_pieces*OSIZE -:OSIZE];
                if(emitted_pieces==(ISIZE/OSIZE)-1) emitted_pieces<=0;
                else emitted_pieces<=emitted_pieces+1;
            end
            if(emitted_pieces==(ISIZE/OSIZE)-2 && wr_vld && rd_ready) wr_ready<=1;
            else if(wr_ready && wr_vld) wr_ready<=0;
            rd_vld <= (wr_vld && rd_ready) || (rd_vld && !rd_ready);
            if(wr_vld && rd_ready) rd_last<=(emitted_pieces==(ISIZE/OSIZE)-2) && wr_last;
            else if(!rd_vld || rd_ready) rd_last<=0;
        end
    end
end
endgenerate
endmodule
