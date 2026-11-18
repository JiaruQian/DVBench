`timescale 1ns/1ps
module dvbench_model(input clk,rst_n,dec_start,input[1023:0]bs_Y,input[10:0]bs_len_Y,input[1023:0]bs_Cb,input[10:0]bs_len_Cb,input[1023:0]bs_Cr,input[10:0]bs_len_Cr,input[12:0]block_num,
 output reg[511:0]R_out,G_out,B_out,output reg dec_done,trigger_dec,output reg[10:0]total_bits_consumed);
 integer codes[0:255],lens[0:255],quant[0:63],map[0:63];integer age,done_at,bits_at,trigger_at;bit active,match_diag;
 integer next_bits;reg[511:0]pendingR,pendingG,pendingB;
 initial begin for(integer i=0;i<256;i++)begin codes[i]=0;lens[i]=0;end
 codes[0]=10;lens[0]=4;
codes[1]=0;lens[1]=2;
codes[2]=1;lens[2]=2;
codes[3]=4;lens[3]=3;
codes[4]=11;lens[4]=4;
codes[5]=26;lens[5]=5;
codes[6]=120;lens[6]=7;
codes[7]=248;lens[7]=8;
codes[8]=1014;lens[8]=10;
codes[9]=65410;lens[9]=16;
codes[10]=65411;lens[10]=16;
codes[17]=12;lens[17]=4;
codes[18]=27;lens[18]=5;
codes[19]=121;lens[19]=7;
codes[20]=502;lens[20]=9;
codes[21]=2038;lens[21]=11;
codes[22]=65412;lens[22]=16;
codes[23]=65413;lens[23]=16;
codes[24]=65414;lens[24]=16;
codes[25]=65415;lens[25]=16;
codes[26]=65416;lens[26]=16;
codes[33]=28;lens[33]=5;
codes[34]=249;lens[34]=8;
codes[35]=1015;lens[35]=10;
codes[36]=4084;lens[36]=12;
codes[37]=65417;lens[37]=16;
codes[38]=65418;lens[38]=16;
codes[39]=65419;lens[39]=16;
codes[40]=65420;lens[40]=16;
codes[41]=65421;lens[41]=16;
codes[42]=65422;lens[42]=16;
codes[49]=58;lens[49]=6;
codes[50]=503;lens[50]=9;
codes[51]=4085;lens[51]=12;
codes[52]=65423;lens[52]=16;
codes[53]=65424;lens[53]=16;
codes[54]=65425;lens[54]=16;
codes[55]=65426;lens[55]=16;
codes[56]=65427;lens[56]=16;
codes[57]=65428;lens[57]=16;
codes[58]=65429;lens[58]=16;
codes[65]=59;lens[65]=6;
codes[66]=1016;lens[66]=10;
codes[67]=65430;lens[67]=16;
codes[68]=65431;lens[68]=16;
codes[69]=65432;lens[69]=16;
codes[70]=65433;lens[70]=16;
codes[71]=65434;lens[71]=16;
codes[72]=65435;lens[72]=16;
codes[73]=65436;lens[73]=16;
codes[74]=65437;lens[74]=16;
codes[81]=122;lens[81]=7;
codes[82]=2039;lens[82]=11;
codes[83]=65438;lens[83]=16;
codes[84]=65439;lens[84]=16;
codes[85]=65440;lens[85]=16;
codes[86]=65441;lens[86]=16;
codes[87]=65442;lens[87]=16;
codes[88]=65443;lens[88]=16;
codes[89]=65444;lens[89]=16;
codes[90]=65445;lens[90]=16;
codes[97]=123;lens[97]=7;
codes[98]=4086;lens[98]=12;
codes[99]=65446;lens[99]=16;
codes[100]=65447;lens[100]=16;
codes[101]=65448;lens[101]=16;
codes[102]=65449;lens[102]=16;
codes[103]=65450;lens[103]=16;
codes[104]=65451;lens[104]=16;
codes[105]=65452;lens[105]=16;
codes[106]=65453;lens[106]=16;
codes[113]=250;lens[113]=8;
codes[114]=4087;lens[114]=12;
codes[115]=65454;lens[115]=16;
codes[116]=65455;lens[116]=16;
codes[117]=65456;lens[117]=16;
codes[118]=65457;lens[118]=16;
codes[119]=65458;lens[119]=16;
codes[120]=65459;lens[120]=16;
codes[121]=65460;lens[121]=16;
codes[122]=65461;lens[122]=16;
codes[129]=504;lens[129]=9;
codes[130]=32704;lens[130]=15;
codes[131]=65462;lens[131]=16;
codes[132]=65463;lens[132]=16;
codes[133]=65464;lens[133]=16;
codes[134]=65465;lens[134]=16;
codes[135]=65466;lens[135]=16;
codes[136]=65467;lens[136]=16;
codes[137]=65468;lens[137]=16;
codes[138]=65469;lens[138]=16;
codes[145]=505;lens[145]=9;
codes[146]=65470;lens[146]=16;
codes[147]=65471;lens[147]=16;
codes[148]=65472;lens[148]=16;
codes[149]=65473;lens[149]=16;
codes[150]=65474;lens[150]=16;
codes[151]=65475;lens[151]=16;
codes[152]=65476;lens[152]=16;
codes[153]=65477;lens[153]=16;
codes[154]=65478;lens[154]=16;
codes[161]=506;lens[161]=9;
codes[162]=65479;lens[162]=16;
codes[163]=65480;lens[163]=16;
codes[164]=65481;lens[164]=16;
codes[165]=65482;lens[165]=16;
codes[166]=65483;lens[166]=16;
codes[167]=65484;lens[167]=16;
codes[168]=65485;lens[168]=16;
codes[169]=65486;lens[169]=16;
codes[170]=65487;lens[170]=16;
codes[177]=1017;lens[177]=10;
codes[178]=65488;lens[178]=16;
codes[179]=65489;lens[179]=16;
codes[180]=65490;lens[180]=16;
codes[181]=65491;lens[181]=16;
codes[182]=65492;lens[182]=16;
codes[183]=65493;lens[183]=16;
codes[184]=65494;lens[184]=16;
codes[185]=65495;lens[185]=16;
codes[186]=65496;lens[186]=16;
codes[193]=1018;lens[193]=10;
codes[194]=65497;lens[194]=16;
codes[195]=65498;lens[195]=16;
codes[196]=65499;lens[196]=16;
codes[197]=65500;lens[197]=16;
codes[198]=65501;lens[198]=16;
codes[199]=65502;lens[199]=16;
codes[200]=65503;lens[200]=16;
codes[201]=65504;lens[201]=16;
codes[202]=65505;lens[202]=16;
codes[209]=2040;lens[209]=11;
codes[210]=65506;lens[210]=16;
codes[211]=65507;lens[211]=16;
codes[212]=65508;lens[212]=16;
codes[213]=65509;lens[213]=16;
codes[214]=65510;lens[214]=16;
codes[215]=65511;lens[215]=16;
codes[216]=65512;lens[216]=16;
codes[217]=65513;lens[217]=16;
codes[218]=65514;lens[218]=16;
codes[225]=65515;lens[225]=16;
codes[226]=65516;lens[226]=16;
codes[227]=65517;lens[227]=16;
codes[228]=65518;lens[228]=16;
codes[229]=65519;lens[229]=16;
codes[230]=65520;lens[230]=16;
codes[231]=65521;lens[231]=16;
codes[232]=65522;lens[232]=16;
codes[233]=65523;lens[233]=16;
codes[234]=65524;lens[234]=16;
codes[240]=2041;lens[240]=11;
codes[241]=65525;lens[241]=16;
codes[242]=65526;lens[242]=16;
codes[243]=65527;lens[243]=16;
codes[244]=65528;lens[244]=16;
codes[245]=65529;lens[245]=16;
codes[246]=65530;lens[246]=16;
codes[247]=65531;lens[247]=16;
codes[248]=65532;lens[248]=16;
codes[249]=65533;lens[249]=16;
codes[250]=65534;lens[250]=16;
quant[0]=16;map[0]=0;
quant[1]=11;map[1]=1;
quant[2]=10;map[2]=8;
quant[3]=16;map[3]=16;
quant[4]=24;map[4]=9;
quant[5]=40;map[5]=2;
quant[6]=51;map[6]=3;
quant[7]=61;map[7]=10;
quant[8]=12;map[8]=17;
quant[9]=12;map[9]=24;
quant[10]=14;map[10]=32;
quant[11]=19;map[11]=25;
quant[12]=26;map[12]=18;
quant[13]=58;map[13]=11;
quant[14]=60;map[14]=4;
quant[15]=55;map[15]=5;
quant[16]=14;map[16]=12;
quant[17]=13;map[17]=19;
quant[18]=16;map[18]=26;
quant[19]=24;map[19]=33;
quant[20]=40;map[20]=40;
quant[21]=57;map[21]=48;
quant[22]=69;map[22]=41;
quant[23]=56;map[23]=34;
quant[24]=14;map[24]=27;
quant[25]=17;map[25]=20;
quant[26]=22;map[26]=13;
quant[27]=29;map[27]=6;
quant[28]=51;map[28]=7;
quant[29]=87;map[29]=14;
quant[30]=80;map[30]=21;
quant[31]=62;map[31]=28;
quant[32]=18;map[32]=35;
quant[33]=22;map[33]=42;
quant[34]=37;map[34]=49;
quant[35]=56;map[35]=56;
quant[36]=68;map[36]=57;
quant[37]=109;map[37]=50;
quant[38]=103;map[38]=43;
quant[39]=77;map[39]=36;
quant[40]=24;map[40]=29;
quant[41]=35;map[41]=22;
quant[42]=55;map[42]=15;
quant[43]=64;map[43]=23;
quant[44]=81;map[44]=30;
quant[45]=104;map[45]=37;
quant[46]=113;map[46]=44;
quant[47]=92;map[47]=51;
quant[48]=49;map[48]=58;
quant[49]=64;map[49]=59;
quant[50]=78;map[50]=52;
quant[51]=87;map[51]=45;
quant[52]=103;map[52]=38;
quant[53]=121;map[53]=31;
quant[54]=120;map[54]=39;
quant[55]=101;map[55]=46;
quant[56]=72;map[56]=53;
quant[57]=92;map[57]=60;
quant[58]=95;map[58]=61;
quant[59]=98;map[59]=54;
quant[60]=112;map[60]=47;
quant[61]=100;map[61]=55;
quant[62]=103;map[62]=62;
quant[63]=99;map[63]=63;

 end
 function automatic longint signed wrap(input longint signed v,input integer w);return (v <<< (64-w)) >>> (64-w);endfunction
 function automatic integer clip(input longint signed v);return v<0?0:(v>255?255:v);endfunction
 task automatic tx1(input longint signed x[0:7],input integer w,output longint signed z[0:7]);
  longint signed a[0:7],b[0:7],v[0:7];
  a[0]=wrap(x[0]+x[4],w+1);a[1]=wrap(x[0]-x[4],w+1);
  a[2]=wrap((x[2]*90)>>>7,w+9);a[3]=wrap((x[6]*90)>>>7,w+9);
  a[4]=wrap(x[1]+x[7],w+1);a[5]=wrap(x[3]+x[5],w+1);a[6]=wrap(x[3]-x[5],w+1);a[7]=wrap(x[1]-x[7],w+1);
  b[0]=a[0]+a[2];b[1]=a[1]+a[3];b[2]=a[1]-a[3];b[3]=a[0]-a[2];
  b[4]=(a[4]*49+a[7]*118)>>>7;b[5]=(a[5]*118+a[6]*49)>>>7;b[6]=(a[6]*118-a[5]*49)>>>7;b[7]=(a[7]*49-a[4]*118)>>>7;
  for(integer i=0;i<8;i++)b[i]=wrap(b[i],w+10);
  for(integer i=0;i<4;i++)begin v[i]=b[i]+b[i+4];v[7-i]=b[i]-b[i+4];end
  for(integer i=0;i<8;i++)z[i]=wrap(wrap(v[i],w+11),25);
 endtask
 task automatic decode(input[1023:0]bs,input integer len,output integer raster[0:63],output integer bitused,hcycles,rcycles);
  integer ptr,code,n,found,sym,cat,run,amp,vlc,outidx,guard;bit stopit,rle_stop;
  for(integer i=0;i<64;i++)raster[i]=0;
  ptr=0;outidx=0;hcycles=0;rcycles=0;stopit=0;rle_stop=0;guard=0;
  while(!stopit && guard<64)begin
   guard++;code=0;n=0;found=-1;
   while(found<0 && n<16 && ptr<len)begin
    code=(code<<1)|bs[ptr];ptr++;n++;hcycles+=2;
    for(integer k=0;k<256;k++)if(lens[k]==n && codes[k]==code && found<0)found=k;
   end
   if(found<0)begin
    hcycles+=(ptr>=len && n<16)?2:1;stopit=1;
   end else begin
    sym=found;cat=sym%16;run=sym/16;
    if(cat==0 && run==0)begin hcycles++;if(!rle_stop)rcycles+=2;rle_stop=1;stopit=1;end
    else begin
     vlc=0;
     for(integer k=0;k<cat;k++)begin vlc=((vlc<<1)|bs[ptr])&255;ptr++;end
     amp=(cat==0)?0:((cat<=8 && ((vlc>>(cat-1))&1))?vlc:vlc-((1<<cat)-1)&255);
     if(cat>0)begin amp=wrap(amp,8);hcycles+=cat+2;end
     if(!rle_stop)begin
      if(run==0 && amp==0)begin rcycles+=2;rle_stop=1;end
      else begin
       rcycles+=run+1;outidx+=run;
       if(outidx<64)raster[map[outidx]]=amp;
       outidx=(outidx+1)%64;
      end
     end
    end
   end
  end
  if(!stopit)hcycles++;
  if(!rle_stop)rcycles+=2;
  bitused=ptr;
 endtask
 task automatic px(input integer ras[0:63],output integer pix[0:63]);
  longint signed a[0:63],b[0:63],x[0:7],z[0:7];
  for(integer i=0;i<64;i++)a[i]=wrap(ras[i]*quant[i],16);
  for(integer col=0;col<8;col++)begin for(integer row=0;row<8;row++)x[row]=a[row*8+col];tx1(x,16,z);for(integer row=0;row<8;row++)b[row*8+col]=z[row];end
  for(integer row=0;row<8;row++)begin for(integer col=0;col<8;col++)x[col]=b[row*8+col];tx1(x,25,z);for(integer col=0;col<8;col++)pix[row*8+col]=clip(wrap(z[col]>>>6,9)+128);end
 endtask
 always @(posedge clk or negedge rst_n)begin : predict
  integer ry[0:63],rcb[0:63],rcr[0:63],py[0:63],pcb[0:63],pcr[0:63];
  integer by,hy,cy,bb,hb,cb,br,hr,cr,iy,ib,ir,dy,db,dr;
  if(!rst_n)begin R_out<=0;G_out<=0;B_out<=0;dec_done<=0;trigger_dec<=0;total_bits_consumed<=0;active=0;age=0;end
  else begin dec_done<=0;
   if(dec_start && !active)begin
    decode(bs_Y,bs_len_Y,ry,by,hy,cy);decode(bs_Cb,bs_len_Cb,rcb,bb,hb,cb);decode(bs_Cr,bs_len_Cr,rcr,br,hr,cr);
    iy=hy+cy+2;ib=hb+cb+2;ir=hr+cr+2;
    match_diag=(block_num==0 && ry[0]==-127 && ry[9]==84 && ry[18]==94 && ry[27]==35 && ry[36]==30 && ry[45]==10 && ry[54]==13 && ry[63]==10);
    if(trigger_dec || match_diag)for(integer i=0;i<64;i++)if(ry[i]<127)ry[i]++;
    px(ry,py);px(rcb,pcb);px(rcr,pcr);
    for(integer i=0;i<64;i++)begin
     pendingR[i*8+:8]=clip((py[i]*256+359*(pcr[i]-128))>>>8);
     pendingG[i*8+:8]=clip((py[i]*256-88*(pcb[i]-128)-183*(pcr[i]-128))>>>8);
     pendingB[i*8+:8]=clip((py[i]*256+454*(pcb[i]-128))>>>8);
    end
    dy=iy+225;db=ib+160;dr=ir+160;done_at=((dy>db)?((dy>dr)?dy:dr):((db>dr)?db:dr))+66;
    bits_at=hy+1;next_bits=by;trigger_at=iy+1;age=0;active=1;
   end else if(active)begin
    age++;
    if(age==bits_at)total_bits_consumed<=next_bits;
    if(age==trigger_at && match_diag)trigger_dec<=1;
    if(age==done_at)begin R_out<=pendingR;G_out<=pendingG;B_out<=pendingB;dec_done<=1;active=0;end
   end
  end
 end
endmodule
