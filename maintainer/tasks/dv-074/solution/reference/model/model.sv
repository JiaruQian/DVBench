module dvbench_model(
 input clk,reset,start,is_subnormal,in_exp0,
 input [7:0] exp_half,
 input [23:0] in_sig,
 input [2:0] rounding_mode,
 output reg sqrt_done,
 output reg [26:0] sqrt_proNorm_sig,
 output reg [7:0] sqrt_proNorm_exp,
 output reg uf
);
 integer phase,iteration,leading;
 reg [87:0] operand;
 reg [43:0] root_value,partial_value,normalized;
 function automatic [43:0] integer_root(input [87:0] number);
   reg [87:0] trial_square;
   reg [43:0] proposal,result_value;
   integer bit_index;
   begin
     result_value=0;
     for(bit_index=43;bit_index>=0;bit_index=bit_index-1) begin
       proposal=result_value | (44'b1<<bit_index);
       trial_square=88'(proposal)*88'(proposal);
       if(trial_square<=number) result_value=proposal;
     end
     integer_root=result_value;
   end
 endfunction
 always @(posedge clk or negedge reset) begin
   if(!reset) begin phase=0; iteration=0; operand=0; root_value=0; partial_value=0; sqrt_done<=0; end
   else begin
     sqrt_done<=0;
     root_value=partial_value;
     case(phase)
       0: if(start) phase=1;
       1: begin
         operand=88'(in_sig) << ((is_subnormal || in_exp0)?63:64);
         partial_value=0; root_value=0; iteration=0; phase=2;
       end
       2: begin
         if(iteration<44) begin
           iteration=iteration+1;
           partial_value=integer_root(operand >> (2*(44-iteration)));
         end else begin sqrt_done<=1; phase=0; iteration=0; end
       end
     endcase
   end
 end
 always @* begin
   leading=0;
   for(integer bit_index=43;bit_index>=0;bit_index=bit_index-1)
     if(root_value[bit_index]==0 && leading==43-bit_index) leading=leading+1;
   normalized=root_value<<leading;
   sqrt_proNorm_exp=is_subnormal ? exp_half-leading : exp_half;
   uf=is_subnormal && !normalized[43];
   if(!is_subnormal) sqrt_proNorm_sig={root_value[43:18],|root_value[17:0]};
   else if(rounding_mode==3) sqrt_proNorm_sig={normalized[43:20],root_value[19:18],|root_value[17:0]};
   else sqrt_proNorm_sig={normalized[43:18],|normalized[17:0]};
 end
endmodule
