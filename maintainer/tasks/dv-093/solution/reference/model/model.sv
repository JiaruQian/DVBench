`timescale 1ns/1ps
module dvbench_model(
input logic nvdla_core_clk,
input logic nvdla_core_rstn,
input logic nvdla_falcon_clk,
input logic nvdla_falcon_rstn,
input logic [31:0] pwrbus_ram_pd,
input logic csb2nvdla_valid,
output logic csb2nvdla_ready,
input logic [15:0] csb2nvdla_addr,
input logic [31:0] csb2nvdla_wdat,
input logic csb2nvdla_write,
input logic csb2nvdla_nposted,
output logic nvdla2csb_valid,
output logic [31:0] nvdla2csb_data,
output logic nvdla2csb_wr_complete,
output logic csb2cfgrom_req_pvld,
input logic csb2cfgrom_req_prdy,
output logic [62:0] csb2cfgrom_req_pd,
input logic cfgrom2csb_resp_valid,
input logic [33:0] cfgrom2csb_resp_pd,
output logic csb2glb_req_pvld,
input logic csb2glb_req_prdy,
output logic [62:0] csb2glb_req_pd,
input logic glb2csb_resp_valid,
input logic [33:0] glb2csb_resp_pd,
output logic csb2mcif_req_pvld,
input logic csb2mcif_req_prdy,
output logic [62:0] csb2mcif_req_pd,
input logic mcif2csb_resp_valid,
input logic [33:0] mcif2csb_resp_pd,
output logic csb2cdma_req_pvld,
input logic csb2cdma_req_prdy,
output logic [62:0] csb2cdma_req_pd,
input logic cdma2csb_resp_valid,
input logic [33:0] cdma2csb_resp_pd,
output logic csb2csc_req_pvld,
input logic csb2csc_req_prdy,
output logic [62:0] csb2csc_req_pd,
input logic csc2csb_resp_valid,
input logic [33:0] csc2csb_resp_pd,
output logic csb2cmac_a_req_pvld,
input logic csb2cmac_a_req_prdy,
output logic [62:0] csb2cmac_a_req_pd,
input logic cmac_a2csb_resp_valid,
input logic [33:0] cmac_a2csb_resp_pd,
output logic csb2cmac_b_req_pvld,
input logic csb2cmac_b_req_prdy,
output logic [62:0] csb2cmac_b_req_pd,
input logic cmac_b2csb_resp_valid,
input logic [33:0] cmac_b2csb_resp_pd,
output logic csb2cacc_req_pvld,
input logic csb2cacc_req_prdy,
output logic [62:0] csb2cacc_req_pd,
input logic cacc2csb_resp_valid,
input logic [33:0] cacc2csb_resp_pd,
output logic csb2sdp_rdma_req_pvld,
input logic csb2sdp_rdma_req_prdy,
output logic [62:0] csb2sdp_rdma_req_pd,
input logic sdp_rdma2csb_resp_valid,
input logic [33:0] sdp_rdma2csb_resp_pd,
output logic csb2sdp_req_pvld,
input logic csb2sdp_req_prdy,
output logic [62:0] csb2sdp_req_pd,
input logic sdp2csb_resp_valid,
input logic [33:0] sdp2csb_resp_pd,
output logic csb2pdp_rdma_req_pvld,
input logic csb2pdp_rdma_req_prdy,
output logic [62:0] csb2pdp_rdma_req_pd,
input logic pdp_rdma2csb_resp_valid,
input logic [33:0] pdp_rdma2csb_resp_pd,
output logic csb2pdp_req_pvld,
input logic csb2pdp_req_prdy,
output logic [62:0] csb2pdp_req_pd,
input logic pdp2csb_resp_valid,
input logic [33:0] pdp2csb_resp_pd,
output logic csb2cdp_rdma_req_pvld,
input logic csb2cdp_rdma_req_prdy,
output logic [62:0] csb2cdp_rdma_req_pd,
input logic cdp_rdma2csb_resp_valid,
input logic [33:0] cdp_rdma2csb_resp_pd,
output logic csb2cdp_req_pvld,
input logic csb2cdp_req_prdy,
output logic [62:0] csb2cdp_req_pd,
input logic cdp2csb_resp_valid,
input logic [33:0] cdp2csb_resp_pd
);

  logic[49:0] memory[2][4],ingress[2],delivered[2];
  integer issued[2],returned[2],accepted_returns[2],accepted_issues[2];
  integer issue_pipe[2][3],return_pipe[2][3];
  integer occupancy[2],write_slot[2],read_slot[2];
  logic pending[2],busy[2],input_blocked[2],delivery_valid[2];
  logic client_ready[14],client_input_valid[14];
  logic[33:0] client_input_data[14],client_reply[14];
  logic client_reply_valid[14],decode_pending[14],request_valid[14];
  logic[49:0] request_saved[14],dispatch_saved;
  logic dummy_pending,dummy_read,dummy_nonposted,dummy_valid,dummy_write;
  logic response_offer;
  logic[33:0] response_data;
  integer decoded_client;
  always @* begin
    response_offer=dummy_valid;
    response_data=dummy_valid?{dummy_write,33'b0}:34'b0;
    for(integer client_index=0;client_index<14;client_index=client_index+1) begin
      response_offer=response_offer|client_reply_valid[client_index];
      if(client_reply_valid[client_index])response_data=response_data|client_reply[client_index];
    end
    decoded_client=delivered[0][15:10];
  end
  assign csb2nvdla_ready=!input_blocked[0];
  task automatic writer_reset(input integer channel);
    pending[channel]<=0;busy[channel]<=0;input_blocked[channel]<=0;
    occupancy[channel]<=0;write_slot[channel]<=0;issued[channel]<=0;accepted_returns[channel]<=0;
    for(integer stage=0;stage<3;stage=stage+1)return_pipe[channel][stage]<=0;
  endtask
  task automatic reader_reset(input integer channel);
    read_slot[channel]<=0;returned[channel]<=0;accepted_issues[channel]<=0;delivery_valid[channel]<=0;
    for(integer stage=0;stage<3;stage=stage+1)issue_pipe[channel][stage]<=0;
  endtask
  task automatic writer_edge(input integer channel,input integer depth,input logic offer,input logic[49:0] value);
    logic commit,acknowledge,next_busy;
    integer next_occupancy;
    commit=pending[channel]&&!busy[channel];
    acknowledge=return_pipe[channel][2]!=accepted_returns[channel];
    next_occupancy=(occupancy[channel]+integer'(commit)-integer'(acknowledge))&(2*depth-1);
    next_busy=!acknowledge&&next_occupancy==depth;
    if(offer&&!input_blocked[channel])ingress[channel]<=value;
    input_blocked[channel]<=offer?next_busy:(pending[channel]&&next_busy&&!commit);
    if(!(pending[channel]&&busy[channel]))pending[channel]<=offer&&!input_blocked[channel];
    busy[channel]<=next_busy;occupancy[channel]<=next_occupancy;
    if(((occupancy[channel]+integer'(commit))&(2*depth-1))!=0) begin
      return_pipe[channel][0]<=returned[channel];return_pipe[channel][1]<=return_pipe[channel][0];return_pipe[channel][2]<=return_pipe[channel][1];
    end
    if(acknowledge)accepted_returns[channel]<=(accepted_returns[channel]+1)&(2*depth-1);
    if(commit) begin
      memory[channel][write_slot[channel]]<=ingress[channel];
      write_slot[channel]<=(write_slot[channel]+1)%depth;
      issued[channel]<=(issued[channel]+1)&(2*depth-1);
    end
  endtask
  task automatic reader_edge(input integer channel,input integer depth);
    logic available;
    available=issue_pipe[channel][2]!=accepted_issues[channel];
    issue_pipe[channel][0]<=issued[channel];issue_pipe[channel][1]<=issue_pipe[channel][0];issue_pipe[channel][2]<=issue_pipe[channel][1];
    delivery_valid[channel]<=available;
    if(available) begin
      delivered[channel]<=memory[channel][read_slot[channel]];
      read_slot[channel]<=(read_slot[channel]+1)%depth;
      returned[channel]<=(returned[channel]+1)&(2*depth-1);
      accepted_issues[channel]<=(accepted_issues[channel]+1)&(2*depth-1);
    end
  endtask
  always @(posedge nvdla_falcon_clk or negedge nvdla_falcon_rstn) begin
    if(!nvdla_falcon_rstn) begin
      writer_reset(0);reader_reset(1);
      nvdla2csb_valid<=0;nvdla2csb_wr_complete<=0;nvdla2csb_data<=0;
    end else begin
      writer_edge(0,4,csb2nvdla_valid,{csb2nvdla_nposted,csb2nvdla_write,csb2nvdla_wdat,csb2nvdla_addr});
      reader_edge(1,2);
      nvdla2csb_valid<=delivery_valid[1]&&!delivered[1][33];
      nvdla2csb_wr_complete<=delivery_valid[1]&&delivered[1][33];
      if(delivery_valid[1]&&!delivered[1][33])nvdla2csb_data<=delivered[1][31:0];
    end
  end
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if(!nvdla_core_rstn) begin
      writer_reset(1);reader_reset(0);
      dummy_pending<=0;dummy_valid<=0;dummy_write<=0;
      for(integer client_index=0;client_index<14;client_index=client_index+1) begin
        decode_pending[client_index]<=0;request_valid[client_index]<=0;request_saved[client_index]<=0;
        client_reply_valid[client_index]<=0;client_reply[client_index]<=0;
      end
    end else begin
      reader_edge(0,4);writer_edge(1,2,response_offer,{16'b0,response_data});
      for(integer client_index=0;client_index<14;client_index=client_index+1) begin
        if(delivery_valid[0]&&decoded_client==client_index)decode_pending[client_index]<=1;
        else if(client_ready[client_index]||!request_valid[client_index])decode_pending[client_index]<=0;
        request_valid[client_index]<=decode_pending[client_index]||(!client_ready[client_index]&&request_valid[client_index]);
        if(decode_pending[client_index]&&(client_ready[client_index]||!request_valid[client_index]))request_saved[client_index]<=dispatch_saved;
        client_reply_valid[client_index]<=client_input_valid[client_index];
        if(client_input_valid[client_index])client_reply[client_index]<=client_input_data[client_index];
      end
      dummy_pending<=delivery_valid[0]&&decoded_client>=14;
      dummy_valid<=dummy_pending&&(dummy_read||dummy_nonposted);
      if(dummy_pending&&(dummy_read||dummy_nonposted))dummy_write<=!dummy_read&&dummy_nonposted;
    end
  end
  always @(posedge nvdla_core_clk) begin
    if(delivery_valid[0])dispatch_saved<=delivered[0];
    if(delivery_valid[0]&&decoded_client>=14)begin dummy_read<=!delivered[0][48];dummy_nonposted<=delivered[0][49];end
  end
  assign client_ready[0]=csb2cfgrom_req_prdy;
  assign client_input_valid[0]=cfgrom2csb_resp_valid;
  assign client_input_data[0]=cfgrom2csb_resp_pd;
  assign csb2cfgrom_req_pvld=request_valid[0];
  assign csb2cfgrom_req_pd={7'b0,request_saved[0][49:16],6'b0,request_saved[0][15:0]};
  assign client_ready[1]=csb2glb_req_prdy;
  assign client_input_valid[1]=glb2csb_resp_valid;
  assign client_input_data[1]=glb2csb_resp_pd;
  assign csb2glb_req_pvld=request_valid[1];
  assign csb2glb_req_pd={7'b0,request_saved[1][49:16],6'b0,request_saved[1][15:0]};
  assign client_ready[2]=csb2mcif_req_prdy;
  assign client_input_valid[2]=mcif2csb_resp_valid;
  assign client_input_data[2]=mcif2csb_resp_pd;
  assign csb2mcif_req_pvld=request_valid[2];
  assign csb2mcif_req_pd={7'b0,request_saved[2][49:16],6'b0,request_saved[2][15:0]};
  assign client_ready[3]=csb2cdma_req_prdy;
  assign client_input_valid[3]=cdma2csb_resp_valid;
  assign client_input_data[3]=cdma2csb_resp_pd;
  assign csb2cdma_req_pvld=request_valid[3];
  assign csb2cdma_req_pd={7'b0,request_saved[3][49:16],6'b0,request_saved[3][15:0]};
  assign client_ready[4]=csb2csc_req_prdy;
  assign client_input_valid[4]=csc2csb_resp_valid;
  assign client_input_data[4]=csc2csb_resp_pd;
  assign csb2csc_req_pvld=request_valid[4];
  assign csb2csc_req_pd={7'b0,request_saved[4][49:16],6'b0,request_saved[4][15:0]};
  assign client_ready[5]=csb2cmac_a_req_prdy;
  assign client_input_valid[5]=cmac_a2csb_resp_valid;
  assign client_input_data[5]=cmac_a2csb_resp_pd;
  assign csb2cmac_a_req_pvld=request_valid[5];
  assign csb2cmac_a_req_pd={7'b0,request_saved[5][49:16],6'b0,request_saved[5][15:0]};
  assign client_ready[6]=csb2cmac_b_req_prdy;
  assign client_input_valid[6]=cmac_b2csb_resp_valid;
  assign client_input_data[6]=cmac_b2csb_resp_pd;
  assign csb2cmac_b_req_pvld=request_valid[6];
  assign csb2cmac_b_req_pd={7'b0,request_saved[6][49:16],6'b0,request_saved[6][15:0]};
  assign client_ready[7]=csb2cacc_req_prdy;
  assign client_input_valid[7]=cacc2csb_resp_valid;
  assign client_input_data[7]=cacc2csb_resp_pd;
  assign csb2cacc_req_pvld=request_valid[7];
  assign csb2cacc_req_pd={7'b0,request_saved[7][49:16],6'b0,request_saved[7][15:0]};
  assign client_ready[8]=csb2sdp_rdma_req_prdy;
  assign client_input_valid[8]=sdp_rdma2csb_resp_valid;
  assign client_input_data[8]=sdp_rdma2csb_resp_pd;
  assign csb2sdp_rdma_req_pvld=request_valid[8];
  assign csb2sdp_rdma_req_pd={7'b0,request_saved[8][49:16],6'b0,request_saved[8][15:0]};
  assign client_ready[9]=csb2sdp_req_prdy;
  assign client_input_valid[9]=sdp2csb_resp_valid;
  assign client_input_data[9]=sdp2csb_resp_pd;
  assign csb2sdp_req_pvld=request_valid[9];
  assign csb2sdp_req_pd={7'b0,request_saved[9][49:16],6'b0,request_saved[9][15:0]};
  assign client_ready[10]=csb2pdp_rdma_req_prdy;
  assign client_input_valid[10]=pdp_rdma2csb_resp_valid;
  assign client_input_data[10]=pdp_rdma2csb_resp_pd;
  assign csb2pdp_rdma_req_pvld=request_valid[10];
  assign csb2pdp_rdma_req_pd={7'b0,request_saved[10][49:16],6'b0,request_saved[10][15:0]};
  assign client_ready[11]=csb2pdp_req_prdy;
  assign client_input_valid[11]=pdp2csb_resp_valid;
  assign client_input_data[11]=pdp2csb_resp_pd;
  assign csb2pdp_req_pvld=request_valid[11];
  assign csb2pdp_req_pd={7'b0,request_saved[11][49:16],6'b0,request_saved[11][15:0]};
  assign client_ready[12]=csb2cdp_rdma_req_prdy;
  assign client_input_valid[12]=cdp_rdma2csb_resp_valid;
  assign client_input_data[12]=cdp_rdma2csb_resp_pd;
  assign csb2cdp_rdma_req_pvld=request_valid[12];
  assign csb2cdp_rdma_req_pd={7'b0,request_saved[12][49:16],6'b0,request_saved[12][15:0]};
  assign client_ready[13]=csb2cdp_req_prdy;
  assign client_input_valid[13]=cdp2csb_resp_valid;
  assign client_input_data[13]=cdp2csb_resp_pd;
  assign csb2cdp_req_pvld=request_valid[13];
  assign csb2cdp_req_pd={7'b0,request_saved[13][49:16],6'b0,request_saved[13][15:0]};
endmodule
