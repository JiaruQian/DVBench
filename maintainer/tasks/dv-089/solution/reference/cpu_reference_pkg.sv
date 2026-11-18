`timescale 1ns/1ps
package cpu_reference_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class program_store;
 static logic[31:0] words[logic[31:0]];
 static logic[31:0] data[logic[31:0]];
 static int scenario;
 static function logic[31:0] ai(int d,int s,int fn,int imm);return (1<<26)|(d<<22)|(s<<18)|(fn<<15)|(imm&32767);endfunction
 static function logic[31:0] ar(int d,int s,int b,int fn);return (d<<22)|(s<<18)|(b<<14)|(fn<<8);endfunction
 static function logic[31:0] memop(int op,int d,int s,int fn,int imm);return (op<<26)|(d<<22)|(s<<18)|(fn<<15)|(imm&32767);endfunction
 static function logic[31:0] sys(int op);return (10<<26)|(op<<20);endfunction
 static function logic[31:0] csrr(int d,int a);return sys(5)|(d<<16)|(a<<8);endfunction
 static function logic[31:0] csrw(int a,int s);return sys(6)|(a<<8)|s;endfunction
 static function logic[31:0] fetch(logic[31:0] a);return words.exists(a)?words[a]:sys(1);endfunction
 static function void build(int mode);
  int p;scenario=mode;words.delete();data.delete();p=0;
  data[32'h1000]=32'h80ff807f;data[32'h1004]=32'hfedcba98;
  // Every phase starts from a fresh program and synchronous reset.
  case(mode)
   0:begin
    words[p]=ai(1,0,0,4096);p+=4;words[p]=ai(2,0,0,7);p+=4;words[p]=ai(3,0,0,-9);p+=4;
    for(int fn=0;fn<15;fn++)begin
     words[p]=ar(4,3,(fn==2||fn==7)?0:2,fn);p+=4;
     words[p]=memop(4,4,1,4,fn*4);p+=4;
    end
    for(int fn=0;fn<7;fn++)begin
     words[p]=ai(4,3,fn,fn<4?-17:31);p+=4;words[p]=memop(4,4,1,4,128+fn*4);p+=4;
    end
    words[p]=ai(4,2,4,16);p+=4;words[p]=memop(4,4,1,4,180);p+=4;
    words[p]=(2<<26)|(5<<22)|(16'h8123<<6);p+=4;words[p]=memop(4,5,1,4,184);p+=4;
    words[p]=ai(0,0,0,31);p+=4;words[p]=memop(4,0,1,4,188);
   end
   1:begin
    words[p]=ai(1,0,0,4096);p+=4;
    for(int fn=0;fn<5;fn++)begin
     words[p]=memop(3,2,1,fn,(fn<2)?3:0);p+=4;
     words[p]=memop(4,2,1,4,32+fn*4);p+=4;
    end
    words[p]=ai(2,0,0,255);p+=4;
    for(int fn=0;fn<4;fn++)begin words[p]=memop(4,2,1,0,fn);p+=4;end
    words[p]=memop(4,2,1,2,2);p+=4;words[p]=memop(3,3,1,4,0);p+=4;words[p]=memop(4,3,1,4,64);
   end
   2:begin
    words[p]=ai(1,0,0,3);p+=4;words[p]=ai(2,0,0,5);p+=4;
    for(int fn=0;fn<6;fn++)begin
     words[p]=memop(5,2,1,fn,2);p+=4;words[p]=ai(3,3,0,1);p+=4;words[p]=ai(3,3,0,2);p+=4;
     words[p]=memop(5,1,2,fn,2);p+=4;words[p]=ai(3,3,0,4);p+=4;words[p]=ai(3,3,0,8);p+=4;
    end
    words[p]=(7<<26)|(4<<22)|2;p+=4;words[p]=sys(2);p+=4;words[p]=memop(4,4,0,4,4096);
   end
   3:begin
    words[0]=ai(1,0,0,16'h1234);words[4]=csrw(10,1);words[8]=csrr(2,10);words[12]=memop(4,2,0,4,4096);
    for(int a=0;a<=10;a++)begin words[16+a*8]=csrr(3,a);words[20+a*8]=memop(4,3,0,4,4100+a*4);end
   end
   4:begin words[0]=32'hfc000000;end
   5:begin words[0]=ai(1,0,0,4096);words[4]=memop(4,1,1,4,1);end
   6:begin words[0]=ai(1,0,0,4096);words[4]=memop(3,2,1,4,4);words[8]=ai(3,2,0,7);words[12]=memop(4,3,1,4,16);end
   7:begin words[0]=ai(1,0,0,4096);words[4]=memop(3,2,1,4,8);end
   8:begin words[0]=ai(1,0,0,64);words[4]=csrw(4,1);words[8]=sys(7);words[12]=sys(1);words[64]=sys(8);words[68]=sys(4);end
   9:begin words[0]=sys(2);end
   10:begin words[0]=sys(3)|8'h7b;end
   11:begin words[0]=ai(1,0,0,17);words[4]=(8<<26)|(1<<18);end
   12:begin words[0]=csrr(1,11);end
   13:begin words[0]=ai(1,0,0,4096);words[4]=memop(3,2,1,2,1);end
   14:begin words[0]=ai(1,0,0,4096);words[4]=memop(4,1,1,4,8);end
   15:begin
    words[0]=ai(1,0,0,4096);words[4]=ai(2,0,0,-1);p=8;
    for(int amount=0;amount<=31;amount+=15)begin
     words[p]=ai(3,0,0,amount);p+=4;
     for(int operation=8;operation<=10;operation++)begin
      words[p]=ar(4,2,3,operation);p+=4;words[p]=memop(4,4,1,4,p);p+=4;
     end
    end
   end
   16:begin
    words[0]=ai(1,0,0,4100);p=4;
    for(int operation=0;operation<5;operation++)begin
     for(int offset=0;offset<4;offset+=(operation<2?1:2))begin
      if(operation==4&&offset!=0)continue;
      words[p]=memop(3,2,1,operation,offset-4);p+=4;
      words[p]=memop(4,2,1,4,64+p);p+=4;
     end
    end
   end
   17:begin
    words[0]=ai(1,0,0,-1);words[4]=ai(2,0,0,1);p=8;
    for(int operation=0;operation<6;operation++)begin
     words[p]=memop(5,2,1,operation,2);p+=4;words[p]=ai(3,3,0,1);p+=4;
     words[p]=memop(5,1,2,operation,2);p+=4;words[p]=ai(3,3,0,2);p+=4;
    end
    words[p]=memop(4,3,0,4,4096);
   end
   18:begin
    words[0]=ai(1,0,0,24);words[4]=(9<<26)|(2<<22)|(1<<18);
    words[8]=sys(2);words[24]=memop(4,2,0,4,4096);
    words[28]=ai(1,0,0,40);words[32]=(8<<26)|(1<<18);
    words[36]=sys(2);words[40]=(6<<26)|2;words[44]=sys(2);words[48]=sys(1);
   end
   19:begin
    words[0]=ai(1,0,0,3);words[4]=ai(1,1,0,-1);
    words[8]=memop(5,0,1,1,-1);words[12]=memop(4,1,0,4,4096);
   end
   20:begin words[0]=ai(1,0,0,9);words[4]=memop(4,1,0,4,4096);end
   21:begin words[0]=memop(3,1,0,4,1);end
   22:begin words[0]=sys(3)|8'ha5;end
   23:begin
    words[0]=ai(1,0,0,67);words[4]=csrw(4,1);words[8]=ai(1,0,0,35);
    words[12]=csrw(2,1);words[16]=sys(4);words[32]=csrr(2,0);
    words[36]=memop(4,2,0,4,4096);words[40]=sys(1);
   end
   24:begin words[0]=ai(1,0,0,3);words[4]=csrw(0,1);words[8]=sys(8);words[12]=csrr(2,0);words[16]=memop(4,2,0,4,4096);end
   25:begin words[0]=ai(1,0,0,1);words[4]=csrw(1,1);end
   26:begin words[0]=sys(5)|1;end
   27:begin words[0]=ai(1,0,0,4096);words[4]=memop(3,2,1,4,0);words[8]=memop(4,2,1,4,4);end
   35:begin
    words[0]=csrr(2,6);words[4]=memop(4,2,0,4,4096);
   end
   28,29,30,31,32,33,34:begin
    words[0]=ai(1,0,0,128);words[4]=csrw(4,1);
    words[8]=mode==28?sys(8):sys(7);
    words[12]=mode==28||mode==29?sys(1):ai(2,0,0,4096);
    if(mode>=30)begin
     words[16]=memop(3,3,2,4,0);words[20]=ar(4,3,3,0);
     words[24]=memop(4,4,2,4,4);words[28]=(6<<26)|22'h3ffffd;
    end
    words[128]=csrr(5,3);words[132]=memop(4,5,0,4,4200);
    words[136]=csrr(6,2);words[140]=memop(4,6,0,4,4204);
    words[144]=sys(4);
   end
   36,37:begin
    words[p]=ai(1,0,0,8192);p+=4;words[p]=csrw(4,1);p+=4;
    words[8192]=csrr(14,2);words[8196]=ai(14,14,0,4);
    words[8200]=csrw(2,14);words[8204]=sys(4);
    if(mode==36)begin
     for(int high_nibble=1;high_nibble<16;high_nibble++)begin
      for(int low_address=0;low_address<=10;low_address++)begin
       words[p]=csrr(2,(high_nibble<<4)|low_address);p+=4;
      end
      for(int low_address=0;low_address<=10;low_address++)begin
       if(low_address==0||low_address==2||low_address==4||low_address==10)begin
        words[p]=csrw((high_nibble<<4)|low_address,0);p+=4;
       end
      end
     end
    end else begin
     for(int reserved_bit=4;reserved_bit<8;reserved_bit++)begin
      for(int operation=0;operation<15;operation++)begin
       words[p]=ar(2,0,0,operation)|(32'b1<<reserved_bit);p+=4;
      end
     end
    end
    words[p]=sys(1);
   end
   38:begin
    words[0]=ai(1,0,0,8192);words[4]=csrw(4,1);words[8]=sys(7);
    words[12]=sys(0);words[16]=(6<<26)|12;words[20]=sys(0);
    words[64]=sys(1);words[8192]=csrr(2,2);
    words[8196]=memop(4,2,0,4,4208);words[8200]=sys(1);
   end
  endcase
 endfunction
endclass
class cycle_item extends uvm_sequence_item;
 `uvm_object_utils(cycle_item)
 int clocks,mode;
 function new(string name="cycle_item");super.new(name);endfunction
