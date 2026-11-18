// Input-history behavioral predictor. No DUT instance or output observation.
// Packet storage is represented by timed records, not the DUT RAM/prefetch RTL.
`timescale 1ns/1ps
module dvbench_model(
 input clk,reset_n,
 input ecdsa_lh_wr,input [11:0] ecdsa_lh_waddr,input [255:0] ecdsa_lh_wdata,
 input [63:0] ecdsa_lh_sn_wdata,input [5:0] ecdsa_lh_ppl_wdata,
 input irl_lh_valid,input [127:0] irl_lh_hdr_data,
 input meta_package::irl_lh_meta_type irl_lh_meta_data,
 input irl_lh_sop,irl_lh_eop,input ecdsa_lh_ready,
 output logic lh_ecdsa_hash_valid,output logic [255:0] lh_ecdsa_hash_data,
 output logic lh_pp_valid,output logic [127:0] lh_pp_hdr_data,
 output meta_package::lh_pp_meta_type lh_pp_meta_data,output logic lh_pp_sop,lh_pp_eop,
 output logic lh_ecdsa_valid,output logic [127:0] lh_ecdsa_hdr_data,
 output meta_package::lh_ecdsa_meta_type lh_ecdsa_meta_data,output logic lh_ecdsa_sop,lh_ecdsa_eop
);
 import meta_package::*;
 typedef struct {logic[127:0] data;irl_lh_meta_type meta;bit sop,eop,t1;int available;} beat_t;
 typedef struct {int due;logic[255:0] hash;bit sn;} lookup_t;
 beat_t ordinary[$],bypass[$],front,lat,toss,last;
 lookup_t scheduled[$],look;
 logic[255:0] table_hash[4096],hash_ring[2],generated_ring[2];
 logic[63:0] table_sn[4096];
 bit serial_ring[2];
 int hr,hw,gr,gw,sr,sw,hcount,gcount,scount;
 int cycle,initialize,retire_hash;
 bit writing;logic[11:0] wa;logic[255:0] wh;logic[63:0] ws;
 bit packet_t3,packet_t1,main_owner,enable_reads,hash_equal;
 bit route_ecd,route_strip,route_shift,route_drop;
 int beat_index;
 bit previous_eop,previous_sop;
 logic[111:0] tail;
 bit head_valid,lat_valid,start_ecd,start_strip,start_shift,start_drop;
 bit ecd,strip,shift,drop,pp,read_main,read_lat,finish_main;
 bit suppress;
 logic[127:0] transformed;
 bit tsop,teop,next_owner,next_enable,next_hash;
 task pp_meta(input irl_lh_meta_type m,input bit disc);
   lh_pp_meta_data.hdr_len<=m.hdr_len;lh_pp_meta_data.buf_ptr<=m.buf_ptr;
   lh_pp_meta_data.len<=m.len;lh_pp_meta_data.port<=m.port;lh_pp_meta_data.rci<=m.rci;
   lh_pp_meta_data.fid<=m.fid;lh_pp_meta_data.tid<=m.tid;lh_pp_meta_data.type1<=m.type1;
   lh_pp_meta_data.type3<=m.type3|disc;lh_pp_meta_data.discard<=m.discard|disc;
 endtask
 task ec_meta(input irl_lh_meta_type m);
   lh_ecdsa_meta_data.traffic_class<=m.traffic_class;lh_ecdsa_meta_data.hdr_len<=m.hdr_len;
   lh_ecdsa_meta_data.buf_ptr<=m.buf_ptr;lh_ecdsa_meta_data.len<=m.len;
   lh_ecdsa_meta_data.port<=m.port;lh_ecdsa_meta_data.rci<=m.rci;
   lh_ecdsa_meta_data.fid<=m.fid;lh_ecdsa_meta_data.tid<=m.tid;
   lh_ecdsa_meta_data.type1<=m.type1;lh_ecdsa_meta_data.type3<=m.type3;
   lh_ecdsa_meta_data.discard<=m.discard;
 endtask
 always @(posedge clk) begin
   if(!reset_n) begin
     ordinary.delete();bypass.delete();scheduled.delete();
     cycle=0;initialize=0;writing=0;retire_hash=-1;
     hr=0;hw=0;gr=0;gw=0;sr=0;sw=0;hcount=0;gcount=0;scount=0;
     packet_t3=0;packet_t1=0;main_owner=1;enable_reads=0;hash_equal=0;
     route_ecd=0;route_strip=0;route_shift=0;route_drop=0;beat_index=0;
     previous_eop=0;
     lh_pp_valid<=0;lh_ecdsa_valid<=0;lh_ecdsa_hash_valid<=0;
   end else begin
     cycle++;
     head_valid=ordinary.size()>0;
     if(head_valid)begin front=ordinary[0];head_valid=front.available<cycle;end
     if(!head_valid)begin front=last;front.data='x;front.sop=0;front.eop=0;end
     lat_valid=bypass.size()>0;
     if(lat_valid)begin lat=bypass[0];lat_valid=lat.available<cycle;end
     start_ecd=head_valid&&front.sop&&hash_equal&&front.t1&&scount>0&&!serial_ring[sr];
     start_strip=head_valid&&front.sop&&hash_equal&&front.t1&&scount>0&&serial_ring[sr];
     start_shift=head_valid&&front.sop&&hash_equal&&!front.t1;
     start_drop=head_valid&&front.sop&&!hash_equal;
     ecd=route_ecd||start_ecd;strip=route_strip||start_strip;
     shift=route_shift||start_shift;drop=route_drop||start_drop;pp=strip||shift||drop;
     read_lat=!main_owner&&lat_valid;
     read_main=head_valid&&enable_reads&&(ecd||(main_owner&&pp));
     finish_main=read_main&&front.eop;
     next_owner=main_owner;
     if(!main_owner) begin
       if((!lat_valid||(read_lat&&lat.eop))&&pp)next_owner=1;
     end else if(!head_valid||(finish_main&&pp&&lat_valid)) next_owner=0;
     next_enable=finish_main?0:retire_hash==cycle?1:enable_reads;
     next_hash=(hcount==0||gcount==0)?1:(hash_ring[hr]==generated_ring[gr]);
     suppress=((strip&&beat_index<4)||drop||(shift&&front.sop))&&!front.eop;
     transformed=(ecd||strip||drop)?front.data:{tail,front.data[127:112]};
     tsop=strip?(beat_index==4):drop?front.eop:shift?previous_sop:(front.sop&&!previous_eop);
     teop=(ecd||strip||drop)?front.eop:previous_eop;
     lh_pp_valid<=((read_main&&pp&&!suppress)||previous_eop||read_lat);
     lh_ecdsa_valid<=read_main&&ecd;
     lh_ecdsa_hash_valid<=read_main&&front.sop;
     lh_ecdsa_hash_data<=generated_ring[gr];
     lh_pp_hdr_data<=read_lat?lat.data:transformed;
     lh_pp_sop<=read_lat?lat.sop:tsop;lh_pp_eop<=read_lat?lat.eop:teop;
     if(read_lat) pp_meta(lat.meta,0);else pp_meta(front.meta,drop);
     lh_ecdsa_hdr_data<=front.data;lh_ecdsa_sop<=front.sop;lh_ecdsa_eop<=front.eop;ec_meta(front.meta);
     if(start_ecd)route_ecd=1;else if(finish_main&&ecd)route_ecd=0;
     if(start_strip)route_strip=1;else if(finish_main&&strip)route_strip=0;
     if(start_shift)route_shift=1;else if(finish_main&&shift)route_shift=0;
     // The pinned drop latch clears on a stripped-packet last beat.
     if(start_drop)route_drop=1;else if(finish_main&&strip)route_drop=0;
     previous_eop=read_main&&shift&&front.eop;
     if(read_main) begin
       tail=front.data[111:0];previous_sop=front.sop;last=front;
       toss=ordinary.pop_front();beat_index=front.eop?0:beat_index+1;
       if(front.sop) begin hr=(hr+1)%2;hcount--;gr=(gr+1)%2;gcount--;end
       if(front.sop&&(ecd||strip||(drop&&front.t1)))begin sr=(sr+1)%2;scount--;end
     end
     if(read_lat)toss=bypass.pop_front();
     main_owner=next_owner;enable_reads=next_enable;hash_equal=next_hash;
     // Delayed writes and read results are added after all pre-edge decisions.
     if(writing)begin table_hash[wa]=wh;table_sn[wa]=ws;end
     if(initialize<=4096)begin table_hash[initialize%4096]=0;table_sn[initialize%4096]=0;initialize++;end
     writing=ecdsa_lh_wr;wa=ecdsa_lh_waddr;wh=ecdsa_lh_wdata;ws=ecdsa_lh_sn_wdata;
     while(scheduled.size()>0)begin
       look=scheduled[0];if(look.due>cycle)break;
       look=scheduled.pop_front();
       if(look.due==cycle)begin
         if(look.hash[255]===1'bx)begin serial_ring[sw]=look.sn;sw=(sw+1)%2;scount++;end
         else begin hash_ring[hw]=look.hash;hw=(hw+1)%2;hcount++;end
       end
     end
     // Read captures refer to the input history, including table state.
     if(irl_lh_valid)begin
       if(irl_lh_sop)begin
         packet_t3=irl_lh_meta_data.type3;packet_t1=irl_lh_meta_data.type1&&!packet_t3;
         if(!packet_t3)begin
           look.due=cycle+2;look.hash=table_hash[irl_lh_meta_data.fid];look.sn=0;scheduled.push_back(look);
           if(packet_t1)begin look.due=cycle+3;look.hash='x;look.sn=(irl_lh_hdr_data[63:0]==table_sn[irl_lh_meta_data.fid]);scheduled.push_back(look);end
         end
       end
       front.data=irl_lh_hdr_data;front.meta=irl_lh_meta_data;front.sop=irl_lh_sop;
       front.eop=irl_lh_eop;front.t1=packet_t1;front.available=cycle+3;
       if(packet_t3)bypass.push_back(front);else ordinary.push_back(front);
       if(irl_lh_eop&&!irl_lh_meta_data.type3)begin
         // Generator's pulse is registered at this edge and sampled next edge.
         retire_hash=cycle+1;
       end
       if(irl_lh_eop)begin packet_t3=0;packet_t1=0;end
     end
     if(retire_hash==cycle)begin generated_ring[gw]=0;gw=(gw+1)%2;gcount++;end
   end
 end
endmodule
