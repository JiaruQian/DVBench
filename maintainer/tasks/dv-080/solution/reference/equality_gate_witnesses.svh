virtual native_if witness_vif;
logic [940:0] witness_pins;
int witness_write_checks=0, witness_read_checks=0;
task witness_tick();
  emit(witness_pins);
  #2;
endtask
task witness_reset();
  witness_pins='0;
  witness_pins[700]=1;
  repeat(3) witness_tick();
  witness_pins[700]=0;
  witness_pins[937+:4]=15;
  witness_pins[933+:4]=15;
  witness_pins[701+:4]=15;
  witness_pins[156+:4]=15;
  witness_pins[160+:4]=15;
  repeat(4) witness_tick();
endtask
task witness_address(input bit reading,input int source_port,input int target_port);
  bit accepted;
  int attempts;
  witness_pins[(reading?432:164)+source_port]=1;
  if(reading)begin
    witness_pins[572+source_port*32+:32]=(32'(target_port)<<24)|32'h1000;
    witness_pins[516+source_port*8+:8]=8'h91+source_port;
    witness_pins[484+source_port*8+:8]=3;
    witness_pins[440+source_port*3+:3]=2;
    witness_pins[564+source_port*2+:2]=1;
  end else begin
    witness_pins[304+source_port*32+:32]=(32'(target_port)<<24)|32'h1000;
    witness_pins[248+source_port*8+:8]=8'ha1+source_port;
    witness_pins[216+source_port*8+:8]=3;
    witness_pins[172+source_port*3+:3]=2;
    witness_pins[296+source_port*2+:2]=1;
  end
  accepted=0;
  for(attempts=0;attempts<20;attempts++)begin
    accepted=reading?witness_vif.expected_s_axi_arready[source_port]:witness_vif.expected_s_axi_awready[source_port];
    witness_tick();
    if(accepted)break;
  end
  if(!accepted)`uvm_fatal("AXI_WITNESS","Reference address handshake absent")
  witness_pins[(reading?432:164)+source_port]=0;
  repeat(3)witness_tick();
endtask
task witness_equal_write(input int source_port,input int target_port,input int first_mask,input int second_mask,input logic[31:0] data_value);
  bit accepted;
  witness_reset();
  witness_address(0,source_port,target_port);
  for(int beat_index=0;beat_index<4;beat_index++)begin
    witness_pins[source_port]=1;
    witness_pins[28+source_port*32+:32]=data_value;
    witness_pins[8+source_port*4+:4]=(beat_index%2)?second_mask:first_mask;
    witness_pins[24+source_port]=(beat_index==3);
    accepted=witness_vif.expected_s_axi_wready[source_port];
    if(!accepted)`uvm_fatal("AXI_WITNESS","Reference write capacity absent")
    witness_tick();
    if(!witness_vif.expected_m_axi_wvalid[target_port] ||
       witness_vif.expected_m_axi_wstrb[target_port*4+:4]!==4'((beat_index%2)?second_mask:first_mask))
      `uvm_error("AXI_WITNESS","Expected equal-data distinct-mask output absent")
    else witness_write_checks++;
  end
  witness_pins[source_port]=0;
  repeat(4)witness_tick();
  witness_pins[885+target_port]=1;
  witness_tick();
  witness_pins[885+target_port]=0;
  repeat(8)witness_tick();
endtask
task witness_same_response_read(input int source_port,input int target_port,input int response_code,input logic[31:0] first_data);
  bit accepted;
  logic[31:0] data_value;
  witness_reset();
  witness_address(1,source_port,target_port);
  for(int beat_index=0;beat_index<4;beat_index++)begin
    data_value=first_data^(32'h10204081*beat_index);
    witness_pins[705+target_port]=1;
    witness_pins[757+target_port*32+:32]=data_value;
    witness_pins[713+target_port*2+:2]=response_code;
    witness_pins[721+target_port]=(beat_index==3);
    accepted=witness_vif.expected_m_axi_rready[target_port];
    if(!accepted)`uvm_fatal("AXI_WITNESS","Reference read capacity absent")
    witness_tick();
    if(!witness_vif.expected_s_axi_rvalid[source_port] ||
       witness_vif.expected_s_axi_rdata[source_port*32+:32]!==data_value)
      `uvm_error("AXI_WITNESS","Expected same-status distinct-data response absent")
    else witness_read_checks++;
  end
  witness_pins[705+target_port]=0;
  repeat(8)witness_tick();
endtask
task equality_gate_witnesses();
  if(!uvm_config_db#(virtual native_if)::get(null,"*","vif",witness_vif))
    `uvm_fatal("AXI_WITNESS","Reference native interface absent")
  for(int source_port=0;source_port<4;source_port++)begin
    for(int target_port=0;target_port<4;target_port++)begin
      for(int first_mask=0;first_mask<16;first_mask++)begin
        witness_equal_write(source_port,target_port,first_mask,first_mask^15,32'ha55a1287^(32'h01010101*first_mask));
      end
      for(int response_code=0;response_code<4;response_code++)begin
        witness_same_response_read(source_port,target_port,response_code,32'h91ab457f^(32'h11111111*response_code));
      end
    end
  end
  if(witness_write_checks!=1024 || witness_read_checks!=256)
    `uvm_error("AXI_WITNESS","Required equality witnesses did not execute")
  `uvm_info("AXI_EQUALITY_WITNESSES",$sformatf("write=%0d read=%0d",witness_write_checks,witness_read_checks),UVM_LOW)
endtask

task rr_prepare_address(input int request_index);
 int source_port;
 source_port=request_index/2;
 if(request_index%2)begin
  witness_pins[432+source_port]=1;
  witness_pins[572+source_port*32+:32]=32'h04001000;
  witness_pins[516+source_port*8+:8]=8'h90+source_port;
  witness_pins[484+source_port*8+:8]=0;
  witness_pins[440+source_port*3+:3]=2;
  witness_pins[564+source_port*2+:2]=1;
 end else begin
  witness_pins[164+source_port]=1;
  witness_pins[304+source_port*32+:32]=32'h04001000;
  witness_pins[248+source_port*8+:8]=8'ha0+source_port;
  witness_pins[216+source_port*8+:8]=0;
  witness_pins[172+source_port*3+:3]=2;
  witness_pins[296+source_port*2+:2]=1;
 end
endtask
task rr_prime(input int request_index);
 bit accepted,completed;
 int source_port;
 source_port=request_index/2;
 accepted=0;completed=0;
 rr_prepare_address(request_index);
 repeat(20)begin
  accepted=request_index%2?witness_vif.expected_s_axi_arready[source_port]:witness_vif.expected_s_axi_awready[source_port];
  witness_tick();
  if(accepted)break;
 end
 if(!accepted)`uvm_fatal("RR_WITNESS","Reference prime address not accepted")
 witness_pins[(request_index%2?432:164)+source_port]=0;
 if(request_index%2==0)begin
  witness_pins[source_port]=1;
  witness_pins[24+source_port]=1;
  witness_pins[8+source_port*4+:4]=15;
  witness_pins[28+source_port*32+:32]=32'h12040801;
  accepted=0;
  repeat(20)begin
   accepted=witness_vif.expected_s_axi_wready[source_port];
   witness_tick();
   if(accepted)break;
  end
  if(!accepted)`uvm_fatal("RR_WITNESS","Reference prime write not accepted")
  witness_pins[source_port]=0;
 end
 repeat(20)begin
  completed=request_index%2?(witness_vif.expected_s_axi_rvalid[source_port] && witness_vif.expected_s_axi_rlast[source_port]):witness_vif.expected_s_axi_bvalid[source_port];
  witness_tick();
  if(completed)break;
 end
 if(!completed)`uvm_fatal("RR_WITNESS","Reference prime response absent")
 repeat(8)witness_tick();
endtask
task idle_priority_witnesses();
 int expected_first,first_seen,completed_cases,differentiating_cases;
 bit[3:0] pending,complete;
 bit[3:0] accepted,retired;
 completed_cases=0;differentiating_cases=0;
 for(int prime_index=0;prime_index<8;prime_index++)begin
  for(int lower_port=0;lower_port<4;lower_port++)begin
   for(int upper_port=lower_port+1;upper_port<4;upper_port++)begin
    witness_reset();
    rr_prime(prime_index);
    expected_first=-1;
    for(int offset=1;offset<=8;offset++)begin
     int request_index;
     request_index=(prime_index+offset)%8;
     if(expected_first<0 && (request_index==2*lower_port+1 || request_index==2*upper_port+1))expected_first=request_index/2;
    end
    pending=(4'b1<<lower_port)|(4'b1<<upper_port);
    complete=0;first_seen=-1;
    rr_prepare_address(2*lower_port+1);
    rr_prepare_address(2*upper_port+1);
    repeat(80)begin
     accepted=witness_vif.expected_s_axi_arready & pending;
     retired=witness_vif.expected_s_axi_rvalid & witness_vif.expected_s_axi_rlast;
     for(int source_port=0;source_port<4;source_port++)begin
      if(accepted[source_port] && first_seen<0)first_seen=source_port;
     end
     witness_tick();
     pending &= ~accepted;
     complete |= retired;
     witness_pins[432+:4]=pending;
     if(complete==((4'b1<<lower_port)|(4'b1<<upper_port)))break;
    end
    if(first_seen!=expected_first || pending!=0 || complete!=((4'b1<<lower_port)|(4'b1<<upper_port)))
     `uvm_error("RR_VACUITY","Independent round-robin prediction or complete legal miss responses absent")
    completed_cases++;
    if(expected_first!=lower_port)differentiating_cases++;
    repeat(8)witness_tick();
   end
  end
 end
 if(completed_cases!=48 || differentiating_cases!=20)`uvm_error("RR_VACUITY","Idle priority sweep incomplete")
 `uvm_info("RR_WITNESSES",$sformatf("cases=%0d distinguishing=%0d",completed_cases,differentiating_cases),UVM_LOW)
endtask
