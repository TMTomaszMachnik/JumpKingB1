/*
* Authors:
* * 2025  AGH University of Science and Technology
* MTM UEC2 Final Project
* Miłosz Płonczyński and Tomasz Machnik 
*
* Description:
* Module to handle drawing the crown on the top 
*/

module crown_rom (
    input  logic clk ,
    input  logic [11:0] address,
    output logic [11:0] rgb
);

/**
 * Local variables and internal logic
 */

reg [11:0] crown_rom [0:3071];
initial $readmemh("../../rtl/Graphics/crown.data", crown_rom);


always_ff @(posedge clk)
   rgb <= crown_rom[address];

endmodule