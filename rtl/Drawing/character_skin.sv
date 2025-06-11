/*
* Authors:
* * 2025  AGH University of Science and Technology
* MTM UEC2 Final Project
* Miłosz Płonczyński and Tomasz Machnik 
*
* Description:
* Module to handle character skin data for the game.
*/


module character_skin (
    input  logic clk,

    input  logic [2:0] character_skin, 
    input  logic [11:0] address,

    output logic [11:0] rgb           
);

    /**
     * Character skin data arrays and enum logic
     */

    reg [11:0] micro_normal [0:3071];   
    reg [11:0] micro_curled [0:3071];  
    reg [11:0] micro_jump   [0:3071]; 
    reg [11:0] micro_left   [0:3071];
    reg [11:0] micro_right  [0:3071];

    typedef enum logic [2:0] {
        MICRO_IDLE = 3'b000,
        MICRO_PREP = 3'b001,
        MICRO_JUMP   = 3'b010,
        MICRO_LEFT   = 3'b011,
        MICRO_RIGHT  = 3'b100
    } character_skin_t;

    
    initial begin
        $readmemh("../../rtl/Graphics/micro.data", micro_normal);
        $readmemh("../../rtl/Graphics/micro_curled.data", micro_curled);
        $readmemh("../../rtl/Graphics/micro_jump.data", micro_jump);
        $readmemh("../../rtl/Graphics/micro_left.data", micro_left);
        $readmemh("../../rtl/Graphics/micro_right.data", micro_right);
    end

    /**
     * Character frame selection logic
     */
    
    always_ff @(posedge clk) begin
        case (character_skin)
            MICRO_IDLE:   rgb <= micro_normal[address];  
            MICRO_PREP:   rgb <= micro_curled[address];  
            MICRO_JUMP:   rgb <= micro_jump[address];    
            MICRO_LEFT:   rgb <= micro_left[address];
            MICRO_RIGHT:   rgb <= micro_right[address];
            default: rgb <= micro_normal[address]; 
        endcase
    end

endmodule
