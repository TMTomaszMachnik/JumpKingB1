/*
* Authors:
* * 2025  AGH University of Science and Technology
* MTM UEC2 Final Project
* Miłosz Płonczyński and Tomasz Machnik 
*
* Description:
* Modified module to handle UART data transmission
*/



module data_tx (
    input  logic        clk,                // Synchronous reset and clock
    input  logic        rst,

    input  logic        tx_full_1,          //  UART transmission data for channel 1
    input  logic [7:0]  data_in_1,
    output logic [7:0]  w_data_1,   
    output logic        wr_uart_1,

    input  logic        tx_full_2,          //  UART transmission data for channel 2
    input  logic [7:0]  data_in_2,
    output logic [7:0]  w_data_2,   
    output logic        wr_uart_2,

    input  logic        tx_full_3,          //  UART transmission data for channel 3
    input  logic [7:0]  data_in_3,
    output logic [7:0]  w_data_3,   
    output logic        wr_uart_3
);

    /**
     * Registers to hold next state values for data and write signals
     */

logic [7:0] w_data_nxt_1;
logic wr_uart_nxt_1;
logic [7:0] w_data_nxt_2;  
logic wr_uart_nxt_2;
logic [7:0] w_data_nxt_3;
logic wr_uart_nxt_3;


    /**
     * Data transmission logic + reset logic
     */

always_ff @(posedge clk) begin
    if (rst) begin
        w_data_1 <= 8'b01000110;    // Default values corresponding to start x,y values and default level
        wr_uart_1 <= 1'b0;
        w_data_2 <= 8'b00001000;
        wr_uart_2 <= 1'b0;
        w_data_3 <= 8'b0010100;
        wr_uart_3 <= 1'b0;

    end else begin
        w_data_1 <= w_data_nxt_1;
        wr_uart_1 <= wr_uart_nxt_1; 
        w_data_2 <= w_data_nxt_2;
        wr_uart_2 <= wr_uart_nxt_2;
        w_data_3 <= w_data_nxt_3;
        wr_uart_3 <= wr_uart_nxt_3;
    end
end

always_comb begin
    if (!tx_full_1) begin
        w_data_nxt_1 = data_in_1;
        wr_uart_nxt_1 = 1'b1;
    end else begin
        w_data_nxt_1 = 8'b0;
        wr_uart_nxt_1 = 1'b0;
    end

    if (!tx_full_2) begin
        w_data_nxt_2 = data_in_2;
        wr_uart_nxt_2 = 1'b1;
    end else begin
        w_data_nxt_2 = 8'b0;
        wr_uart_nxt_2 = 1'b0;
    end

    if (!tx_full_3) begin
        w_data_nxt_3 = data_in_3;
        wr_uart_nxt_3 = 1'b1;
    end else begin
        w_data_nxt_3 = 8'b0;
        wr_uart_nxt_3 = 1'b0;
    end
end

endmodule