// Independent algorithmic AES round predictor, input history only.
module dvbench_model(input [127:0] in,input [255:0] Key,input [5:0] counter,
 input clk,output reg [127:0] out,input [5:0] maxRound);
reg [127:0] history;
reg [127:0] mixed, imixed, next_history;
reg [7:0] sb[0:255], ib[0:255];
reg ready=0;
integer init_i;
function automatic [7:0] mul(input [7:0] a0,b0);
 reg [7:0] a,b,v; integer j;
 begin a=a0;b=b0;v=0;for(j=0;j<8;j=j+1)begin
 if(b[0])v=v^a;a={a[6:0],1'b0}^(a[7]?8'h1b:8'h00);b=b>>1;end mul=v;end
endfunction
function automatic [7:0] forward_sbox(input [7:0] x);
 reg [7:0] v,p; integer j;
 begin v=1;p=x;for(j=0;j<8;j=j+1)begin
 if((254>>j)&1)v=mul(v,p);p=mul(p,p);end
 forward_sbox=v^{v[6:0],v[7]}^{v[5:0],v[7:6]}^{v[4:0],v[7:5]}^{v[3:0],v[7:4]}^8'h63;end
endfunction
initial begin for(init_i=0;init_i<256;init_i=init_i+1)begin
 sb[init_i]=forward_sbox(init_i);ib[forward_sbox(init_i)]=init_i;end ready=1;end
function automatic [31:0] subword(input [31:0] w);
 subword={sb[w[31:24]],sb[w[23:16]],sb[w[15:8]],sb[w[7:0]]};
endfunction
function automatic [127:0] roundkey(input [255:0] k,input [5:0] m,c);
 reg [31:0] w[0:59],v;reg[7:0] rc; integer nk,nr,i,q,base;
 begin
 if(m==10)begin nk=4;nr=10;base=10;end
 else if(m==12)begin nk=6;nr=12;base=12;end
 else begin nk=8;nr=14;base=14;end
 for(i=0;i<nk;i=i+1)w[i]=k[255-32*i-:32];
 rc=1;
 for(i=nk;i<4*(nr+1);i=i+1)begin
 v=w[i-1];
 if(i%nk==0)begin v=subword({v[23:0],v[31:24]})^{rc,24'b0};rc=mul(rc,2);end
 else if(nk==8 && i%nk==4)v=subword(v);
 w[i]=w[i-nk]^v;end
 q=nr-(integer'(c)-base);
 if(q>=0 && q<=nr)roundkey={w[4*q],w[4*q+1],w[4*q+2],w[4*q+3]};
 else roundkey='x;
 end
endfunction
function automatic [127:0] invmix(input [127:0] x);
 reg[7:0] a[0:3];integer c,j;
 begin for(c=0;c<4;c=c+1)begin
 for(j=0;j<4;j=j+1)a[j]=x[127-8*(4*c+j)-:8];
 invmix[127-32*c-:32]={
 mul(a[0],14)^mul(a[1],11)^mul(a[2],13)^mul(a[3],9),
 mul(a[0],9)^mul(a[1],14)^mul(a[2],11)^mul(a[3],13),
 mul(a[0],13)^mul(a[1],9)^mul(a[2],14)^mul(a[3],11),
 mul(a[0],11)^mul(a[1],13)^mul(a[2],9)^mul(a[3],14)};end end
endfunction
function automatic [127:0] invshift_sub(input [127:0] x);
 integer c,r,src;reg[7:0] v;
 begin for(c=0;c<4;c=c+1)for(r=0;r<4;r=r+1)begin
 src=4*((c+4-r)%4)+r;v=x[127-8*src-:8];
 invshift_sub[127-8*(4*c+r)-:8]=ib[v];end end
endfunction
always @* begin
 mixed=((counter==maxRound)?in:history)^roundkey(Key,maxRound,counter);
 imixed=invmix(mixed);
 next_history=invshift_sub((counter==maxRound)?mixed:imixed);
 if(!ready)begin out='x;next_history='x;end
 else if(counter==maxRound)out=in;
 else if(counter==6'(maxRound+maxRound-6'd1))out=imixed;
 else out=mixed;
end
always @(posedge clk)if(counter<6'(maxRound+maxRound))history<=next_history;
endmodule
