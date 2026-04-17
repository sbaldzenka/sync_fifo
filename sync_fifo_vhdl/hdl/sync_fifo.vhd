-- project     : sync_fifo
-- date        : 14.04.2026
-- author      : siarhei baldzenka
-- e-mail      : sbaldzenka@proton.me
-- description : https://github.com/sbaldzenka/sync_fifo/sync_fifo_vhdl

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_fifo is
generic
(
    FIFO_DEPTH : integer := 8;
    DATA_WIDTH : integer := 8
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
end sync_fifo;

architecture rtl of sync_fifo is

    -- types
    type mem_array is array(FIFO_DEPTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

    -- signals
    signal mem          : mem_array;
    signal push_pointer : integer range 0 to FIFO_DEPTH-1;
    signal pop_pointer  : integer range 0 to FIFO_DEPTH-1;
    signal write_flag   : std_logic;
    signal read_flag    : std_logic;
    signal full_flag    : std_logic;
    signal empty_flag   : std_logic;

begin

    full_flag   <= '1' when (write_flag = '1' and push_pointer = pop_pointer) else '0';
    empty_flag  <= '1' when (read_flag = '1' and push_pointer = pop_pointer) else '0';
    o_overflow  <= '1' when (i_wr_en = '1' and full_flag = '1') else '0';
    o_underflow <= '1' when (i_rd_en = '1' and empty_flag = '1') else '0';
    o_full      <= full_flag;
    o_empty     <= empty_flag;

    PUSH_POINTER_CALC: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_reset = '1') then
                push_pointer <= 0;
            elsif (i_wr_en = '1' and full_flag = '0') then
                if (push_pointer = FIFO_DEPTH-1) then
                    push_pointer <= 0;
                else
                    push_pointer <= push_pointer + 1;
                end if;
            end if;
        end if;
    end process;

    WRITE_DATA: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_wr_en = '1' and full_flag = '0') then
                mem(push_pointer) <= i_data;
            end if;
        end if;
    end process;

    WRITE_FLAG_GEN: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_reset = '1') then
                write_flag <= '0';
            else
                if (i_wr_en = '1') then
                    write_flag <= '1';
                end if;

                if (i_rd_en = '1') then
                    write_flag <= '0';
                end if;
            end if;
        end if;
    end process;

    POP_POINTER_CALC: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_reset = '1') then
                pop_pointer <= 0;
            elsif (i_rd_en = '1' and empty_flag = '0') then
                if (pop_pointer = FIFO_DEPTH-1) then
                    pop_pointer <= 0;
                else
                    pop_pointer <= pop_pointer + 1;
                end if;
            end if;
        end if;
    end process;

    READ_DATA: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_rd_en = '1' and empty_flag = '0') then
                o_data <= mem(pop_pointer);
            else
                o_data <= (others => '0');
            end if;
        end if;
    end process;

    READ_FLAG_GEN: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_reset = '1') then
                read_flag <= '1';
            else
                if (i_wr_en = '1') then
                    read_flag <= '0';
                end if;

                if (i_rd_en = '1') then
                    read_flag <= '1';
                end if;
            end if;
        end if;
    end process;

    VALID_GEN: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_rd_en = '1' and empty_flag = '0') then
                o_valid <= '1';
            else
                o_valid <= '0';
            end if;
        end if;
    end process;

end rtl;