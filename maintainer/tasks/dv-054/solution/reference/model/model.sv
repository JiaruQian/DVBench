`timescale 1ns/1ps
module dvbench_model(
input logic MRxClk,MRxDV, input logic[3:0] MRxD,
input logic Reset,Transmitting,input logic[15:0] MaxFL,
input logic r_IFG,HugEn,DlyCrcEn,
output wire[7:0] RxData,output wire RxValid,RxStartFrm,RxEndFrm,
output wire[15:0] ByteCnt,output wire ByteCntEq0,ByteCntGreat2,ByteCntMaxFrame,CrcError,StateIdle,StatePreamble,StateSFD,
output wire[1:0] StateData,input logic[47:0] MAC,
input logic r_Pro,r_Bro,input logic[31:0] r_HASH0,r_HASH1,
output wire RxAbort,AddressMiss,input logic PassAll,ControlFrmAddressOK);
typedef enum logic[2:0] {DISCARD,WAIT_FRAME,WAIT_FIVE,WAIT_DELIMITER,FRAME_PHASE0,FRAME_PHASE1} receive_phase_t;
receive_phase_t phase;
logic[15:0] count;
logic[4:0] gap;
logic[3:0] delay_phase;
logic[7:0] history,pending_byte,predicted_byte;
logic previous_phase0,pending_valid,predicted_valid,pending_start,predicted_start,pending_end,predicted_end;
logic[31:0] crc;
logic[5:0] hash;
logic hash_valid,broadcast_candidate,multicast_candidate,unicast_match,multicast_match,predicted_abort,predicted_miss;
wire p0=phase==FRAME_PHASE0,p1=phase==FRAME_PHASE1;
wire in_frame=p0||p1;
wire at_limit=count==MaxFL&&!HugEn;
wire gap_ready=gap==24||r_IFG;
wire[63:0] hash_table={r_HASH1,r_HASH0};
wire byte_event=p0&&(count!=0||delay_phase>=3);
wire start_event=p0&&((!DlyCrcEn&&count==1)||(DlyCrcEn&&delay_phase==3));
wire end_event=p0&&((!MRxDV&&count>2)||at_limit);
wire dribble=p1&&!MRxDV&&count>2;
wire address_window=in_frame&&count==7;
function automatic logic[31:0] advance(input logic[31:0] old_crc,input logic[3:0] nibble,input logic active);
logic[31:0] v;logic f;
v=old_crc;
for(int i=0;i<4;i++)begin f=active&(v[31]^nibble[i]);v={v[30:0],1'b0}^({32{f}}&32'h04c11db7);end
return v;
endfunction
assign RxData=predicted_byte;
assign RxValid=predicted_valid;
assign RxStartFrm=predicted_start;
assign RxEndFrm=predicted_end;
assign RxAbort=predicted_abort;
assign AddressMiss=predicted_miss;
assign ByteCnt=count+(DlyCrcEn?16'd4:16'd0);
assign ByteCntEq0=count==0;
assign ByteCntGreat2=count>2;
assign ByteCntMaxFrame=at_limit;
assign CrcError=crc!=32'hc704dd7b;
assign StateIdle=phase==WAIT_FRAME;
assign StatePreamble=phase==WAIT_FIVE;
assign StateSFD=phase==WAIT_DELIMITER;
assign StateData={p1,p0};
always @(posedge MRxClk or posedge Reset)begin
 if(Reset)begin
 phase<=DISCARD;count<=0;gap<=0;delay_phase<=0;
 history<=0;pending_byte<=0;predicted_byte<=0;previous_phase0<=0;
 pending_valid<=0;predicted_valid<=0;pending_start<=0;predicted_start<=0;pending_end<=0;predicted_end<=0;
 crc<=32'hffffffff;broadcast_candidate<=0;multicast_candidate<=0;unicast_match<=0;multicast_match<=0;predicted_abort<=0;predicted_miss<=0;
 end else begin
 case(phase)
 DISCARD:if(!MRxDV)phase<=WAIT_FRAME;
 WAIT_FRAME:if(MRxDV)begin if(Transmitting)phase<=DISCARD;else if(MRxD==5)phase<=WAIT_DELIMITER;else phase<=WAIT_FIVE;end
 WAIT_FIVE:if(!MRxDV)phase<=WAIT_FRAME;else if(MRxD==5)phase<=WAIT_DELIMITER;
 WAIT_DELIMITER:if(!MRxDV)phase<=WAIT_FRAME;else if(MRxD==13)phase<=gap_ready?FRAME_PHASE0:DISCARD;
 FRAME_PHASE0:if(!MRxDV)phase<=WAIT_FRAME;else if(at_limit)phase<=DISCARD;else phase<=FRAME_PHASE1;
 FRAME_PHASE1:if(!MRxDV)phase<=WAIT_FRAME;else phase<=FRAME_PHASE0;
 default:phase<=DISCARD;
 endcase
 if(MRxDV&&((phase==WAIT_DELIMITER&&MRxD==13)||(p0&&at_limit)))count<=0;
 else if(MRxDV&&(phase==WAIT_FIVE||phase==WAIT_DELIMITER||(phase==WAIT_FRAME&&!Transmitting)||(p1&&count!=16'hffff&&!(DlyCrcEn&&delay_phase!=0))))count<=count+16'd1;
 if(phase==DISCARD||(phase==WAIT_DELIMITER&&MRxDV&&MRxD==13))gap<=0;
 else if((phase==WAIT_FRAME||phase==WAIT_FIVE||phase==WAIT_DELIMITER)&&!gap_ready)gap<=gap+5'd1;
 if(delay_phase==9)delay_phase<=0;
 else if(DlyCrcEn&&phase==WAIT_DELIMITER)delay_phase<=1;
 else if(DlyCrcEn&&delay_phase!=0)delay_phase<=delay_phase+4'd1;
 history<={MRxD,history[7:4]};previous_phase0<=p0;
 if(byte_event)pending_byte<=history;else if(!previous_phase0)pending_byte<=0;
 predicted_byte<=pending_byte;pending_valid<=byte_event;predicted_valid<=pending_valid;
 pending_start<=start_event;predicted_start<=pending_start;pending_end<=end_event;predicted_end<=pending_end||dribble;
 if(phase==WAIT_DELIMITER||(DlyCrcEn&&delay_phase!=0&&delay_phase<9))crc<=32'hffffffff;
 else crc<=advance(crc,MRxD,MRxDV&&in_frame&&!at_limit);
 if(p0&&count<7&&history!=8'hff)broadcast_candidate<=0;
 else if(p0&&count==1&&history==8'hff)broadcast_candidate<=1;
 else if(predicted_abort||predicted_end)broadcast_candidate<=0;
 if(p0&&count==1&&history[0])multicast_candidate<=1;
 else if(predicted_abort||predicted_end)multicast_candidate<=0;
 if(in_frame&&count>=2&&count<=7)begin
 if(count==2)unicast_match<=predicted_byte==MAC[47:40];
 else unicast_match<=unicast_match&&(predicted_byte==MAC[(7-count)*8+:8]);
 end else if(predicted_end||predicted_abort)unicast_match<=0;
 if(predicted_end||predicted_abort)multicast_match<=0;
 else if(hash_valid&&multicast_candidate)multicast_match<=hash_table[hash];
 predicted_abort<=address_window&&!(unicast_match||(broadcast_candidate&&!r_Bro)||multicast_match||r_Pro);
 if(count==0)predicted_miss<=0;
 else if(address_window)predicted_miss<=!(unicast_match||(broadcast_candidate&&!r_Bro)||multicast_match||(PassAll&&ControlFrmAddressOK));
 end
end
always @(posedge MRxClk)begin
hash_valid<=p0&&count==6;
if(Reset||phase==WAIT_FRAME)hash<=0;
else if(p0&&count==6)hash<=crc[31:26];
end
endmodule
