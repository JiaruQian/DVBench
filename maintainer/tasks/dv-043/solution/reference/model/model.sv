`timescale 1ns/1ps
module dvbench_model #(
  parameter FPU=0,
  parameter ZFINX=0
)(
  input logic [31:0] instr_i,
  output logic [31:0] instr_o,
  output logic is_compressed_o,
  output logic illegal_instr_o
);

  function automatic logic [31:0] encode_i(integer opcode, destination, function_code, source, immediate);
    return 32'((immediate&4095)<<20)|(32'(source)<<15)|(32'(function_code)<<12)|(32'(destination)<<7)|32'(opcode);
  endfunction
  function automatic logic [31:0] encode_r(integer destination, function_code, source_one, source_two, function_seven);
    return (32'(function_seven)<<25)|(32'(source_two)<<20)|(32'(source_one)<<15)|(32'(function_code)<<12)|(32'(destination)<<7)|32'h33;
  endfunction
  function automatic logic [31:0] encode_s(integer source_one, source_two, immediate);
    return (32'((immediate>>5)&127)<<25)|(32'(source_two)<<20)|(32'(source_one)<<15)|(32'd2<<12)|(32'(immediate&31)<<7)|32'h23;
  endfunction
  function automatic logic [31:0] encode_b(integer source_one, function_code, immediate);
    return (32'((immediate>>12)&1)<<31)|(32'((immediate>>5)&63)<<25)|(32'(source_one)<<15)|(32'(function_code)<<12)|(32'((immediate>>1)&15)<<8)|(32'((immediate>>11)&1)<<7)|32'h63;
  endfunction
  function automatic logic [31:0] encode_j(integer destination, immediate);
    return (32'((immediate>>20)&1)<<31)|(32'((immediate>>1)&1023)<<21)|(32'((immediate>>11)&1)<<20)|(32'((immediate>>12)&255)<<12)|(32'(destination)<<7)|32'h6f;
  endfunction
  always_comb begin : expand_instruction
    logic [15:0] compressed;
    integer destination, source_one, source_two, immediate, function_code, operation;
    compressed=instr_i[15:0]; destination=integer'(compressed[11:7]); source_one=8+integer'(compressed[9:7]); source_two=8+integer'(compressed[4:2]);
    immediate=integer'($signed({compressed[12],compressed[6:2]})); function_code=integer'(compressed[15:13]); operation=integer'(compressed[11:10]);
    instr_o=0; illegal_instr_o=0; is_compressed_o=(compressed[1:0]!=3);
    case(compressed[1:0])
      0: begin
        case(function_code)
          0: begin
            immediate=(integer'(compressed[10:7])<<6)|(integer'(compressed[12:11])<<4)|(integer'(compressed[5])<<3)|(integer'(compressed[6])<<2);
            instr_o=encode_i(19,source_two,0,2,immediate); illegal_instr_o=(immediate==0);
          end
          2,6: begin
            immediate=(integer'(compressed[5])<<6)|(integer'(compressed[12:10])<<3)|(integer'(compressed[6])<<2);
            if(function_code==2) instr_o=encode_i(3,source_two,2,source_one,immediate);
            else instr_o=encode_s(source_one,source_two,immediate);
          end
          default: illegal_instr_o=1;
        endcase
      end
      1: begin
        case(function_code)
          0: instr_o=encode_i(19,destination,0,destination,immediate);
          1,5: begin
            immediate=integer'($signed({compressed[12],compressed[8],compressed[10:9],compressed[6],compressed[7],compressed[2],compressed[11],compressed[5:3],1'b0}));
            instr_o=encode_j((function_code==1)?1:0,immediate);
          end
          2: instr_o=encode_i(19,destination,0,0,immediate);
          3: begin
            if(immediate==0) illegal_instr_o=1;
            else if(destination==2) begin
              immediate=integer'($signed({compressed[12],compressed[4:3],compressed[5],compressed[2],compressed[6],4'b0}));
              instr_o=encode_i(19,2,0,2,immediate);
            end else instr_o=(32'(immediate)<<12)|(32'(destination)<<7)|32'h37;
          end
          4: begin
            if(operation<2) begin
              instr_o=encode_i(19,source_one,5,source_one,integer'(compressed[6:2])|((operation==1)?1024:0)); illegal_instr_o=compressed[12];
            end else if(operation==2) instr_o=encode_i(19,source_one,7,source_one,immediate);
            else if(compressed[12]) illegal_instr_o=1;
            else begin
              case(compressed[6:5])
                0: instr_o=encode_r(source_one,0,source_one,source_two,32);
                1: instr_o=encode_r(source_one,4,source_one,source_two,0);
                2: instr_o=encode_r(source_one,6,source_one,source_two,0);
                3: instr_o=encode_r(source_one,7,source_one,source_two,0);
              endcase
            end
          end
          6,7: begin
            immediate=integer'($signed({compressed[12],compressed[6:5],compressed[2],compressed[11:10],compressed[4:3],1'b0}));
            instr_o=encode_b(source_one,function_code-6,immediate);
          end
        endcase
      end
      2: begin
        case(function_code)
          0: begin instr_o=encode_i(19,destination,1,destination,integer'(compressed[6:2])); illegal_instr_o=compressed[12]; end
          2: begin
            immediate=(integer'(compressed[3:2])<<6)|(integer'(compressed[12])<<5)|(integer'(compressed[6:4])<<2);
            instr_o=encode_i(3,destination,2,2,immediate); illegal_instr_o=(destination==0);
          end
          4: begin
            if(compressed[6:2]==0) begin
              if(compressed[12] && destination==0) instr_o=32'h00100073;
              else begin instr_o=encode_i(103,compressed[12]?1:0,0,destination,0); illegal_instr_o=(!compressed[12] && destination==0); end
            end else instr_o=encode_r(destination,0,compressed[12]?destination:0,integer'(compressed[6:2]),0);
          end
          6: begin
            immediate=(integer'(compressed[8:7])<<6)|(integer'(compressed[12:9])<<2);
            instr_o=encode_s(2,integer'(compressed[6:2]),immediate);
          end
          default: illegal_instr_o=1;
        endcase
      end
      3: instr_o=instr_i;
    endcase
  end

endmodule
