// project     : sync_fifo
// date        : 27.07.2023
// author      : siarhei baldzenka
// e-mail      : sbaldzenka@proton.me
// description : https://github.com/sbaldzenka/sync_fifo/sync_fifo_verilog

`timescale 1ns/100ps

module sync_fifo_testbench();

    integer     index;
    real        sys_clk_period = 10.000;

    reg         sys_clk = 1'b0;
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

    always #(sys_clk_period / 2) sys_clk = ~sys_clk;

    task reset_generate;
        begin
            #0   reset <= 1'b0;
            #100 reset <= 1'b1;
            #500 reset <= 1'b0;
        end
    endtask

    initial begin
        reset_generate();
        i_wr_en = 1'b0;
        i_data  = 8'h00;
        i_rd_en = 1'b0;

        #1000;
        @(negedge sys_clk);
        for (index = 0; index < 8; index = index + 1) begin
            i_wr_en = 1'b1;
            i_data  = i_data + 1'b1;
            #10;
        end

        i_wr_en = 1'b0;
        i_data  = 8'h00;

        #1000;
        i_rd_en <= 1'b1;
        #40;
        i_rd_en <= 1'b0;

        #100;
        i_rd_en <= 1'b1;
        #40;
        i_rd_en <= 1'b0;

        #1000;
        @(negedge sys_clk);
        for (index = 0; index < 5; index = index + 1) begin
            i_wr_en = 1'b1;
            i_data  = i_data + 1'b1;
            #10;
        end

        i_wr_en = 1'b0;
        i_data  = 8'h00;

        #2000;
        @(negedge sys_clk);
        for (index = 0; index < 5; index = index + 1) begin
            i_wr_en = 1'b1;
            i_data  = i_data + 1'b1;
            #10;
        end

        i_wr_en = 1'b0;
        i_data  = 8'h00;

        #1000;
        i_rd_en <= 1'b1;
        #40;
        i_rd_en <= 1'b0;

        #100;
        i_rd_en <= 1'b1;
        #40;
        i_rd_en <= 1'b0;

        #1000;
        @(negedge sys_clk);
        for (index = 0; index < 8; index = index + 1) begin
            i_wr_en = 1'b1;
            i_data  = i_data + 1'b1;
            #10;
        end

        i_wr_en = 1'b0;
        i_data  = 8'h00;

        #1000;
        i_rd_en <= 1'b1;
        #40;
        i_rd_en <= 1'b0;

        #1000;
        @(negedge sys_clk);
        for (index = 0; index < 4; index = index + 1) begin
            i_wr_en = 1'b1;
            i_data  = i_data + 1'b1;
            #10;
        end

        i_wr_en = 1'b0;
        i_data  = 8'h00;

        #1000;
        i_rd_en <= 1'b1;
        #80;
        i_rd_en <= 1'b0;
    end

    always@(posedge sys_clk) begin
        i_wr_en_ff <= i_wr_en;
        i_data_ff  <= i_data;
        i_rd_en_ff <= i_rd_en;
    end

    defparam DUT_inst.DEPTH = 3;
    defparam DUT_inst.WIDTH = 8;

    sync_fifo DUT_inst
    (
        .i_clk   ( sys_clk    ),
        .i_reset ( reset      ),
        .i_wr_en ( i_wr_en_ff ),
        .i_data  ( i_data_ff  ),
        .o_valid ( o_valid    ),
        .o_data  ( o_data     ),
        .i_rd_en ( i_rd_en_ff ),
        .o_full  ( o_full     ),
        .o_empty ( o_empty    )
    );

endmodule