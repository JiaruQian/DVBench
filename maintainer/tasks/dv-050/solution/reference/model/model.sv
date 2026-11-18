// Independent mathematical oracle: full-block compression computed on acceptance;
// one abstract retirement deadline. No DUT outputs, RTL round state or sliding W memory.
module dvbench_sha_history(input logic clk,reset_n,init,next,mode,input logic[511:0] block,
 output wire ready,output logic[255:0] digest,output logic digest_valid);

function automatic logic [31:0] rr(input logic[31:0] x,input int n);
 return (x>>n)|(x<<(32-n));
endfunction
function automatic logic [255:0] iv(input logic md);
 return md ? 256'h6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19 :
             256'hc1059ed8367cd5073070dd17f70e5939ffc00b316858151164f98fa7befa4fa4;
endfunction
function automatic logic [255:0] compress(input logic[255:0] start,input logic[511:0] message);
 logic [31:0] schedule[64],v[8],old[8],x,y;
 logic [31:0] k[64];
 k='{32'h428a2f98,32'h71374491,32'hb5c0fbcf,32'he9b5dba5,32'h3956c25b,32'h59f111f1,32'h923f82a4,32'hab1c5ed5,32'hd807aa98,32'h12835b01,32'h243185be,32'h550c7dc3,32'h72be5d74,32'h80deb1fe,32'h9bdc06a7,32'hc19bf174,32'he49b69c1,32'hefbe4786,32'h0fc19dc6,32'h240ca1cc,32'h2de92c6f,32'h4a7484aa,32'h5cb0a9dc,32'h76f988da,32'h983e5152,32'ha831c66d,32'hb00327c8,32'hbf597fc7,32'hc6e00bf3,32'hd5a79147,32'h06ca6351,32'h14292967,32'h27b70a85,32'h2e1b2138,32'h4d2c6dfc,32'h53380d13,32'h650a7354,32'h766a0abb,32'h81c2c92e,32'h92722c85,32'ha2bfe8a1,32'ha81a664b,32'hc24b8b70,32'hc76c51a3,32'hd192e819,32'hd6990624,32'hf40e3585,32'h106aa070,32'h19a4c116,32'h1e376c08,32'h2748774c,32'h34b0bcb5,32'h391c0cb3,32'h4ed8aa4a,32'h5b9cca4f,32'h682e6ff3,32'h748f82ee,32'h78a5636f,32'h84c87814,32'h8cc70208,32'h90befffa,32'ha4506ceb,32'hbef9a3f7,32'hc67178f2};
 for(int j=0;j<8;j++)begin v[j]=start[255-j*32-:32];old[j]=v[j];end
 for(int j=0;j<16;j++)schedule[j]=message[511-j*32-:32];
 for(int j=16;j<64;j++)
  schedule[j]=schedule[j-16]+(rr(schedule[j-15],7)^rr(schedule[j-15],18)^(schedule[j-15]>>3))
    +schedule[j-7]+(rr(schedule[j-2],17)^rr(schedule[j-2],19)^(schedule[j-2]>>10));
 for(int j=0;j<64;j++)begin
  x=v[7]+(rr(v[4],6)^rr(v[4],11)^rr(v[4],25))+((v[4]&v[5])^((~v[4])&v[6]))+k[j]+schedule[j];
  y=(rr(v[0],2)^rr(v[0],13)^rr(v[0],22))+((v[0]&v[1])^(v[0]&v[2])^(v[1]&v[2]));
  v[7]=v[6];v[6]=v[5];v[5]=v[4];v[4]=v[3]+x;
  v[3]=v[2];v[2]=v[1];v[1]=v[0];v[0]=x+y;
 end
 for(int j=0;j<8;j++)compress[255-j*32-:32]=old[j]+v[j];
endfunction

integer remaining;
logic[255:0] pending;
assign ready=(remaining==0);
always @(posedge clk or negedge reset_n) begin
 if(!reset_n)begin remaining<=0;digest<=0;digest_valid<=0;pending<=0;end
 else if(remaining!=0)begin
  remaining<=remaining-1;
  if(remaining==1)begin digest<=pending;digest_valid<=1;end
 end else if(init||next)begin
  pending<=compress(init?iv(mode):digest,block);
  if(init)digest<=iv(mode);
  digest_valid<=0;remaining<=65;
 end
end
endmodule

module dvbench_model(input logic clk,reset_n,init,next,mode,input logic[511:0] block,
 output wire ready,output wire[255:0] digest,output wire digest_valid);
dvbench_sha_history prediction(.*);
endmodule
