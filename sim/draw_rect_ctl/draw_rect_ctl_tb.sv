`timescale 1ns / 1ps

module draw_rect_ctl_tb;

    // Parameters

    localparam REC_WIDTH = 47;
    localparam REC_HEIGHT = 63;
    localparam int SCREEN_HEIGHT = 1024;
    localparam int SCREEN_WIDTH = 786;
    
    // Inputs
    reg clk;
    reg reset;
    reg key_space;
    reg key_left;
    reg key_right;
    logic [1:0] collision_map [0:3071];
    initial $readmemh("../../rtl/Graphics/collision_map.data", collision_map);

    // Outputs
    wire [11:0] value_x;
    wire [11:0] value_y;
    wire [1:0] character_state;

    // Instantiate the Unit Under Test (UUT)
    draw_rect_ctl uut (
        .clk(clk),
        .rst(reset),
        .key_space(key_space),
        .key_left(key_left),
        .key_right(key_right),
        .value_x(value_x),
        .value_y(value_y),
        .character_state(character_state)
    );

    // Clock generation
    always #5 clk = ~clk;

    // State names for display
    typedef enum logic [2:0] {
        IDLE    = 3'b000,
        FALLING = 3'b001, 
        JUMP    = 3'b010,
        LEFT   = 3'b011,
        RIGHT   = 3'b100,
        JUMP_PREP = 3'b101
    } state_t;
    

    function string state_name(input [2:0] state);
        case(state)
            IDLE: return "IDLE";
            JUMP_PREP: return "JUMP_PREP";
            JUMP: return "JUMP";
            FALLING: return "FALLING";
            LEFT: return "LEFT";
            RIGHT: return "RIGHT";
            default: return "UNKNOWN";
        endcase
    endfunction

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        key_space = 0;
        key_left = 0;
        key_right = 0;
        
        // Reset the system
        #20;
        reset = 0;
        #20;
        
        // Test IDLE state
        $display("Testing IDLE state");
        #100;
        
        // Test JUMP sequence
        $display("Testing JUMP sequence");
        key_space = 1;
        #20;
        key_space = 0;
        
        // Wait for jump to complete
        #20000;
        

               // Test RIGHT movement
        $display("Testing RIGHT movement");
        key_right = 1;
        #1000;
        key_right = 0;
        
        // Test collision with right boundary
        $display("Testing RIGHT boundary collision");
        key_right = 1;
        #1000;
        key_right = 0;

        // Test LEFT movement
        $display("Testing LEFT movement");
        key_left = 1;
        #500;
        key_left = 0;
        
        // Test collision with left boundary
        $display("Testing LEFT boundary collision");
        key_left = 1;
        #1000;
        key_left = 0;
        
        
        // Test collision with platform
        $display("Testing platform collision");
        
        // Position character below platform
        // (This would require forcing internal signals or adding testbench hooks)
        // For now we'll just jump toward the platform
        key_space = 1;
        #20;
        key_space = 0;
        #1000;
        
        // End simulation
        $display("Simulation complete");
        #1000;
        $finish;
    end

    // Monitor the outputs
    always @(posedge clk) begin
        $display("Time: %t, X: %3d, Y: %3d, State: %s->%s,key_space = %b, key_left = %b, key_right = %b, tile_above = %b,  tile_r = %b, tile_l = %b, facing = %d, tile_idx_r = %d",
                $time, 
                value_x, 
                value_y, 
                state_name(uut.state),
                state_name(uut.state_nxt),
                key_space,
                key_left,
                key_right,
                uut.tile_above,
                uut.tile_r_bottom,
                uut.tile_l_bottom,
                uut.facing,
                uut.tile_idx_r
                );
        
        // Add assertions to verify behavior
        // X position should stay within bounds
        assert(value_x >= 0 && value_x <= SCREEN_WIDTH - REC_WIDTH - 1);
        
        // Y position should stay within bounds
        assert(value_y >= 0 && value_y <= 768 - REC_HEIGHT - 1);
    end
    // Add this to your testbench to monitor states
    always @(posedge clk) begin
        if (uut.state != uut.state_nxt) begin
            $display("State change: %s -> %s at time %t", 
                    uut.state.name(), uut.state_nxt.name(), $time);
        end
    end

endmodule
