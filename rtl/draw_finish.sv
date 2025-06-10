
module draw_finish (
    input logic clk,
    input logic rst,
    input logic [1:0] level,
    vga_if.in vga_in,
    vga_if.out vga_out,
    input logic [11:0] x_value,
    input logic [11:0] y_value,
    input logic sync_signal
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


    typedef enum logic{
        START = 0,
        FINISH = 1
    } game_state_t;

    // Background and collision map arrays
    logic [11:0] map_start [0:MEM_SIZE-1];
    logic [11:0] map_finish [0:MEM_SIZE-1];
    logic finish;
    logic finish_nxt;
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
            finish         <= '0;
        end else begin
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.rgb    <= rgb_nxt;
            finish         <= finish_nxt;
        end
    end

    initial begin
        $readmemh("../../rtl/Graphics/map_start.data", map_start);
        $readmemh("../../rtl/Graphics/map_finish.data", map_finish);
    end

    logic [11:0] scaled_hcount, scaled_vcount;
    logic [11:0] pixel_address;

    always_comb begin
        scaled_hcount = vga_in.hcount / SCALE_X;
        scaled_vcount = vga_in.vcount / SCALE_Y;
        pixel_address = (scaled_vcount * IMAGE_WIDTH) + scaled_hcount;
    end

    always_comb begin
        finish_nxt = finish;

        if (vga_in.vblnk || vga_in.hblnk) begin
            rgb_nxt = 12'h0_0_0;  // Black color during blanking
        end else begin
            if((level == 2'b11 && y_value > 100 && y_value < 112 && x_value > 500 && x_value < 700) || finish) begin
                rgb_nxt = map_finish[pixel_address];
                finish_nxt = 1;
            end else if (level == 2'b00 && !sync_signal) begin
                rgb_nxt = map_start[pixel_address];
            end
            else begin 
                rgb_nxt = vga_in.rgb;
        end
    end
end
endmodule 




