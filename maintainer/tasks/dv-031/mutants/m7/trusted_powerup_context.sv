`timescale 1ns/1ps
module trusted_powerup_context;
logic GSR=1;
initial begin #100; GSR=0; end
endmodule
bind FDRE trusted_powerup_context glbl();
bind RAMB36E2 trusted_powerup_context glbl();
