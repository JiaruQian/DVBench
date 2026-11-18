module dvbench_elastic #(parameter integer WIDTH=32, DEPTH=1, CAPACITY=1)(
  input logic clk, reset,
  input logic [WIDTH-1:0] input_data,
  input logic input_last, input_valid,
  output logic input_ready,
  output logic [WIDTH-1:0] output_data,
  output logic output_last, output_valid,
  input logic output_ready
);
  generate
    if (CAPACITY==2) begin: buffered_queue
      logic [WIDTH:0] entries[2];
      logic read_index, write_index;
      integer occupancy;
      always_comb begin
        input_ready=occupancy<2;
        output_valid=occupancy!=0;
        {output_last,output_data}=entries[read_index];
      end
      always @(posedge clk) begin
        if (reset) begin
          occupancy<=0;
          read_index<=0;
          write_index<=0;
        end
        else begin
          occupancy<=occupancy+int'(input_ready&&input_valid)-int'(output_valid&&output_ready);
          if (input_ready && input_valid) begin
            entries[write_index]<={input_last,input_data};
            write_index<=!write_index;
          end
          if (output_valid && output_ready) read_index<=!read_index;
        end
      end
    end else begin: staged_tokens
      logic [WIDTH:0] tokens[DEPTH];
      logic [DEPTH-1:0] occupied, advance;
      always_comb begin
        for (int stage=DEPTH-1; stage>=0; stage--) begin
          if (stage==DEPTH-1) advance[stage]=!occupied[stage]||output_ready;
          else advance[stage]=!occupied[stage]||advance[stage+1];
        end
        input_ready=advance[0];
        output_valid=occupied[DEPTH-1];
        {output_last,output_data}=tokens[DEPTH-1];
      end
      always @(posedge clk) begin
        for (int stage=0; stage<DEPTH; stage++) begin
          if (reset) begin
            occupied[stage]<=0;
            tokens[stage]<=0;
          end else if (advance[stage]) begin
            occupied[stage]<=(stage==0)?input_valid:occupied[stage-1];
            tokens[stage]<=(stage==0)?{input_last,input_data}:tokens[stage-1];
          end
        end
      end
    end
  endgenerate
endmodule

