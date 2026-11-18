`timescale 1ns/1ps
module dvbench_model(
input logic nvdla_core_clk,
input logic nvdla_core_rstn,
output logic bdma2csb_resp_valid,
output logic [33:0] bdma2csb_resp_pd,
output logic [1:0] bdma2glb_done_intr_pd,
output logic bdma2mcif_rd_cdt_lat_fifo_pop,
output logic bdma2mcif_rd_req_valid,
input logic bdma2mcif_rd_req_ready,
output logic [78:0] bdma2mcif_rd_req_pd,
output logic bdma2mcif_wr_req_valid,
input logic bdma2mcif_wr_req_ready,
output logic [514:0] bdma2mcif_wr_req_pd,
input logic csb2bdma_req_pvld,
output logic csb2bdma_req_prdy,
input logic [62:0] csb2bdma_req_pd,
input logic mcif2bdma_rd_rsp_valid,
output logic mcif2bdma_rd_rsp_ready,
input logic [513:0] mcif2bdma_rd_rsp_pd,
input logic mcif2bdma_wr_rsp_complete,
input logic [31:0] pwrbus_ram_pd,
input logic dla_clk_ovr_on_sync,
input logic global_clk_ovr_on_sync,
input logic tmc2slcg_disable_clock_gating
);
typedef struct packed {
  logic [26:0] source_low;
  logic [31:0] source_high;
  logic [26:0] destination_low;
  logic [31:0] destination_high;
  logic [12:0] size;
  logic source_mc,destination_mc;
  logic [23:0] lines;
  logic [26:0] source_line,destination_line;
  logic [23:0] surfaces;
  logic [26:0] source_surface,destination_surface;
} descriptor_t;
logic [31:0] configuration[0:15];
logic request_valid;
logic [62:0] request;
wire [9:0] register_index=request[9:0];
wire register_write=request_valid&&request[54];
wire response_due=request_valid&&(!request[54]||request[55]);
logic [31:0] read_value;
logic op_trigger,launch0_trigger,launch1_trigger;
wire push_descriptor=op_trigger&&configuration[12][0];
wire launch0=launch0_trigger&&configuration[13][0];
wire launch1=launch1_trigger&&configuration[14][0];
wire group_launch=launch0||launch1;
logic [4:0] gathered,launched;
logic gathering,gathered_group,active_group;
logic descriptor_ready,context_ready,context_valid,context_idle,context_read_ready;
logic storing,write_command_phase;
wire gather_ready=launched==0||(descriptor_ready&&launched==1);
wire gather_transfer=gathering&&gather_ready;
wire launch_capture_ready=gather_ready||!gathering;
descriptor_t descriptor_input,descriptor_output;
logic descriptor_fifo_ready,descriptor_fifo_valid,descriptor_fifo_idle;
logic [4:0] descriptor_used;
logic [160:0] context_input,context_output;
logic [1:0] group_busy,group_done;
logic [31:0] read_stalls[0:1],latched_read_stalls[0:1],latched_write_stalls[0:1],write_stalls;
logic loading,source_mc;
logic [12:0] read_size;
logic [23:0] read_lines,read_surfaces,read_line_index,read_surface_index;
logic [31:0] read_line_stride,read_surface_stride;
logic [63:0] read_address,read_surface_address;
logic read_pipe_ready;
logic cv_pipe_ready,cv_pipe_valid;
logic [78:0] cv_pipe_data;
wire selected_read_ready=(source_mc&&read_pipe_ready)||(!source_mc&&cv_pipe_ready);
wire read_accept=loading&&selected_read_ready;
wire read_surface_end=read_line_index==read_lines;
wire read_cube_end=read_surface_end&&read_surface_index==read_surfaces;
wire load_slot_ready=!loading||(read_accept&&read_cube_end);
wire store_available=write_command_phase&&!storing;
wire source_switch=descriptor_output.source_mc!=source_mc;
wire load_enabled=launched!=0&&((context_idle&&!loading&&store_available)||!source_switch);
wire load_descriptor=launched!=0&&context_ready&&load_slot_ready&&load_enabled;
wire context_write=launched!=0&&load_slot_ready&&load_enabled;
logic destination_mc,write_source_mc,write_interrupt,write_group;
logic [12:0] write_size,write_lines,write_surfaces,write_line_index,write_surface_index;
logic [26:0] write_line_stride,write_surface_stride;
logic [63:0] write_address,write_surface_address;
logic [11:0] beat_index;
wire final_beat=beat_index==write_size[12:1];
wire write_surface_end=write_line_index==write_lines;
wire write_cube_end=write_surface_end&&write_surface_index==write_surfaces;
logic latency_ready,latency_valid,latency_idle;
logic [513:0] latency_data,response_data;
logic [7:0] latency_used;
logic response_valid;
logic write_pipe_ready;
wire write_valid=write_command_phase ? storing : latency_valid;
wire write_accept=write_valid&&destination_mc&&write_pipe_ready;
wire command_accept=write_accept&&write_command_phase;
wire data_accept=write_accept&&!write_command_phase;
wire latency_pop=destination_mc&&write_pipe_ready&&!write_command_phase;
wire context_accept=context_valid&&context_read_ready;
wire acknowledgement_command=command_accept&&write_interrupt&&write_cube_end;
logic [514:0] write_packet;
logic interrupt_valid,interrupt_group,interrupt_idle;
logic ack_bottom_valid,ack_top_valid,ack_top_mc,registered_completion,pending_completion,released_completion;
wire release_ack=ack_top_mc&&(registered_completion||pending_completion);
wire ack_top_ready=release_ack||!ack_top_valid;
wire ack_bottom_ready=ack_top_ready||!ack_bottom_valid;
wire internal_idle=interrupt_idle&&!storing&&context_idle&&!loading&&descriptor_fifo_idle;
assign csb2bdma_req_prdy=1;
assign descriptor_ready=context_ready&&load_slot_ready&&load_enabled;
assign context_read_ready=!storing||(data_accept&&final_beat&&write_cube_end);
assign group_done[0]=interrupt_valid&&released_completion&&!interrupt_group;
assign group_done[1]=interrupt_valid&&released_completion&&interrupt_group;
always @* begin
  descriptor_input.source_low=configuration[0][31:5];descriptor_input.source_high=configuration[1];
  descriptor_input.destination_low=configuration[2][31:5];descriptor_input.destination_high=configuration[3];
  descriptor_input.size=configuration[4][12:0];descriptor_input.source_mc=configuration[5][0];descriptor_input.destination_mc=configuration[5][1];
  descriptor_input.lines=configuration[6][23:0];descriptor_input.source_line=configuration[7][31:5];descriptor_input.destination_line=configuration[8][31:5];
  descriptor_input.surfaces=configuration[9][23:0];descriptor_input.source_surface=configuration[10][31:5];descriptor_input.destination_surface=configuration[11][31:5];
  context_input={descriptor_output.surfaces[12:0],descriptor_output.destination_surface,descriptor_output.lines[12:0],descriptor_output.destination_line,active_group,descriptor_ready&&launched==1,descriptor_output.destination_mc,descriptor_output.source_mc,descriptor_output.size,descriptor_output.destination_high,descriptor_output.destination_low,5'b0};
  write_packet='0;
  if(write_command_phase) write_packet[77:0]={write_interrupt&&write_cube_end,write_size,write_address};
  else write_packet={1'b1,(write_size[0]==0&&final_beat ? 2'b01 : 2'b11),latency_data[511:0]};
  read_value=0;
  if(register_index<16) read_value=configuration[register_index];
  else case(register_index)
    16:read_value={21'b0,group_busy[1],group_busy[0],internal_idle,8'(20-descriptor_used)};
    17:read_value=latched_read_stalls[0];
    18:read_value=latched_write_stalls[0];
    19:read_value=latched_read_stalls[1];
    20:read_value=latched_write_stalls[1];
    default:read_value=0;
  endcase
end
bdma_predict_ram_fifo #(289,20,5) descriptors(nvdla_core_clk,nvdla_core_rstn,push_descriptor,descriptor_ready,descriptor_input,descriptor_fifo_ready,descriptor_fifo_valid,descriptor_fifo_idle,descriptor_output,descriptor_used);
bdma_predict_context_fifo contexts(nvdla_core_clk,nvdla_core_rstn,context_write,context_read_ready,context_input,context_ready,context_valid,context_idle,context_output);
bdma_predict_pipe #(79,1) requests(nvdla_core_clk,nvdla_core_rstn,loading&&source_mc,bdma2mcif_rd_req_ready,{2'b0,read_size,read_address},read_pipe_ready,bdma2mcif_rd_req_valid,bdma2mcif_rd_req_pd);
bdma_predict_pipe #(79,1) unavailable_requests(nvdla_core_clk,nvdla_core_rstn,loading&&!source_mc,1'bz,{2'b0,read_size,read_address},cv_pipe_ready,cv_pipe_valid,cv_pipe_data);
bdma_predict_pipe #(514,0) responses(nvdla_core_clk,nvdla_core_rstn,mcif2bdma_rd_rsp_valid,latency_ready,mcif2bdma_rd_rsp_pd,mcif2bdma_rd_rsp_ready,response_valid,response_data);
bdma_predict_ram_fifo #(514,245,8) returned_data(nvdla_core_clk,nvdla_core_rstn,response_valid,latency_pop,response_data&{514{response_valid}},latency_ready,latency_valid,latency_idle,latency_data,latency_used);
bdma_predict_pipe #(515,1) writes(nvdla_core_clk,nvdla_core_rstn,write_valid&&destination_mc,bdma2mcif_wr_req_ready,write_packet,write_pipe_ready,bdma2mcif_wr_req_valid,bdma2mcif_wr_req_pd);
bdma_predict_interrupt interrupts(nvdla_core_clk,nvdla_core_rstn,acknowledgement_command,write_group,released_completion,interrupt_valid,interrupt_group,interrupt_idle);
always @(posedge nvdla_core_clk) begin
  if(csb2bdma_req_pvld) request<=csb2bdma_req_pd;
  if(response_due) bdma2csb_resp_pd<={request[54],1'b0,(request[54] ? 32'b0 : read_value)};
  if(load_descriptor) read_address<={descriptor_output.source_high,descriptor_output.source_low,5'b0};
  else if(read_accept) read_address<=read_surface_end ? read_surface_address+read_surface_stride : read_address+read_line_stride;
  if(context_accept) begin
    write_address<=context_output[63:0];write_surface_address<=context_output[63:0];
    write_size<=context_output[76:64];write_source_mc<=context_output[77];destination_mc<=context_output[78];write_interrupt<=context_output[79];write_group<=context_output[80];
    write_line_stride<=context_output[107:81];write_lines<=context_output[120:108];write_surface_stride<=context_output[147:121];write_surfaces<=context_output[160:148];
  end else if(data_accept&&final_beat) begin
    write_address<=write_surface_end ? write_surface_address+(64'(write_surface_stride)<<5) : write_address+(64'(write_line_stride)<<5);
    if(write_surface_end) write_surface_address<=write_surface_address+(64'(write_surface_stride)<<5);
  end
end
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
  if(!nvdla_core_rstn) begin
    request_valid<=0;bdma2csb_resp_valid<=0;bdma2glb_done_intr_pd<=0;
    for(integer register_number=0;register_number<16;register_number++) configuration[register_number]<=0;
    op_trigger<=0;launch0_trigger<=0;launch1_trigger<=0;gathered<=0;launched<=0;gathering<=0;gathered_group<=0;active_group<=0;group_busy<=0;
    loading<=0;source_mc<=0;read_size<=0;read_lines<=0;read_surfaces<=0;read_line_index<=0;read_surface_index<=0;read_line_stride<=0;read_surface_stride<=0;read_surface_address<=0;
    storing<=0;write_command_phase<=1;beat_index<=0;write_line_index<=0;write_surface_index<=0;bdma2mcif_rd_cdt_lat_fifo_pop<=0;
    ack_bottom_valid<=0;ack_top_valid<=0;ack_top_mc<=0;registered_completion<=0;pending_completion<=0;released_completion<=0;write_stalls<=0;
    for(integer group_number=0;group_number<2;group_number++) begin read_stalls[group_number]<=0;latched_read_stalls[group_number]<=0;latched_write_stalls[group_number]<=0;end
  end else begin
    request_valid<=csb2bdma_req_pvld;bdma2csb_resp_valid<=response_due;bdma2glb_done_intr_pd<=group_done;
    if(register_write&&register_index<16) begin
      case(register_index)
        0,2,7,8,10,11:configuration[register_index]<=request[53:22]&32'hffffffe0;
        4:configuration[register_index]<={19'b0,request[34:22]};
        5:configuration[register_index]<={30'b0,request[23:22]};
        6,9:configuration[register_index]<={8'b0,request[45:22]};
        12,13,14,15:configuration[register_index]<={31'b0,request[22]};
        default:configuration[register_index]<=request[53:22];
      endcase
    end
    op_trigger<=register_write&&register_index==12;
    launch0_trigger<=register_write&&register_index==13;
    launch1_trigger<=register_write&&register_index==14;
    if(gather_transfer) gathered<=push_descriptor ? 1 : 0;
    else if(push_descriptor) gathered<=gathered+1'b1;
    if(launch_capture_ready) gathering<=group_launch;
    if(launch0) gathered_group<=0;else if(launch1) gathered_group<=1;
    if(launched!=0) begin
      if(descriptor_ready) begin
        if(launched==1&&gathering) begin launched<=gathered;active_group<=gathered_group;end
        else launched<=launched-1'b1;
      end
    end else if(gathering) begin launched<=gathered;active_group<=gathered_group;end
    for(integer group_number=0;group_number<2;group_number++) begin
      if(group_number==0 ? launch0 : launch1) begin group_busy[group_number]<=1;latched_read_stalls[group_number]<=0;latched_write_stalls[group_number]<=0;end
      else if(group_done[group_number]) begin group_busy[group_number]<=0;latched_read_stalls[group_number]<=read_stalls[group_number];latched_write_stalls[group_number]<=write_stalls;end
      if(configuration[15][0]) read_stalls[group_number]<=group_done[group_number] ? 0 : read_stalls[group_number]+32'(loading&&!selected_read_ready&&(active_group==group_number));
    end
    case(load_slot_ready)
      1'b1:loading<=launched!=0&&context_ready&&load_enabled;
      1'b0:loading<=loading;
      default:loading<=1'bx;
    endcase
    if(load_descriptor) begin
      source_mc<=descriptor_output.source_mc;read_size<=descriptor_output.size;
      read_lines<=descriptor_output.lines;read_surfaces<=descriptor_output.surfaces;
      read_line_stride<={descriptor_output.source_line,5'b0};read_surface_stride<={descriptor_output.source_surface,5'b0};
      read_surface_address<={descriptor_output.source_high,descriptor_output.source_low,5'b0};
    end else if(read_accept&&read_surface_end) read_surface_address<=read_surface_address+read_surface_stride;
    if(read_accept) begin
      read_line_index<=read_surface_end ? 0 : read_line_index+1'b1;
      if(read_cube_end) read_surface_index<=0;else if(read_surface_end) read_surface_index<=read_surface_index+1'b1;
    end
    if(context_read_ready) storing<=context_valid;
    if(command_accept) write_command_phase<=0;
    else if(data_accept&&final_beat) write_command_phase<=1;
    if(data_accept) beat_index<=final_beat ? 0 : beat_index+1'b1;
    if(data_accept&&final_beat) begin
      write_line_index<=write_surface_end ? 0 : write_line_index+1'b1;
      if(write_cube_end) write_surface_index<=0;else if(write_surface_end) write_surface_index<=write_surface_index+1'b1;
    end
    bdma2mcif_rd_cdt_lat_fifo_pop<=latency_valid&&latency_pop&&write_source_mc;
    if(ack_bottom_ready) ack_bottom_valid<=acknowledgement_command;
    if(ack_top_ready) ack_top_valid<=ack_bottom_valid;
    if(ack_bottom_valid&&ack_top_ready) ack_top_mc<=1;
    registered_completion<=mcif2bdma_wr_rsp_complete;released_completion<=release_ack;
    if(!ack_top_mc) begin if(registered_completion) pending_completion<=1;end
    else if(pending_completion) pending_completion<=0;
    if(configuration[15][0]) write_stalls<=released_completion ? 0 : write_stalls+32'(write_valid&&!(destination_mc&&write_pipe_ready));
  end
end

endmodule

module bdma_predict_pipe #(parameter WIDTH=1, INPUT_SKID=1)(
  input logic clk,reset_n,input_valid,output_ready,
  input logic [WIDTH-1:0] input_data,
  output logic input_ready,output_valid,
  output logic [WIDTH-1:0] output_data
);
logic buffered,permission,registered_valid;
logic [WIDTH-1:0] spare_data,registered_data;
wire stage_ready=INPUT_SKID ? output_ready || !registered_valid : permission;
wire offered=INPUT_SKID ? input_valid : registered_valid;
wire [WIDTH-1:0] offered_data=INPUT_SKID ? input_data : registered_data;
wire consumer_ready=INPUT_SKID ? stage_ready : output_ready;
wire capture_spare=offered && permission && !consumer_ready;
wire next_permission=buffered ? consumer_ready : !capture_spare;
wire selected_valid=permission ? offered : buffered;
wire [WIDTH-1:0] selected_data=permission ? offered_data : spare_data;
wire register_ready=INPUT_SKID ? stage_ready : permission || !registered_valid;
assign input_ready=INPUT_SKID ? permission : register_ready;
assign output_valid=INPUT_SKID ? registered_valid : selected_valid;
assign output_data=INPUT_SKID ? registered_data : selected_data;
always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin buffered<=0;permission<=1;registered_valid<=0;end
  else begin
    buffered<=buffered ? !consumer_ready : capture_spare;
    permission<=next_permission;
    registered_valid<=register_ready ? (INPUT_SKID ? selected_valid : input_valid) : 1'b1;
  end
end
always @(posedge clk) begin
  spare_data<=capture_spare ? offered_data : spare_data;
  registered_data<=(register_ready && (INPUT_SKID ? selected_valid : input_valid)) ? (INPUT_SKID ? selected_data : input_data) : registered_data;
end
endmodule

module bdma_predict_ram_fifo #(parameter WIDTH=1,DEPTH=20,COUNT_WIDTH=5)(
  input logic clk,reset_n,input_valid,output_ready,
  input logic [WIDTH-1:0] input_data,
  output logic input_ready,output_valid,idle,
  output logic [WIDTH-1:0] output_data,
  output logic [COUNT_WIDTH-1:0] used
);
logic [WIDTH-1:0] storage[0:DEPTH-1];
logic full,delayed_write,delayed_pop,prefetched;
logic [COUNT_WIDTH-1:0] available;
integer head,tail,read_address;
wire accepted=input_valid&&!full;
wire transfer=prefetched&&(!output_valid||output_ready);
wire [COUNT_WIDTH-1:0] next_used=used+COUNT_WIDTH'(accepted)-COUNT_WIDTH'(delayed_pop);
wire [COUNT_WIDTH-1:0] next_available=available+COUNT_WIDTH'(delayed_write)-COUNT_WIDTH'(transfer);
wire fetch_next=next_available!=0 && (!prefetched||transfer);
assign input_ready=!full;
assign idle=!input_valid&&!output_valid&&!delayed_write&&available==0&&!accepted&&used==0;
always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin
    used<=0;available<=0;full<=0;delayed_write<=0;delayed_pop<=0;prefetched<=0;
    output_valid<=0;head<=0;tail<=0;
  end else begin
    used<=next_used;full<=!delayed_pop&&(used+COUNT_WIDTH'(accepted)==DEPTH);
    available<=next_available;
    delayed_write<=accepted;delayed_pop<=transfer;
    if(delayed_write||transfer) prefetched<=next_available!=0;
    output_valid<=prefetched||(output_valid&&!output_ready);
    if(accepted) tail<=tail==DEPTH-1 ? 0 : tail+1;
    if(transfer) head<=head==DEPTH-1 ? 0 : head+1;
  end
end
always @(posedge clk) begin
  if(accepted) storage[tail]<=input_data;
  if(fetch_next) read_address<=transfer ? (head==DEPTH-1 ? 0 : head+1) : head;
  if(transfer) output_data<=storage[read_address];
end
endmodule

module bdma_predict_context_fifo(
  input logic clk,reset_n,input_valid,output_ready,
  input logic [160:0] input_data,
  output logic input_ready,output_valid,idle,
  output logic [160:0] output_data
);
logic input_held,input_blocked,full;
logic [160:0] input_register,storage[0:19];
logic [4:0] used;
integer head,tail;
wire reserve=input_held&&!full;
wire transfer=(used!=0||reserve)&&(!output_valid||output_ready);
wire [4:0] next_used=used+5'(reserve)-5'(transfer);
wire next_full=!transfer&&(used+5'(reserve)==20);
assign input_ready=!input_blocked;
assign idle=!input_held&&!output_valid&&!reserve&&used==0;
always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin input_held<=0;input_blocked<=0;full<=0;used<=0;head<=0;tail<=0;output_valid<=0;end
  else begin
    input_blocked<=input_valid ? next_full : (input_held&&next_full)&&!reserve;
    if(!(input_held&&full)) input_held<=input_valid&&!input_blocked;
    full<=next_full;used<=next_used;
    output_valid<=used!=0||reserve||(output_valid&&!output_ready);
    if(reserve) tail<=tail==19 ? 0 : tail+1;
    if(transfer) head<=head==19 ? 0 : head+1;
  end
end
always @(posedge clk) begin
  if(input_valid&&!input_blocked) input_register<=input_data;
  if(reserve&&(used!=0||!transfer)) storage[tail]<=input_register;
  if(transfer) output_data<=used==0 ? input_register : storage[head];
end
endmodule

module bdma_predict_interrupt(
  input logic clk,reset_n,input_valid,input_group,complete,
  output logic valid,group_id,idle
);
logic saved_valid,previous_valid,previous_ready,saved_group;
wire select_saved=saved_valid&&previous_valid&&!previous_ready;
wire offered_valid=select_saved ? saved_valid : input_valid;
wire capture=input_valid&&!(saved_valid&&select_saved);
assign idle=!input_valid&&!saved_valid&&!valid;
always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin saved_valid<=0;previous_valid<=0;previous_ready<=1;valid<=0;end
  else begin
    previous_ready<=complete;previous_valid<=valid;
    saved_valid<=input_valid||(saved_valid&&select_saved);
    if(!valid||complete) valid<=offered_valid;
  end
end
always @(posedge clk) begin
  if(valid&&offered_valid&&capture) saved_group<=input_group;
  if(offered_valid&&(!valid||complete)) group_id<=select_saved ? saved_group : input_group;
end
endmodule
