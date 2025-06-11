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
set project_name JumpKing

# Top module name                               -- EDIT
set top_module JumpKing

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/JumpKing.xdc \
    constraints/clk_wiz_0.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/VGA_Display/vga_pkg.sv
    ../rtl/VGA_Display/vga_timing.sv
    ../rtl/VGA_Display/vga_if.sv
    ../rtl/VGA_Display/vga_init_if.sv
    ../rtl/Drawing/draw_background.sv
    ../rtl/Drawing/draw_crown.sv
    ../rtl/Drawing/crown_rom.sv
    ../rtl/Drawing/draw_finish_screen.sv
    ../rtl/Drawing/draw_character.sv
    ../rtl/Drawing/draw_player_UART.sv
    ../rtl/Drawing/character_skin.sv
    ../rtl/Keyboard/keyboard_ctl.sv
    ../rtl/UART/data_tx.sv
    ../rtl/UART/uart_ctl.sv
    ../rtl/jump_king_ctl.sv  
    ../rtl/top_jk.sv
    rtl/JumpKing.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    ../fpga/rtl/clk_wiz_0.v
    ../fpga/rtl/clk_wiz_0_clk_wiz.v
    ../rtl/Keyboard/PS2Receiver.v
    ../rtl/Keyboard/debouncer.v
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
  ../rtl/Graphics/map_win.data
  ../rtl/Graphics/map_lose.data
  ../rtl/Graphics/micro_curled.data
  ../rtl/Graphics/micro_jump.data
  ../rtl/Graphics/micro_left.data
  ../rtl/Graphics/micro_right.data
  ../rtl/Graphics/crown.data
}
