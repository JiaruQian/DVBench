`timescale 1ns/1ps
interface aluexe_if;
logic nvdla_core_clk;
logic nvdla_core_rstn;
logic bdma2csb_resp_valid;
logic [33:0] bdma2csb_resp_pd;
logic [1:0] bdma2glb_done_intr_pd;
logic bdma2mcif_rd_cdt_lat_fifo_pop;
logic bdma2mcif_rd_req_valid;
logic bdma2mcif_rd_req_ready;
logic [78:0] bdma2mcif_rd_req_pd;
logic bdma2mcif_wr_req_valid;
logic bdma2mcif_wr_req_ready;
logic [514:0] bdma2mcif_wr_req_pd;
logic csb2bdma_req_pvld;
logic csb2bdma_req_prdy;
logic [62:0] csb2bdma_req_pd;
logic mcif2bdma_rd_rsp_valid;
logic mcif2bdma_rd_rsp_ready;
logic [513:0] mcif2bdma_rd_rsp_pd;
logic mcif2bdma_wr_rsp_complete;
logic [31:0] pwrbus_ram_pd;
logic dla_clk_ovr_on_sync;
logic global_clk_ovr_on_sync;
logic tmc2slcg_disable_clock_gating;
logic expected_bdma2csb_resp_valid;
logic [33:0] expected_bdma2csb_resp_pd;
logic [1:0] expected_bdma2glb_done_intr_pd;
logic expected_bdma2mcif_rd_cdt_lat_fifo_pop;
logic expected_bdma2mcif_rd_req_valid;
logic [78:0] expected_bdma2mcif_rd_req_pd;
logic expected_bdma2mcif_wr_req_valid;
logic [514:0] expected_bdma2mcif_wr_req_pd;
logic expected_csb2bdma_req_prdy;
logic expected_mcif2bdma_rd_rsp_ready;
logic [635:0] actual_bus,expected_bus;
assign actual_bus={bdma2csb_resp_valid,bdma2csb_resp_pd,bdma2glb_done_intr_pd,bdma2mcif_rd_cdt_lat_fifo_pop,bdma2mcif_rd_req_valid,bdma2mcif_rd_req_pd,bdma2mcif_wr_req_valid,bdma2mcif_wr_req_pd,csb2bdma_req_prdy,mcif2bdma_rd_rsp_ready};
assign expected_bus={expected_bdma2csb_resp_valid,expected_bdma2csb_resp_pd,expected_bdma2glb_done_intr_pd,expected_bdma2mcif_rd_cdt_lat_fifo_pop,expected_bdma2mcif_rd_req_valid,expected_bdma2mcif_rd_req_pd,expected_bdma2mcif_wr_req_valid,expected_bdma2mcif_wr_req_pd,expected_csb2bdma_req_prdy,expected_mcif2bdma_rd_rsp_ready};
task drive(input logic [617:0] value);
{nvdla_core_rstn,bdma2mcif_rd_req_ready,bdma2mcif_wr_req_ready,csb2bdma_req_pvld,csb2bdma_req_pd,mcif2bdma_rd_rsp_valid,mcif2bdma_rd_rsp_pd,mcif2bdma_wr_rsp_complete,pwrbus_ram_pd,dla_clk_ovr_on_sync,global_clk_ovr_on_sync,tmc2slcg_disable_clock_gating}=value;
endtask
bit hardening_active=0;
logic [31:0] random_state;
integer seed_value,phase_index,block_index,operation_index;
logic write_register,read_register;
logic [9:0] selected_register;
logic [31:0] register_value;
function automatic logic [31:0] next_random(input logic [31:0] value);
  next_random={value[30:0],value[31]^value[21]^value[1]^value[0]};
endfunction
task prepare_hardening(input integer index);
  hardening_active=1;
  drive('0);
  nvdla_core_rstn=index>=2 && index<65798;
  bdma2mcif_rd_req_ready=1;
  bdma2mcif_wr_req_ready=1;
  dla_clk_ovr_on_sync=1;
  global_clk_ovr_on_sync=1;
  tmc2slcg_disable_clock_gating=1;
  write_register=0;selected_register=0;register_value=0;
  if(index>=4 && index<40 && (index-4)%3==0) begin
    selected_register=10'((index-4)/3);write_register=1;
    case(selected_register)
      0:register_value=32'h00001000;
      1:register_value=32'h00000001;
      2:register_value=32'h00008000;
      3:register_value=32'h00000002;
      5:register_value=3;
      6:register_value=65536;
      7,8:register_value=32;
      10,11:register_value=32'h01000000;
      default:register_value=0;
    endcase
  end else if(index==44) begin
    write_register=1;selected_register=12;register_value=1;
  end else if(index==50) begin
    write_register=1;selected_register=13;register_value=1;
  end
  csb2bdma_req_pvld=write_register;
  csb2bdma_req_pd={7'b0,1'b0,write_register,register_value,12'b0,selected_register};
endtask
integer performance_phase,performance_group;
bit performance_active=0;
task prepare_performance(input integer index);
  performance_active=1;
  performance_group=index/67000;
  performance_phase=index%67000;
  hardening_active=0;
  drive('0);
  nvdla_core_rstn=performance_phase>=2;
  bdma2mcif_rd_req_ready=1;
  bdma2mcif_wr_req_ready=performance_phase>=66200;
  dla_clk_ovr_on_sync=1;
  global_clk_ovr_on_sync=1;
  tmc2slcg_disable_clock_gating=1;
  mcif2bdma_rd_rsp_valid=performance_phase==100 || performance_phase==120;
  mcif2bdma_rd_rsp_pd={2'b01,{16{32'ha55ac33c}}};
  mcif2bdma_wr_rsp_complete=performance_phase==66400;
  write_register=0;read_register=0;selected_register=0;register_value=0;
  if(performance_phase>=4 && performance_phase<52 && (performance_phase-4)%3==0) begin
    selected_register=10'((performance_phase-4)/3);write_register=1;
    case(selected_register)
      0:register_value=32'h00001000;
      2:register_value=32'h00008000;
      5:register_value=3;
      6:register_value=1;
      7,8,10,11:register_value=32;
      15:register_value=1;
      default:register_value=0;
    endcase
  end else if(performance_phase==60) begin
    write_register=1;selected_register=12;register_value=1;
  end else if(performance_phase==66) begin
    write_register=1;selected_register=10'(13+performance_group);register_value=1;
  end else if(performance_phase>=66500 && performance_phase<66512 && (performance_phase-66500)%3==0) begin
    read_register=1;selected_register=10'(17+2*performance_group+(performance_phase-66500)/6);
  end
  csb2bdma_req_pvld=write_register||read_register;
  csb2bdma_req_pd={7'b0,1'b0,write_register,register_value,12'b0,selected_register};
endtask
task prepare(input integer index);
  if(index>=69896) begin prepare_performance(index-69896);return;end
  if(index>=4096) begin prepare_hardening(index-4096);return;end
  if(index==0) begin
    if(!$value$plusargs("SEED=%d",seed_value))
      if(!$value$plusargs("ntb_random_seed=%d",seed_value)) seed_value=1;
    random_state=32'h6d5a24c3^seed_value;
  end
  random_state=next_random(random_state);
  phase_index=index%1024;block_index=index/1024;
  nvdla_core_rstn=phase_index>=2;
  dla_clk_ovr_on_sync=random_state[0];global_clk_ovr_on_sync=random_state[1];tmc2slcg_disable_clock_gating=random_state[2];
  pwrbus_ram_pd=random_state;
  bdma2mcif_rd_req_ready=phase_index%11!=4;
  bdma2mcif_wr_req_ready=!(phase_index>=160&&phase_index<230)&&phase_index%13!=7;
  mcif2bdma_rd_rsp_valid=phase_index>=180&&phase_index<900&&random_state[3];
  mcif2bdma_rd_rsp_pd={random_state[5:4],{8{random_state,~random_state}}};
  mcif2bdma_wr_rsp_complete=phase_index>=300&&phase_index%13==3;
  write_register=0;read_register=0;selected_register=0;register_value=0;
  if(phase_index>=4&&phase_index<52&&((phase_index-4)%3==0)) begin
    selected_register=10'((phase_index-4)/3);write_register=1;
    case(selected_register)
      0:register_value=32'h102034a0+32'(block_index*32);
      1:register_value=32'h07654321;
      2:register_value=32'hf2345680+32'(block_index*64);
      3:register_value=32'h01234567;
      4:register_value=32'(block_index%4);
      5:register_value=3;
      6,9:register_value=0;
      7:register_value=32'h000003a0;
      8:register_value=32'h00000260;
      10:register_value=32'h00002e20;
      11:register_value=32'h000053a0;
      15:register_value=1;
      default:register_value=0;
    endcase
  end else if(phase_index>=64&&phase_index<130&&((phase_index-64)%3==0)) begin
    selected_register=12;register_value=1;write_register=1;
  end else if(phase_index==140) begin
    selected_register=16;read_register=1;
  end else if(phase_index==150) begin
    selected_register=10'(13+block_index%2);register_value=1;write_register=1;
  end else if(phase_index>=350&&phase_index<374&&((phase_index-350)%3==0)) begin
    operation_index=(phase_index-350)/3;write_register=1;
    case(operation_index)
      0:begin selected_register=4;register_value=32'(4+block_index%3);end
      1:begin selected_register=6;register_value=32'(1+block_index%2);end
      2:begin selected_register=9;register_value=1;end
      3:begin selected_register=12;register_value=1;end
      4:begin selected_register=0;register_value=32'hffffffe0;end
      5:begin selected_register=12;register_value=1;end
      6:begin selected_register=10'(14-block_index%2);register_value=1;end
      default:begin selected_register=4;register_value=0;end
    endcase
  end else if(phase_index>=400&&phase_index%3==0) begin
    selected_register=10'(random_state[12:8]%24);read_register=1;
  end
  csb2bdma_req_pvld=write_register||read_register;
  csb2bdma_req_pd={random_state[6:0],random_state[7],write_register,register_value,12'(random_state[23:12]),selected_register};
endtask

endinterface
