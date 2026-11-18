module dvbench_model #(parameter integer PRESCALER_WIDTH=8,Dw=32,Aw=3,SELw=4,TAGw=3,CNTw=32)(
  input logic clk,
  input logic reset,
  input logic [Dw-1:0] sa_dat_i,
  input logic [SELw-1:0] sa_sel_i,
  input logic [Aw-1:0] sa_addr_i,
  input logic [TAGw-1:0] sa_tag_i,
  input logic sa_stb_i,
  input logic sa_cyc_i,
  input logic sa_we_i,
  output logic [Dw-1:0] sa_dat_o,
  output logic sa_ack_o,
  output logic sa_err_o,
  output logic sa_rty_o,
  output logic irq
);
  localparam integer CONTROL_BITS=$clog2(PRESCALER_WIDTH)+3;
  logic [CONTROL_BITS-1:0] configuration;
  logic interrupt_latched;
  logic [CNTw-1:0] time_value,compare_value,read_value;
  logic [PRESCALER_WIDTH-1:0] divider_phase;
  logic acknowledge;
  logic tick_due,match_due;
  integer selector;
  integer terminal_phase;
  always @* begin
    selector=int'(configuration >> 3);
    terminal_phase=selector==0 ? 0 : selector<PRESCALER_WIDTH ? (1<<(selector-1)) : 0;
    tick_due=(divider_phase & ((1<<(PRESCALER_WIDTH-1))-1))==terminal_phase;
    match_due=configuration[2] && time_value==compare_value;
    sa_dat_o=Dw'(read_value);
    sa_ack_o=acknowledge;
    sa_err_o=0;
    sa_rty_o=0;
    irq=interrupt_latched;
  end
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      configuration<=0;
      interrupt_latched<=0;
      time_value<=0;
      compare_value<={CNTw{1'b1}};
      read_value<=0;
      divider_phase<=0;
      acknowledge<=0;
    end else begin
      acknowledge<=sa_stb_i && !acknowledge;
      interrupt_latched<=configuration[1] && (interrupt_latched || (tick_due && match_due));
      if (configuration[0]) begin
        if (tick_due) begin
          divider_phase<=0;
          time_value<=match_due ? CNTw'(0) : time_value+CNTw'(1);
        end else divider_phase<=divider_phase+1'b1;
      end
      if (sa_stb_i) begin
        if (sa_we_i) begin
          case (sa_addr_i)
            0: begin
              configuration<=sa_dat_i[CONTROL_BITS-1:0];
              interrupt_latched<=interrupt_latched && !sa_dat_i[CONTROL_BITS];
            end
            1: time_value<=sa_dat_i[CNTw-1:0];
            2: compare_value<=sa_dat_i[CNTw-1:0];
            default: begin end
          endcase
        end else begin
          case (sa_addr_i)
            0: read_value<=CNTw'({interrupt_latched,configuration});
            1: read_value<=time_value;
            2: read_value<=compare_value;
            default: begin end
          endcase
        end
      end
    end
  end
endmodule
