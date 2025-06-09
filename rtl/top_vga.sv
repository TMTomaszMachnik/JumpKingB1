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

        input logic rx1,
        output logic tx1,
        input logic rx2,
        output logic tx2,
        input logic rx3,
        output logic tx3,

        input  ps2_clk,
        input  ps2_data

        // input wire bleft,
        // input wire bright,
        // input wire space
    );

    timeunit 1ns;
    timeprecision 1ps;

    vga_if vga_if_t_bg();
    vga_if vga_if_bg_uart();
    vga_if vga_if_uart_ctl();
    vga_if vga_if_ctl_r();
    vga_if vga_if_r_out();


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

    wire [2:0] character_skin;

    wire key_space;
    wire key_right;
    wire key_left;

    wire [1:0] current_level;
    wire [1:0] collision [0:3071];
    /**
     * Submodules instances
     */

    keyboard_ctl u_keyboard_ctl (
        .clk(clk100),
        .rst(rst),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .key_space(key_space),
        .key_right(key_right),
        .key_left(key_left)
    );


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
        .vga_out(vga_if_bg_uart.out)
    );

    wire [7:0] data_1, data_2, data_3;
    wire [11:0] rgb_pixel_uart;
    wire [11:0] address_uart; 

    wire dummy_uart;
    assign dummy_uart = 0;

    draw_char_uart u_draw_char_uart(
        .clk,
        .rst,
        .level_home(current_level),
        .level_remote(data_3[7:6]),
        .vga_in(vga_if_bg_uart.in),
        .vga_out(vga_if_uart_ctl.out),
        .pixel_addr(address_uart),
        .rgb_pixel(rgb_pixel_uart),
        .x_value({dummy_uart,data_2[2:0],data_1}),
        .y_value({dummy_uart,data_3[5:0],data_2[7:3]})
    );

    image_rom u_image_rom_uart(
        .clk,
        .rgb(rgb_pixel_uart),
        .address(address_uart),
        .character_skin('0)
    );

    draw_rect_ctl u_draw_rect_ctl(
        .clk(clk100),
        .rst(rst),
        .key_space(key_space),
        .key_right(key_right),
        .key_left(key_left),
        .value_x(x_pos),
        .value_y(y_pos),
        .character_skin(character_skin),
        .level(current_level),
        .vga_in(vga_if_uart_ctl.in),
        .vga_out(vga_if_ctl_r.out)
    );

    uart_ctl uart_1(
        .clk(clk100),
        .rst(rst),
        .data_in(x_pos[7:0]),
        .data_out(data_1),
        .rx(rx1),
        .tx(tx1)
    );

    uart_ctl uart_2(
        .clk(clk100),
        .rst(rst),
        .data_in({y_pos[4:0],x_pos[10:8]}),
        .data_out(data_2),
        .rx(rx2),
        .tx(tx2)
    );

    uart_ctl uart_3(
        .clk(clk100),
        .rst(rst),
        .data_in({current_level,y_pos[10:5]}),
        .data_out(data_3),
        .rx(rx3),
        .tx(tx3)
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
        .character_skin(character_skin)
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
