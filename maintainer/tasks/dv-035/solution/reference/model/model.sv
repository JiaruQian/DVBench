`timescale 1ns/1ps
module dvbench_model #(
parameter DATA_WIDTH=64,
parameter KEEP_ENABLE=1'b1,
parameter KEEP_WIDTH=8,
parameter PAYLOAD_FIFO_DEPTH=2048,
parameter HEADER_FIFO_DEPTH=8
) (
output logic  busy,
input logic  clk,
output logic [47:0] m_eth_dest_mac,
output logic [47:0] m_eth_src_mac,
output logic [15:0] m_eth_type,
output logic [31:0] m_ip_dest_ip,
output logic [5:0] m_ip_dscp,
output logic [1:0] m_ip_ecn,
output logic [2:0] m_ip_flags,
output logic [12:0] m_ip_fragment_offset,
input logic  m_ip_hdr_ready,
output logic  m_ip_hdr_valid,
output logic [15:0] m_ip_header_checksum,
output logic [15:0] m_ip_identification,
output logic [3:0] m_ip_ihl,
output logic [15:0] m_ip_length,
output logic [63:0] m_ip_payload_axis_tdata,
output logic [7:0] m_ip_payload_axis_tkeep,
output logic  m_ip_payload_axis_tlast,
input logic  m_ip_payload_axis_tready,
output logic  m_ip_payload_axis_tuser,
output logic  m_ip_payload_axis_tvalid,
output logic [7:0] m_ip_protocol,
output logic [31:0] m_ip_source_ip,
output logic [7:0] m_ip_ttl,
output logic [3:0] m_ip_version,
input logic  rst,
input logic [47:0] s_eth_dest_mac,
input logic [47:0] s_eth_src_mac,
input logic [15:0] s_eth_type,
input logic [31:0] s_ip_dest_ip,
input logic [5:0] s_ip_dscp,
input logic [1:0] s_ip_ecn,
input logic [2:0] s_ip_flags,
input logic [12:0] s_ip_fragment_offset,
output logic  s_ip_hdr_ready,
input logic  s_ip_hdr_valid,
input logic [15:0] s_ip_header_checksum,
input logic [15:0] s_ip_identification,
input logic [3:0] s_ip_ihl,
input logic [15:0] s_ip_length,
input logic [63:0] s_ip_payload_axis_tdata,
input logic [7:0] s_ip_payload_axis_tkeep,
input logic  s_ip_payload_axis_tlast,
output logic  s_ip_payload_axis_tready,
input logic  s_ip_payload_axis_tuser,
input logic  s_ip_payload_axis_tvalid,
input logic [7:0] s_ip_protocol,
input logic [31:0] s_ip_source_ip,
input logic [7:0] s_ip_ttl,
input logic [3:0] s_ip_version
);

typedef logic [73:0] beat_t;
beat_t payload_memory[256];
beat_t pipeline[2];
logic [1:0] occupied=0;
integer write_count=0;
integer read_count=0;
logic header_ready=0;
logic commit_pending=0;
integer header_written=0;
integer header_read=0;
logic header_out_valid=0;
logic [272-1:0] header_memory[8];
logic [272-1:0] header_staging=0;
logic [272-1:0] header_output=0;
logic header_full;
logic pop_header;
logic accept_header;
logic accept_last;
logic payload_full;
logic read_step;
logic shift_step;
always @* begin
  busy=0;
  header_full=(header_written-header_read==8);
  payload_full=(write_count-read_count==256);
  s_ip_payload_axis_tready=!payload_full;
  m_ip_payload_axis_tvalid=occupied[1];
  {m_ip_payload_axis_tuser,m_ip_payload_axis_tlast,m_ip_payload_axis_tkeep,m_ip_payload_axis_tdata}=pipeline[1];
  s_ip_hdr_ready=header_ready;
  m_ip_hdr_valid=header_out_valid;
  {m_eth_dest_mac,m_eth_src_mac,m_eth_type,m_ip_dest_ip,m_ip_dscp,m_ip_ecn,m_ip_flags,m_ip_fragment_offset,m_ip_header_checksum,m_ip_identification,m_ip_ihl,m_ip_length,m_ip_protocol,m_ip_source_ip,m_ip_ttl,m_ip_version}=header_output;
  pop_header=(m_ip_hdr_ready || !header_out_valid) && (header_written!=header_read);
  accept_header=header_ready && s_ip_hdr_valid;
  accept_last=s_ip_payload_axis_tvalid && !payload_full && s_ip_payload_axis_tlast;
  read_step=m_ip_payload_axis_tready || !(&occupied);
  shift_step=m_ip_payload_axis_tready || !occupied[1];
end
always @(posedge clk) begin
  if(m_ip_payload_axis_tready) occupied[1]<=0;
  if(shift_step) begin
    pipeline[1]<=pipeline[0]; occupied[1]<=occupied[0]; occupied[0]<=0;
  end
  if(read_step) begin
    pipeline[0]<=payload_memory[read_count%256];
    occupied[0]<=write_count!=read_count;
    if(write_count!=read_count) read_count<=read_count+1;
  end
  if(s_ip_payload_axis_tvalid && !payload_full) begin
    payload_memory[write_count%256]<={s_ip_payload_axis_tuser,s_ip_payload_axis_tlast,s_ip_payload_axis_tkeep,s_ip_payload_axis_tdata};
    write_count<=write_count+1;
  end
  if(m_ip_hdr_ready || !header_out_valid) header_out_valid<=pop_header;
  if(pop_header) begin
    header_output<=header_memory[header_read%8];
    header_read<=header_read+1;
  end
  if(commit_pending && !header_full) begin
    header_memory[header_written%8]<=header_staging;
    header_written<=header_written+1;
  end
  header_ready<=!header_full && !accept_header;
  commit_pending<=accept_header && accept_last;
  if(accept_header) header_staging<={s_eth_dest_mac,s_eth_src_mac,s_eth_type,s_ip_dest_ip,s_ip_dscp,s_ip_ecn,s_ip_flags,s_ip_fragment_offset,s_ip_header_checksum,s_ip_identification,s_ip_ihl,s_ip_length,s_ip_protocol,s_ip_source_ip,s_ip_ttl,s_ip_version};
  if(rst) begin
    write_count<=0; read_count<=0; occupied<=0;
    header_written<=0; header_read<=0; header_out_valid<=0;
    header_ready<=0; commit_pending<=0;
  end
end

endmodule
