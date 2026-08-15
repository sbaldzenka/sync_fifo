// project     : sync_fifo_verilog
// date        : 27.07.2023
// author      : siarhei baldzenka
// e-mail      : sbaldzenka@proton.me
// description : https://github.com/sbaldzenka/sync_fifo

`timescale 1ns/100ps

module sync_fifo_testbench
#(
    parameter CLK_PERIOD = 10.000,
    parameter FIFO_DEPTH = 16,
    parameter DATA_WIDTH = 8
);

    // variables
    integer     index;

    // signals
    reg         sys_clk;
    reg         reset;

    reg         i_wr_en;
    reg   [7:0] i_data;
    reg         i_rd_en;

    reg         i_wr_en_ff;
    reg   [7:0] i_data_ff;
    reg         i_rd_en_ff;

    wire        o_valid;
    wire  [7:0] o_data;

    wire        o_full;
    wire        o_empty;
    wire        o_almost_full;
    wire        o_almost_empty;
    wire        o_overflow;
    wire        o_underflow;

    always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

    task reset_generate;
        begin
            #0   reset = 1'b0;
            #100 reset = 1'b1;
            #500 reset = 1'b0;
        end
    endtask

    task write_data;
        input integer number_of_words;

        begin
            #1000;
            @(negedge sys_clk);
            for (index = 0; index < number_of_words; index = index + 1) begin
                i_wr_en = 1'b1;
                i_data  = i_data + 1'b1;
                #10;
            end

            i_wr_en = 1'b0;
            i_data  = 8'h00;
        end
    endtask

    task read_data;
        input integer number_of_words;

        begin
            #1000;
            i_rd_en = 1'b1;
            #(CLK_PERIOD*number_of_words);
            i_rd_en = 1'b0;
        end
    endtask

    initial begin
        sys_clk = 1'b0;
        i_wr_en = 1'b0;
        i_data  = 8'h00;
        i_rd_en = 1'b0;
    end

    initial begin
        reset_generate();
        write_data(8);
        read_data(4);
        read_data(5);
        read_data(4);
        write_data(19);
        read_data(16);
    end

    always@(posedge sys_clk) begin
        i_wr_en_ff <= i_wr_en;
        i_data_ff  <= i_data;
        i_rd_en_ff <= i_rd_en;
    end

    defparam DUT_inst.FIFO_DEPTH = FIFO_DEPTH;
    defparam DUT_inst.DATA_WIDTH = DATA_WIDTH;

    sync_fifo DUT_inst
    (
        .i_clk          ( sys_clk        ),
        .i_reset        ( reset          ),
        .i_wr_en        ( i_wr_en_ff     ),
        .i_data         ( i_data_ff      ),
        .o_valid        ( o_valid        ),
        .o_data         ( o_data         ),
        .i_rd_en        ( i_rd_en_ff     ),
        .o_full         ( o_full         ),
        .o_empty        ( o_empty        ),
        .o_almost_full  ( o_almost_full  ),
        .o_almost_empty ( o_almost_empty ),
        .o_overflow     ( o_overflow     ),
        .o_underflow    ( o_underflow    )
    );

endmodule