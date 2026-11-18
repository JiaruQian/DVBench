`timescale 1ns/1ps
module dvbench_model(
  input logic clk,
  input logic rst_n,
  input logic des_encipher_en,
  input logic des_decipher_en,
  input logic [63:0] des_data,
  input logic [63:0] des_key_in,
  output logic desc_ready,
  output logic [63:0] desc_result
);
  int IPT [64] = '{
    58,50,42,34,26,18,10, 2,60,52,44,36,28,20,12, 4,
    62,54,46,38,30,22,14, 6,64,56,48,40,32,24,16, 8,
    57,49,41,33,25,17, 9, 1,59,51,43,35,27,19,11, 3,
    61,53,45,37,29,21,13, 5,63,55,47,39,31,23,15, 7};

  int IP1T [64] = '{
    40, 8,48,16,56,24,64,32,39, 7,47,15,55,23,63,31,
    38, 6,46,14,54,22,62,30,37, 5,45,13,53,21,61,29,
    36, 4,44,12,52,20,60,28,35, 3,43,11,51,19,59,27,
    34, 2,42,10,50,18,58,26,33, 1,41, 9,49,17,57,25};

  int ET [48] = '{
    32, 1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 9,
     8, 9,10,11,12,13,12,13,14,15,16,17,
    16,17,18,19,20,21,20,21,22,23,24,25,
    24,25,26,27,28,29,28,29,30,31,32, 1};

  int PT [32] = '{
    16, 7,20,21,29,12,28,17, 1,15,23,26, 5,18,31,10,
     2, 8,24,14,32,27, 3, 9,19,13,30, 6,22,11, 4,25};

  int PC1T [56] = '{
    57,49,41,33,25,17, 9, 1,58,50,42,34,26,18,
    10, 2,59,51,43,35,27,19,11, 3,60,52,44,36,
    63,55,47,39,31,23,15, 7,62,54,46,38,30,22,
    14, 6,61,53,45,37,29,21,13, 5,28,20,12, 4};

  int PC2T [48] = '{
    14,17,11,24, 1, 5, 3,28,15, 6,21,10,
    23,19,12, 4,26, 8,16, 7,27,20,13, 2,
    41,52,31,37,47,55,30,40,51,45,33,48,
    44,49,39,56,34,53,46,42,50,36,29,32};

  int SH_T [16] = '{1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1};

  bit [3:0] SB1 [4][16] = '{
    '{14, 4,13, 1, 2,15,11, 8, 3,10, 6,12, 5, 9, 0, 7},
    '{ 0,15, 7, 4,14, 2,13, 1,10, 6,12,11, 9, 5, 3, 8},
    '{ 4, 1,14, 8,13, 6, 2,11,15,12, 9, 7, 3,10, 5, 0},
    '{15,12, 8, 2, 4, 9, 1, 7, 5,11, 3,14,10, 0, 6,13}};
  bit [3:0] SB2 [4][16] = '{
    '{15, 1, 8,14, 6,11, 3, 4, 9, 7, 2,13,12, 0, 5,10},
    '{ 3,13, 4, 7,15, 2, 8,14,12, 0, 1,10, 6, 9,11, 5},
    '{ 0,14, 7,11,10, 4,13, 1, 5, 8,12, 6, 9, 3, 2,15},
    '{13, 8,10, 1, 3,15, 4, 2,11, 6, 7,12, 0, 5,14, 9}};
  bit [3:0] SB3 [4][16] = '{
    '{10, 0, 9,14, 6, 3,15, 5, 1,13,12, 7,11, 4, 2, 8},
    '{13, 7, 0, 9, 3, 4, 6,10, 2, 8, 5,14,12,11,15, 1},
    '{13, 6, 4, 9, 8,15, 3, 0,11, 1, 2,12, 5,10,14, 7},
    '{ 1,10,13, 0, 6, 9, 8, 7, 4,15,14, 3,11, 5, 2,12}};
  bit [3:0] SB4 [4][16] = '{
    '{ 7,13,14, 3, 0, 6, 9,10, 1, 2, 8, 5,11,12, 4,15},
    '{13, 8,11, 5, 6,15, 0, 3, 4, 7, 2,12, 1,10,14, 9},
    '{10, 6, 9, 0,12,11, 7,13,15, 1, 3,14, 5, 2, 8, 4},
    '{ 3,15, 0, 6,10, 1,13, 8, 9, 4, 5,11,12, 7, 2,14}};
  bit [3:0] SB5 [4][16] = '{
    '{ 2,12, 4, 1, 7,10,11, 6, 8, 5, 3,15,13, 0,14, 9},
    '{14,11, 2,12, 4, 7,13, 1, 5, 0,15,10, 3, 9, 8, 6},
    '{ 4, 2, 1,11,10,13, 7, 8,15, 9,12, 5, 6, 3, 0,14},
    '{11, 8,12, 7, 1,14, 2,13, 6,15, 0, 9,10, 4, 5, 3}};
  bit [3:0] SB6 [4][16] = '{
    '{12, 1,10,15, 9, 2, 6, 8, 0,13, 3, 4,14, 7, 5,11},
    '{10,15, 4, 2, 7,12, 9, 5, 6, 1,13,14, 0,11, 3, 8},
    '{ 9,14,15, 5, 2, 8,12, 3, 7, 0, 4,10, 1,13,11, 6},
    '{ 4, 3, 2,12, 9, 5,15,10,11,14, 1, 7, 6, 0, 8,13}};
  bit [3:0] SB7 [4][16] = '{
    '{ 4,11, 2,14,15, 0, 8,13, 3,12, 9, 7, 5,10, 6, 1},
    '{13, 0,11, 7, 4, 9, 1,10,14, 3, 5,12, 2,15, 8, 6},
    '{ 1, 4,11,13,12, 3, 7,14,10,15, 6, 8, 0, 5, 9, 2},
    '{ 6,11,13, 8, 1, 4,10, 7, 9, 5, 0,15,14, 2, 3,12}};
  bit [3:0] SB8 [4][16] = '{
    '{13, 2, 8, 4, 6,15,11, 1,10, 9, 3,14, 5, 0,12, 7},
    '{ 1,15,13, 8,10, 3, 7, 4,12, 5, 6,11, 0,14, 9, 2},
    '{ 7,11, 4, 1, 9,12,14, 2, 0, 6,10,13,15, 3, 5, 8},
    '{ 2, 1,14, 7, 4,10, 8,13,15,12, 9, 0, 3, 5, 6,11}};

  
  function automatic bit [63:0] perm_l(bit [63:0] value, int table_values[], int count);
    bit [63:0] round_index;
    round_index = '0;
    for (int bit_index = 0; bit_index < count; bit_index++) round_index[count-1-bit_index] = value[64-table_values[bit_index]];
    return round_index;
  endfunction

  function automatic bit [27:0] rol28(bit [27:0] value, int sh);
    return (value << sh) | (value >> (28 - sh));
  endfunction

  function automatic bit [3:0] slookup(int box_number, bit [5:0] six_bits);
    int row, col;
    row = {six_bits[5], six_bits[0]};
    col = six_bits[4:1];
    case (box_number)
      0: slookup = SB1[row][col];
      1: slookup = SB2[row][col];
      2: slookup = SB3[row][col];
      3: slookup = SB4[row][col];
      4: slookup = SB5[row][col];
      5: slookup = SB6[row][col];
      6: slookup = SB7[row][col];
      7: slookup = SB8[row][col];
    endcase
  endfunction

  function automatic bit [63:0] des_model(bit [63:0] data, bit [63:0] key, bit enc);
    bit [27:0] key_left, key_right;
    bit [47:0] KS [0:15];
    bit [31:0] block_left, block_right;
    bit [63:0] permuted;
    bit [47:0] ex;
    bit [31:0] s32;
    bit [3:0] so [0:7];
    permuted = perm_l(key, PC1T, 56);
    key_left = permuted[55:28]; key_right = permuted[27:0];
    for (int round_index = 0; round_index < 16; round_index++) begin
      int sh = SH_T[round_index];
      key_left = rol28(key_left, sh);
      key_right = rol28(key_right, sh);
      KS[round_index] = perm_l({key_left, key_right, 8'b0}, PC2T, 48);
    end
    permuted = perm_l(data, IPT, 64);
    block_left = permuted[63:32]; block_right = permuted[31:0];
    for (int round_index = 0; round_index < 16; round_index++) begin
      bit [47:0] subkey;
      subkey = enc ? KS[round_index] : KS[15-round_index];
      ex = perm_l({block_right, 32'b0}, ET, 48) ^ subkey;
      for (int box_index = 0; box_index < 8; box_index++)
        so[box_index] = slookup(box_index, ex[47-6*box_index -: 6]);
      s32 = perm_l({so[0],so[1],so[2],so[3],so[4],so[5],so[6],so[7], 32'b0}, PT, 32);
      {block_left, block_right} = {block_right, block_left ^ s32};
    end
    return perm_l({block_right, block_left}, IP1T, 64);
  endfunction


  integer age;
  bit operation_active, encrypting;
  logic [63:0] pending_result;
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin age=0; operation_active=0; desc_ready<=1; end
    else if(!operation_active && (des_encipher_en || des_decipher_en)) begin
      operation_active=1; encrypting=des_encipher_en; age=1; desc_ready<=0;
      pending_result=des_model(des_data,des_key_in,des_encipher_en);
    end else if(operation_active) begin
      age=age+1;
      if(age==(encrypting?18:33)) begin desc_ready<=1; desc_result<=pending_result; operation_active=0; end
    end
  end

endmodule
