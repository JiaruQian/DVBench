
module maintenance_phy(
  input wire mdc,input wire resetn,input wire enabled,input wire bad_ta,
  input wire [15:0] identity_word,input wire [15:0] status_word,
  output wire [15:0] phycr,cfg4,rgmiictl,delaycode,
  inout wire mdio
);
  integer count=0;
  logic [63:0] captured=0;
  logic [1:0] operation=0;
  logic [4:0] register_number=0;
  logic [4:0] phy_number=0;
  logic [15:0] read_word=0;
  logic [15:0] clause22[32];
  logic [15:0] extended[256];
  logic [15:0] indirect_control=0;
  logic [15:0] indirect_address=0;
  assign phycr=clause22[16];assign cfg4=extended[8'h31];assign rgmiictl=extended[8'h32];assign delaycode=extended[8'h86];
  wire reading=operation==2 && phy_number==2;
  wire driving=enabled && reading && count>=47 && count<=63;
  wire output_bit=count==47 ? bad_ta : read_word[63-count];
  assign mdio=driving ? output_bit : 1'bz;
  always @(negedge resetn) begin
    count=0;captured=0;operation=0;indirect_control=0;indirect_address=0;
    for(integer index=0;index<32;index++)clause22[index]=16'h5aa5 ^ index;
    for(integer index=0;index<256;index++)extended[index]=16'hf0a5 ^ index;
    clause22[16]=16'hcfff;extended[8'h6e]=16'h0800;extended[8'h31]=16'hf0ff;extended[8'h32]=16'hf090;
  end
  always @(posedge mdc) begin
    if(resetn)begin
      captured={captured[62:0],mdio};count++;
      if(count==46)begin
        operation=captured[11:10];phy_number=captured[9:5];register_number=captured[4:0];
        if(register_number==3)read_word=identity_word;
        else if(register_number==17)read_word=status_word;
        else if(register_number==14 && indirect_control[14])read_word=extended[indirect_address[7:0]];
        else read_word=clause22[register_number];
      end
      if(count==64)begin
        if(enabled && phy_number==2 && operation==1)begin
          clause22[register_number]=captured[15:0];
          if(register_number==13)indirect_control=captured[15:0];
          if(register_number==14)begin
            if(indirect_control[14])extended[indirect_address[7:0]]=captured[15:0];
            else indirect_address=captured[15:0];
          end
        end
        count=0;captured=0;operation=0;
      end
    end
  end
endmodule
