`timescale 1ns/1ps
module dvbench_model #(parameter ADDR_WIDTH = 8, parameter DATA_WIDTH = 32, parameter XLEN = 32) (
input logic pclk,
input logic presetn,
input logic psel,
input logic penable,
input logic pwrite,
input logic [7:0] paddr,
input logic [31:0] pwdata,
output logic [31:0] prdata,
output logic pready,
output logic pslverr,
input logic wdt_clk,
input logic wdt_rstn,
input logic cpu_dbg_halt,
input logic [31:0] cpu_commit_pc,
input logic cpu_commit_valid,
output logic wdt_reset,
output logic [1:0] reset_scope,
output logic [7:0] trace_event_id,
output logic [31:0] trace_data
);
logic [31:0] controls, timeout_setting, window_setting;
logic [15:0] width_setting;
logic config_lock, refresh_pending_key, refresh_error, recovery;
logic [31:0] last_address;
logic refresh_token, config_token, control_token, boot_token;
logic [2:0] clear_tokens;
logic [1:0] commit_delay;
logic [4:0] faults, fault_delay [0:1];
logic [2:0] snapshot_delay, trace_delay;
logic [31:0] snapshot_value, sampled_count, sampled_trace_data;
logic [7:0] sampled_trace_id;
logic snapshot_token, trace_token;
logic [7:0] timer_event;
logic [31:0] timer_event_data;
logic [2:0] refresh_delay, config_delay, control_delay, boot_delay;
logic [2:0] clear_delay [0:2];
logic [1:0] reset_enable_delay, window_enable_delay, halt_delay;
logic timer_enable, freeze_enable, halt_before;
logic [31:0] timer_limit, timer_window, remaining;
logic [15:0] timer_width, pulse_age;
logic loaded, timed_out;
integer index;
wire bus_write = psel && penable && pwrite;
wire mapped = paddr==0 || paddr==4 || paddr==8 || paddr==12 || paddr==16 || paddr==20 || paddr==24 || paddr==28 || paddr==32 || paddr==36 || paddr==40;
wire protected_address = paddr==0 || paddr==4 || paddr==8 || paddr==40;
assign pslverr = !mapped || (bus_write && config_lock && protected_address);
assign reset_scope = controls[7:6];
always @(posedge pclk or negedge presetn) begin
  if(!presetn) begin
    controls<=32'hca; timeout_setting<=65535; window_setting<=0; width_setting<=32;
    config_lock<=0; refresh_pending_key<=0; refresh_error<=0; recovery<=0;
    last_address<=0; refresh_token<=0; config_token<=0; control_token<=0; boot_token<=0;
    clear_tokens<=0; commit_delay<=0; fault_delay[0]<=0; fault_delay[1]<=0;
    snapshot_delay<=0; trace_delay<=0; sampled_count<=0; sampled_trace_data<=0; sampled_trace_id<=0;
    pready<=0; prdata<=0; trace_event_id<=0; trace_data<=0;
  end else begin
    pready<=1;
    commit_delay<={commit_delay[0],cpu_commit_valid};
    if(commit_delay[1]) last_address<=cpu_commit_pc;
    fault_delay[0]<=faults; fault_delay[1]<=fault_delay[0];
    snapshot_delay<={snapshot_delay[1:0],snapshot_token};
    trace_delay<={trace_delay[1:0],trace_token};
    if(snapshot_delay[1]^snapshot_delay[2]) sampled_count<=snapshot_value;
    if(trace_delay[1]^trace_delay[2]) begin sampled_trace_id<=timer_event; sampled_trace_data<=timer_event_data; end
    trace_event_id<=sampled_trace_id; trace_data<=sampled_trace_data;
    case(paddr)
      0: prdata<=controls;
      4: prdata<=timeout_setting;
      8: prdata<=window_setting;
      16: prdata<={28'b0,fault_delay[1][2],refresh_error,fault_delay[1][1:0]};
      24: prdata<=sampled_count;
      28: prdata<={31'b0,fault_delay[1][4]};
      32: prdata<=last_address;
      36: prdata<={30'b0,recovery,fault_delay[1][3]};
      40: prdata<={16'b0,width_setting};
      default: prdata<=0;
    endcase
    if(bus_write) begin
      case(paddr)
        12: begin
          refresh_pending_key<=0;
          if(!refresh_pending_key && pwdata==32'ha5) refresh_pending_key<=1;
          else if(refresh_pending_key && pwdata==32'h5a) begin
            refresh_token<=!refresh_token; trace_event_id<=8'h24; trace_data<=pwdata;
          end else begin
            refresh_error<=1; trace_event_id<=refresh_pending_key ? 8'h30 : 8'h2c; trace_data<=pwdata;
          end
        end
        16: begin
          if(pwdata[0]) clear_tokens[0]<=!clear_tokens[0];
          if(pwdata[1]) clear_tokens[1]<=!clear_tokens[1];
          if(pwdata[3]) clear_tokens[2]<=!clear_tokens[2];
          if(pwdata[2]) refresh_error<=0;
          trace_event_id<=8'h60; trace_data<={28'b0,fault_delay[1][2],refresh_error,fault_delay[1][1:0]};
        end
        20: begin
          if(pwdata==32'h1acce551 || pwdata==0) begin
            config_lock<=pwdata==0; trace_event_id<=pwdata==0 ? 8'h18 : 8'h1c; trace_data<=pwdata;
          end
        end
        0,4,8,40: begin
          if(config_lock) begin trace_event_id<=8'hc0; trace_data<=paddr; end
          else begin
            trace_data<=pwdata;
            case(paddr)
              0: begin controls<=pwdata & 32'hfdf; control_token<=!control_token; trace_event_id<=8'h08; end
              4: begin timeout_setting<=pwdata; config_token<=!config_token; trace_event_id<=8'h0c; end
              8: begin window_setting<=pwdata; config_token<=!config_token; trace_event_id<=8'h10; end
              40: begin width_setting<=pwdata[15:0]; config_token<=!config_token; trace_event_id<=8'h14; end
            endcase
          end
        end
        36: if(!config_lock) begin
          if(pwdata[0]) boot_token<=!boot_token;
          recovery<=pwdata[1];
        end
        default: begin end
      endcase
    end
  end
end
always @(posedge wdt_clk or negedge wdt_rstn) begin : timer_history
  logic [7:0] event_code;
  logic [31:0] event_value;
  if(!wdt_rstn) begin
    refresh_delay<=0; config_delay<=0; control_delay<=0; boot_delay<=0;
    for(index=0;index<3;index=index+1) clear_delay[index]<=0;
    reset_enable_delay<=0; window_enable_delay<=0; halt_delay<=0;
    timer_enable<=0; freeze_enable<=0; halt_before<=0;
    timer_limit<=65535; timer_window<=0; timer_width<=32;
    remaining<=0; pulse_age<=0; loaded<=0; timed_out<=0; faults<=0; wdt_reset<=0;
    snapshot_value<=0; snapshot_token<=0; timer_event<=4; timer_event_data<=0; trace_token<=0;
  end else begin
    refresh_delay<={refresh_delay[1:0],refresh_token};
    config_delay<={config_delay[1:0],config_token};
    control_delay<={control_delay[1:0],control_token};
    boot_delay<={boot_delay[1:0],boot_token};
    for(index=0;index<3;index=index+1) clear_delay[index]<={clear_delay[index][1:0],clear_tokens[index]};
    reset_enable_delay<={reset_enable_delay[0],controls[1]};
    window_enable_delay<={window_enable_delay[0],controls[2]};
    halt_delay<={halt_delay[0],cpu_dbg_halt};
    if(control_delay[1]^control_delay[2]) begin timer_enable<=controls[0]; freeze_enable<=controls[3]; end
    if(config_delay[1]^config_delay[2]) begin timer_limit<=timeout_setting; timer_window<=window_setting; timer_width<=width_setting; end
    snapshot_value<=remaining; snapshot_token<=!snapshot_token;
    event_code=8'ha4; event_value=remaining;
    if(!halt_before && freeze_enable && halt_delay[1]) event_code=8'h80;
    if(halt_before && !freeze_enable && halt_delay[1]) event_code=8'h84;
    halt_before<=halt_delay[1];
    if(clear_delay[0][1]^clear_delay[0][2]) faults[0]<=0;
    if(clear_delay[1][1]^clear_delay[1][2]) faults[1]<=0;
    if(clear_delay[2][1]^clear_delay[2][2]) faults[2]<=0;
    if(boot_delay[1]^boot_delay[2]) faults[3]<=0;
    if(wdt_reset) begin
      if(pulse_age>=timer_width) begin
        wdt_reset<=0; pulse_age<=0; event_code=8'h48; event_value=timer_width;
      end else pulse_age<=pulse_age+1;
    end
    if(timer_enable && !(freeze_enable && halt_delay[1])) begin
      if(!loaded) begin
        loaded<=1; remaining<=timer_limit; event_code=8'h20; event_value=timer_limit;
      end else if(refresh_delay[1]^refresh_delay[2]) begin
        if(window_enable_delay[1] && remaining>timer_window) begin
          faults[1]<=1; event_code=8'h40; event_value=remaining;
          if(reset_enable_delay[1]) begin wdt_reset<=1; faults[2]<=1; faults[3]<=1; event_code=8'h4c; end
        end else begin
          remaining<=timer_limit; timed_out<=0; faults[0]<=0; event_code=8'h28; event_value=timer_limit;
        end
      end else if(remaining!=0) remaining<=remaining-1;
      else if(!timed_out) begin
        timed_out<=1; faults[0]<=1; faults[4]<=1;
        event_code=8'h64; event_value={31'b0,fault_delay[1][4]};
        if(reset_enable_delay[1]) begin wdt_reset<=1; faults[2]<=1; faults[3]<=1; event_code=8'h44; event_value=remaining; end
      end
    end
    timer_event<=event_code; timer_event_data<=event_value; trace_token<=!trace_token;
  end
end
endmodule
