`timescale 1ns/1ps
module fsm_dec (
    input logic clk_12kHz,      // Input of externally divided clock
    input logic rst,            // Active low reset
    input logic [7:0] A_01,     // Address input 1
    input logic [7:0] A_F,      // Address input for float check
    input logic dado_in_serial, // Serial data input
    input logic [4:0] dec_count,    // External bit_count counter
    input logic dec_fim_count,      // End of bit_count counter
    input logic [6:0] dec_count_sync, // External sync_count counter
    input logic dec_fim_sync,       // End of sync_count counter
    output logic [3:0] dado_out_parallel, // Parallel data output
    output logic dv,                 // Data valid signal
    output logic dec_start_count,    // Control to start bit_count counter
    output logic dec_start_sync,     // Control to start sync_count counter
    output logic error_flag          // Error flag
);

logic [3:0] prox_etapa; // Next state
logic [3:0] dado;       // Temporary data storage
logic [3:0] dado_ff;    // Registered data
logic [7:0] a_01;       // Temporary address storage
logic [7:0] a_01_ff;    // Registered address
logic [7:0] a_f;        // Temporary float address storage
logic [7:0] a_f_ff;     // Registered float address
logic [7:0] check_a;    // Address check logic

// State enumeration
typedef enum logic [3:0] {
  IDLE  = 4'd0, 
  A0    = 4'd1, 
  A1    = 4'd2, 
  A2    = 4'd3,
  A3    = 4'd4, 
  A4    = 4'd5, 
  A5    = 4'd6, 
  A6    = 4'd7, 
  A7    = 4'd8, 
  D3    = 4'd9, 
  D2    = 4'd10, 
  D1    = 4'd11, 
  D0    = 4'd12, 
  SYNC  = 4'd13
} state_t;

state_t etapa_atual_ff; // Current state register
logic dado_in_ff;       // Registered serial input
logic dv_ff;            // Registered data valid signal
logic p1, p2, p1_ff, p2_ff; // Temporary and registered parity bits
logic error;            // Error signal
logic dec_start_count_ff, dec_start_sync_ff; // Registered control signals

// State machine logic
always_comb begin : maquina_estados
    prox_etapa = etapa_atual_ff; // Default: stay in current state
    dec_start_count_ff = 1;      // Enable bit_count counter by default
    dec_start_sync_ff = 0;       // Disable sync_count counter by default
    dv_ff = 0;                   // Data valid signal is low by default
    error = 0;                   // No error by default
    p1 = p1_ff;                  // Parity bit 1
    p2 = p2_ff;                  // Parity bit 2
    dado = dado_ff;              // Data storage
    if (rst) begin
        prox_etapa = IDLE;       // Reset to IDLE state
    end else begin
        case (etapa_atual_ff)
        IDLE: begin
            dec_start_count_ff = 0; // Disable bit_count counter
            // Wait for a high input to start decoding
            if (dado_in_serial) prox_etapa = A0;
        end
        A0: begin
            // Check the format of the "first part" of the data
            if (dec_count == 5 && !dado_in_serial) begin
                p1 = 0;
            end else if (dec_count == 5 && dado_in_serial) begin
                p1 = 1;
            end
            // Check the format of the "second part" of the data
            if (dec_count == 20 && dado_in_serial)
                p2 = 1;
            else if (dec_count == 20 && !dado_in_serial) 
                p2 = 0;       
            // After 32 cycles:
            if (dec_fim_count) begin
                if (A_F[0]) begin                   // Check if it is float first
                    if (!p1 && p2) prox_etapa = A1; // Verify if the read bit matches the float
                    else error = 1;
                end else begin
                    // Check if the bit is 0
                    if (!p1 && !p2 && !A_01[0]) prox_etapa = A1;
                    // Check if the bit is 1
                    else if (p1 && p2 && A_01[0]) prox_etapa = A1;
                    // Neither 0 nor 1
                    else error = 1;
                end
            end
        end
        // The following states (A1 to A7) follow the same pattern as A0
        // Each state checks the parity bits and transitions to the next state
        A1: begin
            if (dec_count == 5 && !dado_in_serial) begin
                p1 = 0;
            end else if (dec_count == 5 && dado_in_serial) begin
                p1 = 1;
            end
            if (dec_count == 20 && dado_in_serial)
                p2 = 1;
            else if (dec_count == 20 && !dado_in_serial) 
                p2 = 0;        
            if (dec_fim_count) begin
                if (A_F[1]) begin
                    if (!p1 && p2) prox_etapa = A2;
                    else error = 1;
                end else begin
                    if (!p1 && !p2 && !A_01[1]) prox_etapa = A2;
                    else if (p1 && p2 && A_01[1]) prox_etapa = A2;
                    else error = 1;
                end
            end
        end
        A2: begin
            // Same logic as A1
            if (dec_count == 5 && !dado_in_serial) begin
                p1 = 0;
            end else if (dec_count == 5 && dado_in_serial) begin
                p1 = 1;
            end
            if (dec_count == 20 && dado_in_serial)
                p2 = 1;
            else if (dec_count == 20 && !dado_in_serial) 
                p2 = 0;        
            if (dec_fim_count) begin
                if (A_F[2]) begin
                    if (!p1 && p2) prox_etapa = A3;
                    else error = 1;
                end else begin
                    if (!p1 && !p2 && !A_01[2]) prox_etapa = A3;
                    else if (p1 && p2 && A_01[2]) prox_etapa = A3;
                    else error = 1;
                end
            end
        end
        A3: begin
            // Same logic as A1
            if (dec_count == 5 && !dado_in_serial) begin
                p1 = 0;
            end else if (dec_count == 5 && dado_in_serial) begin
                p1 = 1;
            end
            if (dec_count == 20 && dado_in_serial)
                p2 = 1;
            else if (dec_count == 20 && !dado_in_serial) 
                p2 = 0;        
            if (dec_fim_count) begin
                if (A_F[3]) begin
                    if (!p1 && p2) prox_etapa = A4;
                    else error = 1;
                end else begin
                    if (!p1 && !p2 && !A_01[3]) prox_etapa = A4;
                    else if (p1 && p2 && A_01[3]) prox_etapa = A4;
                    else error = 1;
                end
            end
        end
        A4: begin
            // Same logic as A1
            if (dec_count == 5 && !dado_in_serial) begin
                p1 = 0;
            end else if (dec_count == 5 && dado_in_serial) begin
                p1 = 1;
            end
            if (dec_count == 20 && dado_in_serial)
                p2 = 1;
            else if (dec_count == 20 && !dado_in_serial) 
                p2 = 0;        
            if (dec_fim_count) begin
                if (A_F[4]) begin
                    if (!p1 && p2) prox_etapa = A5;
                    else error = 1;
                end else begin
                    if (!p1 && !p2 && !A_01[4]) prox_etapa = A5;
                    else if (p1 && p2 && A_01[4]) prox_etapa = A5;
                    else error = 1;
                end
            end
        end
        A5: begin
            // Same logic as A1
            if (dec_count == 5 && !dado_in_serial) begin
                p1 = 0;
            end else if (dec_count == 5 && dado_in_serial) begin
                p1 = 1;
            end
            if (dec_count == 20 && dado_in_serial)
                p2 = 1;
            else if (dec_count == 20 && !dado_in_serial) 
                p2 = 0;        
            if (dec_fim_count) begin
                if (A_F[5]) begin
                    if (!p1 && p2) prox_etapa = A6;
                    else error = 1;
                end else begin
                    if (!p1 && !p2 && !A_01[5]) prox_etapa = A6;
                    else if (p1 && p2 && A_01[5]) prox_etapa = A6;
                    else error = 1;
                end
            end
        end
        A6: begin
            // Same logic as A1
            if (dec_count == 5 && !dado_in_serial) begin
                p1 = 0;
            end else if (dec_count == 5 && dado_in_serial) begin
                p1 = 1;
            end
            if (dec_count == 20 && dado_in_serial)
                p2 = 1;
            else if (dec_count == 20 && !dado_in_serial) 
                p2 = 0;        
            if (dec_fim_count) begin
                if (A_F[6]) begin
                    if (!p1 && p2) prox_etapa = A7;
                    else error = 1;
                end else begin
                    if (!p1 && !p2 && !A_01[6]) prox_etapa = A7;
                    else if (p1 && p2 && A_01[6]) prox_etapa = A7;
                    else error = 1;
                end
            end
        end
        A7: begin
            // Same logic as A1
            if (dec_count == 5 && !dado_in_serial) begin
                p1 = 0;
            end else if (dec_count == 5 && dado_in_serial) begin
                p1 = 1;
            end
            if (dec_count == 20 && dado_in_serial)
                p2 = 1;
            else if (dec_count == 20 && !dado_in_serial) 
                p2 = 0;        
            if (dec_fim_count) begin
                if (A_F[7]) begin
                    if (!p1 && p2) prox_etapa = D3;
                    else error = 1;
                end else begin
                    if (!p1 && !p2 && !A_01[7]) prox_etapa = D3;
                    else if (p1 && p2 && A_01[7]) prox_etapa = D3;
                    else error = 1;
                end
            end
        end
        D3: begin
            if (dec_count == 5) dado[3] = dado_in_serial;   // Interpret the received data
            if (dec_fim_count) prox_etapa = D2;
        end
        D2: begin
            if (dec_count == 5) dado[2] = dado_in_serial;
            if (dec_fim_count) prox_etapa = D1;
        end
        D1: begin
            if (dec_count == 5) dado[1] = dado_in_serial;
            if (dec_fim_count) prox_etapa = D0;
        end
        D0: begin
            if (dec_count == 5) dado[0] = dado_in_serial;
            if (dec_fim_count) prox_etapa = SYNC;
        end
        SYNC: begin
            dec_start_count_ff = 0;                         // Stop the 32-cycle counter
            dec_start_sync_ff = 1;                          // Start the 128-cycle counter
            if (dec_count_sync == 17 && !dado_in_serial)    // Check if it is a sync
            dv_ff = 1;                                      // Set data valid signal
            if (dec_fim_sync) prox_etapa = IDLE;            // Return to IDLE after 128 cycles
        end
        default: prox_etapa = IDLE;
        endcase
    end
end

// Register logic
always_ff @(posedge clk_12kHz or posedge rst) begin
    if (rst) begin
        etapa_atual_ff <= IDLE;
        dado_in_ff <= 4'b0;
        dado_out_parallel <= 4'b0;
        dado_ff <= 4'b0;
        p1_ff <= 0;
        p2_ff <= 0;
    end else if (error) begin
        etapa_atual_ff <= IDLE;
        dado_in_ff <= 4'b0;
        dado_out_parallel <= 4'b0;
        dado_ff <= 4'b0;
        p1_ff <= 0;
        p2_ff <= 0;
    end else begin
        etapa_atual_ff <= prox_etapa;
        dado_in_ff <= dado_in_serial;
        dado_ff <= dado;
        p1_ff <= p1;
        p2_ff <= p2;
        dv = dv_ff;                         // Immediate assignment
        if (dv) dado_out_parallel <= dado;  // Update output only if data is valid   
    end
end

assign dec_start_count = dec_start_count_ff;
assign dec_start_sync = dec_start_sync_ff;
assign error_flag = error;

endmodule