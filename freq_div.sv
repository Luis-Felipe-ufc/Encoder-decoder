`timescale 1ns/1ps
module freq_div #(
    parameter div_factor = 250      // Division factor
) (
    input logic clk_in,             // Input clock
    input logic rst,                // Active-high reset
    output logic clk_out            // Output clock
);

    // Number of bits required for the counter
    localparam int required_bits = $clog2(div_factor/2);

    // Counter to divide the frequency
    logic [required_bits-1:0] counter;

    // Clock division logic
    always_ff @(posedge clk_in or posedge rst) begin    // Asynchronous reset
        if (rst) begin
            counter <= 0;                               // Reset the counter
            clk_out <= 0;                               // Set output clock to low
        end else begin
            if (counter == (div_factor/2 - 1)) begin    // Half cycle reached
                counter <= 0;                           // Reset the counter
                clk_out <= ~clk_out;                    // Toggle the output clock
            end else begin
                counter <= counter + 1;                 // Increment the counter
            end
        end
    end

endmodule