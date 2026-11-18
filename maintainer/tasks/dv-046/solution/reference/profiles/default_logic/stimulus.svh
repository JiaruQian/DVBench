function automatic logic[31:0]corner(input int i);
 case(i%18)0:return 0;1:return 32'h80000000;2:return 32'h3f800000;3:return 32'hbf800000;4:return 32'h40000000;5:return 32'h00800000;6:return 1;7:return 32'h007fffff;8:return 32'h7f7fffff;9:return 32'hff7fffff;10:return 32'h7f800000;11:return 32'hff800000;12:return 32'h7fc00001;13:return 32'h7f800001;14:return 32'h3f800001;15:return 32'h33800000;16:return 32'hb3800000;default:return 32'h00800001;endcase
endfunction
task history;
 int seed,unused;logic[95:0]ops;
 if(!$value$plusargs("SEED=%d",seed))seed=1;unused=$urandom(seed);
 drive({1'b0,96'b0,3'b111,3'b0,4'b0,8'b0});drive({1'b0,96'b0,3'b111,3'b0,4'b0,8'b0});
 for(int op=0;op<4;op++)for(int rm=0;rm<6;rm++)for(int modc=0;modc<2;modc++)begin
  for(int i=0;i<18;i++)for(int j=0;j<18;j++)begin
   ops={corner((i+j)%18),corner(j),corner(i)};
   drive({1'b1,ops,3'b111,3'(rm),4'(op),1'(modc),1'(i%2),1'(j%2),1'((i+j)%2),1'b1,1'b0,1'b1,1'b0});
  end
  for(int i=0;i<100;i++)begin ops={$urandom,$urandom,$urandom};drive({1'b1,ops,3'($urandom),3'(rm),4'(op),1'(modc),1'($urandom),1'($urandom),1'($urandom),1'($urandom),1'($urandom),1'($urandom),1'($urandom)});end
 end
 repeat(20)drive({1'b1,96'b0,3'b111,3'b0,4'b0,4'b0,1'b0,1'b0,1'b1,1'b0});
endtask
