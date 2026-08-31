/*
---------------------------------------------------------------------------------------

MIT License

Copyright (c) 2026 Siarhei Baldzenka

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---------------------------------------------------------------------------------------

project     : sync_fifo_verilog
version     : 1.1
date        : 27.07.2023
author      : siarhei baldzenka
e-mail      : sbaldzenka@proton.me
description : https://github.com/sbaldzenka/sync_fifo

---------------------------------------------------------------------------------------
*/

`timescale 1ns/100ps

module sync_fifo
#(
    parameter FIFO_DEPTH = 8,
    parameter DATA_WIDTH = 8
)
(
    // global signals
    input  wire                  i_clk,
    input  wire                  i_reset,
    // write data signals
    input  wire                  i_wr_en,
    input  wire [DATA_WIDTH-1:0] i_data,
    // read data signals
    input  wire                  i_rd_en,
    output reg                   o_valid,
    output reg  [DATA_WIDTH-1:0] o_data,
    // status signals
    output wire                  o_full,
    output wire                  o_empty,
    output wire                  o_almost_full,
    output wire                  o_almost_empty,
    output reg                   o_underflow,
    output reg                   o_overflow
);

    // parameters
    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // signals
    reg [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
    reg [  ADDR_WIDTH:0] push_pointer;
    reg [  ADDR_WIDTH:0] pop_pointer;
    reg                  full_flag;
    reg                  almost_full_flag;
    reg                  empty_flag;
    reg                  almost_empty_flag;

    // WRITE DATA TO MEMORY
    always @(posedge i_clk) begin
        if (i_wr_en && !full_flag) begin
            mem[push_pointer[ADDR_WIDTH-1:0]] <= i_data;
        end
    end

    // READ DATA FROM MEMORY
    always @(posedge i_clk) begin
        if (i_rd_en && !empty_flag) begin
            o_data <= mem[pop_pointer[ADDR_WIDTH-1:0]];
        end else begin
            o_data <= 'b0;
        end
    end

    // PUSH POINTER
    always @(posedge i_clk) begin
        if (i_reset) begin
            push_pointer <= 'b0;
        end else begin
            if (i_wr_en && !full_flag) begin
                push_pointer <= push_pointer + 1'b1;
            end
        end
    end

    // POP POINTER
    always @(posedge i_clk) begin
        if (i_reset) begin
            pop_pointer <= 'b0;
        end else begin
            if (i_rd_en && !empty_flag) begin
                pop_pointer <= pop_pointer + 1'b1;
            end
        end
    end

    // FULL FLAG
    always @(*) begin
        if (i_reset) begin
            full_flag = 1'b0;
        end else begin
            if (push_pointer[ADDR_WIDTH] == ~pop_pointer[ADDR_WIDTH] &&
                push_pointer[ADDR_WIDTH-1:0] == pop_pointer[ADDR_WIDTH-1:0]) begin
                full_flag = 1'b1;
            end else begin
                full_flag = 1'b0;
            end
        end
    end

    assign o_full = full_flag;

    // ALMOST FULL FLAG
    always @(*) begin
        if (i_reset) begin
            almost_full_flag = 1'b0;
        end else begin
            if (push_pointer == pop_pointer - 1'b1) begin
                almost_full_flag = 1'b1;
            end else begin
                almost_full_flag = 1'b0;
            end
        end
    end

    assign o_almost_full = almost_full_flag | full_flag;

    // EMPTY FLAG
    always @(*) begin
        if (i_reset) begin
            empty_flag = 1'b1;
        end else begin
            if (pop_pointer == push_pointer) begin
                empty_flag = 1'b1;
            end else begin
                empty_flag = 1'b0;
            end
        end
    end

    assign o_empty = empty_flag;

    // ALMOST EMPTY FLAG
    always @(*) begin
        if (i_reset) begin
            almost_empty_flag = 1'b0;
        end else begin
            if (pop_pointer == push_pointer - 1'b1) begin
                almost_empty_flag = 1'b1;
            end else begin
                almost_empty_flag = 1'b0;
            end
        end
    end

    assign o_almost_empty = almost_empty_flag | empty_flag;

    // VALID SIGNAL
    always @(posedge i_clk) begin
        if (i_rd_en && !empty_flag) begin
            o_valid <= 1'b1;
        end else begin
            o_valid <= 1'b0;
        end
    end

    // UNDERFLOW
    always @(posedge i_clk) begin
        if (empty_flag && i_rd_en) begin
            o_underflow <= 1'b1;
        end else begin
            o_underflow <= 1'b0;
        end
    end

    // OVERFLOW
    always @(posedge i_clk) begin
        if (full_flag && i_wr_en) begin
            o_overflow <= 1'b1;
        end else begin
            o_overflow <= 1'b0;
        end
    end

endmodule