`timescale 1ns/1ps
module dvbench_model #(
parameter int FpFormat=0,parameter int unsigned NumPipeRegs=0,parameter int PipeConfig=0,parameter type TagType=logic,parameter type AuxType=logic,
localparam int E=FpFormat==1?11:(FpFormat==2||FpFormat==3)?5:8,
localparam int M=FpFormat==0?23:FpFormat==1?52:FpFormat==2?10:FpFormat==3?2:7,
localparam int WIDTH=1+E+M,localparam int ExtRegEnaWidth=NumPipeRegs==0?1:NumPipeRegs
)(input logic clk_i,rst_ni,input logic[2:0][WIDTH-1:0]operands_i,input logic[2:0]is_boxed_i,input logic[2:0]rnd_mode_i,input logic[3:0]op_i,input logic op_mod_i,input TagType tag_i,input logic mask_i,input AuxType aux_i,input logic in_valid_i,output logic in_ready_o,input logic flush_i,output logic[WIDTH-1:0]result_o,output logic[4:0]status_o,output logic extension_bit_o,output TagType tag_o,output logic mask_o,output AuxType aux_o,output logic out_valid_o,input logic out_ready_i,output logic busy_o,input logic[ExtRegEnaWidth-1:0]reg_ena_i);
localparam int B=(1<<(E-1))-1,MAXE=(1<<E)-1,SUB=B+M-1,BIG=2*(1<<E)+2*M+8;
typedef logic[BIG-1:0]big_t;
typedef struct packed{logic[WIDTH-1:0]result;logic[4:0]flags;TagType tag;logic mask;AuxType aux;logic uf_live_sensitive;} packet_t;
function automatic logic[WIDTH+4:0] mathematical_fma(input logic[2:0][WIDTH-1:0]ops,input logic[2:0]boxed,input logic[2:0]rm,input logic[3:0]op,input logic modc,output logic uf_live_sensitive);
 logic[WIDTH-1:0]a[3],ans;logic[4:0]flags;bit nan[3],snan[3],inf[3],zero[3],sg[3],ps,cs,negative,guard,sticky,inc,inexact,over;int ex[3],high,drop,encoded,postexp;
 big_t magnitude[3],prod,add,absolute,retained,lowmask;logic signed[BIG-1:0]sum;logic[WIDTH-2:0]pre,rounded;
 flags=0;uf_live_sensitive=0;
 for(int i=0;i<3;i++)a[i]=ops[i];
 a[2][WIDTH-1]^=modc;
 if(op==1)a[0][WIDTH-1]=~a[0][WIDTH-1];
 if(op==2)begin a[0]=WIDTH'(B)<<M;end
 if(op==3)begin a[2]=0;a[2][WIDTH-1]=(rm!=2);end
 for(int i=0;i<3;i++)begin
  ex[i]=a[i][M+:E];sg[i]=a[i][WIDTH-1];
  nan[i]=(ex[i]==MAXE&&|a[i][M-1:0])||!boxed[i];snan[i]=boxed[i]&&ex[i]==MAXE&&|a[i][M-1:0]&&!a[i][M-1];inf[i]=boxed[i]&&ex[i]==MAXE&&a[i][M-1:0]==0;zero[i]=boxed[i]&&ex[i]==0&&a[i][M-1:0]==0;
  if(op==2&&i==0)begin nan[i]=0;snan[i]=0;inf[i]=0;zero[i]=0;end
  if(op==3&&i==2)begin nan[i]=0;snan[i]=0;inf[i]=0;zero[i]=1;end
  magnitude[i]=a[i][M-1:0];if(ex[i]!=0)magnitude[i][M]=1;
  magnitude[i]<<=(ex[i]==0?0:ex[i]-1);
 end
 ps=sg[0]^sg[1];cs=sg[2];ans=(WIDTH'(MAXE)<<M)|(WIDTH'(1)<<(M-1));
 if((inf[0]&&zero[1])||(zero[0]&&inf[1]))flags[4]=1;
 else if(nan[0]||nan[1]||nan[2])flags[4]=snan[0]||snan[1]||snan[2];
 else if(inf[0]||inf[1]||inf[2])begin
  if((inf[0]||inf[1])&&inf[2]&&(ps!=cs))flags[4]=1;
  else begin ans=(WIDTH'(MAXE)<<M);ans[WIDTH-1]=(inf[0]||inf[1])?ps:cs;end
 end else begin
  prod=magnitude[0]*magnitude[1];add=magnitude[2]<<SUB;
  sum=(ps?-$signed(prod):$signed(prod))+(cs?-$signed(add):$signed(add));negative=sum<0;absolute=negative?big_t'(-sum):big_t'(sum);
  if(absolute==0)begin ans=0;ans[WIDTH-1]=(ps!=cs)?rm==2:ps;end
  else begin
   high=0;for(int i=0;i<BIG;i++)if(absolute[i])high=i;
   encoded=high-2*SUB+B;drop=high-M;if(drop<SUB)drop=SUB;
   retained=absolute>>drop;guard=drop>0?absolute[drop-1]:0;sticky=0;for(int i=0;i<drop-1;i++)sticky|=absolute[i];
   over=encoded>=MAXE;
   if(over)begin pre={E'(MAXE-1),{M{1'b1}}};guard=1;sticky=1;end
   else begin pre={E'(encoded>0?encoded:0),retained[M-1:0]};end
   inexact=guard|sticky;inc=0;
   case(rm)0:inc=guard&&(sticky||pre[0]);1:inc=0;2:inc=inexact&&negative;3:inc=inexact&&!negative;4:inc=guard;5:inc=!pre[0]&&inexact;default:inc=1;endcase
   rounded=pre+inc;postexp=rounded[M+:E];ans={negative,rounded};flags[2]=over||postexp==MAXE;flags[0]=inexact||flags[2];flags[1]=(postexp==0)&&flags[0];
   // Tininess is determined by rounding the exact magnitude to full precision with an unbounded exponent.
   // Near the smallest normal number this has half the subnormal-grid spacing.
   if(postexp==1&&encoded<=0&&flags[0])begin
    lowmask=(big_t'(1)<<(SUB+M))-absolute;
    uf_live_sensitive=(lowmask>(big_t'(1)<<(SUB-2)))&&(lowmask<(big_t'(1)<<(SUB-1)));
    if(rm==0||rm==4)flags[1]=lowmask>(big_t'(1)<<(SUB-2));
    else flags[1]=lowmask>=(big_t'(1)<<(SUB-1));
   end
  end
 end
 return {ans,flags};
endfunction
localparam int NIN=PipeConfig==0?NumPipeRegs:PipeConfig==3?(NumPipeRegs+1)/3:0;
localparam int NMID=PipeConfig==2?NumPipeRegs:PipeConfig==3?(NumPipeRegs+2)/3:0;
localparam int NOUT=NumPipeRegs-NIN-NMID;
function automatic packet_t correct_uf(input packet_t packet,input logic[2:0]live_rm);
 packet_t corrected;corrected=packet;
 if(packet.uf_live_sensitive)corrected.flags[1]=(live_rm==0||live_rm==4);
 return corrected;
endfunction
packet_t finalized;
packet_t fresh,stage[NumPipeRegs+1];logic[NumPipeRegs:0]valids,ready_chain;
always_comb begin
 {fresh.result,fresh.flags}=mathematical_fma(operands_i,is_boxed_i,rnd_mode_i,op_i,op_mod_i,fresh.uf_live_sensitive);fresh.tag=tag_i;fresh.mask=mask_i;fresh.aux=aux_i;
 ready_chain[NumPipeRegs]=out_ready_i;
 for(int i=NumPipeRegs-1;i>=0;i--)ready_chain[i]=ready_chain[i+1]||!valids[i+1];
 finalized=correct_uf(stage[NumPipeRegs],rnd_mode_i);
 in_ready_o=ready_chain[0];extension_bit_o=1;
 if(NumPipeRegs==0)begin result_o=fresh.result;status_o=fresh.flags;tag_o=tag_i;mask_o=mask_i;aux_o=aux_i;out_valid_o=in_valid_i;busy_o=in_valid_i;end
 else begin result_o=stage[NumPipeRegs].result;status_o=NOUT==0?finalized.flags:stage[NumPipeRegs].flags;tag_o=stage[NumPipeRegs].tag;mask_o=stage[NumPipeRegs].mask;aux_o=stage[NumPipeRegs].aux;out_valid_o=valids[NumPipeRegs];busy_o=in_valid_i;for(int i=1;i<=NumPipeRegs;i++)busy_o|=valids[i];end
end
always @(posedge clk_i or negedge rst_ni)begin
 if(!rst_ni)begin for(int i=1;i<=NumPipeRegs;i++)begin stage[i]<='0;valids[i]<=0;end end
 else begin
  for(int i=1;i<=NumPipeRegs;i++)begin
   if(flush_i)valids[i]<=0;else if(ready_chain[i-1])valids[i]<=i==1?in_valid_i:valids[i-1];
   if((ready_chain[i-1]&&(i==1?in_valid_i:valids[i-1]))||reg_ena_i[i-1])stage[i]<=((NOUT>0)&&(i==NIN+NMID+1))?correct_uf(i==1?fresh:stage[i-1],rnd_mode_i):(i==1?fresh:stage[i-1]);
  end
 end
end
endmodule
