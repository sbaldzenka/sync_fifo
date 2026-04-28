-- project     : sync_fifo
-- date        : 14.04.2026
-- author      : siarhei baldzenka
-- e-mail      : sbaldzenka@proton.me
-- description : https://github.com/sbaldzenka/sync_fifo/sync_fifo_vhdl

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity sync_fifo_tb is
generic
(
    FIFO_DEPTH : integer := 8;
    DATA_WIDTH : integer := 8
);
end sync_fifo_tb;

architecture behavioral of sync_fifo_tb is

    component sync_fifo is
    generic
    (
        FIFO_DEPTH : integer;
        DATA_WIDTH : integer
    );
    port
    (
        -- global signals
        i_clk       : in  std_logic;
        i_reset     : in  std_logic;
        -- write data signals
        i_wr_en     : in  std_logic;
        i_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        -- read data signals
        i_rd_en     : in  std_logic;
        o_valid     : out std_logic;
        o_data      : out std_logic_vector(DATA_WIDTH-1 downto 0);
        -- status signals
        o_full      : out std_logic;
        o_empty     : out std_logic;
        o_overflow  : out std_logic;
        o_underflow : out std_logic
    );
    end component;

    -- constants
    constant clk_period : time := 20 ns; --50 MHz

    -- signals
    signal clk        : std_logic;
    signal reset      : std_logic;
    signal wr_en      : std_logic;
    signal data_in    : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal wr_en_ff   : std_logic;
    signal data_in_ff : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rd_en      : std_logic;
    signal rd_en_ff   : std_logic;
    signal valid      : std_logic;
    signal data_out   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal full       : std_logic;
    signal empty      : std_logic;
    signal overflow   : std_logic;
    signal underflow  : std_logic;

begin

    CLK_GENERATE: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    RESET_GENERATE: process
    begin
        reset <= '0';
        wait for 0.1 us;
        reset <= '1';
        wait for 0.1 us;
        reset <= '0';
        wait;
    end process;

    DATA_PROC: process
    begin
        wr_en   <= '0';
        rd_en   <= '0';
        data_in <= (others => '0');
        wait for 1 us;
        wait until falling_edge(clk);

        for index in 0 to 3 loop
            wr_en   <= '1';
            data_in <= data_in + '1';
            wait for clk_period;
        end loop;

        wr_en <= '0';
        wait for 1 us;

        rd_en <= '1';
        wait for clk_period*4;
        rd_en <= '0';

        wait for 1 us;
        wait until falling_edge(clk);
        rd_en <= '1';
        wait for clk_period*4;
        rd_en <= '0';

        wait for 1 us;
        wait until falling_edge(clk);

        for index in 0 to 4 loop
            wr_en   <= '1';
            data_in <= data_in + '1';
            wait for clk_period;
        end loop;

        wr_en <= '0';

        wait for 1 us;
        wait until falling_edge(clk);

        for index in 0 to 4 loop
            wr_en   <= '1';
            data_in <= data_in + '1';
            wait for clk_period;
        end loop;

        wr_en <= '0';

        wait for 1 us;
        wait until falling_edge(clk);
        rd_en <= '1';
        wait for clk_period*8;
        rd_en <= '0';
        wait for 1 us;
        wait;
    end process;

    SIGNALS_FF: process(clk)
    begin
        if rising_edge(clk) then
            wr_en_ff   <= wr_en;
            rd_en_ff   <= rd_en;
            data_in_ff <= data_in;
        end if;
    end process;

    DUT_inst: sync_fifo
    generic map
    (
        FIFO_DEPTH => FIFO_DEPTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map
    (
        i_clk       => clk,
        i_reset     => reset,
        i_wr_en     => wr_en_ff,
        i_data      => data_in_ff,
        i_rd_en     => rd_en_ff,
        o_valid     => valid,
        o_data      => data_out,
        o_full      => full,
        o_empty     => empty,
        o_overflow  => overflow,
        o_underflow => underflow
    );

end behavioral;
