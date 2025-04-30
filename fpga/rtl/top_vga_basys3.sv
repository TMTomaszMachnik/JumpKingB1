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
        output wire Vsync,
        output wire Hsync,
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        output wire JA1,

        inout  wire PS2Clk,
        inout  wire PS2Data

    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    wire clk_ss;
    wire clk_40, clk_100;
    wire locked;
    wire clk_40_mirror;

    (* KEEP = "TRUE" *)
    (* ASYNC_REG = "TRUE" *)
    logic [7:0] safe_start = 0;
    // For details on synthesis attributes used above, see AMD Xilinx UG 901:
    // https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


    /**
     * Signals assignments
     */

    assign JA1 = clk_40_mirror;


    /**
     * FPGA submodules placement
     */
    clk_wiz_0 clk_wiz_mod(
        .clk100MHz(clk_100),
        .clk40Mhz(clk_40),
        .locked(locked),
        .clk(clk)
    );

    always_ff @(posedge clk_ss)
    safe_start <= {safe_start[6:0],locked};

    // Mirror pclk on a pin for use by the testbench;
    // not functionally required for this design to work.

    ODDR pclk_oddr (
        .Q(clk_40_mirror),
        .C(clk_40),
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
        .clk(clk_40),
        .clk100(clk_100),
        .rst(btnC),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),

        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data)
    );

endmodule
