/*
* Authors:
* * 2025  AGH University of Science and Technology
* MTM UEC2 Final Project
* Miłosz Płonczyński and Tomasz Machnik 
*
* Description:
* Module to handle drawing the starting and finish screen of the game
*/

module draw_finish_screen (
    input logic clk,
    input logic rst,

    input logic [1:0] level,
    input logic [11:0] x_value,
    input logic [11:0] y_value,

    input logic [1:0] level_rm,
    input logic [11:0] x_value_rm,
    input logic [11:0] y_value_rm, 

    input logic sync_signal,

    vga_if.in vga_in,
    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    
    /**
     * Parameters for the background image scaling and size to fit the FPGA memoory
     */

    localparam IMAGE_WIDTH = 64; 
    localparam IMAGE_HEIGHT = 48;
    localparam MEM_SIZE = IMAGE_WIDTH * IMAGE_HEIGHT;
    localparam SCALE_X = 4;
    localparam SCALE_Y = 4; 

    /**
     * Parameters for the finish area coordinates
     * 
     */

    localparam FINISH_X_LEFT = 500;
    localparam FINISH_X_RIGHT = 628;
    localparam FINISH_Y_UP = 20;
    localparam FINISH_Y_DOWN = 106;

    logic [11:0] rgb_nxt;
    logic [11:0] map_start [0:MEM_SIZE-1];
    logic [11:0] map_win [0:MEM_SIZE-1];
    logic [11:0] map_lose [0:MEM_SIZE-1];
    logic [11:0] scaled_hcount, scaled_vcount;
    logic [11:0] pixel_address;
    logic win;
    logic win_nxt;
    logic lose;
    logic lose_nxt;


    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
            win            <= '0;
            lose          <= '0;
        end else begin
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.rgb    <= rgb_nxt;
            win            <= win_nxt;
            lose          <= lose_nxt;
        end
    end

    initial begin
        $readmemh("../../rtl/Graphics/map_start.data", map_start);
        $readmemh("../../rtl/Graphics/map_win.data", map_win);
        $readmemh("../../rtl/Graphics/map_lose.data", map_lose);
    end


    always_comb begin
        scaled_hcount = vga_in.hcount >> SCALE_X;
        scaled_vcount = vga_in.vcount >> SCALE_Y;
        pixel_address = (scaled_vcount * IMAGE_WIDTH) + scaled_hcount;
    end

    always_comb begin
        win_nxt = win;
        lose_nxt = lose;

        if (vga_in.vblnk || vga_in.hblnk) begin
            rgb_nxt = 12'h0_0_0;  // Black color during blanking
        end else begin

            if((level == 2'b11 && y_value > FINISH_Y_UP && y_value < FINISH_Y_DOWN && x_value > FINISH_X_LEFT && x_value < FINISH_X_RIGHT) || win) begin
                rgb_nxt = map_win[pixel_address];
                win_nxt = 1;
            end else if((level_rm == 2'b11 && y_value_rm > FINISH_Y_UP && y_value_rm < FINISH_Y_DOWN && x_value_rm > FINISH_X_LEFT && x_value_rm < FINISH_X_RIGHT) || lose) begin
                rgb_nxt = map_lose[pixel_address];
                lose_nxt = 1;
            end
            else if (level == 2'b00 && !sync_signal) begin
                rgb_nxt = map_start[pixel_address];
            end
            else begin 
                rgb_nxt = vga_in.rgb;
            end

        end
    end
endmodule 




