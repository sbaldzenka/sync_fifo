-- project     : sync_fifo_verilog
-- version     : 1.0
-- date        : 27.07.2023
-- author      : siarhei baldzenka
-- e-mail      : sbaldzenka@proton.me
-- description : https://github.com/sbaldzenka/sync_fifo

-- Waves
add wave -noupdate -divider testbench
add wave -noupdate -format Logic -radix HEXADECIMAL -group {testbench} /sync_fifo_testbench/*

add wave -noupdate -divider sync_fifo
add wave -noupdate -format Logic -radix HEXADECIMAL -group {sync_fifo} /sync_fifo_testbench/DUT_inst/*

-- Toggle leaf names command:
config wave -signalnamewidth 1