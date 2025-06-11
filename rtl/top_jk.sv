/*
* Authors:
* * 2025  AGH University of Science and Technology
* MTM UEC2 Final Project
* Miłosz Płonczyński and Tomasz Machnik 
*
* Description:
* Game top module connecting all the sub-modules to the clock and together
*/

module top_jk (
        input  logic clk,
        input  logic clk100,
        input  logic rst,

        output logic sync_local,
        input  logic sync_remote, 
        input  logic sw0,

        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b,

        input logic rx1,
        input logic rx2,
        input logic rx3,

        output logic tx1,
        output logic tx2,
        output logic tx3,

        input  ps2_clk,
        input  ps2_data
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
    * Module interfaces
    */

    vga_init_if     vga_if_t_bg();
    vga_if          vga_if_bg_uart();
    vga_if          vga_if_uart_ctl();
    vga_if          vga_if_ctl_r();
    vga_if          vga_if_r_crown();
    vga_if          vga_if_crown_fin();
    vga_if          vga_if_fin_out();

     
    /**
     * Signals assignments
     */
    
    assign vs = vga_if_fin_out.vsync;
    assign hs = vga_if_fin_out.hsync;
    assign {r,g,b} = vga_if_fin_out.rgb;

    /**
     * Wires
     */

    wire [11:0] x_pos;
    wire [11:0] y_pos;
    wire [11:0] rgb_pixel;
    wire [11:0] address;

    wire key_space;
    wire key_right;
    wire key_left;

    wire [1:0] current_level;
    wire [2:0] character_skin;

    wire [7:0] data_1, data_2, data_3;
    wire [11:0] rgb_pixel_uart;
    wire [11:0] address_uart; 

    wire [11:0] rgb_pixel_crown;
    wire [11:0] address_crown; 
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

    draw_background u_draw_background (
        .clk,
        .rst,
        .level(current_level),
        .vga_in(vga_if_t_bg.in),
        .vga_out(vga_if_bg_uart.out)
    );

    wire dummy_uart;
    assign dummy_uart = 0;

    draw_player_UART u_draw_player_UART(
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

    character_skin u_character_skin_uart(
        .clk,
        .rgb(rgb_pixel_uart),
        .address(address_uart),
        .character_skin('0)
    );

    jump_king_ctl u_jump_king_ctl(
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

    uart_ctl u_uart(
        .clk(clk100),
        .rst(rst),
        .data_in_1(x_pos[7:0]),
        .data_out_1(data_1),
        .rx_1(rx1),
        .tx_1(tx1),
        .data_in_2({y_pos[4:0],x_pos[10:8]}),
        .data_out_2(data_2),
        .rx_2(rx2),
        .tx_2(tx2),
        .data_in_3({current_level,y_pos[10:5]}),
        .data_out_3(data_3),
        .rx_3(rx3),
        .tx_3(tx3)
    );

    draw_character u_draw_character (
        .clk,
        .rst,
        .vga_in(vga_if_ctl_r.in),
        .vga_out(vga_if_r_crown.out),
        .pixel_addr(address),
        .rgb_pixel(rgb_pixel),
        .x_value(x_pos),
        .y_value(y_pos)
    );

    draw_crown u_draw_crown (
        .clk,
        .rst,
        .vga_in(vga_if_r_crown.in),
        .vga_out(vga_if_crown_fin.out),
        .pixel_addr(address_crown),
        .rgb_pixel(rgb_pixel_crown),
        .level(current_level) 
    );

    wire sync_signal;
    assign sync_local = sw0;
    assign sync_signal = sync_remote && sync_local;

    draw_finish_screen u_draw_finish(
        .clk,
        .rst,
        .vga_in(vga_if_crown_fin.in),
        .vga_out(vga_if_fin_out.out),
        .level(current_level),
        .x_value(x_pos),
        .y_value(y_pos),
        .level_rm(data_3[7:6]),
        .x_value_rm({dummy_uart,data_2[2:0],data_1}),
        .y_value_rm({dummy_uart,data_3[5:0],data_2[7:3]}),
        .sync_signal(sync_signal)
    );

    character_skin u_character_skin(
        .clk,
        .rgb(rgb_pixel),
        .address(address),
        .character_skin(character_skin)
    );

    crown_rom u_crown_rom(
        .clk,
        .rgb(rgb_pixel_crown),
        .address(address_crown)
    );
endmodule
