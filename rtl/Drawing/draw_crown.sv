/*
* Authors:
* * 2025  AGH University of Science and Technology
* MTM UEC2 Final Project
* Miłosz Płonczyński and Tomasz Machnik 
*
* Description:
* Module to handle drawing character on the VGA display based on the character physics.
*/

module draw_crown (
    input  logic clk,
    input  logic rst,

    input logic [11:0]  rgb_pixel,
    output logic [11:0] pixel_addr,

    vga_if.in vga_in,
    vga_if.out vga_out,
    input logic [1:0] level
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

localparam FINISH_X_LEFT = 500;
localparam FINISH_Y_UP = 100;
localparam MAX_LEVEL = 4; 
localparam IMAGE_WIDTH = 64;                    
localparam IMAGE_HEIGHT = 48; 


logic [11:0] rgb_nxt;

localparam C_DELAY_LEN = 3;

logic [C_DELAY_LEN-1:0][10:0] hcount_buf;
logic [C_DELAY_LEN-1:0][10:0] vcount_buf;
logic [C_DELAY_LEN-1:0]  hsync_buf;
logic [C_DELAY_LEN-1:0]  vsync_buf;
logic [C_DELAY_LEN-1:0]  hblnk_buf;
logic [C_DELAY_LEN-1:0]  vblnk_buf;
logic [C_DELAY_LEN-1:0][11:0]  rgb_buf;

always_ff @(posedge clk) begin
    if (rst) begin
        vcount_buf[C_DELAY_LEN-1:0] <= '0;
        vsync_buf[C_DELAY_LEN-1:0]  <= '0;
        vblnk_buf[C_DELAY_LEN-1:0]  <= '0;
        hcount_buf[C_DELAY_LEN-1:0] <= '0;
        hsync_buf[C_DELAY_LEN-1:0] <= '0;
        hblnk_buf[C_DELAY_LEN-1:0]  <= '0;
        rgb_buf[C_DELAY_LEN-1:0] <= '0;

    end else begin
        hcount_buf[C_DELAY_LEN-1:0] <= {hcount_buf[C_DELAY_LEN-2:0], vga_in.hcount};
        vcount_buf[C_DELAY_LEN-1:0] <= {vcount_buf[C_DELAY_LEN-2:0], vga_in.vcount};
        hsync_buf[C_DELAY_LEN-1:0]  <= {hsync_buf[C_DELAY_LEN-2:0], vga_in.hsync};
        vsync_buf[C_DELAY_LEN-1:0]  <= {vsync_buf[C_DELAY_LEN-2:0], vga_in.vsync};
        hblnk_buf[C_DELAY_LEN-1:0]  <= {hblnk_buf[C_DELAY_LEN-2:0], vga_in.hblnk};
        vblnk_buf[C_DELAY_LEN-1:0]  <= {vblnk_buf[C_DELAY_LEN-2:0], vga_in.vblnk};
        rgb_buf[C_DELAY_LEN-1:0]    <= {rgb_buf[C_DELAY_LEN-2:0], vga_in.rgb};
    end
end


always_ff @(posedge clk) begin : rec_ff_blk
    if (rst) begin
        vga_out.vcount <= '0;
        vga_out.vsync  <= '0;
        vga_out.vblnk  <= '0;
        vga_out.hcount <= '0;
        vga_out.hsync  <= '0;
        vga_out.hblnk  <= '0;
        vga_out.rgb    <= '0;
    end else begin
        vga_out.vcount <= vcount_buf[C_DELAY_LEN-1];
        vga_out.vsync  <= vsync_buf[C_DELAY_LEN-1];
        vga_out.vblnk  <= vblnk_buf[C_DELAY_LEN-1];
        vga_out.hcount <= hcount_buf[C_DELAY_LEN-1];
        vga_out.hsync  <= hsync_buf[C_DELAY_LEN-1];
        vga_out.hblnk  <= hblnk_buf[C_DELAY_LEN-1];
        vga_out.rgb    <= rgb_nxt;
    end
end


always_comb begin : bg_comb_blk
    rgb_nxt = rgb_buf[C_DELAY_LEN-1];
    pixel_addr = '0;

    if(level == (MAX_LEVEL - 1)) begin
        if ((vcount_buf[C_DELAY_LEN-1] >= FINISH_Y_UP) && 
            (vcount_buf[C_DELAY_LEN-1] < (FINISH_Y_UP + IMAGE_HEIGHT)) &&
            (hcount_buf[C_DELAY_LEN-1] >= FINISH_X_LEFT) && 
            (hcount_buf[C_DELAY_LEN-1] < (FINISH_X_LEFT + IMAGE_WIDTH))) begin
            
            pixel_addr = ((vcount_buf[C_DELAY_LEN-1] - FINISH_Y_UP) * IMAGE_WIDTH) + 
                          (hcount_buf[C_DELAY_LEN-1] - FINISH_X_LEFT);
            
            if (rgb_pixel != 12'hF_A_C) begin
                rgb_nxt = rgb_pixel;
            end
        end
    end else begin
    end
end


endmodule