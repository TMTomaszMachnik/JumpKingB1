/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

module top_vga (
        input  logic clk,
        input  logic clk100,
        input  logic rst,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b,

        input  ps2_clk,
        input  ps2_data,

        input wire bleft,
        input wire bright,
        input wire space
    );

    timeunit 1ns;
    timeprecision 1ps;

    vga_if vga_if_t_bg();
    vga_if vga_if_ctl_r();
    vga_if vga_if_r_out();
    vga_if vga_if_bg_ctl();


    /**
     * Local variables and signals
     */

     
    /**
     * Signals assignments
     */
    
    assign vs = vga_if_r_out.vsync;
    assign hs = vga_if_r_out.hsync;
    assign {r,g,b} = vga_if_r_out.rgb;

    wire [11:0] x_pos;
    wire [11:0] y_pos;
    wire [11:0] rgb_pixel;
    wire [11:0] address;

    wire left;
    wire [11:0] x_pos_pre;
    wire [11:0] y_pos_pre;
    wire [15:0] keyboard_data;
    wire f_EOT;

    wire [1:0] char_state;

    wire key_space;
    wire key_right;
    wire key_left;

    wire [1:0] current_level;

    /**
     * Submodules instances
     */

    // keyboard_ctl u_keyboard_ctl (
    //     .clk(clk100),
    //     .rst(rst),
    //     .ps2_clk(ps2_clk),
    //     .ps2_data(ps2_data),
    //     .key_space(key_space),
    //     .key_right(key_right),
    //     .key_left(key_left)
    // );


    vga_timing u_vga_timing (
        .clk,
        .rst,
        .vcount (vga_if_t_bg.vcount),
        .vsync  (vga_if_t_bg.vsync),
        .vblnk  (vga_if_t_bg.vblnk),
        .hcount (vga_if_t_bg.hcount),
        .hsync  (vga_if_t_bg.hsync),
        .hblnk  (vga_if_t_bg.hblnk)
    );

    draw_bg u_draw_bg (
        .clk,
        .rst,
        .level(current_level),
        .vga_in(vga_if_t_bg.in),
        .vga_out(vga_if_bg_ctl.out)
    );
    
    draw_rect_ctl u_draw_rect_ctl(
        .clk(clk100),
        .rst(rst),
        .key_space(space),
        .key_right(bright),
        .key_left(bleft),
        .value_x(x_pos),
        .value_y(y_pos),
        .character_state(char_state),
        .level(current_level),
        .vga_in(vga_if_bg_ctl.in),
        .vga_out(vga_if_ctl_r.out)
    );

    draw_rect u_draw_rect (
        .clk,
        .rst,
        .vga_in(vga_if_ctl_r.in),
        .vga_out(vga_if_r_out.out),
        .pixel_addr(address),
        .rgb_pixel(rgb_pixel),
        .x_value(x_pos),
        .y_value(y_pos)
    );

    image_rom u_image_rom(
        .clk,
        .rgb(rgb_pixel),
        .address(address),
        .character_state(char_state)
    );

    // draw_rect_ctl u_draw_rect_ctl(
    //     .clk(clk100),
    //     .rst(rst),
    //     .key_space(key_space),
    //     .key_right(key_right),
    //     .key_left(key_left),
    //     .value_x(x_pos),
    //     .value_y(y_pos),
    //     .character_state(char_state)
    // );

endmodule
