// project     : sync_fifo
// date        : 27.07.2023
// author      : siarhei baldzenka
// e-mail      : sbaldzenka@proton.me
// description : https://github.com/sbaldzenka/sync_fifo

`timescale 1ns/100ps

module sync_fifo
#(
    parameter DEPTH,
    parameter WIDTH
)
(
    // global signals
    input  wire             i_clk,
    input  wire             i_reset,
    // write data signals
    input  wire             i_wr_en,
    input  wire [WIDTH-1:0] i_data,
    // read data signals
    input  wire             i_rd_en,
    output reg              o_valid,
    output reg  [WIDTH-1:0] o_data,
    // status signals
    output wire             o_full,
    output wire             o_empty
);

    reg [WIDTH-1:0] mem [2**DEPTH-1:0];

    reg [DEPTH-1:0] push_pointer;
    reg [DEPTH-1:0] pop_pointer;

    reg             read_flag;
    reg             write_flag;

    reg             full_flag;
    reg             empty_flag;

    // WRITE DATA TO MEMORY
    always@(posedge i_clk) begin
        if (i_wr_en && !full_flag) begin
            mem[push_pointer] <= i_data;
        end
    end

    // READ DATA FROM MEMORY
    always@(posedge i_clk) begin
        if (i_rd_en && !empty_flag) begin
            o_data <= mem[pop_pointer];
        end else begin
            o_data <= 'b0;
        end
    end

    // PUSH POINTER
    always@(posedge i_clk) begin
        if (i_reset) begin
            push_pointer <= 'b0;
        end else begin
            if (i_wr_en && !full_flag) begin
                push_pointer <= push_pointer + 1'b1;
            end
        end
    end

    // POP POINTER
    always@(posedge i_clk) begin
        if (i_reset) begin
            pop_pointer <= 'b0;
        end else begin
            if (i_rd_en && !empty_flag) begin
                pop_pointer <= pop_pointer + 1'b1;
            end
        end
    end

    // FULL FLAG
    always@(posedge i_clk) begin
        if (i_reset) begin
            write_flag <= 1'b0;
        end else begin
            if (i_wr_en) begin
                write_flag <= 1'b1;
            end

            if (i_rd_en) begin
                write_flag <= 1'b0;
            end
        end
    end

    always@(*) begin
        if (i_reset) begin
            full_flag = 1'b0;
        end else begin
            if (write_flag && push_pointer == pop_pointer) begin
                full_flag = 1'b1;
            end else begin
                full_flag = 1'b0;
            end
        end
    end

    assign o_full = full_flag;

    // EMPTY FLAG
    always@(posedge i_clk) begin
        if (i_reset) begin
            read_flag <= 1'b1;
        end else begin
            if (i_rd_en) begin
                read_flag <= 1'b1;
            end

            if (i_wr_en) begin
                read_flag <= 1'b0;
            end
        end
    end

    always@(*) begin
        if (i_reset) begin
            empty_flag = 1'b1;
        end else begin
            if (read_flag && push_pointer == pop_pointer) begin
                empty_flag = 1'b1;
            end else begin
                empty_flag = 1'b0;
            end
        end
    end

    assign o_empty = empty_flag;

    // VALID SIGNAL
    always@(posedge i_clk) begin
        if (i_rd_en && !empty_flag) begin
            o_valid <= 1'b1;
        end else begin
            o_valid <= 1'b0;
        end
    end

endmodule