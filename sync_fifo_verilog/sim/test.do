-- project     : sync_fifo_verilog
-- version     : 1.1
-- date        : 27.07.2023
-- author      : siarhei baldzenka
-- e-mail      : sbaldzenka@proton.me
-- description : https://github.com/sbaldzenka/sync_fifo

vlib work
vmap work work

vlog ../tb/sync_fifo_testbench.v
vlog ../hdl/sync_fifo.v

vsim -t 1ps -voptargs=+acc=lprn -lib work sync_fifo_testbench

do wave_test.do
view wave
run 10 us