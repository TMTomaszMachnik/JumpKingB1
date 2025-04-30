/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Package with vga related constants.
 */

 package vga_pkg;

    // Parameters for VGA Display 800 x 600 @ 60fps using a 40 MHz clock;
    localparam HOR_PIXELS = 800;
    localparam VER_PIXELS = 600;

    localparam TOTAL_HOR_PIXELS = 1056;
    localparam TOTAL_VER_PIXELS = 628;

    localparam H_BLANK_START = 800;
    localparam H_BLANK_END = 1056;

    localparam V_BLANK_START = 600;
    localparam V_BLANK_END = 628;
    
    localparam H_SYNC_START = 840;
    localparam H_SYNC_END = 968;

    localparam V_SYNC_START = 601;
    localparam V_SYNC_END = 605;

    // Add VGA timing parameters here and refer to them in other modules.

endpackage
