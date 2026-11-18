function automatic logic[31:0]corner(input int i);
 case(i%18)0:return 0;1:return 32'h80000000;2:return 32'h3f800000;3:return 32'hbf800000;4:return 32'h40000000;5:return 32'h00800000;6:return 1;7:return 32'h007fffff;8:return 32'h7f7fffff;9:return 32'hff7fffff;10:return 32'h7f800000;11:return 32'hff800000;12:return 32'h7fc00001;13:return 32'h7f800001;14:return 32'h3f800001;15:return 32'h33800000;16:return 32'hb3800000;default:return 32'h00800001;endcase
endfunction

task cycle(input bit rst,input logic[95:0]ops,input logic[2:0]boxed,input int rm,op,modc,tag,maskv,aux,input bit valid,flush,ready,input int ena);
drive({rst,ops,boxed,3'(rm),4'(op),1'(modc),4'(tag),1'(maskv),2'(aux),valid,flush,ready,2'(ena)});
endtask
task history;
 int seed,unused;logic[95:0]ops;
 if(!$value$plusargs("SEED=%d",seed))seed=1;unused=$urandom(seed);
 repeat(3)cycle(0,0,7,0,0,0,0,0,0,0,0,1,0);
 for(int op=0;op<4;op++)for(int rm=0;rm<6;rm++)for(int modc=0;modc<2;modc++)begin
  for(int i=0;i<18;i++)for(int j=0;j<18;j++)begin
   ops={corner((i+j)%18),corner(j),corner(i)};cycle(1,ops,7,rm,op,modc,i,j,i+j,1,0,1,0);
  end
  repeat(100)begin ops={$urandom,$urandom,$urandom};cycle(1,ops,3'($urandom),rm,op,modc,$urandom,$urandom,$urandom,$urandom,0,1,0);end
 end
 repeat(8)cycle(1,{32'h3f800000,32'h40000000,32'h3f800000},7,0,0,0,15,1,3,1,0,0,0);
 repeat(6)cycle(1,0,7,0,0,0,0,0,0,0,0,1,0);
 cycle(1,{32'h3f800000,32'h3f800000,32'h3f800000},7,0,0,0,15,1,3,1,0,1,0);
 cycle(1,0,7,0,0,0,0,0,0,0,1,1,0);
 repeat(3)cycle(0,{32'h3f800000,32'h40000000,32'h3f800000},7,0,0,0,15,0,3,1,0,1,3);
 repeat(6)cycle(1,0,7,0,0,0,0,0,0,0,0,1,0);
 // Pipeline-specific live-rounding boundary and ignored operands.
 repeat(5)begin
  cycle(1,{32'h00800000,32'hb3800000,32'h007fffff},7,3,0,0,9,1,2,1,0,1,0);
  cycle(1,0,7,0,0,0,0,0,0,0,0,1,0);
  cycle(1,0,7,0,0,0,0,0,0,0,0,1,0);
 end
 repeat(10)cycle(1,0,7,0,0,0,0,0,0,0,0,1,0);
endtask