endclass
class all_programs extends uvm_sequence#(cycle_item);
 `uvm_object_utils(all_programs)
 function new(string name="all_programs");super.new(name);endfunction
 task body();
  cycle_item t;
  for(int m=0;m<39;m++)begin t=cycle_item::type_id::create("program");start_item(t);t.mode=m;t.clocks=m==35?70000:(m==36?30000:(m==37?12000:(m==0?1500:650)));finish_item(t);end
 endtask
endclass
class native_driver extends uvm_driver#(cycle_item);
 `uvm_component_utils(native_driver)
 virtual cpu_bus bus;
 int ipend,dpent,ileft,dleft;logic[31:0] iword=0,dword=0;bit ierr,derr;
 function new(string name,uvm_component parent);super.new(name,parent);endfunction
 function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual cpu_bus)::get(this,"","bus",bus))`uvm_fatal("CONFIG","missing bus") endfunction
 task run_phase(uvm_phase phase);
  cycle_item t;int k;logic[31:0] address,value;bit witness_store_seen,stale_fetch_accepted;
  bus.rst_i=1;bus.i_req_ready_i=0;bus.i_rsp_valid_i=0;bus.i_rsp_rdata_i=0;bus.i_rsp_error_i=0;
  bus.d_req_ready_i=0;bus.d_rsp_valid_i=0;bus.d_rsp_rdata_i=0;bus.d_rsp_error_i=0;bus.timer_irq_i=0;bus.external_irq_i=0;
  forever begin
   seq_item_port.get_next_item(t);program_store::build(t.mode);ipend=0;dpent=0;witness_store_seen=0;stale_fetch_accepted=0;
   @(negedge bus.clk_i);bus.rst_i=1;bus.i_rsp_valid_i=0;bus.d_rsp_valid_i=0;bus.timer_irq_i=0;bus.external_irq_i=0;
   repeat(3)@(negedge bus.clk_i);bus.rst_i=0;
   for(k=0;k<t.clocks;k++)begin
    @(posedge bus.clk_i);
    stale_fetch_accepted=0;
    if(bus.i_rsp_valid_i&&bus.i_rsp_ready_o)ipend=0;
    if(bus.d_rsp_valid_i&&bus.d_rsp_ready_o)dpent=0;
    if(bus.i_req_valid_o&&bus.i_req_ready_i)begin
     ipend=1;ileft=(t.mode==35&&bus.i_req_addr_o==0)?65540:((t.mode==38&&bus.i_req_addr_o==20)?24:(t.mode==38?1:$urandom_range(0,5)));
     if(t.mode==38&&bus.i_req_addr_o==20)stale_fetch_accepted=1;iword=program_store::fetch(bus.i_req_addr_o);ierr=((t.mode==4||t.mode==20||t.mode==21||t.mode==22)&&bus.i_req_addr_o==0);
    end
    if(bus.d_req_valid_o&&bus.d_req_ready_i)begin
     dpent=1;dleft=4+$urandom_range(0,5);address={bus.d_req_addr_o[31:2],2'b0};dword=program_store::data.exists(address)?program_store::data[address]:0;
     derr=(t.mode==7||t.mode==14)&&address==4104;
     if(t.mode==38&&bus.d_req_write_o&&address==4208)begin
      witness_store_seen=1;
      `uvm_info("EPOCH_EPC_WITNESS",$sformatf("cycle=%0d epc_store=%h expected=%h",k,bus.d_req_wdata_o,bus.exp_d_req_wdata_o),UVM_LOW)
     end
     if(t.mode==35&&bus.d_req_write_o&&address==4096)begin
      witness_store_seen=1;
      `uvm_info("COUNTER_WITNESS",$sformatf("cycle=%0d store=%h expected=%h",k,bus.d_req_wdata_o,bus.exp_d_req_wdata_o),UVM_LOW)
     end
     if(bus.d_req_write_o&&!derr)begin
      value=dword;for(int n=0;n<4;n++)if(bus.d_req_wstrb_o[n])value[n*8+:8]=bus.d_req_wdata_o[n*8+:8];program_store::data[address]=value;
     end
    end
    @(negedge bus.clk_i);
    bus.i_req_ready_i=t.mode==38?1:($urandom_range(0,3)!=0);bus.d_req_ready_i=$urandom_range(0,2)!=0;
    if(ipend&&ileft>0)ileft--;bus.i_rsp_valid_i=ipend&&ileft==0;bus.i_rsp_rdata_i=iword;bus.i_rsp_error_i=ierr;
    if(dpent&&dleft>0)dleft--;bus.d_rsp_valid_i=dpent&&dleft==0;bus.d_rsp_rdata_i=dword;bus.d_rsp_error_i=derr;
    bus.timer_irq_i=(t.mode==38&&stale_fetch_accepted)||(t.mode==8&&k>=80&&k<90)||((t.mode==28||t.mode==29||t.mode==30||t.mode==32||t.mode==34)&&k>=120&&k<150);
    bus.external_irq_i=(t.mode==8&&k>=85&&k<95)||((t.mode==31||t.mode==32||t.mode==33||t.mode==34)&&k>=120&&k<150);
    if(k==300)begin #1;bus.rst_i=1;#1;bus.rst_i=0;end
   end
   if(t.mode==38&&!witness_store_seen)`uvm_error("EPOCH_EPC_WITNESS","interrupt EPC handler did not reach its public store")
   if(t.mode==35&&!witness_store_seen)`uvm_error("COUNTER_WITNESS","long-latency CSR read did not reach a public store")
   `uvm_info("HISTORY",$sformatf("completed program=%0d clocks=%0d",t.mode,t.clocks),UVM_LOW)
   seq_item_port.item_done();
  end
 endtask
