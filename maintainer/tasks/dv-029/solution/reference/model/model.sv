`timescale 1ns/1ps
module dvbench_model #()(output logic [31:0] ClutCacheData,
output logic ClutCacheWrite,
output logic [2:0] ClutWriteIndex,
output logic [63:0] TexCacheData,
output logic TexCacheWrite,
input logic ack_i,
input logic [14:0] adrClutCacheUpdate,
input logic [16:0] adrTexCacheUpdateL,
input logic [16:0] adrTexCacheUpdateR,
output logic [16:0] adrTexCacheWrite,
output logic [19:0] adr_o,
output logic [2:0] cnt_o,
input logic [31:0] dat_i,
output logic [31:0] dat_o,
input logic [255:0] exportedBGBlock,
input logic [15:0] exportedMSKBGBlock,
output wire fifoComplete,
output wire fifoFull,
input logic gpuClk,
input logic i_nRst,
output logic importBGBlockSingleClock,
output logic [255:0] importedBGBlock,
input logic isBlending,
input logic [14:0] loadAdr,
input logic [55:0] memoryWriteCommand,
output logic req_o,
input logic requClutCacheUpdate,
input logic requTexCacheUpdateL,
input logic requTexCacheUpdateR,
output logic resetMask,
output logic resetPipelinePixelStateSpike,
input logic [14:0] saveAdr,
input logic [1:0] saveBGBlock,
output logic saveLoadOnGoing,
output logic [3:0] sel_o,
output logic updateClutCacheComplete,
output logic updateTexCacheCompleteL,
output logic updateTexCacheCompleteR,
output logic wrt_o);
assign fifoFull=1'bz;assign fifoComplete=1'bz;
integer operation=0,position=0,selected_bank=0,rotation=0,pair_id=0;
logic previous_bg=0,busy=0,texture_right=0;
logic [17:0] base_word;
logic [31:0] first_texture_word,colors;
logic [1:0] color_mask,clear_banks;
logic [15:0] stencil;
logic force_mask,check_mask;
logic [15:0] pixels[0:31];
logic [31:0] pixel_mask;
logic [255:0] background;
integer index_pipe=0;
logic cache_write_pipe=0;
integer choice,next_operation,source_pixel;
logic [19:0] requested_address;
logic [1:0] selected_pixels;
logic [31:0] write_word;
always @* begin
  choice=0;requested_address=0;
  if(operation==0 && !ack_i) begin
    if(memoryWriteCommand[2:0]!=0) begin choice=memoryWriteCommand[2:0];requested_address={memoryWriteCommand[21:7],5'b0};end
    else if((saveBGBlock!=0)&&!previous_bg&&(saveBGBlock[1]||(saveBGBlock==1&&isBlending))) choice=(saveBGBlock==1&&isBlending) ? 8 : 7;
    else if(requClutCacheUpdate) begin choice=5;requested_address={adrClutCacheUpdate,5'b0};end
    else if(requTexCacheUpdateL||requTexCacheUpdateR) begin choice=6;requested_address=(requTexCacheUpdateL ? adrTexCacheUpdateL : adrTexCacheUpdateR)<<3;end
  end
  next_operation=operation;
  req_o=0;adr_o=0;cnt_o=0;wrt_o=0;
  TexCacheWrite=0;updateTexCacheCompleteL=0;updateTexCacheCompleteR=0;updateClutCacheComplete=0;
  importBGBlockSingleClock=0;resetMask=0;resetPipelinePixelStateSpike=0;
  saveLoadOnGoing=busy;importedBGBlock=background;
  ClutCacheData=dat_i;ClutCacheWrite=cache_write_pipe;ClutWriteIndex=index_pipe%8;
  TexCacheData={dat_i,first_texture_word};adrTexCacheWrite=base_word>>1;
  write_word=exportedBGBlock[(position%8)*32 +:32];selected_pixels=exportedMSKBGBlock[(position%8)*2 +:2];
  if(operation==1 || operation==2) begin write_word=colors;selected_pixels=color_mask;end
  if(operation==4) begin
    source_pixel=(selected_bank*16+rotation+(position%8)*2)%32;
    write_word={pixels[(source_pixel+1)%32],pixels[source_pixel]};
    if(force_mask) begin write_word[15]=1;write_word[31]=1;end
    selected_pixels[0]=pixel_mask[source_pixel]&&(!check_mask||!stencil[(position%8)*2]);
    selected_pixels[1]=pixel_mask[(source_pixel+1)%32]&&(!check_mask||!stencil[(position%8)*2+1]);
  end
  dat_o=write_word;sel_o={selected_pixels[1],selected_pixels[1],selected_pixels[0],selected_pixels[0]};
  if(operation==0) begin
    if(choice!=0) begin req_o=1;adr_o=requested_address;cnt_o=(choice==1) ? 0 : (choice==6 ? 1 : 7);end
  end else if(operation==9) begin req_o=1;cnt_o=7;next_operation=8;end
  else if(ack_i) begin
    req_o=1;
    case(operation)
      1:begin adr_o={base_word[17:3],3'b0,2'b0}+pair_id*4;wrt_o=1;end
      2,3,4:begin adr_o={base_word[17:3],5'b0}+(position%8)*4;wrt_o=operation!=3;end
      5:begin adr_o=(adrClutCacheUpdate<<5)+(position%8)*4;updateClutCacheComplete=position%8==7;end
      6:begin
        adr_o=((requTexCacheUpdateL ? adrTexCacheUpdateL : adrTexCacheUpdateR)<<3)+(position%2)*4;
        if(position%8!=0) begin updateTexCacheCompleteL=!texture_right;updateTexCacheCompleteR=texture_right;end
      end
      7:begin adr_o=(saveAdr<<5)+(position%8)*4;wrt_o=1;end
      8:adr_o=(loadAdr<<5)+(position%8)*4;
    endcase
  end else begin
    next_operation=0;
    if(operation==6) TexCacheWrite=1;
    if(operation==7) begin
      resetMask=1;
      if(isBlending&&saveBGBlock!=3) next_operation=9;
      else resetPipelinePixelStateSpike=1;
    end
    if(operation==8) begin importBGBlockSingleClock=1;resetPipelinePixelStateSpike=1;end
  end
end
always @(posedge gpuClk) begin
  previous_bg<=saveBGBlock!=0;
  if(!i_nRst) begin
    operation<=0;position<=0;selected_bank<=0;rotation<=0;clear_banks<=0;stencil<=0;busy<=0;
    cache_write_pipe<=0;index_pipe<=0;
  end else begin
    cache_write_pipe<=operation==5&&ack_i;
    index_pipe<=position;
    if(operation==0) begin
      position<=0;
      if(choice!=0) begin
        operation<=choice;busy<=1;
        if(choice<=6) base_word<=requested_address>>2;
        if(choice<=4) begin
          colors<={(choice==2 ? memoryWriteCommand[55:40] : memoryWriteCommand[39:24]),memoryWriteCommand[55:40]};
          color_mask<=choice==2 ? 3 : memoryWriteCommand[23:22];pair_id<=memoryWriteCommand[6:4];
        end
        if(choice==3||choice==4) selected_bank<=memoryWriteCommand[3];
        if(choice==3) begin
          pixel_mask[memoryWriteCommand[3]*16 +:16]<=memoryWriteCommand[55:40];
          if(memoryWriteCommand[22]) pixel_mask[(1-memoryWriteCommand[3])*16 +:16]<=0;
        end
        if(choice==4) begin rotation<=memoryWriteCommand[27:24];clear_banks<=memoryWriteCommand[23:22];stencil<=memoryWriteCommand[55:40];force_mask<=memoryWriteCommand[4];check_mask<=memoryWriteCommand[5];end
        if(choice==6) texture_right<=requTexCacheUpdateR;
      end
    end else if(operation==9) operation<=8;
    else if(ack_i) begin
      if(operation!=1) position<=(position+1)%16;
      if(operation==6&&position%8==0) first_texture_word<=dat_i;
      if(operation==8) background[(position%8)*32 +:32]<=dat_i;
      if(operation==3) begin pixels[selected_bank*16+(position%8)*2]<=dat_i[15:0];pixels[selected_bank*16+(position%8)*2+1]<=dat_i[31:16];end
    end else begin
      operation<=next_operation;
      if(next_operation!=9) busy<=0;
      if(operation==4) begin if(clear_banks[0]) pixel_mask[15:0]<=0;if(clear_banks[1]) pixel_mask[31:16]<=0;end
    end
  end
end
endmodule
