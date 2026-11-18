module dvbench_model #(
 parameter int C_APB_DATA_WIDTH=32,C_APB_ADDR_WIDTH=8,N=256,Q=3329,ROOT=17,COEFF_WIDTH=16,ADDR_WIDTH=8
)(
 input i_ntt_pclk,i_ntt_presetn,
 input [C_APB_ADDR_WIDTH-1:0] i_ntt_paddr,
 input i_ntt_psel,i_ntt_penable,i_ntt_pwrite,
 input [C_APB_DATA_WIDTH-1:0] i_ntt_pwdata,
 input [(C_APB_DATA_WIDTH/8)-1:0] i_ntt_pstrb,
 output reg [C_APB_DATA_WIDTH-1:0] o_ntt_prdata,
 output o_ntt_pready,
 output o_ntt_pslverr,
 output o_ntt_irq
);
 reg [15:0] coefficients[0:255];
 reg [7:0] host_address;
 reg [15:0] pending_data;
 reg pending_write,start_pending,done_sticky,error_sticky;
 reg [1:0] mode;
 integer age,operation,stage,offset,half,address_a,address_b,twiddle,product,operand_a,operand_b;
 reg [15:0] answer_a,answer_b,merged_data;
 wire busy=(age>=0 && age<=5120);
 wire access=i_ntt_psel && i_ntt_penable;
 wire write_access=access && i_ntt_pwrite;
 wire valid_address=(i_ntt_paddr==0 || i_ntt_paddr==4 || i_ntt_paddr==8 || i_ntt_paddr==12);
 assign o_ntt_pready=1;
 assign o_ntt_pslverr=access && (!valid_address || (busy && (i_ntt_paddr==12 || (i_ntt_pwrite && i_ntt_paddr==0 && i_ntt_pwdata[0]))));
 assign o_ntt_irq=done_sticky || error_sticky;
 function automatic integer mod_power(input integer exponent);
   integer result_value,base_value,power_value;
   begin
     result_value=1;base_value=17;power_value=exponent;
     while(power_value>0) begin
       if(power_value%2) result_value=(result_value*base_value)%3329;
       base_value=(base_value*base_value)%3329;power_value=power_value/2;
     end
     mod_power=result_value;
   end
 endfunction
 always @* begin
   o_ntt_prdata=0;
   if(i_ntt_psel && !i_ntt_pwrite) case(i_ntt_paddr)
     0:o_ntt_prdata={29'b0,mode,1'b0};
     4:o_ntt_prdata={29'b0,error_sticky,done_sticky,busy};
     8:o_ntt_prdata=host_address;
     12:if(!busy)o_ntt_prdata=coefficients[host_address];
     default:o_ntt_prdata=0;
   endcase
 end
 always @(posedge i_ntt_pclk or negedge i_ntt_presetn) begin
   if(!i_ntt_presetn) begin
     host_address<=0;pending_data<=0;pending_write<=0;start_pending<=0;
     done_sticky<=0;error_sticky<=0;mode<=1;age<=-1;answer_a<=0;answer_b<=0;
   end else begin
     merged_data=coefficients[host_address];
     if(i_ntt_pstrb[0])merged_data[7:0]=i_ntt_pwdata[7:0];
     if(i_ntt_pstrb[1])merged_data[15:8]=i_ntt_pwdata[15:8];
     if(pending_write)coefficients[host_address]<=pending_data;
     start_pending<=0;pending_write<=0;
     if(age==5121)done_sticky<=1;
     if(age==-2)error_sticky<=1;
     if(age==-1) begin
       if(start_pending) begin
         if(mode==1)age<=0;
         else if(mode==2 || mode==3)age<=-2;
       end
     end else if(age==-2 || age==5121)age<=-1;
     else begin
       age<=age+1;
       if(age>=1) begin
         operation=(age-1)/5;stage=operation/128;
         half=1<<stage;offset=(operation%128)%half;
         address_a=((operation%128)/half)*(half*2)+offset;address_b=address_a+half;
         if((age-1)%5==1) begin
           operand_a=coefficients[address_a]%3329;operand_b=coefficients[address_b]%3329;
           twiddle=mod_power(offset*(128/half));product=(operand_b*twiddle)%3329;
           answer_a<=(operand_a+product)%3329;
           answer_b<=(operand_a-product+3329)%3329;
         end
         if((age-1)%5==3) begin
           coefficients[address_a]<=answer_a;coefficients[address_b]<=answer_b;
         end
       end
     end
     if(write_access && !o_ntt_pslverr) begin
       case(i_ntt_paddr)
         0:if(i_ntt_pstrb[0])begin
           if(!busy)begin mode<=i_ntt_pwdata[2:1];start_pending<=i_ntt_pwdata[0];end
           if(i_ntt_pwdata[3])begin done_sticky<=0;error_sticky<=0;end
         end
         8:if(i_ntt_pstrb[0])host_address<=i_ntt_pwdata[7:0];
         12:begin pending_data<=merged_data;pending_write<=|i_ntt_pstrb[1:0];end
       endcase
     end
   end
 end
endmodule
