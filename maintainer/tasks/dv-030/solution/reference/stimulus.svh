
apply('0,1);
drive[5]=0;apply(drive,3);drive[5]=1;apply(drive,2);
for(integer digit=0;digit<16;digit=digit+1) begin
  drive[4]=1;drive[3:0]=digit;apply(drive,$urandom_range(2,5));
  drive[4]=0;apply(drive,$urandom_range(2,5));
end
drive[4]=0;apply(drive,4100000);
if($test$plusargs("qualification_history")) begin
  string scenario;
  if(!$value$plusargs("witness=%s",scenario)) $fatal(1,"witness selector required");
  drive[5]=0;apply(drive,3);drive[5]=1;apply(drive,2);
  if(scenario=="password" || scenario=="change") begin
    drive[4]=1;drive[3:0]=1;slow_tick(drive);slow_tick(drive);
    drive[3:0]=2;slow_tick(drive);slow_tick(drive);
    drive[4]=0;slow_tick(drive);
    if(scenario=="change") begin
      drive[4]=1;drive[3:0]=10;slow_tick(drive);
      drive[3:0]=1;slow_tick(drive);slow_tick(drive);
      drive[3:0]=2;slow_tick(drive);slow_tick(drive);
      drive[4]=0;slow_tick(drive);
      drive[4]=1;drive[3:0]=3;slow_tick(drive);
      drive[3:0]=4;slow_tick(drive);
      drive[3:0]=7;slow_tick(drive);
      drive[3:0]=8;slow_tick(drive);
      drive[3:0]=3;slow_tick(drive);
      drive[3:0]=4;slow_tick(drive);
      drive[3:0]=7;slow_tick(drive);
      drive[3:0]=8;slow_tick(drive);
      drive[4]=0;slow_tick(drive);
    end
  end else if(scenario=="wrong" || scenario=="blocked_entry") begin
    repeat(scenario=="wrong" ? 1 : 3) begin
      drive[4]=1;drive[3:0]=0;repeat(4)slow_tick(drive);
      drive[4]=0;repeat(5)slow_tick(drive);
    end
    drive[4]=1;drive[3:0]=1;repeat(2)slow_tick(drive);
  end else $fatal(1,"unknown witness selector");
  drive[4]=0;apply(drive,200010);
end
if($test$plusargs("long_history")) begin
  drive[4]=1;drive[3:0]=1;slow_tick(drive);slow_tick(drive);
  drive[3:0]=2;slow_tick(drive);slow_tick(drive);
  drive[4]=0;repeat(12)slow_tick(drive);
  drive[4]=1;drive[3:0]=1;slow_tick(drive);slow_tick(drive);
  drive[3:0]=2;slow_tick(drive);slow_tick(drive);
  drive[4]=0;slow_tick(drive);
  drive[4]=1;drive[3:0]=10;slow_tick(drive);
  drive[3:0]=1;slow_tick(drive);slow_tick(drive);
  drive[3:0]=2;slow_tick(drive);slow_tick(drive);
  drive[4]=0;slow_tick(drive);
  drive[4]=1;drive[3:0]=3;slow_tick(drive);
  drive[3:0]=4;slow_tick(drive);
  drive[3:0]=7;slow_tick(drive);
  drive[3:0]=8;slow_tick(drive);
  drive[3:0]=3;slow_tick(drive);
  drive[3:0]=4;slow_tick(drive);
  drive[3:0]=7;slow_tick(drive);
  drive[3:0]=8;slow_tick(drive);
  drive[4]=0;slow_tick(drive);
  drive[5]=0;apply(drive,3);drive[5]=1;apply(drive,2);
  repeat(3)begin
    drive[4]=1;drive[3:0]=0;repeat(4)slow_tick(drive);
    drive[4]=0;repeat(5)slow_tick(drive);
  end
  drive[4]=1;drive[3:0]=1;repeat(102)slow_tick(drive);
  drive[5]=0;apply(drive,3);drive[5]=1;apply(drive,2);
end
drive[5]=0;apply(drive,3);drive[5]=1;apply(drive,2);
