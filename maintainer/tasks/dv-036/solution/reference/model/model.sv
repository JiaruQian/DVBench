`timescale 1ns/1ps
module dvbench_model #(
parameter AXI_ADDR_WIDTH=8,
parameter INIT_PHY_ADDR=5'b10,
parameter INIT_WAIT_CYCLES=2000000,
parameter INIT_POLL_CYCLES=1430000
) (
output logic  init_done_o,
output logic  init_fail_o,
input logic  init_go_i,
output logic  mdc_o,
inout wire  mdio_io,
output logic  phy_link_change_o,
output logic  phy_link_o,
input logic [7:0] s_axi_araddr,
output logic  s_axi_arready,
input logic  s_axi_arvalid,
input logic [7:0] s_axi_awaddr,
output logic  s_axi_awready,
input logic  s_axi_awvalid,
input logic  s_axi_bready,
output logic [1:0] s_axi_bresp,
output logic  s_axi_bvalid,
input logic  s_axi_lite_clk,
input logic  s_axi_lite_resetn,
output logic [31:0] s_axi_rdata,
input logic  s_axi_rready,
output logic [1:0] s_axi_rresp,
output logic  s_axi_rvalid,
input logic [31:0] s_axi_wdata,
output logic  s_axi_wready,
input logic [3:0] s_axi_wstrb,
input logic  s_axi_wvalid
);

logic [16:0] configuration;
logic [15:0] data_register;
logic [15:0] divider_register;
logic [7:0] address_latch;
logic [31:0] data_latch;
logic [3:0] byte_latch;
logic address_valid;
logic data_valid;
logic [7:0] read_address;
logic read_address_valid;
logic completed_sticky;
logic error_sticky;
logic pending;
wire bus_commit=address_valid && data_valid && !s_axi_bvalid;
wire requested=bus_commit && address_latch==8'h0c && byte_latch[0] && data_latch[0];
logic serial_busy;
logic serial_done;
logic serial_error;
logic serial_write;
logic [63:0] serial_frame;
logic [15:0] received;
integer serial_position;
integer serial_age;
logic init_active;
wire cpu_launch=(requested || pending) && !serial_busy && !init_active;
logic init_done;
logic init_failed;
logic link_valid;
logic [1:0] link_speed;
logic link_full;
integer init_stage;
integer init_step;
integer init_part;
integer wait_remaining;
logic go_previous;
logic init_error;
logic strap;
logic [15:0] prior_read;
logic init_issue;
logic init_write;
logic [4:0] init_register;
logic [15:0] init_data;
integer access_kind;
logic [15:0] extended_address;
logic [15:0] clear_mask;
logic [15:0] set_mask;
assign s_axi_awready=s_axi_lite_resetn && !address_valid && !s_axi_bvalid;
assign s_axi_wready=s_axi_lite_resetn && !data_valid && !s_axi_bvalid;
assign s_axi_arready=s_axi_lite_resetn && !read_address_valid && !s_axi_rvalid;
assign s_axi_bresp=0;
assign s_axi_rresp=0;
assign init_done_o=init_done;
assign init_fail_o=init_failed;
wire released=!serial_busy || (!serial_write && serial_position<=17);
assign mdio_io=released ? 1'bz : serial_frame[serial_position];
always @* begin
  init_active=(init_stage==1 || init_stage==2 || init_stage==3 || init_stage==4);
  init_done=(init_stage==5 || ((init_stage==2 || init_stage==3) && init_step==13));
  init_failed=(init_stage==6);
  init_issue=(init_stage==2);
  access_kind=0; extended_address=0; clear_mask=16'hffff; set_mask=0;
  case(init_step)
    0:extended_address=3;
    1:begin access_kind=2;extended_address=16'h006e;end
    2:extended_address=16'h0010;
    3:begin access_kind=1;extended_address=16'h0010;clear_mask=16'hc400 | (strap?16'h0800:0);set_mask=16'h4000;end
    4:begin access_kind=2;extended_address=16'h0031;end
    5:begin access_kind=3;extended_address=16'h0031;clear_mask=16'h0080;end
    6:begin access_kind=2;extended_address=16'h0032;end
    7:begin access_kind=3;extended_address=16'h0032;clear_mask=16'h0001;set_mask=3;end
    8:begin access_kind=3;extended_address=16'h0086;set_mask=16'h0067;end
    13:extended_address=16'h0011;
  endcase
  init_write=1;init_register=0;init_data=0;
  case(init_part)
    0:begin init_register=13;init_data=16'h001f;end
    1:begin init_register=14;init_data=extended_address;end
    2:begin init_register=13;init_data=16'h401f;end
    3:begin
      init_register=access_kind>=2 ? 14 : extended_address[4:0];
      init_write=(access_kind==1 || access_kind==3);
      init_data=(prior_read & ~clear_mask) | set_mask;
    end
  endcase
end
always @(posedge s_axi_lite_clk or negedge s_axi_lite_resetn) begin
  if(!s_axi_lite_resetn) begin
    configuration<=0;data_register<=0;divider_register<=35;
    address_valid<=0;data_valid<=0;s_axi_bvalid<=0;
    read_address_valid<=0;s_axi_rvalid<=0;s_axi_rdata<=0;
    completed_sticky<=0;error_sticky<=0;pending<=0;
  end else begin
    if(cpu_launch) pending<=0;
    else if(requested && (serial_busy || init_active)) pending<=init_active;
    if(s_axi_awvalid && s_axi_awready) begin address_valid<=1;address_latch<=s_axi_awaddr;end
    if(s_axi_wvalid && s_axi_wready) begin data_valid<=1;data_latch<=s_axi_wdata;byte_latch<=s_axi_wstrb;end
    if(serial_done && !init_active) completed_sticky<=1;
    if(serial_error && !init_active) error_sticky<=1;
    if(bus_commit) begin
      address_valid<=0;data_valid<=0;s_axi_bvalid<=1;
      case(address_latch)
        0:begin
          if(byte_latch[0]) configuration[4:0]<=data_latch[4:0];
          if(byte_latch[1]) configuration[12:8]<=data_latch[12:8];
          if(byte_latch[2]) configuration[16]<=data_latch[16];
        end
        4:for(integer byte_index=0;byte_index<2;byte_index=byte_index+1)
            if(byte_latch[byte_index]) data_register[byte_index*8+:8]<=data_latch[byte_index*8+:8];
        16:begin
          if(byte_latch[0] && data_latch[1]) completed_sticky<=0;
          if(byte_latch[0] && data_latch[2]) error_sticky<=0;
        end
        20:for(integer byte_index=0;byte_index<2;byte_index=byte_index+1)
            if(byte_latch[byte_index]) divider_register[byte_index*8+:8]<=data_latch[byte_index*8+:8];
      endcase
    end
    if(s_axi_bvalid && s_axi_bready) s_axi_bvalid<=0;
    if(s_axi_arready && s_axi_arvalid) begin read_address<=s_axi_araddr;read_address_valid<=1;end
    if(read_address_valid && !s_axi_rvalid) begin
      read_address_valid<=0;s_axi_rvalid<=1;
      case(read_address)
        0:s_axi_rdata<={15'd0,configuration[16],3'd0,configuration[12:8],3'd0,configuration[4:0]};
        4:s_axi_rdata<={16'd0,data_register};
        8:s_axi_rdata<={16'd0,received};
        12:s_axi_rdata<=0;
        16:s_axi_rdata<={22'd0,link_valid,link_full,link_speed,phy_link_o,init_failed,init_done,error_sticky,completed_sticky,serial_busy & init_active};
        20:s_axi_rdata<={16'd0,divider_register};
        default:s_axi_rdata<=0;
      endcase
    end
    if(s_axi_rvalid && s_axi_rready) s_axi_rvalid<=0;
  end
end
always @(posedge s_axi_lite_clk) begin
  serial_done<=0;serial_error<=0;
  if(!s_axi_lite_resetn) begin
    serial_busy<=0;serial_age<=0;serial_position<=63;serial_write<=0;
    received<=0;serial_frame<=64'hffffffff60000000;mdc_o<=0;
  end else if(!serial_busy) begin
    serial_age<=0;mdc_o<=0;
    if(init_active ? init_issue : cpu_launch) begin
      serial_busy<=1;serial_position<=63;received<=0;
      serial_write<=init_active ? init_write : configuration[16];
      serial_frame<={32'hffffffff,2'b01,
        (init_active ? init_write : configuration[16]) ? 2'b01 : 2'b10,
        init_active ? INIT_PHY_ADDR : configuration[4:0],
        init_active ? init_register : configuration[12:8],
        (init_active ? init_write : configuration[16]) ? 2'b10 : 2'b00,
        (init_active ? init_write : configuration[16]) ? (init_active ? init_data : data_register) : 16'd0};
    end
  end else if(serial_age>=divider_register) begin
    serial_age<=0;mdc_o<=!mdc_o;
    if(!mdc_o) begin
      if(!serial_write && serial_position==16 && mdio_io!=0) serial_error<=1;
      if(!serial_write && serial_position<=15) received<={received[14:0],mdio_io};
    end else if(serial_position==0) begin serial_busy<=0;serial_done<=1;end
    else serial_position<=serial_position-1;
  end else serial_age<=serial_age+1;
end
always @(posedge s_axi_lite_clk or negedge s_axi_lite_resetn) begin
  if(!s_axi_lite_resetn) begin
    init_stage<=0;init_step<=0;init_part<=0;wait_remaining<=0;go_previous<=0;
    init_error<=0;strap<=0;prior_read<=0;phy_link_o<=0;link_valid<=0;
    link_full<=0;link_speed<=0;phy_link_change_o<=0;
  end else begin
    go_previous<=init_go_i;phy_link_change_o<=0;
    if(serial_error) init_error<=1;
    case(init_stage)
      0,6:begin
        if(init_go_i && !go_previous) begin init_stage<=1;wait_remaining<=INIT_WAIT_CYCLES;init_step<=0;init_error<=0;end
        if(link_valid || phy_link_o) begin link_valid<=0;phy_link_o<=0;if(phy_link_o)phy_link_change_o<=1;end
      end
      1:begin
        if(!init_go_i) init_stage<=0;
        else if(wait_remaining==0) begin init_stage<=2;init_part<=access_kind>=2 ? 0:3;end
        else wait_remaining<=wait_remaining-1;
      end
      2:begin init_stage<=3;init_error<=0;end
      3:if(serial_done) begin
        if(init_step==13) begin
          link_valid<=!(init_error || serial_error);
          phy_link_o<=!(init_error || serial_error) && received[10];
          if(!(init_error || serial_error)) begin link_speed<=received[15:14];link_full<=received[13];end
          if((!(init_error || serial_error) && received[10])!=phy_link_o)phy_link_change_o<=1;
          init_stage<=5;wait_remaining<=INIT_POLL_CYCLES;
        end else if(init_error) init_stage<=6;
        else if(init_part<3) begin init_part<=init_part+1;init_stage<=2;end
        else begin
          if(access_kind==0 || access_kind==2) prior_read<=received;
          if(init_step==1) strap<=received[11];
          if(init_step==0 && received[15:4]!=12'ha23) init_stage<=6;
          else init_stage<=4;
        end
      end
      4:begin
        if(init_step==8) begin init_stage<=5;wait_remaining<=1000;end
        else begin init_step<=init_step+1;init_stage<=1;wait_remaining<=0;end
      end
      5:begin
        if(!init_go_i) init_stage<=0;
        else if(wait_remaining==0) begin init_stage<=2;init_step<=13;init_part<=3;end
        else wait_remaining<=wait_remaining-1;
      end
      default:init_stage<=0;
    endcase
  end
end

endmodule
