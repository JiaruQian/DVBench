task tick(input integer c,m,input bit valid=1);
vif.counter=c;vif.maxRound=m;vif.valid=valid;#2;vif.phase_id=0;->vif.sampled;
#1;vif.clk=1;#2;vif.phase_id=1;->vif.sampled;#1;vif.clk=0;
endtask
  task automatic exercise;
    integer mode,m,tr,c,j;
    for(mode=0;mode<3;mode++)begin
      m=10+mode*2;
      for(tr=0;tr<12;tr++)begin
        vif.in={$urandom,$urandom,$urandom,$urandom};
        vif.Key={$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom};
        if(tr==0)begin vif.in=0;vif.Key=0;end
        if(tr==1)begin vif.in='1;vif.Key='1;end
        tick(m,m);
        for(c=m+1;c<=2*m;c++)begin
          // Input changes must not replace saved round history.
          vif.in={$urandom,$urandom,$urandom,$urandom};tick(c,m);
        end
        // Hold beyond key-index window, then return without an intervening edge.
        for(j=0;j<3;j++)tick(2*m+1+j,m,0);
        tick(2*m,m);
        // Repeated last round and a live key change.
        tick(2*m-1,m);vif.Key=~vif.Key;tick(m+1,m);
      end
    end
    // Every 6-bit selector, with a known initialized state and a valid key index.
    for(m=0;m<64;m++)begin
      vif.in={$urandom,$urandom,$urandom,$urandom};
      vif.Key={$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom};
      tick(14,14);
      if(m==10)j=10;else if(m==12)j=12;else j=14;
      for(c=j;c<=2*j;c++)tick(c,m);
    end
    // Ignored low-key bits: hold state at vif.counter=2m and perturb only ignored bits.
    for(mode=0;mode<2;mode++)begin
      m=10+2*mode;tick(m,m);tick(2*m,m);
      if(m==10)vif.Key[127:0]=~vif.Key[127:0];else vif.Key[63:0]=~vif.Key[63:0];
      tick(2*m,m);
    end
  endtask
