/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Package with vga related constants.
 */

 package vga_pkg;

    // Parameters for VGA Display 1024x768 @ 60fps using a 65 MHz clock;
    localparam HOR_PIXELS = 1024;
    localparam VER_PIXELS = 768;

    localparam TOTAL_HOR_PIXELS = 1344;
    localparam TOTAL_VER_PIXELS = 806;

    localparam H_BLANK_START = 1024;
    localparam H_BLANK_END = 1344;

    localparam V_BLANK_START = 768;
    localparam V_BLANK_END = 806;
    
    localparam H_SYNC_START = 1048;
    localparam H_SYNC_END = 1184;

    localparam V_SYNC_START = 771;
    localparam V_SYNC_END = 777;

    // Add VGA timing parameters here and refer to them in other modules.

endpackage
