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
    output logic [1:0] character_state,
    output logic [1:0] level,
    vga_if.in vga_in,
    vga_if.out vga_out
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
localparam A = 4; 
localparam VELOCITY = 1;
localparam MAX_VELOCITY = 70;
localparam REC_WIDTH = 47;
localparam REC_HEIGHT = 63;
localparam OFFSET = 12'd10;
localparam MAX_LEVEL = 4; 
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic [31:0] vel_time; // 10ms
logic [31:0] vel_time_nxt;
logic [31:0] counter;
logic [31:0] counter_nxt;
logic [31:0] counter_sd;
logic [31:0] counter_sd_nxt;
logic [11:0] value_x_nxt;
logic [11:0] value_y_nxt;
logic top_reached;
logic bottom_reached;
logic [1:0] character_state_nxt;
logic [11:0] y_pos; 
logic [11:0] y_pos_nxt;
logic facing;
logic facing_nxt;
logic [6:0] jump_vel;
logic [6:0] jump_vel_nxt;

logic [5:0] fall_bottom;
logic [5:0] fall_bottom_nxt;
logic signed [15:0] value_y_temp;

logic collision_left, collision_right, collision_bot, collision_top;
logic collision_left_nxt, collision_right_nxt, collision_bot_nxt, collision_top_nxt;

typedef enum logic [2:0] {
    IDLE    = 3'b000,
    FALLING = 3'b001, 
    JUMP    = 3'b010,
    LEFT   = 3'b011,
    RIGHT   = 3'b100,
    JUMP_PREP = 3'b101
} state_t;

state_t state, state_nxt;   



// logic [6:0] tile_x;
// logic [6:0] tile_x_l, tile_x_r;
// logic [5:0] tile_y_l, tile_y_r,  tile_y_above;
// logic [11:0] tile_idx_l, tile_idx_r,  tile_idx_above;
// logic [1:0] tile_l_bottom, tile_r_bottom, tile_r, tile_l, tile_above;
logic [11:0] y_jump_start, y_jump_start_nxt;
logic [1:0] level_nxt;
// localparam TILES_X = 64;  // 1024/16 rounded up                                                                     
// localparam TILES_Y = 48;  // 
localparam y_start = VER_PIXELS - REC_HEIGHT - 62; //  VER_PIXELS - REC_HEIGHT - 50;
localparam x_start = 12'd70; //12'd50;


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
        jump_vel <= VELOCITY; 
        counter_sd <= '0;
        level <= 2'b00; // Default level
        collision_left <= 1'b0;
        collision_right <= 1'b0;
        collision_bot <= 1'b1;
        collision_top <= 1'b0;
        fall_bottom <= y_start;
    end
    else begin : out_reg_run_blk
        vel_time <= vel_time_nxt;
        counter <= counter_nxt;
        value_x <= value_x_nxt;
        value_y <= value_y_nxt;
        character_state <= character_state_nxt;
        y_pos <= y_pos_nxt;
        jump_vel <= jump_vel_nxt;
        counter_sd <= counter_sd_nxt;
        level <= level_nxt;
        collision_left <= collision_left_nxt;
        collision_right <= collision_right_nxt;
        collision_bot <= collision_bot_nxt;
        collision_top <= collision_top_nxt;
        fall_bottom <= fall_bottom_nxt;
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
                facing <= facing_nxt; 
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

//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------


