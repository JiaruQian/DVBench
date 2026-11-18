`timescale 1ns/1ps // Define the simulation time unit and time precision for designs associated with the FP8 common package

package fp8_pkg; // Define common types for the FP32 auxiliary pipeline and exact reduction

typedef enum logic [1:0] { // Define the rounding mode enumeration shared by subsequent FP8 quantization and packing
    RNE = 2'b00, // Select round to nearest, ties to even
    RTZ = 2'b01, // Select the round-toward-zero truncation mode
    RUP = 2'b10, // Select the round-toward-positive-infinity mode
    RDN = 2'b11 // Select the round-toward-negative-infinity mode
} fp8_rounding_e; // End the FP8 rounding mode enumeration definition

typedef enum logic [1:0] { // Define compact special-result states passed through the four-input reduction pipeline
    FP8_REDUCE_NORMAL = 2'b00, // Indicate that the result should be produced by the ordinary finite-number reduction and rounding path
    FP8_REDUCE_NAN = 2'b01, // Indicate that the result should bypass to a uniform FP32 canonical NaN
    FP8_REDUCE_POS_INF = 2'b10, // Indicate that the result should bypass to FP32 positive infinity
    FP8_REDUCE_NEG_INF = 2'b11 // Indicate that the result should bypass to FP32 negative infinity
} fp8_reduce_special_e; // End the reduction pipeline special-result state enumeration definition

typedef enum logic [1:0] { // Define compact states for restoring the IEEE zero sign when the exact sum is zero
    FP8_ZERO_SIGN_ROUNDING = 2'b00, // Indicate cancellation or mixed-sign zeros and select the sign according to the current rounding mode
    FP8_ZERO_SIGN_POSITIVE = 2'b01, // Indicate that all inputs are positive zero and force positive zero as the output
    FP8_ZERO_SIGN_NEGATIVE = 2'b10, // Indicate that all inputs are negative zero and force negative zero as the output
    FP8_ZERO_SIGN_RESERVED = 2'b11 // Reserve the encoding and handle it according to the rounding mode to provide deterministic fault-tolerant behavior
} fp8_reduce_zero_sign_e; // End the reduction pipeline zero-sign state enumeration definition

typedef struct packed { // Define a unified structure for use by the multiply-add datapath after FP8 unpacking
    logic              sign; // Store the sign bit of the original FP8 value
    logic signed [7:0] exponent; // Store the unbiased signed exponent of a normalized finite number
    logic        [3:0] significand; // Store the normalized significand aligned to a format with one integer bit and three fractional bits
    logic              is_zero; // Indicate that the current decoded result is positive zero or negative zero
    logic              is_subnormal; // Indicate that the current decoded result comes from a subnormal number
    logic              is_normal; // Indicate that the current decoded result is an ordinary normalized finite number
    logic              is_inf; // Indicate that the current decoded result is positive infinity or negative infinity
    logic              is_nan; // Indicate that the current decoded result is not a number
} fp8_decoded_t; // End the unified FP8 decoded-result structure definition

typedef struct packed { // Define an FP8 multiplication metadata structure that advances in parallel with the independent significand datapath
    logic              sign; // Store the FP8 operand sign bit for pipelined product sign calculation
    logic signed [7:0] exponent; // Store the FP8 operand unbiased exponent for pipelined exponent addition
    logic              is_zero; // Store the FP8 operand signed-zero classification
    logic              is_subnormal; // Store the FP8 operand subnormal finite-number classification
    logic              is_normal; // Store the FP8 operand normalized finite-number classification
    logic              is_inf; // Store the FP8 operand signed-infinity classification
    logic              is_nan; // Store the FP8 operand NaN classification
} fp8_mul_metadata_t; // End the FP8 multiplication parallel-pipeline metadata structure definition

typedef struct packed { // Define the internal exact-product structure for FP8 multiplication before normalization and rounding
    logic              sign; // Store the product sign obtained by XORing the sign bits of the two FP8 operands
    logic signed [8:0] exponent; // Store the exact-product exponent obtained by adding the two unbiased exponents
    logic        [7:0] significand; // Store the raw Q2.6 significand obtained by multiplying two unified Q1.3 significands
    logic              is_zero; // Indicate that the exact product is positive zero or negative zero
    logic              is_inf; // Indicate that the exact product is positive infinity or negative infinity
    logic              is_nan; // Indicate that the exact product is NaN or an invalid result of infinity times zero
} fp8_product_t; // End the internal FP8 exact-product structure definition

typedef struct packed { // Define a unified structure for multiply-add exponent alignment after IEEE FP32 unpacking
    logic               sign; // Store the sign bit of the original IEEE FP32 encoding
    logic signed [9:0]  exponent; // Store the unbiased signed exponent of a normalized finite number
    logic        [23:0] significand; // Store the significand in a format with one integer bit and twenty-three fractional bits, including the hidden bit
    logic               is_zero; // Indicate that the current decoded result is positive zero or negative zero
    logic               is_subnormal; // Indicate that the current decoded result comes from an FP32 subnormal number
    logic               is_normal; // Indicate that the current decoded result is an ordinary FP32 normalized finite number
    logic               is_inf; // Indicates that the current decoded result is positive or negative infinity
    logic               is_nan; // Indicates that the current decoded result is a quiet or signaling NaN
} fp32_decoded_t; // Ends the unified IEEE FP32 decoded-result structure definition

typedef struct packed { // Defines the intermediate structure for FP32 field classification and before Subnormal normalization
    logic               sign; // Store the sign bit of the original IEEE FP32 encoding
    logic signed [9:0]  exponent; // Stores the base unbiased exponent obtained during classification
    logic        [23:0] significand; // Stores the significand with the hidden bit for Normal or without the hidden bit for Subnormal
    logic               is_zero; // Indicates that the current FP32 encoding is positive or negative zero
    logic               is_subnormal; // Indicates that the current FP32 encoding is subnormal
    logic               is_normal; // Indicates that the current FP32 encoding is a normalized finite number
    logic               is_inf; // Indicates that the current FP32 encoding is positive or negative infinity
    logic               is_nan; // Indicates that the current FP32 encoding is NaN
} fp32_unpacked_t; // Ends the FP32 unpacking intermediate structure definition

endpackage // Ends the fp8_pkg package of common types and constants
