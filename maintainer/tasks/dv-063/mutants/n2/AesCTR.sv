`timescale 1ns / 1ps

module AesCTR (
	input  logic         clk   ,
	input  logic         rst   ,
	input  logic         load  , //! load key and iv
	input  logic         start , //! start encrypt/decrypt iBlock in CTR mode
	input  logic [127:0] key   ,
	input  logic [127:0] iv    ,
	input  logic [127:0] iBlock,
	output logic [127:0] oBlock,
	output logic         idle
);

	typedef enum { IDLE, KEY_EXPANSION, RUNNING } Step_t;
	Step_t step, nextStep;
	logic[127:0] cnt, nextCnt;
	logic[127:0] regIBlock;
	logic enRegIBlock;
    logic loaded_iv_valid;
    logic [127:0] loaded_iv;
    logic [127:0] loaded_key;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            loaded_iv_valid <= 1'b0;
            loaded_iv <= '0;
            loaded_key <= '0;
        end else if (step == IDLE && load) begin
            loaded_iv_valid <= 1'b1;
            loaded_iv <= iv;
            loaded_key <= (loaded_iv_valid && loaded_iv == iv) ? loaded_key : key;
        end
    end

	// ==== state register ====
	always_ff @(posedge clk or posedge rst)
		begin : STATE_REGISTER
			if (rst)
				begin
					step      <= IDLE;
					cnt       <= 0;
					regIBlock <= 0;
				end
			else
				begin
					step <= nextStep;
					cnt  <= nextCnt;

					if (enRegIBlock)
						begin
							regIBlock <= iBlock;
						end
				end
		end

	// ==== next state logic ====
	logic aesCoreIdle;
	logic[127:0] aesCoreOutput;
	AesCore aesCoreI(
		.clk(clk),
		.rst(rst),
		.start(start),
		.encrypt(1'b1),
		.key((loaded_iv_valid && loaded_iv == iv) ? loaded_key : key),
		.load(load),
		.iBlock(cnt),
		.oBlock(aesCoreOutput),
		.idle(aesCoreIdle)
	);

	always_comb
		begin : NEXT_STATE_LOGIC
			nextStep = step;
			nextCnt  = cnt;

			enRegIBlock = 0;

			case(step)
				IDLE :
					if (load) begin
						nextCnt  = iv;
						nextStep = KEY_EXPANSION;
					end else if (start) begin
						nextStep    = RUNNING;
						enRegIBlock = 1;
					end

				KEY_EXPANSION :
					if (aesCoreIdle) begin
						nextStep = IDLE;
					end

				RUNNING :
					if (aesCoreIdle) begin
						nextStep = IDLE;
						nextCnt  = cnt + 1;
					end
			endcase
		end

	// ==== output logic ====
	always_comb
		begin : OUTPUT_LOGIC
			idle   = (step == IDLE) ? 1 : 0;
			oBlock = aesCoreOutput ^ regIBlock;
		end
endmodule
