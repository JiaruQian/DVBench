task timing_reset();
uart_rx=1;kb_ps2d=1;kb_ps2c=1;
uart_rd_uart=0;uart_wr_uart=0;kb_rd_fifo=0;keyboard_transition=0;
rst_n=0;cycles(4);rst_n=1;cycles(24);
endtask
task timing_keyboard_frame(input logic [7:0] value,input int low_width);
logic [10:0] frame;
frame={1'b1,(~^value),value,1'b0};
for(int bit_index=0;bit_index<11;bit_index++)begin
  kb_ps2d=frame[bit_index];kb_ps2c=1;cycles(24);
  kb_ps2c=0;
  if(bit_index==10)keyboard_transition=1;
  cycles(low_width);kb_ps2c=1;
  if(bit_index==10)begin
    cycles(16-low_width);keyboard_transition=0;cycles(24);
  end else cycles(24);
end
endtask
task timing_witnesses();
int pulse_width,low_width,uart_cases,keyboard_cases,sampling_cases;
logic [7:0] code;
uart_cases=0;keyboard_cases=0;sampling_cases=0;
for(int phase_offset=0;phase_offset<4;phase_offset++)begin
  for(int width_index=0;width_index<5;width_index++)begin
    case(width_index)
      0:pulse_width=1;1:pulse_width=4;2:pulse_width=8;
      3:pulse_width=16;default:pulse_width=24;
    endcase
    timing_reset();cycles(phase_offset);
    uart_rx=0;cycles(pulse_width);uart_rx=1;cycles(720);
    if(pred_uart_rx_empty!==1'b0 || pred_uart_rd_data!==8'hff)
      uvm_pkg::uvm_report_error("PROBE_VACUITY","Independent UART model did not accept short-low start",uvm_pkg::UVM_NONE);
    read_uart();cycles(8);
    if(pred_uart_rx_empty!==1'b1)
      uvm_pkg::uvm_report_error("PROBE_VACUITY","UART queue did not drain",uvm_pkg::UVM_NONE);
    uart_cases++;
  end
end
for(int phase_offset=0;phase_offset<4;phase_offset++)begin
  timing_reset();cycles(phase_offset);
  uart_rx=0;cycles(40);
  for(int source_cycle=0;source_cycle<512;source_cycle++)begin
    uart_rx=source_cycle[0];cycles(1);
  end
  uart_rx=1;cycles(96);
  if(pred_uart_rx_empty!==1'b0 || (pred_uart_rd_data!==8'h00 && pred_uart_rd_data!==8'hff))
    uvm_pkg::uvm_report_error("PROBE_VACUITY","Independent UART model did not sample fixed-phase toggling data",uvm_pkg::UVM_NONE);
  read_uart();cycles(8);sampling_cases++;
end
for(int width_index=0;width_index<3;width_index++)begin
  case(width_index)0:low_width=8;1:low_width=9;default:low_width=12;endcase
  for(int code_index=0;code_index<4;code_index++)begin
    case(code_index)0:code=8'h1c;1:code=8'h32;2:code=8'h21;default:code=8'h23;endcase
    timing_reset();timing_keyboard_frame(code,low_width);
    if(pred_kb_fifo_empty!==1'b0 || pred_kb_rd_data!=={1'b0,code})
      uvm_pkg::uvm_report_error("PROBE_VACUITY","Independent keyboard model did not accept filter-boundary frame",uvm_pkg::UVM_NONE);
    read_keyboard();cycles(8);
    if(pred_kb_fifo_empty!==1'b1)
      uvm_pkg::uvm_report_error("PROBE_VACUITY","Keyboard queue did not drain",uvm_pkg::UVM_NONE);
    keyboard_cases++;
  end
end
if(uart_cases!=20 || keyboard_cases!=12 || sampling_cases!=4)
  uvm_pkg::uvm_report_error("PROBE_VACUITY","Timing witness matrix incomplete",uvm_pkg::UVM_NONE);
timing_reset();cycles(32);
endtask
