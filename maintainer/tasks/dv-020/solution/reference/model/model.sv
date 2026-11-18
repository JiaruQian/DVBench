`timescale 1ns/1ps
module dvbench_model(input [21:0] az_addr,input [1:0] az_be_n,input az_cs,input [15:0] az_data,
input az_rd_n,az_wr_n,clk,reset_n,
output logic [15:0] za_data,output logic za_valid,output za_waitrequest,
output logic [11:0] zs_addr,output logic [1:0] zs_ba,
output zs_cas_n,zs_cke,zs_cs_n,inout wire [15:0] zs_dq,
output logic [1:0] zs_dqm,output zs_ras_n,zs_we_n);
typedef struct packed {logic read_op;logic [21:0] address;logic [1:0] mask;logic [15:0] data;} request_t;
request_t pending_queue[$],active,selected,head;
integer cycle_no=0,phase=0,countdown=0,resume_phase=0,queue_depth=0;
logic [3:0] command=15;
logic [2:0] read_pipeline=0;
logic output_enable=0,deferred_pop=0,refresh_due=0,refresh_ack=0,active_enabled=0;
logic [15:0] write_value=0;
logic match_head,consume,accept_new;
integer next_cycle;
assign {zs_cs_n,zs_ras_n,zs_cas_n,zs_we_n}=command;
assign zs_cke=1;
assign zs_dq=output_enable ? write_value : 16'hzzzz;
assign za_waitrequest=queue_depth==2;
function automatic logic compatible(request_t first,request_t second);
  return first.read_op==second.read_op && first.address[21:8]==second.address[21:8];
endfunction
always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin
    pending_queue.delete();queue_depth<=0; cycle_no<=0; phase<=0;countdown<=0;resume_phase<=0;
    command<=15;zs_addr<=0;zs_ba<=0;zs_dqm<=0;write_value<=0;output_enable<=0;
    read_pipeline<=0;za_valid<=0;za_data<=0;deferred_pop<=0;refresh_due<=0;refresh_ack<=0;active_enabled<=0;
  end else begin
    next_cycle=cycle_no+1;
    cycle_no<=next_cycle;
    za_data<=zs_dq;za_valid<=read_pipeline[2];
    read_pipeline<={read_pipeline[1:0],command[2:0]==5};
    refresh_due<=((next_cycle>=5783 && (next_cycle-5783)%782==0)||refresh_due)&&!refresh_ack;
    accept_new=(pending_queue.size()<2)&&(!az_rd_n || !az_wr_n);
    match_head=0;head='0;
    if(pending_queue.size()>0) begin head=pending_queue[0];match_head=active_enabled&&compatible(head,active);end
    consume=deferred_pop&&match_head;
    selected=consume ? head : active;
    deferred_pop<=0;output_enable<=0;
    if(next_cycle<5018) begin
      zs_addr<=12'hfff; command<=next_cycle<5004 ? 15 : 7;
      case(next_cycle)
        5003:command<=2;
        5005,5009:command<=1;
        5013:begin command<=0;zs_addr<=12'h030;end
      endcase
    end else case(phase)
      0: begin
        command<=refresh_due ? 7 : 15;refresh_ack<=0;
        if(refresh_due) begin active_enabled<=0;phase<=5;resume_phase<=6;countdown<=0;end
        else if(pending_queue.size()>0) begin active=head;active_enabled<=1;deferred_pop<=1;phase<=1;end
      end
      1:begin
        command<={~active_enabled,3'd3};zs_ba<={active.address[21],active.address[8]};zs_addr<=active.address[20:9];
        write_value<=active.data;zs_dqm<=active.mask;phase<=2;countdown<=1;resume_phase<=3;
      end
      2:begin
        command<={(resume_phase==6 ? 1'b0 : ~active_enabled),3'd7};
        if(countdown>1) countdown<=countdown-1;else phase<=resume_phase;
      end
      3:begin
        command<={~active_enabled,(active.read_op ? 3'd5 : 3'd4)};
        zs_ba<={selected.address[21],selected.address[8]};zs_addr<={4'b0,selected.address[7:0]};zs_dqm<=selected.mask;
        if(!active.read_op) begin output_enable<=1;write_value<=selected.data;end
        if(match_head) begin
          if(refresh_due) begin phase<=2;resume_phase<=0;countdown<=active.read_op ? 2 : 1;end
          else begin active=head;deferred_pop<=1;end
        end else begin
          if(deferred_pop) begin command<={~active_enabled,3'd7};output_enable<=0;end
          phase<=7;
        end
      end
      4:begin command<={~active_enabled,3'd7};phase<=5;countdown<=0;end
      5:begin command<={(refresh_due ? 1'b0 : ~active_enabled),3'd2};zs_addr<=12'hfff;phase<=2;end
      6:begin command<=1;refresh_ack<=1;phase<=2;countdown<=3;resume_phase<=0;end
      7:begin
        command<={~active_enabled,3'd7};
        if(refresh_due) begin phase<=2;countdown<=1;resume_phase<=0;end
        else if(pending_queue.size()>0) begin
          if(match_head) begin active=head;deferred_pop<=1;phase<=3;end
          else begin phase<=4;resume_phase<=0;countdown<=1;end
        end
      end
    endcase
    if(consume) head=pending_queue.pop_front();
    if(accept_new) pending_queue.push_back('{az_wr_n,az_addr,(az_wr_n ? 2'b00 : az_be_n),az_data});
    queue_depth<=pending_queue.size();
  end
end
endmodule
