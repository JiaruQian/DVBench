`timescale 1ns/1ps // Defines the simulation time unit and time precision for the two-stage FP32 Subnormal normalization pipeline module

module fp32_subnormal_normalize ( // Defines the FP32 normalization module with a register stage inserted between LZC and the dynamic left shift
    input  logic                    clk_i, // Input operating clock for the normalization pipeline
    input  logic                    rst_i, // Input synchronous active-high reset signal
    input  fp8_pkg::fp32_unpacked_t unpacked_i, // Input FP32 intermediate structure after field unpacking and classification
    output fp8_pkg::fp32_decoded_t  decoded_o // Output unified normalized FP32 structure delayed by one cycle
); // Ends the port declarations of the FP32 Subnormal pipeline normalization module

logic [23:0] subnormal_raw_comb; // Stores the twenty-four-bit raw Subnormal significand including the fixed zero hidden bit
logic [31:0] lzc_input_comb; // Stores the LZC input vector padded to thirty-two bits
logic [15:0] lzc_stage16_comb; // Stores the sixteen-bit candidate region selected by the balanced LZC tree
logic [7:0] lzc_stage8_comb; // Stores the eight-bit candidate region selected by the balanced LZC tree
logic [3:0] lzc_stage4_comb; // Stores the four-bit candidate region selected by the balanced LZC tree
logic [1:0] lzc_stage2_comb; // Stores the two-bit candidate region selected by the balanced LZC tree
logic [4:0] lzc_count_comb; // Stores the five-bit leading-zero count corresponding to the padded vector
logic [4:0] normalize_shift_comb; // Stores the normalization shift amount that directly drives the next-stage left shifter

logic sign_comb; // Stores the sign bit to be bypassed in the first stage
logic signed [9:0] exponent_comb; // Stores the ten-bit unbiased exponent with Subnormal correction already completed in the first stage
logic [23:0] significand_comb; // Stores the twenty-four-bit significand to be bypassed in the first stage

always_comb begin // Prepares bypass metadata that can be registered directly in the first-stage combinational path
    sign_comb = unpacked_i.sign; // Bypasses the input sign bit
    exponent_comb = unpacked_i.exponent; // Bypasses the base unbiased exponent for Normal, zero, and special values by default
    significand_comb = unpacked_i.significand; // Bypasses the complete significand to preserve the behavior of special values such as NaN
    if (unpacked_i.is_subnormal) begin // Completes exponent correction for Subnormal before the register to eliminate serial subtraction on the output side
        exponent_comb = -10'sd126 - $signed({5'b00000, normalize_shift_comb}); // Uses the LZC shift amount to generate the final unbiased exponent
    end // Ends the Subnormal exponent correction selection
end // Ends the logic that generates directly registerable metadata

always_comb begin // Completes LZC on the twenty-four-bit raw significand in the first-stage combinational path
    subnormal_raw_comb = {1'b0, unpacked_i.significand[22:0]}; // Retains the Subnormal zero hidden bit before the twenty-three-bit fraction
    lzc_input_comb = {subnormal_raw_comb, 8'b00000000}; // Map the 24-bit raw significand to the upper bits of the 32-bit LZC
    if (|lzc_input_comb[31:16]) begin // Select the upper half when the upper 16 bits contain a one
        lzc_count_comb[4] = 1'b0; // The leading-zero count is less than 16 when the upper half is hit
        lzc_stage16_comb = lzc_input_comb[31:16]; // Pass the upper half to the next stage for localization
    end else begin // Select the lower half when the upper 16 bits are all zero
        lzc_count_comb[4] = 1'b1; // Add 16 leading zeros when the lower half is hit
        lzc_stage16_comb = lzc_input_comb[15:0]; // Pass the lower half to the next stage for localization
    end // End selection of the 16-bit candidate region
    if (|lzc_stage16_comb[15:8]) begin // Select the upper eight bits when the upper eight bits of the current candidate region contain a one
        lzc_count_comb[3] = 1'b0; // Do not add eight leading zeros when the upper eight bits are hit
        lzc_stage8_comb = lzc_stage16_comb[15:8]; // Pass the upper eight bits to the next stage for localization
    end else begin // Select the lower eight bits when the upper eight bits of the current candidate region are all zero
        lzc_count_comb[3] = 1'b1; // Add eight leading zeros when the lower eight bits are hit
        lzc_stage8_comb = lzc_stage16_comb[7:0]; // Pass the lower eight bits to the next stage for localization
    end // End selection of the eight-bit candidate region
    if (|lzc_stage8_comb[7:4]) begin // Select the upper four bits when the upper four bits of the current candidate region contain a one
        lzc_count_comb[2] = 1'b0; // Do not add four leading zeros when the upper four bits are hit
        lzc_stage4_comb = lzc_stage8_comb[7:4]; // Pass the upper four bits to the next stage for localization
    end else begin // Select the lower four bits when the upper four bits of the current candidate region are all zero
        lzc_count_comb[2] = 1'b1; // Add four leading zeros when the lower four bits are hit
        lzc_stage4_comb = lzc_stage8_comb[3:0]; // Pass the lower four bits to the next stage for localization
    end // End selection of the four-bit candidate region
    if (|lzc_stage4_comb[3:2]) begin // Select the upper two bits when the upper two bits of the current candidate region contain a one
        lzc_count_comb[1] = 1'b0; // Do not add two leading zeros when the upper two bits are hit
        lzc_stage2_comb = lzc_stage4_comb[3:2]; // Pass the upper two bits to the final stage for localization
    end else begin // Select the lower two bits when the upper two bits of the current candidate region are all zero
        lzc_count_comb[1] = 1'b1; // Add two leading zeros when the lower two bits are hit
        lzc_stage2_comb = lzc_stage4_comb[1:0]; // Pass the lower two bits to the final stage for localization
    end // End selection of the two-bit candidate region
    if (lzc_stage2_comb[1]) begin // Do not add a leading zero at the final bit when the most significant of the two candidate bits is one
        lzc_count_comb[0] = 1'b0; // The final count bit is zero when the most significant bit is hit
    end else if (lzc_stage2_comb[0]) begin // Add one leading zero at the final bit when the least significant of the two candidate bits is one
        lzc_count_comb[0] = 1'b1; // The final count bit is one when the least significant bit is hit
    end else begin // Override the shift amount with the all-zero protection logic when both candidate bits are zero
        lzc_count_comb[0] = 1'b1; // Maintain a deterministic result both when the least significant bit is hit and when all bits are zero
    end // End final-bit counting for the two candidate bits
    if (subnormal_raw_comb == 24'h000000) begin // Provide a deterministic saturated shift amount when the raw significand is all zero
        normalize_shift_comb = 5'd24; // The all-zero protection value equals the 24-bit input width
    end else begin // The LZC result for a nonzero Subnormal is the required normalization shift amount
        normalize_shift_comb = lzc_count_comb; // Use the 24-bit LZC result directly without adding one
    end // End selection between all-zero and nonzero shift amounts
end // End first-stage LZC and normalization shift amount combinational logic

logic sign_q; // Store the sign bit after first-stage registration
logic signed [9:0] exponent_q; // Store the final ten-bit unbiased exponent after first-stage registration
logic [23:0] significand_q; // Store the full significand after first-stage registration
logic is_zero_q; // Store the signed-zero classification after first-stage registration
logic is_subnormal_q; // Store the Subnormal classification after first-stage registration
logic is_normal_q; // Store the Normal classification after first-stage registration
logic is_inf_q; // Store the infinity classification after first-stage registration
logic is_nan_q; // Store the NaN classification after first-stage registration
logic [4:0] normalize_shift_q; // Store the normalization shift amount after first-stage registration

always_ff @(posedge clk_i) begin // Establish a synchronous pipeline register boundary between the LZC and the dynamic left shift
    if (rst_i) begin // Clear bypass fields and first-stage intermediate results on synchronous reset
        sign_q <= 1'b0; // Clear the registered sign bit
        exponent_q <= 10'sd0; // Clear the registered final unbiased exponent
        significand_q <= 24'h000000; // Clear the registered significand
        is_zero_q <= 1'b0; // Clear the registered signed-zero classification
        is_subnormal_q <= 1'b0; // Clear the registered Subnormal classification
        is_normal_q <= 1'b0; // Clear the registered Normal classification
        is_inf_q <= 1'b0; // Clear the registered infinity classification
        is_nan_q <= 1'b0; // Clear the registered NaN classification
        normalize_shift_q <= 5'd0; // Clear the registered normalization shift amount
    end else begin // Sample the first-stage combinational results during normal cycles
        sign_q <= sign_comb; // Sample the sign bypass field
        exponent_q <= exponent_comb; // Sample the final exponent with the Subnormal correction already completed
        significand_q <= significand_comb; // Sample the complete significand bypass field
        is_zero_q <= unpacked_i.is_zero; // Directly sample the signed-zero classification to remove output-side classification decoding
        is_subnormal_q <= unpacked_i.is_subnormal; // Directly sample the Subnormal classification to drive normalized significand selection
        is_normal_q <= unpacked_i.is_normal; // Directly sample the Normal classification for downstream finite-number detection
        is_inf_q <= unpacked_i.is_inf; // Directly sample the infinity classification for downstream special-value detection
        is_nan_q <= unpacked_i.is_nan; // Directly sample the NaN classification for downstream special-value detection
        normalize_shift_q <= normalize_shift_comb; // Latch the control shift amount for the dynamic left shifter
    end // End the synchronous reset and normal sampling branches
end // End the pipeline register boundary between LZC and dynamic left shift

logic [23:0] subnormal_normalized_comb; // Store the normalized significand after the second-stage dynamic left shift

always_comb begin // Perform dynamic left shift and unified output selection in the second-stage combinational path
    subnormal_normalized_comb = {1'b0, significand_q[22:0]} << normalize_shift_q; // Reconstruct the original Subnormal number from the registered significand and shift it left
    decoded_o = '0; // Default the unified normalized structure to zero
    decoded_o.sign = sign_q; // Preserve the registered FP32 sign bit
    decoded_o.exponent = exponent_q; // Directly output the registered final ten-bit unbiased exponent
    decoded_o.significand = significand_q; // Retain the Normal or special-value significand by default
    decoded_o.is_zero = is_zero_q; // Directly output the registered signed-zero classification
    decoded_o.is_subnormal = is_subnormal_q; // Directly output the registered Subnormal classification
    decoded_o.is_normal = is_normal_q; // Directly output the registered Normal classification
    decoded_o.is_inf = is_inf_q; // Directly output the registered infinity classification
    decoded_o.is_nan = is_nan_q; // Directly output the registered NaN classification
    if (is_subnormal_q) begin // Subnormal uses the registered shift amount and dynamic left-shift result
        decoded_o.significand = subnormal_normalized_comb; // Output the significand in 1.23 format, including the hidden bit
    end // End Subnormal normalization selection
end // End the second-stage dynamic left-shift and unified output combinational logic

endmodule // End the FP32 Subnormal two-stage normalization pipeline module
