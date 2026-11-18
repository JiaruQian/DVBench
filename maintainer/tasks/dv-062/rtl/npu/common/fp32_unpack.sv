`timescale 1ns/1ps // Define the simulation time unit and time precision for the IEEE FP32 field-unpacking module

module fp32_unpack ( // Define an FP32 combinational unpacker responsible only for field splitting and numerical classification
    input  logic                   [31:0] data_i, // Input a raw IEEE FP32 encoding
    output fp8_pkg::fp32_unpacked_t unpacked_o // Output the intermediate decoded structure before Subnormal normalization
); // End the fp32_unpack port declarations

logic [7:0] exp_field; // Store the IEEE FP32 eight-bit biased exponent field
logic [22:0] frac_field; // Store the IEEE FP32 twenty-three-bit fraction field

always_comb begin // Perform only sign extraction, field splitting, classification, and base exponent generation
    exp_field = data_i[30:23]; // Extract the raw FP32 exponent field
    frac_field = data_i[22:0]; // Extract the raw FP32 fraction field
    unpacked_o = '0; // Default the intermediate numerical value and all mutually exclusive classification flags to zero
    unpacked_o.sign = data_i[31]; // Preserve the sign bit of all FP32 encodings
    unpacked_o.significand = {1'b0, frac_field}; // Unconditionally pass through the fraction field to eliminate the false dependency from exponent classification to the Subnormal LZC input
    if (exp_field == 8'h00) begin // Handle zero or Subnormal corresponding to a zero exponent field
        if (frac_field == 23'h000000) begin // Identify signed zero when both the exponent and fraction are zero
            unpacked_o.is_zero = 1'b1; // Declare the current encoding to be positive zero or negative zero
        end else begin // A zero exponent and a nonzero fraction form a Subnormal intermediate value
            unpacked_o.exponent = -10'sd126; // Record the base exponent of the unnormalized Subnormal representation
            unpacked_o.is_subnormal = 1'b1; // Declare the current encoding to be an FP32 subnormal number
        end // End zero and Subnormal classification for the zero exponent field
    end else if (exp_field == 8'hff) begin // Handle infinity or NaN corresponding to an all-ones exponent field
        if (frac_field == 23'h000000) begin // An all-ones exponent and a zero fraction encode signed infinity
            unpacked_o.is_inf = 1'b1; // Declare the current encoding to be positive infinity or negative infinity
        end else begin // An all-ones exponent and a nonzero fraction encode NaN
            unpacked_o.is_nan = 1'b1; // Declare the current encoding to be NaN and preserve the original payload
        end // End infinity and NaN classification for the all-ones exponent field
    end else begin // Handle normalized finite numbers whose exponent is neither zero nor all ones
        unpacked_o.exponent = $signed({2'b00, exp_field}) - 10'sd127; // Generate the unbiased exponent of a normalized number
        unpacked_o.significand[23] = 1'b1; // Insert the hidden bit only through the Normal classification, without gating the raw fraction field anymore
        unpacked_o.is_normal = 1'b1; // Declare the current encoding to be a normalized finite number
    end // End classification of all FP32 encodings
end // End the FP32 field-unpacking combinational logic

endmodule // End the FP32 unpacker responsible only for fields and classification
