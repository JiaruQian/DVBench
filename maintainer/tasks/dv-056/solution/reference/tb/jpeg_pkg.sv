package jpeg_native_pkg;
 import uvm_pkg::*; `include "uvm_macros.svh"
 class block_item extends uvm_sequence_item;
  `uvm_object_utils(block_item)
  int op;int ras[3][64];bit reset_first,abort_first;int block_num;
  function new(string n="block_item");super.new(n);endfunction
 endclass
 class stimulus extends uvm_sequence#(block_item);
  `uvm_object_utils(stimulus)
  function new(string n="stimulus");super.new(n);endfunction
  task body();block_item t;
   for(int op=0;op<16;op++)begin
    t=block_item::type_id::create("t");start_item(t);t.op=op;t.reset_first=(op==0 || op==8);t.abort_first=(op==14);t.block_num=(op==3 || op==6)?0:1;
    for(int c=0;c<3;c++)for(int j=0;j<64;j++)begin
     t.ras[c][j]=0;
     if(op>=5 && op!=8)t.ras[c][j]=($urandom_range(0,3)==0)?int'($urandom_range(0,254))-127:0;
     if(op==2 || (op==5 && c==1))t.ras[c][j]=int'($urandom_range(0,14))-7;
    end
    for(int c=0;c<3;c++)t.ras[c][63]=0;
    if(op==1)begin t.ras[0][0]=1;t.ras[1][0]=-1;t.ras[2][0]=3;end
    if(op==3 || op==4)begin
     t.ras[0][0]=-127;t.ras[0][9]=84;t.ras[0][18]=94;t.ras[0][27]=35;t.ras[0][36]=30;t.ras[0][45]=10;t.ras[0][54]=13;t.ras[0][63]=10;
    end
    if(op==4)t.ras[0][1]=127;
    if(op==5)for(int j=0;j<64;j++)t.ras[0][j]=0;
    if(op==11)begin
     for(int c=0;c<3;c++)begin
      for(int j=0;j<64;j++)t.ras[c][j]=0;
      t.ras[c][0]=1023;t.ras[c][1]=1;
     end
    end
    if(op==15)begin
     for(int c=0;c<3;c++)for(int j=0;j<64;j++)t.ras[c][j]=0;
     t.ras[0][0]=-128;t.ras[0][1]=256;t.ras[1][0]=-511;t.ras[2][0]=1023;t.ras[2][1]=1;
    end
    finish_item(t);
   end
  endtask
 endclass
 class native_driver extends uvm_driver#(block_item);
  `uvm_component_utils(native_driver)
  virtual jpeg_native_if vif;int code[256],nbits[256],map[64];int completed=0;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);
   if(!uvm_config_db#(virtual jpeg_native_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing")
   code[0]=10;nbits[0]=4;
code[1]=0;nbits[1]=2;
code[2]=1;nbits[2]=2;
code[3]=4;nbits[3]=3;
code[4]=11;nbits[4]=4;
code[5]=26;nbits[5]=5;
code[6]=120;nbits[6]=7;
code[7]=248;nbits[7]=8;
code[8]=1014;nbits[8]=10;
code[9]=65410;nbits[9]=16;
code[10]=65411;nbits[10]=16;
code[17]=12;nbits[17]=4;
code[18]=27;nbits[18]=5;
code[19]=121;nbits[19]=7;
code[20]=502;nbits[20]=9;
code[21]=2038;nbits[21]=11;
code[22]=65412;nbits[22]=16;
code[23]=65413;nbits[23]=16;
code[24]=65414;nbits[24]=16;
code[25]=65415;nbits[25]=16;
code[26]=65416;nbits[26]=16;
code[33]=28;nbits[33]=5;
code[34]=249;nbits[34]=8;
code[35]=1015;nbits[35]=10;
code[36]=4084;nbits[36]=12;
code[37]=65417;nbits[37]=16;
code[38]=65418;nbits[38]=16;
code[39]=65419;nbits[39]=16;
code[40]=65420;nbits[40]=16;
code[41]=65421;nbits[41]=16;
code[42]=65422;nbits[42]=16;
code[49]=58;nbits[49]=6;
code[50]=503;nbits[50]=9;
code[51]=4085;nbits[51]=12;
code[52]=65423;nbits[52]=16;
code[53]=65424;nbits[53]=16;
code[54]=65425;nbits[54]=16;
code[55]=65426;nbits[55]=16;
code[56]=65427;nbits[56]=16;
code[57]=65428;nbits[57]=16;
code[58]=65429;nbits[58]=16;
code[65]=59;nbits[65]=6;
code[66]=1016;nbits[66]=10;
code[67]=65430;nbits[67]=16;
code[68]=65431;nbits[68]=16;
code[69]=65432;nbits[69]=16;
code[70]=65433;nbits[70]=16;
code[71]=65434;nbits[71]=16;
code[72]=65435;nbits[72]=16;
code[73]=65436;nbits[73]=16;
code[74]=65437;nbits[74]=16;
code[81]=122;nbits[81]=7;
code[82]=2039;nbits[82]=11;
code[83]=65438;nbits[83]=16;
code[84]=65439;nbits[84]=16;
code[85]=65440;nbits[85]=16;
code[86]=65441;nbits[86]=16;
code[87]=65442;nbits[87]=16;
code[88]=65443;nbits[88]=16;
code[89]=65444;nbits[89]=16;
code[90]=65445;nbits[90]=16;
code[97]=123;nbits[97]=7;
code[98]=4086;nbits[98]=12;
code[99]=65446;nbits[99]=16;
code[100]=65447;nbits[100]=16;
code[101]=65448;nbits[101]=16;
code[102]=65449;nbits[102]=16;
code[103]=65450;nbits[103]=16;
code[104]=65451;nbits[104]=16;
code[105]=65452;nbits[105]=16;
code[106]=65453;nbits[106]=16;
code[113]=250;nbits[113]=8;
code[114]=4087;nbits[114]=12;
code[115]=65454;nbits[115]=16;
code[116]=65455;nbits[116]=16;
code[117]=65456;nbits[117]=16;
code[118]=65457;nbits[118]=16;
code[119]=65458;nbits[119]=16;
code[120]=65459;nbits[120]=16;
code[121]=65460;nbits[121]=16;
code[122]=65461;nbits[122]=16;
code[129]=504;nbits[129]=9;
code[130]=32704;nbits[130]=15;
code[131]=65462;nbits[131]=16;
code[132]=65463;nbits[132]=16;
code[133]=65464;nbits[133]=16;
code[134]=65465;nbits[134]=16;
code[135]=65466;nbits[135]=16;
code[136]=65467;nbits[136]=16;
code[137]=65468;nbits[137]=16;
code[138]=65469;nbits[138]=16;
code[145]=505;nbits[145]=9;
code[146]=65470;nbits[146]=16;
code[147]=65471;nbits[147]=16;
code[148]=65472;nbits[148]=16;
code[149]=65473;nbits[149]=16;
code[150]=65474;nbits[150]=16;
code[151]=65475;nbits[151]=16;
code[152]=65476;nbits[152]=16;
code[153]=65477;nbits[153]=16;
code[154]=65478;nbits[154]=16;
code[161]=506;nbits[161]=9;
code[162]=65479;nbits[162]=16;
code[163]=65480;nbits[163]=16;
code[164]=65481;nbits[164]=16;
code[165]=65482;nbits[165]=16;
code[166]=65483;nbits[166]=16;
code[167]=65484;nbits[167]=16;
code[168]=65485;nbits[168]=16;
code[169]=65486;nbits[169]=16;
code[170]=65487;nbits[170]=16;
code[177]=1017;nbits[177]=10;
code[178]=65488;nbits[178]=16;
code[179]=65489;nbits[179]=16;
code[180]=65490;nbits[180]=16;
code[181]=65491;nbits[181]=16;
code[182]=65492;nbits[182]=16;
code[183]=65493;nbits[183]=16;
code[184]=65494;nbits[184]=16;
code[185]=65495;nbits[185]=16;
code[186]=65496;nbits[186]=16;
code[193]=1018;nbits[193]=10;
code[194]=65497;nbits[194]=16;
code[195]=65498;nbits[195]=16;
code[196]=65499;nbits[196]=16;
code[197]=65500;nbits[197]=16;
code[198]=65501;nbits[198]=16;
code[199]=65502;nbits[199]=16;
code[200]=65503;nbits[200]=16;
code[201]=65504;nbits[201]=16;
code[202]=65505;nbits[202]=16;
code[209]=2040;nbits[209]=11;
code[210]=65506;nbits[210]=16;
code[211]=65507;nbits[211]=16;
code[212]=65508;nbits[212]=16;
code[213]=65509;nbits[213]=16;
code[214]=65510;nbits[214]=16;
code[215]=65511;nbits[215]=16;
code[216]=65512;nbits[216]=16;
code[217]=65513;nbits[217]=16;
code[218]=65514;nbits[218]=16;
code[225]=65515;nbits[225]=16;
code[226]=65516;nbits[226]=16;
code[227]=65517;nbits[227]=16;
code[228]=65518;nbits[228]=16;
code[229]=65519;nbits[229]=16;
code[230]=65520;nbits[230]=16;
code[231]=65521;nbits[231]=16;
code[232]=65522;nbits[232]=16;
code[233]=65523;nbits[233]=16;
code[234]=65524;nbits[234]=16;
code[240]=2041;nbits[240]=11;
code[241]=65525;nbits[241]=16;
code[242]=65526;nbits[242]=16;
code[243]=65527;nbits[243]=16;
code[244]=65528;nbits[244]=16;
code[245]=65529;nbits[245]=16;
code[246]=65530;nbits[246]=16;
code[247]=65531;nbits[247]=16;
code[248]=65532;nbits[248]=16;
code[249]=65533;nbits[249]=16;
code[250]=65534;nbits[250]=16;
map[0]=0;
map[1]=1;
map[2]=8;
map[3]=16;
map[4]=9;
map[5]=2;
map[6]=3;
map[7]=10;
map[8]=17;
map[9]=24;
map[10]=32;
map[11]=25;
map[12]=18;
map[13]=11;
map[14]=4;
map[15]=5;
map[16]=12;
map[17]=19;
map[18]=26;
map[19]=33;
map[20]=40;
map[21]=48;
map[22]=41;
map[23]=34;
map[24]=27;
map[25]=20;
map[26]=13;
map[27]=6;
map[28]=7;
map[29]=14;
map[30]=21;
map[31]=28;
map[32]=35;
map[33]=42;
map[34]=49;
map[35]=56;
map[36]=57;
map[37]=50;
map[38]=43;
map[39]=36;
map[40]=29;
map[41]=22;
map[42]=15;
map[43]=23;
map[44]=30;
map[45]=37;
map[46]=44;
map[47]=51;
map[48]=58;
map[49]=59;
map[50]=52;
map[51]=45;
map[52]=38;
map[53]=31;
map[54]=39;
map[55]=46;
map[56]=53;
map[57]=60;
map[58]=61;
map[59]=54;
map[60]=47;
map[61]=55;
map[62]=62;
map[63]=63;

  endfunction
  task append_bits(ref logic[1023:0]bs,ref int count,input int value,input int n);
   for(int k=n-1;k>=0;k--)begin bs[count]=(value>>k)&1;count++;end
  endtask
  task encode(input int raster[64],output logic[1023:0]bs,output logic[10:0]len);
   int run,amp,cat,count,sym;bs=0;count=0;run=0;
   for(int i=0;i<64;i++)begin
    amp=raster[map[i]];
    if(amp==0)begin run++;continue;end
    while(run>=16)begin append_bits(bs,count,code[240],nbits[240]);run-=16;end
    cat=0;for(int v=(amp<0?-amp:amp);v!=0;v=v>>1)cat++;
    sym=run*16+cat;append_bits(bs,count,code[sym],nbits[sym]);
    append_bits(bs,count,amp>0?amp:((1<<cat)-1)+amp,cat);run=0;
   end
   append_bits(bs,count,code[0],nbits[0]);len=count;
   if(count>1024)`uvm_fatal("ENCODE","capacity")
  endtask
  task tick();@(negedge vif.clk);endtask
  task do_reset();vif.rst_n=0;vif.start=0;repeat(3)tick();vif.rst_n=1;repeat(3)tick();endtask
  task run_phase(uvm_phase p);int cyc;
   forever begin
    seq_item_port.get_next_item(req);tick();
    if(req.reset_first)do_reset();
    for(int c=0;c<3;c++)encode(req.ras[c],vif.bs[c],vif.len[c]);vif.block_num=req.block_num;
    if(req.op==12)for(int c=0;c<3;c++)vif.len[c]-=nbits[0];
    $display("INPUT time=%0t op=%0d reset=%b abort=%b block=%0d len=%0d/%0d/%0d Y=%h Cb=%h Cr=%h",$time,req.op,req.reset_first,req.abort_first,req.block_num,vif.len[0],vif.len[1],vif.len[2],vif.bs[0],vif.bs[1],vif.bs[2]);
    vif.start=1;tick();vif.start=0;
    if(req.abort_first)begin repeat(20)tick();do_reset();vif.start=1;tick();vif.start=0;end
    for(cyc=0;cyc<4000;cyc++)begin tick();if(vif.done===1'b1)break;end
    if(cyc>=4000)`uvm_error("COMPLETION","native transaction not complete")
    else completed++;
    repeat(5)tick();seq_item_port.item_done();
   end
  endtask
 endclass
 class sample_item extends uvm_sequence_item;
  `uvm_object_utils(sample_item)
  logic done,edone,trig,etrig;logic[10:0]bits,ebits;logic[511:0]R,G,B,eR,eG,eB;
  function new(string n="sample_item");super.new(n);endfunction
 endclass
 class native_monitor extends uvm_monitor;
  `uvm_component_utils(native_monitor)
  virtual jpeg_native_if vif;uvm_analysis_port#(sample_item)ap;bit armed=0;
  function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);endfunction
  function void build_phase(uvm_phase p);if(!uvm_config_db#(virtual jpeg_native_if)::get(this,"","vif",vif))`uvm_fatal("VIF","missing") endfunction
  task run_phase(uvm_phase p);sample_item s;
   forever begin @(posedge vif.clk);#2;if(!vif.rst_n)armed=1;if(!armed)continue;
    s=sample_item::type_id::create("s");s.done=vif.done;s.edone=vif.edone;s.trig=vif.trig;s.etrig=vif.etrig;s.bits=vif.bits;s.ebits=vif.ebits;
    s.R=vif.R;s.G=vif.G;s.B=vif.B;s.eR=vif.eR;s.eG=vif.eG;s.eB=vif.eB;ap.write(s);
   end
  endtask
 endclass
 class native_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(native_scoreboard)
  uvm_analysis_imp#(sample_item,native_scoreboard)imp;int points=0,errors=0,done_count=0,trigger_points=0;
  covergroup cg with function sample(sample_item s);
   coverpoint s.done;coverpoint s.trig;coverpoint s.bits {bins empty={4};bins other=default;}
  endgroup
  function new(string n,uvm_component p);super.new(n,p);imp=new("imp",this);cg=new;endfunction
  function void write(sample_item s);
   points++;cg.sample(s);if(s.done===1'b1)$display("OUTPUT point=%0d done=%b trig=%b bits=%d R=%h G=%h B=%h",points,s.done,s.trig,s.bits,s.R,s.G,s.B);if(s.done===1'b1)done_count++;if(s.trig===1'b1)trigger_points++;
   if(s.done!==s.edone || s.trig!==s.etrig || s.bits!==s.ebits || (s.edone===1'b1 && (s.R!==s.eR || s.G!==s.eG || s.B!==s.eB)))begin
    errors++;if(errors<=20)`uvm_error("MISMATCH",$sformatf("point=%0d done=%b/%b bits=%d/%d trig=%b/%b RGB=%h/%h %h/%h %h/%h",points,s.done,s.edone,s.bits,s.ebits,s.trig,s.etrig,s.R,s.eR,s.G,s.eG,s.B,s.eB))
   end
  endfunction
  function void check_phase(uvm_phase p);
   if(errors>0)`uvm_error("TOTAL_MISMATCH",$sformatf("%0d",errors))
   if(done_count!=16 || trigger_points==0 || points<1000)`uvm_error("VACUITY","missing transaction/trigger/observation activity")
  endfunction
  function void report_phase(uvm_phase p);`uvm_info("COUNTS",$sformatf("points=%0d errors=%0d done=%0d trigger=%0d",points,errors,done_count,trigger_points),UVM_NONE) endfunction
 endclass
 class native_agent extends uvm_agent;
  `uvm_component_utils(native_agent)
  uvm_sequencer#(block_item)sq;native_driver drv;native_monitor mon;native_scoreboard sb;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);sq=new("sq",this);drv=native_driver::type_id::create("drv",this);mon=native_monitor::type_id::create("mon",this);sb=native_scoreboard::type_id::create("sb",this);endfunction
  function void connect_phase(uvm_phase p);drv.seq_item_port.connect(sq.seq_item_export);mon.ap.connect(sb.imp);endfunction
 endclass
 class native_env extends uvm_env;
  `uvm_component_utils(native_env)
  native_agent agent0;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);agent0=native_agent::type_id::create("agent0",this);endfunction
 endclass
 class dvbench_test extends uvm_test;
  `uvm_component_utils(dvbench_test)
  native_env env;
  function new(string n,uvm_component p);super.new(n,p);endfunction
  function void build_phase(uvm_phase p);env=native_env::type_id::create("env",this);endfunction
  task run_phase(uvm_phase p);stimulus s;p.raise_objection(this);s=stimulus::type_id::create("s");s.start(env.agent0.sq);#30;p.drop_objection(this);endtask
  function void report_phase(uvm_phase p);uvm_report_server rs;rs=uvm_report_server::get_server();if(rs.get_severity_count(UVM_ERROR)==0 && rs.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");endfunction
 endclass
endpackage
