package port_types;
typedef struct packed {
logic MRxDV;
logic [3:0] MRxD;
logic Reset;
logic Transmitting;
logic [15:0] MaxFL;
logic r_IFG;
logic HugEn;
logic DlyCrcEn;
logic [47:0] MAC;
logic r_Pro;
logic r_Bro;
logic [31:0] r_HASH0;
logic [31:0] r_HASH1;
logic PassAll;
logic ControlFrmAddressOK;
} command_t;
typedef struct packed {
logic [7:0] RxData;
logic RxValid;
logic RxStartFrm;
logic RxEndFrm;
logic [15:0] ByteCnt;
logic ByteCntEq0;
logic ByteCntGreat2;
logic ByteCntMaxFrame;
logic CrcError;
logic StateIdle;
logic StatePreamble;
logic StateSFD;
logic [1:0] StateData;
logic RxAbort;
logic AddressMiss;
} response_t;
endpackage
module native_d_tb;
import port_types::*;
logic clk=0;always #5 clk=~clk;
command_t c;response_t actual,expected;
int points=0,mismatches=0,seed;
eth_rxethmac dut(.MRxClk(clk),.MRxDV(c.MRxDV),.MRxD(c.MRxD),.Reset(c.Reset),.Transmitting(c.Transmitting),.MaxFL(c.MaxFL),.r_IFG(c.r_IFG),.HugEn(c.HugEn),.DlyCrcEn(c.DlyCrcEn),.MAC(c.MAC),.r_Pro(c.r_Pro),.r_Bro(c.r_Bro),.r_HASH0(c.r_HASH0),.r_HASH1(c.r_HASH1),.PassAll(c.PassAll),.ControlFrmAddressOK(c.ControlFrmAddressOK),.RxData(actual.RxData),.RxValid(actual.RxValid),.RxStartFrm(actual.RxStartFrm),.RxEndFrm(actual.RxEndFrm),.ByteCnt(actual.ByteCnt),.ByteCntEq0(actual.ByteCntEq0),.ByteCntGreat2(actual.ByteCntGreat2),.ByteCntMaxFrame(actual.ByteCntMaxFrame),.CrcError(actual.CrcError),.StateIdle(actual.StateIdle),.StatePreamble(actual.StatePreamble),.StateSFD(actual.StateSFD),.StateData(actual.StateData),.RxAbort(actual.RxAbort),.AddressMiss(actual.AddressMiss));
dvbench_model model(.MRxClk(clk),.MRxDV(c.MRxDV),.MRxD(c.MRxD),.Reset(c.Reset),.Transmitting(c.Transmitting),.MaxFL(c.MaxFL),.r_IFG(c.r_IFG),.HugEn(c.HugEn),.DlyCrcEn(c.DlyCrcEn),.MAC(c.MAC),.r_Pro(c.r_Pro),.r_Bro(c.r_Bro),.r_HASH0(c.r_HASH0),.r_HASH1(c.r_HASH1),.PassAll(c.PassAll),.ControlFrmAddressOK(c.ControlFrmAddressOK),.RxData(expected.RxData),.RxValid(expected.RxValid),.RxStartFrm(expected.RxStartFrm),.RxEndFrm(expected.RxEndFrm),.ByteCnt(expected.ByteCnt),.ByteCntEq0(expected.ByteCntEq0),.ByteCntGreat2(expected.ByteCntGreat2),.ByteCntMaxFrame(expected.ByteCntMaxFrame),.CrcError(expected.CrcError),.StateIdle(expected.StateIdle),.StatePreamble(expected.StatePreamble),.StateSFD(expected.StateSFD),.StateData(expected.StateData),.RxAbort(expected.RxAbort),.AddressMiss(expected.AddressMiss));

task drive(input command_t value);
 @(negedge clk);c=value;
 @(posedge clk);#1;points++;
 if(actual!==expected)begin mismatches++;if(mismatches<=20)$display("D_MISMATCH point=%0d a=%h e=%h",points,actual,expected);end
endtask

task histories();
 command_t c;
 int len;
 c='0;c.Reset=1;c.MaxFL=1518;c.MAC=48'h123456789abc;c.r_IFG=0;
 repeat(3)drive(c);
 c.Reset=0;repeat(30)drive(c);
 for(int f=0;f<120;f++)begin
  c.MRxDV=0;c.Transmitting=0;c.Reset=0;
  c.MaxFL=(f<6)?f:((f%5==0)?16'hffff:((f%5==1)?16'd20:16'd1518));
  c.HugEn=f%3==0;c.DlyCrcEn=f%2;c.r_IFG=f%3==1;
  c.r_Pro=f%4==0;c.r_Bro=f%4==1;c.PassAll=f%3==0;c.ControlFrmAddressOK=f%2;
  c.r_HASH0=$urandom;c.r_HASH1=$urandom;
  repeat((f%6==0)?2:30)drive(c);
  c.MRxDV=1;c.MRxD=(f%7==0)?3:5;drive(c);
  repeat(14)begin c.MRxD=5;drive(c);end
  c.MRxD=13;drive(c);
  len=(f<6)?f:(40+$urandom_range(0,150));
  for(int k=0;k<len*2;k++)begin
   if(k<12)begin
    case(f%3)
    0:c.MRxD=15;
    1:c.MRxD=(k%2)?(c.MAC>>(44-(k/2)*8)):(c.MAC>>(40-(k/2)*8));
    default:c.MRxD=$urandom_range(0,15);
    endcase
   end else c.MRxD=$urandom_range(0,15);
   if(f%11==0&&k==8)c.Transmitting=1;
   drive(c);
  end
  c.MRxDV=0;repeat(8)drive(c);
 end
 for(int k=0;k<5000;k++)begin
  c.MRxDV=$urandom_range(0,1);c.MRxD=$urandom_range(0,15);
  if(k%31==0)begin
   c.Reset=1;drive(c);c.Reset=0;
   c.Transmitting=$urandom_range(0,1);c.MaxFL=$urandom_range(0,30);
   c.DlyCrcEn=$urandom_range(0,1);c.HugEn=$urandom_range(0,1);
   c.r_IFG=$urandom_range(0,1);c.r_Pro=$urandom_range(0,1);c.r_Bro=$urandom_range(0,1);
  end
  drive(c);
 end
 c.Reset=1;drive(c);c.Reset=0;c.MRxDV=0;repeat(32)drive(c);
endtask

initial begin
 c='0;c.Reset=1;
 if(!$value$plusargs("SEED=%d",seed))seed=1;
 seed=$urandom(seed);
 histories();
 $display("D_RESULT checks=%0d mismatches=%0d",points,mismatches);
 $finish;
end
endmodule
