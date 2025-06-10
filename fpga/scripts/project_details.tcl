# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc \
    constraints/clk_wiz_0.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/vga_pkg.sv
    ../rtl/vga_timing.sv
    ../rtl/draw_bg.sv
    ../rtl/draw_finish.sv
    ../rtl/draw_rect.sv
    ../rtl/draw_char_uart.sv
    ../rtl/vga_if.sv
    ../rtl/draw_rect_ctl.sv  
    ../rtl/keyboard_ctl.sv
    ../rtl/top_vga.sv
    ../rtl/rom_files/image_rom.sv
    rtl/top_vga_basys3.sv
    ../rtl/UART/data_tx.sv
    ../rtl/UART/uart_ctl.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    ../fpga/rtl/clk_wiz_0.v
    ../fpga/rtl/clk_wiz_0_clk_wiz.v
    ../rtl/PS2Receiver.v
    ../rtl/debouncer.v
    ../rtl/UART/fifo.v
    ../rtl/UART/flag_buf.v
    ../rtl/UART/mod_m_counter.v
    ../rtl/UART/uart_rx.v
    ../rtl/UART/uart_tx.v
    ../rtl/UART/uart.v
}

# Specify VHDL design files location            -- EDIT
#set vhdl_files {
#    ../rtl/mouse_ctrl/MouseCtl.vhd
#    ../rtl/mouse_ctrl/MouseDisplay.vhd
#    ../rtl/mouse_ctrl/Ps2Interface.vhd
#}

#Specify files for a memory initialization     -- EDIT
set mem_files {
  ../rtl/Graphics/micro.data
  ../rtl/Graphics/bg0.data
  ../rtl/Graphics/bg1.data
  ../rtl/Graphics/bg2.data
  ../rtl/Graphics/bg3.data
  ../rtl/Graphics/map_start.data
  ../rtl/Graphics/map_finish.data
  ../rtl/Graphics/micro_curled.data
  ../rtl/Graphics/micro_jump.data
  ../rtl/Graphics/micro_left.data
  ../rtl/Graphics/micro_right.data
}
