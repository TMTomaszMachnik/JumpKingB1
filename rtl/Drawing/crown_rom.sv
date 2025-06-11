 module crown_rom (
    input  logic clk ,
    input  logic [11:0] address,
    output logic [11:0] rgb
);


/**
 * Local variables and signals
 */

reg [11:0] crown_rom [0:3071];

/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial $readmemh("../../rtl/Graphics/crown.data", crown_rom);


/**
 * Internal logic
 */

always_ff @(posedge clk)
   rgb <= crown_rom[address];

endmodule