module dvbench_model #(
  parameter integer WIDTH_A=16, WIDTH_B=16, WIDTH_P=32, DROP_TOP_P=1,
  LATENCY=3, EN_SATURATE=0, EN_ROUND=0, SIGNED=1
)(
  input logic clk, reset,
  input logic [WIDTH_A-1:0] a_tdata,
  input logic a_tlast, a_tvalid,
  output logic a_tready,
  input logic [WIDTH_B-1:0] b_tdata,
  input logic b_tlast, b_tvalid,
  output logic b_tready,
  output logic [WIDTH_P-1:0] p_tdata,
  output logic p_tlast, p_tvalid,
  input logic p_tready
);
  localparam integer PRODUCT_WIDTH=WIDTH_A+WIDTH_B;
  localparam integer INPUT_STAGES=(LATENCY inside {1,2})?1:2;
  localparam integer PRODUCT_STAGES=(LATENCY inside {2,3})?1:2;
  localparam integer REDUCED_WIDTH=PRODUCT_WIDTH-DROP_TOP_P;
  localparam integer COMBINED_WIDTH=WIDTH_P+DROP_TOP_P+((DROP_TOP_P!=0)?1:0);
  logic [WIDTH_A-1:0] buffered_a;
  logic [WIDTH_B-1:0] buffered_b;
  logic a_last, b_last, a_valid, b_valid, join_ready, join_valid;
  logic [PRODUCT_WIDTH-1:0] product_input, buffered_product, selected_product;
  logic product_last, product_valid, product_ready;
  logic [63:0] conversion_input, converted_data, middle_data;
  logic middle_last, middle_valid, middle_ready;
  function automatic logic [63:0] rounded_value(input logic [63:0] value, input int input_width, output_width, input bit safe_round);
    logic [63:0] sliced_value, mask_value;
    int drop_count;
    bit correction;
    drop_count=input_width-output_width;
    sliced_value=value>>drop_count;
    correction=drop_count>0 ? value[drop_count-1]:0;
    mask_value=(64'h1<<(output_width-1))-1;
    if (safe_round && drop_count>1 && !value[input_width-1] && (sliced_value&mask_value)==mask_value) correction=0;
    return (sliced_value+int'(correction))&((64'h1<<output_width)-1);
  endfunction
  function automatic logic [63:0] clipped_value(input logic [63:0] value, input int input_width, output_width);
    logic signed [63:0] signed_value, maximum_value, minimum_value;
    signed_value=$signed(value << (64-input_width)) >>> (64-input_width);
    maximum_value=(64'sh1<<(output_width-1))-1;
    minimum_value=-(64'sh1<<(output_width-1));
    if (signed_value>maximum_value) return maximum_value;
    if (signed_value<minimum_value) return minimum_value & ((64'h1<<output_width)-1);
    return value & ((64'h1<<output_width)-1);
  endfunction
  dvbench_elastic #(.WIDTH(WIDTH_A),.DEPTH(INPUT_STAGES)) input_a(
    .clk,.reset,.input_data(a_tdata),.input_last(a_tlast),.input_valid(a_tvalid),.input_ready(a_tready),
    .output_data(buffered_a),.output_last(a_last),.output_valid(a_valid),.output_ready(join_ready&&b_valid));
  dvbench_elastic #(.WIDTH(WIDTH_B),.DEPTH(INPUT_STAGES)) input_b(
    .clk,.reset,.input_data(b_tdata),.input_last(b_tlast),.input_valid(b_tvalid),.input_ready(b_tready),
    .output_data(buffered_b),.output_last(b_last),.output_valid(b_valid),.output_ready(join_ready&&a_valid));
  always_comb begin
    if (LATENCY==0) begin
      if (SIGNED) product_input=$signed(a_tdata)*$signed(b_tdata);
      else product_input=a_tdata*b_tdata;
    end else begin
      if (SIGNED) product_input=$signed(buffered_a)*$signed(buffered_b);
      else product_input=buffered_a*buffered_b;
    end
    join_valid=a_valid&&b_valid;
    selected_product=(LATENCY==0)?product_input:buffered_product;
    conversion_input=64'(selected_product);
    if (EN_ROUND && EN_SATURATE) begin
      if (DROP_TOP_P!=0 && selected_product[PRODUCT_WIDTH-1]) conversion_input|=(64'h1<<PRODUCT_WIDTH);
      if (PRODUCT_WIDTH==WIDTH_P+DROP_TOP_P) converted_data=conversion_input;
      else converted_data=rounded_value(conversion_input,PRODUCT_WIDTH+((DROP_TOP_P!=0)?1:0),COMBINED_WIDTH,DROP_TOP_P==0);
    end else if (EN_ROUND) converted_data=rounded_value(conversion_input&((64'h1<<REDUCED_WIDTH)-1),REDUCED_WIDTH,WIDTH_P,1);
    else if (EN_SATURATE) converted_data=clipped_value(conversion_input,PRODUCT_WIDTH,REDUCED_WIDTH)>>(REDUCED_WIDTH-WIDTH_P);
    else converted_data=conversion_input>>(REDUCED_WIDTH-WIDTH_P);
  end
  dvbench_elastic #(.WIDTH(PRODUCT_WIDTH),.DEPTH(PRODUCT_STAGES)) product_tokens(
    .clk,.reset,.input_data(product_input),.input_last(a_last||b_last),.input_valid(join_valid),.input_ready(join_ready),
    .output_data(buffered_product),.output_last(product_last),.output_valid(product_valid),.output_ready(product_ready));
  generate
    if (EN_ROUND && EN_SATURATE) begin: rounded_clipped
      if (PRODUCT_WIDTH!=WIDTH_P+DROP_TOP_P) begin: round_stage
        dvbench_elastic #(.WIDTH(64),.CAPACITY(2)) rounded_tokens(
          .clk,.reset,.input_data(converted_data),.input_last(product_last),.input_valid(product_valid),.input_ready(product_ready),
          .output_data(middle_data),.output_last(middle_last),.output_valid(middle_valid),.output_ready(middle_ready));
      end else begin: round_bypass
        assign middle_data=converted_data;
        assign middle_last=product_last;
        assign middle_valid=product_valid;
        assign product_ready=middle_ready;
      end
      if (DROP_TOP_P!=0) begin: clip_stage
        logic [WIDTH_P-1:0] clipped_data;
        always_comb clipped_data=WIDTH_P'(clipped_value(middle_data,COMBINED_WIDTH,WIDTH_P));
        dvbench_elastic #(.WIDTH(WIDTH_P),.CAPACITY(2)) clipped_tokens(
          .clk,.reset,.input_data(clipped_data),.input_last(middle_last),.input_valid(middle_valid),.input_ready(middle_ready),
          .output_data(p_tdata),.output_last(p_tlast),.output_valid(p_tvalid),.output_ready(p_tready));
      end else begin: clip_bypass
        assign p_tdata=middle_data[WIDTH_P-1:0];
        assign p_tlast=middle_last;
        assign p_tvalid=middle_valid;
        assign middle_ready=p_tready;
      end
    end else if ((EN_ROUND && REDUCED_WIDTH!=WIDTH_P) || (EN_SATURATE && DROP_TOP_P!=0)) begin: conversion_stage
      dvbench_elastic #(.WIDTH(WIDTH_P)) converted_tokens(
        .clk,.reset,.input_data(converted_data[WIDTH_P-1:0]),.input_last(product_last),.input_valid(product_valid),.input_ready(product_ready),
        .output_data(p_tdata),.output_last(p_tlast),.output_valid(p_tvalid),.output_ready(p_tready));
    end else begin: conversion_bypass
      assign p_tdata=converted_data[WIDTH_P-1:0];
      assign p_tlast=product_last;
      assign p_tvalid=product_valid;
      assign product_ready=p_tready;
    end
  endgenerate
endmodule
