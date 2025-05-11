//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   template_fsm
 Author:        Roberto C. Garcia
 Version:       1.0
 Last modified: 2023-05-15
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
    output logic [11:0] value_y
);


`timescale 1ns / 1ps

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam int SCREEN_HEIGHT = 600;
localparam int RECT_HEIGHT = 64;
localparam int CLOCKS_PER_MS = 1_000_000; 
localparam int A = 2;


//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------


logic [11:0] position_y;
logic signed [15:0] velocity_y;
logic [11:0] time_passed; 
logic [25:0] cycle_counter;


logic [11:0] value_x_nxt;
logic [11:0] value_y_nxt;
logic [11:0] position_y_nxt;
logic signed [15:0] velocity_y_nxt;
logic [11:0] time_passed_nxt;
logic [25:0] cycle_counter_nxt;;


typedef enum logic [1:0] {
    IDLE    = 2'b00,
    FALLING = 2'b01, 
    JUMP    = 2'b10
} state_t;

state_t state, state_nxt;   


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
    case(state)
        IDLE: begin
            if (key_space) begin
                state_nxt = JUMP;
            end else begin
                state_nxt = IDLE;
            end
        end
        FALLING: begin
            if (position_y  + ((A*time_passed*time_passed)/2) < (SCREEN_HEIGHT - RECT_HEIGHT - 1)) begin
                state_nxt = FALLING;
            end else begin
                state_nxt = IDLE;
            end
        end
        JUMP: begin
            if (velocity_y > 0) begin
                state_nxt = FALLING;
            end else begin
                state_nxt = JUMP;
            end
        end
    endcase
end


//------------------------------------------------------------------------------
// output register
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : out_reg_blk
    if (rst) begin
        value_x <= 12'h000;
        value_y <= SCREEN_HEIGHT - RECT_HEIGHT - 1;
        position_y <= SCREEN_HEIGHT - RECT_HEIGHT - 1;
        velocity_y <= '0;
        time_passed <= '0;
        cycle_counter <= 26'h0000000;
    end else begin
        cycle_counter <= cycle_counter_nxt;
        position_y <= position_y_nxt;
        velocity_y <= velocity_y_nxt;
        time_passed <= time_passed_nxt;
        value_y <= value_y_nxt;
        value_x <= value_x_nxt;
    end
end


//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
always_comb begin : out_comb_blk
    case(state_nxt)
        IDLE: begin
            value_x_nxt = value_x;
            value_y_nxt = value_y;
            velocity_y_nxt = 0;
            position_y_nxt = position_y;
            time_passed_nxt = 0;
            cycle_counter_nxt = 0; 
        end
        FALLING: begin
            if(state == JUMP) begin
                time_passed_nxt = 0;
                velocity_y_nxt = 0;
            end
            value_x_nxt = value_x; 
            if (cycle_counter == CLOCKS_PER_MS - 1) begin
                cycle_counter_nxt = 0; 
                if (position_y  + ((A*time_passed*time_passed)/2) < (SCREEN_HEIGHT - RECT_HEIGHT - 1)) begin
                    time_passed_nxt = time_passed + 1;
                    position_y_nxt = position_y + ((A*time_passed*time_passed)/2);
                    value_y_nxt = position_y + ((A*time_passed*time_passed)/2);
                    velocity_y_nxt = A * time_passed;
                end else begin
                    value_y_nxt = (SCREEN_HEIGHT - RECT_HEIGHT - 1);
                    position_y_nxt = (SCREEN_HEIGHT - RECT_HEIGHT - 1);
                    velocity_y_nxt = 0;
                    time_passed_nxt = 0;
                    end
                end else begin
                cycle_counter_nxt = cycle_counter + 1; 
            end
        end
        JUMP: begin
            value_x_nxt = value_x;

            if (cycle_counter == CLOCKS_PER_MS - 1) begin
                if(time_passed == 0) begin 
                    velocity_y_nxt = $signed(-20);
                end else begin
                    velocity_y_nxt = velocity_y + $signed(A*time_passed); 
                end
                cycle_counter_nxt = 0; 
                time_passed_nxt = time_passed + 1;

                position_y_nxt = position_y - (velocity_y*velocity_y)/(A*2); 
                value_y_nxt = position_y - (velocity_y*velocity_y)/(A*2);
            end else begin
                cycle_counter_nxt = cycle_counter + 1; 
            end
        end
    endcase
end

endmodule
