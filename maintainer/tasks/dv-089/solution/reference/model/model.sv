// Independent transaction-scheduled ISA interpreter. No DUT, package or output input.
module dvbench_model (
 input logic clk_i,rst_i,
 output wire i_req_valid_o,input logic i_req_ready_i,output wire[31:0] i_req_addr_o,
 input logic i_rsp_valid_i,output wire i_rsp_ready_o,input logic[31:0] i_rsp_rdata_i,input logic i_rsp_error_i,
 output wire d_req_valid_o,input logic d_req_ready_i,output wire[31:0] d_req_addr_o,
 output wire d_req_write_o,output wire[31:0] d_req_wdata_o,output wire[3:0] d_req_wstrb_o,
 input logic d_rsp_valid_i,output wire d_rsp_ready_o,input logic[31:0] d_rsp_rdata_i,input logic d_rsp_error_i,
 input logic timer_irq_i,external_irq_i,
 output logic halted_o,trap_o,output logic[7:0] trap_cause_o,output logic[31:0] trap_badaddr_o,
 output logic retire_valid_o,output logic[31:0] retire_pc_o,retire_instruction_o
);
 typedef struct packed {
  logic valid,fetch_error;logic[31:0] pc,ins;
 } token_t;
 typedef struct packed {
  logic valid,write_reg,memory,store,sent,fault,halt,system,redirect;
  logic[3:0] rd,sysop;logic[2:0] sub;
  logic[7:0] csr,cause;
  logic[31:0] pc,ins,result,address,data,bad,epc,csrdata,target;
  logic[3:0] lanes;
 } effect_t;
 logic[31:0] regs[0:15];
 logic[31:0] csr_epc,csr_cause,csr_vector,csr_bad,csr_scratch;
 logic[1:0] status;
 logic[63:0] cycles,retired;
 logic waiting,epoch,request_epoch;
 logic[31:0] fetch_next,request_pc,resume_pc;
 token_t inbox,execute;
 effect_t commit;
 assign i_req_valid_o=!waiting&&!inbox.valid&&!halted_o;
 assign i_req_addr_o=fetch_next;
 assign i_rsp_ready_o=waiting;
 assign d_req_valid_o=commit.valid&&commit.memory&&!commit.sent;
 assign d_rsp_ready_o=commit.valid&&commit.memory&&commit.sent;
 assign d_req_addr_o=commit.address;
 assign d_req_write_o=commit.store;
 assign d_req_wdata_o=commit.data;
 assign d_req_wstrb_o=commit.lanes;
 function automatic logic[31:0] csr_read(input logic[7:0] a);
  case(a)
   0:return {30'b0,status};1:return {30'b0,external_irq_i,timer_irq_i};
   2:return csr_epc;3:return csr_cause;4:return csr_vector;5:return csr_bad;
   6:return cycles[31:0];7:return cycles[63:32];8:return retired[31:0];9:return retired[63:32];
   10:return csr_scratch;default:return 0;
  endcase
 endfunction
 function automatic logic[31:0] load_result(input effect_t e);
  logic[31:0] v;integer n;
  n=e.address[1:0]*8; v=d_rsp_rdata_i>>n;
  case(e.sub)
   0:return {{24{v[7]}},v[7:0]};1:return {24'b0,v[7:0]};
   2:return {{16{v[15]}},v[15:0]};3:return {16'b0,v[15:0]};default:return d_rsp_rdata_i;
  endcase
 endfunction
 // Interpret one instruction into architectural effects rather than gate-level datapaths.
 function automatic effect_t interpret(input token_t t);
  effect_t e;logic[31:0] a,b,imm,res;logic legal,taken;integer op,fn,sub,rd,r1,r2,sys;
  e='0;e.valid=t.valid;e.pc=t.pc;e.ins=t.ins;
  op=t.ins[31:26];fn=t.ins[13:8];sub=t.ins[17:15];rd=t.ins[25:22];r1=t.ins[21:18];r2=t.ins[17:14];sys=t.ins[25:20];
  if(op==4 || op==5)r2=rd;
  if(op==10)begin rd=t.ins[19:16];if(sys==6)r1=t.ins[3:0];end
  a=regs[r1];b=regs[r2];imm={{17{t.ins[14]}},t.ins[14:0]};res=a+b;
  legal=0;taken=0;e.rd=rd;e.sub=sub;e.csr=t.ins[15:8];e.sysop=sys;
  case(op)
   0:begin
    legal=t.ins[7:0]==0&&fn<15&&(!(fn==2||fn==7)||r2==0);e.write_reg=1;
    case(fn)
     0:res=a+b;1:res=a-b;2:res=-a;3:res=a*b;4:res=a&b;5:res=a|b;6:res=a^b;7:res=~a;
     8:res=a<<b[4:0];9:res=a>>b[4:0];10:res=$signed(a)>>>b[4:0];11:res=$signed(a)<$signed(b);
     12:res=a<b;13:res=a==b;14:res=a!=b;default:res=a+b;
    endcase
   end
   1:begin
    legal=sub<=6&&(sub<4||t.ins[14:5]==0);e.write_reg=1;
    case(sub)
     0:res=a+imm;1:res=a&imm;2:res=a|imm;3:res=a^imm;4:res=a<<imm[4:0];5:res=a>>imm[4:0];6:res=$signed(a)>>>imm[4:0];
    endcase
   end
   2:begin legal=t.ins[5:0]==0;e.write_reg=1;res={t.ins[21:6],16'b0};end
   3,4:begin legal=(op==3)?sub<=4:(sub==0||sub==2||sub==4);e.memory=1;e.store=op==4;e.write_reg=op==3;end
   5:begin
    legal=sub<=5;imm={{15{t.ins[14]}},t.ins[14:0],2'b0};
    case(sub)
     0:taken=a==b;1:taken=a!=b;2:taken=$signed(a)<$signed(b);3:taken=$signed(a)>=$signed(b);4:taken=a<b;5:taken=a>=b;
    endcase
    e.redirect=taken;
   end
   6,7:begin legal=(op==6)?rd==0:rd!=0;imm={{8{t.ins[21]}},t.ins[21:0],2'b0};e.redirect=1;e.write_reg=op==7;res=t.pc+4;end
   8,9:begin legal=sub==0&&((op==8)?rd==0:rd!=0);e.redirect=1;e.write_reg=op==9;res=t.pc+4;end
   10:begin
    e.system=1;
    case(sys)
     0,1,2,4,7,8:legal=t.ins[19:0]==0;
     3:legal=rd==0&&e.csr==0;
     5:begin legal=t.ins[7:0]==0&&e.csr<=10;e.write_reg=1;end
     6:legal=rd==0&&t.ins[7:4]==0&&(e.csr==0||e.csr==2||e.csr==4||e.csr==10);
     default:legal=0;
    endcase
    e.csrdata=a;e.halt=sys==1;
   end
  endcase
  e.address=a+imm;e.target=(op==8||op==9)?e.address:t.pc+imm;e.result=res;
  if(sub==0)begin e.data=b<<(e.address[1:0]*8);e.lanes=e.store?(1<<e.address[1:0]):0;end
  else if(sub==2)begin e.data=b<<(e.address[1:0]*8);e.lanes=e.store?(3<<e.address[1:0]):0;end
  else begin e.data=b;e.lanes=e.store?15:0;end
  e.fault=t.fetch_error||!legal;e.cause=t.fetch_error?3:1;e.bad=t.fetch_error?t.pc:t.ins;e.epc=t.pc;
  if(legal&&e.memory&&((sub==2||sub==3)?e.address[0]:((sub==4)?(|e.address[1:0]):0)))begin e.fault=1;e.cause=e.store?6:4;e.bad=e.address;end
  else if(legal&&(op>=6&&op<=9)&&(|e.target[1:0]))begin e.fault=1;e.cause=2;e.bad=e.target;end
  else if(legal&&op==10&&(sys==2||sys==3))begin e.fault=1;e.cause=sys==2?9:8;e.bad=sys==2?t.ins:{24'b0,t.ins[7:0]};if(sys==3)e.epc=t.pc+4;end
  if(e.fault)begin e.memory=0;e.write_reg=0;e.halt=0;e.system=0;e.redirect=0;end
  if(e.halt)e.write_reg=0;
  return e;
 endfunction
 always @(posedge clk_i) begin : advance_history
  logic complete,sync_fault,stop_event,return_event,irq,control,can_execute,branch_event,move_inbox;
  logic accept_fetch,accept_response,accept_data,old_epoch,old_halt;
  logic[31:0] result_value,epc_value,redirect_address;logic[7:0] cause_value;
  token_t arriving;effect_t next_effect;
  if(rst_i)begin
   foreach(regs[i])regs[i]=0;
   csr_epc=0;csr_cause=0;csr_vector=0;csr_bad=0;csr_scratch=0;status=0;cycles=0;retired=0;
   waiting=0;epoch=0;request_epoch=0;fetch_next=0;request_pc=0;resume_pc=0;inbox='0;execute='0;commit='0;
   halted_o=0;trap_o=0;trap_cause_o=0;trap_badaddr_o=0;retire_valid_o=0;retire_pc_o=0;retire_instruction_o=0;
  end else begin
   complete=commit.valid&&(!commit.memory||(commit.sent&&d_rsp_valid_i));
   sync_fault=complete&&(commit.fault||(commit.memory&&d_rsp_error_i));
   stop_event=complete&&commit.halt&&!sync_fault;
   return_event=complete&&commit.system&&commit.sysop==4&&!sync_fault;
   irq=status[0]&&(timer_irq_i||external_irq_i)&&!sync_fault&&!stop_event&&!return_event&&(halted_o||!commit.valid||(complete&&!commit.system));
   control=sync_fault||stop_event||return_event||irq;
   can_execute=execute.valid&&(!commit.valid||complete)&&!control&&!(commit.valid&&commit.system);
   accept_fetch=i_req_valid_o&&i_req_ready_i;accept_response=i_rsp_valid_i&&waiting;accept_data=d_req_valid_o&&d_req_ready_i;
   old_epoch=epoch;old_halt=halted_o;
   result_value=(commit.system&&commit.sysop==5)?csr_read(commit.csr):(commit.memory?load_result(commit):commit.result);
   epc_value=halted_o?resume_pc:execute.valid?execute.pc:inbox.valid?inbox.pc:(waiting&&request_epoch==epoch)?request_pc:fetch_next;
   if(!irq)epc_value=commit.fault?commit.epc:commit.pc;
   cause_value=irq?(external_irq_i?17:16):(commit.fault?commit.cause:(commit.store?7:5));
   redirect_address=return_event?csr_epc:csr_vector;
   if(complete&&!sync_fault&&commit.write_reg&&commit.rd!=0)regs[commit.rd]=result_value;
   next_effect=interpret(execute);
   branch_event=can_execute&&next_effect.redirect;
   move_inbox=inbox.valid&&(!execute.valid||can_execute)&&!control&&!branch_event;
   arriving=inbox;
   trap_o=0;retire_valid_o=0;
   if(complete)begin
    if(sync_fault)begin trap_o=1;trap_cause_o=cause_value;trap_badaddr_o=commit.fault?commit.bad:commit.address;end
    else begin retire_valid_o=1;retire_pc_o=commit.pc;retire_instruction_o=commit.ins;retired=retired+1;if(stop_event)begin halted_o=1;resume_pc=commit.pc+4;end end
   end
   cycles=cycles+1;
   if(sync_fault||irq)begin
    csr_epc={epc_value[31:2],2'b0};csr_cause={irq,23'b0,cause_value};csr_bad=irq?0:(commit.fault?commit.bad:commit.address);
    status={status[0],1'b0};
   end else if(return_event)status={1'b1,status[1]};
   else if(complete&&commit.system)begin
    if(commit.sysop==6)case(commit.csr)
     0:status=commit.csrdata[1:0];2:csr_epc={commit.csrdata[31:2],2'b0};4:csr_vector={commit.csrdata[31:2],2'b0};10:csr_scratch=commit.csrdata;
    endcase
    if(commit.sysop==7)status[0]=1;
    if(commit.sysop==8)status[0]=0;
   end
   if(accept_response)begin
    waiting=0;
    if(request_epoch==old_epoch&&!branch_event&&!control&&!old_halt)begin inbox.valid=1;inbox.pc=request_pc;inbox.ins=i_rsp_rdata_i;inbox.fetch_error=i_rsp_error_i;end
   end
   if(accept_fetch)begin waiting=1;request_pc=fetch_next;request_epoch=old_epoch;fetch_next=fetch_next+4;end
   if(move_inbox)inbox.valid=0;
   if(control||branch_event)execute.valid=0;
   else if(move_inbox)execute=arriving;
   else if(can_execute)execute.valid=0;
   if(can_execute)commit=next_effect;else if(complete)commit.valid=0;
   if(accept_data)commit.sent=1;
   if(branch_event||control)begin
    epoch=!old_epoch;inbox.valid=0;
    if(branch_event)fetch_next=next_effect.target;
    if(sync_fault||return_event||irq)begin fetch_next=redirect_address;halted_o=0;end
   end
   if(irq)begin trap_o=1;trap_cause_o=cause_value;trap_badaddr_o=0;halted_o=0;end
  end
 end
endmodule
