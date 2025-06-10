/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * * 2025  AGH University of Science and Technology
 * MTM UEC2 Final Project
 * Miłosz Płonczyński and Tomasz Machnik 
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_vga_basys3 (
        input  wire clk,                     // Synchronnous reset and clock
        input  wire btnC,

        output wire Vsync,                   // VGA Signals
        output wire Hsync,
        output wire [3:0] vgaRed,          
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,

        input wire JA2,                      // UART signals
        input wire JA4,
        input wire JA6,
        input wire JB2,

        output wire JA1,                   
        output wire JA3,
        output wire JA5,   
        output wire JA7,
        output wire JB1,
           
        input wire sw0,                     // Peripheral signals
        inout  wire PS2Clk,
        inout  wire PS2Data

    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    wire clk_ss;
    wire clk_65, clk_100;
    wire locked;
    wire clk_65_mirror;

    (* KEEP = "TRUE" *)
    (* ASYNC_REG = "TRUE" *)
    logic [7:0] safe_start = 0;

    /**
     * Signals assignments
     */

    assign JA1 = clk_65_mirror;

    /**
     * FPGA submodules placement
     */
    clk_wiz_0 clk_wiz_mod(
        .clk_100(clk_100),
        .clk_65(clk_65),
        .locked(locked),
        .clk_in1(clk)
    );

    always_ff @(posedge clk_ss)
    safe_start <= {safe_start[6:0],locked};

    // Mirror pclk on a pin for use by the testbench;
    // not functionally required for this design to work.

    ODDR pclk_oddr (
        .Q(clk_65_mirror),
        .C(clk_65),
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0)
    );


    /**
     *  Project functional top module
     */

    top_vga u_top_vga (                 // Top module instantiation
        .clk(clk_65),
        .clk100(clk_100),
        .rst(btnC),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),

        .rx1(JA2),
        .tx1(JA3),
        .rx2(JA4),
        .tx2(JA5),
        .rx3(JA6),
        .tx3(JA7),
        .sw0(sw0),
        .sync_local(JB1),
        .sync_remote(JB2),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data)
    );

endmodule