endclass
class port_sample extends uvm_sequence_item;
 `uvm_object_utils(port_sample)
 logic [31:0] actual[17],expected[17];
 function new(string n="port_sample");super.new(n);endfunction
endclass
class native_monitor extends uvm_monitor;
 `uvm_component_utils(native_monitor)
 virtual cpu_bus bus;uvm_analysis_port#(port_sample) ap;
 covergroup observed with function sample(int opcode,int cause,bit halted,bit request,bit store,int lanes);
  cp_op:coverpoint opcode {bins opcodes[]={[0:10]};}
  cp_cause:coverpoint cause {bins causes[]={1,2,3,4,5,6,7,8,9,16,17};}
  cp_halt:coverpoint halted;cp_req:coverpoint request;cp_store:coverpoint store;cp_lanes:coverpoint lanes;
 endgroup
 function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);observed=new;endfunction
 function void build_phase(uvm_phase p);if(!uvm_config_db#(virtual cpu_bus)::get(this,"","bus",bus))`uvm_fatal("CONFIG","monitor missing bus") endfunction
 task run_phase(uvm_phase p);port_sample s;forever begin @(posedge bus.clk_i);#1;s=port_sample::type_id::create("pins");
 s.actual[0]=bus.i_req_valid_o;s.expected[0]=bus.exp_i_req_valid_o;
 s.actual[1]=bus.i_req_addr_o;s.expected[1]=bus.exp_i_req_addr_o;
 s.actual[2]=bus.i_rsp_ready_o;s.expected[2]=bus.exp_i_rsp_ready_o;
 s.actual[3]=bus.d_req_valid_o;s.expected[3]=bus.exp_d_req_valid_o;
 s.actual[4]=bus.d_req_addr_o;s.expected[4]=bus.exp_d_req_addr_o;
 s.actual[5]=bus.d_req_write_o;s.expected[5]=bus.exp_d_req_write_o;
 s.actual[6]=bus.d_req_wdata_o;s.expected[6]=bus.exp_d_req_wdata_o;
 s.actual[7]=bus.d_req_wstrb_o;s.expected[7]=bus.exp_d_req_wstrb_o;
 s.actual[8]=bus.d_rsp_ready_o;s.expected[8]=bus.exp_d_rsp_ready_o;
 s.actual[9]=bus.halted_o;s.expected[9]=bus.exp_halted_o;
 s.actual[10]=bus.trap_o;s.expected[10]=bus.exp_trap_o;
 s.actual[11]=bus.trap_cause_o;s.expected[11]=bus.exp_trap_cause_o;
 s.actual[12]=bus.trap_badaddr_o;s.expected[12]=bus.exp_trap_badaddr_o;
 s.actual[13]=bus.retire_valid_o;s.expected[13]=bus.exp_retire_valid_o;
 s.actual[14]=bus.retire_pc_o;s.expected[14]=bus.exp_retire_pc_o;
 s.actual[15]=bus.retire_instruction_o;s.expected[15]=bus.exp_retire_instruction_o;
 observed.sample(bus.retire_valid_o?bus.retire_instruction_o[31:26]:-1,bus.trap_o?bus.trap_cause_o:-1,bus.halted_o,bus.d_req_valid_o,bus.d_req_write_o,bus.d_req_wstrb_o);ap.write(s);end endtask
endclass
class native_scoreboard extends uvm_scoreboard;
 `uvm_component_utils(native_scoreboard)
 uvm_analysis_imp#(port_sample,native_scoreboard) imp;
 int compared=0,mismatches=0,retirements=0,requests=0,traps=0;
 function new(string n,uvm_component p);super.new(n,p);imp=new("imp",this);endfunction
 function void write(port_sample s);
 bit mismatch;mismatch=0;compared++;
 if((1) && s.actual[0]!==s.expected[0])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("i_req_valid_o cycle=%0d actual=%h expected=%h",compared,s.actual[0],s.expected[0])) end
 if((1) && s.actual[1]!==s.expected[1])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("i_req_addr_o cycle=%0d actual=%h expected=%h",compared,s.actual[1],s.expected[1])) end
 if((1) && s.actual[2]!==s.expected[2])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("i_rsp_ready_o cycle=%0d actual=%h expected=%h",compared,s.actual[2],s.expected[2])) end
 if((1) && s.actual[3]!==s.expected[3])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("d_req_valid_o cycle=%0d actual=%h expected=%h",compared,s.actual[3],s.expected[3])) end
 if((s.expected[3]) && s.actual[4]!==s.expected[4])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("d_req_addr_o cycle=%0d actual=%h expected=%h",compared,s.actual[4],s.expected[4])) end
 if((s.expected[3]) && s.actual[5]!==s.expected[5])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("d_req_write_o cycle=%0d actual=%h expected=%h",compared,s.actual[5],s.expected[5])) end
 if((s.expected[3]) && s.actual[6]!==s.expected[6])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("d_req_wdata_o cycle=%0d actual=%h expected=%h",compared,s.actual[6],s.expected[6])) end
 if((s.expected[3]) && s.actual[7]!==s.expected[7])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("d_req_wstrb_o cycle=%0d actual=%h expected=%h",compared,s.actual[7],s.expected[7])) end
 if((1) && s.actual[8]!==s.expected[8])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("d_rsp_ready_o cycle=%0d actual=%h expected=%h",compared,s.actual[8],s.expected[8])) end
 if((1) && s.actual[9]!==s.expected[9])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("halted_o cycle=%0d actual=%h expected=%h",compared,s.actual[9],s.expected[9])) end
 if((1) && s.actual[10]!==s.expected[10])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("trap_o cycle=%0d actual=%h expected=%h",compared,s.actual[10],s.expected[10])) end
 if((s.expected[10]) && s.actual[11]!==s.expected[11])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("trap_cause_o cycle=%0d actual=%h expected=%h",compared,s.actual[11],s.expected[11])) end
 if((s.expected[10]) && s.actual[12]!==s.expected[12])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("trap_badaddr_o cycle=%0d actual=%h expected=%h",compared,s.actual[12],s.expected[12])) end
 if((1) && s.actual[13]!==s.expected[13])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("retire_valid_o cycle=%0d actual=%h expected=%h",compared,s.actual[13],s.expected[13])) end
 if((s.expected[13]) && s.actual[14]!==s.expected[14])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("retire_pc_o cycle=%0d actual=%h expected=%h",compared,s.actual[14],s.expected[14])) end
 if((s.expected[13]) && s.actual[15]!==s.expected[15])begin mismatch=1;if(mismatches<15)`uvm_error("PORT",$sformatf("retire_instruction_o cycle=%0d actual=%h expected=%h",compared,s.actual[15],s.expected[15])) end
 if(s.actual[13])retirements++;if(s.actual[3])requests++;if(s.actual[10])traps++;if(mismatch)mismatches++;
endfunction
 function void check_phase(uvm_phase p);if(compared<10000||retirements<50||requests<20||traps<5)`uvm_error("VACUOUS","required native activity missing") endfunction
 function void report_phase(uvm_phase p);$display("REFERENCE_PORT_COUNTS compared=%0d mismatches=%0d retire=%0d data=%0d traps=%0d",compared,mismatches,retirements,requests,traps);endfunction
endclass
class native_agent extends uvm_agent;
 `uvm_component_utils(native_agent)
 native_driver driver;uvm_sequencer#(cycle_item) sequencer;native_monitor monitor;native_scoreboard scoreboard;
 function new(string name,uvm_component parent);super.new(name,parent);endfunction
 function void build_phase(uvm_phase phase);driver=native_driver::type_id::create("driver",this);sequencer=new("sequencer",this);monitor=native_monitor::type_id::create("monitor",this);scoreboard=native_scoreboard::type_id::create("scoreboard",this);endfunction
 function void connect_phase(uvm_phase phase);driver.seq_item_port.connect(sequencer.seq_item_export);monitor.ap.connect(scoreboard.imp);endfunction
endclass
class native_env extends uvm_env;
 `uvm_component_utils(native_env)
 native_agent agent;
 function new(string name,uvm_component parent);super.new(name,parent);endfunction
 function void build_phase(uvm_phase phase);agent=native_agent::type_id::create("agent",this);endfunction
endclass
class dvbench_test extends uvm_test;
 `uvm_component_utils(dvbench_test)
 native_env env;
 function new(string name,uvm_component parent);super.new(name,parent);endfunction
 function void build_phase(uvm_phase phase);env=native_env::type_id::create("env",this);endfunction
 task run_phase(uvm_phase phase);all_programs sequence_all;phase.raise_objection(this);sequence_all=all_programs::type_id::create("sequence_all");sequence_all.start(env.agent.sequencer);phase.drop_objection(this);endtask
 function void report_phase(uvm_phase phase);uvm_report_server rs;rs=uvm_report_server::get_server();if(rs.get_severity_count(UVM_ERROR)==0&&rs.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");endfunction
endclass
endpackage
