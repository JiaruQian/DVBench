module dvbench_model #
(
    
    parameter S_COUNT = 4,
    
    parameter M_COUNT = 4,
    
    parameter DATA_WIDTH = 32,
    
    parameter ADDR_WIDTH = 32,
    
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    
    parameter ID_WIDTH = 8,
    
    parameter AWUSER_ENABLE = 0,
    
    parameter AWUSER_WIDTH = 1,
    
    parameter WUSER_ENABLE = 0,
    
    parameter WUSER_WIDTH = 1,
    
    parameter BUSER_ENABLE = 0,
    
    parameter BUSER_WIDTH = 1,
    
    parameter ARUSER_ENABLE = 0,
    
    parameter ARUSER_WIDTH = 1,
    
    parameter RUSER_ENABLE = 0,
    
    parameter RUSER_WIDTH = 1,
    
    parameter FORWARD_ID = 0,
    
    parameter M_REGIONS = 1,
    
    
    
    parameter M_BASE_ADDR = 0,
    
    
    parameter M_ADDR_WIDTH = {M_COUNT{{M_REGIONS{32'd24}}}},
    
    
    parameter M_CONNECT_READ = {M_COUNT{{S_COUNT{1'b1}}}},
    
    
    parameter M_CONNECT_WRITE = {M_COUNT{{S_COUNT{1'b1}}}},
    
    
    parameter M_SECURE = {M_COUNT{1'b0}}
)
(
    input  wire                            clk,
    input  wire                            rst,

    
    input  wire [S_COUNT*ID_WIDTH-1:0]     s_axi_awid,
    input  wire [S_COUNT*ADDR_WIDTH-1:0]   s_axi_awaddr,
    input  wire [S_COUNT*8-1:0]            s_axi_awlen,
    input  wire [S_COUNT*3-1:0]            s_axi_awsize,
    input  wire [S_COUNT*2-1:0]            s_axi_awburst,
    input  wire [S_COUNT-1:0]              s_axi_awlock,
    input  wire [S_COUNT*4-1:0]            s_axi_awcache,
    input  wire [S_COUNT*3-1:0]            s_axi_awprot,
    input  wire [S_COUNT*4-1:0]            s_axi_awqos,
    input  wire [S_COUNT*AWUSER_WIDTH-1:0] s_axi_awuser,
    input  wire [S_COUNT-1:0]              s_axi_awvalid,
    output logic [S_COUNT-1:0]              s_axi_awready,
    input  wire [S_COUNT*DATA_WIDTH-1:0]   s_axi_wdata,
    input  wire [S_COUNT*STRB_WIDTH-1:0]   s_axi_wstrb,
    input  wire [S_COUNT-1:0]              s_axi_wlast,
    input  wire [S_COUNT*WUSER_WIDTH-1:0]  s_axi_wuser,
    input  wire [S_COUNT-1:0]              s_axi_wvalid,
    output logic [S_COUNT-1:0]              s_axi_wready,
    output logic [S_COUNT*ID_WIDTH-1:0]     s_axi_bid,
    output logic [S_COUNT*2-1:0]            s_axi_bresp,
    output logic [S_COUNT*BUSER_WIDTH-1:0]  s_axi_buser,
    output logic [S_COUNT-1:0]              s_axi_bvalid,
    input  wire [S_COUNT-1:0]              s_axi_bready,
    input  wire [S_COUNT*ID_WIDTH-1:0]     s_axi_arid,
    input  wire [S_COUNT*ADDR_WIDTH-1:0]   s_axi_araddr,
    input  wire [S_COUNT*8-1:0]            s_axi_arlen,
    input  wire [S_COUNT*3-1:0]            s_axi_arsize,
    input  wire [S_COUNT*2-1:0]            s_axi_arburst,
    input  wire [S_COUNT-1:0]              s_axi_arlock,
    input  wire [S_COUNT*4-1:0]            s_axi_arcache,
    input  wire [S_COUNT*3-1:0]            s_axi_arprot,
    input  wire [S_COUNT*4-1:0]            s_axi_arqos,
    input  wire [S_COUNT*ARUSER_WIDTH-1:0] s_axi_aruser,
    input  wire [S_COUNT-1:0]              s_axi_arvalid,
    output logic [S_COUNT-1:0]              s_axi_arready,
    output logic [S_COUNT*ID_WIDTH-1:0]     s_axi_rid,
    output logic [S_COUNT*DATA_WIDTH-1:0]   s_axi_rdata,
    output logic [S_COUNT*2-1:0]            s_axi_rresp,
    output logic [S_COUNT-1:0]              s_axi_rlast,
    output logic [S_COUNT*RUSER_WIDTH-1:0]  s_axi_ruser,
    output logic [S_COUNT-1:0]              s_axi_rvalid,
    input  wire [S_COUNT-1:0]              s_axi_rready,

    
    output logic [M_COUNT*ID_WIDTH-1:0]     m_axi_awid,
    output logic [M_COUNT*ADDR_WIDTH-1:0]   m_axi_awaddr,
    output logic [M_COUNT*8-1:0]            m_axi_awlen,
    output logic [M_COUNT*3-1:0]            m_axi_awsize,
    output logic [M_COUNT*2-1:0]            m_axi_awburst,
    output logic [M_COUNT-1:0]              m_axi_awlock,
    output logic [M_COUNT*4-1:0]            m_axi_awcache,
    output logic [M_COUNT*3-1:0]            m_axi_awprot,
    output logic [M_COUNT*4-1:0]            m_axi_awqos,
    output logic [M_COUNT*4-1:0]            m_axi_awregion,
    output logic [M_COUNT*AWUSER_WIDTH-1:0] m_axi_awuser,
    output logic [M_COUNT-1:0]              m_axi_awvalid,
    input  wire [M_COUNT-1:0]              m_axi_awready,
    output logic [M_COUNT*DATA_WIDTH-1:0]   m_axi_wdata,
    output logic [M_COUNT*STRB_WIDTH-1:0]   m_axi_wstrb,
    output logic [M_COUNT-1:0]              m_axi_wlast,
    output logic [M_COUNT*WUSER_WIDTH-1:0]  m_axi_wuser,
    output logic [M_COUNT-1:0]              m_axi_wvalid,
    input  wire [M_COUNT-1:0]              m_axi_wready,
    input  wire [M_COUNT*ID_WIDTH-1:0]     m_axi_bid,
    input  wire [M_COUNT*2-1:0]            m_axi_bresp,
    input  wire [M_COUNT*BUSER_WIDTH-1:0]  m_axi_buser,
    input  wire [M_COUNT-1:0]              m_axi_bvalid,
    output logic [M_COUNT-1:0]              m_axi_bready,
    output logic [M_COUNT*ID_WIDTH-1:0]     m_axi_arid,
    output logic [M_COUNT*ADDR_WIDTH-1:0]   m_axi_araddr,
    output logic [M_COUNT*8-1:0]            m_axi_arlen,
    output logic [M_COUNT*3-1:0]            m_axi_arsize,
    output logic [M_COUNT*2-1:0]            m_axi_arburst,
    output logic [M_COUNT-1:0]              m_axi_arlock,
    output logic [M_COUNT*4-1:0]            m_axi_arcache,
    output logic [M_COUNT*3-1:0]            m_axi_arprot,
    output logic [M_COUNT*4-1:0]            m_axi_arqos,
    output logic [M_COUNT*4-1:0]            m_axi_arregion,
    output logic [M_COUNT*ARUSER_WIDTH-1:0] m_axi_aruser,
    output logic [M_COUNT-1:0]              m_axi_arvalid,
    input  wire [M_COUNT-1:0]              m_axi_arready,
    input  wire [M_COUNT*ID_WIDTH-1:0]     m_axi_rid,
    input  wire [M_COUNT*DATA_WIDTH-1:0]   m_axi_rdata,
    input  wire [M_COUNT*2-1:0]            m_axi_rresp,
    input  wire [M_COUNT-1:0]              m_axi_rlast,
    input  wire [M_COUNT*RUSER_WIDTH-1:0]  m_axi_ruser,
    input  wire [M_COUNT-1:0]              m_axi_rvalid,
    output logic [M_COUNT-1:0]              m_axi_rready
);

typedef struct packed {
logic[7:0] id;
logic[31:0] addr;
logic[7:0] len;
logic[2:0] size;
logic[1:0] burst;
logic lock_bit;
logic[3:0] cache_bits;
logic[2:0] protection;
logic[3:0] quality;
} descriptor_t;
typedef struct packed {logic[31:0] data; logic[3:0] strobe; logic last_bit;} write_beat_t;
typedef struct packed {logic[7:0] id; logic[31:0] data; logic[1:0] response; logic last_bit;} read_beat_t;
descriptor_t descriptor;
write_beat_t writes[$];
read_beat_t reads[$];
integer selected_request=-1, next_priority=0, destination=0, service_phase=0;
logic[3:0] address_write_ready=0,address_read_ready=0,write_ready=0,response_valid=0;
logic[3:0] outgoing_write_address=0,outgoing_read_address=0,response_ready=0,read_ready=0;
logic[1:0] response_code=0;
logic header_waiting=0,write_capacity=0,read_capacity=0;
integer remaining_reads=0;
logic history_epoch=0;
always_comb begin : output_projection
logic epoch_observed;
epoch_observed=history_epoch;
s_axi_awready=address_write_ready;
s_axi_arready=address_read_ready;
s_axi_wready=write_ready;
s_axi_bvalid=response_valid;
s_axi_bid={4{descriptor.id}};
s_axi_bresp={4{response_code}};
s_axi_buser=0;
m_axi_awvalid=outgoing_write_address;
m_axi_arvalid=outgoing_read_address;
m_axi_bready=response_ready;
m_axi_rready=read_ready;
m_axi_awid=0; m_axi_arid=0;
m_axi_awaddr={4{descriptor.addr}}; m_axi_araddr={4{descriptor.addr}};
m_axi_awlen={4{descriptor.len}}; m_axi_arlen={4{descriptor.len}};
m_axi_awsize={4{descriptor.size}}; m_axi_arsize={4{descriptor.size}};
m_axi_awburst={4{descriptor.burst}}; m_axi_arburst={4{descriptor.burst}};
m_axi_awlock={4{descriptor.lock_bit}}; m_axi_arlock={4{descriptor.lock_bit}};
m_axi_awcache={4{descriptor.cache_bits}}; m_axi_arcache={4{descriptor.cache_bits}};
m_axi_awprot={4{descriptor.protection}}; m_axi_arprot={4{descriptor.protection}};
m_axi_awqos={4{descriptor.quality}}; m_axi_arqos={4{descriptor.quality}};
m_axi_awregion=0; m_axi_arregion=0; m_axi_awuser=0; m_axi_aruser=0;
m_axi_wvalid=0; m_axi_wdata=0; m_axi_wstrb=0; m_axi_wlast=0; m_axi_wuser=0;
s_axi_rvalid=0; s_axi_rid=0; s_axi_rdata=0; s_axi_rresp=0; s_axi_rlast=0; s_axi_ruser=0;
if(writes.size()>0) begin
m_axi_wvalid=4'b1<<destination;
m_axi_wdata={4{writes[0].data}};
m_axi_wstrb={4{writes[0].strobe}};
m_axi_wlast={4{writes[0].last_bit}};
end
if(reads.size()>0 && selected_request>=0) begin
s_axi_rvalid=4'b1<<(selected_request/2);
s_axi_rid={4{reads[0].id}};
s_axi_rdata={4{reads[0].data}};
s_axi_rresp={4{reads[0].response}};
s_axi_rlast={4{reads[0].last_bit}};
end
end
always @(posedge clk) begin : advance_history
integer owner, old_destination, old_phase, winner;
logic completed, insert_write, insert_read, retire_write, retire_read;
logic next_write_capacity,next_read_capacity;
logic previous_write_handshake,previous_response_ready;
write_beat_t incoming_write, discarded_write;
read_beat_t incoming_read, discarded_read;
#0;
owner=selected_request<0 ? 0 : selected_request/2;
old_destination=destination;
old_phase=service_phase;
previous_write_handshake=write_ready[owner] && s_axi_wvalid[owner];
previous_response_ready=response_ready[destination];
completed=0;
if(selected_request>=0) begin
if(selected_request%2==0) completed=response_valid[owner] && s_axi_bready[owner];
else completed=reads.size()>0 && s_axi_rready[owner] && reads[0].last_bit;
end
insert_write=old_phase==2 && write_ready[owner] && s_axi_wvalid[owner];
insert_read=(old_phase==6 && read_ready[destination] && m_axi_rvalid[destination]) || old_phase==5;
incoming_write='{s_axi_wdata[owner*32+:32],s_axi_wstrb[owner*4+:4],s_axi_wlast[owner]};
incoming_read='{descriptor.id,m_axi_rdata[destination*32+:32],m_axi_rresp[destination*2+:2],m_axi_rlast[destination]};
if(old_phase==5) incoming_read='{descriptor.id,32'b0,2'b11,remaining_reads==1};
retire_write=writes.size()>0 && m_axi_wready[destination];
retire_read=reads.size()>0 && s_axi_rready[owner];
next_write_capacity=m_axi_wready[destination] || (writes.size()-(retire_write?1:0)+(insert_write?1:0)<2);
next_read_capacity=s_axi_rready[owner] || (reads.size()-(retire_read?1:0)+(insert_read && read_capacity?1:0)<2);
address_write_ready=0;
address_read_ready=0;
response_valid=response_valid & ~s_axi_bready;
outgoing_write_address=outgoing_write_address & ~m_axi_awready;
outgoing_read_address=outgoing_read_address & ~m_axi_arready;
response_ready=0;
read_ready=0;
case(old_phase)
0: if(selected_request>=0) begin
if(selected_request%2) begin
descriptor='{s_axi_arid[owner*8+:8],s_axi_araddr[owner*32+:32],s_axi_arlen[owner*8+:8],s_axi_arsize[owner*3+:3],s_axi_arburst[owner*2+:2],s_axi_arlock[owner],s_axi_arcache[owner*4+:4],s_axi_arprot[owner*3+:3],s_axi_arqos[owner*4+:4]};
address_read_ready=4'b1<<owner;
end else begin
descriptor='{s_axi_awid[owner*8+:8],s_axi_awaddr[owner*32+:32],s_axi_awlen[owner*8+:8],s_axi_awsize[owner*3+:3],s_axi_awburst[owner*2+:2],s_axi_awlock[owner],s_axi_awcache[owner*4+:4],s_axi_awprot[owner*3+:3],s_axi_awqos[owner*4+:4]};
address_write_ready=4'b1<<owner;
end
remaining_reads=int'(descriptor.len)+1;
header_waiting=1;
service_phase=1;
end
1: begin
if(descriptor.addr[31:24]<4) begin
destination=int'(descriptor.addr[31:24]);
if(selected_request%2) begin service_phase=6; read_ready=next_read_capacity ? (4'b1<<old_destination) : 0; end
else begin service_phase=2; write_ready=next_write_capacity ? (4'b1<<owner) : 0; end
end else begin
if(selected_request%2) service_phase=5;
else begin service_phase=4; write_ready=4'b1<<owner; response_code=3; end
end
end
2: begin
write_ready=next_write_capacity ? (4'b1<<owner) : 0;
if(header_waiting) outgoing_write_address=4'b1<<destination;
header_waiting=0;
if(insert_write && incoming_write.last_bit) begin
write_ready=0; response_ready=4'b1<<destination; service_phase=3;
end
end
3: begin
response_ready=4'b1<<destination;
if(m_axi_bvalid[destination] && previous_response_ready) begin
response_ready=0; response_code=m_axi_bresp[destination*2+:2]; response_valid=4'b1<<owner; service_phase=7;
end
end
4: begin
header_waiting=0;
write_ready=4'b1<<owner;
if(previous_write_handshake && s_axi_wlast[owner]) begin
write_ready=0; response_valid=4'b1<<owner; service_phase=7;
end
end
5: if(read_capacity) begin
remaining_reads--;
if(remaining_reads==0) service_phase=7;
end
6: begin
read_ready=next_read_capacity ? (4'b1<<destination) : 0;
if(header_waiting) outgoing_read_address=4'b1<<destination;
header_waiting=0;
if(insert_read && incoming_read.last_bit) begin read_ready=0; service_phase=7; end
end
7: if(completed || selected_request<0) service_phase=0;
endcase
if(retire_write) discarded_write=writes.pop_front();
if(insert_write && write_capacity) writes.push_back(incoming_write);
if(retire_read) discarded_read=reads.pop_front();
if(insert_read && read_capacity) reads.push_back(incoming_read);
write_capacity=next_write_capacity;
read_capacity=next_read_capacity;
if(selected_request<0 || completed) begin
winner=-1;
for(integer offset=0;offset<8;offset++) begin
integer candidate;
candidate=(next_priority+offset)%8;
if(winner<0 && ((candidate%2==0 && s_axi_awvalid[candidate/2]) || (candidate%2==1 && s_axi_arvalid[candidate/2]))) winner=candidate;
end
selected_request=winner;
if(winner>=0) next_priority=(winner+1)%8;
end
if(rst) begin
selected_request=-1; next_priority=0; service_phase=0;
address_write_ready=0;address_read_ready=0;write_ready=0;response_valid=0;
outgoing_write_address=0;outgoing_read_address=0;response_ready=0;read_ready=0;
writes.delete();reads.delete();write_capacity=0;read_capacity=0;
end
history_epoch=~history_epoch;
end
endmodule
