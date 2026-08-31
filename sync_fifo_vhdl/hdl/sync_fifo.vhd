---------------------------------------------------------------------------------------
--
-- MIT License
--
-- Copyright (c) 2026 Siarhei Baldzenka
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- ---------------------------------------------------------------------------------------
--
-- project     : sync_fifo_vhdl
-- version     : 1.1
-- date        : 14.04.2026
-- author      : siarhei baldzenka
-- e-mail      : sbaldzenka@proton.me
-- description : https://github.com/sbaldzenka/sync_fifo
--
-- ---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use Ieee.std_logic_unsigned.all;
use ieee.math_real.all;

entity sync_fifo is
generic
(
    FIFO_DEPTH : integer := 8;
    DATA_WIDTH : integer := 8
);
port
(
    -- global signals
    i_clk          : in  std_logic;
    i_reset        : in  std_logic;
    -- write data signals
    i_wr_en        : in  std_logic;
    i_data         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    -- read data signals
    i_rd_en        : in  std_logic;
    o_valid        : out std_logic;
    o_data         : out std_logic_vector(DATA_WIDTH-1 downto 0);
    -- status signals
    o_full         : out std_logic;
    o_empty        : out std_logic;
    o_almost_full  : out std_logic;
    o_almost_empty : out std_logic;
    o_overflow     : out std_logic;
    o_underflow    : out std_logic
);
end sync_fifo;

architecture rtl of sync_fifo is

    -- types
    type mem_array is array(FIFO_DEPTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

    -- constants
    constant ADDR_WIDTH      : integer := integer(ceil(log2(real(FIFO_DEPTH))));

    -- signals
    signal mem               : mem_array;
    signal push_pointer      : std_logic_vector(ADDR_WIDTH downto 0);
    signal pop_pointer       : std_logic_vector(ADDR_WIDTH downto 0);
    signal almost_full_flag  : std_logic;
    signal almost_empty_flag : std_logic;
    signal full_flag         : std_logic;
    signal empty_flag        : std_logic;

begin

    full_flag         <= '1' when (push_pointer(ADDR_WIDTH) = not pop_pointer(ADDR_WIDTH) and
                                push_pointer(ADDR_WIDTH-1 downto 0) = pop_pointer(ADDR_WIDTH-1 downto 0)) else '0';
    empty_flag        <= '1' when (pop_pointer = push_pointer) else '0';

    almost_full_flag  <= '1' when (push_pointer(ADDR_WIDTH) = not pop_pointer(ADDR_WIDTH) and
                                   push_pointer(ADDR_WIDTH-1 downto 0) = pop_pointer(ADDR_WIDTH-1 downto 0) - '1') else '0';
    almost_empty_flag <= '1' when (pop_pointer = push_pointer - '1') else '0';

    o_full            <= full_flag;
    o_empty           <= empty_flag;

    o_almost_full     <= full_flag or almost_full_flag;
    o_almost_empty    <= empty_flag or almost_empty_flag;

    PUSH_POINTER_CALC: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_reset = '1') then
                push_pointer <= (others => '0');
            elsif (i_wr_en = '1' and full_flag = '0') then
                push_pointer <= push_pointer + '1';
            end if;
        end if;
    end process;

    WRITE_DATA: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_wr_en = '1' and full_flag = '0') then
                mem(conv_integer(push_pointer(ADDR_WIDTH-1 downto 0))) <= i_data;
            end if;
        end if;
    end process;

    POP_POINTER_CALC: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_reset = '1') then
                pop_pointer <= (others => '0');
            elsif (i_rd_en = '1' and empty_flag = '0') then
                pop_pointer <= pop_pointer + '1';
            end if;
        end if;
    end process;

    READ_DATA: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_rd_en = '1' and empty_flag = '0') then
                o_valid <= '1';
                o_data  <= mem(conv_integer(pop_pointer(ADDR_WIDTH-1 downto 0)));
            else
                o_valid <= '0';
                o_data  <= (others => '0');
            end if;
        end if;
    end process;

    OVERFLOW_GEN: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_wr_en = '1' and full_flag = '1') then
                o_overflow <= '1';
            else
                o_overflow <= '0';
            end if;
        end if;
    end process;

    UNDERFLOW_GEN: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_rd_en = '1' and empty_flag = '1') then
                o_underflow <= '1';
            else
                o_underflow <= '0';
            end if;
        end if;
    end process;

end rtl;