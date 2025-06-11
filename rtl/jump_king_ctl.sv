/*
* Authors:
* * 2025  AGH University of Science and Technology
* MTM UEC2 Final Project
* Miłosz Płonczyński and Tomasz Machnik 
*
* Description:
* Main control module which handles:
 * - Keyboard input for character control
 * - Character movement and jumping logic
 * - Collision detection with the ground and walls
 * - Drawing the character on the VGA display
 * - Level management
 * And combines the functionality of the character skin ROM and VGA interface.
*/

 module jump_king_ctl (
    input logic clk,
    input logic rst,

    input logic key_space,
    input logic key_right,
    input logic key_left,

    output logic [11:0] value_x,
    output logic [11:0] value_y,
    
    output logic [2:0] character_skin,
    output logic [1:0] level,

    vga_if.in vga_in,
    vga_if.out vga_out
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

/**
 *  Parameters and constants for the game physics and timing
*/

localparam CLK_FREQ = 100_000_000;
localparam CTR_FREQ = 100;
localparam CTR_MAX = (CLK_FREQ / CTR_FREQ) - 1;
localparam DIV = 10;
localparam A = 4; 
localparam VELOCITY = 1;
localparam MAX_VELOCITY = 70;

/**
 *  Parameters for the rectangle size and starting position on the screen
*/

localparam REC_WIDTH = 47;
localparam REC_HEIGHT = 63;
localparam OFFSET = 12'd10;
localparam MAX_LEVEL = 4;
localparam Y_START = VER_PIXELS - REC_HEIGHT - 64; 
localparam X_START = 12'd70; 

/**
 *  Registers and logic variables for the control module and jump/movement physics
*/

logic [31:0] vel_time; 
logic [31:0] vel_time_nxt;
logic [31:0] counter;
logic [31:0] counter_nxt;
logic [31:0] counter_sd;
logic [31:0] counter_sd_nxt;

logic [11:0] value_x_nxt;
logic [11:0] value_y_nxt;
logic [11:0] y_pos; 
logic [11:0] y_pos_nxt;
logic [11:0] y_jump_start, y_jump_start_nxt;

logic [6:0] jump_vel;
logic [6:0] jump_vel_nxt;

logic facing;
logic facing_nxt;
logic top_reached;

/**
 *  Level change logic variables
*/

logic signed [11:0] value_y_temp;
logic signed [11:0] value_y_temp_nxt;
logic [1:0] level_nxt;

/**
 *  Collision detection logic variables and enum variables for current skin and current level
*/

logic collision_left, collision_right, collision_bot, collision_top;
logic collision_left_nxt, collision_right_nxt, collision_bot_nxt, collision_top_nxt;


typedef enum logic [2:0] {
    IDLE      =   3'b000,
    FALLING   =   3'b001, 
    JUMP      =   3'b010,
    LEFT      =   3'b011,
    RIGHT     =   3'b100,
    JUMP_PREP =   3'b101
} state_t;

typedef enum logic [2:0] {
    MICRO_IDLE  = 3'b000,
    MICRO_PREP  = 3'b001,
    MICRO_JUMP  = 3'b010,
    MICRO_LEFT  = 3'b011,
    MICRO_RIGHT = 3'b100
} character_skin_t;

character_skin_t character_skin_nxt;
state_t state, state_nxt;   

/**
 *  State sequential block with synchronous reset
*/

always_ff @(posedge clk) begin : state_seq_blk
    if(rst)begin : state_seq_rst_blk
        state <= IDLE;
    end
    else begin : state_seq_run_blk
        state <= state_nxt;
    end
end

/**
 *  Next state logic
*/

always_comb begin : state_comb_blk
    state_nxt = state;

    case (state)
        IDLE: begin
            if (key_space) begin
                state_nxt = JUMP_PREP;
            end else if (key_right) begin
                state_nxt = RIGHT;
            end else if (key_left) begin
                state_nxt = LEFT;
            end
        end

        JUMP_PREP: begin
            if (!key_space) begin
                state_nxt = JUMP;
            end
        end

        JUMP: begin
            if (top_reached || collision_top) begin
                state_nxt = FALLING;
            end
        end

        LEFT: begin
           if(!collision_bot) begin
                state_nxt = FALLING;
            end else
            if (!key_left) begin
                state_nxt = IDLE;
            end else begin
                state_nxt = LEFT;
            end
        end

        RIGHT: begin
            if(!collision_bot) begin
                state_nxt = FALLING;
            end else 
            if (!key_right) begin
                state_nxt = IDLE;
            end else begin
                state_nxt = RIGHT;
            end
        end

        FALLING: begin
            if (collision_bot) begin 
                state_nxt = IDLE;
            end
        end
    endcase
end

/**
*  Output register
*/

always_ff @(posedge clk) begin : out_reg_blk
    if (rst) begin : out_reg_rst_blk
        vel_time        <= '0;
        counter         <= '0;
        value_x         <= X_START;
        value_y         <= Y_START;
        y_pos           <= Y_START;
        value_y_temp    <= '0;
        character_skin  <= MICRO_IDLE; 
        jump_vel        <= VELOCITY; 
        counter_sd      <= '0;
        level           <= '0;
        collision_left  <= 1'b0;
        collision_right <= 1'b0;
        collision_bot   <= 1'b1;
        collision_top   <= 1'b0;
    end else begin : out_reg_run_blk
        vel_time        <= vel_time_nxt;
        counter         <= counter_nxt;
        value_x         <= value_x_nxt;
        value_y         <= value_y_nxt;
        character_skin  <= character_skin_nxt;
        y_pos           <= y_pos_nxt;
        value_y_temp    <= value_y_temp_nxt;
        jump_vel        <= jump_vel_nxt;
        counter_sd      <= counter_sd_nxt;
        level           <= level_nxt;
        collision_left  <= collision_left_nxt;
        collision_right <= collision_right_nxt;
        collision_bot   <= collision_bot_nxt;
        collision_top   <= collision_top_nxt;
    end
end

/**
*  Facing direction register for collision purposes
*/

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
                facing <= facing_nxt; 
            end
        endcase
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        y_jump_start <= Y_START;
    end else begin
        y_jump_start <= y_jump_start_nxt;
    end
end

always_ff @(posedge clk) begin : rec_ff_blk
    if (rst) begin
        vga_out.vcount <= '0;
        vga_out.vsync  <= '0;
        vga_out.vblnk  <= '0;
        vga_out.hcount <= '0;
        vga_out.hsync  <= '0;
        vga_out.hblnk  <= '0;
        vga_out.rgb    <= '0;
    end else begin
        vga_out.vcount <= vga_in.vcount;
        vga_out.vsync  <= vga_in.vsync;
        vga_out.vblnk  <= vga_in.vblnk;
        vga_out.hcount <= vga_in.hcount;
        vga_out.hsync  <= vga_in.hsync;
        vga_out.hblnk  <= vga_in.hblnk;
        vga_out.rgb    <= vga_in.rgb;
    end
end

/**
*   Output logic
*/


always_comb begin : out_comb_blk
    value_x_nxt = value_x;
    value_y_nxt = value_y;
    y_pos_nxt = value_y;
    counter_nxt = counter;
    vel_time_nxt = vel_time;
    character_skin_nxt = character_skin_t'(character_skin);
    top_reached = 1'b0;
    y_jump_start_nxt = y_jump_start;
    jump_vel_nxt = jump_vel;
    counter_sd_nxt = counter_sd;
    facing_nxt = facing;
    level_nxt = level;
    value_y_temp_nxt = '0; 

    collision_left_nxt = collision_left;
    collision_right_nxt = collision_right;
    collision_bot_nxt = collision_bot;
    collision_top_nxt = collision_top;


/**
*   Collision detection logic using pixel colors
*/

    if(vga_in.hcount == value_x && vga_in.vcount >= (value_y + OFFSET) && vga_in.vcount <= (value_y + (REC_HEIGHT) - OFFSET)) begin // left
        if(vga_in.rgb == 12'hF_C_0) begin
            collision_left_nxt = '1;
        end else begin
            collision_left_nxt = '0;
        end

    end 
    if(vga_in.hcount == (value_x + REC_WIDTH - 1) && vga_in.vcount >= (value_y + OFFSET) && vga_in.vcount <= (value_y + (REC_HEIGHT) - OFFSET)) begin // right
        if(vga_in.rgb == 12'hF_C_0) begin
            collision_right_nxt = '1;
        end else begin
            collision_right_nxt = '0;
        end 
    end
    if (vga_in.hcount >= (value_x + OFFSET) && vga_in.hcount <= (value_x + REC_WIDTH - OFFSET) && vga_in.vcount == (value_y + REC_HEIGHT + 5)) begin // bot whole
        if(vga_in.rgb == 12'hF_C_0) begin
            collision_bot_nxt = '1;
        end else begin
            collision_bot_nxt = '0;
        end 
    end 
    if (vga_in.hcount >= (value_x + OFFSET) && vga_in.hcount <= (value_x + REC_WIDTH - OFFSET) && vga_in.vcount == value_y) begin // top whole
        if(vga_in.rgb == 12'hF_C_0) begin
            collision_top_nxt = '1;
        end else begin
            collision_top_nxt = '0;
        end
    end

    if(collision_left) begin
        facing_nxt = 1'b1; 
    end else if (collision_right) begin
        facing_nxt = 1'b0; 
    end else begin
        facing_nxt = facing; 
    end


    case(state)
        IDLE: begin
            top_reached = 1'b0;
            counter_nxt = '0;
            counter_sd_nxt = '0;
            value_x_nxt = value_x;
            value_y_nxt = value_y;
            y_pos_nxt = value_y;
            y_jump_start_nxt = y_jump_start;
            vel_time_nxt = '0;
            jump_vel_nxt = VELOCITY;
            character_skin_nxt = MICRO_IDLE;

            if (vga_in.hcount >= (value_x + OFFSET) && vga_in.hcount <= (value_x + REC_WIDTH - OFFSET) && vga_in.vcount == (value_y + REC_HEIGHT - 2)) begin // pillow after jump
                if(vga_in.rgb == 12'hF_C_0) begin
                    value_y_nxt = value_y - 6;
                end
            end
        end

        JUMP_PREP: begin
            character_skin_nxt = MICRO_PREP;
            
            if(key_space) begin
                vel_time_nxt = '0;
                y_jump_start_nxt = value_y;
            end
            if (counter == 3*CTR_MAX) begin
                counter_nxt = 0;
                jump_vel_nxt = jump_vel + 2; 
                if(jump_vel >= MAX_VELOCITY) begin
                    jump_vel_nxt = MAX_VELOCITY; 
                end 
            end else begin
                counter_nxt = counter + 1;
            end
        end

        JUMP: begin
            character_skin_nxt = MICRO_JUMP;

            //  Calculate the next vertical position based on the jump physics

            value_y_temp_nxt = y_jump_start + ((A * vel_time * vel_time) / (2 * DIV)) - (jump_vel * vel_time);
            if (value_y_temp > VER_PIXELS) begin
                value_y_temp_nxt = VER_PIXELS;
            end else if (value_y_temp < 0) begin
                value_y_temp_nxt = 0;
            end

            //  Vertical movement logic during JUMP state

            if(counter == 4*CTR_MAX && value_y > 5) begin
                counter_nxt = 0;
                vel_time_nxt = vel_time + 1;
        
                value_y_nxt = value_y_temp;
                y_pos_nxt   = value_y_temp;

                if((A * vel_time) >= (VELOCITY * DIV)) begin
                        vel_time_nxt = 0;
                        top_reached = 1;
                end

            end else if (value_y <= 5) begin  
                    if (level < MAX_LEVEL) begin
                        level_nxt = level + 1;        
                        value_y_nxt = VER_PIXELS - 10;   
                        y_pos_nxt = value_y_nxt;
                        y_jump_start_nxt  = value_y_nxt; 
                        vel_time_nxt = vel_time;
                    end 
                end else begin 
                counter_nxt = counter + 1;
                vel_time_nxt = vel_time;
            end 

            //  Horizontal movement logic during JUMP state

            if(counter_sd == CTR_MAX) begin 
                counter_sd_nxt = 0;

                if(facing_nxt) begin
                    value_x_nxt = value_x + 3; 
                end else begin
                    value_x_nxt = value_x - 3; 
                end
            end else begin
                counter_sd_nxt = counter_sd + 1;
            end
        end
        
        FALLING: begin
            character_skin_nxt = MICRO_JUMP;

            //  Calculate the next vertical position based on the falling physics

            value_y_temp_nxt = y_pos + ((A * vel_time * vel_time) / (2 * DIV));
            if (value_y_temp > VER_PIXELS) begin
                value_y_temp_nxt = VER_PIXELS;
            end else if (value_y_temp < 0) begin
                value_y_temp_nxt = 0;
            end
            
            //  Vertical movement logic during FALLING state

            if (counter == 4 * CTR_MAX) begin
                counter_nxt = 0;    
                vel_time_nxt = vel_time + 1;
                    
                value_y_nxt = value_y_temp;
                y_pos_nxt   = value_y_temp;

                if (collision_bot) begin
                    value_y_nxt = value_y - REC_HEIGHT;
                    vel_time_nxt = 0;
                    y_jump_start_nxt = value_y_nxt; 
                end else begin
                    y_jump_start_nxt = y_pos;
                end
            end else if (value_y >= VER_PIXELS - 5) begin

                if (level > 0) begin
                    level_nxt = level - 1;
                    value_y_nxt = 10;
                    y_pos_nxt = value_y_nxt;
                end
            end else begin
                counter_nxt = counter + 1;
                y_jump_start_nxt = y_jump_start;
            end
            
            //  Horizontal movement logic during JUMP state
            
            if (counter_sd == CTR_MAX) begin
                counter_sd_nxt = 0;
                
                if (facing_nxt) begin
                    value_x_nxt = value_x + 3; 
                end else begin
                    value_x_nxt = value_x - 3; 
                end
            end else begin
                counter_sd_nxt = counter_sd + 1;
            end
        end
        

        LEFT: begin
            character_skin_nxt = MICRO_LEFT;
            vel_time_nxt = '0;
            if (collision_left) begin
                value_x_nxt  = value_x;
                counter_sd_nxt = counter_sd; 
            end
            else if (counter_sd == CTR_MAX) begin
                counter_sd_nxt = 0;
                value_x_nxt  = value_x - 3;
            end
            else begin
                counter_sd_nxt = counter_sd + 1;
            end
        end

        RIGHT: begin
            counter_sd_nxt = 0;
            character_skin_nxt = MICRO_RIGHT;
            vel_time_nxt = '0;
            if (collision_right) begin
                value_x_nxt   = value_x;
                counter_sd_nxt = counter_sd;
            end
            else if (counter_sd == CTR_MAX) begin
                counter_sd_nxt = 0;
                value_x_nxt  = value_x + 3;
            end
            else begin
                counter_sd_nxt = counter_sd + 1;
            end
        end

        default: begin
        end
    endcase
end

endmodule