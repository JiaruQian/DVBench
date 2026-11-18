/*--------------------------------------------
* Fonction : Machine FSM Ascon 
* Auteur : Aurélien Goupil
* Date : 20/11/23
--------------------------------------------*/

`timescale 1ns /1 ps

module ascon_fsm import ascon_pack::*; (
	input logic [3:0] rnd_i,
	input logic [1:0] nb_blocs_i,
	input logic resetb_i,start_i, clock_i, data_valid_i,
	output logic bypass_xor_end_o, bypass_xor_begin_o, enable_reg_state_o, enable_cpt_perm_o, enable_cpt_blocs_o, input_mode_o, input_p12_o,input_p6_o, init_blocs_o, xor_begin_data_mode_o,xor_end_key_mode_o,
	output logic end_o,cipher_valid_o
	);
		
// enumerate type declaration
	typedef enum {attente , conf_init , init_round_0, init_1_to_10, init_rnd_11, attente_da , da_rnd_6 , da_7_to_10, da_rnd_11, attente_tc, tc_rnd_6, tc_7_to_11, attente_final, final_rnd_0, final_1_to_10, final_rnd_11, fin} state_t ;
// internal variable to model the FSM
	state_t current_state , next_state ;
	
// sequential process modeling the state register
always_ff @( posedge clock_i or negedge resetb_i )
	begin : seq_0
		if ( resetb_i == 0)
			// nonblocking assignment
			current_state <= attente ;
		else
			current_state <= next_state ;
end : seq_0

// first combinational process for transitions
always_comb
	begin : state
		case ( current_state )
			attente : if (start_i == 1)
				next_state = conf_init ;
			else
				next_state = attente ;
			//
			conf_init :
				next_state = init_round_0 ;
			//
			init_round_0 :
				next_state = init_1_to_10 ;
			//
			init_1_to_10 : if (rnd_i == 10)
				next_state = init_rnd_11 ;
			else
				next_state = init_1_to_10 ;
			//
			init_rnd_11 :
				next_state = attente_da ;
			//
			attente_da : if (data_valid_i == 1'b1)
				next_state = da_rnd_6;
			else
				next_state = attente_da ;
			//	
			da_rnd_6: 
				next_state = da_7_to_10;
			//	
			da_7_to_10 : if (rnd_i == 10)
				next_state = da_rnd_11 ;
			else
				next_state = da_7_to_10;
			//
			da_rnd_11: 
				next_state = attente_tc;
			//	
			attente_tc : if (data_valid_i == 1'b1)
				next_state = tc_rnd_6;
			else
				next_state = attente_tc ;
			//	
			tc_rnd_6 : 
				next_state = tc_7_to_11;
			//	
			tc_7_to_11 : 
			if (rnd_i == 11)
				if(nb_blocs_i != 3)
					next_state = attente_final;
				else
					next_state = attente_tc;
			else
				next_state = tc_7_to_11 ; 
			//
			attente_final : if (data_valid_i == 1'b1)
				next_state = final_rnd_0;
			else
				next_state = attente_final;
			//
			final_rnd_0 :
				next_state = final_1_to_10;	
			//
			final_1_to_10 : if(rnd_i == 10)
				next_state = final_rnd_11;
			else 
				next_state = final_1_to_10;
			//
			final_rnd_11 :
				next_state = fin;
			fin :
				next_state = attente ;
				
			default : next_state = attente ;
		endcase ; // case ( current_state )
	end : state

// second combinational process for outputs
always_comb
	begin : process
		case ( current_state )
			attente : begin
				bypass_xor_end_o = 1;
				bypass_xor_begin_o = 1;
				enable_reg_state_o = 0;
			end
			//
			conf_init : begin
				enable_cpt_perm_o = 1;
				input_p12_o = 1;
				enable_reg_state_o = 1;
			end
			//
			init_round_0 : begin
				input_mode_o = 1;
				input_p12_o = 0;
				
			end
			//	
			init_1_to_10 : begin
				input_mode_o = 0;
			end
			//
			init_rnd_11 : begin
				bypass_xor_end_o = 0;
				xor_end_key_mode_o = 1;
			end
			//
			attente_da : begin
				bypass_xor_end_o = 1;
				bypass_xor_begin_o = 1;
				enable_reg_state_o = 0;
				enable_cpt_perm_o = 1;
				input_p6_o = 1;
			end
			//
			da_rnd_6 : begin
				bypass_xor_begin_o = 0;
				xor_begin_data_mode_o = 1;
				input_p6_o = 0;
				enable_reg_state_o = 1;
			end
			
			da_7_to_10 : begin
				bypass_xor_begin_o = 1;
			end
			//
			da_rnd_11 : begin
				bypass_xor_end_o = 0;
				xor_end_key_mode_o = 0;
				init_blocs_o = 1;
				enable_cpt_blocs_o = 1;
			end
			//
			attente_tc : begin
				bypass_xor_end_o = 1;
				bypass_xor_begin_o = 1;
				enable_reg_state_o = 0;
				enable_cpt_perm_o = 1;
				input_p6_o = 1;
				init_blocs_o = 0;
				enable_cpt_blocs_o = 1;
			end
			//
			tc_rnd_6 : begin
				bypass_xor_begin_o = 0;
				xor_begin_data_mode_o = 1;
				input_p6_o = 0;
				enable_reg_state_o = 1;
				enable_cpt_blocs_o = 0;
				cipher_valid_o = 1;
			end
			//
			tc_7_to_11 : begin
				cipher_valid_o = 0;
				bypass_xor_begin_o = 1;
				enable_cpt_blocs_o = 0;
				init_blocs_o = 0;
			end
			//
			attente_final : begin
				bypass_xor_end_o = 1;
				bypass_xor_begin_o = 1;
				enable_reg_state_o = 0;
				enable_cpt_perm_o = 1;
				input_p12_o = 1;
			end
			//
			final_rnd_0 : begin
				bypass_xor_begin_o = 0;
				xor_begin_data_mode_o = 0;
				cipher_valid_o = 1;
				input_p12_o = 0;
				enable_reg_state_o = 1;
				
			end
			//
			final_1_to_10 : begin
				bypass_xor_begin_o = 1;
				cipher_valid_o = 0;
			end
			//
			final_rnd_11 : begin
				bypass_xor_end_o = 0;
				xor_end_key_mode_o = 1;
			end
			//
			fin : begin
				end_o = 1;
				enable_reg_state_o = 0;
			end
			default : end_o = 0;
		endcase ; // case ( current_state )
	end : process

endmodule : ascon_fsm



