module dvbench_model(
    input logic [1:0] cacc2glb_done_intr_pd,
    input logic [1:0] cdma_dat2glb_done_intr_pd,
    input logic [1:0] cdma_wt2glb_done_intr_pd,
    input logic [1:0] cdp2glb_done_intr_pd,
    input logic [62:0] csb2glb_req_pd,
    input logic csb2glb_req_pvld,
    input logic direct_reset_,
    input logic nvdla_core_clk,
    input logic nvdla_core_rstn,
    input logic nvdla_falcon_clk,
    input logic nvdla_falcon_rstn,
    input logic [1:0] pdp2glb_done_intr_pd,
    input logic [1:0] sdp2glb_done_intr_pd,
    input logic test_mode,
    output logic core_intr,
    output logic csb2glb_req_prdy,
    output logic [33:0] glb2csb_resp_pd,
    output logic glb2csb_resp_valid
);
    logic [31:0] mask_bits;
    logic [31:0] pending_events;
    logic [31:0] sampled_events;
    logic interrupt_to_falcon;
    logic [2:0] falcon_history;
    logic request_pending;
    logic request_is_write;
    logic request_needs_reply;
    logic [9:0] request_address;
    logic [31:0] request_data;
    logic [31:0] read_value;
    logic [31:0] software_set;
    logic [31:0] software_clear;
    assign csb2glb_req_prdy=1'b1;
    assign core_intr=falcon_history[2];
    always_comb begin
        case(request_address)
            0: read_value=32'h00303031;
            1: read_value=mask_bits;
            2: read_value=0;
            3: read_value=pending_events;
            default: read_value=0;
        endcase
        software_set=0;
        software_clear=0;
        if(request_pending && request_is_write) begin
            if(request_address==2) software_set=request_data & 32'h003f003f;
            if(request_address==3) software_clear=request_data & 32'h003f003f;
        end
    end
    always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
        if(!nvdla_core_rstn) begin
            mask_bits<=0;
            pending_events<=0;
            sampled_events<=0;
            interrupt_to_falcon<=0;
            request_pending<=0;
            request_is_write<=0;
            request_needs_reply<=0;
            request_address<=0;
            request_data<=0;
            glb2csb_resp_valid<=0;
            glb2csb_resp_pd<=0;
        end else begin
            sampled_events<={10'b0,cacc2glb_done_intr_pd,cdma_wt2glb_done_intr_pd,cdma_dat2glb_done_intr_pd,10'b0,pdp2glb_done_intr_pd,cdp2glb_done_intr_pd,sdp2glb_done_intr_pd};
            pending_events<=((pending_events & ~software_clear) | software_set | sampled_events) & 32'h003f003f;
            interrupt_to_falcon<=|(pending_events & ~mask_bits);
            if(request_pending && request_is_write && request_address==1)
                mask_bits<=request_data & 32'h003f03ff;
            glb2csb_resp_valid<=request_pending && (!request_is_write || request_needs_reply);
            if(request_pending && (!request_is_write || request_needs_reply))
                glb2csb_resp_pd<=request_is_write ? {1'b1,33'b0} : {2'b0,read_value};
            request_pending<=csb2glb_req_pvld;
            if(csb2glb_req_pvld) begin
                request_is_write<=csb2glb_req_pd[54];
                request_needs_reply<=csb2glb_req_pd[55];
                request_address<=csb2glb_req_pd[9:0];
                request_data<=csb2glb_req_pd[53:22];
            end
        end
    end
    always @(posedge nvdla_falcon_clk or negedge nvdla_falcon_rstn) begin
        if(!nvdla_falcon_rstn) falcon_history<=0;
        else falcon_history<={falcon_history[1:0],interrupt_to_falcon};
    end
endmodule
