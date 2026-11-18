`timescale 1ns/1ps
module dvbench_model #(parameter PROGRAM_FILE="program.mem") (
  input clk,rst,
  input [31:0] input_data,
  output reg result_valid,
  output reg [31:0] result_data
);
  reg [15:0] program_words[0:1023];
  reg [31:0] data_words[0:1023];
  reg signed [31:0] registers[0:7];
  integer fetch_address;
  reg [15:0] decoded_instruction, executing_instruction;
  reg signed [31:0] operand0,operand1,operand2;
  integer retiring_destination;
  reg signed [31:0] retiring_value;
  reg retiring_load,retiring_write;
  reg [31:0] read_value;
  integer index,opcode,destination,address,source0,source1,source2;
  integer target,displacement,condition;
  reg signed [31:0] execution_value,writeback_value,next0,next1,next2;
  reg execution_write,is_load,is_store,is_halt,branch_taken;
  initial begin
    for(index=0;index<1024;index=index+1) program_words[index]=0;
    if(PROGRAM_FILE!="") $readmemh(PROGRAM_FILE,program_words);
    else begin
      program_words[0]=16'h0000;
      program_words[1]=16'h4996;
      program_words[2]=16'h4a64;
      program_words[3]=16'h020a;
      program_words[4]=16'h04c8;
      program_words[5]=16'h071a;
      program_words[6]=16'h0923;
      program_words[7]=16'h0a53;
      program_words[8]=16'h0c9c;
      program_words[9]=16'h10e5;
      program_words[10]=16'h0f03;
      program_words[11]=16'h1364;
      program_words[12]=16'h15a8;
      program_words[13]=16'h1605;
      program_words[14]=16'h4f80;
      program_words[15]=16'h1bd8;
      program_words[16]=16'h19c5;
      program_words[17]=16'h480f;
      program_words[18]=16'h4901;
      program_words[19]=16'h5002;
      program_words[20]=16'h9005;
      program_words[21]=16'h4f80;
      program_words[22]=16'h1bd8;
      program_words[23]=16'h19c5;
      program_words[24]=16'h0a56;
      program_words[25]=16'h0dec;
      program_words[26]=16'h480f;
      program_words[27]=16'h4300;
      program_words[28]=16'h0853;
      program_words[29]=16'h07b6;
      program_words[30]=16'h4e52;
      program_words[31]=16'h16d9;
      program_words[32]=16'h169a;
      program_words[33]=16'h492d;
      program_words[34]=16'h8001;
      program_words[35]=16'h4c14;
      program_words[45]=16'h1b04;
      program_words[46]=16'ha102;
      program_words[63]=16'h0ffe;
      program_words[64]=16'ha045;
      program_words[65]=16'h1057;
      program_words[66]=16'ha386;
      program_words[82]=16'h1885;
      program_words[83]=16'ha3c0;
      program_words[84]=16'h5202;
      program_words[85]=16'ha403;
      program_words[127]=16'h4402;
      program_words[128]=16'ha487;
      program_words[129]=16'ha745;
      program_words[250]=16'h089f;
      program_words[251]=16'ha601;
      program_words[252]=16'h05bd;
      program_words[253]=16'hb05b;
      program_words[280]=16'h0d47;
      program_words[281]=16'hb03f;
      program_words[282]=16'h17cc;
      program_words[283]=16'hb29f;
      program_words[314]=16'h0b2e;
      program_words[315]=16'hb342;
      program_words[316]=16'hb411;
      program_words[333]=16'h12d1;
      program_words[334]=16'hb4c6;
      program_words[335]=16'h15f4;
      program_words[336]=16'hb798;
      program_words[360]=16'h4a15;
      program_words[361]=16'hb631;
      program_words[362]=16'hc000;
    end
  end

  function automatic integer register_index(input [15:0] instruction,input integer operand_number);
    integer operation;
    begin
      operation=instruction>>9;
      register_index=0;
      if(operation>=1 && operation<=10)
        register_index=(instruction>>(6-3*operand_number))&7;
      else if(operation>=11 && operation<=13) begin
        if(operand_number==0) register_index=(instruction>>6)&7;
      end else if(instruction[15:11]==8 || instruction[15:11]==10) begin
        if(operand_number==0) register_index=(instruction>>8)&7;
        if(operand_number==1) register_index=instruction&7;
      end else if(instruction[15:11]==9) begin
        if(operand_number==0) register_index=(instruction>>8)&7;
      end else if(instruction[15:12]==8) begin
        if(operand_number==0) register_index=instruction&7;
      end else if(instruction[15:12]==10 || instruction[15:12]==11) begin
        if(operand_number==0) register_index=(instruction>>6)&7;
        if(operand_number==1 && instruction[15:12]==10) register_index=instruction&7;
      end
    end
  endfunction

  function automatic signed [31:0] forwarded(input integer selected);
    begin
      if(decoded_instruction[15:9]!=0 && selected==destination) forwarded=execution_value;
      else if(decoded_instruction[15:9]!=0 && selected==retiring_destination) forwarded=writeback_value;
      else forwarded=registers[selected];
    end
  endfunction

  always @(posedge clk) begin
    opcode=executing_instruction>>9;
    destination=0;
    execution_value=0;
    execution_write=0;
    is_load=0;
    is_store=0;
    is_halt=executing_instruction[15:12]==12;
    branch_taken=0;
    address=0;
    target=0;
    if(opcode>=1 && opcode<=13) begin
      destination=(executing_instruction>>6)&7;
      execution_write=1;
      case(opcode)
        1,2: execution_value=operand1+operand2;
        3,4: execution_value=operand1-operand2;
        5: execution_value=operand1&operand2;
        6: execution_value=operand1|operand2;
        7: execution_value=operand1^operand2;
        8: execution_value=~(operand1&operand2);
        9: execution_value=~(operand1|operand2);
        10: execution_value=~(operand1^operand2);
        11: execution_value=$unsigned(operand0)>>(executing_instruction&63);
        12: execution_value=operand0>>>(executing_instruction&63);
        13: execution_value=operand0<<(executing_instruction&63);
      endcase
    end else if(executing_instruction[15:11]==9) begin
      destination=(executing_instruction>>8)&7;
      execution_value={operand0[31:8],executing_instruction[7:0]};
      execution_write=1;
    end else if(executing_instruction[15:11]==8) begin
      destination=(executing_instruction>>8)&7;
      address=operand1&1023;
      is_load=1;
      execution_write=1;
    end else if(executing_instruction[15:11]==10) begin
      address=operand0&1023;
      is_store=1;
    end else if(executing_instruction[15:12]>=8 && executing_instruction[15:12]<=11) begin
      condition=(executing_instruction>>9)&7;
      branch_taken=executing_instruction[15:12]<10;
      if(executing_instruction[15:12]>=10)
        case(condition)
          0: branch_taken=operand0<0;
          1: branch_taken=operand0>=0;
          2: branch_taken=operand0==0;
          3: branch_taken=operand0!=0;
          default: branch_taken=0;
        endcase
      displacement=$signed(executing_instruction[5:0]);
      if(executing_instruction[12]) target=(fetch_address+displacement-2)&1023;
      else if(executing_instruction[15:12]==8) target=operand0&1023;
      else target=operand1&1023;
    end
    writeback_value=retiring_write ? (retiring_load ? read_value : retiring_value) : 0;
    next0=forwarded(register_index(decoded_instruction,0));
    next1=forwarded(register_index(decoded_instruction,1));
    next2=forwarded(register_index(decoded_instruction,2));
    if(is_load) begin
      if(address==1022) read_value<=input_data;
      else if(address==1023) read_value<=result_data;
      else read_value<=data_words[address];
    end else if(is_store && rst && address<1022) data_words[address]<=operand1;
    if(!rst) begin
      fetch_address<=0;
      decoded_instruction<=0;
      executing_instruction<=0;
      operand0<=0; operand1<=0; operand2<=0;
      retiring_destination<=0;
      retiring_value<=0;
      retiring_load<=0;
      retiring_write<=0;
      for(index=0;index<8;index=index+1) registers[index]<=0;
      result_valid<=0;
      result_data<=0;
    end else begin
      registers[retiring_destination]<=writeback_value;
      result_valid<=is_store && address==1023;
      if(is_store && address==1023) result_data<=operand1;
      if(!is_halt) begin
        retiring_destination<=destination;
        retiring_value<=execution_value;
        retiring_load<=is_load;
        retiring_write<=execution_write;
        if(!is_load) begin
          fetch_address<=branch_taken ? target : (fetch_address+1)&1023;
          decoded_instruction<=branch_taken ? 0 : program_words[fetch_address];
        end
        executing_instruction<=is_load || branch_taken ? 0 : decoded_instruction;
        operand0<=is_load || branch_taken ? 0 : next0;
        operand1<=is_load || branch_taken ? 0 : next1;
        operand2<=is_load || branch_taken ? 0 : next2;
      end
    end
  end
endmodule
