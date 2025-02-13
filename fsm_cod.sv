`timescale 1ns/1ps
module fsm_cod (
    input logic clk_12kHz,          // Input of externally divided clock
    input logic rst,                // Active-high reset
    input logic [7:0] A_01,         // Comes from comp_endereco
    input logic [7:0] A_F,          // Comes from comp_endereco
    input logic [3:0] dado_in,      // Input data
    input logic [4:0] count,        // External bit_count counter
    input logic fim,                // End of bit_count counter
    input logic [6:0] count_sync,   // External sync_count counter
    input logic fim_sync,           // End of sync_count counter
    output logic dado_out,          // Output data
    output logic sync_flag,         // Indicates the 'sync' stage
    output logic start_count,       // Control to start bit_count counter
    output logic start_sync         // Control to start sync_count counter   
);

logic [3:0] prox_etapa;
logic ready;                        // Condition to exit IDLE

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

state_t etapa_atual_ff;

// Store inputs
logic [3:0] dado_in_ff;
logic start_count_ff, start_sync_ff;

always_ff @(posedge clk_12kHz or posedge rst) begin
    if (rst) begin                                  // Encoding starts on reset
        ready <= 1;
    end else if (etapa_atual_ff == SYNC) begin
        ready <= 1;                                 // Starts new encoding at SYNC
    end else if (etapa_atual_ff == A0) begin
        ready <= 0;                                 // Blocks new encoding
    end
end

always_comb begin : maquina_estados
    dado_out = 1;                                   // Output is 1 by default
    prox_etapa = etapa_atual_ff;                    // Stay in the current state if nothing happens
    start_count_ff = 1;                             // Enable counting up to 31
    start_sync_ff = 0;                              // Disable counting up to 127
    sync_flag = 0;                                  // Sync flag is low by default
    if (rst) begin
        dado_out = 0;
        prox_etapa = IDLE;                          // Go back to IDLE on reset
    end else begin
        case (etapa_atual_ff)
        // Wait for 'ready' to be high to start encoding
        IDLE: begin
            dado_out = 0;
            start_count_ff = 0;
            if (ready) prox_etapa = A0;     // If ready = 1, move to the next stage
        end
        // Encode bit A0
        A0: begin
            // Check if it is float (priority)
            if (A_F[0])  
                if ((count >= 4 && count <= 15) || count >= 28) dado_out = 0;
                else dado_out = 1;
            else begin
                // Check if the bit is 0
                if (!A_01[0] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
                // Check if the bit is 1
                if (A_01[0] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            end
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = A1;
        end
        // Encode bit A1
        A1: begin
            // Check if it is float (priority)
            if (A_F[1])  
                if ((count >= 4 && count <= 15) || count >= 28) dado_out = 0;
                else dado_out = 1;
            else begin
                // Check if the bit is 0
                if (!A_01[1] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
                // Check if the bit is 1
                if (A_01[1] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            end
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = A2;
        end
        // Encode bit A2
        A2: begin
            // Check if it is float (priority)
            if (A_F[2])  
                if ((count >= 4 && count <= 15) || count >= 28) dado_out = 0;
                else dado_out = 1;
            else begin
                // Check if the bit is 0
                if (!A_01[2] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
                // Check if the bit is 1
                if (A_01[2] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            end
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = A3;
        end
        // Encode bit A3
        A3: begin
            // Check if it is float (priority)
            if (A_F[3])  
                if ((count >= 4 && count <= 15) || count >= 28) dado_out = 0;
                else dado_out = 1;
            else begin
                // Check if the bit is 0
                if (!A_01[3] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
                // Check if the bit is 1
                if (A_01[3] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            end
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = A4;
        end
        // Encode bit A4
        A4: begin
            // Check if it is float (priority)
            if (A_F[4])  
                if ((count >= 4 && count <= 15) || count >= 28) dado_out = 0;
                else dado_out = 1;
            else begin
                // Check if the bit is 0
                if (!A_01[4] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
                // Check if the bit is 1
                if (A_01[4] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            end
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = A5;
        end
        // Encode bit A5
        A5: begin
            // Check if it is float (priority)
            if (A_F[5])  
                if ((count >= 4 && count <= 15) || count >= 28) dado_out = 0;
                else dado_out = 1;
            else begin
                // Check if the bit is 0
                if (!A_01[5] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
                // Check if the bit is 1
                if (A_01[5] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            end
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = A6;
        end
        // Encode bit A6
        A6: begin
            // Check if it is float (priority)
            if (A_F[6])  
                if ((count >= 4 && count <= 15) || count >= 28) dado_out = 0;
                else dado_out = 1;
            else begin
                // Check if the bit is 0
                if (!A_01[6] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
                // Check if the bit is 1
                if (A_01[6] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            end
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = A7;
        end
        // Encode bit A7
        A7: begin
            // Check if it is float (priority)
            if (A_F[7])  
                if ((count >= 4 && count <= 15) || count >= 28) dado_out = 0;
                else dado_out = 1;
            else begin
                // Check if the bit is 0
                if (!A_01[7] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
                // Check if the bit is 1
                if (A_01[7] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            end
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = D3;
        end
        // Encode bit D3
        D3: begin
            // Check if the bit is 0
            if (!dado_in_ff[3] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
            // Check if the bit is 1
            if (dado_in_ff[3] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = D2;
        end
        // Encode bit D2
        D2: begin
            // Check if the bit is 0
            if (!dado_in_ff[2] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
            // Check if the bit is 1
            if (dado_in_ff[2] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = D1;
        end
        // Encode bit D1
        D1: begin
            // Check if the bit is 0
            if (!dado_in_ff[1] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
            // Check if the bit is 1
            if (dado_in_ff[1] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            // After 32 cycles, move to the next bit
            if (fim) prox_etapa = D0;
        end
        // Encode bit D0
        D0: begin
            // Check if the bit is 0
            if (!dado_in_ff[0] && ((count >= 4 && count <= 15) || count >= 20)) dado_out = 0;
            // Check if the bit is 1
            if (dado_in_ff[0] && ((count >= 12 && count <= 15) || count >= 28)) dado_out = 0;
            // After 32 cycles, move to SYNC
            if (fim) prox_etapa = SYNC;
        end
        // Send SYNC
        SYNC: begin
            sync_flag = 1;                      // Set the SYNC flag
            start_count_ff = 0;                 // Stop the 32-cycle counter
            start_sync_ff = 1;                  // Start the 128-cycle counter
            if (count_sync >= 4) dado_out = 0;  // Send the signal
            if (fim_sync) prox_etapa = IDLE;    // After 128 cycles, return to IDLE
        end
        // Default
        default: begin
            dado_out = 0;
            prox_etapa = IDLE;
        end
        endcase
    end
end

always_ff @(posedge clk_12kHz or posedge rst) begin
    if (rst) begin
        etapa_atual_ff <= IDLE;
        dado_in_ff <= 4'b0;
    end else begin
        etapa_atual_ff <= prox_etapa;
        if (ready) dado_in_ff <= dado_in;   // Condition the change of the data to be transmitted
    end
end

assign start_count = start_count_ff;
assign start_sync = start_sync_ff;

endmodule