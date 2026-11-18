apply('0,1);
drive[348:348]=1;apply(drive,3);drive[348:348]=0;apply(drive,4);
drive[350:350]=1;drive[349:349]=1;
for(integer item=0;item<48;item=item+1) begin
drive[347:300]={$urandom,$urandom};
drive[299:252]={$urandom,$urandom};
drive[251:236]={$urandom,$urandom};
drive[235:204]={$urandom,$urandom};
drive[203:198]={$urandom,$urandom};
drive[197:196]={$urandom,$urandom};
drive[195:193]={$urandom,$urandom};
drive[192:180]={$urandom,$urandom};
drive[178:163]={$urandom,$urandom};
drive[162:147]={$urandom,$urandom};
drive[146:143]={$urandom,$urandom};
drive[142:127]={$urandom,$urandom};
drive[126:63]={$urandom,$urandom};
drive[62:55]={$urandom,$urandom};
drive[54:54]={$urandom,$urandom};
drive[53:53]={$urandom,$urandom};
drive[51:44]={$urandom,$urandom};
drive[43:12]={$urandom,$urandom};
drive[11:4]={$urandom,$urandom};
drive[3:0]={$urandom,$urandom};
drive[179:179]=1;drive[52:52]=1;drive[54:54]=1;apply(drive,1);
drive[179:179]=0;drive[52:52]=0;apply(drive,4);
end
drive[350:350]=0;
repeat(9) begin
drive[179:179]=1;drive[52:52]=1;drive[126:63]={$urandom,$urandom};apply(drive,1);drive[179:179]=0;drive[52:52]=0;apply(drive,4);end
drive[179:179]=1;drive[52:52]=0;apply(drive,20);drive[350:350]=1;apply(drive,5);drive[179:179]=0;apply(drive,20);
drive[349:349]=0;drive[52:52]=1;
for(integer item=0;item<258;item=item+1) begin
drive[126:63]={$urandom,$urandom};
drive[62:55]={$urandom,$urandom};
drive[54:54]={$urandom,$urandom};
drive[53:53]={$urandom,$urandom};
apply(drive,1);end
drive[126:63]=64'haced12345678beef;apply(drive,20);drive[349:349]=1;apply(drive,4);drive[52:52]=0;apply(drive,300);
repeat(600) begin
drive[52:52]=1;drive[126:63]={$urandom,$urandom};drive[62:55]=$urandom;drive[54:54]=$urandom;drive[53:53]=$urandom;apply(drive,1);end
drive[52:52]=0;apply(drive,300);drive[348:348]=1;apply(drive,3);drive[348:348]=0;apply(drive,10);
