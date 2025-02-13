/*
 Simulation model for a block capable of detecting the logical state of address pins as 0, 1, or F (floating).
*/

module comp_endereco(
input [7:0] A,         // Address connected to the pin
output reg [7:0] A_01, // Address if high or low level
output reg [7:0] A_F   // Address if FLOAT
);

integer i;

always_comb begin
    for (i = 0; i < 8; i = i + 1) begin
        if (A[i] === 1'bz) begin
            A_01[i] = 1'bx; // Undefined value if floating
            A_F[i]  = 1'b1; // Mark as floating
        end else begin
            A_01[i] = A[i]; // Pass through the valid address value
            A_F[i]  = 1'b0; // Mark as not floating
        end
    end
end

endmodule
