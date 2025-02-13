`timescale 1ns/1ps
module decodificador_pt2272 (
    input clk,      // 3MHz as per specification
    input reset,    // Active-high reset
    input [7:0] A,  // Input address, ternary (0, 1, or FLOAT)
    input cod_i,    // Encoded input data
    output [3:0] D, // Registered received data
    output dv       // Signal indicating new valid data received, synchronized to the same clock domain as output "D"
);

// Frequency divider
wire clk_12kHz;
// Counter (31 cycles)
wire dec_start_count, dec_fim_count;
wire [4:0] dec_count;
// Counter (127 cycles)
wire dec_start_sync, dec_fim_sync;
wire [6:0] dec_count_sync;
// Address comparator
wire [7:0] A_01, A_F;
// Finite State Machine (FSM)
wire error_flag;

// Instantiate the frequency divider to generate a 12kHz clock
freq_div clk12kHz (
    .clk_in(clk), 
    .rst(reset), 
    .clk_out(clk_12kHz)
);

// Instantiate the 31-cycle counter
counter_31 dec_31_counter (
    .clk(clk_12kHz), 
    .rst(reset), 
    .error_flag(error_flag),
    .start(dec_start_count), 
    .count(dec_count), 
    .fim(dec_fim_count)
);

// Instantiate the 127-cycle counter
counter_127 dec_127_counter (
    .clk(clk_12kHz), 
    .rst(reset), 
    .error_flag(error_flag),
    .start(dec_start_sync), 
    .count(dec_count_sync), 
    .fim(dec_fim_sync)
);

// Instantiate the address comparator to detect FLOAT, HIGH, or LOW states
comp_endereco analog (
    .A(A), 
    .A_01(A_01), 
    .A_F(A_F)
);

// Instantiate the FSM (Finite State Machine) for decoding
fsm_dec fsm_dec (
    .clk_12kHz(clk_12kHz), 
    .rst(reset), 
    .A_01(A_01), 
    .A_F(A_F),
    .dado_in_serial(cod_i), 
    .dado_out_parallel(D), 
    .dec_count(dec_count),
    .dec_fim_count(dec_fim_count), 
    .dec_count_sync(dec_count_sync),
    .dec_fim_sync(dec_fim_sync), 
    .dv(dv), 
    .error_flag(error_flag),
    .dec_start_count(dec_start_count), 
    .dec_start_sync(dec_start_sync)
);

endmodule