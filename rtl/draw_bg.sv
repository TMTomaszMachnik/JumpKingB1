// /**
//  * Copyright (C) 2025  AGH University of Science and Technology
//  * MTM UEC2
//  * Author: Piotr Kaczmarczyk
//  *
//  * Description:
//  * Draw background.
//  */

// module draw_bg (
//         input  logic clk,
//         input  logic rst,

//         vga_if.in vga_in,

//         vga_if.out vga_out
//     );

//     timeunit 1ns;
//     timeprecision 1ps;

//     import vga_pkg::*;


//     /**
//      * Local variables and signals
//      */

//     logic [11:0] rgb_nxt;


//     /**
//      * Internal logic
//      */

//     always_ff @(posedge clk) begin : bg_ff_blk
//         if (rst) begin
//             vga_out.vcount <= '0;
//             vga_out.vsync  <= '0;
//             vga_out.vblnk  <= '0;
//             vga_out.hcount <= '0;
//             vga_out.hsync <= '0;
//             vga_out.hblnk <= '0;
//             vga_out.rgb    <= '0;
//         end else begin
//             vga_out.vcount <= vga_in.vcount;
//             vga_out.vsync  <= vga_in.vsync;
//             vga_out.vblnk  <= vga_in.vblnk;
//             vga_out.hcount <= vga_in.hcount;
//             vga_out.hsync  <= vga_in.hsync;
//             vga_out.hblnk  <= vga_in.hblnk;
//             vga_out.rgb    <= rgb_nxt;
//         end
//     end

//     always_comb begin : bg_comb_blk
//         if (vga_in.vblnk || vga_in.hblnk) begin             // Blanking region:
//             rgb_nxt = 12'h0_0_0;                    // - make it it black.
//         end else begin                              // Active region:
//             if (vga_in.vcount == 0)                     // - top edge:
//                 rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
//             else if (vga_in.vcount == VER_PIXELS - 1)   // - bottom edge:
//                 rgb_nxt = 12'hf_0_0;                // - - make a red line.
//             else if (vga_in.hcount == 0)                // - left edge:
//                 rgb_nxt = 12'h0_f_0;                // - - make a green line.
//             else if (vga_in.hcount == HOR_PIXELS - 1)   // - right edge:
//                 rgb_nxt = 12'h0_0_f;                // - - make a blue line.
//             else if(((vga_in.hcount >= 100 && vga_in.hcount <= 120) && (vga_in.vcount >= 100 && vga_in.vcount <= 400)) ||
//             (((vga_in.hcount >= vga_in.vcount) && (vga_in.hcount <= vga_in.vcount + 30)) && (vga_in.hcount >= 100 && vga_in.hcount <= 190)) ||
//             (((vga_in.hcount + vga_in.vcount >= 350) && (vga_in.hcount + vga_in.vcount <= 380)) && (vga_in.hcount >= 190 && vga_in.hcount <= 280)) ||
//             ((vga_in.hcount >= 260 && vga_in.hcount <= 280) && (vga_in.vcount >= 100 && vga_in.vcount <= 400)) ||
//             ((vga_in.hcount >= 328 && vga_in.hcount <= 348) && (vga_in.vcount >= 70 && vga_in.vcount <= 400)) ||
//             ((vga_in.hcount >= 349 && vga_in.hcount <= 497) && (vga_in.vcount >= 70 && vga_in.vcount <= 90)) ||
//             ((vga_in.hcount >= 349 && vga_in.hcount <= 497) && (vga_in.vcount >= 200 && vga_in.vcount <= 220)) ||
//             ((vga_in.hcount >= 477 && vga_in.hcount <= 497) && (vga_in.vcount >= 91 && vga_in.vcount <= 199)))
//                 rgb_nxt = 12'hf_f_f;
//             else                                    // The rest of active display pixels:
//                 rgb_nxt = 12'h8_8_8;                // - fill with gray.
//         end
//     end

// endmodule

module draw_bg (
    input logic clk,
    input logic rst,
    vga_if.in vga_in, 
    vga_if.out vga_out 
);

    timeunit 1ns;
    timeprecision 1ps;
    
    import vga_pkg::*;

    localparam int IMAGE_WIDTH = 64; 
    localparam int IMAGE_HEIGHT = 48;
    // localparam int SCALE_X = VER_PIXELS / IMAGE_WIDTH; 
    // localparam int SCALE_Y = HOR_PIXELS / IMAGE_HEIGHT;
    localparam SCALE_X = 13;
    localparam SCALE_Y = 13; 
    logic [11:0] rgb_nxt;
    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hcount <= '0;
            vga_out.hsync <= '0;
            vga_out.hblnk <= '0;
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
    
    
    logic [11:0] bg_memory [0:IMAGE_WIDTH*IMAGE_HEIGHT-1];

    initial begin
        // $readmemh("../../rtl/Graphics/background.data", bg_memory);
        $readmemh("../rtl/Graphics/background.data", bg_memory);
        // $display("Loaded %d pixels from memory file", IMAGE_WIDTH*IMAGE_HEIGHT);
    end

    logic [11:0] scaled_hcount, scaled_vcount;
    logic [11:0] pixel_address;

    always_comb begin
        scaled_hcount = vga_in.hcount / (SCALE_X);
        scaled_vcount = vga_in.vcount / (SCALE_Y);
        pixel_address = (scaled_vcount * IMAGE_WIDTH) + scaled_hcount;
    end

    always_comb begin : dupa
        if (vga_in.vblnk || vga_in.hblnk) begin
            rgb_nxt = 12'h0_0_0;
        end else begin
        rgb_nxt = bg_memory[pixel_address]; 
    end
end


endmodule