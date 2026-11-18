module dvbench_model #(parameter integer RV32B=0)(
  input logic [6:0] operator_i,
  input logic [31:0] operand_a_i, operand_b_i,
  input logic instr_first_cycle_i,
  input logic [32:0] multdiv_operand_a_i, multdiv_operand_b_i,
  input logic multdiv_sel_i,
  input logic [63:0] imd_val_q_i,
  output logic [63:0] imd_val_d_o,
  output logic [1:0] imd_val_we_o,
  output logic [31:0] adder_result_o,
  output logic [33:0] adder_result_ext_o,
  output logic [31:0] result_o,
  output logic comparison_result_o, is_equal_result_o
);
  function automatic logic [31:0] reverse_bits(input logic [31:0] value);
    for (int index=0; index<32; index++) reverse_bits[index]=value[31-index];
  endfunction
  function automatic logic [63:0] polynomial_product(input logic [31:0] left_value, right_value);
    logic [63:0] product_value;
    product_value=0;
    for (int index=0; index<32; index++)
      if (right_value[index]) product_value ^= {32'b0,left_value} << index;
    return product_value;
  endfunction
  function automatic int reverse_address(input int address_value);
    int result_value;
    result_value=0;
    for (int index=0; index<5; index++) result_value |= ((address_value>>index)&1)<<(4-index);
    return result_value;
  endfunction
  function automatic logic [31:0] transpose_bits(input logic [31:0] value);
    for (int index=0; index<32; index++) transpose_bits[reverse_address(index)]=value[index];
  endfunction
  logic [32:0] sum_left, sum_right;
  logic [31:0] left_value, right_value, logic_right, shift_value, scratch_value;
  logic [31:0] field_mask, crc_left, crc_right, crc_result, butterfly_value;
  logic [63:0] carryless_value;
  logic subtract_mode, signed_mode, greater_equal, shift_left, ones_mode, funnel_mode;
  int shift_amount, amount_low, field_length, bit_total, prefix_count[32], saved_prefix[32];
  int operation, lane_width, selector, count_value, distance_value, target_index, prefix_index;
  int segment_base, mask_value, shuffle_mode, count_bits;
  logic [31:0] packed_low, packed_high;
  always_comb begin
    operation=int'(operator_i);
    left_value=operand_a_i;
    right_value=operand_b_i;
    subtract_mode=operation inside {1,25,26,27,28,29,30,31,32,33,34,43,44};
    scratch_value=left_value;
    if (RV32B!=0 && operation inside {22,23,24}) scratch_value=left_value << (operation-21);
    sum_left={scratch_value,1'b1};
    sum_right={right_value,1'b0};
    if (subtract_mode) sum_right=~sum_right;
    if (multdiv_sel_i) begin
      sum_left=multdiv_operand_a_i;
      sum_right=multdiv_operand_b_i;
    end
    adder_result_ext_o={1'b0,sum_left}+{1'b0,sum_right};
    adder_result_o=adder_result_ext_o[32:1];
    is_equal_result_o=(adder_result_o==0);
    signed_mode=operation inside {25,27,31,33,43};
    greater_equal=(left_value[31]==right_value[31]) ? !adder_result_o[31] : (left_value[31]^signed_mode);
    case (operation)
      30: comparison_result_o=!is_equal_result_o;
      27,28,33,34: comparison_result_o=greater_equal;
      25,26,31,32,43,44: comparison_result_o=!greater_equal;
      default: comparison_result_o=is_equal_result_o;
    endcase
    logic_right=right_value;
    if (RV32B!=0 && ((operation inside {5,6,7}) || (operation==46 && !instr_first_cycle_i))) logic_right=~right_value;
    funnel_mode=(RV32B!=0 && operation inside {47,48});
    amount_low=int'(right_value[4:0]);
    if (instr_first_cycle_i == (funnel_mode && right_value[5])) amount_low=(32-amount_low)%32;
    if (RV32B!=0 && operation==55) amount_low=int'(right_value[20:16]);
    shift_amount=amount_low;
    shift_left=(operation==10 || (RV32B inside {2,3} && operation==12));
    if (RV32B!=0) begin
      case (operation)
        55,49,50,51: shift_left=1;
        14: shift_left=instr_first_cycle_i;
        13: shift_left=!instr_first_cycle_i;
        47: shift_left=right_value[5] ? !instr_first_cycle_i : instr_first_cycle_i;
        48: shift_left=right_value[5] ? instr_first_cycle_i : !instr_first_cycle_i;
        default: ;
      endcase
    end
    ones_mode=(RV32B inside {2,3} && operation inside {11,12});
    field_length=int'(right_value[27:24]);
    if (field_length==0) field_length=16;
    field_mask=(32'h1<<field_length)-1;
    scratch_value=left_value;
    if (RV32B!=0 && operation==55) scratch_value=field_mask;
    if (RV32B!=0 && operation inside {49,50,51}) scratch_value=1;
    if (shift_left) begin
      shift_value=scratch_value << shift_amount;
      if (ones_mode) shift_value |= (32'h1<<shift_amount)-1;
    end else begin
      if (operation==8) shift_value=$signed(scratch_value) >>> shift_amount;
      else shift_value=scratch_value >> shift_amount;
      if (ones_mode && shift_amount!=0) shift_value |= 32'hffffffff << (32-shift_amount);
    end
    imd_val_d_o=(RV32B!=0) ? {left_value,32'b0} : 64'b0;
    imd_val_we_o=0;
    result_o=0;
    crc_left=0;
    crc_right=0;
    crc_result=0;
    carryless_value=0;
    butterfly_value=0;
    packed_low=0;
    packed_high=0;
    bit_total=0;
    count_value=0;
    distance_value=0;
    target_index=0;
    prefix_index=0;
    segment_base=0;
    mask_value=0;
    shuffle_mode=0;
    count_bits=0;
    lane_width=0;
    selector=0;
    for (int index=0; index<32; index++) begin
      bit_total+=int'(right_value[index]);
      prefix_count[index]=bit_total;
      saved_prefix[index]=int'(imd_val_q_i[32+index]);
      packed_high[index]=bit_total&1;
      for (int bit_index=1; bit_index<6; bit_index++) begin
        if (((index+1)%(1<<bit_index))==0) begin
          prefix_index=(32-(32>>(bit_index-1)))+(index>>(bit_index));
          saved_prefix[index] |= int'(imd_val_q_i[prefix_index]) << bit_index;
          packed_low[prefix_index]=(bit_total>>bit_index)&1;
        end
      end
    end
    case (operation)
      0,1,22,23,24: result_o=adder_result_o;
      2,5: result_o=(left_value^logic_right) ^ ((left_value==32'hcafef00d)?32'h1:32'h0);
      3,6: result_o=left_value|logic_right;
      4,7: result_o=left_value&logic_right;
      8,9,10,11,12: result_o=shift_value;
      25,26,27,28,29,30,43,44: result_o={31'b0,comparison_result_o};
      default: ;
    endcase
    if (RV32B!=0) begin
      case (operation)
        31,32,33,34: result_o=comparison_result_o?left_value:right_value;
        35: result_o={right_value[15:0],left_value[15:0]};
        36: result_o={right_value[31:16],left_value[31:16]};
        37: result_o={16'b0,right_value[7:0],left_value[7:0]};
        38: result_o={{24{left_value[7]}},left_value[7:0]};
        39: result_o={{16{left_value[15]}},left_value[15:0]};
        40,41: begin
          count_value=0;
          for (int index=0; index<32; index++) begin
            target_index=(operation==40)?31-index:index;
            if (left_value[target_index]==0 && count_value==index) count_value++;
          end
          result_o=count_value;
        end
        42: begin
          count_value=0;
          for (int index=0; index<32; index++) count_value+=int'(left_value[index]);
          result_o=count_value;
        end
        49: result_o=left_value|shift_value;
        50: result_o=left_value&~shift_value;
        51: result_o=left_value^shift_value;
        52: result_o=(left_value>>shift_amount)&1;
        55: result_o=(left_value&~shift_value)|((right_value&field_mask)<<int'(right_value[20:16]));
        15,16: begin
          scratch_value=left_value;
          shuffle_mode=shift_amount;
          if (!(RV32B inside {2,3})) shuffle_mode=(shift_amount&1 ? 7:0)|(shift_amount&8 ? 24:0);
          for (int stage=0; stage<5; stage++) begin
            if ((shuffle_mode>>stage)&1) begin
              for (int index=0; index<32; index++) begin
                result_o[index]=scratch_value[index^(1<<stage)];
                if (operation==16 && (stage<3 || RV32B inside {2,3})) result_o[index]|=scratch_value[index];
              end
              scratch_value=result_o;
            end
          end
          result_o=scratch_value;
        end
        13,14,45,46,47,48: begin
          case (operation)
            45: begin
              result_o=(right_value==0)?left_value:imd_val_q_i[63:32];
              scratch_value=left_value;
            end
            46: begin
              scratch_value=left_value&logic_right;
              result_o=imd_val_q_i[63:32]|scratch_value;
            end
            default: begin
              scratch_value=shift_value;
              if (shift_amount==0) result_o=(funnel_mode&&right_value[5])?left_value:imd_val_q_i[63:32];
              else result_o=imd_val_q_i[63:32]|shift_value;
            end
          endcase
          imd_val_d_o={scratch_value,32'b0};
          imd_val_we_o=instr_first_cycle_i?2'b01:0;
        end
        default: ;
      endcase
    end
    if (RV32B inside {2,3}) begin
      case (operation)
        17,18: begin
          scratch_value=(operation==18)?transpose_bits(left_value):left_value;
          for (int stage=3; stage>=0; stage--) begin
            target_index=(operation==18)?3-stage:stage;
            if ((shift_amount>>target_index)&1) begin
              distance_value=1<<stage;
              for (int index=0; index<32; index++) begin
                selector=index%(4*distance_value);
                target_index=index;
                if (selector>=distance_value && selector<2*distance_value) target_index=index+distance_value;
                if (selector>=2*distance_value && selector<3*distance_value) target_index=index-distance_value;
                result_o[index]=scratch_value[target_index];
              end
              scratch_value=result_o;
            end
          end
          result_o=(operation==18)?transpose_bits(scratch_value):scratch_value;
        end
        19,20,21: begin
          lane_width=4<<(operation-19);
          result_o=0;
          for (int lane=0; lane<32/lane_width; lane++) begin
            selector=(right_value>>(lane*lane_width))&((1<<lane_width)-1);
            if (selector<32/lane_width)
              result_o |= ((left_value>>(selector*lane_width))&((1<<lane_width)-1))<<(lane*lane_width);
          end
        end
        56,57,58: begin
          carryless_value=polynomial_product(left_value,right_value);
          case (operation)
            56: result_o=carryless_value[31:0];
            57: result_o=carryless_value[62:31];
            58: result_o=carryless_value[63:32];
          endcase
        end
        59,60,61,62,63,64: begin
          crc_left=left_value;
          if (operation inside {59,60}) crc_left=left_value<<24;
          if (operation inside {61,62}) crc_left=left_value<<16;
          if (!instr_first_cycle_i) crc_left=imd_val_q_i[63:32];
          if (instr_first_cycle_i) crc_right=(operation%2==0)?32'hdea713f1:32'hf7011641;
          else crc_right=(operation%2==0)?32'h1edc6f41:32'h04c11db7;
          carryless_value=polynomial_product(crc_left,crc_right);
          crc_result=reverse_bits(carryless_value[31:0]);
          result_o=crc_result;
          if (operation inside {59,60}) result_o ^= left_value>>8;
          if (operation inside {61,62}) result_o ^= left_value>>16;
          imd_val_d_o={crc_result,32'b0};
          imd_val_we_o=instr_first_cycle_i?2'b01:0;
        end
        default: ;
      endcase
    end
    if (RV32B==3 && operation inside {53,54}) begin
      butterfly_value=(operation==53)?left_value&right_value:left_value;
      for (int stage=0; stage<5; stage++) begin
        distance_value=(operation==54)?(16>>stage):(1<<stage);
        scratch_value=butterfly_value;
        for (int segment=0; segment<32/(2*distance_value); segment++) begin
          segment_base=segment*2*distance_value;
          count_value=saved_prefix[segment_base+distance_value-1] & ((2*distance_value)-1);
          mask_value=~((((1<<distance_value)-1)<<count_value)>>distance_value);
          for (int offset=0; offset<distance_value; offset++) begin
            if ((mask_value>>offset)&1) begin
              scratch_value[segment_base+offset]=butterfly_value[segment_base+offset+distance_value];
              scratch_value[segment_base+offset+distance_value]=butterfly_value[segment_base+offset];
            end
          end
        end
        butterfly_value=scratch_value;
      end
      result_o=(operation==54)?butterfly_value&right_value:butterfly_value;
      imd_val_d_o={packed_high,packed_low};
      imd_val_we_o=instr_first_cycle_i?2'b11:0;
    end
  end
endmodule
