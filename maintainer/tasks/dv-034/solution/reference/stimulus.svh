
apply('0,1);
drive[1]=1; apply(drive,3);
drive[1]=0; drive[6]=1; apply(drive,1);
for(integer section=0;section<1444;section=section+1) begin
  drive[5:2]=$urandom_range(0,10);
  drive[0]=$urandom_range(0,1); drive[7]=$urandom_range(0,1);
  apply(drive,256);
end
drive[1]=1;apply(drive,3);
drive[1]=0;drive[6]=0;apply(drive,31000);
for(integer section=0;section<1024;section=section+1) begin
  drive[6]=$urandom_range(0,1);
  drive[5:2]=$urandom_range(0,10);
  apply(drive,$urandom_range(1,31));
end
drive[1]=1;apply(drive,2);drive[1]=0;apply(drive,300);
