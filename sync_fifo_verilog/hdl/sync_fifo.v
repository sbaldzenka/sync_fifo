// project     : sync_fifo
// date        : 27.07.2023
// author      : siarhei baldzenka
// e-mail      : sbaldzenka@proton.me
// description : https://github.com/sbaldzenka/sync_fifo/sync_fifo_verilog

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
    output wire                  o_underflow,
    output wire                  o_overflow
);

    // parameters
    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // signals
    reg [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
    reg [ADDR_WIDTH-1:0] push_pointer;
    reg [ADDR_WIDTH-1:0] pop_pointer;
    reg                  read_flag;
    reg                  write_flag;
    reg                  full_flag;
    reg                  empty_flag;

    assign o_overflow  = (full_flag && i_wr_en) ? 1'b1 : 1'b0;
    assign o_underflow = (empty_flag && i_rd_en) ? 1'b1 : 1'b0;

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

    // WRITE FLAG
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

    // FULL FLAG
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

    // READ FLAG
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

    // EMPTY FLAG
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