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
 * Testbench for top_vga.
 * Thanks to the tiff_writer module, an expected image
 * produced by the project is exported to a tif file.
 * Since the vs signal is connected to the go input of
 * the tiff_writer, the first (top-left) pixel of the tif
 * will not correspond to the vga project (0,0) pixel.
 * The active image (not blanked space) in the tif file
 * will be shifted down by the number of lines equal to
 * the difference between VER_SYNC_START and VER_TOTAL_TIME.
 */

module top_jk_tb;

    timeunit 1ns;
    timeprecision 1ps;
    import vga_pkg::*;
    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15.38;     // 65 MHz
    localparam CLK_PERIOD100 = 10;     // 100 MHz


    /**
     * Local variables and signals
     */

    logic clk, clk100, rst;
    wire vs, hs;
    wire [3:0] r, g, b;


    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        clk100 = 1'b0;
        forever #(CLK_PERIOD100/2) clk100 = ~clk100;
    end


    /**
     * Submodules instances
     */

    top_jk dut (
        .clk(clk),
        .clk100(clk100),
        .rst(rst),
        .vs(vs),
        .hs(hs),
        .r(r),
        .g(g),
        .b(b)
    );

    tiff_writer #(
        // .XDIM(16'd1056),
        // .YDIM(16'd628),
            .XDIM(TOTAL_HOR_PIXELS),
            .YDIM(TOTAL_VER_PIXELS),

        .FILE_DIR("../../results")
    ) u_tiff_writer (
        .clk(clk),
        .r({r,r}), // fabricate an 8-bit value
        .g({g,g}), // fabricate an 8-bit value
        .b({b,b}), // fabricate an 8-bit value
        .go(vs)
    );


    /**
     * Main test
     */
    // always @(posedge clk) begin
    //     $display("dut.r = %h, dut.g = %h, dut.b = %h", r, g, b);
    // end

    initial begin
        rst = 1'b0;
        # 30 rst = 1'b1;
        # 30 rst = 1'b0;



        // force dut.u_draw_rect.x_value = 12'd328;
        // force dut.u_draw_rect.y_value = 12'd70; 


        $display("If simulation ends before the testbench");
        $display("completes, use the menu option to run all.");
        $display("Prepare to wait a long time...");

        wait (vs == 1'b0);
        @(negedge vs) $display("Info: negedge VS at %t",$time);
        @(negedge vs) $display("Info: negedge VS at %t",$time);

        // End the simulation.
        $display("Simulation is over, check the waveforms.");
        $finish;
    end

endmodule
