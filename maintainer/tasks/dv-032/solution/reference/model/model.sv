`timescale 1ns/1ps
module dvbench_model(
 input rst_i,input tck_i,input tdi_i,output logic module_tdo_o,
 input capture_dr_i,input shift_dr_i,input update_dr_i,
 input [63:0] data_register_i,input module_select_i,output logic top_inhibit_o,
 input PRESETn,input PCLK,input PSEL,input PENABLE,input PWRITE,
 input [2:0] PADDR,input [7:0] PWDATA,
 output logic [7:0] PRDATA,output logic PREADY,output logic PSLVERR,output logic int_o
);
 // Input-history event links, ring queues and scheduled operations.
 // No DUT instance, implementation hierarchy, or actual output is observed.
 typedef struct packed {logic [2:0] history;logic held;} event_link;
 function automatic logic active(input event_link q);
  return (q.history[1]^q.history[2])|q.held;
 endfunction
 function automatic event_link advance(input event_link q,input logic source,input logic consume);
  event_link n;n=q;n.history={q.history[1:0],source};
  if(consume)n.held=0;else if(q.history[1]^q.history[2])n.held=1;
  return n;
 endfunction
 logic [7:0] inbound[0:7],outbound[0:7];
 int unsigned in_head,in_tail,out_head,out_tail;
 logic [3:0] in_count,out_count;
 wire [7:0] inbound_head=in_count ? inbound[in_head]:8'hxx;
 wire [7:0] outbound_head=out_count ? outbound[out_head]:8'hxx;
 wire clear_in=PSEL&&PENABLE&&PWRITE&&PADDR==3'd2&&PWDATA[1];
 wire clear_out=PSEL&&PENABLE&&PWRITE&&PADDR==3'd2&&PWDATA[2];
 logic [7:0] lcr,scr;logic [3:0] ier;logic thr_armed,reg_ack;
 wire apb_get=PSEL&&!PENABLE&&!PWRITE&&PADDR==0&&!lcr[7];
 wire apb_put=PSEL&&!PENABLE&&PWRITE&&PADDR==0&&!lcr[7];
 wire iir_read=PSEL&&PENABLE&&!PWRITE&&PADDR==2;
 int unsigned outbound_op,inbound_op;
 logic [7:0] held_outbound_head;
 logic released_tck,write_toggle,read_toggle;logic [7:0] written_byte;
 event_link release_event,write_event,read_event;
 wire write_pending=active(write_event),read_pending=active(read_event);
 wire link_ready=active(release_event);
 wire consume_write=(inbound_op==1),consume_read=(outbound_op==2);
 wire outbound_pop=(outbound_op==2&&out_count!=0);
 wire outbound_push=(outbound_op==1),inbound_pop=(inbound_op==2),inbound_push=(inbound_op==1);
 logic [3:0] count_source[0:1],count_sample[0:1];
 logic count_request_toggle[0:1],count_ack_toggle[0:1];
 event_link count_request_event[0:1],count_ack_event[0:1];
 wire [3:0] current_free=4'd8-in_count,current_available=out_count;
 always @(posedge PCLK or posedge rst_i) begin
  if(rst_i)begin
   release_event<='0;write_event<='0;read_event<='0;
   for(int k=0;k<2;k++)begin count_source[k]<=0;count_request_toggle[k]<=0;count_ack_event[k]<='0;end
  end else begin
   release_event<=advance(release_event,released_tck,1'b0);
   write_event<=advance(write_event,write_toggle,consume_write);
   read_event<=advance(read_event,read_toggle,consume_read);
   for(int k=0;k<2;k++)begin
    if(active(count_ack_event[k])&&count_source[k]!=(k==0?current_free:current_available))begin
     count_source[k]<=k==0?current_free:current_available;
     count_request_toggle[k]<=~count_request_toggle[k];
     count_ack_event[k]<=advance(count_ack_event[k],count_ack_toggle[k],1'b1);
    end else count_ack_event[k]<=advance(count_ack_event[k],count_ack_toggle[k],1'b0);
   end
  end
 end
 always @(posedge tck_i or posedge rst_i) begin
  if(rst_i)begin
   for(int k=0;k<2;k++)begin count_sample[k]<=0;count_ack_toggle[k]<=1;count_request_event[k]<='0;end
  end else begin
   for(int k=0;k<2;k++)begin
    count_request_event[k]<=advance(count_request_event[k],count_request_toggle[k],active(count_request_event[k]));
    if(active(count_request_event[k]))begin count_sample[k]<=count_source[k];count_ack_toggle[k]<=~count_ack_toggle[k];end
   end
  end
 end
 always @(posedge PCLK or posedge rst_i or posedge clear_in)begin
  if(rst_i||clear_in)begin in_count<=0;in_head<=0;in_tail<=0;for(int k=0;k<8;k++)inbound[k]<=0;end
  else if(inbound_push&&in_count<8)begin inbound[in_tail]<=written_byte;in_tail<=(in_tail+1)%8;in_count<=in_count+1;end
  else if(inbound_pop&&in_count!=0)begin in_head<=(in_head+1)%8;in_count<=in_count-1;end
 end
 always @(posedge PCLK or posedge rst_i or posedge clear_out)begin
  if(rst_i||clear_out)begin out_count<=0;out_head<=0;out_tail<=0;for(int k=0;k<8;k++)outbound[k]<=0;end
  else if(outbound_push&&out_count<8)begin outbound[out_tail]<=PWDATA;out_tail<=(out_tail+1)%8;out_count<=out_count+1;end
  else if(outbound_pop)begin out_head<=(out_head+1)%8;out_count<=out_count-1;end
 end
 always @(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin outbound_op<=0;inbound_op<=0;held_outbound_head<=0;end
  else begin
   case(outbound_op)
    0:if(apb_put)outbound_op<=1;else if(read_pending&&out_count!=0)outbound_op<=2;
    1:if(out_count==0)outbound_op<=3;else if(read_pending&&out_count!=0)outbound_op<=2;else outbound_op<=0;
    2:if(apb_put)outbound_op<=1;else outbound_op<=3;
    3:if(apb_put)outbound_op<=1;else if(read_pending&&out_count!=0)outbound_op<=2;else outbound_op<=0;
    default:outbound_op<=0;
   endcase
   case(inbound_op)
    0:if(apb_get)inbound_op<=2;else if(write_pending)inbound_op<=1;
    1:if(apb_get)inbound_op<=2;else inbound_op<=0;
    2:if(write_pending)inbound_op<=1;else inbound_op<=0;
    default:inbound_op<=0;
   endcase
   if(outbound_op==3)held_outbound_head<=outbound_head;
  end
 end
 always @(posedge PCLK)reg_ack<=PSEL&&!PENABLE&&(lcr[7]||PADDR!=0);
 always @(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin ier<=0;lcr<=0;scr<=0;thr_armed<=0;end
  else begin
   if(PSEL&&PENABLE&&PWRITE)case(PADDR)
    1:if(!lcr[7])ier<=PWDATA[3:0];3:lcr<=PWDATA;7:scr<=PWDATA;default:;
   endcase
   if(apb_put||(outbound_pop&&out_count==1))thr_armed<=1;
   else if(iir_read&&in_count==0)thr_armed<=0;
  end
 end
 wire not_full=(out_count!=8)&&link_ready;
 logic [7:0] interrupt_identification;
 always_comb begin
  if(in_count!=0)interrupt_identification=8'h04;
  else if(thr_armed&&not_full)interrupt_identification=8'h02;
  else interrupt_identification=8'h01;
  case(PADDR)
   0:PRDATA=inbound_head;1:PRDATA={4'h0,ier};2:PRDATA=interrupt_identification;
   3:PRDATA=lcr;4:PRDATA=0;5:PRDATA={1'b0,not_full,not_full,4'h0,(in_count!=0)};
   6:PRDATA=8'h0b;7:PRDATA=scr;default:PRDATA=0;
  endcase
  PREADY=(outbound_op==1)||(inbound_op==2)||reg_ack;
  PSLVERR=0;top_inhibit_o=0;
  int_o=(not_full&&thr_armed&&ier[1])||(in_count!=0&&ier[0]);
 end
 int unsigned write_phase,read_phase;
 logic [3:0] write_position,read_position;
 logic [3:0] input_remaining,user_remaining,output_remaining;
 logic [7:0] serial_out;
 wire write_byte_event=write_phase==2&&shift_dr_i&&write_position==7&&input_remaining!=0&&user_remaining!=0;
 wire read_byte_event=read_phase==2&&shift_dr_i&&output_remaining!=0;
 always @(posedge tck_i or posedge rst_i)begin
  if(rst_i)begin
   released_tck<=0;write_toggle<=0;read_toggle<=0;written_byte<=0;
   write_phase<=0;read_phase<=0;write_position<=0;read_position<=0;
   input_remaining<=0;user_remaining<=0;output_remaining<=0;serial_out<=0;
  end else begin
   released_tck<=1;
   if(write_byte_event)begin write_toggle<=~write_toggle;written_byte<={tdi_i,data_register_i[63:57]};end
   if(read_byte_event)read_toggle<=~read_toggle;
   case(write_phase)
    0:if(module_select_i&&capture_dr_i)begin write_phase<=1;write_position<=0;input_remaining<=count_sample[0];end
    1:begin
     if(update_dr_i)write_phase<=0;else if(write_position==7)write_phase<=2;
     if(shift_dr_i)begin
      write_position<=write_position+1'b1;
      if(write_position==7)begin write_position<=0;user_remaining<={tdi_i,data_register_i[63:61]};end
     end
    end
    2:begin
     if(update_dr_i)write_phase<=0;
     if(shift_dr_i)begin
      write_position<=write_position+1'b1;
      if(write_position==7)begin
       write_position<=0;
       if(write_byte_event)begin input_remaining<=input_remaining-1'b1;user_remaining<=user_remaining-1'b1;end
      end
     end
    end
    default:write_phase<=0;
   endcase
   case(read_phase)
    0:if(module_select_i&&capture_dr_i)begin read_phase<=1;read_position<=0;output_remaining<=count_sample[1];serial_out<={count_sample[1],count_sample[0]};end
    1:begin
     if(update_dr_i)read_phase<=0;else if(read_position==7)read_phase<=2;
     if(shift_dr_i)begin
      read_position<=read_position+1'b1;serial_out<={1'b0,serial_out[7:1]};
      if(read_position==7)begin read_position<=0;if(output_remaining!=0)serial_out<=held_outbound_head;end
     end
    end
    2:begin
     if(update_dr_i)read_phase<=0;else read_phase<=3;
     if(shift_dr_i)begin read_position<=read_position+1'b1;serial_out<={1'b0,serial_out[7:1]};end
    end
    3:begin
     if(update_dr_i)read_phase<=0;else if(read_position==7)read_phase<=2;
     if(shift_dr_i)begin
      read_position<=read_position+1'b1;serial_out<={1'b0,serial_out[7:1]};
      if(read_position==7)begin read_position<=0;if(output_remaining!=0)begin serial_out<=held_outbound_head;output_remaining<=output_remaining-1'b1;end end
     end
    end
    default:read_phase<=0;
   endcase
  end
 end
 always_comb module_tdo_o=serial_out[0];
endmodule
