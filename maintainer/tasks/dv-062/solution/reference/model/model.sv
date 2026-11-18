`timescale 1ns/1ps
// Scalar behavioral oracle built from the published fixed-point/LUT equations.
// Coefficients are generated from high-precision mathematical definitions at
// construction, then independently checked against the immutable source table.
// No RTL body, partial-product tree or pipeline implementation is copied.
// No DUT output, hierarchy, trace, UVM dependency or external file is consumed.
package dvbench_sigmoid_math;
  localparam longint unsigned EXP_ANCHOR[0:16]='{64'd8388608,64'd8032959,64'd7692387,64'd7366255,64'd7053950,64'd6754886,64'd6468501,64'd6194258,64'd5931642,64'd5680159,64'd5439339,64'd5208729,64'd4987896,64'd4776426,64'd4573921,64'd4380002,64'd4194304};
  localparam longint unsigned RECIP_ANCHOR[0:16]='{64'd8388608,64'd7895160,64'd7456540,64'd7064091,64'd6710886,64'd6391320,64'd6100806,64'd5835553,64'd5592405,64'd5368709,64'd5162220,64'd4971027,64'd4793490,64'd4628198,64'd4473924,64'd4329604,64'd4194304};
  function automatic longint unsigned rne_shift(input longint unsigned value,input int count);
    longint unsigned whole,remainder,halfway;
    if(count<=0) return value;
    whole=value>>count;
    remainder=value-(whole<<count);
    halfway=64'd1<<(count-1);
    return whole+((remainder>halfway)||((remainder==halfway)&&whole[0]));
  endfunction
  // q is Q1.23 in [0.5,1]; the desired real value is q*2^(-23-scale).
  function automatic logic [31:0] pack_q23(input longint unsigned q,input int scale);
    longint unsigned significand;
    int biased;
    significand=q; biased=127-scale;
    if(q<64'd8388608) begin significand=q<<1; biased--; end
    return {1'b0,8'(biased),23'(significand)};
  endfunction
  function automatic logic [31:0] exponential(input logic [30:0] magnitude);
    longint unsigned m,r,high,low,correction;
    int exponent,segment,remainder;
    if(magnitude>31'h41800000) return 32'd0;
    exponent=int'(magnitude[30:23]);
    m=0;
    if(exponent>=111 && exponent<=131)
      m=(64'd8388608+longint'(magnitude[22:0]))>>(134-exponent);
    r=rne_shift(m*64'd94548,16);
    segment=int'((r>>12)&64'd15); remainder=int'(r&64'd4095);
    high=EXP_ANCHOR[segment]; low=EXP_ANCHOR[segment+1];
    correction=rne_shift((high-low)*remainder,12);
    return pack_q23(high-correction,int'(r>>16));
  endfunction
  function automatic logic [31:0] add_one(input logic [31:0] value);
    longint unsigned contribution;
    int exponent;
    if(value==32'd0) return 32'h3f800000;
    if(value==32'h3f800000) return 32'h40000000;
    exponent=int'(value[30:23]);
    contribution=rne_shift(64'd8388608+longint'(value[22:0]),127-exponent);
    if(contribution>=64'd8388608) return 32'h40000000;
    return 32'h3f800000|32'(contribution);
  endfunction
  function automatic logic [31:0] reciprocal(input logic [31:0] value);
    longint unsigned high,low,correction;
    int segment,remainder,scale;
    segment=int'(value[22:19]);
    remainder=int'(value[18:7]);
    scale=int'(value[30:23])-127;
    high=RECIP_ANCHOR[segment]; low=RECIP_ANCHOR[segment+1];
    correction=rne_shift((high-low)*remainder,12);
    return pack_q23(high-correction,scale);
  endfunction
  // Only the top-level reachable domain is needed: operands are nonnegative
  // normal or exact zero; all nonzero products exceed 2^-25, far above FTZ.
  function automatic logic [31:0] multiply(input logic [31:0] a,input logic [31:0] b);
    longint unsigned product,rounded;
    int exponent,shift;
    if(a==0 || b==0) return 32'd0;
    product=(64'd8388608+longint'(a[22:0]))*(64'd8388608+longint'(b[22:0]));
    exponent=int'(a[30:23])+int'(b[30:23])-254;
    shift=(product>=64'd140737488355328)?24:23;
    if(shift==24) exponent++;
    rounded=rne_shift(product,shift);
    if(rounded>=64'd16777216) begin rounded=rounded>>1; exponent++; end
    if(exponent < -126 || exponent > 127) return 32'hxxxxxxxx;
    return {1'b0,8'(exponent+127),23'(rounded)};
  endfunction
  function automatic logic [32:0] evaluate(input logic [31:0] value,input logic input_invalid);
    logic [31:0] e,d,q,result;
    logic invalid;
    invalid=input_invalid;
    if(value[30:23]==8'hff && value[22:0]!=0) begin
      result=32'h7fc00000; invalid=1;
    end else if(value[30:23]==8'hff) begin
      result=value[31]?32'h00000000:32'h3f800000;
    end else begin
      e=exponential(value[30:0]);
      d=add_one(e);
      q=reciprocal(d);
      result=value[31]?multiply(e,q):q;
    end
    return {invalid,result};
  endfunction
endpackage

module dvbench_model #(parameter bit FTZ=1'b0)(
  input logic clk_i,rst_i,clear_i,valid_i,
  input logic [31:0] data_i,
  input logic invalid_i,
  output logic valid_o,
  output logic [31:0] result_o,
  output logic invalid_o
);
  import dvbench_sigmoid_math::*;
  logic [44:0] tokens;
  logic [32:0] predictions[0:44];
  always @(posedge clk_i) begin : advance
    predictions[0]<=evaluate(data_i,invalid_i);
    for(int k=1;k<=44;k++) predictions[k]<=predictions[k-1];
    if(rst_i || clear_i) tokens<='0;
    else tokens<={tokens[43:0],valid_i};
  end
  assign valid_o=tokens[44];
  assign result_o=predictions[44][31:0];
  assign invalid_o=predictions[44][32];
endmodule
