`timescale 1ns/1ps
module hpa_qualification;
  reg clock=0;
  always #5 clock=~clock;
  integer checks=0, failures=0, seed=1, beat_count=0;
  integer control_value;
  reg [31:0] random_state;
  reg initialized=0;
  function automatic [31:0] next_random();
    random_state=random_state^(random_state<<13);
    random_state=random_state^(random_state>>17);
    random_state=random_state^(random_state<<5);
    next_random=random_state;
  endfunction
  logic reset;
  logic io_in_1_valid;
  logic [2:0] io_in_1_bits_opcode;
  logic [2:0] io_in_1_bits_param;
  logic [7:0] io_in_1_bits_size;
  logic [7:0] io_in_1_bits_source;
  logic [63:0] io_in_1_bits_data;
  logic io_in_1_bits_corrupt;
  logic [8:0] io_in_1_bits_union;
  logic io_in_1_bits_last;
  logic io_in_4_valid;
  logic [2:0] io_in_4_bits_opcode;
  logic [2:0] io_in_4_bits_param;
  logic [7:0] io_in_4_bits_size;
  logic [7:0] io_in_4_bits_source;
  logic [63:0] io_in_4_bits_address;
  logic [63:0] io_in_4_bits_data;
  logic io_in_4_bits_corrupt;
  logic [8:0] io_in_4_bits_union;
  logic io_in_4_bits_last;
  logic io_out_ready;
  logic io_in_1_ready;
  logic io_in_4_ready;
  logic io_out_valid;
  logic [2:0] io_out_bits_chanId;
  logic [2:0] io_out_bits_opcode;
  logic [2:0] io_out_bits_param;
  logic [7:0] io_out_bits_size;
  logic [7:0] io_out_bits_source;
  logic [63:0] io_out_bits_address;
  logic [63:0] io_out_bits_data;
  logic io_out_bits_corrupt;
  logic [8:0] io_out_bits_union;
  logic io_out_bits_last;
  logic expected_io_in_1_ready;
  logic expected_io_in_4_ready;
  logic expected_io_out_valid;
  logic [2:0] expected_io_out_bits_chanId;
  logic [2:0] expected_io_out_bits_opcode;
  logic [2:0] expected_io_out_bits_param;
  logic [7:0] expected_io_out_bits_size;
  logic [7:0] expected_io_out_bits_source;
  logic [63:0] expected_io_out_bits_address;
  logic [63:0] expected_io_out_bits_data;
  logic expected_io_out_bits_corrupt;
  logic [8:0] expected_io_out_bits_union;
  logic expected_io_out_bits_last;
  HellaPeekingArbiter dut (
    .clock(clock),
    .reset(reset),
    .io_in_1_ready(io_in_1_ready),
    .io_in_1_valid(io_in_1_valid),
    .io_in_1_bits_opcode(io_in_1_bits_opcode),
    .io_in_1_bits_param(io_in_1_bits_param),
    .io_in_1_bits_size(io_in_1_bits_size),
    .io_in_1_bits_source(io_in_1_bits_source),
    .io_in_1_bits_data(io_in_1_bits_data),
    .io_in_1_bits_corrupt(io_in_1_bits_corrupt),
    .io_in_1_bits_union(io_in_1_bits_union),
    .io_in_1_bits_last(io_in_1_bits_last),
    .io_in_4_ready(io_in_4_ready),
    .io_in_4_valid(io_in_4_valid),
    .io_in_4_bits_opcode(io_in_4_bits_opcode),
    .io_in_4_bits_param(io_in_4_bits_param),
    .io_in_4_bits_size(io_in_4_bits_size),
    .io_in_4_bits_source(io_in_4_bits_source),
    .io_in_4_bits_address(io_in_4_bits_address),
    .io_in_4_bits_data(io_in_4_bits_data),
    .io_in_4_bits_corrupt(io_in_4_bits_corrupt),
    .io_in_4_bits_union(io_in_4_bits_union),
    .io_in_4_bits_last(io_in_4_bits_last),
    .io_out_ready(io_out_ready),
    .io_out_valid(io_out_valid),
    .io_out_bits_chanId(io_out_bits_chanId),
    .io_out_bits_opcode(io_out_bits_opcode),
    .io_out_bits_param(io_out_bits_param),
    .io_out_bits_size(io_out_bits_size),
    .io_out_bits_source(io_out_bits_source),
    .io_out_bits_address(io_out_bits_address),
    .io_out_bits_data(io_out_bits_data),
    .io_out_bits_corrupt(io_out_bits_corrupt),
    .io_out_bits_union(io_out_bits_union),
    .io_out_bits_last(io_out_bits_last)
  );
  dvbench_model model (
    .clock(clock),
    .reset(reset),
    .io_in_1_ready(expected_io_in_1_ready),
    .io_in_1_valid(io_in_1_valid),
    .io_in_1_bits_opcode(io_in_1_bits_opcode),
    .io_in_1_bits_param(io_in_1_bits_param),
    .io_in_1_bits_size(io_in_1_bits_size),
    .io_in_1_bits_source(io_in_1_bits_source),
    .io_in_1_bits_data(io_in_1_bits_data),
    .io_in_1_bits_corrupt(io_in_1_bits_corrupt),
    .io_in_1_bits_union(io_in_1_bits_union),
    .io_in_1_bits_last(io_in_1_bits_last),
    .io_in_4_ready(expected_io_in_4_ready),
    .io_in_4_valid(io_in_4_valid),
    .io_in_4_bits_opcode(io_in_4_bits_opcode),
    .io_in_4_bits_param(io_in_4_bits_param),
    .io_in_4_bits_size(io_in_4_bits_size),
    .io_in_4_bits_source(io_in_4_bits_source),
    .io_in_4_bits_address(io_in_4_bits_address),
    .io_in_4_bits_data(io_in_4_bits_data),
    .io_in_4_bits_corrupt(io_in_4_bits_corrupt),
    .io_in_4_bits_union(io_in_4_bits_union),
    .io_in_4_bits_last(io_in_4_bits_last),
    .io_out_ready(io_out_ready),
    .io_out_valid(expected_io_out_valid),
    .io_out_bits_chanId(expected_io_out_bits_chanId),
    .io_out_bits_opcode(expected_io_out_bits_opcode),
    .io_out_bits_param(expected_io_out_bits_param),
    .io_out_bits_size(expected_io_out_bits_size),
    .io_out_bits_source(expected_io_out_bits_source),
    .io_out_bits_address(expected_io_out_bits_address),
    .io_out_bits_data(expected_io_out_bits_data),
    .io_out_bits_corrupt(expected_io_out_bits_corrupt),
    .io_out_bits_union(expected_io_out_bits_union),
    .io_out_bits_last(expected_io_out_bits_last)
  );
  task compare_outputs;
    begin
      if(initialized) begin
        checks=checks+1;
        if(io_in_1_ready !== expected_io_in_1_ready) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_in_1_ready actual=%h expected=%h time=%0t",io_in_1_ready,expected_io_in_1_ready,$time);
        end
        if(io_in_4_ready !== expected_io_in_4_ready) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_in_4_ready actual=%h expected=%h time=%0t",io_in_4_ready,expected_io_in_4_ready,$time);
        end
        if(io_out_valid !== expected_io_out_valid) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_valid actual=%h expected=%h time=%0t",io_out_valid,expected_io_out_valid,$time);
        end
        if(io_out_bits_chanId !== expected_io_out_bits_chanId) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_chanId actual=%h expected=%h time=%0t",io_out_bits_chanId,expected_io_out_bits_chanId,$time);
        end
        if(io_out_bits_opcode !== expected_io_out_bits_opcode) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_opcode actual=%h expected=%h time=%0t",io_out_bits_opcode,expected_io_out_bits_opcode,$time);
        end
        if(io_out_bits_param !== expected_io_out_bits_param) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_param actual=%h expected=%h time=%0t",io_out_bits_param,expected_io_out_bits_param,$time);
        end
        if(io_out_bits_size !== expected_io_out_bits_size) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_size actual=%h expected=%h time=%0t",io_out_bits_size,expected_io_out_bits_size,$time);
        end
        if(io_out_bits_source !== expected_io_out_bits_source) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_source actual=%h expected=%h time=%0t",io_out_bits_source,expected_io_out_bits_source,$time);
        end
        if(io_out_bits_address !== expected_io_out_bits_address) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_address actual=%h expected=%h time=%0t",io_out_bits_address,expected_io_out_bits_address,$time);
        end
        if(io_out_bits_data !== expected_io_out_bits_data) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_data actual=%h expected=%h time=%0t",io_out_bits_data,expected_io_out_bits_data,$time);
        end
        if(io_out_bits_corrupt !== expected_io_out_bits_corrupt) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_corrupt actual=%h expected=%h time=%0t",io_out_bits_corrupt,expected_io_out_bits_corrupt,$time);
        end
        if(io_out_bits_union !== expected_io_out_bits_union) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_union actual=%h expected=%h time=%0t",io_out_bits_union,expected_io_out_bits_union,$time);
        end
        if(io_out_bits_last !== expected_io_out_bits_last) begin
          failures=failures+1;
          if(failures<=12) $display("MISMATCH io_out_bits_last actual=%h expected=%h time=%0t",io_out_bits_last,expected_io_out_bits_last,$time);
        end
      end
    end
  endtask
  task beat(input integer controls,input integer reset_value,input integer pulse);
    begin
      @(negedge clock);
      io_in_1_valid=next_random();
      io_in_1_bits_opcode=next_random();
      if(beat_count%3==0) io_in_1_bits_opcode='0; else if(beat_count%3==1) io_in_1_bits_opcode='1;
      io_in_1_bits_param=next_random();
      if(beat_count%3==0) io_in_1_bits_param='0; else if(beat_count%3==1) io_in_1_bits_param='1;
      io_in_1_bits_size=next_random();
      if(beat_count%3==0) io_in_1_bits_size='0; else if(beat_count%3==1) io_in_1_bits_size='1;
      io_in_1_bits_source=next_random();
      if(beat_count%3==0) io_in_1_bits_source='0; else if(beat_count%3==1) io_in_1_bits_source='1;
      io_in_1_bits_data={next_random(),next_random()};
      if(beat_count%3==0) io_in_1_bits_data='0; else if(beat_count%3==1) io_in_1_bits_data='1;
      io_in_1_bits_corrupt=next_random();
      if(beat_count%3==0) io_in_1_bits_corrupt='0; else if(beat_count%3==1) io_in_1_bits_corrupt='1;
      io_in_1_bits_union=next_random();
      if(beat_count%3==0) io_in_1_bits_union='0; else if(beat_count%3==1) io_in_1_bits_union='1;
      io_in_1_bits_last=next_random();
      io_in_4_valid=next_random();
      io_in_4_bits_opcode=next_random();
      if(beat_count%3==0) io_in_4_bits_opcode='0; else if(beat_count%3==1) io_in_4_bits_opcode='1;
      io_in_4_bits_param=next_random();
      if(beat_count%3==0) io_in_4_bits_param='0; else if(beat_count%3==1) io_in_4_bits_param='1;
      io_in_4_bits_size=next_random();
      if(beat_count%3==0) io_in_4_bits_size='0; else if(beat_count%3==1) io_in_4_bits_size='1;
      io_in_4_bits_source=next_random();
      if(beat_count%3==0) io_in_4_bits_source='0; else if(beat_count%3==1) io_in_4_bits_source='1;
      io_in_4_bits_address={next_random(),next_random()};
      if(beat_count%3==0) io_in_4_bits_address='0; else if(beat_count%3==1) io_in_4_bits_address='1;
      io_in_4_bits_data={next_random(),next_random()};
      if(beat_count%3==0) io_in_4_bits_data='0; else if(beat_count%3==1) io_in_4_bits_data='1;
      io_in_4_bits_corrupt=next_random();
      if(beat_count%3==0) io_in_4_bits_corrupt='0; else if(beat_count%3==1) io_in_4_bits_corrupt='1;
      io_in_4_bits_union=next_random();
      if(beat_count%3==0) io_in_4_bits_union='0; else if(beat_count%3==1) io_in_4_bits_union='1;
      io_in_4_bits_last=next_random();
      io_out_ready=next_random();
      beat_count=beat_count+1;
      reset=reset_value;
      io_in_1_valid=controls[0]; io_in_4_valid=controls[1]; io_out_ready=controls[2];
      io_in_1_bits_last=controls[3]; io_in_4_bits_last=controls[4];
      if(pulse) begin #1 reset=1; #1 compare_outputs(); #1 reset=0; end
      else begin #2 compare_outputs(); end
      @(posedge clock);
      #2;
      if(reset) initialized=1;
      compare_outputs();
    end
  endtask
  initial begin
    if($value$plusargs("SEED=%d",seed)) begin end
    random_state=seed;
    reset=0;
    io_in_1_valid=0;
    io_in_1_bits_opcode=0;
    io_in_1_bits_param=0;
    io_in_1_bits_size=0;
    io_in_1_bits_source=0;
    io_in_1_bits_data=0;
    io_in_1_bits_corrupt=0;
    io_in_1_bits_union=0;
    io_in_1_bits_last=0;
    io_in_4_valid=0;
    io_in_4_bits_opcode=0;
    io_in_4_bits_param=0;
    io_in_4_bits_size=0;
    io_in_4_bits_source=0;
    io_in_4_bits_address=0;
    io_in_4_bits_data=0;
    io_in_4_bits_corrupt=0;
    io_in_4_bits_union=0;
    io_in_4_bits_last=0;
    io_out_ready=0;
    reset=1;
    repeat(2) @(posedge clock);
    #2; initialized=1;
    for(integer owner=0;owner<3;owner=owner+1) begin
      for(integer controls=0;controls<32;controls=controls+1) begin
        beat(0,1,0);
        if(owner==1) beat(5,0,0);
        if(owner==2) beat(6,0,0);
        beat(controls,0,0); beat(31,0,0);
      end
    end
    beat(0,1,0); beat(6,0,0); beat(7,0,1); beat(31,0,0);
    beat(0,1,0); beat(5,0,0); beat(7,0,1); beat(31,0,0);
    for(integer index=0;index<1000;index=index+1) begin
      control_value=next_random()%32;
      beat(control_value,next_random()%40==0,0);
    end
    beat(0,1,0); beat(24,0,0);
    $display("QUALIFICATION_COMPLETED checks=%0d failures=%0d seed=%0d",checks,failures,seed);
    $finish;
  end
endmodule
