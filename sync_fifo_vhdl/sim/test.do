-- project     : sync_fifo
-- date        : 14.04.2026
-- author      : siarhei baldzenka
-- e-mail      : sbaldzenka@proton.me
-- description : https://github.com/sbaldzenka/sync_fifo

vlib work
vmap work work

vcom -93 ../tb/sync_fifo_tb.vhd
vcom -93 ../hdl/sync_fifo.vhd

vsim -t 1ps -voptargs=+acc=lprn -lib work sync_fifo_tb

do wave_test.do
view wave
run 12 us