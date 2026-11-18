function automatic logic[319:0]rs();logic[319:0]x;for(int j=0;j<10;j++)x[32*j+:32]=$urandom;return x;endfunction
function automatic logic[127:0]rk();return {$urandom,$urandom,$urandom,$urandom};endfunction
function automatic logic[63:0]rd();return {$urandom,$urandom};endfunction
task history;
 int seed,unused;logic[319:0]s;logic[127:0]k;logic[63:0]d;
 if(!$value$plusargs("SEED=%d",seed))seed=1;unused=$urandom(seed);
 drive({1'b0,1'b0,1'b0,320'b0,128'b0,64'b0});drive({1'b0,1'b0,1'b0,320'b0,128'b0,64'b0});
 for(int session=0;session<16;session++)begin
  s=rs();k=rk();d=rd();drive({1'b1,1'b1,1'b0,s,k,d});
  // Fixed-history input flow; no scheduling or expected values derived from DUT outputs.
  repeat(120)begin d=rd();drive({1'b1,1'b0,1'b1,s,k,d});end
  repeat(5)drive({1'b1,1'b0,1'b0,s,k,d});
 end
 // Vary waiting gaps, ignored start pulses, key/data and reset at each algorithm region.
 for(int cut=1;cut<70;cut+=5)begin
  s=rs();k=rk();d=rd();drive({1'b0,1'b0,1'b0,s,k,d});drive({1'b0,1'b0,1'b0,s,k,d});
  drive({1'b1,1'b1,1'b0,s,k,d});repeat(cut)drive({1'b1,1'b0,1'b1,s,k,d});
  drive({1'b0,1'b0,1'b0,s,k,d});drive({1'b0,1'b0,1'b0,s,k,d});
  repeat(3)drive({1'b1,1'b0,1'b0,s,k,d});
 end
 s=rs();k=rk();for(int cyc=0;cyc<600;cyc++)drive({1'b1,1'(cyc%37==0),1'($urandom%3!=0),s,k,rd()});
 repeat(100)drive({1'b1,1'b0,1'b1,s,k,rd()});
endtask
