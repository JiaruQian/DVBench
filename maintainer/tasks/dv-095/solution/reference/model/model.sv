module dvbench_model(
 input clk,rst,
 input [63:0] s_axis_a_tdata,input s_axis_a_tvalid,output s_axis_a_tready,input s_axis_a_tlast,
 input [63:0] s_axis_b_tdata,input s_axis_b_tvalid,output s_axis_b_tready,input s_axis_b_tlast,
 output reg [255:0] m_axis_c_tdata,output m_axis_c_tvalid,input m_axis_c_tready,output m_axis_c_tlast,
 input [7:0] s_axil_awaddr,input s_axil_awvalid,output s_axil_awready,
 input [31:0] s_axil_wdata,input [3:0] s_axil_wstrb,input s_axil_wvalid,output s_axil_wready,
 output [1:0] s_axil_bresp,output reg s_axil_bvalid,input s_axil_bready,
 input [7:0] s_axil_araddr,input s_axil_arvalid,output s_axil_arready,
 output reg [31:0] s_axil_rdata,output [1:0] s_axil_rresp,output reg s_axil_rvalid,input s_axil_rready,
 output irq
);
 reg address_pending,data_pending,read_pending,start_latch,soft_clear,sticky,irq_enable;
 reg [7:0] write_address,read_address;
 reg [31:0] write_data,tile_count;
 integer phase,received_a,received_b,phase_age,output_row;
 integer signed matrix_a[0:7][0:7],matrix_b[0:7][0:7],matrix_c[0:7][0:7];
 integer signed accumulation;
 wire busy=phase!=0;
 wire done=phase==6;
 wire commit_write=address_pending && data_pending && !s_axil_bvalid;
 assign s_axil_awready=!address_pending;
 assign s_axil_wready=!data_pending;
 assign s_axil_arready=!read_pending && !s_axil_rvalid;
 assign s_axil_bresp=0;
 assign s_axil_rresp=0;
 assign irq=irq_enable && sticky;
 assign s_axis_a_tready=phase==1 && received_a<8;
 assign s_axis_b_tready=(phase==1 || phase==2 || phase==3) && received_b<8;
 assign m_axis_c_tvalid=phase==5;
 assign m_axis_c_tlast=phase==5 && output_row==7;
 always @* begin
   for(integer column=0;column<8;column=column+1)
     m_axis_c_tdata[column*32+:32]=matrix_c[output_row%8][column];
 end
 function automatic [31:0] read_register(input [7:0] address_value);
   case(address_value)
     0:read_register={30'b0,soft_clear,start_latch};
     4:read_register={29'b0,1'b0,sticky,busy};
     8:read_register=tile_count;
     12:read_register=irq_enable;
     16:read_register=32'h10000;
     default:read_register=0;
   endcase
 endfunction
 always @(posedge clk) begin
   if(rst) begin
     address_pending<=0;data_pending<=0;read_pending<=0;
     s_axil_bvalid<=0;s_axil_rvalid<=0;s_axil_rdata<=0;
     write_address<=0;write_data<=0;read_address<=0;
     start_latch<=0;soft_clear<=0;sticky<=0;irq_enable<=0;tile_count<=0;
   end else begin
     soft_clear<=0;
     if(s_axil_awvalid && s_axil_awready)begin address_pending<=1;write_address<=s_axil_awaddr;end
     if(s_axil_wvalid && s_axil_wready)begin data_pending<=1;write_data<=s_axil_wdata;end
     if(commit_write)begin
       address_pending<=0;data_pending<=0;s_axil_bvalid<=1;
       case(write_address)
         0:if(write_data[1])begin soft_clear<=1;start_latch<=0;end else if(!busy)start_latch<=write_data[0];
         4:if(write_data[1])sticky<=0;
         12:irq_enable<=write_data[0];
       endcase
     end
     if(s_axil_bvalid && s_axil_bready)s_axil_bvalid<=0;
     if(s_axil_arvalid && s_axil_arready)begin read_pending<=1;read_address<=s_axil_araddr;end
     if(read_pending && !s_axil_rvalid)begin s_axil_rdata<=read_register(read_address);s_axil_rvalid<=1;read_pending<=0;end
     if(s_axil_rvalid && s_axil_rready)s_axil_rvalid<=0;
     if(done)begin start_latch<=0;sticky<=1;tile_count<=tile_count+1;end
   end
   if(rst || soft_clear)begin phase<=0;received_a<=0;received_b<=0;phase_age<=0;output_row<=0;end
   else begin
     if(s_axis_a_tvalid && s_axis_a_tready)begin
       for(integer column=0;column<8;column=column+1)matrix_a[received_a][column]<=$signed(s_axis_a_tdata[column*8+:8]);
       received_a<=received_a+1;
     end
     if(s_axis_b_tvalid && s_axis_b_tready)begin
       for(integer column=0;column<8;column=column+1)matrix_b[received_b][column]<=$signed(s_axis_b_tdata[column*8+:8]);
       received_b<=received_b+1;
     end
     case(phase)
       0:if(start_latch)begin phase<=1;received_a<=0;received_b<=0;phase_age<=0;output_row<=0;end
       1:if(received_a==8)begin phase<=2;phase_age<=0;end
       2:if(phase_age==7)begin phase_age<=0;if(received_b==8)phase<=4;else phase<=3;end else phase_age<=phase_age+1;
       3:if(received_b==8)begin phase<=4;phase_age<=0;end
       4:begin
         if(phase_age==22)begin
           for(integer row=0;row<8;row=row+1)for(integer column=0;column<8;column=column+1)begin
             accumulation=0;
             for(integer inner=0;inner<8;inner=inner+1)accumulation=accumulation+matrix_a[row][inner]*matrix_b[inner][column];
             matrix_c[row][column]<=accumulation;
           end
           phase<=5;output_row<=0;
         end else phase_age<=phase_age+1;
       end
       5:if(m_axis_c_tready)begin if(output_row==7)phase<=6;else output_row<=output_row+1;end
       6:phase<=0;
       default:phase<=0;
     endcase
   end
 end
endmodule
