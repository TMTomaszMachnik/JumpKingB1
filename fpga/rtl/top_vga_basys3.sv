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
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_vga_basys3 (
        input  wire clk,
        input  wire btnC,
        // input  wire  bleft,
        // input  wire  bright,
        // input  wire  space,
        output wire Vsync,
        output wire Hsync,
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        output wire JA1,
        input wire JA2,
        output wire JA3,
        input wire JA4,
        output wire JA5,
        input wire JA6,
        output wire JA7,

        input wire sw0,

        input wire JB1,
        output wire JB2,

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
    // For details on synthesis attributes used above, see AMD Xilinx UG 901:
    // https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


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

    top_vga u_top_vga (
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

        .local_sync(sw0),
        .sync_out(JB2),
        .sync_in(JB1),

        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data)
        // .bleft(bleft),
        // .bright(bright),
        // .space(space)
    );

endmodule
