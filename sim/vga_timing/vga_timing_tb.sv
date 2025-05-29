/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for vga_timing module.
 */

module vga_timing_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15;     // 40 MHz


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;

    wire [10:0] vcount, hcount;
    wire        vsync,  hsync;
    wire        vblnk,  hblnk;


    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Reset generation
     */

    initial begin
        rst = 1'b0;
        #(1.25*CLK_PERIOD) rst = 1'b1;
        rst = 1'b1;
        #(2.00*CLK_PERIOD) rst = 1'b0;
    end


    /**
     * Dut placement
     */

    vga_timing dut(
        .clk,
        .rst,
        .vcount,
        .vsync,
        .vblnk,
        .hcount,
        .hsync,
        .hblnk
    );

    /**
     * Tasks and functions
     */

    // Here you can declare tasks with immediate assertions (assert).
    /** 
     * Assertions
     */

    // Here you can declare concurrent assertions (assert property).

    property h_reset_check;
        @(posedge clk) disable iff (rst)
        (hcount == TOTAL_HOR_PIXELS - 1) |-> ##1 hcount == 0;
    endproperty
    ap_h_reset_check: assert property (h_reset_check)
        else $error("Assertion failed: hcount doesn't reset");

    property v_reset_check;
        @(posedge clk) disable iff (rst)
        (vcount == TOTAL_VER_PIXELS - 1 && hcount == TOTAL_HOR_PIXELS -1) |-> ##1 vcount == 0;
    endproperty
    ap_v_reset_check: assert property (v_reset_check)
        else $error("Assertion failed: vcount doesn't reset");

    property hblank_check;
        @(posedge clk) disable iff (rst)
        (hcount > (H_BLANK_START - 1)) && (hcount <= (H_BLANK_END - 1)) |-> hblnk;
    endproperty
    ap_hblank_check: assert property (hblank_check)
        else $error("Assertion failed: hblank requirements not fulfilled");
    
    property hsync_check;
        @(posedge clk) disable iff (rst)
        (hcount > (H_SYNC_START - 1)) && (hcount <= (H_SYNC_END - 1)) |-> hsync;
    endproperty
    ap_hsync_check: assert property (hsync_check)
        else $error("Assertion failed: hsync requirements not fulfilled");

    property vblank_check;
        @(posedge clk) disable iff (rst)
        (vcount > (V_BLANK_START - 1)) && (vcount <= (V_BLANK_END - 1)) |-> vblnk;
    endproperty
    ap_vblank_check: assert property (vblank_check)
        else $error("Assertion failed: vblank requirements not fulfilled");

    property vsync_check;
        @(posedge clk) disable iff (rst)
        (vcount > (V_SYNC_START - 1)) && (vcount <= (V_SYNC_END - 1)) |-> vsync;
    endproperty
    ap_vsync_check: assert property (vsync_check)
        else $error("Assertion failed: vsync requirements not fulfilled");

    /**
     * Main test
     */

    initial begin
        @(posedge rst);
        @(negedge rst);

        wait (vsync == 1'b0);
        @(negedge vsync);
        @(negedge vsync);

        $finish;
    end

endmodule
