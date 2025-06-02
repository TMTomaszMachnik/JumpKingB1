//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   template_fsm
 Author:        Robert Szczygiel
 Version:       1.0
 Last modified: 2023-05-18
 Coding style: safe with FPGA sync reset
 Description:  Template for modified Moore FSM for UEC2 project
 */
//////////////////////////////////////////////////////////////////////////////
 module draw_rect_ctl (
    input logic clk,
    input logic rst,
    input logic key_space,
    input logic key_right,
    input logic key_left,
    output logic [11:0] value_x,
    output logic [11:0] value_y,
    output logic [1:0] character_state
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;
//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam CLK_FREQ = 100_000_000;
localparam CTR_FREQ = 100;
localparam CTR_MAX = (CLK_FREQ / CTR_FREQ) - 1;
localparam DIV = 10;
localparam A = 2; 
localparam VELOCITY = 10;
localparam REC_WIDTH = 47;
localparam REC_HEIGHT = 63;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic [31:0] vel_time; // 10ms
logic [31:0] vel_time_nxt;
logic [31:0] counter;
logic [31:0] counter_nxt;
logic [11:0] value_x_nxt;
logic [11:0] value_y_nxt;
logic top_reached;
logic bottom_reached;
logic [1:0] character_state_nxt;
logic [11:0] y_pos; 
logic [11:0] y_pos_nxt;
logic facing;

typedef enum logic [2:0] {
    IDLE    = 3'b000,
    FALLING = 3'b001, 
    JUMP    = 3'b010,
    LEFT   = 3'b011,
    RIGHT   = 3'b100,
    JUMP_PREP = 3'b101
} state_t;

state_t state, state_nxt;   

logic [1:0] collision_map [0:3071];

initial $readmemh("../../rtl/Graphics/collision_map.data", collision_map);
    //$readmemh("../rtl/Graphics/collision_map.data", collision_map);


logic [6:0] tile_x;
logic [6:0] tile_x_l, tile_x_r;
logic [5:0] tile_y_l, tile_y_r, tile_y_below, tile_y_above;
logic [11:0] tile_idx_l, tile_idx_r, tile_idx_below, tile_idx_above;
logic [1:0] tile_l, tile_r, tile_below, tile_above;
logic [11:0] y_jump_start, y_jump_start_nxt;

localparam TILES_X = 64;  // 1024/16 rounded up
localparam TILES_Y = 48;  // 
localparam y_start = VER_PIXELS - REC_HEIGHT - 50; //  VER_PIXELS - REC_HEIGHT - 50;
localparam x_start = 12'd50; //12'd50;


//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : state_seq_blk
    if(rst)begin : state_seq_rst_blk
        state <= IDLE;
    end
    else begin : state_seq_run_blk
        state <= state_nxt;
    end
end
//------------------------------------------------------------------------------
// next state logic
//------------------------------------------------------------------------------
always_comb begin : state_comb_blk
    state_nxt = state;
    case(state)
        IDLE: begin
            if (key_space) begin
                state_nxt = JUMP_PREP;
            end else if (key_right) begin
                state_nxt = RIGHT;
            end else if (key_left) begin
                state_nxt = LEFT;
            end
        end

        JUMP: begin
            if(top_reached || (tile_above == 2'b01)) begin
                state_nxt = FALLING;
            end
        end

        FALLING: begin
            if(bottom_reached  || (tile_below == 2'b01)) begin 
                state_nxt = IDLE;
            end
        end
        LEFT: begin
            if (!key_left) begin
                state_nxt = IDLE;
            end
        end

        RIGHT: begin
            if (!key_right) begin
                state_nxt = IDLE;
            end
        end
        JUMP_PREP: begin
            if(!key_space) begin
                state_nxt = JUMP;
            end
        end
    endcase
end
//------------------------------------------------------------------------------
// output register
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : out_reg_blk
    if(rst) begin : out_reg_rst_blk
        vel_time <= '0;
        counter <= '0;
        value_x <= x_start;
        value_y <= y_start;
        y_pos <= y_start;
        character_state <= 2'b00; 
    end
    else begin : out_reg_run_blk
        vel_time <= vel_time_nxt;
        counter <= counter_nxt;
        value_x <= value_x_nxt;
        value_y <= value_y_nxt;
        character_state <= character_state_nxt;
        y_pos <= y_pos_nxt;
    end
end


always_ff @(posedge clk) begin
    if (rst) begin
        facing <= 1'b0; 
    end else begin
        case (state)
            LEFT: begin
                facing <= 1'b0; 
            end
            RIGHT: begin
                facing <= 1'b1; 
            end
            default: begin
                facing <= facing; 
            end
        endcase
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        y_jump_start <= y_start;
    end else begin
        y_jump_start <= y_jump_start_nxt;
    end
end


//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
always_comb begin : out_comb_blk
    // Default assignments
    value_x_nxt = value_x;
    value_y_nxt = value_y;
    y_pos_nxt = y_pos;
    counter_nxt = counter;
    vel_time_nxt = vel_time;
    character_state_nxt = character_state;
    top_reached = 1'b0;
    bottom_reached = 1'b0;
    y_jump_start_nxt = y_jump_start;

    tile_y_l = value_y >> 4;
    tile_x_l = (value_x - 1) >> 4;
    tile_idx_l = tile_y_l * 64 + tile_x_l;
    tile_l = collision_map[tile_idx_l];

    tile_y_r = value_y >> 4;                  
    tile_x_r = (value_x + REC_WIDTH - 1) >> 4;     
    tile_idx_r = (tile_y_r < TILES_Y && tile_x_r < TILES_X) 
                ? tile_y_r * TILES_X + tile_x_r 
                : 1;                            
    tile_r = collision_map[tile_idx_r];

    tile_y_below = (value_y + REC_HEIGHT) >> 4;
    tile_x       = value_x >> 4;
    tile_idx_below = (tile_y_below < TILES_Y && tile_x < TILES_X) 
                   ? tile_y_below * TILES_X + tile_x 
                   : 1;  
    tile_below = collision_map[tile_idx_below];

    tile_y_above = (value_y - 1) >> 4;
    tile_idx_above = tile_y_above * 64 + tile_x;
    tile_above = collision_map[tile_idx_above];

    case(state)
        IDLE: begin
            y_jump_start_nxt = y_jump_start;
            value_x_nxt = value_x;
            value_y_nxt = value_y;
            y_pos_nxt = y_pos;
            counter_nxt = counter;
            vel_time_nxt = vel_time;
            character_state_nxt = 2'b00;
            top_reached = 1'b0;
            bottom_reached = 1'b0;
        end

        JUMP_PREP: begin
            character_state_nxt = 2'b01;
            if(key_space) begin
                vel_time_nxt = '0;
                counter_nxt = '0;
                y_jump_start = value_y_nxt;
            end else begin
                counter_nxt = counter + 1;
            end
        end

        JUMP: begin
            character_state_nxt = 2'b01;
            if(counter == CTR_MAX) begin
                vel_time_nxt = vel_time + 1; // Domyślne zwiększenie czasu
                value_y_nxt = y_jump_start + ((A*vel_time*vel_time)/(2*DIV)) - (VELOCITY*vel_time);
                y_pos_nxt = value_y_nxt;      

                if((facing && (tile_r == 2'b00)) || (tile_l == 2'b01)) begin
                    value_x_nxt = value_x + 3;
                end else if ((!facing && tile_l == 2'b00) || (tile_r == 2'b01)) begin
                    value_x_nxt = value_x - 3;
                end else begin
                    value_x_nxt = value_x; 
                end

                if( (A*vel_time) >= (VELOCITY * DIV) ) begin 
                    vel_time_nxt = 0;        
                    top_reached = 1;     
                end
                counter_nxt = 0;
            end
            else begin
                counter_nxt = counter + 1;
            end
        end

        FALLING: begin
            character_state_nxt = 2'b10;
            if(counter == CTR_MAX) begin
                vel_time_nxt = vel_time + 1;
                value_y_nxt = y_pos + ((A*vel_time*vel_time)/(2*DIV));
                
                if(value_y_nxt >= y_start) begin
                    value_y_nxt = y_start;
                    vel_time_nxt = 0;
                    bottom_reached = 1;
                    y_jump_start_nxt = y_start; // Set new jump base
                end else begin
                    y_jump_start_nxt = y_pos; // Keep previous value
                end
                
                counter_nxt = 0;
            end else begin
                counter_nxt = counter + 1;
                y_jump_start_nxt = y_jump_start; // Keep previous value
            end
        end
        
        
        LEFT: begin
            character_state_nxt = 2'b01;
            if (value_x <= x_start || (tile_l == 2'b01)) begin
            end else if (vel_time >= (CTR_MAX * 4)) begin
                value_x_nxt = value_x - 16;
                vel_time_nxt = 0;
            end else begin
                vel_time_nxt = vel_time + 1;
            end
        end

        RIGHT: begin
            character_state_nxt = 2'b01;
            if (value_x >= VER_PIXELS - REC_WIDTH - 1 || (tile_r == 2'b01)) begin
            end else if (vel_time >= (CTR_MAX * 4)) begin
                value_x_nxt = value_x + 16;
                vel_time_nxt = 0;
            end else begin
                vel_time_nxt = vel_time + 1;
            end
        end

        default: begin
        end
    endcase
end
endmodule