/*---------------------------
* Fonction : Compte le nombre de permutations
* Auteur : Aurélien Goupil
* Date : 17/11/23
---------------------------*/

`timescale 1 ns/ 1 ps

module compteur_permutations import ascon_pack::*;(
	input logic clock_i, resetb_i, enable_i, init_p6_i, init_p12_i,
	output logic [3:0] compteur_o
	);
	
	//internal declaration
	logic [3:0] cpt_s;

always_ff @(posedge clock_i or negedge resetb_i)
begin : compteur
	if(resetb_i == 1'b0)
		cpt_s <= 0;
	else begin
		if(enable_i == 1'b1) begin
			if(init_p6_i == 1'b1)
				cpt_s <= 6;
			else 
				if(init_p12_i == 1'b1)
					cpt_s <= 0;
			else
				cpt_s <= cpt_s+1;
		end
	end	
		

end:compteur

assign compteur_o = cpt_s;

endmodule : compteur_permutations
