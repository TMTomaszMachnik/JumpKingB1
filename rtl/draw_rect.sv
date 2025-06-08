module draw_rect (
    input  logic clk,
    input  logic rst,

    input logic [11:0]  rgb_pixel,
    input  logic  [11:0]  x_value,
    input  logic  [11:0]  y_value,

    vga_if.in vga_in,

    vga_if.out vga_out,

    output logic [11:0] pixel_addr
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

localparam REC_WIDTH = 47;
localparam REC_HEIGHT = 63;

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

    if ((vcount_buf[C_DELAY_LEN-1] >= y_value) && 
        (vcount_buf[C_DELAY_LEN-1] < (y_value + REC_HEIGHT)) &&
        (hcount_buf[C_DELAY_LEN-1] >= x_value) && 
        (hcount_buf[C_DELAY_LEN-1] < (x_value + REC_WIDTH))) begin
        
        pixel_addr = (vcount_buf[C_DELAY_LEN-1] - y_value) * (REC_WIDTH+1) + 
                    (hcount_buf[C_DELAY_LEN-1] - x_value);
        
        if (rgb_pixel != 12'hF_F_F) begin
            rgb_nxt = rgb_pixel;
        end
    end
end


endmodule