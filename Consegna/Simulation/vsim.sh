#!/usr/bin/env bash

VHDL_SOURCES="./sources.f"

vlib work

vcom -F $VHDL_SOURCES -2008

# GUI interface
vsim -onfinish stop -do sim.do tb	

exec rm -r work/ vsim.wlf transcript