always_comb begin : out_comb_blk
    // Default assignments
    value_x_nxt = value_x;
    value_y_nxt = value_y;
    y_pos_nxt = value_y;
    counter_nxt = counter;
    vel_time_nxt = vel_time;
    character_state_nxt = character_state;
    top_reached = 1'b0;
    bottom_reached = 1'b0;
    y_jump_start_nxt = y_jump_start;
    jump_vel_nxt = jump_vel;
    counter_sd_nxt = counter_sd;
    facing_nxt = facing;
    level_nxt = level;
    fall_bottom_nxt = fall_bottom;

    collision_left_nxt = collision_left;
    collision_right_nxt = collision_right;
    collision_bot_nxt = collision_bot;
    collision_top_nxt = collision_top;

    if(vga_in.hcount == value_x && vga_in.vcount >= (value_y + OFFSET) && vga_in.vcount <= (value_y + (REC_HEIGHT) - OFFSET)) begin // left
        if(vga_in.rgb == 12'h2_B_4) begin
            collision_left_nxt = '1;
        end else begin
            collision_left_nxt = '0;
        end

    end 
    if(vga_in.hcount == (value_x + REC_WIDTH - 1) && vga_in.vcount >= (value_y + OFFSET) && vga_in.vcount <= (value_y + (REC_HEIGHT) - OFFSET)) begin // right
        if(vga_in.rgb == 12'h2_B_4) begin
            collision_right_nxt = '1;
        end else begin
            collision_right_nxt = '0;
        end 
    end
    if (vga_in.hcount >= (value_x + OFFSET) && vga_in.hcount <= (value_x + REC_WIDTH - OFFSET) && vga_in.vcount == (value_y + REC_HEIGHT + 5)) begin // bot whole
        if(vga_in.rgb == 12'h2_B_4) begin
            collision_bot_nxt = '1;
        end else begin
            collision_bot_nxt = '0;
        end 
    end 
    if (vga_in.hcount >= (value_x + OFFSET) && vga_in.hcount <= (value_x + REC_WIDTH - OFFSET) && vga_in.vcount == value_y) begin // top whole
        if(vga_in.rgb == 12'h2_B_4) begin
            collision_top_nxt = '1;
        end else begin
            collision_top_nxt = '0;
        end
    end

    if(collision_left) begin
        facing_nxt = 1'b1; // Facing left
    end else if (collision_right) begin
        facing_nxt = 1'b0; // Facing right
    end else begin
        facing_nxt = facing; // Keep previous value
    end

    case(state)
        IDLE: begin
            y_jump_start_nxt = y_jump_start;
            value_x_nxt = value_x;
            value_y_nxt = value_y;
            y_pos_nxt = value_y;
            counter_nxt = '0;
            counter_sd_nxt = '0;
            vel_time_nxt = vel_time;
            character_state_nxt = 2'b00;
            top_reached = 1'b0;
            bottom_reached = 1'b0;
            jump_vel_nxt = VELOCITY;

            if (vga_in.hcount >= (value_x + OFFSET) && vga_in.hcount <= (value_x + REC_WIDTH - OFFSET) && vga_in.vcount == (value_y + REC_HEIGHT - 2)) begin // bot whole
                if(vga_in.rgb == 12'h2_B_4) begin
                    value_y_nxt = value_y - 6;
                end
            end
            
            
        end

        JUMP_PREP: begin
            character_state_nxt = 2'b01;
            if(key_space) begin
                vel_time_nxt = '0;
                y_jump_start_nxt = value_y;
            end
            if (counter == 3*CTR_MAX) begin
                counter_nxt = 0;
                jump_vel_nxt = jump_vel + 2; // Set initial jump velocity
                if(jump_vel >= MAX_VELOCITY) begin
                    jump_vel_nxt = MAX_VELOCITY; // Reset jump velocity
                end 
            end else begin
                counter_nxt = counter + 1;
            end
        end

               JUMP: begin
            character_state_nxt = 2'b01;
        
            if(collision_left) begin
                facing_nxt = 1'b1;
            end else if (collision_right) begin
                facing_nxt = 1'b0; 
            end else begin
                facing_nxt = facing; 
            end


            if(counter == 3*CTR_MAX && value_y > 5) begin
                counter_nxt = 0;
                vel_time_nxt = vel_time + 1;
                value_y_temp = y_jump_start + ((A * vel_time * vel_time) / (2 * DIV)) - (jump_vel * vel_time);
                if (value_y_temp > VER_PIXELS) begin
                    value_y_temp = VER_PIXELS;
                end else if (value_y_temp < 0) begin
                    value_y_temp = 0;
                end
                
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
                        fall_bottom_nxt = VER_PIXELS;   
                        y_jump_start_nxt  = value_y_nxt; // ← THIS is critical!
                    end 
                end else begin 
                counter_nxt = counter + 1;
                
            end 

            // Horizontal movement during jump
            if(counter_sd == CTR_MAX && value_x >= x_start && value_x <= HOR_PIXELS - REC_WIDTH - 1) begin
                counter_sd_nxt = 0;

                if(facing_nxt) begin
                    value_x_nxt = value_x + 3; // Move right
                end else begin
                    value_x_nxt = value_x - 3; // Move left
                end
            end else begin
                counter_sd_nxt = counter_sd + 1;
            end
        end
        
        FALLING: begin
            character_state_nxt = 2'b10;
            
 
            if (collision_left) begin
                facing_nxt = 1'b1; 
            end else if (collision_right) begin
                facing_nxt = 1'b0; 
            end else begin
                facing_nxt = facing; 
            end

            if (counter == 3 * CTR_MAX) begin
                counter_nxt = 0;    
                vel_time_nxt = vel_time + 1;
                // value_y_nxt = y_pos + ((A * vel_time * vel_time) / (2 * DIV));
                // y_pos_nxt = value_y_nxt;
                
                value_y_temp = y_pos + ((A * vel_time * vel_time) / (2 * DIV));
                if (value_y_temp > VER_PIXELS) begin
                    value_y_temp = VER_PIXELS;
                end else if (value_y_temp < 0) begin
                    value_y_temp = 0;
                end
                
                value_y_nxt = value_y_temp;
                y_pos_nxt   = value_y_temp;


                if (collision_bot) begin
                    value_y_nxt = value_y - REC_HEIGHT;
                    vel_time_nxt = 0;
                    bottom_reached = 1;
                    y_jump_start_nxt = value_y_nxt; 
                end else begin
                    y_jump_start_nxt = y_pos;
                end
                
            end else if (value_y >= VER_PIXELS - 5) begin
                    if (level > 0) begin
                        level_nxt = level - 1;
                        value_y_nxt = 10;
                        y_pos_nxt = value_y_nxt;
                        fall_bottom_nxt = VER_PIXELS;
                    end else begin
                        fall_bottom_nxt = y_start;
                end
            end else begin
                counter_nxt = counter + 1;
                y_jump_start_nxt = y_jump_start;
            end
            
            if (counter_sd == CTR_MAX && value_x >= x_start) begin
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
        
            // … inside your always_comb out_comb_blk, replace the LEFT/RIGHT cases with:

        LEFT: begin
            character_state_nxt = 2'b01;
            // if wall on left edge, hold position and timer
            if (collision_left) begin
                value_x_nxt  = value_x;
                counter_sd_nxt = counter_sd; 
            end
            // otherwise, every CTR_MAX ticks take a 3-pixel step left
            else if (counter_sd == CTR_MAX) begin
                counter_sd_nxt = 0;
                value_x_nxt  = value_x - 3;
            end
            // else just advance the step timer
            else begin
                counter_sd_nxt = counter_sd + 1;
            end
        end

        RIGHT: begin
            character_state_nxt = 2'b01;
            // if wall on right edge, hold position and timer
            if (collision_right) begin
                value_x_nxt   = value_x;
                counter_sd_nxt = counter_sd;
            end
            // otherwise, every CTR_MAX ticks take a 3-pixel step right
            else if (counter_sd == CTR_MAX) begin
                counter_sd_nxt = 0;
                value_x_nxt  = value_x + 3;
            end
            // else just advance the step timer
            else begin
                counter_sd_nxt = counter_sd + 1;
            end
        end


        default: begin
        end
    endcase
end
endmodule