`timescale 1ns/1ps
module dvbench_model(input logic clk,rst,load,start,input logic [127:0] key,iv,iBlock,output logic [127:0] oBlock,output logic idle);
function automatic logic [7:0] mul(input logic [7:0] x,y);
 logic [7:0] a,b,p; a=x;b=y;p=0;
 for(int i=0;i<8;i++) begin if(b[0])p^=a; a={a[6:0],1'b0} ^ (a[7]?8'h1b:8'h00);b>>=1;end
 return p;
endfunction
function automatic logic [7:0] sb(input logic [7:0] x);
 logic [7:0] p,a,z;int n;p=1;a=x;n=254;
 for(int i=0;i<8;i++)begin if(n&1)p=mul(p,a);a=mul(a,a);n>>=1;end
 z=p ^ {p[6:0],p[7]} ^ {p[5:0],p[7:6]} ^ {p[4:0],p[7:5]} ^ {p[3:0],p[7:4]} ^ 8'h63;
 return z;
endfunction
function automatic logic [127:0] transform(input logic [127:0] x,input bit mix_enable);
 logic [7:0] a[0:15],b[0:15];logic [127:0] z;
 for(int r=0;r<4;r++)for(int c=0;c<4;c++)a[4*c+r]=sb(x[127-8*(4*((c+r)%4)+r)-:8]);
 for(int c=0;c<4;c++)for(int r=0;r<4;r++)begin
  b[4*c+r]=a[4*c+r];
  if(mix_enable) b[4*c+r]=mul(a[4*c+r],2)^mul(a[4*c+(r+1)%4],3)^a[4*c+(r+2)%4]^a[4*c+(r+3)%4];
  z[127-8*(4*c+r)-:8]=b[4*c+r];
 end
 return z;
endfunction

function automatic logic [127:0] expand(input logic [127:0] k,input integer r);
 logic [31:0] w[0:3],g;logic [7:0] rc;rc=1;
 for(int n=1;n<r;n++)rc=mul(rc,2);
 g={sb(k[23:16]),sb(k[15:8]),sb(k[7:0]),sb(k[31:24])}^{rc,24'b0};
 for(int n=0;n<4;n++)begin w[n]=k[127-32*n-:32]^(n==0?g:w[n-1]);end
 return {w[0],w[1],w[2],w[3]};
endfunction
logic [127:0] schedule[0:10],keywork,counter,plaintext,intermediate;
integer key_age,cipher_age,core_job,outer_job;
logic [127:0] old_counter;
logic core_available;
assign oBlock=intermediate^plaintext;
assign idle=(outer_job==0);
always @(posedge clk or posedge rst) begin : history_step
 logic ca,ka,ea;logic [127:0] rk;
 if(rst)begin counter=0;plaintext=0;intermediate=0;keywork=0;key_age=-1;cipher_age=-1;core_job=0;outer_job=0;end
 else begin
  old_counter=counter;
  ca=(core_job==0);ka=(key_age<0);ea=(cipher_age<0);
  rk=ka?schedule[(cipher_age<0)?0:cipher_age]:128'b0;
  // outer accepted commands track their completion through independent input histories.
  if(outer_job==0)begin if(load)begin counter=iv;outer_job=1;end else if(start)begin plaintext=iBlock;outer_job=2;end end
  else if(ca)begin if(outer_job==2)counter=counter+1;outer_job=0;end
  if(core_job==0)begin if(load)core_job=1;else if(start)core_job=2;end
  else if((core_job==1&&ka)||(core_job==2&&ea))core_job=0;
  // Cipher acceptance observes the counter value BEFORE this edge updates it.
  // old_counter is supplied below from the nonblocking input-history snapshot.
  if(cipher_age<0)begin if(start)begin intermediate=old_counter;cipher_age=0;end end
  else begin intermediate=(cipher_age==0?intermediate:transform(intermediate,cipher_age<10))^rk;cipher_age++;if(cipher_age==11)cipher_age=-1;end
  if(key_age<0)begin if(load)begin schedule[0]=key;keywork=key;key_age=1;end end
  else begin keywork=expand(keywork,key_age);schedule[key_age]=keywork;key_age++;if(key_age==11)key_age=-1;end
 end
end


endmodule
