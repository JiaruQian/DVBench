
  task automatic tick(input integer c,m,input bit valid=1);
    counter=c;maxRound=m;#2;
    if(valid)begin checks++;if(out!==expected)begin errors++;if(errors<5)$display("BAD pre m=%0d c=%0d out=%h exp=%h",m,c,out,expected);end end
    #1;clk=1;#2;
    if(valid)begin checks++;if(out!==expected)begin errors++;if(errors<5)$display("BAD post m=%0d c=%0d out=%h exp=%h",m,c,out,expected);end end
    #1;clk=0;
  endtask
  task automatic exercise;
    integer mode,m,tr,c,j;
    for(mode=0;mode<3;mode++)begin
      m=10+mode*2;
      for(tr=0;tr<12;tr++)begin
        in={$urandom,$urandom,$urandom,$urandom};
        Key={$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom};
        if(tr==0)begin in=0;Key=0;end
        if(tr==1)begin in='1;Key='1;end
        tick(m,m);
        for(c=m+1;c<=2*m;c++)begin
          // Input changes must not replace saved round history.
          in={$urandom,$urandom,$urandom,$urandom};tick(c,m);
        end
        // Hold beyond key-index window, then return without an intervening edge.
        for(j=0;j<3;j++)tick(2*m+1+j,m,0);
        tick(2*m,m);
        // Repeated last round and a live key change.
        tick(2*m-1,m);Key=~Key;tick(m+1,m);
      end
    end
    // Every 6-bit selector, with a known initialized state and a valid key index.
    for(m=0;m<64;m++)begin
      in={$urandom,$urandom,$urandom,$urandom};
      Key={$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom,$urandom};
      tick(14,14);
      if(m==10)j=10;else if(m==12)j=12;else j=14;
      for(c=j;c<=2*j;c++)tick(c,m);
    end
  endtask
