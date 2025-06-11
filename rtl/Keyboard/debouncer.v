/*
* Author: Unknown
* Company: Digilent
* 
* Modified by:
* * 2025  AGH University of Science and Technology
* MTM UEC2 Final Project
* Miłosz Płonczyński and Tomasz Machnik 
*
* Description:
* Module to handle keyboard debouncing
*/

`timescale 1ns / 1ps

module debouncer(
    input clk,
    input I,
    output reg O
    );
    parameter COUNT_MAX=255, COUNT_WIDTH=8;
    reg [COUNT_WIDTH-1:0] count;
    reg Iv=0;
    always@(posedge clk)
        if (I == Iv) begin
            if (count == COUNT_MAX)
                O <= I;
            else
                count <= count + 1'b1;
        end else begin
            count <= 'b0;
            Iv <= I;
        end
    
endmodule
