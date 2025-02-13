`timescale 1ns/1ps
module codificador_pt2262 (
    input clk,      // 3MHz as per specification
    input reset,    // Active-high reset
    input [7:0] A,  // Input address, ternary (0, 1, or FLOAT)
    input [3:0] D,  // Input data
    output sync,    // Indicates generation of the SYNC symbol
    output cod_o    // Encoded output
);

// Frequency divider
wire clk_12kHz;
// Counter (31 cycles)
wire cod_start_count, cod_fim_count;
wire [4:0] cod_count;
// Counter (127 cycles)
wire cod_start_sync, cod_fim_sync;
wire [6:0] cod_count_sync;
// Address comparator
wire [7:0] A_01, A_F;

// Instantiate the frequency divider to generate a 12kHz clock
freq_div clk12kHz (
    .clk_in(clk), 
    .rst(reset), 
    .clk_out(clk_12kHz)
);

// Instantiate the 31-cycle counter
counter_31 cod_31_counter (
    .clk(clk_12kHz), 
    .rst(reset), 
    .error_flag(0),
    .start(cod_start_count), 
    .count(cod_count), 
    .fim(cod_fim_count)
);

// Instantiate the 127-cycle counter
counter_127 cod_127_counter (
    .clk(clk_12kHz), 
    .rst(reset), 
    .error_flag(0),
    .start(cod_start_sync), 
    .count(cod_count_sync), 
    .fim(cod_fim_sync)
);

// Instantiate the address comparator to detect FLOAT, HIGH, or LOW states
comp_endereco analog (
    .A(A), 
    .A_01(A_01), 
    .A_F(A_F)
);

// Instantiate the FSM (Finite State Machine) for encoding
fsm_cod fsm_cod (
    .clk_12kHz(clk_12kHz), 
    .rst(reset), 
    .A_01(A_01), 
    .A_F(A_F),
    .dado_in(D), 
    .dado_out(cod_o), 
    .count(cod_count), 
    .fim(cod_fim_count),
    .count_sync(cod_count_sync), 
    .fim_sync(cod_fim_sync), 
    .sync_flag(sync),
    .start_count(cod_start_count), 
    .start_sync(cod_start_sync)
);

endmodule