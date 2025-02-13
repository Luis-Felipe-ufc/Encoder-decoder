`timescale 1ns/1ps
module counter_127 #(
    parameter val_max = 127,    // Maximum value of the counter (can be adjusted when instantiating the module)
    parameter required_bits = $clog2(val_max + 1) // +1 because counting starts from zero
) (
    input logic clk,                        // Clock signal
    input logic rst,                        // Reset (active high)
    input logic start,
    input logic error_flag,
    output logic [required_bits-1:0] count, // Bit counter with required bits
    output logic fim                        // "End" signal (when the counter reaches the maximum value)
);

    // Registers to store the current count value
    logic [required_bits-1:0] contagem_ff;

    // Register logic (stores the count)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            contagem_ff <= 0;  // Reset the counter
        end else begin
            if (contagem_ff == val_max) begin
                contagem_ff <= 0;  // Reset when reaching the maximum value
            end else begin
                if (start)
                contagem_ff <= contagem_ff + 1;  // Increment the counter
            end
            if (error_flag) contagem_ff <= 0;
        end
    end

    // Assignment of output signals
    assign fim = (contagem_ff == val_max);  // "End" signal when the counter reaches the maximum value
    assign count = contagem_ff;  // Current value of the counter

endmodule