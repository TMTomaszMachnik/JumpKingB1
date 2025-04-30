/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Vga timing controller.
 */

 module vga_timing (
    input  logic clk,
    input  logic rst,
    output logic [10:0] vcount,
    output logic vsync,
    output logic vblnk,
    output logic [10:0] hcount,
    output logic hsync,
    output logic hblnk
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

/**
 * Local variables and signals
 */

// Add your signals and variables here.
logic [10:0] next_hcount;
logic [10:0] next_vcount;

/**
 * Internal logic
 */

// Add your code here.

always_ff @(posedge clk) begin: count_blk
    if (rst) begin
        hcount <= '0;
        vcount <= '0;
        hblnk <= '0;
        hsync <= '0;
        vblnk <= '0;
        vsync <= '0;
    end else begin
        hcount <= next_hcount;
        vcount <= next_vcount;
        hblnk <= (next_hcount > (H_BLANK_START - 1)) && (next_hcount <= (H_BLANK_END - 1));
        hsync <= (next_hcount > (H_SYNC_START - 1)) && (next_hcount <= (H_SYNC_END - 1));
        vblnk <= (next_vcount > (V_BLANK_START - 1)) && (next_vcount <= (V_BLANK_END - 1));
        vsync <= (next_vcount > (V_SYNC_START - 1)) && (next_vcount <= (V_SYNC_END - 1));
    end
end

always_comb begin: next_count_blk
    next_hcount = hcount + 1;
    next_vcount = vcount;

    if (hcount == TOTAL_HOR_PIXELS - 1) begin
        next_hcount = '0;
        if (vcount == TOTAL_VER_PIXELS - 1) begin
            next_vcount = '0;
        end else begin
            next_vcount = vcount + 1;
        end
    end
end

endmodule
