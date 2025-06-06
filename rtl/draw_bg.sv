module draw_bg (
    input logic clk,
    input logic rst,
    input logic [1:0] level,
    vga_if.in vga_in,
    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    localparam int IMAGE_WIDTH = 64; 
    localparam int IMAGE_HEIGHT = 48;
    localparam MEM_SIZE = IMAGE_WIDTH * IMAGE_HEIGHT;
    localparam SCALE_X = 16;
    localparam SCALE_Y = 16; 
    logic [11:0] rgb_nxt;



    typedef enum logic [1:0] {
        LEVEL_0 = 2'd0,
        LEVEL_1 = 2'd1
    } level_t;

    

    logic [11:0] bg0 [0:MEM_SIZE-1];
    logic [11:0] bg1 [0:MEM_SIZE-1];



    // VGA signals
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

    initial begin
        $readmemh("../../rtl/Graphics/bg0.data", bg0);
        $readmemh("../../rtl/Graphics/bg1.data", bg1);
    end

    logic [11:0] scaled_hcount, scaled_vcount;
    logic [11:0] pixel_address;

    always_comb begin
        scaled_hcount = vga_in.hcount / SCALE_X;
        scaled_vcount = vga_in.vcount / SCALE_Y;
        pixel_address = (scaled_vcount * IMAGE_WIDTH) + scaled_hcount;
    end

    always_comb begin
        if (vga_in.vblnk || vga_in.hblnk) begin
            rgb_nxt = 12'h0_0_0;  // Black color during blanking
        end else begin
            case (level)
                LEVEL_0: begin
                    rgb_nxt = bg0[pixel_address];
                end
                LEVEL_1: begin
                    rgb_nxt = bg1[pixel_address];
                end
                default: begin
                    rgb_nxt = 12'h0_0_0;  // Default to black if level is unknown
                end
            endcase
        end
    end
endmodule
