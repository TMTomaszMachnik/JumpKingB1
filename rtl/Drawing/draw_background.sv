/*
* Authors:
* * 2025  AGH University of Science and Technology
* MTM UEC2 Final Project
* Miłosz Płonczyński and Tomasz Machnik 
*
* Description:
* Module to draw background image
*/

module draw_background (
    input logic clk,
    input logic rst,

    input logic [1:0] level,

    vga_if.in vga_in,
    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;   // Package with important VGA display constants


    /**
     * Parameters for the background image scaling and size to fit the FPGA memoory
     */

    localparam int IMAGE_WIDTH = 64;                    
    localparam int IMAGE_HEIGHT = 48;                  
    localparam MEM_SIZE = IMAGE_WIDTH * IMAGE_HEIGHT;
    localparam SCALE_X = 16;
    localparam SCALE_Y = 16; 

    typedef enum logic [1:0] {
        LEVEL_0 = 2'd0,
        LEVEL_1 = 2'd1,
        LEVEL_2 = 2'd2,
        LEVEL_3 = 2'd3
    } level_t;  

    /**
     * Background image data arrays
     * Each array corresponds to a different level of the game.
     */

    logic [11:0] bg0 [0:MEM_SIZE-1];
    logic [11:0] bg1 [0:MEM_SIZE-1];
    logic [11:0] bg2 [0:MEM_SIZE-1];
    logic [11:0] bg3 [0:MEM_SIZE-1];
    logic [11:0] rgb_nxt;
    logic [11:0] scaled_hcount, scaled_vcount;
    logic [11:0] pixel_address;

    /**
     * Reset logic
     */
    
    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.rgb    <= rgb_nxt;
        end
    end

    /**
     * Background image data loading from external files
     */

    initial begin
        $readmemh("../../rtl/Graphics/bg0.data", bg0);
        $readmemh("../../rtl/Graphics/bg1.data", bg1);
        $readmemh("../../rtl/Graphics/bg2.data", bg2);
        $readmemh("../../rtl/Graphics/bg3.data", bg3);
    end

    /**
     * Background drawing logic
     */

    always_comb begin
        scaled_hcount = vga_in.hcount / SCALE_X;
        scaled_vcount = vga_in.vcount / SCALE_Y;
        pixel_address = (scaled_vcount * IMAGE_WIDTH) + scaled_hcount;
    end

    always_comb begin
        if (vga_in.vblnk || vga_in.hblnk) begin
            rgb_nxt = 12'h0_0_0;  
        end else begin
            case (level)
                LEVEL_0: begin
                    rgb_nxt = bg0[pixel_address];
                end
                LEVEL_1: begin
                    rgb_nxt = bg1[pixel_address];
                end
                LEVEL_2: begin
                    rgb_nxt = bg2[pixel_address];
                end
                LEVEL_3: begin
                    rgb_nxt = bg3[pixel_address];
                end
                default: begin
                    rgb_nxt = 12'h0_0_0;  
                end
            endcase
        end
    end
endmodule 




