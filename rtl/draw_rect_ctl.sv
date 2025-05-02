module draw_rect_ctl (
    input logic clk,
    input logic rst,
    input logic key_space,
    input logic key_right,
    input logic key_left,
    output logic [11:0] value_x,
    output logic [11:0] value_y
);

localparam int SCREEN_HEIGHT = 600;
localparam int RECT_HEIGHT = 64;
localparam int CLOCKS_PER_MS = 1_000_000; 
localparam int A = 2;
localparam int ENERGY_LOSS_FACTOR = 80;
logic [11:0] position_y;
logic signed [15:0] velocity_y;
logic [11:0] time_passed; 
logic [25:0] cycle_counter;
logic key_space_prev;


typedef enum logic [1:0] {IDLE, FALLING, BOUNCE} state_t;
state_t state;              

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        value_x <= 12'h000;
        value_y <= SCREEN_HEIGHT - RECT_HEIGHT - 1;
        position_y <= SCREEN_HEIGHT - RECT_HEIGHT - 1;
        velocity_y <= 0;
        cycle_counter <= 26'h0000000;
        time_passed <= 0;
        state <= IDLE;
        key_space_prev <= 1'b0;
    end else begin
        key_space_prev <= key_space;
        state <= IDLE;
        

        case (state)
            IDLE: begin
                value_x <= value_x;
                value_y <= value_y;
                position_y <= position_y;
                time_passed <= 0;
                if (key_space && !key_space_prev) begin
                    velocity_y <= $signed(-20);
                    state <= BOUNCE;
                end else begin
                    state <= IDLE;
                end
            end

            FALLING: begin
                value_x <= value_x; 
                if (cycle_counter == CLOCKS_PER_MS - 1) begin
                    cycle_counter <= 0; 
                    if (position_y  + ((A*time_passed*time_passed)/2) < SCREEN_HEIGHT - RECT_HEIGHT - 1) begin
                        time_passed <= time_passed + 1;
                        position_y <= position_y  + ((A*time_passed*time_passed)/2);
                        value_y <= position_y + ((A*time_passed*time_passed)/2);
                        velocity_y <= A * time_passed;
                        state <= FALLING;
                    end else begin
                        value_y <= SCREEN_HEIGHT - RECT_HEIGHT - 1;
                        position_y <= SCREEN_HEIGHT - RECT_HEIGHT - 1;
                        if (velocity_y <= 2) begin
                            state <= IDLE; 
                        end else begin
                        velocity_y <= -(velocity_y * ENERGY_LOSS_FACTOR)/100;
                        time_passed <= 0; 
                        state <= BOUNCE;
                        end
                    end
                end else begin
                    cycle_counter <= cycle_counter + 1; 
                    state <= FALLING; 
                end
            end

            BOUNCE: begin
                value_x <= value_x;
                if (cycle_counter == CLOCKS_PER_MS - 1) begin
                    cycle_counter <= 0;
                    if (velocity_y >= 0) begin
                        time_passed <= 0; 
                        state <= FALLING;
                    end else begin
                        time_passed <= time_passed + 1;
                        velocity_y <= velocity_y + $signed(A*time_passed); 
                        position_y <= position_y  - (velocity_y*velocity_y)/(A*2); 
                        value_y <= position_y - (velocity_y*velocity_y)/(A*2);
                        state <= BOUNCE;
                    end
                end else begin
                    cycle_counter <= cycle_counter + 1;
                    state <= BOUNCE;
                end
            end


        endcase
    end
end



endmodule