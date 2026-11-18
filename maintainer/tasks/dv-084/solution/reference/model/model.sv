// Behavioral input-history model: ordinal FIFO occupancy and independent host ledger.
// No implementation modules, DUT references, hierarchy or output observations.
`timescale 1ns/1ps
module dvbench_model(
 input clock,reset,input [7:0] in_data,input in_data_vld,
 output logic error,output logic in_suspend,
 output logic[7:0] data_0,data_1,data_2,
 output logic data_vld_0,data_vld_1,data_vld_2,
 input suspend_0,suspend_1,suspend_2,
 input [15:0] haddr,inout wire[7:0] hdata,input hen,hwr_rd);
 logic[7:0] bus_drive=8'hzz, cfg=63, enables=1;
 logic[2:0] ien=0, irq=0;
 logic[4:0] soft_reset=0;
 logic[7:0] rw[256],capture[65];
 int counters[6],visible[6];
 int phase=0,route=0,used[3];
 longint put[3],take[3];
 logic[7:0] fifo_data[3][longint];
 bit full_hold[3];
 logic[7:0] checksum=0,cap_data=0;
 int cap_index=0,cap_size=0,visible_size=0;
 bit cap_active=0;
 bit writing;
 int selected;
 logic[2:0] paused;
 assign hdata=bus_drive;
 always_comb begin
   paused={suspend_2,suspend_1,suspend_0};
   selected=(phase==0 && in_data_vld)?int'(in_data[1:0]):route;
   writing=0;in_suspend=0;
   if(phase==0 && in_data_vld) begin
     if(selected<3) in_suspend=(used[selected]!=0);
     writing=(selected<3 && in_data[7:2]!=0 && in_data[7:2]<=cfg[5:0] && used[selected]==0);
   end
   if(phase==1) begin
     in_suspend=full_hold[route];
     writing=!in_data_vld || !in_suspend;
   end
 end
 // Output sampling is deliberately separate from FIFO acceptance.
 always @(posedge clock or posedge reset) begin
   if(reset || soft_reset[0]) begin data_vld_0<=0;data_vld_1<=0;data_vld_2<=0;end
   else begin
     data_vld_0 <= used[0]>0 && !(used[0]==1 && !(writing && selected==0));
     data_vld_1 <= used[1]>0 && !(used[1]==1 && !(writing && selected==1));
     data_vld_2 <= used[2]>0 && !(used[2]==1 && !(writing && selected==2));
   end
   data_0<=fifo_data[0].exists(take[0])?fifo_data[0][take[0]]:8'hxx;
   data_1<=fifo_data[1].exists(take[1])?fifo_data[1][take[1]]:8'hxx;
   data_2<=fifo_data[2].exists(take[2])?fifo_data[2][take[2]]:8'hxx;
 end
 // Integer ledgers express the packet protocol rather than RTL state encodings.
 always @(negedge clock or posedge reset) begin : history
   bit wr,rd,was_empty,old_active;
   int old_phase,old_selected,idx;
   logic[7:0] host_value;
   old_phase=phase;old_selected=selected;old_active=cap_active;
   host_value=hdata;
   if(reset || soft_reset[0]) begin
     phase=0;route=0;checksum=0;error=0;cap_active=0;cap_index=0;cap_data=0;cap_size=0;
     cfg=63;enables=1;ien=0;irq=0;visible_size=0;bus_drive=0;
     for(int j=0;j<6;j++) begin counters[j]=0;visible[j]=0;end
     for(int j=0;j<65;j++)capture[j]=0;
     for(int j=0;j<3;j++)begin used[j]=0;put[j]=0;take[j]=0;full_hold[j]=0;end
     if(reset)soft_reset=0;
   end else begin
     // Registered host snapshots lag the packet ledgers by one falling edge.
     for(int j=0;j<6;j++)begin
       idx=(j==0)?1:(j==1)?2:(j==2)?7:j+1;
       if(enables[idx] && visible[j]<counters[j])visible[j]=counters[j]&255;
     end
     visible_size=cap_size;
     if(cap_active && cap_index<=64)capture[cap_index]=cap_data;
     for(int j=0;j<3;j++) begin
       wr=writing && old_selected==j;rd=!paused[j];was_empty=used[j]==0;
       if(wr && (rd || !full_hold[j]))begin
         fifo_data[j][put[j]]=in_data;put[j]++;
         if(!rd || was_empty)used[j]++;
       end
       if(rd && !was_empty)begin
         take[j]++;if(!wr)used[j]--;
       end
       if(wr && !rd && used[j]==16)full_hold[j]=1;
       if(rd && !wr)full_hold[j]=0;
     end
     if(in_data_vld && !in_suspend)begin
       error=0;checksum^=in_data;cap_data=in_data;
       if(!cap_active && !soft_reset[4])begin cap_index=0;cap_size=in_data[7:2];cap_active=1;end
       else if(cap_active && !soft_reset[4] && cap_index<cap_size+1)cap_index++;
     end else if(!in_data_vld)begin
       if(old_phase==1 && checksum!=in_data)begin
         error=1;cap_data=in_data;
         if(enables[1] && !soft_reset[1])begin counters[0]=(counters[0]+1)&255;if(ien[0])irq[0]=1;end
         checksum=0;
       end else begin error=0;checksum=0;cap_index=0;cap_data=0;cap_active=0;end
     end
     case(old_phase)
       0:if(in_data_vld)begin
         route=in_data[1:0];
         if(route==3)begin
           phase=2;if(enables[7]&&!soft_reset[1])begin counters[2]=(counters[2]+1)&255;if(ien[2])irq[2]=1;end
         end else if(in_data[7:2]==0 || in_data[7:2]>cfg[5:0])begin
           phase=2;if(enables[2]&&!soft_reset[1])begin counters[1]=(counters[1]+1)&255;if(ien[1])irq[1]=1;end
         end else if(!in_suspend)begin
           phase=1;if(enables[route+4]&&!soft_reset[2])counters[route+3]=(counters[route+3]+1)&255;
         end
       end
       1:if(!in_data_vld)phase=0;
       2:if(!in_data_vld)phase=0;
     endcase
     if(phase==0)cap_active=0;
     if(soft_reset[1])for(int j=0;j<3;j++)begin counters[j]=0;visible[j]=0;end
     if(soft_reset[2])for(int j=3;j<6;j++)begin counters[j]=0;visible[j]=0;end
     if(soft_reset[3])begin ien=0;irq=0;end
     if(soft_reset[4])begin
       for(int j=0;j<65;j++)capture[j]=0;
       cap_index=0;cap_data=0;
     end
   end
   // Host writes require an idle cycle to release the previous read driver.
   if(!hen)bus_drive=8'hzz;
   else if(haddr>=16'h1000 && haddr<=16'h2fff)begin
     if(!hwr_rd)begin
       if(haddr>=16'h1010 && haddr<16'h1051)bus_drive=capture[haddr-16'h1010];
       else if(haddr[15:8]==8'h11)bus_drive=rw[haddr[7:0]];
       else if(haddr[15:8]==8'h10)case(haddr[7:0])
         0:bus_drive={2'b0,cfg[5:0]};
         1:bus_drive=enables;
         2:bus_drive={5'b0,ien};
         3:bus_drive={5'b0,irq};
         4:bus_drive=visible[0];5:bus_drive=visible[1];6:bus_drive=visible[2];
         9:bus_drive=visible[3];10:bus_drive=visible[4];11:bus_drive=visible[5];
         12:bus_drive={3'b0,soft_reset};13:bus_drive=visible_size;
         default:bus_drive=8'hzz;
       endcase
     end else if(haddr[15:8]==8'h11)rw[haddr[7:0]]=host_value;
     else if(haddr[15:8]==8'h10)case(haddr[7:0])
       0:cfg={2'b0,host_value[5:0]};
       1:enables=host_value&8'hf7;
       2:ien=host_value[2:0];
       3:irq&=~(host_value[2:0]&ien);
       12:soft_reset=host_value[4:0];
     endcase
   end
 end
endmodule
